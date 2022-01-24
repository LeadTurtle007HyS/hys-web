import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_core/firebase_core.dart' as firebase_core;
import 'package:path/path.dart' as Path;
import 'dart:html' as html;

final databaseReference = FirebaseDatabase.instance.reference();

class CrudMethods {
  late String datavalue;

  Future<void> addUserCallingProfileData(
      fname, lname, profilepic, email) async {
    var firebaseUser = auth.FirebaseAuth.instance.currentUser!.uid;

    CollectionReference reference =
        FirebaseFirestore.instance.collection('usercallingprofiledata');
    await reference.add({
      "uid": firebaseUser,
      "email": email,
      "name": fname + " " + lname,
      "profilephoto": profilepic,
      "username": lname + fname
    });
  }

  Future<void> addUserInteractionScoreData(interactionscore) async {
    var firebaseUser = auth.FirebaseAuth.instance.currentUser!.uid;

    DocumentReference reference = FirebaseFirestore.instance
        .collection('interactionscore')
        .doc(firebaseUser);
    await reference
        .set({"userid": firebaseUser, "interactionscore": interactionscore});
  }

  Future updateUserInteractionScoreData(selectedDoc, newValues) async {
    CollectionReference referance =
        FirebaseFirestore.instance.collection('interactionscore');
    referance
        .doc(selectedDoc)
        .update(newValues)
        .then((value) => print("Success"))
        .catchError((error) => print("Error: $error"));
  }

  Future getUserInteractionScore(String id) async {
    var firebaseUser = auth.FirebaseAuth.instance.currentUser!.uid;
    return await FirebaseFirestore.instance
        .collection('interactionscore')
        .where('userid', isEqualTo: id)
        .get();
  }

  Future getAllUserInteractionScore() async {
    var firebaseUser = auth.FirebaseAuth.instance.currentUser!.uid;
    return await FirebaseFirestore.instance
        .collection('interactionscore')
        .get();
  }

  Future<void> addUserCreditPointsData(
      credits, topic, createdate, comparedate) async {
    var firebaseUser = auth.FirebaseAuth.instance.currentUser!.uid;

    CollectionReference reference =
        FirebaseFirestore.instance.collection('creditpointsdetails');
    await reference.add({
      "userid": firebaseUser,
      "creditpoints": credits,
      "topic": topic,
      "createdate": createdate,
      "comparedate": comparedate
    });
  }

  Future getUserCreditPoints() async {
    var firebaseUser = auth.FirebaseAuth.instance.currentUser!.uid;
    return await FirebaseFirestore.instance
        .collection('creditpointsdetails')
        .where('userid', isEqualTo: firebaseUser)
        .get();
  }

  Future updateUserCreditPointsDetails(selectedDoc, newValues) async {
    CollectionReference referance =
        FirebaseFirestore.instance.collection('creditpointsdetails');
    referance
        .doc(selectedDoc)
        .update(newValues)
        .then((value) => print("Success"))
        .catchError((error) => print("Error: $error"));
  }

  Future<void> addUserAchievements(
      achievementType,
      achievementTittle,
      achievementPic,
      achievemntDesc,
      schoreCardBoardName,
      schoreCardSchoolname,
      scoreCardGrade,
      List scoreCardSubjects,
      List scoreCardSubjectWiseScore,
      scoreCardtotalScore,
      createdate,
      compaedate) async {
    var firebaseUser = auth.FirebaseAuth.instance.currentUser!.uid;
    CollectionReference reference =
        FirebaseFirestore.instance.collection('userAchievements');
    await reference.add({
      "userid": firebaseUser,
      "type": achievementType,
      "achievementTittle": achievementTittle,
      "achievementPic": achievementPic,
      "achievementDesc": achievemntDesc,
      "ScoreCardBoardName": schoreCardBoardName,
      "ScoreCardSchoolname": schoreCardSchoolname,
      "scoreCardGrade": scoreCardGrade,
      "scoreCardSubjects": scoreCardSubjects,
      "scoreCardSubjectWiseScore": scoreCardSubjectWiseScore,
      "scoreCardtotalScore": scoreCardtotalScore,
      "createdate": createdate,
      "comparedate": compaedate
    });
  }

