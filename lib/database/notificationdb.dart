import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

final databaseReference = FirebaseDatabase.instance.reference();

class PushNotificationDB {
  final firebaseUser = auth.FirebaseAuth.instance.currentUser!.uid;

  Future<void> initialteTokenData() async {
    DocumentReference reference = FirebaseFirestore.instance
        .collection('notificationtokendata')
        .doc(firebaseUser);
    await reference.set({"userid": firebaseUser, "token": "", "createdat": ''});
  }

  Future<void> addCallingMessages(sendername, receivername, receiverid, message,
      current_date, token, questionid, comparedate) async {
    CollectionReference reference =
        FirebaseFirestore.instance.collection('questionaddedrequestsent');
    await reference.add({
      "notificationtype": "q&a",
      "senderid": firebaseUser,
      "token": token,
      "createdate": current_date,
      "comparedate": comparedate,
      "sendername": sendername,
      "receivername": receivername,
      "receiverid": receiverid,
      "message": message,
      "notificationid": "questionaddedrequestsent",
      "questionid": questionid
    }).then((value) async {
      await databaseReference.child("allnotifications").child(value.id).set({
        "trigger": false,
      });
    });
  }

  Future<void> addsuperuserresponseonquestionadded(
      sendername,
      receivername,
      receiverid,
      message,
      current_date,
      token,
      questionid,
      response,
      comparedate) async {
    CollectionReference reference = FirebaseFirestore.instance
        .collection('superuserresponseonquestionadded');
    await reference.add({
      "notificationtype": "q&a",
      "senderid": firebaseUser,
      "token": token,
      "createdate": current_date,
      "comparedate": comparedate,
      "sendername": sendername,
      "receivername": receivername,
      "receiverid": receiverid,
      "message": message,
      "notificationid": "superuserresponseonquestionadded",
      "questionid": questionid,
      "response": response
    }).then((value) async {
      await databaseReference.child("allnotifications").child(value.id).set({
        "trigger": false,
      });
    });
  }

  Future<void> questionPostNotifications(
      sendername,
      receivername,
      receiverid,
      message,
      current_date,
      token,
      questionid,
      answerpreference,
      callnow,
      response,
      notificationid,
      comparedate) async {
    CollectionReference reference =
        FirebaseFirestore.instance.collection('allnotifications');
    await reference.add({
      "notificationtype": "q&a",
      "senderid": firebaseUser,
      "token": token,
      "createdate": current_date,
      "comparedate": comparedate,
      "sendername": sendername,
      "receivername": receivername,
      "receiverid": receiverid,
      "answerpreference": answerpreference,
      "message": message,
      "notificationid": notificationid,
      "callnow": callnow,
      "questionid": questionid,
      "response": response
    }).then((value) async {
      await databaseReference.child("allnotifications").child(value.id).set({
        "trigger": false,
      });
    });
  }

  Future<void> questionReactionsNotifications(
      sendername,
      senderprofile,
      receivername,
      receiverid,
      message,
      tittle,
      current_date,
      token,
      questionid,
      questionindex,
      reactiontype,
      comparedate) async {
    DocumentReference reference = FirebaseFirestore.instance
        .collection('allnotifications')
        .doc(firebaseUser + questionid + reactiontype);
    await reference.set({
      "notificationtype": "q&a",
      "senderid": firebaseUser,
      "senderprofile": senderprofile,
      "token": token,
      "createdate": current_date,
      "comparedate": comparedate,
      "sendername": sendername,
      "receivername": receivername,
      "receiverid": receiverid,
      "tittle": tittle,
      "message": message,
      "reactiontype": reactiontype,
      "notificationid": "reactionsonquestion",
      "questionid": questionid,
      "questionindex": questionindex
    }).then((value) async {
      await databaseReference
          .child("allnotifications")
          .child(firebaseUser + questionid + reactiontype)
          .set({
        "trigger": false,
      });
    });
  }

