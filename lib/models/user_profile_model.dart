import 'dart:convert';

List<ProfileModel> profileModelFromJson(String str) => List<ProfileModel>.from(
    json.decode(str).map((x) => ProfileModel.fromJson(x)));

String profileModelToJson(List<ProfileModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ProfileModel {
  ProfileModel({
    required this.achievements,
    required this.address,
    required this.ambition,
    required this.answerCounts,
    required this.board,
    required this.city,
    required this.dreamVacations,
    required this.emailId,
    required this.firstName,
    required this.gender,
    required this.grade,
    required this.hobbies,
    required this.lastName,
    required this.mobileNo,
    required this.novels,
    required this.placesVisited,
    required this.preferredLanguages,
    required this.privacy,
    required this.profilepic,
    required this.questionCounts,
    required this.schoolAddress,
    required this.schoolCity,
    required this.schoolNme,
    required this.schoolState,
    required this.schoolStreet,
    required this.state,
    required this.stream,
    required this.street,
    required this.strengths,
    required this.uploads,
    required this.userDob,
    required this.userId,
    required this.weakness,
  });

  List<Achievement>? achievements;
  String? address;
  List<Ambition>? ambition;
  List<AnswerCount>? answerCounts;
  String? board;
  String? city;
  List<DreamVacation>? dreamVacations;
  String? emailId;
  String? firstName;
  String? gender;
  int? grade;
  List<Hobby>? hobbies;
  String? lastName;
  String? mobileNo;
  List<Novel>? novels;
  List<PlacesVisited>? placesVisited;
  List<PreferredLanguage>? preferredLanguages;
  List<Privacy>? privacy;
  String? profilepic;
  List<QuestionCount>? questionCounts;
  String? schoolAddress;
  String? schoolCity;
  String? schoolNme;
  String? schoolState;
  String? schoolStreet;
  String? state;
  String? stream;
  String? street;
  List<Strength>? strengths;
  List<Upload>? uploads;
  String? userDob;
  UserId? userId;
  List<Strength>? weakness;

  factory ProfileModel.fromJson(Map<String, dynamic> json) => ProfileModel(
        achievements: List<Achievement>.from(
            json["achievements"].map((x) => Achievement.fromJson(x))),
        address: json["address"],
        ambition: List<Ambition>.from(
            json["ambition"].map((x) => Ambition.fromJson(x))),
        answerCounts: List<AnswerCount>.from(
            json["answer_counts"].map((x) => AnswerCount.fromJson(x))),
        board: json["board"],
        city: json["city"],
        dreamVacations: List<DreamVacation>.from(
            json["dream_vacations"].map((x) => DreamVacation.fromJson(x))),
        emailId: json["email_id"],
        firstName: json["first_name"],
        gender: json["gender"],
        grade: json["grade"],
        hobbies:
            List<Hobby>.from(json["hobbies"].map((x) => Hobby.fromJson(x))),
        lastName: json["last_name"],
        mobileNo: json["mobile_no"],
        novels: List<Novel>.from(json["novels"].map((x) => Novel.fromJson(x))),
        placesVisited: List<PlacesVisited>.from(
            json["places_visited"].map((x) => PlacesVisited.fromJson(x))),
        preferredLanguages: List<PreferredLanguage>.from(
            json["preferred_languages"]
                .map((x) => PreferredLanguage.fromJson(x))),
        privacy:
            List<Privacy>.from(json["privacy"].map((x) => Privacy.fromJson(x))),
        profilepic: json["profilepic"],
        questionCounts: List<QuestionCount>.from(
            json["question_counts"].map((x) => QuestionCount.fromJson(x))),
        schoolAddress: json["school_address"],
        schoolCity: json["school_city"],
        schoolNme: json["school_nme"],
        schoolState: json["school_state"],
        schoolStreet: json["school_street"],
        state: json["state"],
        stream: json["stream"],
        street: json["street"],
        strengths: List<Strength>.from(
            json["strengths"].map((x) => Strength.fromJson(x))),
        uploads:
            List<Upload>.from(json["uploads"].map((x) => Upload.fromJson(x))),
        userDob: json["user_dob"],
        userId: userIdValues.map[json["user_id"]]!,
        weakness: List<Strength>.from(
            json["weakness"].map((x) => Strength.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "achievements":
            List<dynamic>.from(achievements!.map((x) => x.toJson())),
        "address": address,
        "ambition": List<dynamic>.from(ambition!.map((x) => x.toJson())),
        "answer_counts":
            List<dynamic>.from(answerCounts!.map((x) => x.toJson())),
        "board": board,
        "city": city,
        "dream_vacations":
            List<dynamic>.from(dreamVacations!.map((x) => x.toJson())),
        "email_id": emailId,
        "first_name": firstName,
        "gender": gender,
        "grade": grade,
        "hobbies": List<dynamic>.from(hobbies!.map((x) => x.toJson())),
        "last_name": lastName,
        "mobile_no": mobileNo,
        "novels": List<dynamic>.from(novels!.map((x) => x.toJson())),
        "places_visited":
            List<dynamic>.from(placesVisited!.map((x) => x.toJson())),
        "preferred_languages":
            List<dynamic>.from(preferredLanguages!.map((x) => x.toJson())),
        "privacy": List<dynamic>.from(privacy!.map((x) => x.toJson())),
        "profilepic": profilepic,
        "question_counts":
            List<dynamic>.from(questionCounts!.map((x) => x.toJson())),
        "school_address": schoolAddress,
        "school_city": schoolCity,
        "school_nme": schoolNme,
        "school_state": schoolState,
        "school_street": schoolStreet,
        "state": state,
        "stream": stream,
        "street": street,
        "strengths": List<dynamic>.from(strengths!.map((x) => x.toJson())),
        "uploads": List<dynamic>.from(uploads!.map((x) => x.toJson())),
        "user_dob": userDob,
        "user_id": userIdValues.reverse[userId],
        "weakness": List<dynamic>.from(weakness!.map((x) => x.toJson())),
      };
}

class Achievement {
  Achievement({
    required this.achDescription,
    required this.achImageUrl,
    required this.achTitle,
    required this.achType,
    required this.achievementId,
    required this.compareDate,
    required this.createdate,
    required this.scorecardBoardName,
    required this.scorecardDetails,
    required this.scorecardGrade,
    required this.scorecardSchoolName,
    required this.scorecardTotalScore,
    required this.userId,
  });

  String achDescription;
  String achImageUrl;
  String achTitle;
  String achType;
  String achievementId;
  String compareDate;
  String createdate;
  String scorecardBoardName;
  List<ScorecardDetail> scorecardDetails;
  String scorecardGrade;
  String scorecardSchoolName;
  String scorecardTotalScore;
  UserId userId;

  factory Achievement.fromJson(Map<String, dynamic> json) => Achievement(
        achDescription: json["ach_description"],
        achImageUrl: json["ach_image_url"],
        achTitle: json["ach_title"],
        achType: json["ach_type"],
        achievementId: json["achievement_id"],
        compareDate: json["compare_date"],
        createdate: json["createdate"],
        scorecardBoardName: json["scorecard_board_name"],
        scorecardDetails: List<ScorecardDetail>.from(
            json["scorecard_details"].map((x) => ScorecardDetail.fromJson(x))),
        scorecardGrade: json["scorecard_grade"],
        scorecardSchoolName: json["scorecard_school_name"],
        scorecardTotalScore: json["scorecard_total_score"],
        userId: userIdValues.map[json["user_id"]]!,
      );

  Map<String, dynamic> toJson() => {
        "ach_description": achDescription,
        "ach_image_url": achImageUrl,
        "ach_title": achTitle,
        "ach_type": achType,
        "achievement_id": achievementId,
        "compare_date": compareDate,
        "createdate": createdate,
        "scorecard_board_name": scorecardBoardName,
        "scorecard_details":
            List<dynamic>.from(scorecardDetails.map((x) => x.toJson())),
        "scorecard_grade": scorecardGrade,
        "scorecard_school_name": scorecardSchoolName,
        "scorecard_total_score": scorecardTotalScore,
        "user_id": userIdValues.reverse[userId],
      };
}

class ScorecardDetail {
  ScorecardDetail({
    required this.achievementId,
    required this.createdate,
    required this.marks,
    required this.subject,
    required this.userId,
  });

  String achievementId;
  String createdate;
  String marks;
  String subject;
  UserId userId;

  factory ScorecardDetail.fromJson(Map<String, dynamic> json) =>
      ScorecardDetail(
        achievementId: json["achievement_id"],
        createdate: json["createdate"],
        marks: json["marks"],
        subject: json["subject"],
        userId: userIdValues.map[json["user_id"]]!,
      );

  Map<String, dynamic> toJson() => {
        "achievement_id": achievementId,
        "createdate": createdate,
        "marks": marks,
        "subject": subject,
        "user_id": userIdValues.reverse[userId],
      };
}

enum UserId { J1_W_TH_GZ_ZBD_QNPB_KOU_CU6_X_FE_ZZOG2 }

final userIdValues = EnumValues({
  "J1WThGzZBDQnpbKouCu6xFeZzog2": UserId.J1_W_TH_GZ_ZBD_QNPB_KOU_CU6_X_FE_ZZOG2
});

class Ambition {
  Ambition({
    required this.createdate,
    required this.userAmbition,
    required this.userId,
  });

  String createdate;
  String userAmbition;
  UserId userId;

  factory Ambition.fromJson(Map<String, dynamic> json) => Ambition(
        createdate: json["createdate"],
        userAmbition: json["user_ambition"],
        userId: userIdValues.map[json["user_id"]]!,
      );

  Map<String, dynamic> toJson() => {
        "createdate": createdate,
        "user_ambition": userAmbition,
        "user_id": userIdValues.reverse[userId],
      };
}

class AnswerCount {
  AnswerCount({
    this.grade,
    this.subject,
    this.totalAnswers,
  });

  int? grade;
  String? subject;
  int? totalAnswers;

  factory AnswerCount.fromJson(Map<String, dynamic> json) => AnswerCount(
        grade: json["grade"],
        subject: json["subject"],
        totalAnswers: json["total_answers"],
      );

  Map<String, dynamic> toJson() => {
        "grade": grade,
        "subject": subject,
        "total_answers": totalAnswers,
      };
}

class DreamVacation {
  DreamVacation({
    this.createdate,
    this.userDreamVacations,
    this.userId,
  });

  String? createdate;
  String? userDreamVacations;
  UserId? userId;

  factory DreamVacation.fromJson(Map<String, dynamic> json) => DreamVacation(
        createdate: json["createdate"],
        userDreamVacations: json["user_dream_vacations"],
        userId: userIdValues.map[json["user_id"]],
      );

  Map<String, dynamic> toJson() => {
        "createdate": createdate,
        "user_dream_vacations": userDreamVacations,
        "user_id": userIdValues.reverse[userId],
      };
}

class Hobby {
  Hobby({
    this.createdate,
    this.userHobbies,
    this.userId,
  });

  String? createdate;
  String? userHobbies;
  UserId? userId;

  factory Hobby.fromJson(Map<String, dynamic> json) => Hobby(
        createdate: json["createdate"],
        userHobbies: json["user_hobbies"],
        userId: userIdValues.map[json["user_id"]],
      );

  Map<String, dynamic> toJson() => {
        "createdate": createdate,
        "user_hobbies": userHobbies,
        "user_id": userIdValues.reverse[userId],
      };
}

class Novel {
  Novel({
    this.createdate,
    this.userId,
    this.userNovelsRead,
  });

  String? createdate;
  UserId? userId;
  String? userNovelsRead;

  factory Novel.fromJson(Map<String, dynamic> json) => Novel(
        createdate: json["createdate"],
        userId: userIdValues.map[json["user_id"]],
        userNovelsRead: json["user_novels_read"],
      );

  Map<String, dynamic> toJson() => {
        "createdate": createdate,
        "user_id": userIdValues.reverse[userId],
        "user_novels_read": userNovelsRead,
      };
}

class PlacesVisited {
  PlacesVisited({
    this.createdate,
    this.userId,
    this.userPlaceVisited,
  });

  String? createdate;
  UserId? userId;
  String? userPlaceVisited;

  factory PlacesVisited.fromJson(Map<String, dynamic> json) => PlacesVisited(
        createdate: json["createdate"],
        userId: userIdValues.map[json["user_id"]],
        userPlaceVisited: json["user_place_visited"],
      );

  Map<String, dynamic> toJson() => {
        "createdate": createdate,
        "user_id": userIdValues.reverse[userId],
        "user_place_visited": userPlaceVisited,
      };
}

class PreferredLanguage {
  PreferredLanguage({
    this.preferredLang,
  });

  String? preferredLang;

  factory PreferredLanguage.fromJson(Map<String, dynamic> json) =>
      PreferredLanguage(
        preferredLang: json["preferred_lang"],
      );

  Map<String, dynamic> toJson() => {
        "preferred_lang": preferredLang,
      };
}

class Privacy {
  Privacy({
    this.address,
    this.ambition,
    this.compareDate,
    this.createdate,
    this.dreamvacations,
    this.email,
    this.friends,
    this.hobbies,
    this.privacyLibrary,
    this.mobileno,
    this.mygroups,
    this.novels,
    this.placesvisited,
    this.schooladdress,
    this.scorecards,
    this.uploads,
    this.userId,
    this.weakness,
  });

  int? address;
  int? ambition;
  String? compareDate;
  String? createdate;
  int? dreamvacations;
  int? email;
  int? friends;
  int? hobbies;
  int? privacyLibrary;
  int? mobileno;
  int? mygroups;
  int? novels;
  int? placesvisited;
  int? schooladdress;
  int? scorecards;
  int? uploads;
  UserId? userId;
  int? weakness;

  factory Privacy.fromJson(Map<String, dynamic> json) => Privacy(
        address: json["address"],
        ambition: json["ambition"],
        compareDate: json["compare_date"],
        createdate: json["createdate"],
        dreamvacations: json["dreamvacations"],
        email: json["email"],
        friends: json["friends"],
        hobbies: json["hobbies"],
        privacyLibrary: json["library"],
        mobileno: json["mobileno"],
        mygroups: json["mygroups"],
        novels: json["novels"],
        placesvisited: json["placesvisited"],
        schooladdress: json["schooladdress"],
        scorecards: json["scorecards"],
        uploads: json["uploads"],
        userId: userIdValues.map[json["user_id"]],
        weakness: json["weakness"],
      );

  Map<String, dynamic> toJson() => {
        "address": address,
        "ambition": ambition,
        "compare_date": compareDate,
        "createdate": createdate,
        "dreamvacations": dreamvacations,
        "email": email,
        "friends": friends,
        "hobbies": hobbies,
        "library": privacyLibrary,
        "mobileno": mobileno,
        "mygroups": mygroups,
        "novels": novels,
        "placesvisited": placesvisited,
        "schooladdress": schooladdress,
        "scorecards": scorecards,
        "uploads": uploads,
        "user_id": userIdValues.reverse[userId],
        "weakness": weakness,
      };
}

class QuestionCount {
  QuestionCount({
    this.grade,
    this.subject,
    this.totalQuestions,
  });

  int? grade;
  String? subject;
  int? totalQuestions;

  factory QuestionCount.fromJson(Map<String, dynamic> json) => QuestionCount(
        grade: json["grade"],
        subject: json["subject"],
        totalQuestions: json["total_questions"],
      );

  Map<String, dynamic> toJson() => {
        "grade": grade,
        "subject": subject,
        "total_questions": totalQuestions,
      };
}

class Strength {
  Strength({
    this.createdate,
    this.grade,
    this.subject,
    this.topic,
    this.userId,
  });

  String? createdate;
  int? grade;
  String? subject;
  String? topic;
  UserId? userId;

  factory Strength.fromJson(Map<String, dynamic> json) => Strength(
        createdate: json["createdate"],
        grade: json["grade"],
        subject: json["subject"],
        topic: json["topic"],
        userId: userIdValues.map[json["user_id"]],
      );

  Map<String, dynamic> toJson() => {
        "createdate": createdate,
        "grade": grade,
        "subject": subject,
        "topic": topic,
        "user_id": userIdValues.reverse[userId],
      };
}

class Upload {
  Upload({
    this.chapter,
    this.compareDate,
    this.createdate,
    this.description,
    this.examName,
    this.fdCreatedate,
    this.fdUploadId,
    this.fileExt,
    this.fileName,
    this.fileUrl,
    this.grade,
    this.schoolName,
    this.subject,
    this.tags,
    this.term,
    this.topic,
    this.uploadId,
    this.uploadType,
    this.userId,
    this.year,
  });

  String? chapter;
  String? compareDate;
  String? createdate;
  String? description;
  String? examName;
  String? fdCreatedate;
  String? fdUploadId;
  String? fileExt;
  String? fileName;
  String? fileUrl;
  String? grade;
  String? schoolName;
  String? subject;
  String? tags;
  String? term;
  String? topic;
  String? uploadId;
  String? uploadType;
  UserId? userId;
  String? year;

  factory Upload.fromJson(Map<String, dynamic> json) => Upload(
        chapter: json["chapter"],
        compareDate: json["compare_date"],
        createdate: json["createdate"],
        description: json["description"],
        examName: json["exam_name"],
        fdCreatedate: json["fd.createdate"],
        fdUploadId: json["fd.upload_id"],
        fileExt: json["file_ext"],
        fileName: json["file_name"],
        fileUrl: json["file_url"],
        grade: json["grade"],
        schoolName: json["school_name"],
        subject: json["subject"],
        tags: json["tags"],
        term: json["term"],
        topic: json["topic"],
        uploadId: json["upload_id"],
        uploadType: json["upload_type"],
        userId: userIdValues.map[json["user_id"]],
        year: json["year"],
      );

  Map<String, dynamic> toJson() => {
        "chapter": chapter,
        "compare_date": compareDate,
        "createdate": createdate,
        "description": description,
        "exam_name": examName,
        "fd.createdate": fdCreatedate,
        "fd.upload_id": fdUploadId,
        "file_ext": fileExt,
        "file_name": fileName,
        "file_url": fileUrl,
        "grade": grade,
        "school_name": schoolName,
        "subject": subject,
        "tags": tags,
        "term": term,
        "topic": topic,
        "upload_id": uploadId,
        "upload_type": uploadType,
        "user_id": userIdValues.reverse[userId],
        "year": year,
      };
}

class EnumValues<T> {
  Map<String, T> map;
  Map<T, String>? reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    if (reverseMap == null) {
      reverseMap = map.map((k, v) => new MapEntry(v, k));
    }
    return reverseMap!;
  }
}
