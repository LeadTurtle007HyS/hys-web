
// import 'package:json_annotation/json_annotation.dart';

// @JsonSerializable(includeIfNull: true)
// class PreQuestionPaperModel {
//   String board;
//   String createdate;
//   String dictionary_id;
//   String grade;
//   String subject_;

//   @JsonKey(name: 'dictionary_list')
//   var dictionary_list;

//   PreQuestionPaperModel(
//       {this.board,
//       this.createdate,
//       this.dictionary_id,
//       this.grade,
//       this.subject_,
//       this.dictionary_list});

//   PreQuestionPaperModel.fromJson(Map<String, dynamic> json) {
//     board = json['board'];
//     createdate = json['createdate'];
//     dictionary_id = json['dictionary_id'];
//     grade = json['grade'];
//     subject_ = json['subject_'];
//     dictionary_list =json['dictionary_list'] ;    // Map<String, ChapterDetails>.from(json["dictionary_list"]);  
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['board'] = this.board;
//     data['createdate'] = this.createdate;
//     data['grade'] = this.dictionary_id;
//     data['grade'] = this.grade;
//     data['subject_'] = this.subject_;
//     data['dictionary_list'] = this.dictionary_list;

//     return data;
//   }
// }
