import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:HyS/constants/style.dart';
import 'package:HyS/database/feedpostdb.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:dash_chat/dash_chat.dart';
import 'package:oktoast/oktoast.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:http/http.dart' as http;

class ChatScreen extends StatefulWidget {
  List? userDetails;
  String? collectionID;
  ChatScreen(this.userDetails, this.collectionID);
  @override
  _ChatScreenState createState() =>
      _ChatScreenState(this.userDetails, this.collectionID);
}

class _ChatScreenState extends State<ChatScreen> {
  List? userDetails;
  String? collectionID;
  _ChatScreenState(this.userDetails, this.collectionID);
  final GlobalKey<DashChatState> _chatViewKey = GlobalKey<DashChatState>();
  ChatUser? user;
  QuerySnapshot? allMessages;
  DocumentSnapshot? chatDetails;
  SocialFeedPost socialFeed = SocialFeedPost();
  ChatUser? otherUser;
  String current_date = DateTime.now().toString();
  String _currentUserId = FirebaseAuth.instance.currentUser!.uid;
  DataSnapshot? currentstatus;
  DataSnapshot? unreadmessagecountdata;
  final databaseReference = FirebaseDatabase.instance.reference();
  List<ChatMessage> messages = <ChatMessage>[];
  String comparedate = DateFormat('yyyyMMddkkmm').format(DateTime.now());

  var m = <ChatMessage>[];
  var i = 0;
  String lastSeen = "Offline";

  String getTimeDifferenceFromNow(String dateTime) {
    try {
      DateTime todayDate = DateTime.parse(dateTime);
      Duration difference = DateTime.now().difference(todayDate);
      if (difference.inSeconds < 5) {
        return "La s t seen just now";
      } else if (difference.inMinutes < 1) {
        return "Last seen just now";
      } else if (difference.inHours < 1) {
        return "Last seen ${difference.inMinutes} minutes ago";
      } else if (difference.inHours < 24) {
        return "Last seen ${difference.inHours} hours ago";
      } else {
        return "Last seen ${difference.inDays} days ago";
      }
    } catch (e) {
      print(e);
      return "";
    }
  }

  Future initializetimezone() async {
    tz.initializeTimeZones();
  }

  @override
  void initState() {
    super.initState();
    user = _currentUserId == this.userDetails![1]
        ? ChatUser(
            name: this.userDetails![0],
            uid: this.userDetails![1],
            avatar: this.userDetails![2],
          )
        : ChatUser(
            name: this.userDetails![3],
            uid: this.userDetails![4],
            avatar: this.userDetails![5],
          );
    socialFeed.getChatMessages(this.collectionID).then((value) {
      setState(() {
        allMessages = value;
      });
    });
    socialFeed.getAllChatSectionDetails(this.collectionID).then((value) {
      setState(() {
        chatDetails = value;
      });
    });
  }

  @override
  void dispose() {
    databaseReference
        .child("unreadmessagecount")
        .child(this.collectionID!)
        .update({_currentUserId + 'isuseronchatscreen': false});
    databaseReference
        .child("hysweb")
        .child("chat")
        .child(FirebaseAuth.instance.currentUser!.uid)
        .update({"index": 0, "userdetails": [], "chatid": ""});
    super.dispose();
  }

  void systemMessage() {
    Timer(Duration(milliseconds: 300), () {
      if (i < 6) {
        setState(() {
          messages = [...messages, m[i]];
        });
        i++;
      }
      Timer(Duration(milliseconds: 300), () {
        if (_chatViewKey.currentState != null) {
          _chatViewKey.currentState!.scrollController
            ..animateTo(
              _chatViewKey
                  .currentState!.scrollController.position.maxScrollExtent,
              curve: Curves.easeOut,
              duration: const Duration(milliseconds: 300),
            );
        }
      });
    });
  }