  Future<void> addUserPrivacy(createdate, compaedate) async {
    var firebaseUser = auth.FirebaseAuth.instance.currentUser!.uid;
    DocumentReference reference =
        FirebaseFirestore.instance.collection('userprivacy').doc(firebaseUser);
    await reference.set({
      "userid": firebaseUser,
      "friends": true,
      "weakness": true,
      "uploads": true,
      "scorecard": true,
      "groups": true,
      "library": true,
      "email": true,
      "mobile": true,
      "address": true,
      "schooladdress": true,
      "hobbies": true,
      "ambition": true,
      "novels": true,
      "placesvisited": true,
      "dreamvacations": true,
      "createdate": createdate,
      "comparedate": compaedate
    });
  }

  Future getUserPrivacy() async {
    var firebaseUser = auth.FirebaseAuth.instance.currentUser!.uid;
    return await FirebaseFirestore.instance
        .collection('userprivacy')
        .where('userid', isEqualTo: firebaseUser)
        .get();
  }

  Future getSpecificUserPrivacy(String id) async {
    var firebaseUser = auth.FirebaseAuth.instance.currentUser!.uid;
    return await FirebaseFirestore.instance
        .collection('userprivacy')
        .where('userid', isEqualTo: id)
        .get();
  }

  Future updateUserPrivacy(selectedDoc, newValues) async {
    CollectionReference referance =
        FirebaseFirestore.instance.collection('userprivacy');
    referance
        .doc(selectedDoc)
        .update(newValues)
        .then((value) => print("Success"))
        .catchError((error) => print("Error: $error"));
  }

  Future<void> addUserInConnection(
      username,
      userprofile,
      otheruserid,
      bool isfollowing,
      bool isfriend,
      bool isrequestaccepted,
      bool onlyfollowing,
      createdate,
      compaedate) async {
    var firebaseUser = auth.FirebaseAuth.instance.currentUser!.uid;
    CollectionReference reference =
        FirebaseFirestore.instance.collection('userconnections');
    await reference.add({
      "userid": firebaseUser,
      "username": username,
      "userprofilepic": userprofile,
      "otheruserid": otheruserid,
      "isfollowing": isfollowing,
      "onlyfollowing": onlyfollowing,
      "isfriend": isfriend,
      "isrequestaccepted": isrequestaccepted,
      "createdate": createdate,
      "comparedate": compaedate
    });
  }

  Future<void> addUserLogs(username, int noOfLogins, onlyDate, int activetime,
      starttime, createdate, compaedate) async {
    var firebaseUser = auth.FirebaseAuth.instance.currentUser!.uid;
    DocumentReference reference = FirebaseFirestore.instance
        .collection('userlogs')
        .doc(onlyDate + firebaseUser);
    await reference.set({
      "userid": firebaseUser,
      "username": username,
      "onlydate": onlyDate,
      "starttime": starttime,
      "numbersoflogins": noOfLogins,
      "activetime": activetime,
      "createdate": createdate,
      "comparedate": compaedate
    });
  }

  Future getUsersLogs() async {
    var firebaseUser = auth.FirebaseAuth.instance.currentUser!.uid;
    return await FirebaseFirestore.instance
        .collection('userlogs')
        .where('userid', isEqualTo: firebaseUser)
        .orderBy("comparedate", descending: true)
        .get();
  }

  Future updateUsersLogs(selectedDoc, newValues) async {
    CollectionReference referance =
        FirebaseFirestore.instance.collection('userlogs');
    referance
        .doc(selectedDoc)
        .update(newValues)
        .then((value) => print("Success"))
        .catchError((error) => print("Error: $error"));
  }