  Future deleteQuestionReactionsNotification(questionid, reactiontype) async {
    var firebaseUser = FirebaseAuth.instance.currentUser!.uid;
    return await FirebaseFirestore.instance
        .collection("allnotifications")
        .doc(firebaseUser + questionid + reactiontype)
        .delete()
        .catchError((e) {
      print(e);
    });
  }

  Future deleteNotification(id) async {
    return await FirebaseFirestore.instance
        .collection("allnotifications")
        .doc(id)
        .delete()
        .catchError((e) {
      print(e);
    });
  }

  Future<void> addAllTypeOfNotifications(
      sendername,
      receivername,
      receiverid,
      message,
      current_date,
      token,
      questionid,
      answerpreference,
      response,
      notificationid,
      comparedate) async {
    CollectionReference reference =
        FirebaseFirestore.instance.collection('allnotifications');
    await reference.add({
      "notificationtype": "q&a",
      "senderid": firebaseUser,
      "token": token,
      "createdate": current_date,
      "comparedate": comparedate,
      "sendername": sendername,
      "receivername": receivername,
      "receiverid": receiverid,
      "answerpreference": answerpreference,
      "message": message,
      "notificationid": notificationid,
      "questionid": questionid,
      "response": response
    }).then((value) async {
      await databaseReference.child("allnotifications").child(value.id).set({
        "trigger": false,
      });
    });
  }

  Future<void> sendFriendRequest(
      sendername,
      senderprofile,
      receivername,
      receiverid,
      message,
      current_date,
      token,
      notificationid,
      comparedate) async {
    CollectionReference reference =
        FirebaseFirestore.instance.collection('allnotifications');
    await reference.add({
      "notificationtype": "friendrequest",
      "senderid": firebaseUser,
      "token": token,
      "profilepic": senderprofile,
      "createdate": current_date,
      "comparedate": comparedate,
      "sendername": sendername,
      "receivername": receivername,
      "receiverid": receiverid,
      "message": message,
      "notificationid": notificationid,
      "requeststatus": false,
      "questionid": receiverid
    }).then((value) async {
      await databaseReference.child("allnotifications").child(value.id).set({
        "trigger": false,
      });
    });
  }

  Future<String> incomingCalNotificationToSuperUser(
      sendername,
      receivername,
      receiverid,
      message,
      current_date,
      token,
      questionid,
      answerpreference,
      channelid,
      notificationid,
      comparedate) async {
    CollectionReference reference = FirebaseFirestore.instance
        .collection('callingresponsetosuperuserquestionadded');
    String id = "";
    await reference.add({
      "notificationtype": "q&a",
      "senderid": firebaseUser,
      "token": token,
      "createdate": current_date,
      "comparedate": comparedate,
      "sendername": sendername,
      "receivername": receivername,
      "receiverid": receiverid,
      "message": message,
      "notificationid": notificationid,
      "questionid": questionid,
      "answerpreference": answerpreference,
      "channelid": channelid
    }).then((value) async {
      id = value.id;
      await databaseReference
          .child("hys_calling_data")
          .child("sm_calls")
          .child(channelid)
          .set({
        "iscallreceivedbyReceiver": false,
        "iscallcancelledbycaller": false,
        "iscallrejected": false,
        "iscallcancelledafterReceived": false,
        "message": "NO"
      });
    });
    return id;
  }

  Future<void> incomingCallTestDataStore(
      sendername,
      receivername,
      receiverid,
      message,
      current_date,
      token,
      questionid,
      channelid,
      notificationid,
      comparedate) async {
    CollectionReference reference =
        FirebaseFirestore.instance.collection('callingnotificationtotest');
    await reference.add({
      "notificationtype": "q&a",
      "senderid": firebaseUser,
      "token": token,
      "createdate": current_date,
      "comparedate": comparedate,
      "sendername": sendername,
      "receivername": receivername,
      "receiverid": receiverid,
      "message": message,
      "notificationid": notificationid,
      "questionid": questionid,
      "channelid": channelid
    });
  }

