import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_core/firebase_core.dart' as firebase_core;
import 'package:path/path.dart' as Path;
import 'package:intl/intl.dart';

final databaseReference = FirebaseDatabase.instance.reference();
String current_date = DateFormat.yMMMMd('en_US').format(DateTime.now());
String comparedate = DateFormat('yyyyMMddkkmm').format(DateTime.now());
String weekday = DateFormat('EEEE').format(DateTime.now());

class SocialFeedPost {
  Future<String> addFeedPost(
      feedtype,
      username,
      userprofilepic,
      gender,
      userarea,
      userschoolname,
      usergrade,
      usermood,
      message,
      tageduserid,
      tagedusername,
      videolist,
      thumbUrl,
      List imagelist,
      createdate,
      comparedate,
      updatedate) async {
    var firebaseUser = auth.FirebaseAuth.instance.currentUser!.uid;
    String id;
    CollectionReference reference =
        FirebaseFirestore.instance.collection('sm_feeds');

    await reference.add({
      "userid": firebaseUser,
      "username": username,
      "feedtype": feedtype,
      "userprofilepic": userprofilepic,
      "usergender": gender,
      "userarea": userarea,
      "userschoolname": userschoolname,
      "usergrade": usergrade,
      "usermood": usermood,
      "message": message,
      "tageduserid": tageduserid,
      "tagedusername": tagedusername,
      'videolist': videolist,
      "videothumbnail": thumbUrl,
      "imagelist": imagelist,
      "comparedate": comparedate,
      "createdate": createdate,
      "updatedate": "",
      "likescount": 0,
      "commentscount": 0,
      "viewscount": 0
    }).then((value) {
      id = value.id;
      databaseReference
          .child("sm_feeds")
          .child("reactions")
          .child(id)
          .set({"likecount": 0, "commentcount": 0, "viewscount": 0});
      for (int i = 0; i < imagelist.length; i++) {
        databaseReference
            .child("sm_feeds")
            .child("images")
            .child(id + i.toString())
            .set({"likecount": 0, "commentcount": 0, "viewscount": 0});
      }
    });
    return "";
  }

  Future<String> addSharedFeedPost(
      feedtype,
      username,
      userprofilepic,
      gender,
      userarea,
      userschoolname,
      usergrade,
      usermood,
      message,
      tageduserid,
      tagedusername,
      videolist,
      thumbUrl,
      List imagelist,
      shareuserid,
      shareusername,
      sharefeedid,
      sharefeedindex,
      shareuserprofilepic,
      sharegender,
      shareuserarea,
      shareuserschoolname,
      shareusergrade,
      shareusermood,
      sharemessage,
      sharetageduserid,
      sharetagedusername,
      sharevideolist,
      sharethumbUrl,
      List shareimagelist,
      createdate,
      comparedate,
      updatedate) async {
    var firebaseUser = auth.FirebaseAuth.instance.currentUser!.uid;
    String id;
    CollectionReference reference =
        FirebaseFirestore.instance.collection('sm_feeds');

    await reference.add({
      "shareuserid": shareuserid,
      "shareusername": shareusername,
      "sharefeedid": sharefeedid,
      "sharefeedindex": sharefeedindex,
      "shareuserprofilepic": shareuserprofilepic,
      "sharegender": sharegender,
      "shareuserarea": shareuserarea,
      "shareuserschoolname": shareuserschoolname,
      "shareusergrade": shareusergrade,
      "shareusermood": shareusermood,
      "sharemessage": sharemessage,
      "sharetageduserid": sharetageduserid,
      "sharetagedusername": sharetagedusername,
      "sharevideolist": sharevideolist,
      "sharethumbUrl": sharethumbUrl,
      "shareimagelist": shareimagelist,
      "userid": firebaseUser,
      "username": username,
      "feedtype": "shared",
      "userprofilepic": userprofilepic,
      "usergender": gender,
      "userarea": userarea,
      "userschoolname": userschoolname,
      "usergrade": usergrade,
      "usermood": usermood,
      "message": message,
      "tageduserid": tageduserid,
      "tagedusername": tagedusername,
      'videolist': videolist,
      "videothumbnail": thumbUrl,
      "imagelist": imagelist,
      "comparedate": comparedate,
      "createdate": createdate,
      "updatedate": "",
      "likescount": 0,
      "commentscount": 0,
      "viewscount": 0
    }).then((value) {
      id = value.id;
      databaseReference
          .child("sm_feeds")
          .child("reactions")
          .child(id)
          .set({"likecount": 0, "commentcount": 0, "viewscount": 0});
      for (int i = 0; i < imagelist.length; i++) {
        databaseReference
            .child("sm_feeds")
            .child("images")
            .child(id + i.toString())
            .set({"likecount": 0, "commentcount": 0, "viewscount": 0});
      }
    });
    return "";
  }

