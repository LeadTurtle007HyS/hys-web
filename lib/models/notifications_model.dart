// To parse this JSON data, do
//
//     final notificationModel = notificationModelFromJson(jsonString);

import 'dart:convert';

List<NotificationModel> notificationModelFromJson(String str) =>
    List<NotificationModel>.from(
        json.decode(str).map((x) => NotificationModel.fromJson(x)));

String notificationModelToJson(List<NotificationModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class NotificationModel {
  NotificationModel({
    required this.address,
    required this.board,
    required this.city,
    required this.compareDate,
    required this.createdate,
    required this.emailId,
    required this.firstName,
    required this.gender,
    required this.grade,
    required this.isClicked,
    required this.lastName,
    required this.message,
    required this.mobileNo,
    required this.notifyId,
    required this.notifyType,
    required this.pdCreatedate,
    required this.postId,
    required this.postType,
    required this.profilepic,
    required this.receiverId,
    required this.schoolName,
    required this.sdAddress,
    required this.sdCity,
    required this.sdCreatedate,
    required this.sdState,
    required this.sdStreet,
    required this.sdUserId,
    required this.section,
    required this.senderId,
    required this.state,
    required this.stream,
    required this.street,
    required this.title,
    required this.token,
    required this.userDob,
    required this.userId,
  });

  String address;
  String board;
  String city;
  String compareDate;
  String createdate;
  String emailId;
  String firstName;
  String gender;
  int grade;
  String isClicked;
  String lastName;
  String message;
  String mobileNo;
  String notifyId;
  String notifyType;
  String pdCreatedate;
  String postId;
  String postType;
  String profilepic;
  String receiverId;
  String schoolName;
  String sdAddress;
  String sdCity;
  String sdCreatedate;
  String sdState;
  String sdStreet;
  String sdUserId;
  String section;
  String senderId;
  String state;
  String stream;
  String street;
  String title;
  String token;
  String userDob;
  String userId;

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      NotificationModel(
        address: json["address"],
        board: json["board"],
        city: json["city"],
        compareDate: json["compare_date"],
        createdate: json["createdate"],
        emailId: json["email_id"],
        firstName: json["first_name"],
        gender: json["gender"],
        grade: json["grade"],
        isClicked: json["is_clicked"],
        lastName: json["last_name"],
        message: json["message"],
        mobileNo: json["mobile_no"],
        notifyId: json["notify_id"],
        notifyType: json["notify_type"],
        pdCreatedate: json["pd.createdate"],
        postId: json["post_id"],
        postType: json["post_type"],
        profilepic: json["profilepic"],
        receiverId: json["receiver_id"],
        schoolName: json["school_name"],
        sdAddress: json["sd.address"],
        sdCity: json["sd.city"],
        sdCreatedate: json["sd.createdate"],
        sdState: json["sd.state"],
        sdStreet: json["sd.street"],
        sdUserId: json["sd.user_id"],
        section: json["section"],
        senderId: json["sender_id"],
        state: json["state"],
        stream: json["stream"],
        street: json["street"],
        title: json["title"],
        token: json["token"],
        userDob: json["user_dob"],
        userId: json["user_id"],
      );

  Map<String, dynamic> toJson() => {
        "address": address,
        "board": board,
        "city": city,
        "compare_date": compareDate,
        "createdate": createdate,
        "email_id": emailId,
        "first_name": firstName,
        "gender": gender,
        "grade": grade,
        "is_clicked": isClicked,
        "last_name": lastName,
        "message": message,
        "mobile_no": mobileNo,
        "notify_id": notifyId,
        "notify_type": notifyType,
        "pd.createdate": pdCreatedate,
        "post_id": postId,
        "post_type": postType,
        "profilepic": profilepic,
        "receiver_id": receiverId,
        "school_name": schoolName,
        "sd.address": sdAddress,
        "sd.city": sdCity,
        "sd.createdate": sdCreatedate,
        "sd.state": sdState,
        "sd.street": sdStreet,
        "sd.user_id": sdUserId,
        "section": section,
        "sender_id": senderId,
        "state": state,
        "stream": stream,
        "street": street,
        "title": title,
        "token": token,
        "user_dob": userDob,
        "user_id": userId,
      };
}
