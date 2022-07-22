// To parse this JSON data, do
//
//     final qReactionModel = qReactionModelFromJson(jsonString);

import 'dart:convert';

QReactionModel qReactionModelFromJson(String str) =>
    QReactionModel.fromJson(json.decode(str));

String qReactionModelToJson(QReactionModel data) => json.encode(data.toJson());

class QReactionModel {
  QReactionModel({
    this.board,
    this.city,
    this.firstName,
    this.gender,
    this.grade,
    this.lastName,
    this.likeType,
    this.profilepic,
    this.questionId,
    this.schoolName,
    this.userId,
  });

  String? board;
  String? city;
  String? firstName;
  String? gender;
  int? grade;
  String? lastName;
  String? likeType;
  String? profilepic;
  String? questionId;
  String? schoolName;
  String? userId;

  factory QReactionModel.fromJson(Map<String, dynamic> json) => QReactionModel(
        board: json["board"],
        city: json["city"],
        firstName: json["first_name"],
        gender: json["gender"],
        grade: json["grade"],
        lastName: json["last_name"],
        likeType: json["like_type"],
        profilepic: json["profilepic"],
        questionId: json["question_id"],
        schoolName: json["school_name"],
        userId: json["user_id"],
      );

  Map<String, dynamic> toJson() => {
        "board": board,
        "city": city,
        "first_name": firstName,
        "gender": gender,
        "grade": grade,
        "last_name": lastName,
        "like_type": likeType,
        "profilepic": profilepic,
        "question_id": questionId,
        "school_name": schoolName,
        "user_id": userId,
      };
}