  Future<void> addProfielVisitedLogs(hostid, createdate, compaedate) async {
    var firebaseUser = auth.FirebaseAuth.instance.currentUser!.uid;
    DocumentReference reference = FirebaseFirestore.instance
        .collection('profilevisitedlogs')
        .doc(firebaseUser + hostid);
    await reference.set({
      "userid": firebaseUser,
      "hostid": hostid,
      "createdate": createdate,
      "comparedate": compaedate
    });
  }

  Future getProfielVisitedLogs() async {
    var firebaseUser = auth.FirebaseAuth.instance.currentUser!.uid;
    return await FirebaseFirestore.instance
        .collection('profilevisitedlogs')
        .where('  ', isEqualTo: firebaseUser)
        .orderBy("comparedate", descending: true)
        .get();
  }

  Future<void> addcallLogs(receiverid, channelid, calltype, status, callmotive,
      int duration, starttime, endtime, createdate, compaedate) async {
    var firebaseUser = auth.FirebaseAuth.instance.currentUser!.uid;
    DocumentReference reference =
        FirebaseFirestore.instance.collection('calllogs').doc(channelid);
    await reference.set({
      "callerid": firebaseUser,
      "receiverid": receiverid,
      "starttime": starttime,
      "endtime": endtime,
      "calltype": calltype,
      "callstatus": status,
      "callmotive": callmotive,
      "createdate": createdate,
      "duration": duration,
      "comparedate": compaedate
    });
  }

  Future getCallLogs() async {
    // var firebaseUser = auth.FirebaseAuth.instance.currentUser!.uid;
    return await FirebaseFirestore.instance
        .collection('calllogs')
        .orderBy("comparedate", descending: true)
        .get();
  }

  Future updateCallLogs(selectedDoc, newValues) async {
    CollectionReference referance =
        FirebaseFirestore.instance.collection('calllogs');
    referance
        .doc(selectedDoc)
        .update(newValues)
        .then((value) => print("Success"))
        .catchError((error) => print("Error: $error"));
  }

  Future getUserConnection() async {
    var firebaseUser = auth.FirebaseAuth.instance.currentUser!.uid;
    return await FirebaseFirestore.instance
        .collection('userconnections')
        .orderBy("comparedate", descending: true)
        .get();
  }

  Future getMyUserConnection() async {
    var firebaseUser = auth.FirebaseAuth.instance.currentUser!.uid;
    return await FirebaseFirestore.instance
        .collection('userconnections')
        .orderBy("comparedate", descending: true)
        .where('userid', isEqualTo: firebaseUser)
        .get();
  }

  Future getUserConnectionStatus(String userid) async {
    var firebaseUser = auth.FirebaseAuth.instance.currentUser!.uid;
    return await FirebaseFirestore.instance
        .collection('userconnections')
        .orderBy("comparedate", descending: true)
        .where('userid', isEqualTo: firebaseUser)
        .where('otheruserid', isEqualTo: userid)
        .get();
  }

  Future getAllUserConnectionStatus() async {
    var firebaseUser = auth.FirebaseAuth.instance.currentUser!.uid;
    return await FirebaseFirestore.instance
        .collection('userconnections')
        .orderBy("comparedate", descending: true)
        .where('userid', isEqualTo: firebaseUser)
        .get();
  }

  Future updateUserConnectionData(selectedDoc, newValues) async {
    CollectionReference referance =
        FirebaseFirestore.instance.collection('userconnections');
    referance
        .doc(selectedDoc)
        .update(newValues)
        .then((value) => print("Success"))
        .catchError((error) => print("Error: $error"));
  }

  Future deleteUserConnectionData(selectedDoc) async {
    return await FirebaseFirestore.instance
        .collection('userconnections')
        .doc(selectedDoc)
        .delete()
        .catchError((e) {
      print(e);
    });
  }

  Future getUserAchievementsData() async {
    var firebaseUser = auth.FirebaseAuth.instance.currentUser!.uid;
    return await FirebaseFirestore.instance
        .collection('userAchievements')
        .orderBy("comparedate", descending: true)
        .where('userid', isEqualTo: firebaseUser)
        .get();
  }

