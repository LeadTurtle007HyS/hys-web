// ignore_for_file: unnecessary_this

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:HyS/constants/style.dart';
import 'package:HyS/database/crud.dart';
import 'package:HyS/database/feedpostdb.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_custom_dialog/flutter_custom_dialog.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:dash_chat/dash_chat.dart';
import 'package:search_page/search_page.dart';

class GroupChatScreen extends StatefulWidget {
  List userDetails;
  String collectionID;
  GroupChatScreen(this.userDetails, this.collectionID);
  @override
  _GroupChatScreenState createState() =>
      _GroupChatScreenState(this.userDetails, this.collectionID);
}

class Person {
  final String userid;
  final String username;
  final String userprofilepic;
  final int userindex;

  Person(this.userid, this.username, this.userprofilepic, this.userindex);
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  List userDetails;
  String collectionID;
  _GroupChatScreenState(this.userDetails, this.collectionID);
  final GlobalKey<DashChatState> _chatViewKey = GlobalKey<DashChatState>();
  ChatUser? user;
  SocialFeedPost socialFeed = SocialFeedPost();
  ChatUser? otherUser;
  QuerySnapshot? allMessages;
  List<Person> allusers = [];
  List<bool> _selectedindex = [];
  DocumentSnapshot? chatDetails;
  String current_date = DateTime.now().toString();
  String _currentUserId = FirebaseAuth.instance.currentUser!.uid;
  DataSnapshot? currentstatus;
  DataSnapshot? unreadmessagecountdata;
  QuerySnapshot? chatIds;
  QuerySnapshot? personaldata;
  QuerySnapshot? schooldata;
  QuerySnapshot? allUserpersonaldata;
  final databaseReference = FirebaseDatabase.instance.reference();
  List<ChatMessage> messages = <ChatMessage>[];
  String comparedate = DateFormat('yyyyMMddkkmm').format(DateTime.now());
  CrudMethods crudobj = CrudMethods();
  String adminID = '';

  var m = <ChatMessage>[];
  var i = 0;
  String lastSeen = "tap here to see group info";

  String getTimeDifferenceFromNow(String dateTime) {
    DateTime todayDate = DateTime.parse(dateTime);
    Duration difference = DateTime.now().difference(todayDate);
    if (difference.inSeconds < 5) {
      return "Last seen just now";
    } else if (difference.inMinutes < 1) {
      return "Last seen just now";
    } else if (difference.inHours < 1) {
      return "Last seen ${difference.inMinutes} minutes ago";
    } else if (difference.inHours < 24) {
      return "Last seen ${difference.inHours} hours ago";
    } else {
      return "Last seen ${difference.inDays} days ago";
    }
  }

  File? _image;
  dynamic? imgUrl;
  final picker = ImagePicker();
  // ignore: non_constant_identifier_names
  var curr_uid = FirebaseAuth.instance.currentUser!.uid;
  var uid;
  bool isUsernotPartOfThisGroup = false;

