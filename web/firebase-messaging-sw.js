importScripts("https://www.gstatic.com/firebasejs/10.12.2/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/10.12.2/firebase-messaging-compat.js");

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

messaging.onBackgroundMessage(function (payload) {
  console.log("Received background message: ", payload);


  if (payload.notification) return;

  self.registration.showNotification(payload.data?.title || "Notification", {
    body: payload.data?.body || "",
    icon: "/icons/Icon-192.png",
  });
});