
// import 'dart:convert';

// import 'package:hys/models/publication_model.dart';


// class SubjectDetailsModel {

//   String subjectImageURL;
//   String subject_;
//   List<PublicationModel> distinct_publication;

// SubjectDetailsModel({this.subjectImageURL,this.subject_,this.distinct_publication});


//   SubjectDetailsModel.fromJson(Map<String, dynamic> data) {

//     var distinctPublicationJson = data['distinct_publication'] !=null ? json.decode(data['distinct_publication']) as List: [];
//     List<PublicationModel> distinctPublicationList = distinctPublicationJson!=null ?distinctPublicationJson.map((tagJson) => PublicationModel.fromJson(tagJson)).toList():<PublicationModel>[];
   
//     subjectImageURL = data['subjectImageURL'];
//     subject_ = data['subject_'];
//     distinct_publication = distinctPublicationList;


//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['subjectImageURL'] = this.subjectImageURL;
//     data['subject_'] = this.subject_;
//     data['distinct_publication'] = json.encode(this.distinct_publication);
 
//     return data;
//   }
// }