  void onSend(ChatMessage message) {
    print(message.toJson());
    FirebaseFirestore.instance
        .collection('messages')
        .doc(this.collectionID)
        .collection("SocialMediaChat")
        .doc(DateTime.now().millisecondsSinceEpoch.toString())
        .set(message.toJson());
    socialFeed.updateChatMessage(this.collectionID,
        {"lastmessage": message.text, "lastmessagetime": current_date});
    if ((currentstatus!.value[_currentUserId != this.userDetails![4]
            ? this.userDetails![4]
            : _currentUserId != this.userDetails![1]
                ? this.userDetails![1]
                : this.userDetails![1]]["currentstatus"] ==
        "online")) {
      databaseReference
          .child("userlocalnotificationstatus")
          .child(_currentUserId != this.userDetails![4]
              ? this.userDetails![4]
              : _currentUserId != this.userDetails![1]
                  ? this.userDetails![1]
                  : this.userDetails![1])
          .set({
        "currentstatus":
            currentstatus!.value[_currentUserId != this.userDetails![4]
                ? this.userDetails![4]
                : _currentUserId != this.userDetails![1]
                    ? this.userDetails![1]
                    : this.userDetails![1]]["currentstatus"],
        "message": message.text,
        "tittle": _currentUserId != this.userDetails![4]
            ? this.userDetails![0]
            : _currentUserId != this.userDetails![1]
                ? this.userDetails![3]
                : this.userDetails![3],
        "currenttime": current_date,
        "isnewmessage": true,
        "profilepic": _currentUserId != this.userDetails![4]
            ? this.userDetails![2]
            : _currentUserId != this.userDetails![1]
                ? this.userDetails![5]
                : this.userDetails![5],
      });
    }

    String checking = _currentUserId != this.userDetails![4]
        ? this.userDetails![4] + "isuseronchatscreen"
        : _currentUserId != this.userDetails![1]
            ? this.userDetails![1] + "isuseronchatscreen"
            : this.userDetails![1] + "isuseronchatscreen";

    if ((unreadmessagecountdata!.value[collectionID][checking] == false)) {
      print("true");
      databaseReference
          .child("unreadmessagecount")
          .child(this.collectionID!)
          .update({
        _currentUserId != this.userDetails![4]
                ? this.userDetails![4]
                : _currentUserId != this.userDetails![1]
                    ? this.userDetails![1]
                    : this.userDetails![1]:
            unreadmessagecountdata!.value[collectionID]
                    [_currentUserId != this.userDetails![4]
                        ? this.userDetails![4]
                        : _currentUserId != this.userDetails![1]
                            ? this.userDetails![1]
                            : this.userDetails![1]] +
                1
      });
    }
    /* setState(() {
      messages = [...messages, message];
      print(messages.length);
    });
    if (i == 0) {
      systemMessage();
      Timer(Duration(milliseconds: 600), () {
        systemMessage();
      });
    } else {
      systemMessage();
    } */
  }

  @override
  Widget build(BuildContext context) {
    if (currentstatus != null) {
      lastSeen = getTimeDifferenceFromNow(
          (currentstatus!.value[_currentUserId != this.userDetails![4]
              ? this.userDetails![4]
              : _currentUserId != this.userDetails![1]
                  ? this.userDetails![1]
                  : this.userDetails![1]]["lastseentime"]));
    }
    return SizedBox(width: 500, child: _body());
  }

