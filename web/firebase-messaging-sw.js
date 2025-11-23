importScripts("https://www.gstatic.com/firebasejs/9.6.10/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/9.6.10/firebase-messaging-compat.js");

firebase.initializeApp({
  apiKey: "AIzaSyBXXaetL2R7rw0hrmNVyLWyPcXwcMqOoyg",
  authDomain: "easy-crm-756ad.firebaseapp.com",
  projectId: "easy-crm-756ad",
  storageBucket: "easy-crm-756ad.firebasestorage.app",
  messagingSenderId: "344835605079",
  appId: "1:344835605079:web:d85d02377ca6cb39e19912",
  measurementId: "G-41B0VK89XP"
});

const messaging = firebase.messaging();

// OPTIONAL – handles background push messages
messaging.onBackgroundMessage(function (payload) {
  console.log("Received background message: ", payload);

  const notificationTitle = payload.notification.title;
  const notificationOptions = {
    body: payload.notification.body,
    icon: "/icons/Icon-192.png"
  };

  self.registration.showNotification(notificationTitle, notificationOptions);
});
self.addEventListener('push', function(event) {
  const data = event.data.json();

  const title = data.notification.title;
  const options = {
    body: data.notification.body,
    icon: "/icons/Icon-192.png",
  };

  event.waitUntil(
    self.registration.showNotification(title, options)
  );
});
