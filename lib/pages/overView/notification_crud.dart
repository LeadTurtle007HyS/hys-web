import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_database/firebase_database.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:dio/dio.dart';

class NotificationCRUD {
  var dio = Dio();
  final firebaseUser = auth.FirebaseAuth.instance.currentUser!.uid;
  String current_date = DateFormat.yMMMMd('en_US').format(DateTime.now());
  String comparedate = DateFormat('yyyyMMddkkmm').format(DateTime.now());
  final databaseReference = FirebaseDatabase.instance.reference();

  Future<void> createNotification(
      post_id,
      post_type,
      needNotify,
      isClicked,
      receiver_id,
      token,
      message,
      title,
      notify_section,
      notify_function,
      process) async {
    if (receiver_id != firebaseUser) {
      sendNotification([
        'ntf$post_id$firebaseUser$comparedate',
        notify_function,
        notify_section,
        firebaseUser,
        receiver_id,
        token,
        title,
        message,
        post_id,
        post_type,
        isClicked,
        comparedate,
        process == '-' ? "delete" : "add",
        needNotify
      ]);
    }
  }

  Future<bool> sendNotification(List data) async {
    print(data);
    final http.Response response = await http.post(
      Uri.parse('https://hys.today/add_notification_details'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        "Access-Control_Allow_Origin": "*"
      },
      body: jsonEncode(<String, dynamic>{
        "notify_id": data[0],
        "notify_type": data[1],
        "section": data[2],
        "sender_id": data[3],
        "receiver_id": data[4],
        "token": data[5],
        "title": data[6],
        "message": data[7],
        "post_id": data[8],
        "post_type": data[9],
        "is_clicked": data[10],
        "compare_date": data[11],
        "addordelete": data[12]
      }),
    );

    print(response.statusCode);

    if ((response.statusCode == 200) || (response.statusCode == 201)) {
      if (data[12] == 'add' && data[13] == 'yes') {
        final http.Response notification_response = await http.post(
          Uri.parse('https://fcm.googleapis.com/fcm/send'),
          headers: <String, String>{
            'Content-Type': 'application/json',
            "Access-Control_Allow_Origin": "*",
            'Authorization':
                'key=AAAAqaWaBPY:APA91bHQAvw_ld3ulPKtYDICkrOL0bwB0cs3wqak5zfj0n558nYM_qUvA4P_L4dZqAz3Wk2oxnWVnQjmyisYMAz2t9oDmoo_xj0ocMAg8_gzamFlNHf2OffzMuFrW_RhffxKTiAYgjyy'
          },
          body: json.encode({
            'to': data[5],
            'message': {
              'token': data[5],
            },
            "notification": {"title": data[6], "body": data[7]}
          }),
        );
      }
      return true;
    } else {
      return false;
    }
  }

  Future<bool> addFriendInDB(List data) async {
    print(data);
    final http.Response response = await http.post(
      Uri.parse('https://hys.today/add_friend_details'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        "Access-Control_Allow_Origin": "*"
      },
      body: jsonEncode(<String, dynamic>{
        "sender_id": data[0],
        "receiver_id": data[1],
        "following": data[2],
        "friend": data[3],
        "request_sent": data[4],
        "compare_date": data[5]
      }),
    );

    print(response.statusCode);

    if ((response.statusCode == 200) || (response.statusCode == 201)) {
      return true;
    } else {
      return false;
    }
  }

  DataSnapshot? tokenData;
  Future connectToSuperUser(List data) async {
    databaseReference.child("hysweb").once().then((snapshot) async {
      tokenData = snapshot;
      print(data);
      final http.Response response = await http.post(
        Uri.parse('https://hys.today/listing_super_users'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          "Access-Control_Allow_Origin": "*"
        },
        body: jsonEncode(<String, dynamic>{
          "user_id": data[0],
          "grade": data[1],
          "subject": data[2],
          "topic": data[3]
        }),
      );
      print(response.statusCode);
      if ((response.statusCode == 200) || (response.statusCode == 201)) {
        List superuserIdList = json.decode(response.body);
        print(superuserIdList);
        for (int i = 0; i < superuserIdList.length; i++) {
          await sendNotification([
            data[4] + i.toString(),
            data[5],
            data[6],
            data[0],
            superuserIdList[i]["user_id"],
            tokenData!.value["usertoken"][superuserIdList[i]["user_id"]]
                ["tokenid"],
            data[7],
            data[8],
            data[9],
            "false",
            data[11],
            "add",
            "yes"
          ]);
        }
      }
    });
  }
}
