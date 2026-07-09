// Firebase Cloud Messaging Service Worker
// This file handles background push notifications for the web app

// Import Firebase scripts with version 9.23.0 (more stable)
importScripts('https://www.gstatic.com/firebasejs/9.23.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/9.23.0/firebase-messaging-compat.js');

// Firebase configuration - matches your app configuration
const firebaseConfig = {
  apiKey: "AIzaSyAGJBjhIIEaX7L3WgiRWFFwm4HoIVpIj5w",
  authDomain: "noticlassapp-361d5.firebaseapp.com",
  projectId: "noticlassapp-361d5",
  storageBucket: "noticlassapp-361d5.firebasestorage.app",
  messagingSenderId: "742437097759",
  appId: "1:742437097759:web:5d1784f9b21b438a55602a",
  measurementId: "G-G6EST5K38X"
};

// Initialize Firebase in the service worker
try {
  firebase.initializeApp(firebaseConfig);
  console.log('Firebase initialized in service worker');
} catch (error) {
  console.error('Failed to initialize Firebase in service worker:', error);
}

// Get the Firebase Messaging instance
const messaging = firebase.messaging();

// Handle background messages when the app is not in focus
messaging.onBackgroundMessage(function(payload) {
  console.log('[firebase-messaging-sw.js] Received background message:', payload);
  
  // Customize notification here
  const notificationTitle = payload.notification?.title || 'New Notification';
  const notificationOptions = {
    body: payload.notification?.body || 'You have a new message',
    icon: payload.notification?.icon || '/icons/Icon-192.png',
    badge: '/icons/Icon-192.png',
    tag: 'notification-tag',
    requireInteraction: false,
    actions: [
      {
        action: 'open',
        title: 'Open App'
      },
      {
        action: 'close',
        title: 'Close'
      }
    ]
  };

  // Show the notification
  return self.registration.showNotification(notificationTitle, notificationOptions);
});

// Handle notification click events
self.addEventListener('notificationclick', function(event) {
  console.log('[firebase-messaging-sw.js] Notification click received.');
  
  event.notification.close();
  
  if (event.action === 'open' || !event.action) {
    // Open the app when notification is clicked
    event.waitUntil(
      clients.openWindow('/')
    );
  }
});

// Handle service worker installation
self.addEventListener('install', function(event) {
  console.log('[firebase-messaging-sw.js] Service worker installing...');
  self.skipWaiting();
});

// Handle service worker activation
self.addEventListener('activate', function(event) {
  console.log('[firebase-messaging-sw.js] Service worker activating...');
  event.waitUntil(self.clients.claim());
});