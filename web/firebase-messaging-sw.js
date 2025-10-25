importScripts('https://www.gstatic.com/firebasejs/10.7.0/firebase-app.js');
importScripts('https://www.gstatic.com/firebasejs/10.7.0/firebase-messaging.js');

firebase.initializeApp({
  apiKey: 'AIzaSyAC7B4DLfnCqr292V0ulvJINss0Wzsvfnw',
  authDomain: 'floatit-app.firebaseapp.com',
  projectId: 'floatit-app',
  storageBucket: 'floatit-app.firebasestorage.app',
  messagingSenderId: '129192884776',
  appId: '1:129192884776:web:541d2b77864ec0d597d31d',
});

const messaging = firebase.messaging();

// Add event listener to ensure the service worker activates immediately
self.addEventListener('install', (event) => {
  self.skipWaiting();
});