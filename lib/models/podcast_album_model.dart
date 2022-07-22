// import 'package:cloud_firestore/cloud_firestore.dart';

// class PodcastAlbumModel{

//   String albumID;
//   String albumName;
//   String userID;
//   String coverImage;
//   bool isPublished;


//   PodcastAlbumModel({this.albumID, this.albumName, this.userID,this.coverImage,this.isPublished});

//   PodcastAlbumModel.fromJson({ DocumentSnapshot<Map<String, dynamic>> json}) {
//     albumID = json.data()['albumID'];
//     albumName = json.data()['albumName'];
//     userID = json.data()['userID'];
//     this.coverImage=json.data()['coverImage'];
//     isPublished=json.data()['isPublished'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['albumID'] = albumID;
//     data['albumName'] = albumName;
//     data['userID'] = userID;
//     data['isPublished']=isPublished;
//     data['coverImage']=coverImage;
//     return data;
//   }

// }