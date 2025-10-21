importScripts('https://www.gstatic.com/firebasejs/9.22.2/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/9.22.2/firebase-messaging-compat.js');

// Initialize the Firebase app in the service worker by passing in
// your app's Firebase config. The configuration below should match
// the values in lib/firebase_options.dart (web config).
// These values are safe to include in client-side code.

firebase.initializeApp({
  apiKey: 'AIzaSyAC7B4DLfnCqr292V0ulvJINss0Wzsvfnw',
  authDomain: 'floatit-app.firebaseapp.com',
  projectId: 'floatit-app',
  storageBucket: 'floatit-app.firebasestorage.app',
  messagingSenderId: '129192884776',
  appId: '1:129192884776:web:541d2b77864ec0d597d31d',
});

const messaging = firebase.messaging();

// Handle background messages
messaging.onBackgroundMessage(function(payload) {
  console.log('[firebase-messaging-sw.js] Received background message ', payload);

  const notificationTitle = payload.notification?.title || 'FloatIT';
  const notificationOptions = {
    body: payload.notification?.body || '',
    icon: '/icons/Icon-192.png',
    data: payload.data || {},
  };

  return self.registration.showNotification(notificationTitle, notificationOptions);
});
