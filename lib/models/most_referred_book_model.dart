
// import 'package:json_annotation/json_annotation.dart';

// @JsonSerializable(includeIfNull: true)
// class MostReferredBookModel {
//   String chapterName;
//   String chapter_id;
//   String dictionary_id;
//   String first_name;
//   String last_name;
//   String gender;
//   String profilepic;
//   String EPUB_link;
//   String user_id;
  


//   MostReferredBookModel(
//       {this.chapterName,
//       this.chapter_id,
//       this.dictionary_id,
//       this.first_name,
//       this.last_name,
//       this.gender,
//       this.profilepic,
//       this.EPUB_link,
//       this.user_id});

//   MostReferredBookModel.fromJson(Map<String, dynamic> json) {
//     chapterName = json['chapterName'];
//     chapter_id = json['chapter_id'];
//     dictionary_id = json['dictionary_id'];
//     first_name = json['first_name'];
//     last_name = json['last_name'];
//     gender =json['gender'] ;
//     profilepic =json['profilepic'];
//     EPUB_link =json['EPUB_link'];
//     user_id =json['user_id'];    // Map<String, ChapterDetails>.from(json["dictionary_list"]);  
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['chapterName'] = this.chapterName;
//     data['chapter_id'] = this.chapter_id;
//     data['dictionary_id'] = this.dictionary_id;
//     data['gender'] = this.gender;
//     data['first_name'] = this.first_name;
//     data['last_name'] = this.last_name;
//     data['profilepic']=this.profilepic;
//     data['EPUB_link']=this.EPUB_link;
//     data['user_id']=this.user_id;

//     return data;
//   }
// }