  Future updateReactionCount(selectedDoc, newValues) async {
    CollectionReference referance =
        FirebaseFirestore.instance.collection('sm_feeds');
    referance
        .doc(selectedDoc)
        .update(newValues)
        .then((value) => print("Success"))
        .catchError((error) => print("Error: $error"));
  }

  Future<String> addFeedPostasDraft(
      feedtype,
      username,
      userprofilepic,
      gender,
      userarea,
      userschoolname,
      usergrade,
      usermood,
      message,
      tageduserid,
      tagedusername,
      videolist,
      thumbUrl,
      imagelist,
      createdate,
      comparedate,
      updatedate) async {
    var firebaseUser = auth.FirebaseAuth.instance.currentUser!.uid;
    String id;
    CollectionReference reference =
        FirebaseFirestore.instance.collection('sm_feedsAsDraft');

    await reference.add({
      "userid": firebaseUser,
      "username": username,
      "feedtype": feedtype,
      "userprofilepic": userprofilepic,
      "usergender": gender,
      "userarea": userarea,
      "userschoolname": userschoolname,
      "usergrade": usergrade,
      "usermood": usermood,
      "message": message,
      "tageduserid": tageduserid,
      "tagedusername": tagedusername,
      'videolist': videolist,
      "videothumbnail": thumbUrl,
      "imagelist": imagelist,
      "comparedate": comparedate,
      "createdate": createdate
    });
    return "";
  }

  Future<String> addFeedPostReactions(
      feedid,
      reactiontype,
      feeduserid,
      feedusername,
      feeduserschoolname,
      feeduserprofilepic,
      feeduserarea,
      feedusergrade,
      reactusername,
      reactuserschoolname,
      reactuserprofilepic,
      reactuserarea,
      reactusergrade,
      createdate,
      comparedate) async {
    var firebaseUser = auth.FirebaseAuth.instance.currentUser!.uid;
    String id;
    CollectionReference reference =
        FirebaseFirestore.instance.collection('sm_reactions_details');

    await reference.add({
      "feedid": feedid,
      "reactiontype": reactiontype,
      "feeduserid": feeduserid,
      "feedusername": feedusername,
      "feeduserschoolname": feeduserschoolname,
      "feeduserprofilepic": feeduserprofilepic,
      "feeduserarea": feeduserarea,
      "feedusergrade": feedusergrade,
      "reactusername": reactusername,
      "reactuserschoolname": reactuserschoolname,
      "reactuserprofilepic": reactuserprofilepic,
      "reactuserarea": reactuserarea,
      "reactusergrade": reactusergrade,
      "reactuserid": firebaseUser,
      "comparedate": comparedate,
      "updatedate": "",
      "createdate": createdate
    });
    return "";
  }

  Future getSocialFeedPosts() async {
    var firebaseUser = auth.FirebaseAuth.instance.currentUser!.uid;
    return await FirebaseFirestore.instance
        .collection('sm_feeds')
        .orderBy("comparedate", descending: true)
        .get();
  }

  Future<void> saveFeedPost(savedusername, feeduserid, feedusername, feedid,
      createdate, comparedate) async {
    var firebaseUser = auth.FirebaseAuth.instance.currentUser!.uid;
    DocumentReference reference = FirebaseFirestore.instance
        .collection('sm_feeds_saved')
        .doc(firebaseUser + feedid);
    await reference.set({
      "savesuserid": firebaseUser,
      "savedusername": savedusername,
      "feeduserid": feeduserid,
      "feedusername": feedusername,
      "savedfeedid": feedid,
      "comparedate": comparedate,
      "createdate": createdate,
      "updatedate": ""
    });
  }

