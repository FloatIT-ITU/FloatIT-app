const admin = require('firebase-admin');

// Initialize Firebase Admin SDK
let serviceAccount = null;
if (process.env.FIREBASE_SERVICE_ACCOUNT) {
  try {
    serviceAccount = JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT);
  } catch (err) {
    console.error('FIREBASE_SERVICE_ACCOUNT is not valid JSON:', err.message);
    return res.status(500).json({ error: 'Invalid Firebase credentials' });
  }
} else {
  if (!process.env.FIREBASE_PROJECT_ID || !process.env.FIREBASE_PRIVATE_KEY || !process.env.FIREBASE_CLIENT_EMAIL) {
    console.error('Missing Firebase credentials');
    return res.status(500).json({ error: 'Missing Firebase credentials' });
  }

  serviceAccount = {
    type: 'service_account',
    project_id: process.env.FIREBASE_PROJECT_ID,
    private_key_id: 'auto-generated-key',
    private_key: process.env.FIREBASE_PRIVATE_KEY.replace(/\\n/g, '\n'),
    client_email: process.env.FIREBASE_CLIENT_EMAIL,
    client_id: 'auto-generated',
    auth_uri: 'https://accounts.google.com/o/oauth2/auth',
    token_uri: 'https://oauth2.googleapis.com/token',
    auth_provider_x509_cert_url: 'https://www.googleapis.com/oauth2/v1/certs',
    client_x509_cert_url: `https://www.googleapis.com/robot/v1/metadata/x509/${process.env.FIREBASE_CLIENT_EMAIL}`
  };
}

if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    databaseURL: `https://${serviceAccount.project_id}.firebaseio.com`
  });
}

const db = admin.firestore();

/**
 * Send admin notifications to all-users topic
 */
async function sendAdminNotifications() {
  try {
    // Get pending admin notifications
    const pendingNotifications = await db.collection('admin_notifications')
      .where('status', '==', 'pending')
      .get();

    if (pendingNotifications.empty) {
      console.log('No pending admin notifications');
      return { processed: 0 };
    }

    console.log(`Found ${pendingNotifications.size} pending admin notifications`);
    let processed = 0;

    for (const doc of pendingNotifications.docs) {
      const data = doc.data();
      const { title, body } = data;

      console.log(`Sending admin notification: ${title}`);

      // Send to all-users topic
      const message = {
        notification: {
          title: title,
          body: body
        },
        data: {
          type: 'admin',
          timestamp: new Date().toISOString()
        },
        topic: 'all-users'
      };

      try {
        const response = await admin.messaging().send(message);
        console.log(`Admin notification sent successfully: ${response}`);

        // Mark as sent
        await doc.ref.update({
          status: 'sent',
          sentAt: new Date().toISOString()
        });
        processed++;
      } catch (error) {
        console.error(`Error sending admin notification ${doc.id}:`, error);
        // Mark as failed
        await doc.ref.update({
          status: 'failed',
          error: error.message,
          failedAt: new Date().toISOString()
        });
      }
    }

    return { processed };

  } catch (error) {
    console.error('Error processing admin notifications:', error);
    throw error;
  }
}

/**
 * Send event notifications to event attendees
 */
