import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';

class NotificationCRUD {
  var dio = Dio();

  Future<bool> sendNotification(List data) async {
    print(data);

    final http.Response response = await http.post(
      Uri.parse('https://hys-api.herokuapp.com/web_add_notification_details'),
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
      if (data[12] == 'add') {
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

  Future<bool> updateNotificationDetails(List data) async {
    print(data);
    final http.Response response = await http.post(
      Uri.parse(
          'https://hys-api.herokuapp.com/web_update_notification_details'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        "Access-Control_Allow_Origin": "*"
      },
      body: jsonEncode(<String, dynamic>{"notify_id": data[0]}),
    );
    print(response.statusCode);
    if ((response.statusCode == 200) || (response.statusCode == 201)) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> deleteNotificationDetails(List data) async {
    print(data);
    final http.Response response = await http.post(
      Uri.parse(
          'https://hys-api.herokuapp.com/web_delete_notification_details'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        "Access-Control_Allow_Origin": "*"
      },
      body: jsonEncode(<String, dynamic>{"notify_id": data[0]}),
    );
    print(response.statusCode);
    if ((response.statusCode == 200) || (response.statusCode == 201)) {
      return true;
    } else {
      return false;
    }
  }
}