  Future<void> addUserData(
      fname,
      lname,
      email,
      mobile,
      gender,
      dob,
      address,
      street,
      city,
      state,
      avatar,
      List preferedlanguage,
      hobbies,
      ambition,
      novels,
      placesVisited,
      dreamVacations,
      createdate,
      comparedate) async {
    var firebaseUser = auth.FirebaseAuth.instance.currentUser!.uid;

    await FirebaseFirestore.instance
        .collection('userpersonaldata')
        .doc(firebaseUser)
        .set({
      "userid": firebaseUser,
      "firstname": fname,
      "lastname": lname,
      "email": email,
      "mobile": mobile,
      "gender": gender,
      "dob": dob,
      "address": address,
      "street": street,
      "city": city,
      'state': state,
      "preferedlanguage": preferedlanguage,
      'profilepic': avatar,
      "hobbies": hobbies,
      "ambition": ambition,
      "novelsread": novels,
      "placesvisited": placesVisited,
      "dreamvacations": dreamVacations,
      'createdate': createdate,
      "comparedate": comparedate
    }).then((value) {
      databaseReference
          .child("hys_calling_data")
          .child("usercallstatus")
          .child(firebaseUser)
          .set({"callstatus": false});
    });
  }

  updateProfile(File image) async {
    String imgUrl = '';
    var firebaseUser = auth.FirebaseAuth.instance.currentUser!.uid;
    uploadProfilePic(image).then((value) {
      print(value);
      if (value[0] == true) {
        imgUrl = value[1];
        print(imgUrl);
        if (imgUrl != "") {
          updateUserData(firebaseUser, {"profilepic": imgUrl});
        }
      }
    });
  }

  Future<void> addSubjectTopicData(
      id, grade, subject, books, topic, board) async {
    CollectionReference reference =
        FirebaseFirestore.instance.collection("classsubjecttopicdata");

    await reference.add({
      "id": id,
      "grade": grade,
      "subject": subject,
      "book": books,
      "topic": topic,
      "board": board
    });
  }

  Future<void> addUserRegistrationProcessStatusData(
      personaldata, schooldata, strength, weakness) async {
    var firebaseUser = auth.FirebaseAuth.instance.currentUser!.uid;
    CollectionReference reference = FirebaseFirestore.instance
        .collection("userregistrationprocessstatusdata");

    await reference.add({
      "userid": firebaseUser,
      "personaldata": personaldata,
      "schooldata": schooldata,
      "strength": strength,
      "weakness": weakness
    });
  }

  Future<void> addGradeSubjectData(grade, subject, board) async {
    CollectionReference reference =
        FirebaseFirestore.instance.collection("classgradesubjectdata");

    await reference.add({"grade": grade, "subject": subject, "board": board});
  }

  Future<void> addUserStrengthGradeSubjectTopicData(
      grade, subject, topic, createdate, comparedate) async {
    var firebaseUser = auth.FirebaseAuth.instance.currentUser!.uid;
    CollectionReference reference =
        FirebaseFirestore.instance.collection("strengthclassgradesubjectdata");

    await reference.add({
      "userid": firebaseUser,
      "grade": grade,
      "subject": subject,
      "topic": topic,
      "createdate": createdate,
      "comparedate": comparedate,
      "updatedate": ""
    });
  }

  Future<void> addUserWeaknessGradeSubjectTopicData(
      grade, subject, topic, createdate, comparedate) async {
    var firebaseUser = auth.FirebaseAuth.instance.currentUser!.uid;
    CollectionReference reference =
        FirebaseFirestore.instance.collection("weaknessclassgradesubjectdata");

    await reference.add({
      "userid": firebaseUser,
      "grade": grade,
      "subject": subject,
      "topic": topic,
      "createdate": createdate,
      "comparedate": comparedate,
      "updatedate": ""
    });
  }