  Future getSocialFeedPostSaved() async {
    var firebaseUser = auth.FirebaseAuth.instance.currentUser!.uid;
    return await FirebaseFirestore.instance
        .collection('sm_feeds_saved')
        .orderBy("comparedate", descending: true)
        .get();
  }

  Future<void> createChatID(username, userid, userprofilepic, otherusername,
      otheruserid, otheruserprofilepic, chatid, createdate) async {
    var firebaseUser = auth.FirebaseAuth.instance.currentUser!.uid;
    DocumentReference reference = FirebaseFirestore.instance
        .collection('messages')
        .doc(userid + otheruserid);
    await reference.set({
      "username": username,
      "userid": userid,
      "isblocked": false,
      "userprofilepic": userprofilepic,
      "otherusername": otherusername,
      "otheruserid": otheruserid,
      "otheruserprofilepic": otheruserprofilepic,
      "chatid": chatid,
      "createdate": createdate,
      "lastmessage": "",
      "lastmessagetime": ""
    }).then((value) {
      databaseReference
          .child("unreadmessagecount")
          .child(userid + otheruserid)
          .set({
        userid: 0,
        otheruserid: 0,
        userid + "isuseronchatscreen": false,
        otheruserid + "isuseronchatscreen": false
      });
    });
  }

  Future getAllChatSectionDetails(selectedDoc) async {
    return await FirebaseFirestore.instance
        .collection('messages')
        .doc(selectedDoc)
        .get();
  }

  Future updateAllChatSectionDetails(selectedDoc, newValues) async {
    CollectionReference referance =
        FirebaseFirestore.instance.collection('messages');
    referance
        .doc(selectedDoc)
        .update(newValues)
        .then((value) => print("Success"))
        .catchError((error) => print("Error: $error"));
  }

  Future<void> createGroupChatID(
      groupname,
      username,
      userid,
      userprofilepic,
      List groupmemberid,
      List groupmembername,
      List groupmemberprofilepic,
      chatid,
      createdate) async {
    DocumentReference reference =
        FirebaseFirestore.instance.collection('groups').doc(groupname);
    await reference.set({
      "groupprofile":
          "https://firebasestorage.googleapis.com/v0/b/hys-pro-41c66.appspot.com/o/groupchatdefault.jpg?alt=media&token=9e53ec4a-dc49-4996-b8f5-b601d0ac5746",
      "groupname": groupname,
      "username": username,
      "userid": userid,
      "userprofilepic": userprofilepic,
      "groupmemberid": groupmemberid,
      "groupmembername": groupmembername,
      "groupmemberprofilepic": groupmemberprofilepic,
      "chatid": chatid,
      "createdate": createdate,
      "lastmessage": "",
      "lastmessagetime": ""
    });
  }

  Future getAllUserData() async {
    var firebaseUser = FirebaseAuth.instance.currentUser!.uid;
    return await FirebaseFirestore.instance
        .collection('userpersonaldata')
        .where("userid", isNotEqualTo: firebaseUser)
        .get();
  }

  Future getSocialMediaChatIDs() async {
    return await FirebaseFirestore.instance.collection('messages').get();
  }

  Future getSocialMediaGroupChatIDs() async {
    return await FirebaseFirestore.instance.collection('groups').get();
  }

  Future getSocialMediaGroupChatByID(String groupid) async {
    return await FirebaseFirestore.instance
        .collection('groups')
        .doc(groupid)
        .get();
  }

  Future getSocialMediaChat() async {
    var firebaseUser = FirebaseAuth.instance.currentUser!.uid;
    return await FirebaseFirestore.instance.collection('messages').get();
  }

  Future getSocialMediaGroupChat() async {
    var firebaseUser = FirebaseAuth.instance.currentUser!.uid;
    return await FirebaseFirestore.instance.collection('groups').get();
  }

  Future getGroupChatMessages(selectedDoc) async {
    return await FirebaseFirestore.instance
        .collection('groups')
        .doc(selectedDoc)
        .collection('SocialMediaChat')
        .get();
  }

  Future getGroupAllChatSectionDetails(selectedDoc) async {
    return await FirebaseFirestore.instance
        .collection('groups')
        .doc(selectedDoc)
        .get();
  }

