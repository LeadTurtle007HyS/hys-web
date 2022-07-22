import 'dart:convert';

List<AnsReplyModel> ansReplyModelFromJson(String str) =>
    List<AnsReplyModel>.from(
        json.decode(str).map((x) => AnsReplyModel.fromJson(x)));

String ansReplyModelToJson(List<AnsReplyModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class AnsReplyModel {
  AnsReplyModel({
    required this.answerId,
    required this.city,
    required this.commentId,
    required this.compareDate,
    required this.firstName,
    required this.grade,
    required this.image,
    required this.lastName,
    required this.likeCount,
    required this.likeType,
    required this.profilepic,
    required this.questionId,
    required this.reply,
    required this.replyId,
    required this.replyType,
    required this.schoolName,
    required this.userId,
  });

  String answerId;
  String city;
  String commentId;
  String compareDate;
  String firstName;
  int grade;
  String image;
  String lastName;
  int likeCount;
  String likeType;
  String profilepic;
  String questionId;
  String reply;
  String replyId;
  String replyType;
  String schoolName;
  String userId;

  factory AnsReplyModel.fromJson(Map<String, dynamic> json) => AnsReplyModel(
        answerId: json["answer_id"],
        city: json["city"],
        commentId: json["comment_id"],
        compareDate: json["compare_date"],
        firstName: json["first_name"],
        grade: json["grade"],
        image: json["image"],
        lastName: json["last_name"],
        likeCount: json["like_count"],
        likeType: json["like_type"],
        profilepic: json["profilepic"],
        questionId: json["question_id"],
        reply: json["reply"],
        replyId: json["reply_id"],
        replyType: json["reply_type"],
        schoolName: json["school_name"],
        userId: json["user_id"],
      );

  Map<String, dynamic> toJson() => {
        "answer_id": answerId,
        "city": city,
        "comment_id": commentId,
        "compare_date": compareDate,
        "first_name": firstName,
        "grade": grade,
        "image": image,
        "last_name": lastName,
        "like_count": likeCount,
        "like_type": likeType,
        "profilepic": profilepic,
        "question_id": questionId,
        "reply": reply,
        "reply_id": replyId,
        "reply_type": replyType,
        "school_name": schoolName,
        "user_id": userId,
      };
}
