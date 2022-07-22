
// import 'package:json_annotation/json_annotation.dart';

// @JsonSerializable(includeIfNull: true)
// class ChapterModel {
//   String createdate;
//   String dictionary_id;
//   String grade;
//   String pub_edition;

//   String publication;
//   String subject_;

//   @JsonKey(name: 'dictionary_list')
//   var dictionary_list;

//   ChapterModel(
//       {this.createdate,
//       this.dictionary_id,
//       this.grade,
//       this.pub_edition,
//       this.publication,
//       this.subject_,
//       this.dictionary_list});

//   ChapterModel.fromJson(Map<String, dynamic> json) {
//     createdate = json['createdate'];
//     dictionary_id = json['dictionary_id'];
//     grade = json['grade'];
//     pub_edition = json['pub_edition'];

//     publication = json['publication'];
//     subject_ = json['subject_'];
//     dictionary_list =json['dictionary_list'] ;    // Map<String, ChapterDetails>.from(json["dictionary_list"]);  
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['createdate'] = this.createdate;
//     data['dictionary_id'] = this.dictionary_id;
//     data['grade'] = this.grade;
//     data['pub_edition'] = this.pub_edition;

//     data['publication'] = this.publication;
//     data['subject_'] = this.subject_;
//     data['dictionary_list'] = this.dictionary_list;

//     return data;
//   }
// }
