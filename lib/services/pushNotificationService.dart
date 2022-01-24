// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';

// class PushNotificationService {
//   final FirebaseMessaging _fcm = FirebaseMessaging();
//   void initialize() {
//     _fcm.configure(
//       onMessage: (Map<String, dynamic> message) async {
//         print("onMessage: $message");
//         onMessageNotify(message);
//       },
//       //onBackgroundMessage: myBackgroundMessageHandler,
//       onLaunch: (Map<String, dynamic> message) async {
//         print("onLaunch: $message");
//         _serialiseAndNavigate(message);
//       },
//       onResume: (Map<String, dynamic> message) async {
//         print("onResume: $message");
//         _serialiseAndNavigate(message);
//       },
//     );
//   }
// }

// void _serialiseAndNavigate(Map<String, dynamic> message) {
//   var notificationData = message['data'];
//   var route = notificationData['route'];

//   if (route != null) {
//     // Navigate to the create post view

//     // If there's no view it'll just open the app on the first view
//   }
// }

// void onMessageNotify(Map<String, dynamic> message) {
//   var notificationData = message['data'];
//   var route = notificationData['route'];

//   if (route != null) {
//     // Navigate to the create post view

//     final snackBar = SnackBar(
//       content: Text(message['notification']['body']),
//       action: SnackBarAction(label: 'GO', onPressed: () {}),
//     );
//     GlobalKey<ScaffoldState>().currentState.showSnackBar(snackBar);

//     // If there's no view it'll just open the app on the first view
//   }
// }
