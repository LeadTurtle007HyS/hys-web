importScripts('https://www.gstatic.com/firebasejs/9.2.0/firebase-app-compat.js');
 importScripts('https://www.gstatic.com/firebasejs/9.2.0/firebase-messaging-compat.js');

   /*Update with yours config*/
  const firebaseConfig = {
    apiKey: "AIzaSyBgLz76YA2rYZQVZNkISn1ifdhp3LpXzYw",
    authDomain: "hys-pro-41c66.firebaseapp.com",
    databaseURL: "https://hys-pro-41c66-default-rtdb.firebaseio.com",
    projectId: "hys-pro-41c66",
    storageBucket: "hys-pro-41c66.appspot.com",
    messagingSenderId: "728627807478",
    appId: "1:728627807478:web:14af922de235285e0658d7",
    measurementId: "G-P503Q821B4"
 };
  firebase.initializeApp(firebaseConfig);
  const messaging = firebase.messaging();

  /*messaging.onMessage((payload) => {
  console.log('Message received. ', payload);*/
  messaging.onBackgroundMessage(function(payload) {
    console.log('Received background message ', payload);

    const notificationTitle = payload.notification.title;
    const notificationOptions = {
      body: payload.notification.body,
    };

    self.registration.showNotification(notificationTitle,
      notificationOptions);
  });