  Future<void> addUserSchoolData(schoolname, grade, stream, board, sArea, sCity,
      sState, createdate, comparedate) async {
    var firebaseUser = auth.FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance
        .collection("userschooldata")
        .doc(firebaseUser)
        .set({
      "userid": firebaseUser,
      "schoolname": schoolname,
      "grade": grade,
      "stream": stream,
      "board": board,
      "schoolstreet": sArea,
      "schoolcity": sCity,
      "schoolstate": sState,
      "createdate": createdate,
      "comparedate": comparedate
    });
  }

  Future getUserData() async {
    var firebaseUser = auth.FirebaseAuth.instance.currentUser!.uid;
    return await FirebaseFirestore.instance
        .collection('userpersonaldata')
        .where('userid', isEqualTo: firebaseUser)
        .get();
  }

  Future getSpecificUserData(String uid) async {
    return await FirebaseFirestore.instance
        .collection('userpersonaldata')
        .where('userid', isEqualTo: uid)
        .get();
  }

  Future getAllUserData() async {
    return await FirebaseFirestore.instance
        .collection('userpersonaldata')
        .get();
  }

  Future getUserCallingProfileData() async {
    var firebaseUser = auth.FirebaseAuth.instance.currentUser!.uid;
    return await FirebaseFirestore.instance
        .collection('usercallingprofiledata')
        .where('userid', isEqualTo: firebaseUser)
        .get();
  }

  Future getSubjectAndTopicList(String grade) async {
    return await FirebaseFirestore.instance
        .collection('classgradesubjectdata')
        .where("board",
            isEqualTo: "Central Board of Secondary Education (CBSE)")
        .where("grade", isEqualTo: grade)
        .get();
  }

  Future getUserAskedQuestions(String userid) async {
    return await FirebaseFirestore.instance
        .collection('userquestionadded')
        .where('userid', isEqualTo: userid)
        .get();
  }

  Future getUserSchoolData() async {
    var firebaseUser = auth.FirebaseAuth.instance.currentUser!.uid;
    return await FirebaseFirestore.instance
        .collection('userschooldata')
        .where('userid', isEqualTo: firebaseUser)
        .get();
  }

  Future getAllUserSchoolData() async {
    return await FirebaseFirestore.instance.collection('userschooldata').get();
  }

  Future getOtherUsersData(String userid) async {
    return await FirebaseFirestore.instance
        .collection('userpersonaldata')
        .where('userid', isEqualTo: userid)
        .get();
  }

  Future getOtherUsersSchoolData(String userid) async {
    return await FirebaseFirestore.instance
        .collection('userschooldata')
        .where('userid', isEqualTo: userid)
        .get();
  }

  Future getUserRegistrationProcessStatusData() async {
    var firebaseUser = auth.FirebaseAuth.instance.currentUser!.uid;
    return await FirebaseFirestore.instance
        .collection('userregistrationprocessstatusdata')
        .where('userid', isEqualTo: firebaseUser)
        .get();
  }

  Future getUserAnsweredCount(String userid) async {
    return await FirebaseFirestore.instance
        .collection('useranswerposted')
        .where('answererid', isEqualTo: userid)
        .get();
  }

  Future getUserStrengthData(String userid) async {
    return await FirebaseFirestore.instance
        .collection('strengthclassgradesubjectdata')
        .where('userid', isEqualTo: userid)
        .get();
  }

  Future getUserWeaknessData(String userid) async {
    return await FirebaseFirestore.instance
        .collection('weaknessclassgradesubjectdata')
        .where('userid', isEqualTo: userid)
        .get();
  }

  Future getSchoolRankingData() async {
    return await FirebaseFirestore.instance.collection('school_ranking').get();
  }

  Future getAllUserStrengthData() async {
    return await FirebaseFirestore.instance
        .collection('strengthclassgradesubjectdata')
        .get();
  }

  Future getAllUserWeaknessData() async {
    return await FirebaseFirestore.instance
        .collection('weaknessclassgradesubjectdata')
        .get();
  }

  Future getGradeSubjectList(String board) async {
    return await FirebaseFirestore.instance
        .collection('classgradesubjectdata')
        .where("board",
            isEqualTo: "Central Board of Secondary Education (CBSE)")
        .get();
  }

