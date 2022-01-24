import 'dart:convert';

import 'package:HyS/database/crud.dart';
import 'package:HyS/pages/overView/notification_crud.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class AllNotifications extends StatefulWidget {
  const AllNotifications({Key? key}) : super(key: key);

  @override
  _AllNotificationsState createState() => _AllNotificationsState();
}

class _AllNotificationsState extends State<AllNotifications>
    with SingleTickerProviderStateMixin {
  Box<dynamic>? userDataDB;
  String _currentUserId = FirebaseAuth.instance.currentUser!.uid;
  String current_date = DateFormat.yMMMMd('en_US').format(DateTime.now());
  String current_time = DateTime.now().toString().substring(11, 15);
  String starttime = DateTime.now().toString();
  String current_onlyDate = (DateFormat('yyyyMMddkkmm').format(DateTime.now()))
      .toString()
      .substring(0, 8);
  String comparedate = DateFormat('yyyyMMddkkmm').format(DateTime.now());
  List<dynamic> allNotifications = [];
  List<dynamic> allQuestionsData = [];
  List<dynamic> allPostData = [];
  final databaseReference = FirebaseDatabase.instance.reference();
  NotificationCRUD notifyCRUD = NotificationCRUD();
  DataSnapshot? countData;
  TabController? _tabController;
  ScrollController? _scrollController;
  QuerySnapshot? allConnections;

  CrudMethods crudobj = CrudMethods();
  int statusCode = 600;

  Future<void> _get_allNotifications() async {
    final http.Response response = await http.get(
      Uri.parse(
          'https://hys-api.herokuapp.com/get_all_notifications/$_currentUserId'),
    );

    print("get_all_notifications: ${response.statusCode}");
    setState(() {
      statusCode = response.statusCode;
    });
    if ((response.statusCode == 200) || (response.statusCode == 201)) {
      setState(() {
        allNotifications = json.decode(response.body);
        print("get_all_notifications: $allNotifications");
      });
    }
  }

  Future<void> _get_all_questions_posted() async {
    final http.Response response = await http.get(
      Uri.parse('https://hys-api.herokuapp.com/get_all_questions_posted'),
    );
    print("get_all_questions_posted: ${response.statusCode}");
    if ((response.statusCode == 200) || (response.statusCode == 201)) {
      setState(() {
        allQuestionsData = json.decode(response.body);
      });
    }
  }

  Future<void> _get_all_post_details() async {
    final http.Response response = await http.get(
      Uri.parse('https://hys-api.herokuapp.com/get_all_sm_posts'),
    );

    print("get_all_sm_posts: ${response.statusCode}");
    if ((response.statusCode == 200) || (response.statusCode == 201)) {
      setState(() {
        allPostData = json.decode(response.body);
      });
    }
  }

  void initState() {
    userDataDB = Hive.box<dynamic>('userdata');
    _get_allNotifications();
    _get_all_questions_posted();
    _tabController = TabController(length: 4, vsync: this);
    crudobj.getUserConnection().then((value) {
      setState(() {
        allConnections = value;
      });
    });
    super.initState();
  }

  void dispose() {
    _get_allNotifications();
    super.dispose();
  }

  double? _width;
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
    _width = MediaQuery.of(context).size.width;
    if ((statusCode == 200) || (statusCode == 201)) {
      if (allNotifications.isNotEmpty) {
        return Container(
            child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(30),
              child: TabBar(
                  controller: _tabController,
                  indicatorColor: Colors.transparent,
                  labelColor: Color(0xff0C2551),
                  isScrollable: true,
                  labelPadding: EdgeInsets.only(right: 20.0),
                  unselectedLabelColor: Color(0xFF6C8BC2),
                  physics: BouncingScrollPhysics(),
                  tabs: [
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('   All    ',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Nunito Sans',
                                fontSize: 25,
                                fontWeight: FontWeight.w600,
                              )),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text('   Q/A    ',
                              style: TextStyle(
                                fontFamily: 'Nunito Sans',
                                fontSize: 25,
                                fontWeight: FontWeight.w600,
                              )),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text('   Social    ',
                              style: TextStyle(
                                fontFamily: 'Nunito Sans',
                                fontSize: 25,
                                fontWeight: FontWeight.w600,
                              )),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text('   Friends    ',
                              style: TextStyle(
                                fontFamily: 'Nunito Sans',
                                fontSize: 25,
                                fontWeight: FontWeight.w600,
                              )),
                        ],
                      ),
                    ),
                  ]),
            ),
            Container(
                height: MediaQuery.of(context).size.height - 50,
                width: double.infinity,
                child: TabBarView(
                    physics: BouncingScrollPhysics(),
                    controller: _tabController,
                    children: [
                      _allNotifications(),
                      SizedBox(),
                      SizedBox(),
                      SizedBox()
                    ])),
          ],
        ));
      } else {
        return Container(
            height: 500,
            child:
                Center(child: Text('No Data', style: TextStyle(fontSize: 30))));
      }
    } else {
      return _loading();
    }
  }

  _allNotifications() {
    return allNotifications.length != 0
        ? Container(
            padding: EdgeInsets.only(bottom: 30),
            color: Colors.white10,
            height: MediaQuery.of(context).size.height - 30,
            child: ListView.builder(
              controller: _scrollController,
              itemCount: allNotifications.length,
              itemBuilder: (BuildContext context, int i) {
                return allNotifications[i]["notify_type"] == "friendrequest"
                    ? friendRequestNotification(i)
                    : _expression_notify(i);
              },
            )) //
        : Center(
            child: Text(
              'No Notifications',
              style: TextStyle(
                fontFamily: 'Nunito Sans',
                fontSize: 35,
                color: Color(0xFF737475),
                fontWeight: FontWeight.w900,
              ),
            ),
          );
  }

  _expression_notify(int i) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        InkWell(
          onTap: () {
            if (allNotifications[i]["post_type"] == "question") {
              for (int j = 0; j < allQuestionsData.length; j++) {
                if (allQuestionsData[j]["question_id"] ==
                    allNotifications[i]["post_id"]) {
                  notifyCRUD.updateNotificationDetails(
                      [allNotifications[i]["notify_id"]]);
                  print("true");
                  databaseReference
                      .child("hysweb")
                      .child("qANDa")
                      .child("jump_to_listview_index")
                      .update({"$_currentUserId": j});
                  databaseReference
                      .child("hysweb")
                      .child("app_bar_navigation")
                      .child(FirebaseAuth.instance.currentUser!.uid)
                      .update({"$_currentUserId": 1});
                  break;
                }
              }
            } else if (allNotifications[i]["section"] == "social") {
              for (int j = 0; j < allPostData.length; j++) {
                if (allPostData[j]["post_id"] ==
                    allNotifications[i]["post_id"]) {
                  notifyCRUD.updateNotificationDetails(
                      [allNotifications[i]["notify_id"]]);

                  databaseReference
                      .child("hysweb")
                      .child("social")
                      .child("jump_to_listview_index")
                      .update({"$_currentUserId": j});
                  databaseReference
                      .child("hysweb")
                      .child("app_bar_navigation")
                      .child(FirebaseAuth.instance.currentUser!.uid)
                      .update({"$_currentUserId": 1});
                  break;
                }
              }
            }
          },
          child: Container(
            width: _width! > 750 ? 700 : _width! - 30,
            decoration: BoxDecoration(
                color: allNotifications[i]["is_clicked"] == "false"
                    ? Color.fromRGBO(199, 234, 246, 1)
                    : Colors.white,
                border: Border.all(color: Color(0xFFD2E2FF)),
                borderRadius: BorderRadius.all(Radius.circular(15))),
            margin: EdgeInsets.all(10),
            padding: EdgeInsets.only(left: 8, top: 8, bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.white,
                  backgroundImage: NetworkImage(
                    allNotifications[i]["profilepic"],
                  ),
                ),
                SizedBox(
                  width: _width! > 750 ? 50 : 20,
                ),
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(width: 10),
                      Container(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(allNotifications[i]["title"],
                                style: TextStyle(
                                  fontFamily: 'Nunito Sans',
                                  fontSize: 14,
                                  color: Color.fromRGBO(0, 0, 0, 0.8),
                                  fontWeight: FontWeight.w700,
                                )),
                            SizedBox(height: 8),
                            Text(allNotifications[i]["message"],
                                style: TextStyle(
                                  fontFamily: 'Nunito Sans',
                                  fontSize: 14,
                                  color: Color.fromRGBO(0, 0, 0, 0.8),
                                  fontWeight: FontWeight.w500,
                                )),
                            SizedBox(height: 4),
                            Text(
                              allNotifications[i]["createdate"],
                              style: TextStyle(
                                fontFamily: 'Nunito Sans',
                                fontSize: 12,
                                fontWeight: FontWeight.normal,
                                color: Color.fromRGBO(0, 0, 0, 0.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  friendRequestNotification(int i) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        InkWell(
          child: Container(
            width: _width! > 750 ? 700 : _width! - 30,
            decoration: BoxDecoration(
                color: allNotifications[i]["is_clicked"] == "false"
                    ? Color.fromRGBO(199, 234, 246, 1)
                    : Colors.white,
                border: Border.all(color: Color(0xFFD2E2FF)),
                borderRadius: BorderRadius.all(Radius.circular(15))),
            margin: EdgeInsets.all(10),
            padding: EdgeInsets.only(left: 8, top: 8, bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () {
                    databaseReference
                        .child("hysweb")
                        .child("app_bar_navigation")
                        .child(FirebaseAuth.instance.currentUser!.uid)
                        .update({
                      "$_currentUserId": 7,
                      "userid": allNotifications[i]["sender_id"]
                    });
                  },
                  child: CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.white,
                    backgroundImage: NetworkImage(
                      allNotifications[i]["profilepic"],
                    ),
                  ),
                ),
                SizedBox(
                  width: _width! > 750 ? 50 : 20,
                ),
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(width: 10),
                      Container(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(allNotifications[i]["title"],
                                style: TextStyle(
                                  fontFamily: 'Nunito Sans',
                                  fontSize: 14,
                                  color: Color.fromRGBO(0, 0, 0, 0.8),
                                  fontWeight: FontWeight.w700,
                                )),
                            SizedBox(height: 8),
                            Text(allNotifications[i]["message"],
                                style: TextStyle(
                                  fontFamily: 'Nunito Sans',
                                  fontSize: 14,
                                  color: Color.fromRGBO(0, 0, 0, 0.8),
                                  fontWeight: FontWeight.w500,
                                )),
                            SizedBox(height: 4),
                            Text(
                              allNotifications[i]["createdate"],
                              style: TextStyle(
                                fontFamily: 'Nunito Sans',
                                fontSize: 12,
                                fontWeight: FontWeight.normal,
                                color: Color.fromRGBO(0, 0, 0, 0.5),
                              ),
                            ),
                            SizedBox(height: 10),
                            allNotifications[i]["post_id"] == "sent" &&
                                    allNotifications[i]["is_clicked"] == "false"
                                ? Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Container(
                                        height: 30,
                                        width: 110,
                                        child: RaisedButton(
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8.0)),
                                            color: Color(0xff0C2551),
                                            splashColor: Color(0xff0C2551),
                                            child: Center(
                                              child: Text(
                                                "Confirm",
                                                style: GoogleFonts.raleway(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 13),
                                              ),
                                            ),
                                            onPressed: () async {
                                              notifyCRUD
                                                  .updateNotificationDetails([
                                                allNotifications[i]["notify_id"]
                                              ]);
                                              for (int k = 0;
                                                  k <
                                                      allConnections!
                                                          .docs.length;
                                                  k++) {
                                                if ((allConnections!.docs[k].get(
                                                            "otheruserid") ==
                                                        _currentUserId) &&
                                                    (allConnections!.docs[k]
                                                            .get("userid") ==
                                                        allNotifications[i]
                                                            ["sender_id"])) {
                                                  crudobj
                                                      .updateUserConnectionData(
                                                          allConnections!
                                                              .docs[k].id,
                                                          {
                                                        "isfriend": true,
                                                        "isfollowing": true,
                                                        "onlyfollowing": false,
                                                        "isrequestaccepted":
                                                            true
                                                      });
                                                }
                                              }
                                              ////////////////////////////notification//////////////////////////////////////
                                              String notify_id =
                                                  "ntf${allNotifications[i]["sender_id"]}frndacc$comparedate";
                                              notifyCRUD.sendNotification([
                                                notify_id,
                                                "friendrequest",
                                                "friend",
                                                _currentUserId,
                                                allNotifications[i]
                                                    ["sender_id"],
                                                countData!.value["usertoken"][
                                                        allNotifications[i]
                                                            ["sender_id"]]
                                                    ["tokenid"],
                                                "Listen!",
                                                "${userDataDB!.get("first_name")} ${userDataDB!.get("last_name")} accepted your friend request.",
                                                "accepted",
                                                "friend",
                                                "false",
                                                comparedate,
                                                "add"
                                              ]);
                                              //////////////////////////////////////////////////////////////////////////

                                              crudobj.addUserInConnection(
                                                  userDataDB!
                                                          .get("first_name") +
                                                      " " +
                                                      userDataDB!
                                                          .get("last_name"),
                                                  userDataDB!.get("profilepic"),
                                                  allNotifications[i]
                                                      ["sender_id"],
                                                  true,
                                                  true,
                                                  true,
                                                  false,
                                                  current_date,
                                                  comparedate);
                                              allNotifications = [];
                                              _allNotifications();
                                            }),
                                      ),
                                      Container(
                                        height: 30,
                                        width: 110,
                                        child: RaisedButton(
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8.0)),
                                            color: Colors.white,
                                            splashColor: Colors.white,
                                            child: Center(
                                              child: Text(
                                                "Delete",
                                                style: GoogleFonts.raleway(
                                                    color: Color(0xff0C2551),
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 13),
                                              ),
                                            ),
                                            onPressed: () async {
                                              for (int k = 0;
                                                  k <
                                                      allConnections!
                                                          .docs.length;
                                                  k++) {
                                                if ((allConnections!.docs[k]
                                                            .get("userid") ==
                                                        _currentUserId) &&
                                                    (allConnections!.docs[k].get(
                                                            "otheruserid") ==
                                                        allNotifications[i]
                                                            ["sender_id"])) {
                                                  crudobj
                                                      .deleteUserConnectionData(
                                                          allConnections!
                                                              .docs[k].id);
                                                }
                                                if ((allConnections!.docs[k].get(
                                                            "otheruserid") ==
                                                        _currentUserId) &&
                                                    (allConnections!.docs[k]
                                                            .get("userid") ==
                                                        allNotifications[i]
                                                            ["sender_id"])) {
                                                  crudobj
                                                      .deleteUserConnectionData(
                                                          allConnections!
                                                              .docs[k].id);
                                                }
                                              }
                                              notifyCRUD
                                                  .deleteNotificationDetails([
                                                allNotifications[i]["notify_id"]
                                              ]);
                                              _get_allNotifications();
                                            }),
                                      ),
                                    ],
                                  )
                                : SizedBox(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _loading() {
    return Center(
      child: Container(
          height: 50.0,
          margin: EdgeInsets.only(left: 10.0, right: 10.0),
          child: Center(
              child: CircularProgressIndicator(
            valueColor:
                AlwaysStoppedAnimation<Color>(Color.fromRGBO(88, 165, 196, 1)),
          ))),
    );
  }
}
