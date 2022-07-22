// // To parse this JSON data, do
// //
// //     final welcome = welcomeFromJson(jsonString);

// import 'dart:convert';

// ReferredBookByFriend welcomeFromJson(String str) => ReferredBookByFriend.fromJson(json.decode(str));

// String welcomeToJson(ReferredBookByFriend data) => json.encode(data.toJson());

// class ReferredBookByFriend {
//   ReferredBookByFriend({
//     this.epubLink,
//     this.chapterName,
//     this.chapterId,
//     this.dictionaryId,
//     this.firstName,
//     this.gender,
//     this.lastName,
//     this.profilepic,
//     this.userId,
//   });

//   String epubLink;
//   String chapterName;
//   String chapterId;
//   String dictionaryId;
//   String firstName;
//   String gender;
//   String lastName;
//   String profilepic;
//   String userId;

//   factory ReferredBookByFriend.fromJson(Map<String, dynamic> json) => ReferredBookByFriend(
//     epubLink: json["EPUB_link"],
//     chapterName: json["chapterName"],
//     chapterId: json["chapter_id"],
//     dictionaryId: json["dictionary_id"],
//     firstName: json["first_name"],
//     gender: json["gender"],
//     lastName: json["last_name"],
//     profilepic: json["profilepic"],
//     userId: json["user_id"],
//   );

//   Map<String, dynamic> toJson() => {
//     "EPUB_link": epubLink,
//     "chapterName": chapterName,
//     "chapter_id": chapterId,
//     "dictionary_id": dictionaryId,
//     "first_name": firstName,
//     "gender": gender,
//     "last_name": lastName,
//     "profilepic": profilepic,
//     "user_id": userId,
//   };
// }
