importScripts('https://www.gstatic.com/firebasejs/9.22.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/9.22.0/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: 'AIzaSyAC7B4DLfnCqr292V0ulvJINss0Wzsvfnw',
  authDomain: 'floatit-app.firebaseapp.com',
  projectId: 'floatit-app',
  storageBucket: 'floatit-app.firebasestorage.app',
  messagingSenderId: '129192884776',
  appId: '1:129192884776:web:541d2b77864ec0d597d31d',
});

const messaging = firebase.messaging();

// Add event listeners to ensure the service worker activates immediately
self.addEventListener('install', (event) => {
  self.skipWaiting();
});

self.addEventListener('activate', (event) => {
  event.waitUntil(self.clients.claim());
});