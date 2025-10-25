importScripts('https://www.gstatic.com/firebasejs/10.13.2/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.13.2/firebase-messaging-compat.js');

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
messaging.onBackgroundMessage((payload) => {
  console.log('Received background message:', payload);
  
  const notificationTitle = payload.notification?.title || 'FloatIT';
  const notificationOptions = {
    body: payload.notification?.body || '',
    icon: '/icons/Icon-192.png',
    badge: '/icons/Icon-192.png',
    data: payload.data || {},
  };

  return self.registration.showNotification(notificationTitle, notificationOptions);
});

// Add event listener to ensure the service worker activates immediately
self.addEventListener('install', (event) => {
  self.skipWaiting();
});

// Take control of all clients immediately
self.addEventListener('activate', (event) => {
  event.waitUntil(self.clients.claim());
});