  Future getGradeSubjectListwithGradeFilter(String grade) async {
    return await FirebaseFirestore.instance
        .collection('classgradesubjectdata')
        .where("board",
            isEqualTo: "Central Board of Secondary Education (CBSE)")
        .get();
  }

  Future getSubjectListSingleGradeWise(String grade, String board) async {
    return await FirebaseFirestore.instance
        .collection('classgradesubjectdata')
        .where("board", isEqualTo: board)
        .where("grade", isEqualTo: grade)
        .get();
  }

  Future getTopicSubjectList(String board) async {
    return await FirebaseFirestore.instance
        .collection('classsubjecttopicdata')
        .where("board", isEqualTo: board)
        .orderBy("id", descending: false)
        .get();
  }

  Future getTopicSubjectListGradeSubjectWise(
      String grade, String subject) async {
    return await FirebaseFirestore.instance
        .collection('classsubjecttopicdata')
        .where('grade', isEqualTo: grade)
        .where('subject', isEqualTo: subject)
        .where("board",
            isEqualTo: "Central Board of Secondary Education (CBSE)")
        .orderBy("id", descending: false)
        .get();
  }

  Future updateUserData(selectedDoc, newValues) async {
    CollectionReference referance =
        FirebaseFirestore.instance.collection('userpersonaldata');
    referance
        .doc(selectedDoc)
        .update(newValues)
        .then((value) => print("Success"))
        .catchError((error) => print("Error: $error"));
  }

  Future updateUserCallingProfileData(selectedDoc, newValues) async {
    CollectionReference referance =
        FirebaseFirestore.instance.collection('usercallingprofiledata');
    referance
        .doc(selectedDoc)
        .update(newValues)
        .then((value) => print("Success"))
        .catchError((error) => print("Error: $error"));
  }

  Future updateUserSchoolData(selectedDoc, newValues) async {
    CollectionReference referance =
        FirebaseFirestore.instance.collection('userschooldata');
    referance
        .doc(selectedDoc)
        .update(newValues)
        .then((value) => print("Success"))
        .catchError((error) => print("Error: $error"));
  }

  Future updateUserRegistrationProcessStatusData(selectedDoc, newValues) async {
    CollectionReference referance = FirebaseFirestore.instance
        .collection('userregistrationprocessstatusdata');
    referance
        .doc(selectedDoc)
        .update(newValues)
        .then((value) => print("Success"))
        .catchError((error) => print("Error: $error"));
  }

  Future deleteUserPersonalData(selectedDoc) async {
    return await FirebaseFirestore.instance
        .collection('userpersonaldata')
        .doc(selectedDoc)
        .delete()
        .catchError((e) {
      print(e);
    });
  }

  Future deleteUserSchoolData(selectedDoc) async {
    return await FirebaseFirestore.instance
        .collection('userschooldata')
        .doc(selectedDoc)
        .delete()
        .catchError((e) {
      print(e);
    });
  }

  Future deleteUserStrengthData(selectedDoc) async {
    return await FirebaseFirestore.instance
        .collection('strengthclassgradesubjectdata')
        .doc(selectedDoc)
        .delete()
        .catchError((e) {
      print(e);
    });
  }

  Future deleteUserWeaknessData(selectedDoc) async {
    return await FirebaseFirestore.instance
        .collection('weaknessclassgradesubjectdata')
        .doc(selectedDoc)
        .delete()
        .catchError((e) {
      print(e);
    });
  }