  _chatContainer() {
    return Container(
      height: 150,
      child: Center(
        child: Column(
          children: [
            SizedBox(
              height: 20,
            ),
            GestureDetector(
              onTap: () async {
                socialFeed.deleteChatMessages(this.collectionID);
                socialFeed.deleteChatSection(this.collectionID);
              },
              child: Container(
                  padding: EdgeInsets.only(left: 20, top: 10, bottom: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(Icons.delete),
                      SizedBox(
                        width: 10,
                      ),
                      Text("Clear chat",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600)),
                    ],
                  )),
            ),
            GestureDetector(
              onTap: () async {
                if (chatDetails!.get("isblocked") == false) {
                  socialFeed.updateAllChatSectionDetails(
                      this.collectionID, {"isblocked": true});
                } else if (chatDetails!.get("isblocked") == true) {
                  socialFeed.updateAllChatSectionDetails(
                      this.collectionID, {"isblocked": false});
                }
                socialFeed
                    .getAllChatSectionDetails(this.collectionID)
                    .then((value) {
                  setState(() {
                    chatDetails = value;
                  });
                });
              },
              child: Container(
                  padding: EdgeInsets.only(left: 20, top: 10, bottom: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(Icons.report),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                          chatDetails!.get("isblocked") == false
                              ? "Block"
                              : "Unblock",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600)),
                    ],
                  )),
            ),
          ],
        ),
      ),
    );
  }

  _messageContainer(String docID, String message, String uid) {
    return Container(
      height: 150,
      child: Center(
        child: Column(
          children: [
            SizedBox(
              height: 20,
            ),
            _currentUserId == uid
                ? GestureDetector(
                    onTap: () async {
                      socialFeed.deleteChatMessage(this.collectionID, docID);
                      if (message == chatDetails!.get("lastmessage")) {
                        socialFeed.updateAllChatSectionDetails(
                            this.collectionID, {"lastmessage": ""});
                      }
                    },
                    child: Container(
                        padding: EdgeInsets.only(left: 20, top: 10, bottom: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(Icons.delete),
                            SizedBox(
                              width: 10,
                            ),
                            Text("Delete Message",
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.w600)),
                          ],
                        )),
                  )
                : SizedBox(),
            GestureDetector(
              onTap: () async {
                Clipboard.setData(ClipboardData(text: message));
              },
              child: Container(
                  padding: EdgeInsets.only(left: 20, top: 10, bottom: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(Icons.copy),
                      SizedBox(
                        width: 10,
                      ),
                      Text("Copy Message",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600)),
                    ],
                  )),
            ),
          ],
        ),
      ),
    );
  }

  _body() {
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

    if ((currentstatus != null) &&
        (unreadmessagecountdata != null) &&
        (allMessages != null) &&
        (chatDetails != null)) {
      databaseReference
          .child("unreadmessagecount")
          .child(this.collectionID!)
          .update(
              {_currentUserId + 'isuseronchatscreen': true, _currentUserId: 0});

      return Column(
        children: [
          SizedBox(height: 20),
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
                Container(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(width: 20),
                      IconButton(
                        onPressed: () {
                          databaseReference
                              .child("hysweb")
                              .child("chat")
                              .child(FirebaseAuth.instance.currentUser!.uid)
                              .update({
                            "index": 0,
                            "userdetails": [],
                            "chatid": ""
                          });
                        },
                        icon: Icon(Icons.arrow_back_ios,
                            color: Colors.black87, size: 25),
                      ),
                      SizedBox(width: 20),
                      InkWell(
                          child: Stack(
                        children: [
                          Container(
                            height: 45,
                            width: 45,
                            margin: EdgeInsets.only(right: 10),
                            decoration: new BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color:
                                      const Color.fromRGBO(242, 246, 248, 1)),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(25.0),
                              child: CachedNetworkImage(
                                imageUrl: _currentUserId != this.userDetails![4]
                                    ? this.userDetails![5]
                                    : _currentUserId != this.userDetails![1]
                                        ? this.userDetails![2]
                                        : this.userDetails![2],
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                    height: 45,
                                    width: 45,
                                    child: Image.network(
                                      "https://firebasestorage.googleapis.com/v0/b/hys-pro-41c66.appspot.com/o/assets%2Floadingimg.gif?alt=media&token=4ca910f2-c584-4b3a-bbcb-2f1c01d93f67",
                                    )),
                                errorWidget: (context, url, error) =>
                                    Icon(Icons.error),
                              ),
                            ),
                          ),
                          chatDetails != null
                              ? chatDetails!.get("isblocked") == false
                                  ? Positioned(
                                      top: 28,
                                      left: 32,
                                      child: Icon(
                                        Icons.circle,
                                        size: 12,
                                        color: ((currentstatus != null) &&
                                                (currentstatus!
                                                        .value[_currentUserId !=
                                                            this.userDetails![4]
                                                        ? this.userDetails![4]
                                                        : _currentUserId !=
                                                                this.userDetails![
                                                                    1]
                                                            ? this
                                                                .userDetails![1]
                                                            : this.userDetails![
                                                                1]]["currentstatus"] ==
                                                    "online"))
                                            ? Colors.green
                                            : Colors.orangeAccent,
                                      ),
                                    )
                                  : SizedBox()
                              : SizedBox()
                        ],
                      )),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _currentUserId != this.userDetails![4]
                                ? this.userDetails![3]
                                : _currentUserId != this.userDetails![1]
                                    ? this.userDetails![0]
                                    : this.userDetails![0],
                            style: TextStyle(
                                color: Color(0xE7272727),
                                fontSize: 17,
                                fontWeight: FontWeight.w800),
                          ),
                          SizedBox(
                            height: 3,
                          ),
                          chatDetails != null
                              ? chatDetails!.get("isblocked") == false
                                  ? ((currentstatus != null) &&
                                          (currentstatus!
                                                  .value[_currentUserId !=
                                                      this.userDetails![4]
                                                  ? this.userDetails![4]
                                                  : _currentUserId !=
                                                          this.userDetails![1]
                                                      ? this.userDetails![1]
                                                      : this.userDetails![
                                                          1]]["currentstatus"] ==
                                              "online"))
                                      ? Text(
                                          "Online",
                                          style: TextStyle(
                                              color: Colors.black45,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w400),
                                        )
                                      : Text(
                                          lastSeen,
                                          style: TextStyle(
                                              color: Colors.black45,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w400),
                                        )
                                  : Text(
                                      "Blocked",
                                      style: TextStyle(
                                          color: Colors.black45,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400),
                                    )
                              : SizedBox(),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.more_vert_outlined,
                    color: Colors.black45,
                  ),
                  onPressed: () {
                    showModalBottomSheet(
                        context: context,
                        builder: (context) => _chatContainer());
                  },
                ),
              ],
            ),
          ),
          Container(
              width: 500,
              height: MediaQuery.of(context).size.height - 180,
              child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('messages')
                      .doc(this.collectionID)
                      .collection("SocialMediaChat")
                      .orderBy("createdAt")
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xE70798BD),
                          ),
                        ),
                      );
                    } else {
                      List<DocumentSnapshot> items = snapshot.data!.docs;
                      var messages = items
                          .map((i) => ChatMessage.fromJson(
                              i.data() as Map<String, dynamic>))
                          .toList();
                      return DashChat(
                        width: 500,
                        key: _chatViewKey,
                        inverted: false,
                        inputToolbarMargin: EdgeInsets.all(10),
                        inputCursorColor: Color.fromRGBO(8, 127, 254, 1),
                        onSend: onSend,
                        sendOnEnter: true,
                        textInputAction: TextInputAction.send,
                        user: user!,
                        inputDecoration: InputDecoration.collapsed(
                          hintText: "Add message here...",
                          hintStyle: TextStyle(
                              color: Colors.black45,
                              fontSize: 15,
                              fontWeight: FontWeight.w500),
                        ),
                        dateFormat: DateFormat.yMMMMd('en_US'),
                        timeFormat: DateFormat('HH:mm'),
                        messages: messages,
                        showUserAvatar: false,
                        showAvatarForEveryMessage: false,
                        scrollToBottom: false,
                        onLongPressMessage: (ChatMessage message) {
                          print(message.id);
                          String docid = '';
                          String uid = '';
                          Map userDetails = {};
                          for (int k = 0; k < allMessages!.docs.length; k++) {
                            if (allMessages!.docs[k].get("id") == message.id) {
                              setState(() {
                                docid = allMessages!.docs[k].id;

                                userDetails = allMessages!.docs[k].get("user");
                                uid = userDetails['uid'];
                              });
                              break;
                            }
                          }
                          showModalBottomSheet(
                              context: context,
                              builder: (context) =>
                                  _messageContainer(docid, message.text!, uid));
                        },
                        onPressAvatar: (ChatUser user) {},
                        messageBuilder: ((ChatMessage msg) {
                          String hrs =
                              int.parse(msg.createdAt.hour.toString()) > 9
                                  ? msg.createdAt.hour.toString()
                                  : "0" + msg.createdAt.hour.toString();
                          String min =
                              int.parse(msg.createdAt.minute.toString()) > 9
                                  ? msg.createdAt.minute.toString()
                                  : "0" + msg.createdAt.minute.toString();
                          return _currentUserId == msg.user.uid
                              ? ((msg.image == null) || (msg.image == ""))
                                  ? Container(
                                      alignment: _currentUserId == msg.user.uid
                                          ? Alignment.centerRight
                                          : Alignment.centerLeft,
                                      margin: EdgeInsets.only(
                                          top: 10, bottom: 10, right: 10),
                                      child: Container(
                                        padding: EdgeInsets.only(
                                            top: 8,
                                            bottom: 8,
                                            left: 10,
                                            right: 10),
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            color:
                                                Color.fromRGBO(8, 127, 254, 1)),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                              height: 10,
                                            ),
                                            Text(
                                              msg.text!,
                                              textAlign: TextAlign.start,
                                              style: TextStyle(
                                                  fontSize: 17,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.white),
                                            ),
                                            SizedBox(
                                              height: 5,
                                            ),
                                            Text(
                                              hrs + ":" + min,
                                              textAlign: TextAlign.start,
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w400,
                                                  color: Colors.white70),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  : Container(
                                      alignment: _currentUserId == msg.user.uid
                                          ? Alignment.centerRight
                                          : Alignment.centerLeft,
                                      margin: EdgeInsets.only(
                                          top: 10, bottom: 10, right: 10),
                                      child: Container(
                                        padding: EdgeInsets.only(
                                            top: 8,
                                            bottom: 8,
                                            left: 5,
                                            right: 5),
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            color:
                                                Color.fromRGBO(8, 127, 254, 1)),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                              height: 10,
                                            ),
                                            InkWell(
                                              onTap: () {
                                                // Navigator.push(
                                                //     context,
                                                //     MaterialPageRoute(
                                                //         builder: (context) =>
                                                //             SingleImageView(msg.image,
                                                //                 "NetworkImage")));
                                              },
                                              child: Container(
                                                child: CachedNetworkImage(
                                                  imageUrl: msg.image!,
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
                                            SizedBox(
                                              height: 5,
                                            ),
                                            Text(
                                              hrs + ":" + min,
                                              textAlign: TextAlign.start,
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w400,
                                                  color: Colors.white70),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                              : ((msg.image == null) || (msg.image == ""))
                                  ? Container(
                                      margin:
                                          EdgeInsets.only(top: 10, bottom: 10),
                                      alignment: _currentUserId == msg.user.uid
                                          ? Alignment.centerRight
                                          : Alignment.centerLeft,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Container(
                                        padding: EdgeInsets.only(
                                            top: 8,
                                            bottom: 8,
                                            left: 10,
                                            right: 10),
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            color: Color(0xFFEEEEEE)),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                              height: 10,
                                            ),
                                            Text(
                                              msg.text!,
                                              textAlign: TextAlign.start,
                                              style: TextStyle(
                                                  fontSize: 17,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.black),
                                            ),
                                            SizedBox(
                                              height: 5,
                                            ),
                                            Text(
                                              hrs + ":" + min,
                                              textAlign: TextAlign.start,
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w400,
                                                  color: Colors.black54),
                                            ),
                                          ],
                                        ),
                                      ))
                                  : Container(
                                      alignment: _currentUserId == msg.user.uid
                                          ? Alignment.centerRight
                                          : Alignment.centerLeft,
                                      margin: EdgeInsets.only(
                                          top: 10, bottom: 10, right: 10),
                                      child: Container(
                                        padding: EdgeInsets.only(
                                            top: 8,
                                            bottom: 8,
                                            left: 5,
                                            right: 5),
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            color: Color(0xFFEEEEEE)),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                              height: 10,
                                            ),
                                            InkWell(
                                              onTap: () {
                                                // Navigator.push(
                                                //     context,
                                                //     MaterialPageRoute(
                                                //         builder: (context) =>
                                                //             SingleImageView(msg.image,
                                                //                 "NetworkImage")));
                                              },
                                              child: Container(
                                                child: CachedNetworkImage(
                                                  imageUrl: msg.image!,
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
                                            SizedBox(
                                              height: 5,
                                            ),
                                            Text(
                                              hrs + ":" + min,
                                              textAlign: TextAlign.start,
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w400,
                                                  color: Colors.white70),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                        }),
                        readOnly: chatDetails!.get("isblocked"),
                        messagePadding: EdgeInsets.fromLTRB(8, 8, 8, 8),
                        messageDecorationBuilder:
                            (ChatMessage msg, bool? isUser) {
                          return BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: isUser!
                                ? Color.fromRGBO(8, 127, 254, 1)
                                : Color(0xFFEEEEEE),
                          );
                        },
                        inputMaxLines: 5,
                        messageContainerPadding: EdgeInsets.all(5),
                        alwaysShowSend: true,
                        inputTextStyle: TextStyle(
                            fontSize: 20.0,
                            color: Color.fromRGBO(8, 127, 254, 1)),
                        inputContainerStyle: BoxDecoration(
                          border:
                              Border.all(width: 2.0, color: Colors.grey[100]!),
                          borderRadius: BorderRadius.circular(100),
                          color: Colors.grey[100],
                        ),
                        onQuickReply: (Reply reply) {
                          setState(() {
                            messages.add(ChatMessage(
                                text: reply.value,
                                createdAt: DateTime.now(),
                                user: user!));

                            messages = [...messages];
                          });

                          Timer(Duration(milliseconds: 300), () {
                            if (_chatViewKey.currentState != null) {
                              _chatViewKey.currentState!.scrollController
                                ..animateTo(
                                  _chatViewKey.currentState!.scrollController
                                      .position.maxScrollExtent,
                                  curve: Curves.easeOut,
                                  duration: const Duration(milliseconds: 300),
                                );

                              if (i == 0) {
                                systemMessage();
                                Timer(Duration(milliseconds: 600), () {
                                  systemMessage();
                                });
                              } else {
                                systemMessage();
                              }
                            }
                          });
                        },
                        onLoadEarlier: () {
                          print("laoding...");
                        },
                        shouldShowLoadEarlier: false,
                        showTraillingBeforeSend: true,
                        leading: <Widget>[
                          IconButton(
                            icon: Icon(
                              Icons.photo,
                              color: Color(0xFF3D3D3D),
                            ),
                            onPressed: () async {
                              _pickNotes(context);
                            },
                          )
                        ],
                      );
                    }
                  })),
        ],
      );
    }
  }

  final GlobalKey<State> _keyLoader = new GlobalKey<State>();
  double progress = 0;
  void _pickNotes(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      Dialogs.showLoadingDialog(context, _keyLoader);

      Uint8List? file = result.files.first.bytes;
      String fileName = result.files.first.name;
      UploadTask task = FirebaseStorage.instance
          .ref()
          .child("chat_images/$_currentUserId/$fileName")
          .putData(file!);

      task.snapshotEvents.listen((event) async {
        setState(() {
          progress = ((event.bytesTransferred.toDouble() /
                      event.totalBytes.toDouble()) *
                  100)
              .roundToDouble();
        });
        if (progress == 100) {
          print(progress);
          String downloadURL = await FirebaseStorage.instance
              .ref("chat_images/$_currentUserId/$fileName")
              .getDownloadURL();
          if (downloadURL != null) {
            setState(() {
              ChatMessage message =
                  ChatMessage(text: "", user: user!, image: downloadURL);

              FirebaseFirestore.instance
                  .collection('messages')
                  .doc(this.collectionID)
                  .collection("SocialMediaChat")
                  .add(message.toJson());
              socialFeed.updateChatMessage(this.collectionID,
                  {"lastmessage": "[Image]", "lastmessagetime": current_date});
              progress = 0.0;
            });
            Navigator.of(_keyLoader.currentContext!, rootNavigator: true)
                .pop(); //close the dialoge

          }
        }
      });
    }
  }
}

class Dialogs {
  static Future<void> showLoadingDialog(
      BuildContext context, GlobalKey key) async {
    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new WillPopScope(
              onWillPop: () async => false,
              child: SimpleDialog(
                  key: key,
                  backgroundColor: Colors.black54,
                  children: <Widget>[
                    Center(
                      child: Column(children: [
                        CircularProgressIndicator(),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          "Please Wait....",
                          style: TextStyle(color: Colors.blueAccent),
                        )
                      ]),
                    )
                  ]));
        });
  }
}
