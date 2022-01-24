import 'package:HyS/constants/style.dart';
import 'package:HyS/database/crud.dart';
import 'package:HyS/database/feedpostDB.dart';
import 'package:HyS/services/auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:fluttericon/mfg_labs_icons.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:search_page/search_page.dart';

class AllChatScreen extends StatefulWidget {
  @override
  _AllChatScreenState createState() => _AllChatScreenState();
}

class Person {
  final String userid;
  final String username;
  final String userprofilepic;
  final int userindex;

  Person(this.userid, this.username, this.userprofilepic, this.userindex);
}

class _AllChatScreenState extends State<AllChatScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  String current_date = DateFormat.yMMMMd('en_US').format(DateTime.now());
  String comparedate = DateFormat('yyyyMMddkkmm').format(DateTime.now());
  QuerySnapshot? personaldata;
  QuerySnapshot? schooldata;
  QuerySnapshot? allUserpersonaldata;

  List<Person> groupmember = [];
  List<String> groupmemberid = [];
  List<String> groupmembername = [];
  List<String> groupmemberprofilepic = [];
  CrudMethods crudobj = CrudMethods();
  SocialFeedPost socialFeed = SocialFeedPost();
  String _currentUserId = FirebaseAuth.instance.currentUser!.uid;
  QuerySnapshot? socialfeed;
  QuerySnapshot? chatIds;
  QuerySnapshot? chatDetails;
  QuerySnapshot? groupdetails;
  DataSnapshot? countData;
  DataSnapshot? callStatusCheck;
  DataSnapshot? currentstatus;
  DataSnapshot? unreadmessagecountdata;
  final AuthService _auth = AuthService();
  final databaseReference = FirebaseDatabase.instance.reference();
  List userDetails = [];
  String collectionID = "";

  Box<dynamic>? userpersonaldataLocalDB;
  List<bool> _selectedindex = [];
  bool indexcountbool = false;
  String groupname = "";
  List<Person> allusers = [];
  PanelController _pc = new PanelController();
  bool changepanel = false;
  TabController? _tabController;
  ScrollController? _scrollController;

  @override
  void initState() {
    userpersonaldataLocalDB = Hive.box<dynamic>('userdata');
    crudobj.getUserData().then((value) {
      setState(() {
        personaldata = value;
      });
    });

    socialFeed.getAllUserData().then((value) {
      setState(() {
        allUserpersonaldata = value;
        if (allUserpersonaldata != null) {
          for (int k = 0; k < allUserpersonaldata!.docs.length; k++) {
            _selectedindex.add(false);
            allusers.add(Person(
                allUserpersonaldata!.docs[k].get("userid"),
                allUserpersonaldata!.docs[k].get("firstname") +
                    " " +
                    allUserpersonaldata!.docs[k].get("lastname"),
                allUserpersonaldata!.docs[k].get("profilepic"),
                k));
          }
        }
      });
    });
    socialFeed.getSocialMediaChatIDs().then((value) {
      setState(() {
        chatIds = value;
      });
    });
    socialFeed.getSocialMediaChat().then((value) {
      setState(() {
        chatDetails = value;
      });
    });
    socialFeed.getSocialMediaGroupChatIDs().then((value) {
      setState(() {
        groupdetails = value;
      });
    });

    super.initState();
    _scrollController = ScrollController();
    _tabController = TabController(length: 2, vsync: this);
  }

  String getTimeDifferenceFromNow(String dateTime) {
    DateTime todayDate = DateTime.parse(dateTime);
    Duration difference = DateTime.now().difference(todayDate);
    if (difference.inSeconds < 5) {
      return "Just now";
    } else if (difference.inMinutes < 1) {
      return "Just now";
    } else if (difference.inHours < 1) {
      return "${difference.inMinutes} m";
    } else if (difference.inHours < 24) {
      return "${difference.inHours} h";
    } else {
      return "${difference.inDays} d";
    }
  }

  @override
  void dispose() {
    print("dispose");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlidingUpPanel(
      controller: _pc,
      minHeight: 1,
      maxHeight: MediaQuery.of(context).size.height,
      body: _body(context),
      panel: _panel(context),
    );
  }

  _body(BuildContext context) {
    databaseReference
        .child("usersloginstatus")
        .once()
        .then((DataSnapshot snapshot) {
      setState(() {
        if (mounted) {
          setState(() {
            currentstatus = snapshot;
          });
        }
      });
    });
    databaseReference
        .child("unreadmessagecount")
        .once()
        .then((DataSnapshot snapshot) {
      setState(() {
        if (mounted) {
          setState(() {
            unreadmessagecountdata = snapshot;
          });
        }
      });
    });

    if ((personaldata != null) &&
        (allUserpersonaldata != null) &&
        (chatIds != null) &&
        (chatDetails != null) &&
        (currentstatus != null) &&
        (unreadmessagecountdata != null) &&
        (groupdetails != null)) {
      return SizedBox(
          width: 500,
          child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                children: [
                  SizedBox(
                    height: 40,
                  ),
                  Container(
                    width: 500,
                    padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: light,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          onTap: () {
                            databaseReference
                                .child("hysweb")
                                .child("app_bar_navigation")
                                .child(FirebaseAuth.instance.currentUser!.uid)
                                .update({"$_currentUserId": 5});
                          },
                          child: CircleAvatar(
                            backgroundImage: NetworkImage(
                                userpersonaldataLocalDB!.get("profilepic")),
                            radius: 25,
                          ),
                        ),
                        InkWell(
                          onTap: () {},
                          child: Container(
                            width: 300,
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                                color: background),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("  Search chat",
                                    style: TextStyle(
                                        color: lightGrey,
                                        fontSize: 16,
                                        fontWeight: FontWeight.normal)),
                                Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: Icon(MfgLabs.search,
                                      color: Colors.black26, size: 17),
                                ),
                              ],
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(FontAwesome5.edit,
                              color: Color.fromRGBO(88, 165, 196, 1), size: 18),
                          onPressed: () {
                            //createNewChat(context);
                            _pc.open();
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                      width: 500,
                      height: 120,
                      padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: light,
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: 7,
                        scrollDirection: Axis.horizontal,
                        physics: BouncingScrollPhysics(),
                        itemBuilder: (context, index) {
                          return Container(
                            padding: EdgeInsets.all(5),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Stack(
                                  children: [
                                    InkWell(
                                        onTap: () {},
                                        child: Container(
                                          height: 50,
                                          width: 50,
                                          decoration: new BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                                color: const Color(0xff0962ff)),
                                          ),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(25.0),
                                            child: CachedNetworkImage(
                                              imageUrl: allUserpersonaldata!
                                                  .docs[index]
                                                  .get("profilepic"),
                                              fit: BoxFit.cover,
                                              placeholder: (context, url) =>
                                                  Container(
                                                      height: 30,
                                                      width: 30,
                                                      child: Image.network(
                                                        "https://firebasestorage.googleapis.com/v0/b/hys-pro-41c66.appspot.com/o/assets%2Floadingimg.gif?alt=media&token=4ca910f2-c584-4b3a-bbcb-2f1c01d93f67",
                                                      )),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      Icon(Icons.error),
                                            ),
                                          ),
                                        )),
                                    index == 0
                                        ? Positioned(
                                            child: Icon(
                                              Icons.add_circle_rounded,
                                              size: 20,
                                              color: Color.fromRGBO(
                                                  88, 165, 196, 1),
                                            ),
                                          )
                                        : SizedBox()
                                  ],
                                ),
                                SizedBox(height: 5),
                                Text(
                                  (allUserpersonaldata!.docs[index]
                                                  .get("firstname") +
                                              " " +
                                              allUserpersonaldata!.docs[index]
                                                  .get("lastname"))
                                          .toString()
                                          .substring(0, 10) +
                                      "...",
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.black54),
                                ),
                              ],
                            ),
                          );
                        },
                      )),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    width: 500,
                    padding: const EdgeInsets.only(left: 15.0),
                    child: TabBar(
                        controller: _tabController,
                        indicatorColor: Colors.transparent,
                        labelColor: Color(0xff0C2551),
                        isScrollable: true,
                        labelPadding: EdgeInsets.only(right: 20.0),
                        unselectedLabelColor: Color(0xFFB1B1B1),
                        physics: BouncingScrollPhysics(),
                        tabs: [
                          Tab(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8)),
                                  child: Text('    Personal Chat    ',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontFamily: 'Nunito Sans',
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800,
                                      )),
                                ),
                              ],
                            ),
                          ),
                          Tab(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8)),
                                  child: Text('    Group Chat    ',
                                      style: TextStyle(
                                        fontFamily: 'Nunito Sans',
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800,
                                      )),
                                ),
                              ],
                            ),
                          )
                        ]),
                  ),
                  Container(
                      height: MediaQuery.of(context).size.height - 50,
                      width: 500,
                      child: TabBarView(
                          physics: BouncingScrollPhysics(),
                          controller: _tabController,
                          children: [_personalchat(), _groupchat()])),
                ],
              )));
    }
  }

  _personalchat() {
    return ((1 != 0))
        ? Container(
            height: MediaQuery.of(context).size.height - 100,
            width: 500,
            child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('messages')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xff0962ff),
                        ),
                      ),
                    );
                  } else {
                    List<DocumentSnapshot> items = snapshot.data!.docs;
                    return ListView.builder(
                      itemCount: items.length,
                      controller: _scrollController,
                      itemBuilder: (BuildContext context, int i) {
                        return ((items[i].get("userid") == _currentUserId) ||
                                (items[i].get("otheruserid") == _currentUserId)
                            ? InkWell(
                                onTap: () {
                                  userDetails = [
                                    items[i].get("username"),
                                    items[i].get("userid"),
                                    items[i].get("userprofilepic"),
                                    items[i].get("otherusername"),
                                    items[i].get("otheruserid"),
                                    items[i].get("otheruserprofilepic"),
                                  ];
                                  collectionID = items[i].get("chatid");
                                  databaseReference
                                      .child("hysweb")
                                      .child("chat")
                                      .child(FirebaseAuth
                                          .instance.currentUser!.uid)
                                      .update({
                                    "index": 1,
                                    "userdetails": userDetails,
                                    "chatid": collectionID
                                  });
                                },
                                child: Container(
                                  height: 85,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      InkWell(
                                          child: Stack(
                                        children: [
                                          Container(
                                            margin: EdgeInsets.all(10),
                                            height: 45,
                                            width: 45,
                                            decoration: new BoxDecoration(
                                              shape: BoxShape.circle,
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(25.0),
                                              child: CachedNetworkImage(
                                                imageUrl: _currentUserId !=
                                                        items[i]
                                                            .get("otheruserid")
                                                    ? items[i].get(
                                                        "otheruserprofilepic")
                                                    : _currentUserId !=
                                                            items[i]
                                                                .get("userid")
                                                        ? items[i].get(
                                                            "userprofilepic")
                                                        : "https://firebasestorage.googleapis.com/v0/b/hys-pro-41c66.appspot.com/o/userProfile%2FOMjugi0iu8NEZd6MnKRKa7SkhGJ3%2FOMjugi0iu8NEZd6MnKRKa7SkhGJ3image_cropper_1617796475933.jpg?alt=media&token=723ad693-d108-4fb4-87eb-4062775e92b6",
                                                fit: BoxFit.cover,
                                                placeholder: (context, url) =>
                                                    Container(
                                                        height: 30,
                                                        width: 30,
                                                        child: Image.network(
                                                          "https://firebasestorage.googleapis.com/v0/b/hys-pro-41c66.appspot.com/o/assets%2Floadingimg.gif?alt=media&token=4ca910f2-c584-4b3a-bbcb-2f1c01d93f67",
                                                        )),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        Icon(Icons.error),
                                              ),
                                            ),
                                          ),
                                          items[i].get("isblocked") == false
                                              ? Positioned(
                                                  top: 40,
                                                  left: 44,
                                                  child: Icon(
                                                    Icons.circle,
                                                    size: 12,
                                                    color: ((currentstatus !=
                                                                null) &&
                                                            (currentstatus!
                                                                    .value[_currentUserId !=
                                                                        items[i].get(
                                                                            "otheruserid")
                                                                    ? items[i].get(
                                                                        "otheruserid")
                                                                    : _currentUserId !=
                                                                            items[i].get(
                                                                                "userid")
                                                                        ? items[i].get(
                                                                            "userid")
                                                                        : items[i]
                                                                            .get("userid")]["currentstatus"] ==
                                                                "online"))
                                                        ? Colors.green
                                                        : Colors.orangeAccent,
                                                  ),
                                                )
                                              : SizedBox()
                                        ],
                                      )),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Container(
                                        height: 85,
                                        padding: EdgeInsets.only(
                                            top: 10, bottom: 10, right: 20),
                                        width: 430,
                                        decoration: BoxDecoration(
                                            border: Border(
                                                bottom: BorderSide(
                                                    color: Colors.black12))),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                RichText(
                                                  text: TextSpan(
                                                      text: _currentUserId !=
                                                              items[i].get(
                                                                  "otheruserid")
                                                          ? items[i].get(
                                                              "otherusername")
                                                          : _currentUserId !=
                                                                  items[i].get(
                                                                      "userid")
                                                              ? items[i].get(
                                                                  "username")
                                                              : "HyS ChatBot",
                                                      style: TextStyle(
                                                        fontFamily:
                                                            'Nunito Sans',
                                                        fontSize: 15,
                                                        color: Color.fromRGBO(
                                                            0, 0, 0, 0.7),
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                      children: <TextSpan>[
                                                        TextSpan(
                                                          text: ' ,  Delhi',
                                                          style: TextStyle(
                                                            fontFamily:
                                                                'Nunito Sans',
                                                            fontSize: 12,
                                                            color:
                                                                Color.fromRGBO(
                                                                    0,
                                                                    0,
                                                                    0,
                                                                    0.5),
                                                            fontWeight:
                                                                FontWeight.w400,
                                                          ),
                                                        )
                                                      ]),
                                                ),
                                                items[i].get(
                                                            "lastmessagetime") !=
                                                        ""
                                                    ? Text(
                                                        getTimeDifferenceFromNow(
                                                            items[i].get(
                                                                "lastmessagetime")),
                                                        style: TextStyle(
                                                          fontFamily:
                                                              'Nunito Sans',
                                                          fontSize: 12,
                                                          color: Color.fromRGBO(
                                                              0, 0, 0, 0.35),
                                                          fontWeight:
                                                              FontWeight.w400,
                                                        ),
                                                      )
                                                    : SizedBox()
                                              ],
                                            ),
                                            SizedBox(
                                              height: 5,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Container(
                                                  width: 250,
                                                  child: Text(
                                                    items[i]
                                                                .get(
                                                                    "lastmessage")
                                                                .toString()
                                                                .length <
                                                            80
                                                        ? items[i]
                                                            .get("lastmessage")
                                                        : items[i]
                                                                .get(
                                                                    "lastmessage")
                                                                .toString()
                                                                .substring(
                                                                    0, 80) +
                                                            "...",
                                                    style: TextStyle(
                                                      fontFamily: 'Nunito Sans',
                                                      fontSize: 15,
                                                      color: Color.fromRGBO(
                                                          0, 0, 0, 0.6),
                                                      fontWeight: unreadmessagecountdata!
                                                                      .value[items[
                                                                          i]
                                                                      .get(
                                                                          "chatid")]
                                                                  [
                                                                  _currentUserId] >
                                                              0
                                                          ? FontWeight.w700
                                                          : FontWeight.w400,
                                                    ),
                                                  ),
                                                ),
                                                unreadmessagecountdata!.value[
                                                                items[i].get(
                                                                    "chatid")]
                                                            [_currentUserId] >
                                                        0
                                                    ? Container(
                                                        padding:
                                                            EdgeInsets.all(5),
                                                        decoration: BoxDecoration(
                                                            color:
                                                                Color.fromRGBO(
                                                                    88,
                                                                    165,
                                                                    196,
                                                                    1),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        100)),
                                                        child: Center(
                                                          child: Text("1",
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize: 14,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700)),
                                                        ),
                                                      )
                                                    : SizedBox(),
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : SizedBox());
                      },
                    );
                  }
                }),
          )
        : InkWell(
            onTap: () {
              _pc.open();
            },
            child: Container(
              child: Image.network(
                  "https://firebasestorage.googleapis.com/v0/b/hys-pro-41c66.appspot.com/o/assets%2Fnochat.gif?alt=media&token=a51f2287-7deb-4217-87ae-8dd80b53e3f2"),
            ),
          );
  }

  _groupchat() {
    return ((1 != 0))
        ? Container(
            height: MediaQuery.of(context).size.height - 100,
            width: 500,
            child: StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance.collection('groups').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xff0962ff),
                        ),
                      ),
                    );
                  } else {
                    List<DocumentSnapshot> items = snapshot.data!.docs;
                    return ListView.builder(
                      itemCount: items.length,
                      controller: _scrollController,
                      itemBuilder: (BuildContext context, int i) {
                        bool checkuserpresenceingroup = false;
                        List usersidlist = items[i].get("groupmemberid");

                        for (int b = 0; b < usersidlist.length; b++) {
                          if (_currentUserId == usersidlist[b]) {
                            checkuserpresenceingroup = true;
                            break;
                          }
                        }
                        return (checkuserpresenceingroup == true)
                            ? InkWell(
                                onTap: () {
                                  List userDetails = [
                                    personaldata!.docs[0].get("firstname") +
                                        " " +
                                        personaldata!.docs[0].get("lastname"),
                                    personaldata!.docs[0].get("userid"),
                                    personaldata!.docs[0].get("profilepic")
                                  ];
                                  databaseReference
                                      .child("hysweb")
                                      .child("chat")
                                      .child(FirebaseAuth
                                          .instance.currentUser!.uid)
                                      .update({
                                    "index": 2,
                                    "userdetails": userDetails,
                                    "chatid": items[i].get("chatid")
                                  });
                                },
                                child: Container(
                                  height: 85,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      InkWell(
                                          child: Stack(
                                        children: [
                                          Container(
                                            margin: EdgeInsets.all(10),
                                            height: 45,
                                            width: 45,
                                            decoration: new BoxDecoration(
                                              shape: BoxShape.circle,
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(25.0),
                                              child: CachedNetworkImage(
                                                imageUrl: items[i]
                                                    .get("groupprofile"),
                                                fit: BoxFit.cover,
                                                placeholder: (context, url) =>
                                                    Container(
                                                        height: 30,
                                                        width: 30,
                                                        child: Image.network(
                                                          "https://firebasestorage.googleapis.com/v0/b/hys-pro-41c66.appspot.com/o/assets%2Floadingimg.gif?alt=media&token=4ca910f2-c584-4b3a-bbcb-2f1c01d93f67",
                                                        )),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        Icon(Icons.error),
                                              ),
                                            ),
                                          ),
                                        ],
                                      )),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Container(
                                        height: 85,
                                        padding: EdgeInsets.only(
                                            top: 10, bottom: 10, right: 20),
                                        width: 430,
                                        decoration: BoxDecoration(
                                            border: Border(
                                                bottom: BorderSide(
                                                    color: Colors.black12))),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                RichText(
                                                  text: TextSpan(
                                                      text: items[i]
                                                                  .get(
                                                                      "groupname")
                                                                  .toString()
                                                                  .length >
                                                              30
                                                          ? items[i]
                                                                  .get(
                                                                      "groupname")
                                                                  .toString()
                                                                  .substring(
                                                                      0, 30) +
                                                              "..."
                                                          : items[i]
                                                              .get("groupname")
                                                              .toString(),
                                                      style: TextStyle(
                                                        fontFamily:
                                                            'Nunito Sans',
                                                        fontSize: 15,
                                                        color: Color.fromRGBO(
                                                            0, 0, 0, 0.7),
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                      children: <TextSpan>[
                                                        TextSpan(
                                                          text: '',
                                                          style: TextStyle(
                                                            fontFamily:
                                                                'Nunito Sans',
                                                            fontSize: 12,
                                                            color:
                                                                Color.fromRGBO(
                                                                    0,
                                                                    0,
                                                                    0,
                                                                    0.5),
                                                            fontWeight:
                                                                FontWeight.w400,
                                                          ),
                                                        )
                                                      ]),
                                                ),
                                                items[i].get(
                                                            "lastmessagetime") !=
                                                        ""
                                                    ? Text(
                                                        getTimeDifferenceFromNow(
                                                            items[i].get(
                                                                "lastmessagetime")),
                                                        style: TextStyle(
                                                          fontFamily:
                                                              'Nunito Sans',
                                                          fontSize: 12,
                                                          color: Color.fromRGBO(
                                                              0, 0, 0, 0.35),
                                                          fontWeight:
                                                              FontWeight.w400,
                                                        ),
                                                      )
                                                    : SizedBox()
                                              ],
                                            ),
                                            SizedBox(
                                              height: 5,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Container(
                                                  width: 250,
                                                  child: Text(
                                                    items[i]
                                                                .get(
                                                                    "lastmessage")
                                                                .toString()
                                                                .length <
                                                            80
                                                        ? items[i]
                                                            .get("lastmessage")
                                                        : items[i]
                                                                .get(
                                                                    "lastmessage")
                                                                .toString()
                                                                .substring(
                                                                    0, 80) +
                                                            "...",
                                                    style: TextStyle(
                                                      fontFamily: 'Nunito Sans',
                                                      fontSize: 15,
                                                      color: Color.fromRGBO(
                                                          0, 0, 0, 0.6),
                                                      fontWeight:
                                                          FontWeight.w400,
                                                    ),
                                                  ),
                                                ),
                                                // unreadmessagecountdata.value[
                                                //                 items[i].get(
                                                //                     "chatid")]
                                                //             [_currentUserId] >
                                                //         0
                                                //     ? Container(
                                                //         padding:
                                                //             EdgeInsets.all(5),
                                                //         decoration: BoxDecoration(
                                                //             color:
                                                //                 Color.fromRGBO(
                                                //                     88,
                                                //                     165,
                                                //                     196,
                                                //                     1),
                                                //             borderRadius:
                                                //                 BorderRadius
                                                //                     .circular(
                                                //                         100)),
                                                //         child: Center(
                                                //           child: Text("1",
                                                //               style: TextStyle(
                                                //                   color: Colors
                                                //                       .white,
                                                //                   fontSize: 14,
                                                //                   fontWeight:
                                                //                       FontWeight
                                                //                           .w700)),
                                                //         ),
                                                //       )
                                                //     : SizedBox(),
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : SizedBox();
                      },
                    );
                  }
                }),
          )
        : InkWell(
            onTap: () {
              _pc.open();
            },
            child: Container(
              child: Image.network(
                  "https://firebasestorage.googleapis.com/v0/b/hys-pro-41c66.appspot.com/o/assets%2Fnochat.gif?alt=media&token=a51f2287-7deb-4217-87ae-8dd80b53e3f2"),
            ),
          );
  }

  _panel(BuildContext context) {
    databaseReference
        .child("usersloginstatus")
        .once()
        .then((DataSnapshot snapshot) {
      setState(() {
        if (mounted) {
          setState(() {
            currentstatus = snapshot;
          });
        }
      });
    });
    databaseReference
        .child("unreadmessagecount")
        .once()
        .then((DataSnapshot snapshot) {
      setState(() {
        if (mounted) {
          setState(() {
            unreadmessagecountdata = snapshot;
          });
        }
      });
    });

    if ((personaldata != null) &&
        (allUserpersonaldata != null) &&
        (chatIds != null) &&
        (chatDetails != null) &&
        (currentstatus != null) &&
        (unreadmessagecountdata != null) &&
        (groupdetails != null)) {
      return changepanel == true
          ? Container(
              height: MediaQuery.of(context).size.height - 30,
              width: 500,
              margin: EdgeInsets.only(left: 1, right: 1),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10)),
                color: Colors.white,
              ),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10.0, left: 5, right: 5),
                child: ListView(
                  physics: BouncingScrollPhysics(),
                  children: [
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              changepanel = false;
                            });
                          },
                          child: Container(
                            child: Text(
                              "  Cancel",
                              style: TextStyle(
                                fontFamily: 'Nunito Sans',
                                fontSize: 18,
                                color: Color.fromRGBO(0, 0, 0, 0.7),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        Text(
                          "New Group",
                          style: TextStyle(
                            fontFamily: 'Nunito Sans',
                            fontSize: 18,
                            color: Color.fromRGBO(0, 0, 0, 0.8),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            setState(() {
                              if (groupmember.length > 1) {
                                bool alreadyexist = false;
                                String defaultgroupname =
                                    personaldata!.docs[0].get("firstname") +
                                        " " +
                                        personaldata!.docs[0].get("lastname");
                                groupmemberid
                                    .add(personaldata!.docs[0].get("userid"));
                                groupmembername.add(
                                    personaldata!.docs[0].get("firstname") +
                                        " " +
                                        personaldata!.docs[0].get("lastname"));
                                groupmemberprofilepic.add(
                                    personaldata!.docs[0].get("profilepic"));

                                for (int m = 0; m < groupmember.length; m++) {
                                  Person person = groupmember[m];
                                  groupmemberid.add(person.userid);
                                  groupmembername.add(person.username);
                                  groupmemberprofilepic
                                      .add(person.userprofilepic);
                                  defaultgroupname =
                                      defaultgroupname + " " + person.username;
                                }

                                for (int d = 0;
                                    d < groupdetails!.docs.length;
                                    d++) {
                                  if (groupname != "" && groupname != " ") {
                                    if (groupdetails!.docs[d].id == groupname) {
                                      alreadyexist = true;
                                      groupmemberid.clear();
                                      groupmembername.clear();
                                      groupmemberprofilepic.clear();

                                      break;
                                    }
                                  } else {
                                    if (groupdetails!.docs[d].id ==
                                        defaultgroupname) {
                                      alreadyexist = true;
                                      groupmemberid.clear();
                                      groupmembername.clear();
                                      groupmemberprofilepic.clear();
                                      break;
                                    }
                                  }
                                }
                                if (alreadyexist == false) {
                                  socialFeed.createGroupChatID(
                                      (groupname != "" && groupname != " ")
                                          ? groupname
                                          : defaultgroupname,
                                      personaldata!.docs[0].get("firstname") +
                                          " " +
                                          personaldata!.docs[0].get("lastname"),
                                      _currentUserId,
                                      personaldata!.docs[0].get("profilepic"),
                                      groupmemberid,
                                      groupmembername,
                                      groupmemberprofilepic,
                                      (groupname != "" && groupname != " ")
                                          ? groupname
                                          : defaultgroupname,
                                      current_date);

                                  _pc.close();

                                  databaseReference
                                      .child("hysweb")
                                      .child("chat")
                                      .child(FirebaseAuth
                                          .instance.currentUser!.uid)
                                      .update({
                                    "index": 2,
                                    "userdetails": [
                                      personaldata!.docs[0].get("firstname") +
                                          " " +
                                          personaldata!.docs[0].get("lastname"),
                                      _currentUserId,
                                      personaldata!.docs[0].get("profilepic")
                                    ],
                                    "chatid":
                                        (groupname != "" && groupname != " ")
                                            ? groupname
                                            : defaultgroupname
                                  });
                                }
                              }
                            });
                          },
                          child: Text(
                            "Create  ",
                            style: TextStyle(
                              fontFamily: 'Nunito Sans',
                              fontSize: 18,
                              color: groupmember.length > 1
                                  ? Color.fromRGBO(0, 0, 0, 0.7)
                                  : Color.fromRGBO(0, 0, 0, 0.3),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Container(
                      height: 40,
                      padding: EdgeInsets.only(bottom: 8),
                      width: MediaQuery.of(context).size.width - 57,
                      child: Center(
                        child: TextField(
                          textAlignVertical: TextAlignVertical.top,
                          textAlign: TextAlign.start,
                          keyboardType: TextInputType.text,
                          cursorColor: Color.fromRGBO(88, 165, 196, 1),
                          style: TextStyle(
                              fontSize: 17,
                              color: Colors.black87,
                              fontWeight: FontWeight.w400),
                          onChanged: (val) {
                            setState(() => groupname = val);
                          },
                          decoration: InputDecoration(
                            hintText: "Group name (Optional)",
                            hintStyle: TextStyle(
                              fontFamily: 'Nunito Sans',
                              fontSize: 18,
                              color: Color.fromRGBO(0, 0, 0, 0.4),
                              fontWeight: FontWeight.w400,
                            ),
                            border: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    InkWell(
                      onTap: () async {
                        setState(() {
                          showSearch(
                            context: context,
                            delegate: SearchPage<Person>(
                                onQueryUpdate: (s) => print(s),
                                items: allusers,
                                suggestion: ListView.builder(
                                  itemCount: allusers.length,
                                  itemBuilder: (context, index) {
                                    final Person person = allusers[index];
                                    return InkWell(
                                      onTap: () {
                                        setState(() {
                                          if (_selectedindex[index] == false) {
                                            Person person = Person(
                                                allUserpersonaldata!.docs[index]
                                                    .get("userid"),
                                                allUserpersonaldata!.docs[index]
                                                        .get("firstname") +
                                                    " " +
                                                    allUserpersonaldata!
                                                        .docs[index]
                                                        .get("lastname"),
                                                allUserpersonaldata!.docs[index]
                                                    .get("profilepic"),
                                                index);
                                            groupmember.add(person);
                                            _selectedindex[index] = true;
                                          } else {
                                            for (int j = 0;
                                                j < groupmember.length;
                                                j++) {
                                              final Person person =
                                                  groupmember[j];
                                              if (person.userid ==
                                                  allUserpersonaldata!.docs[j]
                                                      .get("userid")) {
                                                groupmember.removeAt(j);
                                              }
                                            }

                                            _selectedindex[index] = false;
                                          }
                                          _pc.close();
                                        });
                                      },
                                      child: Container(
                                        margin: EdgeInsets.all(2),
                                        padding: EdgeInsets.all(2),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            InkWell(
                                                child: Container(
                                              margin: EdgeInsets.all(10),
                                              height: 45,
                                              width: 45,
                                              decoration: new BoxDecoration(
                                                shape: BoxShape.circle,
                                              ),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(25.0),
                                                child: CachedNetworkImage(
                                                  imageUrl:
                                                      person.userprofilepic,
                                                  fit: BoxFit.cover,
                                                  placeholder: (context, url) =>
                                                      Container(
                                                          height: 30,
                                                          width: 30,
                                                          child: Image.network(
                                                            "https://firebasestorage.googleapis.com/v0/b/hys-pro-41c66.appspot.com/o/assets%2Floadingimg.gif?alt=media&token=4ca910f2-c584-4b3a-bbcb-2f1c01d93f67",
                                                          )),
                                                  errorWidget:
                                                      (context, url, error) =>
                                                          Icon(Icons.error),
                                                ),
                                              ),
                                            )),
                                            SizedBox(
                                              width: 5,
                                            ),
                                            Text(
                                              person.username,
                                              style: TextStyle(
                                                fontFamily: 'Nunito Sans',
                                                fontSize: 18,
                                                color: Color.fromRGBO(
                                                    0, 0, 0, 0.8),
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                failure: Center(
                                  child: Text('No person found :('),
                                ),
                                filter: (person) => [person.username],
                                builder: (person) => InkWell(
                                      onTap: () {
                                        List userDetails = [
                                          personaldata!.docs[0]
                                                  .get("firstname") +
                                              " " +
                                              personaldata!.docs[0]
                                                  .get("lastname"),
                                          personaldata!.docs[0].get("userid"),
                                          personaldata!.docs[0]
                                              .get("profilepic"),
                                          person.username,
                                          person.userid,
                                          person.userprofilepic
                                        ];
                                        bool check = false;
                                        if (chatIds!.docs.length > 0) {
                                          for (int k = 0;
                                              k < chatIds!.docs.length;
                                              k++) {
                                            if (personaldata!.docs[0]
                                                        .get("userid") +
                                                    person.userid ==
                                                chatIds!.docs[k].id) {
                                              check = true;

                                              _pc.close();
                                              databaseReference
                                                  .child("hysweb")
                                                  .child("chat")
                                                  .child(FirebaseAuth.instance
                                                      .currentUser!.uid)
                                                  .update({
                                                "index": 1,
                                                "userdetails": userDetails,
                                                "chatid": personaldata!.docs[0]
                                                        .get("userid") +
                                                    person.userid
                                              });
                                            } else if (person.userid +
                                                    personaldata!.docs[0]
                                                        .get("userid") ==
                                                chatIds!.docs[k].id) {
                                              check = true;
                                              _pc.close();
                                              databaseReference
                                                  .child("hysweb")
                                                  .child("chat")
                                                  .child(FirebaseAuth.instance
                                                      .currentUser!.uid)
                                                  .update({
                                                "index": 1,
                                                "userdetails": userDetails,
                                                "chatid": person.userid +
                                                    personaldata!.docs[0]
                                                        .get("userid")
                                              });
                                            }
                                          }
                                        }
                                        if (check != true) {
                                          socialFeed.createChatID(
                                              personaldata!.docs[0]
                                                      .get("firstname") +
                                                  " " +
                                                  personaldata!.docs[0]
                                                      .get("lastname"),
                                              personaldata!.docs[0]
                                                  .get("userid"),
                                              personaldata!.docs[0]
                                                  .get("profilepic"),
                                              person.username,
                                              person.userid,
                                              person.userprofilepic,
                                              personaldata!.docs[0]
                                                      .get("userid") +
                                                  person.userid,
                                              current_date);
                                          _pc.close();
                                          databaseReference
                                              .child("hysweb")
                                              .child("chat")
                                              .child(FirebaseAuth
                                                  .instance.currentUser!.uid)
                                              .update({
                                            "index": 1,
                                            "userdetails": userDetails,
                                            "chatid": personaldata!.docs[0]
                                                    .get("userid") +
                                                person.userid
                                          });
                                        }
                                      },
                                      child: Container(
                                        margin: EdgeInsets.all(2),
                                        padding: EdgeInsets.all(2),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            InkWell(
                                                child: Container(
                                              margin: EdgeInsets.all(10),
                                              height: 45,
                                              width: 45,
                                              decoration: new BoxDecoration(
                                                shape: BoxShape.circle,
                                              ),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(25.0),
                                                child: CachedNetworkImage(
                                                  imageUrl:
                                                      person.userprofilepic,
                                                  fit: BoxFit.cover,
                                                  placeholder: (context, url) =>
                                                      Container(
                                                          height: 30,
                                                          width: 30,
                                                          child: Image.network(
                                                            "https://firebasestorage.googleapis.com/v0/b/hys-pro-41c66.appspot.com/o/assets%2Floadingimg.gif?alt=media&token=4ca910f2-c584-4b3a-bbcb-2f1c01d93f67",
                                                          )),
                                                  errorWidget:
                                                      (context, url, error) =>
                                                          Icon(Icons.error),
                                                ),
                                              ),
                                            )),
                                            SizedBox(
                                              width: 5,
                                            ),
                                            Text(
                                              person.username,
                                              style: TextStyle(
                                                fontFamily: 'Nunito Sans',
                                                fontSize: 18,
                                                color: Color.fromRGBO(
                                                    0, 0, 0, 0.8),
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )),
                          );
                        });
                      },
                      child: Container(
                        height: 40,
                        width: MediaQuery.of(context).size.width - 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Color(0xD8F0F0F0),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              "     Search",
                              style: TextStyle(
                                fontFamily: 'Nunito Sans',
                                fontSize: 15,
                                color: Color.fromRGBO(0, 0, 0, 0.5),
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height - 180,
                      child: ListView.builder(
                        itemCount: allUserpersonaldata!.docs.length,
                        physics: BouncingScrollPhysics(),
                        itemBuilder: (BuildContext context, int i) {
                          return InkWell(
                            onTap: () {
                              setState(() {
                                if (_selectedindex[i] == false) {
                                  Person person = Person(
                                      allUserpersonaldata!.docs[i]
                                          .get("userid"),
                                      allUserpersonaldata!.docs[i]
                                              .get("firstname") +
                                          " " +
                                          allUserpersonaldata!.docs[i]
                                              .get("lastname"),
                                      allUserpersonaldata!.docs[i]
                                          .get("profilepic"),
                                      i);
                                  groupmember.add(person);
                                  _selectedindex[i] = true;
                                } else {
                                  for (int j = 0; j < groupmember.length; j++) {
                                    final Person person = groupmember[j];
                                    if (person.userid ==
                                        allUserpersonaldata!.docs[j]
                                            .get("userid")) {
                                      groupmember.removeAt(j);
                                    }
                                  }

                                  _selectedindex[i] = false;
                                }
                              });
                            },
                            child: Container(
                              margin: EdgeInsets.all(2),
                              padding: EdgeInsets.all(2),
                              color: _selectedindex[i] == true
                                  ? Color(0xD8B0F9FC)
                                  : Color(0xFFFFFFFF),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  InkWell(
                                      child: Container(
                                    margin: EdgeInsets.all(10),
                                    height: 45,
                                    width: 45,
                                    decoration: new BoxDecoration(
                                      shape: BoxShape.circle,
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(25.0),
                                      child: CachedNetworkImage(
                                        imageUrl: allUserpersonaldata!.docs[i]
                                            .get("profilepic"),
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) =>
                                            Container(
                                                height: 30,
                                                width: 30,
                                                child: Image.network(
                                                  "https://firebasestorage.googleapis.com/v0/b/hys-pro-41c66.appspot.com/o/assets%2Floadingimg.gif?alt=media&token=4ca910f2-c584-4b3a-bbcb-2f1c01d93f67",
                                                )),
                                        errorWidget: (context, url, error) =>
                                            Icon(Icons.error),
                                      ),
                                    ),
                                  )),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    allUserpersonaldata!.docs[i]
                                            .get("firstname") +
                                        " " +
                                        allUserpersonaldata!.docs[i]
                                            .get("lastname"),
                                    style: TextStyle(
                                      fontFamily: 'Nunito Sans',
                                      fontSize: 18,
                                      color: Color.fromRGBO(0, 0, 0, 0.8),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  ],
                ),
              ),
            )
          : Container(
              height: MediaQuery.of(context).size.height - 100,
              margin: EdgeInsets.only(left: 1, right: 1),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10)),
                color: Colors.white,
              ),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10.0, left: 5, right: 5),
                child: ListView(
                  physics: BouncingScrollPhysics(),
                  children: [
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              changepanel = false;
                            });
                            _pc.close();
                            groupmember.clear();
                          },
                          child: Container(
                            child: Text(
                              "  Cancel",
                              style: TextStyle(
                                fontFamily: 'Nunito Sans',
                                fontSize: 18,
                                color: Color.fromRGBO(0, 0, 0, 0.7),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        Text(
                          "New Message",
                          style: TextStyle(
                            fontFamily: 'Nunito Sans',
                            fontSize: 18,
                            color: Color.fromRGBO(0, 0, 0, 0.8),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          "Secret  ",
                          style: TextStyle(
                            fontFamily: 'Nunito Sans',
                            fontSize: 18,
                            color: Color.fromRGBO(0, 0, 0, 0.4),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    InkWell(
                      onTap: () async {
                        showSearch(
                          context: context,
                          delegate: SearchPage<Person>(
                              onQueryUpdate: (s) => print(s),
                              items: allusers,
                              suggestion: ListView.builder(
                                itemCount: allusers.length,
                                itemBuilder: (context, index) {
                                  final Person person = allusers[index];
                                  return InkWell(
                                    onTap: () {
                                      List userDetails = [
                                        personaldata!.docs[0].get("firstname") +
                                            " " +
                                            personaldata!.docs[0]
                                                .get("lastname"),
                                        personaldata!.docs[0].get("userid"),
                                        personaldata!.docs[0].get("profilepic"),
                                        person.username,
                                        person.userid,
                                        person.userprofilepic
                                      ];
                                      bool check = false;
                                      if (chatIds!.docs.length > 0) {
                                        for (int k = 0;
                                            k < chatIds!.docs.length;
                                            k++) {
                                          if (personaldata!.docs[0]
                                                      .get("userid") +
                                                  person.userid ==
                                              chatIds!.docs[k].id) {
                                            check = true;
                                            _pc.close();
                                            databaseReference
                                                .child("hysweb")
                                                .child("chat")
                                                .child(FirebaseAuth
                                                    .instance.currentUser!.uid)
                                                .update({
                                              "index": 1,
                                              "userdetails": userDetails,
                                              "chatid": personaldata!.docs[0]
                                                      .get("userid") +
                                                  person.userid
                                            });
                                          } else if (person.userid +
                                                  personaldata!.docs[0]
                                                      .get("userid") ==
                                              chatIds!.docs[k].id) {
                                            check = true;
                                            _pc.close();
                                            databaseReference
                                                .child("hysweb")
                                                .child("chat")
                                                .child(FirebaseAuth
                                                    .instance.currentUser!.uid)
                                                .update({
                                              "index": 1,
                                              "userdetails": userDetails,
                                              "chatid": person.userid +
                                                  personaldata!.docs[0]
                                                      .get("userid")
                                            });
                                          }
                                        }
                                      }
                                      if (check != true) {
                                        socialFeed.createChatID(
                                            personaldata!.docs[0]
                                                    .get("firstname") +
                                                " " +
                                                personaldata!.docs[0]
                                                    .get("lastname"),
                                            personaldata!.docs[0].get("userid"),
                                            personaldata!.docs[0]
                                                .get("profilepic"),
                                            person.username,
                                            person.userid,
                                            person.userprofilepic,
                                            personaldata!.docs[0]
                                                    .get("userid") +
                                                person.userid,
                                            current_date);
                                        _pc.close();
                                        databaseReference
                                            .child("hysweb")
                                            .child("chat")
                                            .child(FirebaseAuth
                                                .instance.currentUser!.uid)
                                            .update({
                                          "index": 1,
                                          "userdetails": userDetails,
                                          "chatid": personaldata!.docs[0]
                                                  .get("userid") +
                                              person.userid
                                        });
                                      }
                                    },
                                    child: Container(
                                      margin: EdgeInsets.all(2),
                                      padding: EdgeInsets.all(2),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          InkWell(
                                              child: Container(
                                            margin: EdgeInsets.all(10),
                                            height: 45,
                                            width: 45,
                                            decoration: new BoxDecoration(
                                              shape: BoxShape.circle,
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(25.0),
                                              child: CachedNetworkImage(
                                                imageUrl: person.userprofilepic,
                                                fit: BoxFit.cover,
                                                placeholder: (context, url) =>
                                                    Container(
                                                        height: 30,
                                                        width: 30,
                                                        child: Image.network(
                                                          "https://firebasestorage.googleapis.com/v0/b/hys-pro-41c66.appspot.com/o/assets%2Floadingimg.gif?alt=media&token=4ca910f2-c584-4b3a-bbcb-2f1c01d93f67",
                                                        )),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        Icon(Icons.error),
                                              ),
                                            ),
                                          )),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Text(
                                            person.username,
                                            style: TextStyle(
                                              fontFamily: 'Nunito Sans',
                                              fontSize: 18,
                                              color:
                                                  Color.fromRGBO(0, 0, 0, 0.8),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                              failure: Center(
                                child: Text('No person found :('),
                              ),
                              filter: (person) => [person.username],
                              builder: (person) => InkWell(
                                    onTap: () {
                                      List userDetails = [
                                        personaldata!.docs[0].get("firstname") +
                                            " " +
                                            personaldata!.docs[0]
                                                .get("lastname"),
                                        personaldata!.docs[0].get("userid"),
                                        personaldata!.docs[0].get("profilepic"),
                                        person.username,
                                        person.userid,
                                        person.userprofilepic
                                      ];
                                      bool check = false;
                                      if (chatIds!.docs.length > 0) {
                                        for (int k = 0;
                                            k < chatIds!.docs.length;
                                            k++) {
                                          if (personaldata!.docs[0]
                                                      .get("userid") +
                                                  person.userid ==
                                              chatIds!.docs[k].id) {
                                            check = true;
                                            _pc.close();
                                            databaseReference
                                                .child("hysweb")
                                                .child("chat")
                                                .child(FirebaseAuth
                                                    .instance.currentUser!.uid)
                                                .update({
                                              "index": 1,
                                              "userdetails": userDetails,
                                              "chatid": personaldata!.docs[0]
                                                      .get("userid") +
                                                  person.userid
                                            });
                                          } else if (person.userid +
                                                  personaldata!.docs[0]
                                                      .get("userid") ==
                                              chatIds!.docs[k].id) {
                                            check = true;
                                            _pc.close();
                                            databaseReference
                                                .child("hysweb")
                                                .child("chat")
                                                .child(FirebaseAuth
                                                    .instance.currentUser!.uid)
                                                .update({
                                              "index": 1,
                                              "userdetails": userDetails,
                                              "chatid": person.userid +
                                                  personaldata!.docs[0]
                                                      .get("userid")
                                            });
                                          }
                                        }
                                      }
                                      if (check != true) {
                                        socialFeed.createChatID(
                                            personaldata!.docs[0]
                                                    .get("firstname") +
                                                " " +
                                                personaldata!.docs[0]
                                                    .get("lastname"),
                                            personaldata!.docs[0].get("userid"),
                                            personaldata!.docs[0]
                                                .get("profilepic"),
                                            person.username,
                                            person.userid,
                                            person.userprofilepic,
                                            personaldata!.docs[0]
                                                    .get("userid") +
                                                person.userid,
                                            current_date);
                                        _pc.close();
                                        databaseReference
                                            .child("hysweb")
                                            .child("chat")
                                            .child(FirebaseAuth
                                                .instance.currentUser!.uid)
                                            .update({
                                          "index": 1,
                                          "userdetails": userDetails,
                                          "chatid": personaldata!.docs[0]
                                                  .get("userid") +
                                              person.userid
                                        });
                                      }
                                    },
                                    child: Container(
                                      margin: EdgeInsets.all(2),
                                      padding: EdgeInsets.all(2),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          InkWell(
                                              child: Container(
                                            margin: EdgeInsets.all(10),
                                            height: 45,
                                            width: 45,
                                            decoration: new BoxDecoration(
                                              shape: BoxShape.circle,
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(25.0),
                                              child: CachedNetworkImage(
                                                imageUrl: person.userprofilepic,
                                                fit: BoxFit.cover,
                                                placeholder: (context, url) =>
                                                    Container(
                                                        height: 30,
                                                        width: 30,
                                                        child: Image.network(
                                                          "https://firebasestorage.googleapis.com/v0/b/hys-pro-41c66.appspot.com/o/assets%2Floadingimg.gif?alt=media&token=4ca910f2-c584-4b3a-bbcb-2f1c01d93f67",
                                                        )),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        Icon(Icons.error),
                                              ),
                                            ),
                                          )),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Text(
                                            person.username,
                                            style: TextStyle(
                                              fontFamily: 'Nunito Sans',
                                              fontSize: 18,
                                              color:
                                                  Color.fromRGBO(0, 0, 0, 0.8),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )),
                        );
                      },
                      child: Container(
                        height: 40,
                        width: MediaQuery.of(context).size.width - 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Color(0xD8F0F0F0),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "   To:  ",
                              style: TextStyle(
                                fontFamily: 'Nunito Sans',
                                fontSize: 15,
                                color: Color.fromRGBO(0, 0, 0, 0.5),
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            Container(
                              height: 40,
                              padding: EdgeInsets.only(bottom: 8),
                              width: MediaQuery.of(context).size.width - 57,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height - 180,
                      child: ListView.builder(
                        itemCount: allUserpersonaldata!.docs.length,
                        physics: BouncingScrollPhysics(),
                        itemBuilder: (BuildContext context, int i) {
                          return i == 0
                              ? indexIsZero()
                              : InkWell(
                                  onTap: () {
                                    List userDetails = [
                                      personaldata!.docs[0].get("firstname") +
                                          " " +
                                          personaldata!.docs[0].get("lastname"),
                                      personaldata!.docs[0].get("userid"),
                                      personaldata!.docs[0].get("profilepic"),
                                      allUserpersonaldata!.docs[i]
                                              .get("firstname") +
                                          " " +
                                          allUserpersonaldata!.docs[i]
                                              .get("lastname"),
                                      allUserpersonaldata!.docs[i]
                                          .get("userid"),
                                      allUserpersonaldata!.docs[i]
                                          .get("profilepic"),
                                    ];
                                    bool check = false;
                                    if (chatIds!.docs.length > 0) {
                                      for (int k = 0;
                                          k < chatIds!.docs.length;
                                          k++) {
                                        if (personaldata!.docs[0]
                                                    .get("userid") +
                                                allUserpersonaldata!.docs[i]
                                                    .get("userid") ==
                                            chatIds!.docs[k].id) {
                                          check = true;
                                          _pc.close();
                                          databaseReference
                                              .child("hysweb")
                                              .child("chat")
                                              .child(FirebaseAuth
                                                  .instance.currentUser!.uid)
                                              .update({
                                            "index": 1,
                                            "userdetails": userDetails,
                                            "chatid": personaldata!.docs[0]
                                                    .get("userid") +
                                                allUserpersonaldata!.docs[i]
                                                    .get("userid")
                                          });
                                        } else if (allUserpersonaldata!.docs[i]
                                                    .get("userid") +
                                                personaldata!.docs[0]
                                                    .get("userid") ==
                                            chatIds!.docs[k].id) {
                                          check = true;
                                          _pc.close();
                                          databaseReference
                                              .child("hysweb")
                                              .child("chat")
                                              .child(FirebaseAuth
                                                  .instance.currentUser!.uid)
                                              .update({
                                            "index": 1,
                                            "userdetails": userDetails,
                                            "chatid": allUserpersonaldata!
                                                    .docs[i]
                                                    .get("userid") +
                                                personaldata!.docs[0]
                                                    .get("userid")
                                          });
                                        }
                                      }
                                    }
                                    if (check != true) {
                                      socialFeed.createChatID(
                                          personaldata!.docs[0]
                                                  .get("firstname") +
                                              " " +
                                              personaldata!.docs[0]
                                                  .get("lastname"),
                                          personaldata!.docs[0].get("userid"),
                                          personaldata!.docs[0]
                                              .get("profilepic"),
                                          allUserpersonaldata!.docs[i]
                                                  .get("firstname") +
                                              " " +
                                              allUserpersonaldata!.docs[i]
                                                  .get("lastname"),
                                          allUserpersonaldata!.docs[i]
                                              .get("userid"),
                                          allUserpersonaldata!.docs[i]
                                              .get("profilepic"),
                                          personaldata!.docs[0].get("userid") +
                                              allUserpersonaldata!.docs[i]
                                                  .get("userid"),
                                          current_date);
                                      _pc.close();
                                      databaseReference
                                          .child("hysweb")
                                          .child("chat")
                                          .child(FirebaseAuth
                                              .instance.currentUser!.uid)
                                          .update({
                                        "index": 1,
                                        "userdetails": userDetails,
                                        "chatid": personaldata!.docs[0]
                                                .get("userid") +
                                            allUserpersonaldata!.docs[i]
                                                .get("userid")
                                      });
                                    }
                                  },
                                  child: Container(
                                    margin: EdgeInsets.all(2),
                                    padding: EdgeInsets.all(2),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        InkWell(
                                            child: Container(
                                          margin: EdgeInsets.all(10),
                                          height: 45,
                                          width: 45,
                                          decoration: new BoxDecoration(
                                            shape: BoxShape.circle,
                                          ),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(25.0),
                                            child: CachedNetworkImage(
                                              imageUrl: allUserpersonaldata!
                                                  .docs[i]
                                                  .get("profilepic"),
                                              fit: BoxFit.cover,
                                              placeholder: (context, url) =>
                                                  Container(
                                                      height: 30,
                                                      width: 30,
                                                      child: Image.network(
                                                        "https://firebasestorage.googleapis.com/v0/b/hys-pro-41c66.appspot.com/o/assets%2Floadingimg.gif?alt=media&token=4ca910f2-c584-4b3a-bbcb-2f1c01d93f67",
                                                      )),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      Icon(Icons.error),
                                            ),
                                          ),
                                        )),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                          allUserpersonaldata!.docs[i]
                                                  .get("firstname") +
                                              " " +
                                              allUserpersonaldata!.docs[i]
                                                  .get("lastname"),
                                          style: TextStyle(
                                            fontFamily: 'Nunito Sans',
                                            fontSize: 18,
                                            color: Color.fromRGBO(0, 0, 0, 0.8),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                        },
                      ),
                    )
                  ],
                ),
              ),
            );
    } else
      return SizedBox();
  }

  indexIsZero() {
    return Container(
      width: 500,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () {
                  setState(() {
                    changepanel = true;
                  });
                },
                child: Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      InkWell(
                          child: Container(
                              margin: EdgeInsets.all(10),
                              height: 40,
                              width: 40,
                              decoration: new BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xEFF0F0F0),
                              ),
                              child: Icon(Icons.group))),
                      SizedBox(
                        width: 5,
                      ),
                      Text(
                        "Create a new group",
                        style: TextStyle(
                          fontFamily: 'Nunito Sans',
                          fontSize: 18,
                          color: Color.fromRGBO(0, 0, 0, 0.8),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.all(5),
                child: Icon(
                  Icons.arrow_forward_ios_outlined,
                  size: 17,
                  color: Color(0xEFBEBEBE),
                ),
              )
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                "SUGGESTED",
                style: TextStyle(
                  fontFamily: 'Nunito Sans',
                  fontSize: 14,
                  color: Color(0xEFACACAC),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          InkWell(
            onTap: () {
              List userDetails = [
                personaldata!.docs[0].get("firstname") +
                    " " +
                    personaldata!.docs[0].get("lastname"),
                personaldata!.docs[0].get("userid"),
                personaldata!.docs[0].get("profilepic"),
                allUserpersonaldata!.docs[0].get("firstname") +
                    " " +
                    allUserpersonaldata!.docs[0].get("lastname"),
                allUserpersonaldata!.docs[0].get("userid"),
                allUserpersonaldata!.docs[0].get("profilepic"),
              ];
              bool check = false;
              if (chatIds!.docs.length > 0) {
                for (int k = 0; k < chatIds!.docs.length; k++) {
                  if (personaldata!.docs[0].get("userid") +
                          allUserpersonaldata!.docs[0].get("userid") ==
                      chatIds!.docs[k].id) {
                    check = true;
                    _pc.close();
                    databaseReference
                        .child("hysweb")
                        .child("chat")
                        .child(FirebaseAuth.instance.currentUser!.uid)
                        .update({
                      "index": 1,
                      "userdetails": userDetails,
                      "chatid": personaldata!.docs[0].get("userid") +
                          allUserpersonaldata!.docs[0].get("userid")
                    });
                  } else if (allUserpersonaldata!.docs[0].get("userid") +
                          personaldata!.docs[0].get("userid") ==
                      chatIds!.docs[k].id) {
                    check = true;
                    _pc.close();
                    databaseReference
                        .child("hysweb")
                        .child("chat")
                        .child(FirebaseAuth.instance.currentUser!.uid)
                        .update({
                      "index": 1,
                      "userdetails": userDetails,
                      "chatid": allUserpersonaldata!.docs[0].get("userid") +
                          personaldata!.docs[0].get("userid")
                    });
                  }
                }
              }
              if (check != true) {
                socialFeed.createChatID(
                    personaldata!.docs[0].get("firstname") +
                        " " +
                        personaldata!.docs[0].get("lastname"),
                    personaldata!.docs[0].get("userid"),
                    personaldata!.docs[0].get("profilepic"),
                    allUserpersonaldata!.docs[0].get("firstname") +
                        " " +
                        allUserpersonaldata!.docs[0].get("lastname"),
                    allUserpersonaldata!.docs[0].get("userid"),
                    allUserpersonaldata!.docs[0].get("profilepic"),
                    personaldata!.docs[0].get("userid") +
                        allUserpersonaldata!.docs[0].get("userid"),
                    current_date);
                _pc.close();
                databaseReference
                    .child("hysweb")
                    .child("chat")
                    .child(FirebaseAuth.instance.currentUser!.uid)
                    .update({
                  "index": 1,
                  "userdetails": userDetails,
                  "chatid": personaldata!.docs[0].get("userid") +
                      allUserpersonaldata!.docs[0].get("userid")
                });
              }
            },
            child: Container(
              margin: EdgeInsets.all(2),
              padding: EdgeInsets.all(2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  InkWell(
                      child: Container(
                    margin: EdgeInsets.all(10),
                    height: 45,
                    width: 45,
                    decoration: new BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(25.0),
                      child: CachedNetworkImage(
                        imageUrl:
                            allUserpersonaldata!.docs[0].get("profilepic"),
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                            height: 30,
                            width: 30,
                            child: Image.network(
                              "https://firebasestorage.googleapis.com/v0/b/hys-pro-41c66.appspot.com/o/assets%2Floadingimg.gif?alt=media&token=4ca910f2-c584-4b3a-bbcb-2f1c01d93f67",
                            )),
                        errorWidget: (context, url, error) => Icon(Icons.error),
                      ),
                    ),
                  )),
                  SizedBox(
                    width: 5,
                  ),
                  Text(
                    allUserpersonaldata!.docs[0].get("firstname") +
                        " " +
                        allUserpersonaldata!.docs[0].get("lastname"),
                    style: TextStyle(
                      fontFamily: 'Nunito Sans',
                      fontSize: 18,
                      color: Color.fromRGBO(0, 0, 0, 0.8),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
