import 'dart:typed_data';
import 'package:HyS/pages/authentication/authentication.dart';
import 'package:HyS/pages/livebook_code/liveBookOpen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mentions/flutter_mentions.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:oktoast/oktoast.dart';
import 'constants/style.dart';
import 'controllers/menu_controller.dart';
import 'package:HyS/live_books/epub_view.dart';
import 'package:http/http.dart' as http;
import 'controllers/navigation_controller.dart';
import 'configure_nonweb.dart' if (dart.library.html) 'configure_web.dart';

String user_id = '';
String epub_url = '';

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

  await Hive.openBox("epub");

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
          initialRoute: '/welcome',
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
          routes: {
            '/welcome': (context) => AuthPage(),
          },
          home: AuthPage(),
          onGenerateRoute: (settings) {
            List<String> pathComponents = settings.name!.split('/');
            print(pathComponents);
            if (pathComponents[1] == 'epub') {
              // user_id = pathComponents[2];
              // epub_url = pathComponents[3];
              return MaterialPageRoute(builder: (context) {
                return EpubExternal();
              });
            } else {
              return MaterialPageRoute(builder: (context) {
                return AuthPage();
              });
            }
          },
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

class EpubExternal extends StatefulWidget {
  @override
  _EpubExternalState createState() => _EpubExternalState();
}

class _EpubExternalState extends State<EpubExternal> {
  EpubController? _epubReaderController;
  bool _fileLoaded = true;
  Uint8List? fileBytes;

  @override
  void initState() {
    final loadedBook = _loadFromNetwork(
        'https://firebasestorage.googleapis.com/v0/b/hys-pro-41c66.appspot.com/o/jesc101.epub?alt=media&token=c1a56d06-1406-4fa6-86c8-49ec21419d12');
    _epubReaderController = EpubController(
      document: EpubReader.readBook(loadedBook),
      //  document: EpubReader,
      // epubCfi:
      //     'epubcfi(/6/26[id4]!/4/2/2[id4]/22)', // book.epub Chapter 3 paragraph 10
      // epubCfi:
      //     'epubcfi(/6/6[chapter-2]!/4/2/1612)', // book_2.epub Chapter 16 paragraph 3
    );
    super.initState();
  }

  @override
  void dispose() {
    _epubReaderController!.dispose();
    super.dispose();
  }

  Future<Uint8List> _loadFromAssets(String assetName) async {
    final bytes = await rootBundle.load(assetName);
    return bytes.buffer.asUint8List();
  }

  Future<Uint8List> _loadFromNetwork(String url) async {
    final http.Response response = await http.get(
      Uri.parse(url),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      setState(() {
        _fileLoaded = true;
      });
      fileBytes = response.bodyBytes;
    }
    return fileBytes!;
  }

  @override
  Widget build(BuildContext context) => WillPopScope(
        onWillPop: () {
          return Future(() => false);
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: EpubActualChapter(
              controller: _epubReaderController!,
              builder: (chapterValue) => Text(
                (chapterValue?.chapter?.Title?.trim() ?? '')
                    .replaceAll('\n', ''),
                textAlign: TextAlign.start,
              ),
            ),
            leading: SizedBox(),
          ),
          body: EpubView(
            controller: _epubReaderController!,
            onDocumentLoaded: (document) {
              print('isLoaded: $document');
            },
            dividerBuilder: (_) => Divider(),
            tittle: Text(""),
          ),
        ),
      );

  void _showCurrentEpubCfi(context) {
    final cfi = _epubReaderController!.generateEpubCfi();

    if (cfi != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(cfi),
          action: SnackBarAction(
            label: 'GO',
            onPressed: () {
              _epubReaderController!.gotoEpubCfi(cfi);
            },
          ),
        ),
      );
    }
  }
}