  Future deleteGroupChatMessage(selectedDoc, messageDoc) async {
    return await FirebaseFirestore.instance
        .collection('groups')
        .doc(selectedDoc)
        .collection('SocialMediaChat')
        .doc(messageDoc)
        .delete();
  }

  Future deleteGroupChatSection(selectedDoc) async {
    return await FirebaseFirestore.instance
        .collection('groups')
        .doc(selectedDoc)
        .delete()
        .catchError((e) {
      print(e);
    });
  }

  Future updateChatMessage(selectedDoc, newValues) async {
    CollectionReference referance =
        FirebaseFirestore.instance.collection('messages');
    referance
        .doc(selectedDoc)
        .update(newValues)
        .then((value) => print("Success"))
        .catchError((error) => print("Error: $error"));
  }

  Future updateGroupChatMessage(selectedDoc, newValues) async {
    CollectionReference referance =
        FirebaseFirestore.instance.collection('groups');
    referance
        .doc(selectedDoc)
        .update(newValues)
        .then((value) => print("Success"))
        .catchError((error) => print("Error: $error"));
  }

  Future updateGroupChatSectionDetails(selectedDoc, newValues) async {
    CollectionReference referance =
        FirebaseFirestore.instance.collection('groups');
    referance
        .doc(selectedDoc)
        .update(newValues)
        .then((value) => print("Success"))
        .catchError((error) => print("Error: $error"));
  }

  Future getChatMessages(selectedDoc) async {
    return await FirebaseFirestore.instance
        .collection('messages')
        .doc(selectedDoc)
        .collection('SocialMediaChat')
        .get();
  }

  Future deleteChatMessages(selectedDoc) async {
    return await FirebaseFirestore.instance
        .collection('messages')
        .doc(selectedDoc)
        .collection('SocialMediaChat')
        .get()
        .then((snapshot) {
      for (DocumentSnapshot doc in snapshot.docs) {
        doc.reference.delete();
      }
    });
  }

  Future deleteChatMessage(selectedDoc, messageDoc) async {
    return await FirebaseFirestore.instance
        .collection('messages')
        .doc(selectedDoc)
        .collection('SocialMediaChat')
        .doc(messageDoc)
        .delete();
  }

  Future deleteChatSection(selectedDoc) async {
    return await FirebaseFirestore.instance
        .collection('messages')
        .doc(selectedDoc)
        .delete()
        .catchError((e) {
      print(e);
    });
  }

  Future deleteSocialFeedPostSaved(selectedDoc) async {
    return await FirebaseFirestore.instance
        .collection('sm_feeds_saved')
        .doc(selectedDoc)
        .delete()
        .catchError((e) {
      print(e);
    });
  }

  Future<String> addBlogPost(
    username,
    userprofilepic,
    grade,
    blogtitle,
    blogintro,
    blogtext,
    personalbio,
    blogmood,
    _image,
    createdate,
    comparedate,
  ) async {
    var firebaseUser = auth.FirebaseAuth.instance.currentUser!.uid;
    String id;
    CollectionReference reference =
        FirebaseFirestore.instance.collection('sm_feeds');

    await reference.add({
      "feedtype": "blog",
      "userid": firebaseUser,
      "username": username,
      "userprofilepic": userprofilepic,
      'grade': grade,
      "blogtitle": blogtitle,
      "blogintro": blogintro,
      "blogtext": blogtext,
      "personalbio": personalbio,
      "blogmood": blogmood,
      'image': _image,
      "comparedate": comparedate,
      "createdate": weekday + ", " + current_date,
      "updatedate": "",
      "likescount": 0,
      "commentscount": 0,
      "viewscount": 0
    }).then((value) {
      id = value.id;
      databaseReference.child("sm_feeds").child("reactions").child(id).set({
        "likecount": 0,
        "commentcount": 0,
        "viewcount": 0,
        "joinedcount": 0
      });
    });
    return "";
  }

  Future getUserBlogData() async {
    return await FirebaseFirestore.instance
        .collection('sm_feeds')
        .where("feedtype", isEqualTo: "blog")
        .get();
  }

