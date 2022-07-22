import 'ans_reply_model.dart';

class AnswerCommentModel {
  AnswerCommentModel(
      {required this.address,
      required this.answerId,
      required this.audioReference,
      required this.board,
      required this.city,
      required this.comment,
      required this.commentId,
      required this.commentType,
      required this.compareDate,
      required this.createdate,
      required this.emailId,
      required this.firstName,
      required this.gender,
      required this.grade,
      required this.image,
      required this.lastName,
      required this.likeCount,
      required this.likeType,
      required this.mobileNo,
      required this.noteReference,
      required this.pdCreatedate,
      required this.pdUserId,
      required this.profilepic,
      required this.questionId,
      required this.replyCount,
      required this.replyList,
      required this.schoolName,
      required this.sdAddress,
      required this.sdCity,
      required this.sdCreatedate,
      required this.sdState,
      required this.sdStreet,
      required this.sdUserId,
      required this.state,
      required this.stream,
      required this.street,
      required this.textReference,
      required this.userDob,
      required this.userId,
      required this.videoReference});

  AnswerCommentModel.a(
      this.address,
      this.answerId,
      this.audioReference,
      this.board,
      this.city,
      this.comment,
      this.commentId,
      this.commentType,
      this.compareDate,
      this.createdate,
      this.emailId,
      this.firstName,
      this.gender,
      this.grade,
      this.image,
      this.lastName,
      this.likeCount,
      this.likeType,
      this.mobileNo,
      this.noteReference,
      this.pdCreatedate,
      this.pdUserId,
      this.profilepic,
      this.questionId,
      this.replyCount,
      this.replyList,
      this.schoolName,
      this.sdAddress,
      this.sdCity,
      this.sdCreatedate,
      this.sdState,
      this.sdStreet,
      this.sdUserId,
      this.state,
      this.stream,
      this.street,
      this.textReference,
      this.userDob,
      this.userId,
      this.videoReference);

  String address;
  String answerId;
  String audioReference;
  String board;
  String city;
  String comment;
  String commentId;
  String commentType;
  String compareDate;
  String createdate;
  String emailId;
  String firstName;
  String gender;
  int grade;
  String image;
  String lastName;
  int likeCount;
  String likeType;
  String mobileNo;
  String noteReference;
  String pdCreatedate;
  String pdUserId;
  String profilepic;
  String questionId;
  int replyCount;
  List<AnsReplyModel> replyList;
  String schoolName;
  String sdAddress;
  String sdCity;
  String sdCreatedate;
  String sdState;
  String sdStreet;
  String sdUserId;
  String state;
  String stream;
  String street;
  String textReference;
  String userDob;
  String userId;
  String videoReference;
  String? reply;
  String? replyId;
  String? replyType;

  factory AnswerCommentModel.fromJson(Map<String, dynamic> json) =>
      AnswerCommentModel(
        address: json["address"],
        answerId: json["answer_id"],
        audioReference:
            json["audio_reference"] == null ? null : json["audio_reference"],
        board: json["board"],
        city: json["city"],
        comment: json["comment"] == null ? null : json["comment"],
        commentId: json["comment_id"],
        commentType: json["comment_type"] == null ? null : json["comment_type"],
        compareDate: json["compare_date"],
        createdate: json["createdate"],
        emailId: json["email_id"],
        firstName: json["first_name"],
        gender: json["gender"],
        grade: json["grade"],
        image: json["image"],
        lastName: json["last_name"],
        likeCount: json["like_count"],
        likeType: json["like_type"],
        mobileNo: json["mobile_no"],
        noteReference:
            json["note_reference"] == null ? null : json["note_reference"],
        pdCreatedate: json["pd.createdate"],
        pdUserId: json["pd.user_id"],
        profilepic: json["profilepic"],
        questionId: json["question_id"],
        replyCount: json["reply_count"] == null ? null : json["reply_count"],
        replyList: json["reply_list"] == null
            ? []
            : List<AnsReplyModel>.from(
                json["reply_list"].map((x) => AnsReplyModel.fromJson(x))),
        schoolName: json["school_name"],
        sdAddress: json["sd.address"],
        sdCity: json["sd.city"],
        sdCreatedate: json["sd.createdate"],
        sdState: json["sd.state"],
        sdStreet: json["sd.street"],
        sdUserId: json["sd.user_id"],
        state: json["state"],
        stream: json["stream"],
        street: json["street"],
        textReference:
            json["text_reference"] == null ? null : json["text_reference"],
        userDob: json["user_dob"],
        userId: json["user_id"],
        videoReference:
            json["video_reference"] == null ? null : json["video_reference"],
      );

  Map<String, dynamic> toJson() => {
        "address": address,
        "answer_id": answerId,
        "audio_reference": audioReference == null ? null : audioReference,
        "board": board,
        "city": city,
        "comment": comment == null ? null : comment,
        "comment_id": commentId,
        "comment_type": commentType == null ? null : commentType,
        "compare_date": compareDate,
        "createdate": createdate,
        "email_id": emailId,
        "first_name": firstName,
        "gender": gender,
        "grade": grade,
        "image": image,
        "last_name": lastName,
        "like_count": likeCount,
        "like_type": likeType,
        "mobile_no": mobileNo,
        "note_reference": noteReference == null ? null : noteReference,
        "pd.createdate": pdCreatedate,
        "pd.user_id": pdUserId,
        "profilepic": profilepic,
        "question_id": questionId,
        "reply_count": replyCount == null ? null : replyCount,
        "reply_list": replyList == null
            ? null
            : List<dynamic>.from(replyList.map((x) => x.toJson())),
        "school_name": schoolName,
        "sd.address": sdAddress,
        "sd.city": sdCity,
        "sd.createdate": sdCreatedate,
        "sd.state": sdState,
        "sd.street": sdStreet,
        "sd.user_id": sdUserId,
        "state": state,
        "stream": stream,
        "street": street,
        "text_reference": textReference == null ? null : textReference,
        "user_dob": userDob,
        "user_id": userId,
        "video_reference": videoReference == null ? null : videoReference,
      };
}
