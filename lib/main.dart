import 'dart:convert';
import 'dart:io';
import 'package:HyS/pages/authentication/authentication.dart';
import 'package:HyS/pages/openLink.dart';
import 'package:HyS/test1.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mentions/flutter_mentions.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:oktoast/oktoast.dart';
import 'constants/style.dart';
import 'controllers/menu_controller.dart';
import 'controllers/navigation_controller.dart';
import 'layout.dart';
import 'configure_nonweb.dart' if (dart.library.html) 'configure_web.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  Get.put(MenuController());
  Get.put(NavigationController());
  Hive.initFlutter();

// these are the local storage folders created by using Hive

  await Hive.openBox("userdata");
  await Hive.openBox("questionliked");
  await Hive.openBox("questionmydoubttoo");
  await Hive.openBox("questionmarkimp");
  await Hive.openBox("questionsaved");
  await Hive.openBox("questionedbookmarked");
  await Hive.openBox("questionaskreference");
  await Hive.openBox("questionreport");
  await Hive.openBox("questiontoughness");
  await Hive.openBox("questionexamlikelyhood");
  await Hive.openBox("questionreport");
  await Hive.openBox("usertokendata");
  await Hive.openBox("answerliked");
  await Hive.openBox("answervotes");
  await Hive.openBox("answermarkasimp");
  await Hive.openBox("answerhelpful");
  await Hive.openBox("answersaved");
  await Hive.openBox("answerbookmarked");
  await Hive.openBox("answeraskreference");
  await Hive.openBox("answerreport");
  await Hive.openBox("answercommentliked");
  await Hive.openBox("answercommentreply");
  await Hive.openBox("commentreport");
  await Hive.openBox("ansSubcommentliked");
  await Hive.openBox("ansSubcommentreport");

  await Hive.openBox("allquestions");
  await Hive.openBox("allanswers");
  await Hive.openBox("allQcomments");
  await Hive.openBox("allQreplies");
  await Hive.openBox("allQsaved");
  await Hive.openBox("allQbookmark");

  await Hive.openBox("topiclist");

  await Hive.openBox("allsocialposts");
  await Hive.openBox("allsocialcomments");
  await Hive.openBox("allsocialreplies");

  configureApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Portal(
      child: OKToast(
        child: GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: "HyS",
          theme: ThemeData(
            scaffoldBackgroundColor: light,
            textTheme: GoogleFonts.mulishTextTheme(
              Theme.of(context).textTheme,
            ).apply(bodyColor: Colors.black),
            pageTransitionsTheme: const PageTransitionsTheme(builders: {
              TargetPlatform.iOS: FadeUpwardsPageTransitionsBuilder(),
              TargetPlatform.android: FadeUpwardsPageTransitionsBuilder()
            }),
            primaryColor: Colors.blue,
          ),
          home: AuthPage(),
        ),
      ),
    );
  }
}

/// Entry point for the example application.
// class PushNotificationApp extends StatefulWidget {
//   static const routeName = "/firebase-push";

//   @override
//   _PushNotificationAppState createState() => _PushNotificationAppState();
// }

// class _PushNotificationAppState extends State<PushNotificationApp> {
//   @override
//   void initState() {
//     getPermission();
//     messageListener(context);
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder(
//       // Initialize FlutterFire
//       future: Firebase.initializeApp(),
//       builder: (context, snapshot) {
//         // Check for errors
//         if (snapshot.hasError) {
//           return Center(
//             child: Text(snapshot.error as String),
//           );
//         }
//         // Once complete, show your application
//         if (snapshot.connectionState == ConnectionState.done) {
//           print('android firebase initiated');
//           return NotificationPage();
//         }
//         // Otherwise, show something whilst waiting for initialization to complete
//         return Center(
//           child: CircularProgressIndicator(),
//         );
//       },
//     );
//   }

//   Future<void> getPermission() async {
//     FirebaseMessaging messaging = FirebaseMessaging.instance;

//     NotificationSettings settings = await messaging.requestPermission(
//       alert: true,
//       announcement: false,
//       badge: true,
//       carPlay: false,
//       criticalAlert: false,
//       provisional: false,
//       sound: true,
//     );

//     print('User granted permission: ${settings.authorizationStatus}');
//   }

//   void messageListener(BuildContext context) {
//     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//       print('Got a message whilst in the foreground!');
//       print('Message data: ${message.data}');

//       if (message.notification != null) {
//         print(
//             'Message also contained a notification: ${message.notification!.body}');
//         showDialog(
//             context: context,
//             builder: ((BuildContext context) {
//               return DynamicDialog(
//                   title: message.notification!.title,
//                   body: message.notification!.body);
//             }));
//       }
//     });
//   }
// }

// class NotificationPage extends StatefulWidget {
//   @override
//   State<StatefulWidget> createState() => _Application();
// }

// class _Application extends State<NotificationPage> {
//   String? _token;
//   Stream<String>? _tokenStream;
//   int notificationCount = 0;

//   void setToken(String token) {
//     print('FCM TokenToken: $token');
//     setState(() {
//       _token = token;
//     });
//   }

//   @override
//   void initState() {
//     super.initState();
//     //get token
//     FirebaseMessaging.instance.getToken().then((value) {
//       print('FCM TokenToken: $value');
//       setState(() {
//         _token = value;
//       });
//     });
//     _tokenStream = FirebaseMessaging.instance.onTokenRefresh;
//     _tokenStream!.listen(setToken);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(
//           title: const Text('Firebase push notification'),
//         ),
//         body: Container(
//           child: Center(
//             child: Card(
//               margin: EdgeInsets.all(10),
//               elevation: 10,
//               child: ListTile(
//                 title: Center(
//                   child: OutlinedButton.icon(
//                     label: Text('Push Notification',
//                         style: TextStyle(
//                             color: Colors.blueAccent,
//                             fontWeight: FontWeight.bold,
//                             fontSize: 16)),
//                     onPressed: () {
//                       sendPushMessageToWeb();
//                     },
//                     icon: Icon(Icons.notifications),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ));
//   }

//   //send notification
//   sendPushMessageToWeb() async {
//     if (_token == null) {
//       print('Unable to send FCM message, no token exists.');
//       return;
//     }
//     try {
//       await http
//           .post(
//             Uri.parse('https://fcm.googleapis.com/fcm/send'),
//             headers: <String, String>{
//               'Content-Type': 'application/json',
//               'Authorization':
//                   'key=AAAAqaWaBPY:APA91bHQAvw_ld3ulPKtYDICkrOL0bwB0cs3wqak5zfj0n558nYM_qUvA4P_L4dZqAz3Wk2oxnWVnQjmyisYMAz2t9oDmoo_xj0ocMAg8_gzamFlNHf2OffzMuFrW_RhffxKTiAYgjyy'
//             },
//             body: json.encode({
//               'to': _token,
//               'message': {
//                 'token': _token,
//               },
//               "notification": {
//                 "title": "Push Notification",
//                 "body": "Firebase  push notification"
//               }
//             }),
//           )
//           .then((value) => print(value.body));
//       print('FCM request for web sent!');
//     } catch (e) {
//       print(e);
//     }
//   }
// }

// //push notification dialog for foreground
class DynamicDialog extends StatefulWidget {
  final title;
  final body;
  DynamicDialog({this.title, this.body});
  @override
  _DynamicDialogState createState() => _DynamicDialogState();
}

class _DynamicDialogState extends State<DynamicDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      actions: <Widget>[
        OutlinedButton.icon(
            label: Text('Close'),
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.close))
      ],
      content: Text(widget.body),
    );
  }
}