  Future<dynamic> uploadPodcastAudio(String username, String profilepic,
      String albumname, String name, String duration, String filePath) async {
    var firebaseUser = FirebaseAuth.instance.currentUser!.uid;
    firebase_storage.UploadTask task = firebase_storage.FirebaseStorage.instance
        .ref('SocialFeedPost/Podcast/$firebaseUser' +
            '${Path.basename(filePath)}')
        .putFile(File(filePath));

    task.snapshotEvents.listen((firebase_storage.TaskSnapshot snapshot) {
      print(
          'Progress: ${(snapshot.bytesTransferred / snapshot.totalBytes) * 100} %');
    }, onError: (e) {
      // The final snapshot is also available on the task via `.snapshot`,
      // this can include 2 additional states, `TaskState.error` & `TaskState.canceled`
      print(task.snapshot);

      if (e.code == 'permission-denied') {
        print('User does not have permission to upload to this reference.');
        List<dynamic> x = [
          false,
          'User does not have permission to upload to this reference.'
        ];
        return x;
      }
    });

    // We can still optionally use the Future alongside the stream.
    try {
      await task;
      print('Upload complete.');
    } on firebase_core.FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        print('User does not have permission to upload to this reference.');
        List<dynamic> x = [
          false,
          'User does not have permission to upload to this reference.'
        ];
        return x;
      }
      // ...
    }

    String downloadURL = await firebase_storage.FirebaseStorage.instance
        .ref('SocialFeedPost/Podcast/$firebaseUser' +
            '${Path.basename(filePath)}')
        .getDownloadURL();
    List<dynamic> x = [true, downloadURL];
    if (downloadURL != null) {
      await addPodcastAudio(username, profilepic, albumname, name, "", duration,
          downloadURL, "", "");

      return x;
    }
  }

  Future<String> addPodcastAudio(username, userprofilepic, albumname, name,
      profilepic, duration, url, comparedate, createdate) async {
    var firebaseUser = auth.FirebaseAuth.instance.currentUser!.uid;
    String id;
    CollectionReference reference =
        FirebaseFirestore.instance.collection('podcastdata');

    await reference.add({
      "userid": firebaseUser,
      "username": username,
      "userprofilepic": userprofilepic,
      "albumname": albumname,
      "name": name,
      "profilepic": profilepic,
      "duration": duration,
      "audiourl": url,
      "comparedate": comparedate,
      "createdate": createdate,
      "updatedate": "",
      "likescount": 0,
      "commentscount": 0,
      "viewscount": 0
    }).then((value) {
      id = value.id;
      databaseReference.child("sm_podcast").child("reactions").child(id).set({
        "likecount": 0,
        "commentcount": 0,
        "viewscount": 0,
      });
      addPodcastAudiotoFeed(
          username, profilepic, albumname, name, "", duration, url, "", "");
    });
    return "";
  }

  Future<String> addPodcastAudiotoFeed(username, userprofilepic, albumname,
      name, profilepic, duration, url, comparedate, createdate) async {
    var firebaseUser = auth.FirebaseAuth.instance.currentUser!.uid;
    String id;
    CollectionReference reference =
        FirebaseFirestore.instance.collection('sm_feeds');

    await reference.add({
      "feedtype": "podcast",
      "userid": firebaseUser,
      "username": username,
      "userprofilepic": userprofilepic,
      "albumname": albumname,
      "name": name,
      "profilepic": profilepic,
      "duration": duration,
      "audiourl": url,
      "comparedate": comparedate,
      "createdate": createdate,
      "updatedate": "",
      "likescount": 0,
      "commentscount": 0,
      "viewscount": 0
    }).then((value) {
      id = value.id;
      databaseReference
          .child("sm_feeds")
          .child("reactions")
          .child(id)
          .set({"likecount": 0, "commentcount": 0, "viewscount": 0});
    });
    return "";
  }

  Future getPodcastAudio() async {
    return await FirebaseFirestore.instance.collection('podcastdata').get();
  }

  Future getPodcastAudioWhere(String albumname) async {
    return await FirebaseFirestore.instance
        .collection('podcastdata')
        .where('albumname', isEqualTo: albumname)
        .get();
  }

  Future getUserPodcastAudio() async {
    var firebaseUser = auth.FirebaseAuth.instance.currentUser!.uid;
    return await FirebaseFirestore.instance
        .collection('podcastdata')
        .where("userid", isEqualTo: firebaseUser)
        .get();
  }

  Future<dynamic> uploadEventPic(File _image) async {
    var firebaseUser = auth.FirebaseAuth.instance.currentUser!.uid;
    firebase_storage.UploadTask task = firebase_storage.FirebaseStorage.instance
        .ref('userEventPoster/$firebaseUser/$firebaseUser' +
            '${Path.basename(_image.path)}')
        .putFile(_image);

    task.snapshotEvents.listen((firebase_storage.TaskSnapshot snapshot) {
      print('Task state: ${snapshot.state}');
      print(
          'Progress: ${(snapshot.bytesTransferred / snapshot.totalBytes) * 100} %');
    }, onError: (e) {
      if (e.code == 'permission-denied') {
        print('User does not have permission to upload to this reference.');
        print('User does not have permission to upload to this reference.');
        List<dynamic> x = [
          false,
          'User does not have permission to upload to this reference.'
        ];
        return x;
      }
    });

    // We can still optionally use the Future alongside the stream.
    try {
      await task;
      print('Upload complete.');
    } on firebase_core.FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        print('User does not have permission to upload to this reference.');
        print('User does not have permission to upload to this reference.');
        List<dynamic> x = [
          false,
          'User does not have permission to upload to this reference.'
        ];
        return x;
      }
      // ...
    }

    String downloadURL = await firebase_storage.FirebaseStorage.instance
        .ref('userEventPoster/$firebaseUser/$firebaseUser' +
            '${Path.basename(_image.path)}')
        .getDownloadURL();

    List<dynamic> x = [true, downloadURL];
    if (downloadURL != null) {
      return x;
    }
  }

  Future<dynamic> uploadSocialMediaFeedImages(File _image) async {
    var firebaseUser = FirebaseAuth.instance.currentUser!.uid;
    firebase_storage.UploadTask task = firebase_storage.FirebaseStorage.instance
        .ref('SocialFeedPost/$firebaseUser/Images/$firebaseUser' +
            '${Path.basename(_image.path)}')
        .putFile(_image);

    task.snapshotEvents.listen((firebase_storage.TaskSnapshot snapshot) {
      print('Task state: ${snapshot.state}');
      print(
          'Progress: ${(snapshot.bytesTransferred / snapshot.totalBytes) * 100} %');
    }, onError: (e) {
      if (e.code == 'permission-denied') {
        print('User does not have permission to upload to this reference.');
        print('User does not have permission to upload to this reference.');
        List<dynamic> x = [
          false,
          'User does not have permission to upload to this reference.'
        ];
        return x;
      }
    });

    // We can still optionally use the Future alongside the stream.
    try {
      await task;
      print('Upload complete.');
    } on firebase_core.FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        print('User does not have permission to upload to this reference.');
        print('User does not have permission to upload to this reference.');
        List<dynamic> x = [
          false,
          'User does not have permission to upload to this reference.'
        ];
        return x;
      }
      // ...
    }

    String downloadURL = await firebase_storage.FirebaseStorage.instance
        .ref('SocialFeedPost/$firebaseUser/Images/$firebaseUser' +
            '${Path.basename(_image.path)}')
        .getDownloadURL();

    List<dynamic> x = [true, downloadURL];
    if (downloadURL != null) {
      return x;
    }
  }

  Future<dynamic> uploadSocialMediaGroupChatProfileImages(File _image) async {
    var firebaseUser = FirebaseAuth.instance.currentUser!.uid;
    firebase_storage.UploadTask task = firebase_storage.FirebaseStorage.instance
        .ref(
            'SocialFeedPost/GroupChat/GroupProfile/$firebaseUser/Images/$firebaseUser' +
                '${Path.basename(_image.path)}')
        .putFile(_image);

    task.snapshotEvents.listen((firebase_storage.TaskSnapshot snapshot) {
      print('Task state: ${snapshot.state}');
      print(
          'Progress: ${(snapshot.bytesTransferred / snapshot.totalBytes) * 100} %');
    }, onError: (e) {
      if (e.code == 'permission-denied') {
        print('User does not have permission to upload to this reference.');
        print('User does not have permission to upload to this reference.');
        List<dynamic> x = [
          false,
          'User does not have permission to upload to this reference.'
        ];
        return x;
      }
    });

    // We can still optionally use the Future alongside the stream.
    try {
      await task;
      print('Upload complete.');
    } on firebase_core.FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        print('User does not have permission to upload to this reference.');
        print('User does not have permission to upload to this reference.');
        List<dynamic> x = [
          false,
          'User does not have permission to upload to this reference.'
        ];
        return x;
      }
      // ...
    }

    String downloadURL = await firebase_storage.FirebaseStorage.instance
        .ref(
            'SocialFeedPost/GroupChat/GroupProfile/$firebaseUser/Images/$firebaseUser' +
                '${Path.basename(_image.path)}')
        .getDownloadURL();

    List<dynamic> x = [true, downloadURL];
    if (downloadURL != null) {
      return x;
    }
  }

  Future<dynamic> uploadSocialMediaGroupChatImages(File _image) async {
    var firebaseUser = FirebaseAuth.instance.currentUser!.uid;
    firebase_storage.UploadTask task = firebase_storage.FirebaseStorage.instance
        .ref(
            'SocialFeedPost/GroupChat/chat_images/$firebaseUser/Images/$firebaseUser' +
                '${Path.basename(_image.path)}')
        .putFile(_image);

    task.snapshotEvents.listen((firebase_storage.TaskSnapshot snapshot) {
      print('Task state: ${snapshot.state}');
      print(
          'Progress: ${(snapshot.bytesTransferred / snapshot.totalBytes) * 100} %');
    }, onError: (e) {
      if (e.code == 'permission-denied') {
        print('User does not have permission to upload to this reference.');
        print('User does not have permission to upload to this reference.');
        List<dynamic> x = [
          false,
          'User does not have permission to upload to this reference.'
        ];
        return x;
      }
    });

    // We can still optionally use the Future alongside the stream.
    try {
      await task;
      print('Upload complete.');
    } on firebase_core.FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        print('User does not have permission to upload to this reference.');
        print('User does not have permission to upload to this reference.');
        List<dynamic> x = [
          false,
          'User does not have permission to upload to this reference.'
        ];
        return x;
      }
      // ...
    }

    String downloadURL = await firebase_storage.FirebaseStorage.instance
        .ref(
            'SocialFeedPost/GroupChat/chat_images/$firebaseUser/Images/$firebaseUser' +
                '${Path.basename(_image.path)}')
        .getDownloadURL();

    List<dynamic> x = [true, downloadURL];
    if (downloadURL != null) {
      return x;
    }
  }

  Future<dynamic> uploadReferenceVideo(String filePath) async {
    var firebaseUser = FirebaseAuth.instance.currentUser!.uid;
    firebase_storage.UploadTask task = firebase_storage.FirebaseStorage.instance
        .ref('SocialFeedPost/$firebaseUser/$firebaseUser' +
            '${Path.basename(filePath)}')
        .putFile(File(filePath));

    task.snapshotEvents.listen((firebase_storage.TaskSnapshot snapshot) {
      print(
          'Progress: ${(snapshot.bytesTransferred / snapshot.totalBytes) * 100} %');
    }, onError: (e) {
      // The final snapshot is also available on the task via `.snapshot`,
      // this can include 2 additional states, `TaskState.error` & `TaskState.canceled`
      print(task.snapshot);

      if (e.code == 'permission-denied') {
        print('User does not have permission to upload to this reference.');
        List<dynamic> x = [
          false,
          'User does not have permission to upload to this reference.'
        ];
        return x;
      }
    });

    // We can still optionally use the Future alongside the stream.
    try {
      await task;
      print('Upload complete.');
    } on firebase_core.FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        print('User does not have permission to upload to this reference.');
        List<dynamic> x = [
          false,
          'User does not have permission to upload to this reference.'
        ];
        return x;
      }
      // ...
    }

    String downloadURL = await firebase_storage.FirebaseStorage.instance
        .ref('SocialFeedPost/$firebaseUser/$firebaseUser' +
            '${Path.basename(filePath)}')
        .getDownloadURL();
    List<dynamic> x = [true, downloadURL];
    if (downloadURL != null) {
      return x;
    }
  }
}
