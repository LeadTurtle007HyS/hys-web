// import 'package:cloud_firestore/cloud_firestore.dart';

// class AlbumEpisode{
//   String albumID;
//   String episodeID;
//   String episodeName;
//   String userID;
//   String coverImage;
//   String audioURL;
//   String fileType;


//   AlbumEpisode({this.albumID, this.episodeID,this.episodeName, this.userID,this.coverImage,this.audioURL,this.fileType});

//   AlbumEpisode.fromJson({ DocumentSnapshot<Map<String, dynamic>> json}) {
//     albumID = json.data()['albumID'];
//     episodeID = json.data()['episodeID'];
//     episodeName=json.data()['episodeName'];
//     userID = json.data()['userID'];
//     coverImage=json.data()['coverImage'];
//     audioURL=json.data()['audioURL'];
//     fileType=json.data()['fileType'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['albumID'] = albumID;
//     data['episodeName'] = episodeName;
//     data['userID'] = userID;
//     data['episodeID']=episodeID;
//     data['coverImage']=coverImage;
//     data['audioURL']=audioURL;
//     data['fileType']=fileType;
//     return data;
//   }
// }