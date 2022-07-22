// import 'package:json_annotation/json_annotation.dart';

// @JsonSerializable(includeIfNull: true)
// class ChapterDetails {
//   String chapterImageURL;
//   String embeddings;
//   String epub;
//   String text;

//   ChapterDetails({this.chapterImageURL,this.embeddings,this.epub,this.text});

//   ChapterDetails.fromJson(Map<String, dynamic> json) {
   
//     chapterImageURL = json['chapterImageURL'];
//     embeddings =json['embeddings'];
//       epub = json['epub'];
//     text =json['text'];
    


//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['chapterImageURL'] = this.chapterImageURL;
//     data['embeddings'] = this.embeddings;
//      data['epub'] = this.epub;
//     data['text'] = this.text;
    
//     return data;
//   }
// }