async function sendEventNotifications() {
  try {
    // Get pending event notifications
    const pendingNotifications = await db.collection('event_notifications')
      .where('status', '==', 'pending')
      .get();

    if (pendingNotifications.empty) {
      console.log('No pending event notifications');
      return { processed: 0 };
    }

    console.log(`Found ${pendingNotifications.size} pending event notifications`);
    let processed = 0;

    for (const doc of pendingNotifications.docs) {
      const data = doc.data();
      const { eventId, title, body } = data;

      console.log(`Sending event notification for event ${eventId}: ${title}`);

      try {
        // Get event data to find attendees
        const eventDoc = await db.collection('events').doc(eventId).get();
        if (!eventDoc.exists) {
          console.log(`Event ${eventId} not found, skipping notification`);
          await doc.ref.update({
            status: 'failed',
            error: 'Event not found',
            failedAt: new Date().toISOString()
          });
          continue;
        }

        const eventData = eventDoc.data();
        const attendees = eventData.attendees || [];
        const waitingList = eventData.waitingListUids || [];
        const allRecipients = [...new Set([...attendees, ...waitingList])];

        if (allRecipients.length === 0) {
          console.log(`No recipients for event ${eventId}, marking as sent`);
          await doc.ref.update({
            status: 'sent',
            sentAt: new Date().toISOString()
          });
          processed++;
          continue;
        }

        // Get FCM tokens for all recipients
        const tokens = [];
        for (const userId of allRecipients) {
          const userTokens = await db.collection('fcm_tokens')
            .doc(userId)
            .collection('tokens')
            .get();

          userTokens.forEach(tokenDoc => {
            const tokenData = tokenDoc.data();
            if (tokenData.token) {
              tokens.push(tokenData.token);
            }
          });
        }

        if (tokens.length === 0) {
          console.log(`No FCM tokens found for event ${eventId} recipients`);
          await doc.ref.update({
            status: 'sent',
            sentAt: new Date().toISOString()
          });
          processed++;
          continue;
        }

        console.log(`Sending to ${tokens.length} tokens for event ${eventId}`);

        // Send notification to all attendee tokens
        const message = {
          notification: {
            title: title,
            body: body
          },
          data: {
            type: 'event',
            eventId: eventId,
            timestamp: new Date().toISOString()
          },
          tokens: tokens
        };

        const response = await admin.messaging().sendMulticast(message);
        console.log(`Event notification sent: ${response.successCount} success, ${response.failureCount} failed`);

        // Mark as sent
        await doc.ref.update({
          status: 'sent',
          sentAt: new Date().toISOString(),
          recipientCount: allRecipients.length,
          tokenCount: tokens.length,
          successCount: response.successCount,
          failureCount: response.failureCount
        });
        processed++;

      } catch (error) {
        console.error(`Error sending event notification ${doc.id}:`, error);
        // Mark as failed
        await doc.ref.update({
          status: 'failed',
          error: error.message,
          failedAt: new Date().toISOString()
        });
      }
    }

    return { processed };

  } catch (error) {
    console.error('Error processing event notifications:', error);
    throw error;
  }
}

/**
 * Send personal message notifications to recipients
 */
async function sendMessageNotifications() {
  try {
    // Get pending message notifications
    const pendingNotifications = await db.collection('message_notifications')
      .where('status', '==', 'pending')
      .get();

    if (pendingNotifications.empty) {
      console.log('No pending message notifications');
      return { processed: 0 };
    }

    console.log(`Found ${pendingNotifications.size} pending message notifications`);
    let processed = 0;

    for (const doc of pendingNotifications.docs) {
      const data = doc.data();
      const { recipientId, senderId, senderName, message, conversationId } = data;

      console.log(`Sending message notification to ${recipientId} from ${senderName}`);

      try {
        // Get FCM tokens for the recipient
        const userTokens = await db.collection('fcm_tokens')
          .doc(recipientId)
          .collection('tokens')
          .get();

        const tokens = [];
        userTokens.forEach(tokenDoc => {
          const tokenData = tokenDoc.data();
          if (tokenData.token) {
            tokens.push(tokenData.token);
          }
        });

        if (tokens.length === 0) {
          console.log(`No FCM tokens found for user ${recipientId}`);
          await doc.ref.update({
            status: 'sent',
            sentAt: new Date().toISOString()
          });
          processed++;
          continue;
        }

        console.log(`Sending to ${tokens.length} tokens for user ${recipientId}`);

        // Truncate message if too long for notification
        const truncatedMessage = message.length > 100
          ? message.substring(0, 97) + '...'
          : message;

        // Send notification to recipient's tokens
        const notificationMessage = {
          notification: {
            title: `Message from ${senderName}`,
            body: truncatedMessage
          },
          data: {
            type: 'message',
            senderId: senderId,
            senderName: senderName,
            conversationId: conversationId,
            timestamp: new Date().toISOString()
          },
          tokens: tokens
        };

        const response = await admin.messaging().sendMulticast(notificationMessage);
        console.log(`Message notification sent: ${response.successCount} success, ${response.failureCount} failed`);

        // Mark as sent
        await doc.ref.update({
          status: 'sent',
          sentAt: new Date().toISOString(),
          tokenCount: tokens.length,
          successCount: response.successCount,
          failureCount: response.failureCount
        });
        processed++;

      } catch (error) {
        console.error(`Error sending message notification ${doc.id}:`, error);
        // Mark as failed
        await doc.ref.update({
          status: 'failed',
          error: error.message,
          failedAt: new Date().toISOString()
        });
      }
    }

    return { processed };

  } catch (error) {
    console.error('Error processing message notifications:', error);
    throw error;
  }
}

