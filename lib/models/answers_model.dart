// To parse this JSON data, do
//
//     final answerModel = answerModelFromJson(jsonString);

import 'dart:convert';

import 'answer_comment_model.dart';

List<AnswerModel> answerModelFromJson(String str) => List<AnswerModel>.from(
    json.decode(str).map((x) => AnswerModel.fromJson(x)));

String answerModelToJson(List<AnswerModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class AnswerModel {
  AnswerModel({
    required this.answer,
    required this.answerLikeButton,
    required this.answerId,
    required this.answerType,
    required this.audioReference,
    required this.city,
    required this.commentCount,
    required this.commentList,
    required this.compareDate,
    required this.downvoteCount,
    required this.firstName,
    required this.grade,
    required this.image,
    required this.lastName,
    required this.likeCount,
    required this.likeType,
    required this.noteReference,
    required this.profilepic,
    required this.questionId,
    required this.schoolName,
    required this.textReference,
    required this.upvoteCount,
    required this.userId,
    required this.videoReference,
    required this.voteType,
  });

  String answer;
  String answerLikeButton;
  String answerId;
  String answerType;
  String audioReference;
  String city;
  int commentCount;
  List<AnswerCommentModel> commentList;
  String compareDate;
  int downvoteCount;
  String firstName;
  int grade;
  String image;
  String lastName;
  int likeCount;
  String likeType;
  String noteReference;
  String profilepic;
  String questionId;
  String schoolName;
  String textReference;
  int upvoteCount;
  String userId;
  String videoReference;
  String voteType;

  factory AnswerModel.fromJson(Map<String, dynamic> json) => AnswerModel(
        answer: json["answer"],
        answerLikeButton: json["answerLikeButton"],
        answerId: json["answer_id"],
        answerType: json["answer_type"],
        audioReference: json["audio_reference"],
        city: json["city"],
        commentCount: json["comment_count"],
        commentList: List<AnswerCommentModel>.from(
            json["comment_list"].map((x) => AnswerCommentModel.fromJson(x))),
        compareDate: json["compare_date"],
        downvoteCount: json["downvote_count"],
        firstName: json["first_name"],
        grade: json["grade"],
        image: json["image"],
        lastName: json["last_name"],
        likeCount: json["like_count"],
        likeType: json["like_type"],
        noteReference: json["note_reference"],
        profilepic: json["profilepic"],
        questionId: json["question_id"],
        schoolName: json["school_name"],
        textReference: json["text_reference"],
        upvoteCount: json["upvote_count"],
        userId: json["user_id"],
        videoReference: json["video_reference"],
        voteType: json["vote_type"],
      );

  Map<String, dynamic> toJson() => {
        "answer": answer,
        "answerLikeButton": answerLikeButton,
        "answer_id": answerId,
        "answer_type": answerType,
        "audio_reference": audioReference,
        "city": city,
        "comment_count": commentCount,
        "comment_list": List<dynamic>.from(commentList.map((x) => x.toJson())),
        "compare_date": compareDate,
        "downvote_count": downvoteCount,
        "first_name": firstName,
        "grade": grade,
        "image": image,
        "last_name": lastName,
        "like_count": likeCount,
        "like_type": likeType,
        "note_reference": noteReference,
        "profilepic": profilepic,
        "question_id": questionId,
        "school_name": schoolName,
        "text_reference": textReference,
        "upvote_count": upvoteCount,
        "user_id": userId,
        "video_reference": videoReference,
        "vote_type": voteType,
      };
}
