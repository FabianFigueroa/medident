importScripts("https://www.gstatic.com/firebasejs/10.14.1/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/10.14.1/firebase-messaging-compat.js");

firebase.initializeApp({
  apiKey: "AIzaSyCRpxCV1Clh27U_51oNLAH8hmTbvJ8lk38",
  authDomain: "ips-medident.firebaseapp.com",
  projectId: "ips-medident",
  storageBucket: "ips-medident.firebasestorage.app",
  messagingSenderId: "435865924056",
  appId: "1:435865924056:web:07b721ee76d40b056282ad",
  measurementId: "G-063DY2YTCQ",
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
  const title = payload.notification?.title || "Medident";
  const options = {
    body: payload.notification?.body || "",
    icon: "/favicon.png",
  };
  self.registration.showNotification(title, options);
});