  Future<void> callingFeedBackStore(questionid, userid, ratings,
      isSolutionCorrect, comments, current_date, comparedate) async {
    var firebaseUser = auth.FirebaseAuth.instance.currentUser!.uid;
    CollectionReference reference =
        FirebaseFirestore.instance.collection('audiovideosolutionfeedback');
    await reference.add({
      "userid": firebaseUser,
      "questionid": questionid,
      "feedbackgiventouser": userid,
      "ratings": ratings,
      "issolutioncorrect": isSolutionCorrect,
      "comments": comments,
      "createdate": current_date,
      "comparedate": comparedate,
    });
  }

  Future<void> notifyForBucketB(questionid, sendername, receiverid,
      receivername, token, message, current_date, comparedate) async {
    var firebaseUser = auth.FirebaseAuth.instance.currentUser!.uid;
    CollectionReference reference =
        FirebaseFirestore.instance.collection('notificationforbucketB');
    await reference.add({
      "senderid": firebaseUser,
      "sendername": sendername,
      "receiverid": receiverid,
      "receivername": receivername,
      "questionid": questionid,
      "notificationtype": "superuser",
      "notificationid": "forBucketB",
      "token": token,
      "message": message,
      "createdate": current_date,
      "comparedate": comparedate,
    });
  }

  Future<void> notifyForBucketBAllNotificationsTable(
      questionid,
      sendername,
      receiverid,
      receivername,
      token,
      message,
      current_date,
      comparedate) async {
    var firebaseUser = auth.FirebaseAuth.instance.currentUser!.uid;
    CollectionReference reference =
        FirebaseFirestore.instance.collection('allnotifications');
    await reference.add({
      "senderid": firebaseUser,
      "sendername": sendername,
      "receiverid": receiverid,
      "receivername": receivername,
      "questionid": questionid,
      "notificationtype": "superuser",
      "notificationid": "forBucketB",
      "token": token,
      "message": message,
      "createdate": current_date,
      "comparedate": comparedate,
    }).then((value) async {
      await databaseReference.child("allnotifications").child(value.id).set({
        "trigger": false,
      });
    });
  }

  Future<void> addIntoBucketB(
      questionid, username, token, current_date, comparedate) async {
    var firebaseUser = auth.FirebaseAuth.instance.currentUser!.uid;
    CollectionReference reference =
        FirebaseFirestore.instance.collection('bucketB');
    await reference.add({
      "userid": firebaseUser,
      "username": username,
      "questionid": questionid,
      "token": token,
      "createdate": current_date,
      "comparedate": comparedate,
    });
  }

  Future getBucketBData() async {
    return await FirebaseFirestore.instance
        .collection('bucketB')
        .orderBy("comparedate", descending: true)
        .get();
  }

  Future getTokenData() async {
    return await FirebaseFirestore.instance
        .collection('notificationtokendata')
        .get();
  }

  Future getMyNotificationData() async {
    var firebaseUser = auth.FirebaseAuth.instance.currentUser!.uid;
    return await FirebaseFirestore.instance
        .collection('allnotifications')
        .orderBy("comparedate", descending: true)
        .where('receiverid', isEqualTo: firebaseUser)
        .get();
  }

  Future getSpecificNotificationData(String id) async {
    return await FirebaseFirestore.instance
        .collection('allnotifications')
        .doc(id)
        .get();
  }

  Future updateNotificationData(selectedDoc, newValues) async {
    CollectionReference referance =
        FirebaseFirestore.instance.collection('allnotifications');
    referance
        .doc(selectedDoc)
        .update(newValues)
        .then((value) => print("Success"))
        .catchError((error) => print("Error: $error"));
  }

  Future updateTokenData(selectedDoc, newValues) async {
    CollectionReference referance =
        FirebaseFirestore.instance.collection('notificationtokendata');
    referance
        .doc(selectedDoc)
        .update(newValues)
        .then((value) => print("Success"))
        .catchError((error) => print("Error: $error"));
  }
}
