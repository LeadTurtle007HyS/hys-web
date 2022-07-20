import 'dart:convert';

import 'package:HyS/widgets/bottombarforsmallscreen.dart';
import 'package:HyS/widgets/large_screen.dart';
import 'package:HyS/widgets/medilum_screen.dart';
import 'package:HyS/widgets/side_menu.dart';
import 'package:HyS/widgets/small_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elegant_notification/elegant_notification.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:hive_flutter/hive_flutter.dart';

import 'constants/style.dart';
import 'database/crud.dart';
import 'helpers/responsiveness.dart';

class SiteLayout extends StatefulWidget {
  const SiteLayout({Key? key}) : super(key: key);

  @override
  _SiteLayoutState createState() => _SiteLayoutState();
}

class _SiteLayoutState extends State<SiteLayout> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  DataSnapshot? countData;
  final String _currentUserId = FirebaseAuth.instance.currentUser!.uid;
  final databaseReference = FirebaseDatabase.instance.reference();
  int appbar_nav_index = 1;
  List<dynamic> userDatainit = [];
  Map<dynamic, dynamic> userData = {};
  Box<dynamic>? userDataDB;
  String? _token;
  List userPreferredLang = [];
  Box<dynamic>? allQuestionsLocalDB;

  Box<dynamic>? allSocialPostLocalDB;

  CrudMethods crudobj = CrudMethods();
  QuerySnapshot? service;
  QuerySnapshot? topics;

  List<List<String>> topicList = [];
  List<String> subjectList = [];
  Box<dynamic>? topicListQLocalDB;

  void initState() {
    _get_userData();
    _getPermission();
    _getTokenForUser();
    _messageListener(context);
    _get_user_languagePreference_Data();
    _get_all_questions_posted();
    _get_all_post_details();
    _get_all_blog_post_details();
    _get_all_mood_post_details();
    _get_all_cause_post_details();
    _get_all_bideas_post_details();
    _get_all_project_post_details();
    userDataDB = Hive.box<dynamic>('userdata');
    allQuestionsLocalDB = Hive.box<dynamic>('allquestions');
    topicListQLocalDB = Hive.box<dynamic>('topiclist');

    allSocialPostLocalDB = Hive.box<dynamic>('allsocialposts');

    crudobj
        .getSubjectListSingleGradeWise((userDataDB!.get("grade")).toString(),
            "Central Board of Secondary Education (CBSE)")
        .then((value) {
      setState(() {
        service = value;

        if (service != null) {
          crudobj
              .getTopicSubjectList(
                  "Central Board of Secondary Education (CBSE)")
              .then((value) {
            setState(() {
              topics = value;

              if (topics != null) {
                print("Subjects: ${service!.docs.length}");
                print("Topics:${topics!.docs.length}");
                for (int i = 0; i < service!.docs.length; i++) {
                  List<String> subjectTopics = [];
                  subjectList.add(service!.docs[i].get("subject"));
                  for (int j = 0; j < topics!.docs.length; j++) {
                    if ((topics!.docs[j].get("grade") ==
                            (userDataDB!.get("grade")).toString()) &&
                        (topics!.docs[j].get("subject") ==
                            service!.docs[i].get("subject"))) {
                      subjectTopics.add(topics!.docs[j].get("topic"));
                    }
                  }
                  topicList.add(subjectTopics);
                }
                topicListQLocalDB!.put("topiclist", topicList);
                topicListQLocalDB!.put("subjectlist", subjectList);
              }
            });
          });
        }
      });
    });
    super.initState();
  }

  Future<void> _getPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    print('User granted permission: ${settings.authorizationStatus}');
  }

  void _messageListener(BuildContext context) {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message notification: ${message.notification}');

      if (message.notification != null) {
        print(
            'Message also contained a notification: ${message.notification!.body}');
        ElegantNotification(
          title: Text(message.notification!.title!),
          description: Text(message.notification!.body!),
          icon: Icon(
            Icons.notifications_active,
            color: Colors.green,
          ),
          progressIndicatorColor: Colors.green,
        ).show(context);
      }
    });
  }

  Future<void> _get_userData() async {
    final http.Response response = await http.get(
      Uri.parse('https://hys-api.herokuapp.com/web_get_user_data/$_currentUserId'),
    );

    print("web_get_user_data: ${response.statusCode}");
    if ((response.statusCode == 200) || (response.statusCode == 201)) {
      setState(() {
        userDatainit = json.decode(response.body);
        userData = userDatainit[0];
        //  userDataDB!.put("user_id", userData["user_id"]);
        userDataDB!.put("first_name", userData["first_name"]);
        userDataDB!.put("last_name", userData["last_name"]);
        userDataDB!.put("email_id", userData["email_id"]);
        userDataDB!.put("mobile_no", userData["mobile_no"]);
        userDataDB!.put("address", userData["address"]);
        userDataDB!.put("board", userData["board"]);
        userDataDB!.put("city", userData["city"]);
        userDataDB!.put("gender", userData["gender"]);
        userDataDB!.put("grade", userData["grade"]);
        userDataDB!.put("profilepic", userData["profilepic"]);
        userDataDB!.put("school_address", userData["school_address"]);
        userDataDB!.put("school_city", userData["school_city"]);
        userDataDB!.put("school_name", userData["school_name"]);
        userDataDB!.put("school_state", userData["school_state"]);
        userDataDB!.put("school_street", userData["school_street"]);
        userDataDB!.put("state", userData["state"]);
        userDataDB!.put("stream", userData["stream"]);
        userDataDB!.put("street", userData["street"]);
        userDataDB!.put("user_dob", userData["user_dob"]);
      });
    }
  }

  Future<void> _getTokenForUser() async {
    await FirebaseMessaging.instance.getToken().then((value) {
      print('FCM TokenToken: $value');
      setState(() {
        _token = value;
        userDataDB!.put("token", _token);
        databaseReference
            .child("hysweb")
            .child("usertoken")
            .child("$_currentUserId")
            .update({"tokenid": _token});
      });
    });
  }

  Future<void> _get_user_languagePreference_Data() async {
    final http.Response response = await http.get(
      Uri.parse(
          'https://hys-api.herokuapp.com/web_get_user_preferred_languages_data/$_currentUserId'),
    );

    print("get_user_preferred_languages_data: ${response.statusCode}");
    if ((response.statusCode == 200) || (response.statusCode == 201)) {
      setState(() {
        userPreferredLang = json.decode(response.body);

        userDataDB!.put("preferred_lang", userPreferredLang);
      });
    }
  }

  Future<void> _get_all_questions_posted() async {
    final http.Response response = await http.get(
      Uri.parse('https://hys-api.herokuapp.com/web_get_all_questions_posted'),
    );
    print("get_all_questions_posted: ${response.statusCode}");
    if ((response.statusCode == 200) || (response.statusCode == 201)) {
      setState(() {
        allQuestionsLocalDB!.put("data", json.decode(response.body));
      });
    }
  }

  //social

  Future<void> _get_all_post_details() async {
    final http.Response response = await http.get(
      Uri.parse('https://hys-api.herokuapp.com/web_get_all_sm_posts'),
    );

    print("web_get_all_sm_posts: ${response.statusCode}");
    if ((response.statusCode == 200) || (response.statusCode == 201)) {
      setState(() {
        allSocialPostLocalDB!.put("allpost", json.decode(response.body));
      });
    }
  }

  Future<void> _get_all_mood_post_details() async {
    final http.Response response = await http.get(
      Uri.parse('https://hys-api.herokuapp.com/web_get_all_sm_mood_posts'),
    );

    print("get_all_sm_mood_posts: ${response.statusCode}");
    if ((response.statusCode == 200) || (response.statusCode == 201)) {
      setState(() {
        allSocialPostLocalDB!.put("moodpost", json.decode(response.body));
      });
    }
  }

  Future<void> _get_all_cause_post_details() async {
    final http.Response response = await http.get(
      Uri.parse('https://hys-api.herokuapp.com/web_get_all_sm_cause_posts'),
    );

    print("get_all_sm_cause_posts: ${response.statusCode}");
    if ((response.statusCode == 200) || (response.statusCode == 201)) {
      setState(() {
        allSocialPostLocalDB!.put("causepost", json.decode(response.body));
      });
    }
  }

  Future<void> _get_all_bideas_post_details() async {
    final http.Response response = await http.get(
      Uri.parse('https://hys-api.herokuapp.com/web_get_all_sm_bideas_posts'),
    );

    print("get_all_sm_bideas_posts: ${response.statusCode}");
    if ((response.statusCode == 200) || (response.statusCode == 201)) {
      setState(() {
        allSocialPostLocalDB!.put("businesspost", json.decode(response.body));
      });
    }
  }

  Future<void> _get_all_project_post_details() async {
    final http.Response response = await http.get(
      Uri.parse('https://hys-api.herokuapp.com/web_get_all_sm_project_posts'),
    );

    print("get_all_sm_project_posts: ${response.statusCode}");
    if ((response.statusCode == 200) || (response.statusCode == 201)) {
      setState(() {
        allSocialPostLocalDB!.put("projectpost", json.decode(response.body));
      });
    }
  }

  Future<void> _get_all_blog_post_details() async {
    final http.Response response = await http.get(
      Uri.parse('https://hys-api.herokuapp.com/web_get_all_sm_blog_posts'),
    );

    print("get_all_sm_blog_posts: ${response.statusCode}");
    if ((response.statusCode == 200) || (response.statusCode == 201)) {
      setState(() {
        allSocialPostLocalDB!.put("blogpost", json.decode(response.body));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    databaseReference.child("hysweb").once().then((DataSnapshot snapshot) {
      setState(() {
        if (mounted) {
          setState(() {
            countData = snapshot;
          });
        }
      });
    });
    if ((countData != null) &&
        (userData.isNotEmpty) &&
        (topics != null) &&
        (service != null)) {
      appbar_nav_index = countData!.value["app_bar_navigation"][_currentUserId]
          [_currentUserId];
      return WillPopScope(
        onWillPop: () {
          return Future(() => false);
        },
        child: Scaffold(
            backgroundColor: background,
            key: scaffoldKey,
            appBar: AppBar(
              leading: !ResponsiveWidget.isSmallScreen(context)
                  ? Row(
                      children: [
                        Container(
                            padding: const EdgeInsets.only(left: 14),
                            child: Image.network(
                              "https://firebasestorage.googleapis.com/v0/b/hys-pro-41c66.appspot.com/o/assets%2Flogo.png?alt=media&token=211cd46d-c154-4ce6-8d6d-a297c78fd836",
                              height: 20,
                            )),
                      ],
                    )
                  : IconButton(
                      onPressed: () {
                        scaffoldKey.currentState?.openDrawer();
                      },
                      icon: const Icon(Icons.menu)),
              elevation: 0,
              title: Row(
                children: [
                  (ResponsiveWidget.isSmallScreen(context)) ||
                          (ResponsiveWidget.isMediumScreen(context))
                      ? SizedBox()
                      : Material(
                          elevation: 1,
                          borderRadius: BorderRadius.circular(100),
                          child: Container(
                            width: 120,
                            padding: EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: background,
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Search",
                                    style: TextStyle(
                                        color: lightGrey, fontSize: 14)),
                                Icon(Icons.search, size: 18, color: lightGrey)
                              ],
                            ),
                          ),
                        ),
                  ResponsiveWidget.isSmallScreen(context)
                      ? Container(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                  padding: const EdgeInsets.only(left: 14),
                                  child: Image.network(
                                    "https://firebasestorage.googleapis.com/v0/b/hys-pro-41c66.appspot.com/o/assets%2Flogo.png?alt=media&token=211cd46d-c154-4ce6-8d6d-a297c78fd836",
                                    height: 20,
                                  )),
                              SizedBox(
                                width: 20,
                              ),
                              Material(
                                elevation: 1,
                                borderRadius: BorderRadius.circular(100),
                                child: Container(
                                  width: 100,
                                  padding: EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: background,
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("Search",
                                          style: TextStyle(
                                              color: lightGrey, fontSize: 14)),
                                      Icon(Icons.search,
                                          size: 16, color: lightGrey)
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        )
                      : SizedBox(),
                  !ResponsiveWidget.isSmallScreen(context)
                      ? Expanded(
                          child: Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Column(
                                  children: [
                                    appbar_nav_index == 1
                                        ? InkWell(
                                            onTap: () {
                                              databaseReference
                                                  .child("hysweb")
                                                  .child("app_bar_navigation")
                                                  .child(_currentUserId)
                                                  .update(
                                                      {"$_currentUserId": 1});
                                              setState(() {
                                                appbar_nav_index = 1;
                                              });
                                            },
                                            child: Container(
                                                width: 100,
                                                padding: EdgeInsets.all(5),
                                                decoration: BoxDecoration(
                                                    color: active,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8)),
                                                child: Center(
                                                  child: Text("HOME",
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        color: background,
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      )),
                                                )),
                                          )
                                        : InkWell(
                                            onTap: () {
                                              databaseReference
                                                  .child("hysweb")
                                                  .child("app_bar_navigation")
                                                  .child(_currentUserId)
                                                  .update(
                                                      {"$_currentUserId": 1});
                                              setState(() {
                                                appbar_nav_index = 1;
                                              });
                                            },
                                            child: Container(
                                              child: Text("HOME",
                                                  style: TextStyle(
                                                      color: lightGrey,
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.normal)),
                                            ),
                                          ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    appbar_nav_index == 1
                                        ? Container(
                                            width: 100, height: 4, color: dark)
                                        : SizedBox()
                                  ],
                                ),
                                Column(
                                  children: [
                                    appbar_nav_index == 2
                                        ? InkWell(
                                            onTap: () {
                                              databaseReference
                                                  .child("hysweb")
                                                  .child("app_bar_navigation")
                                                  .child(_currentUserId)
                                                  .update(
                                                      {"$_currentUserId": 2});
                                              setState(() {
                                                appbar_nav_index = 2;
                                              });
                                            },
                                            child: Container(
                                                width: 140,
                                                padding: EdgeInsets.all(5),
                                                decoration: BoxDecoration(
                                                    color: active,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8)),
                                                child: Center(
                                                  child: Text("NETWORK",
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        color: background,
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      )),
                                                )),
                                          )
                                        : InkWell(
                                            onTap: () {
                                              databaseReference
                                                  .child("hysweb")
                                                  .child("app_bar_navigation")
                                                  .child(_currentUserId)
                                                  .update(
                                                      {"$_currentUserId": 2});
                                              setState(() {
                                                appbar_nav_index = 2;
                                              });
                                            },
                                            child: Container(
                                              child: Text("NETWORK",
                                                  style: TextStyle(
                                                      color: lightGrey,
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.normal)),
                                            ),
                                          ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    appbar_nav_index == 2
                                        ? Container(
                                            width: 100, height: 4, color: dark)
                                        : SizedBox()
                                  ],
                                ),
                                Column(
                                  children: [
                                    appbar_nav_index == 3
                                        ? InkWell(
                                            onTap: () {
                                              databaseReference
                                                  .child("hysweb")
                                                  .child("app_bar_navigation")
                                                  .child(_currentUserId)
                                                  .update(
                                                      {"$_currentUserId": 3});
                                              setState(() {
                                                appbar_nav_index = 3;
                                              });
                                            },
                                            child: Container(
                                                width: 160,
                                                padding: EdgeInsets.all(5),
                                                decoration: BoxDecoration(
                                                    color: active,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8)),
                                                child: Center(
                                                  child: Text("LIVE BOOKS",
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        color: background,
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      )),
                                                )),
                                          )
                                        : InkWell(
                                            onTap: () {
                                              databaseReference
                                                  .child("hysweb")
                                                  .child("app_bar_navigation")
                                                  .child(_currentUserId)
                                                  .update(
                                                      {"$_currentUserId": 3});
                                              setState(() {
                                                appbar_nav_index = 3;
                                              });
                                            },
                                            child: Container(
                                              child: Text("LIVE BOOKS",
                                                  style: TextStyle(
                                                      color: lightGrey,
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.normal)),
                                            ),
                                          ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    appbar_nav_index == 3
                                        ? Container(
                                            width: 100, height: 4, color: dark)
                                        : SizedBox()
                                  ],
                                ),
                              ],
                            ),
                          ),
                        )
                      : Expanded(child: Container()),
                  Container(
                    child: Row(children: [
                      Stack(
                        children: [
                          IconButton(
                              icon: Icon(Icons.message,
                                  color: appbar_nav_index != 4
                                      ? dark
                                      : Colors.redAccent),
                              onPressed: () {
                                databaseReference
                                    .child("hysweb")
                                    .child("app_bar_navigation")
                                    .child(_currentUserId)
                                    .update({"$_currentUserId": 4});
                                setState(() {
                                  appbar_nav_index = 4;
                                });
                              }),
                          appbar_nav_index != 4
                              ? Positioned(
                                  top: 7,
                                  right: 7,
                                  child: Container(
                                      width: 12,
                                      height: 12,
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                          color: active,
                                          borderRadius:
                                              BorderRadius.circular(30),
                                          border: Border.all(
                                              color: light, width: 2))),
                                )
                              : SizedBox()
                        ],
                      ),
                      Stack(
                        children: [
                          IconButton(
                              icon: Icon(Icons.notifications,
                                  color: appbar_nav_index != 6
                                      ? dark
                                      : Colors.redAccent),
                              onPressed: () {
                                databaseReference
                                    .child("hysweb")
                                    .child("app_bar_navigation")
                                    .child(_currentUserId)
                                    .update({"$_currentUserId": 6});
                                setState(() {
                                  appbar_nav_index = 6;
                                });
                              }),
                          Positioned(
                            top: 7,
                            right: 7,
                            child: Container(
                                width: 12,
                                height: 12,
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                    color: active,
                                    borderRadius: BorderRadius.circular(30),
                                    border:
                                        Border.all(color: light, width: 2))),
                          )
                        ],
                      ),
                      const SizedBox(
                        width: 16,
                      ),
                      Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(30)),
                          child: Container(
                              padding: const EdgeInsets.all(2),
                              margin: const EdgeInsets.all(2),
                              child: CircleAvatar(
                                  backgroundColor: light,
                                  child: Icon(Icons.person_outline,
                                      color: dark)))),
                    ]),
                  ),
                ],
              ),
              iconTheme: IconThemeData(color: dark),
              backgroundColor: background,
            ),
            bottomNavigationBar: ResponsiveWidget.isSmallScreen(context)
                ? BottomBarMobileScreen()
                : SizedBox(),
            drawer: const Drawer(child: SideMenu()),
            body: const ResponsiveWidget(
              largeScreen: LargeScreen(),
              smallScreen: SmallScreen(),
              mediumScreen: LargeScreen(),
            )),
      );
    } else {
      return _loading();
    }
  }

  Widget _loading() {
    return Center(
      child: Container(
          height: 50.0,
          margin: const EdgeInsets.only(left: 10.0, right: 10.0),
          child: const Center(
              child: CircularProgressIndicator(
            valueColor:
                AlwaysStoppedAnimation<Color>(Color.fromRGBO(88, 165, 196, 1)),
          ))),
    );
  }
}