  Future<dynamic> uploadProfilePic(File _image) async {
    var firebaseUser = auth.FirebaseAuth.instance.currentUser!.uid;
    firebase_storage.UploadTask task = firebase_storage.FirebaseStorage.instance
        .ref('userProfile/$firebaseUser/$firebaseUser' +
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
        .ref('userProfile/$firebaseUser/$firebaseUser' +
            '${Path.basename(_image.path)}')
        .getDownloadURL();

    List<dynamic> x = [true, downloadURL];
    if (downloadURL != null) {
      return x;
    }
  }

  Future<dynamic> uploadIDCard(File _image) async {
    var firebaseUser = auth.FirebaseAuth.instance.currentUser!.uid;
    firebase_storage.UploadTask task = firebase_storage.FirebaseStorage.instance
        .ref('userSchoolIDCard/$firebaseUser/$firebaseUser' +
            '${Path.basename(_image.path)}')
        .putFile(_image);

    task.snapshotEvents.listen((firebase_storage.TaskSnapshot snapshot) {
      print('Task state: ${snapshot.state}');
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
        .ref('userSchoolIDCard/$firebaseUser/$firebaseUser' +
            '${Path.basename(_image.path)}')
        .getDownloadURL();
    List<dynamic> x = [true, downloadURL];
    if (downloadURL != null) {
      return x;
    }
  }

  Future<dynamic> uploadOCRImage(File _image) async {
    var firebaseUser = auth.FirebaseAuth.instance.currentUser!.uid;
    firebase_storage.UploadTask task = firebase_storage.FirebaseStorage.instance
        .ref('userOCRImage/$firebaseUser/$firebaseUser' +
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
        .ref('userOCRImage/$firebaseUser/$firebaseUser' +
            '${Path.basename(_image.path)}')
        .getDownloadURL();

    List<dynamic> x = [true, downloadURL];
    if (downloadURL != null) {
      return x;
    }
  }

  Future<dynamic> uploadReferenceNotes(File notes) async {
    var firebaseUser = auth.FirebaseAuth.instance.currentUser!.uid;
    firebase_storage.UploadTask task = firebase_storage.FirebaseStorage.instance
        .ref('userNotesReference/$firebaseUser/$firebaseUser' +
            '${Path.basename(notes.path)}')
        .putFile(notes);

    task.snapshotEvents.listen((firebase_storage.TaskSnapshot snapshot) {
      print('Task state: ${snapshot.state}');
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
        .ref('userNotesReference/$firebaseUser/$firebaseUser' +
            '${Path.basename(notes.path)}')
        .getDownloadURL();
    List<dynamic> x = [true, downloadURL];
    if (downloadURL != null) {
      return x;
    }
  }

  Future<dynamic> uploadReferenceAudio(String filePath) async {
    var firebaseUser = auth.FirebaseAuth.instance.currentUser!.uid;
    firebase_storage.UploadTask task = firebase_storage.FirebaseStorage.instance
        .ref('userAudioReference/$firebaseUser/$firebaseUser' +
            '${Path.basename(filePath)}')
        .putFile(File(filePath));

    task.snapshotEvents.listen((firebase_storage.TaskSnapshot snapshot) {
      print('Task state: ${snapshot.state}');
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
        .ref('userAudioReference/$firebaseUser/$firebaseUser' +
            '${Path.basename(filePath)}')
        .getDownloadURL();
    List<dynamic> x = [true, downloadURL];
    if (downloadURL != null) {
      return x;
    }
  }

  Future<dynamic> uploadReferenceVideo(String filePath) async {
    var firebaseUser = auth.FirebaseAuth.instance.currentUser!.uid;
    firebase_storage.UploadTask task = firebase_storage.FirebaseStorage.instance
        .ref('userVideoReference/$firebaseUser/$firebaseUser' +
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
        .ref('userVideoReference/$firebaseUser/$firebaseUser' +
            '${Path.basename(filePath)}')
        .getDownloadURL();
    List<dynamic> x = [true, downloadURL];
    if (downloadURL != null) {
      return x;
    }
  }

  Future<dynamic> uploadAchievement(File _image) async {
    var firebaseUser = auth.FirebaseAuth.instance.currentUser!.uid;
    firebase_storage.UploadTask task = firebase_storage.FirebaseStorage.instance
        .ref('achievement/$firebaseUser/$firebaseUser' +
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
        .ref('achievement/$firebaseUser/$firebaseUser' +
            '${Path.basename(_image.path)}')
        .getDownloadURL();

    List<dynamic> x = [true, downloadURL];
    if (downloadURL != null) {
      return x;
    }
  }
}
