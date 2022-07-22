
// import 'dart:convert';
// SuperUserListModel welcomeFromJson(String str) => SuperUserListModel.fromJson(json.decode(str));

// String welcomeToJson(SuperUserListModel data) => json.encode(data.toJson());

// class SuperUserListModel {
//   SuperUserListModel({
//     this.city,
//     this.firstName,
//     this.grade,
//     this.lastName,
//     this.postId,
//     this.postType,
//     this.profilepic,
//     this.questionerid,
//     this.schoolName,
//     this.suCity,
//     this.suFirstName,
//     this.suGrade,
//     this.suLastName,
//     this.suProfilepic,
//     this.suSchoolName,
//     this.superuserid,
//   });

//   String city;
//   String firstName;
//   int grade;
//   String lastName;
//   String postId;
//   String postType;
//   String profilepic;
//   String questionerid;
//   String schoolName;
//   String suCity;
//   String suFirstName;
//   int suGrade;
//   String suLastName;
//   String suProfilepic;
//   String suSchoolName;
//   String superuserid;

//   factory SuperUserListModel.fromJson(Map<String, dynamic> json) => SuperUserListModel(
//     city: json["city"],
//     firstName: json["first_name"],
//     grade: json["grade"],
//     lastName: json["last_name"],
//     postId: json["post_id"],
//     postType: json["post_type"],
//     profilepic: json["profilepic"],
//     questionerid: json["questionerid"],
//     schoolName: json["school_name"],
//     suCity: json["su_city"],
//     suFirstName: json["su_first_name"],
//     suGrade: json["su_grade"],
//     suLastName: json["su_last_name"],
//     suProfilepic: json["su_profilepic"],
//     suSchoolName: json["su_school_name"],
//     superuserid: json["superuserid"],
//   );

//   Map<String, dynamic> toJson() => {
//     "city": city,
//     "first_name": firstName,
//     "grade": grade,
//     "last_name": lastName,
//     "post_id": postId,
//     "post_type": postType,
//     "profilepic": profilepic,
//     "questionerid": questionerid,
//     "school_name": schoolName,
//     "su_city": suCity,
//     "su_first_name": suFirstName,
//     "su_grade": suGrade,
//     "su_last_name": suLastName,
//     "su_profilepic": suProfilepic,
//     "su_school_name": suSchoolName,
//     "superuserid": superuserid,
//   };
// }