/**
 * Send feedback notifications to all admins
 */
async function sendFeedbackNotifications() {
  try {
    // Get pending feedback notifications
    const pendingNotifications = await db.collection('feedback_notifications')
      .where('status', '==', 'pending')
      .get();

    if (pendingNotifications.empty) {
      console.log('No pending feedback notifications');
      return { processed: 0 };
    }

    console.log(`Found ${pendingNotifications.size} pending feedback notifications`);
    let processed = 0;

    for (const doc of pendingNotifications.docs) {
      const data = doc.data();
      const { userId, userName, userEmail, message } = data;

      console.log(`Sending feedback notification for feedback from ${userName}`);

      try {
        // Get all admin users
        const adminUsers = await db.collection('users')
          .where('admin', '==', true)
          .get();

        if (adminUsers.empty) {
          console.log('No admin users found');
          await doc.ref.update({
            status: 'sent',
            sentAt: new Date().toISOString()
          });
          processed++;
          continue;
        }

        const adminIds = adminUsers.docs.map(doc => doc.id);

        // Get FCM tokens for all admins
        const tokens = [];
        for (const adminId of adminIds) {
          const userTokens = await db.collection('fcm_tokens')
            .doc(adminId)
            .collection('tokens')
            .get();

          userTokens.forEach(tokenDoc => {
            const tokenData = tokenDoc.data();
            if (tokenData.token) {
              tokens.push(tokenData.token);
            }
          });
        }

        if (tokens.length === 0) {
          console.log('No FCM tokens found for admin users');
          await doc.ref.update({
            status: 'sent',
            sentAt: new Date().toISOString()
          });
          processed++;
          continue;
        }

        console.log(`Sending to ${tokens.length} tokens for ${adminIds.length} admins`);

        // Truncate message if too long for notification
        const truncatedMessage = message.length > 100
          ? message.substring(0, 97) + '...'
          : message;

        // Send notification to all admin tokens
        const notificationMessage = {
          notification: {
            title: `Feedback from ${userName}`,
            body: truncatedMessage
          },
          data: {
            type: 'feedback',
            userId: userId,
            userName: userName,
            userEmail: userEmail,
            timestamp: new Date().toISOString()
          },
          tokens: tokens
        };

        const response = await admin.messaging().sendMulticast(notificationMessage);
        console.log(`Feedback notification sent: ${response.successCount} success, ${response.failureCount} failed`);

        // Mark as sent
        await doc.ref.update({
          status: 'sent',
          sentAt: new Date().toISOString(),
          adminCount: adminIds.length,
          tokenCount: tokens.length,
          successCount: response.successCount,
          failureCount: response.failureCount
        });
        processed++;

      } catch (error) {
        console.error(`Error sending feedback notification ${doc.id}:`, error);
        // Mark as failed
        await doc.ref.update({
          status: 'failed',
          error: error.message,
          failedAt: new Date().toISOString()
        });
      }
    }

    return { processed };

  } catch (error) {
    console.error('Error processing feedback notifications:', error);
    throw error;
  }
}

module.exports = async (req, res) => {
  // Only allow POST requests
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  try {
    console.log('Processing immediate notifications...');

    const results = {};

    // Process all notification types
    results.admin = await sendAdminNotifications();
    results.event = await sendEventNotifications();
    results.message = await sendMessageNotifications();
    results.feedback = await sendFeedbackNotifications();

    const totalProcessed = Object.values(results).reduce((sum, type) => sum + type.processed, 0);

    console.log(`Processed ${totalProcessed} notifications immediately`);

    res.status(200).json({
      success: true,
      message: `Processed ${totalProcessed} notifications`,
      results
    });

  } catch (error) {
    console.error('Error processing notifications:', error);
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
};