  Future updateProfilePic(ImageSource source) async {
    final pickedfile = await picker.getImage(source: source);
    if (pickedfile != null) {
      setState(() {
        _image = File(pickedfile.path);
        print(_image);
      });
    }

    if (_image != null) {
      File? croppedFile = await ImageCropper().cropImage(
          sourcePath: _image!.path,
          compressQuality: 40,
          aspectRatioPresets: Platform.isAndroid
              ? [CropAspectRatioPreset.square]
              : [CropAspectRatioPreset.square],
          androidUiSettings: AndroidUiSettings(
              toolbarTitle: 'Crop',
              toolbarColor: Colors.white,
              hideBottomControls: true,
              toolbarWidgetColor: Colors.black,
              initAspectRatio: CropAspectRatioPreset.ratio3x2,
              lockAspectRatio: false),
          iosUiSettings: IOSUiSettings(
            title: 'Crop',
          ));
      if (croppedFile != null) {
        socialFeed
            .uploadSocialMediaGroupChatProfileImages(croppedFile)
            .then((value) {
          setState(() {
            print(value);
            if (value[0] == true) {
              imgUrl = value[1];
              _image = croppedFile;
              print(imgUrl);
              if (imgUrl != null) {
                socialFeed.updateGroupChatMessage(
                    this.collectionID, {"groupprofile": imgUrl});

                Navigator.pop(context);
              }
            }
          });
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();

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
    user = ChatUser(
      name: this.userDetails[0],
      uid: this.userDetails[1],
      avatar: this.userDetails[2],
    );
    crudobj.getUserData().then((value) {
      setState(() {
        personaldata = value;
      });
    });
    socialFeed.getGroupChatMessages(this.collectionID).then((value) {
      setState(() {
        allMessages = value;
      });
    });
    socialFeed.getGroupAllChatSectionDetails(this.collectionID).then((value) {
      setState(() {
        chatDetails = value;
        if (chatDetails != null) {
          List groupMemberID = chatDetails!.get("groupmemberid");
          adminID = chatDetails!.get("userid");
          int index = -1;
          for (int g = 0; g < groupMemberID.length; g++) {
            if (_currentUserId == groupMemberID[g]) {
              setState(() {
                index = g;
              });
              break;
            }
          }
          if (index != -1) {
            isUsernotPartOfThisGroup = false;
          }
        }
      });
    });
  }

  @override
  void dispose() {
    databaseReference
        .child("unreadmessagecount")
        .child(this.collectionID)
        .update({_currentUserId + 'isuseronchatscreen': false});
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
        .collection('groups')
        .doc(this.collectionID)
        .collection("SocialMediaChat")
        .doc(DateTime.now().millisecondsSinceEpoch.toString())
        .set(message.toJson());
    socialFeed.updateGroupChatMessage(this.collectionID,
        {"lastmessage": message.text, "lastmessagetime": current_date});

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
    if (chatDetails != null) {
      lastSeen = "";
      List test = chatDetails!.get("groupmembername");
      for (int j = 0; j < test.length; j++) {
        lastSeen = lastSeen + " " + test[j];
      }
    }
    return _body();
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
        (personaldata != null) &&
        (chatIds != null) &&
        (allMessages != null) &&
        (chatDetails != null) &&
        (allUserpersonaldata != null)) {
      return Column(children: [
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
                            .update(
                                {"index": 0, "userdetails": [], "chatid": ""});
                      },
                      icon: Icon(Icons.arrow_back_ios,
                          color: Colors.black87, size: 25),
                    ),
                    SizedBox(width: 20),
                    InkWell(
                        onTap: () {
                          if (isUsernotPartOfThisGroup == false) {
                            showAllUsers();
                          }
                        },
                        child: Stack(
                          children: [
                            Container(
                              height: 35,
                              width: 35,
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
                                  imageUrl: chatDetails != null
                                      ? chatDetails!.get("groupprofile")
                                      : "https://firebasestorage.googleapis.com/v0/b/hys-pro-41c66.appspot.com/o/groupchatdefault.jpg?alt=media&token=9e53ec4a-dc49-4996-b8f5-b601d0ac5746",
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(
                                      height: 30,
                                      width: 30,
                                      child: Image.network(
                                        "https://firebasestorage.googleapis.com/v0/b/hys-pro-41c66.appspot.com/o/assets%2Floadingimg.gif?alt=media&token=4ca910f2-c584-4b3a-bbcb-2f1c01d93f67",
                                      )),
                                  errorWidget: (context, url, error) =>
                                      Icon(Icons.error),
                                ),
                              ),
                            ),
                          ],
                        )),
                    InkWell(
                      onTap: () {
                        showAllUsers();
                      },
                      child: Container(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              collectionID.toString().length > 25
                                  ? collectionID.toString().substring(0, 25) +
                                      "..."
                                  : collectionID.toString(),
                              style: TextStyle(
                                  color: Color(0xE7272727),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600),
                            ),
                            SizedBox(
                              height: 3,
                            ),
                            Text(
                              lastSeen.length > 35
                                  ? lastSeen.toString().substring(0, 35) + "..."
                                  : lastSeen,
                              style: TextStyle(
                                  color: Colors.black45,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.more_vert_outlined,
                  color: Colors.black45,
                ),
                onPressed: () {},
              ),
            ],
          ),
        ),
        Container(
            width: 500,
            height: MediaQuery.of(context).size.height - 180,
            child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('groups')
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
                      avatarBuilder: ((ChatUser cuser) {
                        return SizedBox();
                      }),
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
                      readOnly: isUsernotPartOfThisGroup,
                      dateFormat: DateFormat.yMMMMd('en_US'),
                      timeFormat: DateFormat('HH:mm'),
                      messages: messages,
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
                                        top: 10,
                                        bottom: 10,
                                        left: 10,
                                        right: 10),
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
                                          Text(
                                            msg.user.name!,
                                            textAlign: TextAlign.start,
                                            style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w400,
                                                color: Colors.white70),
                                          ),
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
                                        top: 10,
                                        bottom: 10,
                                        left: 10,
                                        right: 10),
                                    child: Container(
                                      padding: EdgeInsets.only(
                                          top: 8, bottom: 8, left: 5, right: 5),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          color:
                                              Color.fromRGBO(8, 127, 254, 1)),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            msg.user.name!,
                                            textAlign: TextAlign.start,
                                            style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w400,
                                                color: Colors.white70),
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          InkWell(
                                            onTap: () {},
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
                                          Text(
                                            msg.user.name!,
                                            textAlign: TextAlign.start,
                                            style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w400,
                                                color: Colors.black54),
                                          ),
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
                                        top: 10,
                                        bottom: 10,
                                        left: 10,
                                        right: 10),
                                    child: Container(
                                      padding: EdgeInsets.only(
                                          top: 8, bottom: 8, left: 5, right: 5),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          color: Color(0xFFEEEEEE)),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            msg.user.name!,
                                            textAlign: TextAlign.start,
                                            style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w400,
                                                color: Colors.white70),
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          InkWell(
                                            onTap: () {},
                                            child: Container(
                                              child: CachedNetworkImage(
                                                imageUrl: msg.image!,
                                                fit: BoxFit.cover,
                                                placeholder: (context, url) =>
                                                    Container(
                                                        height: 100,
                                                        width: 100,
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
                      showUserAvatar: false,
                      showAvatarForEveryMessage: false,
                      scrollToBottom: false,
                      onLongPressMessage: (ChatMessage message) {
                        socialFeed
                            .getGroupChatMessages(this.collectionID)
                            .then((value) {
                          setState(() {
                            allMessages = value;
                          });
                        });
                        if (isUsernotPartOfThisGroup == false) {
                          String docid = '';
                          Map userDetails = {};
                          String uid = "";
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
                        }
                      },
                      messagePadding: EdgeInsets.fromLTRB(8, 8, 8, 8),
                      messageDecorationBuilder:
                          (ChatMessage msg, bool? isUser) {
                        return BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: isUser!
                              ? Color.fromRGBO(8, 127, 254, 1)
                              : Color(0xFFEEEEEE),
                          // gradient: isUser
                          //     ? LinearGradient(
                          //         colors: [
                          //           const Color(0xFF067C99),
                          //           const Color(0xFF0AACD4),
                          //         ],
                          //       )
                          //     : LinearGradient(
                          //         colors: [
                          //           const Color(0xFFE7E7E7),
                          //           const Color(0xFFEEEEEE),
                          //         ],
                          //       ),
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
                            // final picker = ImagePicker();
                            // PickedFile result = await picker.getImage(
                            //   source: ImageSource.gallery,
                            //   imageQuality: 80,
                            //   maxHeight: 600,
                            //   maxWidth: 600,
                            // );

                            // if (result != null) {
                            //   final Reference storageRef =
                            //       FirebaseStorage.instance.ref().child("chat_images");

                            //   final taskSnapshot = await storageRef.putFile(
                            //     File(result.path),
                            //   );

                            //   String url = await taskSnapshot.ref.getDownloadURL();

                            //   ChatMessage message =
                            //       ChatMessage(text: "", user: user, image: url);

                            //   FirebaseFirestore.instance
                            //       .collection('groups')
                            //       .doc(this.collectionID)
                            //       .collection("SocialMediaChat")
                            //       .add(message.toJson());
                            //   socialFeed.updateChatMessage(this.collectionID, {
                            //     "lastmessage": "[Image]",
                            //     "lastmessagetime": current_date
                            //   });
                            // }
                            _pickNotes(context);
                          },
                        )
                      ],
                    );
                  }
                }))
      ]);
    }
  }

  void showAllUsers() {
    List allusersname = chatDetails!.get("groupmembername");
    List allusersid = chatDetails!.get("groupmemberid");
    List allusersprofilepic = chatDetails!.get("groupmemberprofilepic");
    showDialog(
        context: context,
        barrierColor: Colors.grey.withOpacity(0.2),
        barrierDismissible: false,
        builder: (_) => StatefulBuilder(builder: (context, setState) {
              return AlertDialog(
                contentPadding: EdgeInsets.all(20),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0)),
                content: Container(
                  height: 470,
                  width: 500,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).pop();
                              },
                              child: Container(
                                child: Text(
                                  "    Cancel",
                                  style: TextStyle(
                                    fontFamily: 'Nunito Sans',
                                    fontSize: 16,
                                    color: Color.fromRGBO(0, 0, 0, 0.7),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).pop();
                                editProfilePic(context);
                              },
                              child: Container(
                                child: Text(
                                  "Change Group Profile    ",
                                  style: TextStyle(
                                    fontFamily: 'Nunito Sans',
                                    fontSize: 16,
                                    color: Color.fromRGBO(0, 0, 0, 0.7),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          height: 20,
                          color: Colors.grey[200],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          // height: (allusersname.length * 80).toDouble(),
                          child: ListView.builder(
                            shrinkWrap: true,
                            physics: BouncingScrollPhysics(),
                            itemCount: allusersname.length,
                            itemBuilder: (context, index) {
                              return InkWell(
                                onTap: () {
                                  _showAlertDialog(
                                      allusersname[index],
                                      allusersid[index],
                                      allusersprofilepic[index]);
                                },
                                child: Container(
                                  margin: EdgeInsets.all(2),
                                  padding: EdgeInsets.all(2),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                          child: Row(
                                              mainAxisSize: MainAxisSize.min,
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
                                                      allusersprofilepic[index],
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
                                              allusersname[index],
                                              style: TextStyle(
                                                fontFamily: 'Nunito Sans',
                                                fontSize: 18,
                                                color: Color.fromRGBO(
                                                    0, 0, 0, 0.8),
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            SizedBox(width: 20),
                                            adminID == allusersid[index]
                                                ? Text(
                                                    "admin",
                                                    style: TextStyle(
                                                      fontFamily: 'Nunito Sans',
                                                      fontSize: 12,
                                                      color: Color.fromRGBO(
                                                          0, 0, 0, 0.6),
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  )
                                                : SizedBox(),
                                          ])),
                                      ((adminID != allusersid[index]) &&
                                              (_currentUserId == adminID))
                                          ? IconButton(
                                              icon: Icon(
                                                Icons
                                                    .remove_circle_outline_outlined,
                                                color: Colors.redAccent,
                                                size: 15,
                                              ),
                                              onPressed: () async {
                                                _removeFromGroupAlertDialog(
                                                    allusersname[index],
                                                    allusersid[index]);
                                              },
                                            )
                                          : SizedBox(),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          height: 20,
                          color: Colors.grey[200],
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        GestureDetector(
                          onTap: () {
                            _exitGroupAlertDialog();
                          },
                          child: Container(
                            child: Text(
                              "    Exit Group",
                              style: TextStyle(
                                fontFamily: 'Nunito Sans',
                                fontSize: 18,
                                color: Color.fromRGBO(0, 0, 0, 0.7),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        GestureDetector(
                          onTap: () {
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
                                          List groupMemberID =
                                              chatDetails!.get("groupmemberid");
                                          List groupMembername = chatDetails!
                                              .get("groupmembername");
                                          List groupMemberprofilepic =
                                              chatDetails!
                                                  .get("groupmemberprofilepic");
                                          int index = -1;
                                          for (int g = 0;
                                              g < groupMemberID.length;
                                              g++) {
                                            if (person.userid ==
                                                groupMemberID[g]) {
                                              setState(() {
                                                index = g;
                                              });
                                              break;
                                            }
                                          }
                                          if (index != -1) {
                                            // Fluttertoast.showToast(
                                            //     msg: "User already exist in group",
                                            //     toastLength: Toast.LENGTH_SHORT,
                                            //     gravity: ToastGravity.BOTTOM,
                                            //     timeInSecForIosWeb: 5,
                                            //     backgroundColor:
                                            //         Color.fromRGBO(37, 36, 36, 1.0),
                                            //     textColor: Colors.white,
                                            //     fontSize: 12.0);
                                          } else {
                                            groupMemberID.add(person.userid);
                                            groupMembername
                                                .add(person.username);
                                            groupMemberprofilepic
                                                .add(person.userprofilepic);

                                            socialFeed
                                                .updateGroupChatSectionDetails(
                                                    this.collectionID, {
                                              "groupmemberid": groupMemberID,
                                              "groupmembername":
                                                  groupMembername,
                                              "groupmemberprofilepic":
                                                  groupMemberprofilepic
                                            });
                                            socialFeed
                                                .getGroupAllChatSectionDetails(
                                                    this.collectionID)
                                                .then((value) {
                                              setState(() {
                                                chatDetails = value;
                                                if (chatDetails != null) {
                                                  List groupMemberID =
                                                      chatDetails!
                                                          .get("groupmemberid");
                                                  int index = -1;
                                                  for (int g = 0;
                                                      g < groupMemberID.length;
                                                      g++) {
                                                    if (_currentUserId ==
                                                        groupMemberID[g]) {
                                                      setState(() {
                                                        index = g;
                                                      });
                                                      break;
                                                    }
                                                  }
                                                  if (index != -1) {
                                                    isUsernotPartOfThisGroup =
                                                        false;
                                                  }
                                                }
                                              });
                                            });
                                            // Fluttertoast.showToast(
                                            //     msg: "User added successfully",
                                            //     toastLength: Toast.LENGTH_SHORT,
                                            //     gravity: ToastGravity.BOTTOM,
                                            //     timeInSecForIosWeb: 5,
                                            //     backgroundColor:
                                            //         Color.fromRGBO(37, 36, 36, 1.0),
                                            //     textColor: Colors.white,
                                            //     fontSize: 12.0);
                                            Navigator.of(context).pop();
                                            Navigator.of(context).pop();
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
                                                      BorderRadius.circular(
                                                          25.0),
                                                  child: CachedNetworkImage(
                                                    imageUrl:
                                                        person.userprofilepic,
                                                    fit: BoxFit.cover,
                                                    placeholder: (context,
                                                            url) =>
                                                        Container(
                                                            height: 30,
                                                            width: 30,
                                                            child:
                                                                Image.network(
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
                                          List groupMemberID =
                                              chatDetails!.get("groupmemberid");
                                          List groupMembername = chatDetails!
                                              .get("groupmembername");
                                          List groupMemberprofilepic =
                                              chatDetails!
                                                  .get("groupmemberprofilepic");
                                          int index = -1;
                                          for (int g = 0;
                                              g < groupMemberID.length;
                                              g++) {
                                            if (person.userid ==
                                                groupMemberID[g]) {
                                              setState(() {
                                                index = g;
                                              });
                                              break;
                                            }
                                          }
                                          if (index != -1) {
                                            // Fluttertoast.showToast(
                                            //     msg: "User already exist in group",
                                            //     toastLength: Toast.LENGTH_SHORT,
                                            //     gravity: ToastGravity.BOTTOM,
                                            //     timeInSecForIosWeb: 5,
                                            //     backgroundColor:
                                            //         Color.fromRGBO(37, 36, 36, 1.0),
                                            //     textColor: Colors.white,
                                            //     fontSize: 12.0);
                                          } else {
                                            groupMemberID.add(person.userid);
                                            groupMembername
                                                .add(person.username);
                                            groupMemberprofilepic
                                                .add(person.userprofilepic);

                                            socialFeed
                                                .updateGroupChatSectionDetails(
                                                    this.collectionID, {
                                              "groupmemberid": groupMemberID,
                                              "groupmembername":
                                                  groupMembername,
                                              "groupmemberprofilepic":
                                                  groupMemberprofilepic
                                            });
                                            socialFeed
                                                .getGroupAllChatSectionDetails(
                                                    this.collectionID)
                                                .then((value) {
                                              setState(() {
                                                chatDetails = value;
                                                if (chatDetails != null) {
                                                  List groupMemberID =
                                                      chatDetails!
                                                          .get("groupmemberid");
                                                  int index = -1;
                                                  for (int g = 0;
                                                      g < groupMemberID.length;
                                                      g++) {
                                                    if (_currentUserId ==
                                                        groupMemberID[g]) {
                                                      setState(() {
                                                        index = g;
                                                      });
                                                      break;
                                                    }
                                                  }
                                                  if (index != -1) {
                                                    isUsernotPartOfThisGroup =
                                                        false;
                                                  }
                                                }
                                              });
                                            });
                                            // Fluttertoast.showToast(
                                            //     msg: "User added successfully",
                                            //     toastLength: Toast.LENGTH_SHORT,
                                            //     gravity: ToastGravity.BOTTOM,
                                            //     timeInSecForIosWeb: 5,
                                            //     backgroundColor:
                                            //         Color.fromRGBO(37, 36, 36, 1.0),
                                            //     textColor: Colors.white,
                                            //     fontSize: 12.0);
                                            Navigator.of(context).pop();
                                            Navigator.of(context).pop();
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
                                                      BorderRadius.circular(
                                                          25.0),
                                                  child: CachedNetworkImage(
                                                    imageUrl:
                                                        person.userprofilepic,
                                                    fit: BoxFit.cover,
                                                    placeholder: (context,
                                                            url) =>
                                                        Container(
                                                            height: 30,
                                                            width: 30,
                                                            child:
                                                                Image.network(
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
                          },
                          child: Container(
                            child: Text(
                              "    Add Participants",
                              style: TextStyle(
                                fontFamily: 'Nunito Sans',
                                fontSize: 18,
                                color: Color.fromRGBO(0, 0, 0, 0.7),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }));
  }

  _messageContainer(String docID, String message, String uid) {
    print("currentID: $_currentUserId     messageuID: $uid");
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
                      socialFeed.deleteGroupChatMessage(
                          this.collectionID, docID);
                      if (message == chatDetails!.get("lastmessage")) {
                        socialFeed.updateGroupChatSectionDetails(
                            this.collectionID, {"lastmessage": ""});
                      }
                      Navigator.of(context).pop();
                      // Fluttertoast.showToast(
                      //     msg: "Message deleted successfully",
                      //     toastLength: Toast.LENGTH_SHORT,
                      //     gravity: ToastGravity.BOTTOM,
                      //     timeInSecForIosWeb: 5,
                      //     backgroundColor: Color.fromRGBO(37, 36, 36, 1.0),
                      //     textColor: Colors.white,
                      //     fontSize: 12.0);
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
                Navigator.of(context).pop();
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

  YYDialog editProfilePic(BuildContext context) {
    return YYDialog().build(context)
      ..gravity = Gravity.bottom
      ..gravityAnimationEnable = true
      ..backgroundColor = Colors.transparent
      ..widget(Container(
        height: 180,
        margin: EdgeInsets.only(left: 2, right: 2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10), topRight: Radius.circular(10)),
          color: Colors.white,
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 20.0, bottom: 10, right: 10),
          child: ListView(
            physics: BouncingScrollPhysics(),
            children: [
              Text(
                "Group Profile Photo",
                style: TextStyle(
                    fontSize: 20,
                    color: Colors.black54,
                    fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      InkWell(
                        onTap: () {
                          socialFeed.updateGroupChatMessage(this.collectionID, {
                            "groupprofile":
                                "https://firebasestorage.googleapis.com/v0/b/hys-pro-41c66.appspot.com/o/groupchatdefault.jpg?alt=media&token=9e53ec4a-dc49-4996-b8f5-b601d0ac5746"
                          });

                          Navigator.pop(context);
                        },
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.red,
                          child: Center(
                            child: Icon(Icons.delete, color: Colors.white),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Remove",
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.black87,
                            fontWeight: FontWeight.w400),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                  SizedBox(
                    width: 30,
                  ),
                  Column(
                    children: [
                      InkWell(
                        onTap: () {
                          updateProfilePic(ImageSource.gallery);
                        },
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.deepPurple,
                          child: Center(
                            child: Icon(Icons.photo, color: Colors.white),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Gallery",
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.black87,
                            fontWeight: FontWeight.w400),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                  SizedBox(
                    width: 30,
                  ),
                  Column(
                    children: [
                      InkWell(
                        onTap: () {
                          updateProfilePic(ImageSource.gallery);
                        },
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.deepPurple,
                          child: Center(
                            child: Icon(Icons.camera, color: Colors.white),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Camera",
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.black87,
                            fontWeight: FontWeight.w400),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                ],
              )
            ],
          ),
        ),
      ))
      ..show();
  }

  void _showAlertDialog(String username, String userid, String userprofilepic) {
    AlertDialog alertDialog = AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Are you sure?',
            style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
                fontFamily: 'Montserrat'),
          ),
        ],
      ),
      content: Container(
        height: 100,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Want to message $username ?",
                  style: TextStyle(
                      color: Colors.black54,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Montserrat'),
                ),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              Container(
                height: 40,
                width: 60,
                child: RaisedButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0)),
                    color: Color(0xFFFFFFFF),
                    splashColor: Color(0xFFC496CF),
                    elevation: 2,
                    child: Center(
                        child: Text(
                      'No',
                      style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w700,
                          fontSize: 18),
                    )),
                    onPressed: () {
                      Navigator.of(context).pop();
                    }),
              ),
              Container(
                height: 40,
                width: 60,
                child: RaisedButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0)),
                    color: Color(0xFF07B1CF),
                    splashColor: Color(0xFF91DDF0),
                    elevation: 2,
                    child: Center(
                        child: Text(
                      'Yes',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 18),
                    )),
                    onPressed: () {
                      List userDetails = [
                        personaldata!.docs[0].get("firstname") +
                            " " +
                            personaldata!.docs[0].get("lastname"),
                        personaldata!.docs[0].get("userid"),
                        personaldata!.docs[0].get("profilepic"),
                        username,
                        userid,
                        userprofilepic,
                      ];
                      bool check = false;
                      if (chatIds!.docs.length > 0) {
                        for (int k = 0; k < chatIds!.docs.length; k++) {
                          if (personaldata!.docs[0].get("userid") + userid ==
                              chatIds!.docs[k].id) {
                            check = true;
                            Navigator.of(context).pop();
                            Navigator.of(context).pop();

                            databaseReference
                                .child("hysweb")
                                .child("chat")
                                .child(FirebaseAuth.instance.currentUser!.uid)
                                .update({
                              "index": 1,
                              "userdetails": userDetails,
                              "chatid":
                                  personaldata!.docs[0].get("userid") + userid
                            });
                          } else if (userid +
                                  personaldata!.docs[0].get("userid") ==
                              chatIds!.docs[k].id) {
                            check = true;
                            Navigator.of(context).pop();
                            Navigator.of(context).pop();

                            databaseReference
                                .child("hysweb")
                                .child("chat")
                                .child(FirebaseAuth.instance.currentUser!.uid)
                                .update({
                              "index": 1,
                              "userdetails": userDetails,
                              "chatid":
                                  userid + personaldata!.docs[0].get("userid")
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
                            username,
                            userid,
                            userprofilepic,
                            personaldata!.docs[0].get("userid") + userid,
                            current_date);
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();

                        databaseReference
                            .child("hysweb")
                            .child("chat")
                            .child(FirebaseAuth.instance.currentUser!.uid)
                            .update({
                          "index": 1,
                          "userdetails": userDetails,
                          "chatid": personaldata!.docs[0].get("userid") + userid
                        });
                      }
                    }),
              ),
            ]),
            SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => alertDialog);
  }

  void _exitGroupAlertDialog() {
    AlertDialog alertDialog = AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Are you sure?',
            style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
                fontFamily: 'Montserrat'),
          ),
        ],
      ),
      content: Container(
        height: 100,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "do you want to exit this group?",
                  style: TextStyle(
                      color: Colors.black54,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Montserrat'),
                ),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              Container(
                height: 40,
                width: 60,
                child: RaisedButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0)),
                    color: Color(0xFF07B1CF),
                    splashColor: Color(0xFF91DDF0),
                    elevation: 2,
                    child: Center(
                        child: Text(
                      'Yes',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 18),
                    )),
                    onPressed: () {
                      List groupMemberID = chatDetails!.get("groupmemberid");
                      List groupMembername =
                          chatDetails!.get("groupmembername");
                      List groupMemberprofilepic =
                          chatDetails!.get("groupmemberprofilepic");
                      int index = -1;
                      for (int g = 0; g < groupMemberID.length; g++) {
                        if (_currentUserId == groupMemberID[g]) {
                          setState(() {
                            index = g;
                          });
                          break;
                        }
                      }
                      groupMemberID.removeAt(index);
                      groupMembername.removeAt(index);
                      groupMemberprofilepic.removeAt(index);
                      socialFeed
                          .updateGroupChatSectionDetails(this.collectionID, {
                        "groupmemberid": groupMemberID,
                        "groupmembername": groupMembername,
                        "groupmemberprofilepic": groupMemberprofilepic
                      });

                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    }),
              ),
              Container(
                height: 40,
                width: 60,
                child: RaisedButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0)),
                    color: Color(0xFFFFFFFF),
                    splashColor: Color(0xFFC496CF),
                    elevation: 2,
                    child: Center(
                        child: Text(
                      'No',
                      style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w700,
                          fontSize: 18),
                    )),
                    onPressed: () {
                      Navigator.of(context).pop();
                    }),
              ),
            ]),
            SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => alertDialog);
  }

  void _removeFromGroupAlertDialog(String username, String usersid) {
    AlertDialog alertDialog = AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Are you sure',
            style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
                fontFamily: 'Montserrat'),
          ),
        ],
      ),
      content: Container(
        height: 120,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "do you want to remove\n$username?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.black54,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Montserrat'),
                ),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              Container(
                height: 40,
                width: 60,
                child: RaisedButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0)),
                    color: Color(0xFF07B1CF),
                    splashColor: Color(0xFF91DDF0),
                    elevation: 2,
                    child: Center(
                        child: Text(
                      'Yes',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 18),
                    )),
                    onPressed: () {
                      List groupMemberID = chatDetails!.get("groupmemberid");
                      List groupMembername =
                          chatDetails!.get("groupmembername");
                      List groupMemberprofilepic =
                          chatDetails!.get("groupmemberprofilepic");
                      int i = -1;
                      for (int g = 0; g < groupMemberID.length; g++) {
                        if (usersid == groupMemberID[g]) {
                          setState(() {
                            i = g;
                          });
                          break;
                        }
                      }
                      if (i != -1) {
                        groupMemberID.removeAt(i);
                        groupMembername.removeAt(i);
                        groupMemberprofilepic.removeAt(i);

                        socialFeed
                            .updateGroupChatSectionDetails(this.collectionID, {
                          "groupmemberid": groupMemberID,
                          "groupmembername": groupMembername,
                          "groupmemberprofilepic": groupMemberprofilepic
                        });
                        socialFeed
                            .getGroupAllChatSectionDetails(this.collectionID)
                            .then((value) {
                          setState(() {
                            chatDetails = value;
                            if (chatDetails != null) {
                              List groupMemberID =
                                  chatDetails!.get("groupmemberid");
                              int i = -1;
                              for (int g = 0; g < groupMemberID.length; g++) {
                                if (_currentUserId == groupMemberID[g]) {
                                  setState(() {
                                    i = g;
                                  });
                                  break;
                                }
                              }
                              if (i != -1) {
                                isUsernotPartOfThisGroup = false;
                              }
                            }
                          });
                        });

                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                      }
                    }),
              ),
              Container(
                height: 40,
                width: 60,
                child: RaisedButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0)),
                    color: Color(0xFFFFFFFF),
                    splashColor: Color(0xFFC496CF),
                    elevation: 2,
                    child: Center(
                        child: Text(
                      'No',
                      style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w700,
                          fontSize: 18),
                    )),
                    onPressed: () {
                      Navigator.of(context).pop();
                    }),
              ),
            ]),
            SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => alertDialog);
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
                  .collection('groups')
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
