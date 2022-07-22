
// import 'package:hys/models/subject_details_model.dart';

// class GradeDetailsModel {

//   int grade;
//   List<SubjectDetailsModel> distinct_subjects;


 

// GradeDetailsModel({this.grade,this.distinct_subjects});


//   GradeDetailsModel.fromJson(Map<String, dynamic> json) {

//     var distinctPublicationJson = json['distinct_subjects'] as List;
//     List<SubjectDetailsModel> distinctPublicationList = distinctPublicationJson!=null ?distinctPublicationJson.map((tagJson) => SubjectDetailsModel.fromJson(tagJson)).toList():<SubjectDetailsModel>[];
   
//     grade = json['grade'];
//     distinct_subjects =distinctPublicationList;
    


//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['grade'] = this.grade;
//     data['distinct_subjects'] = this.distinct_subjects;
    
//     return data;
//   }
// }


