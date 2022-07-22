// import 'package:hys/models/user_personal_data_model.dart';

// class GroupDetails {
//   String chatid;
//   String createdate;
//   List<UserPersonalData> groupmember;
//   List<String> groupmemberid;
//   String groupname;
//   String groupprofile;
//   String lastmessage;
//   String lastmessagetime;
//   String userid;
//   String username;
//   String userprofilepic;

//   GroupDetails(this.chatid, this.createdate, this.groupmember,
//       this.groupmemberid, this.groupname, this.groupprofile, this.lastmessage,
//       this.lastmessagetime, this.userid, this.username, this.userprofilepic);

//   factory GroupDetails.fromJson(dynamic json) {
//     if (json['groupmember'] != null) {
//       var groupmemberJson = json['groupmember'] as List;
//       List<UserPersonalData> groupMemeberList = groupmemberJson.map((tagJson) => UserPersonalData.fromJson(tagJson)).toList();
//       var groupMemeberIDJson = json['groupmemberid'];
//       List<String> tags = groupMemeberIDJson != null ? List.from(groupMemeberIDJson) : null;
//       return GroupDetails(
//         json['chatid'] as String,
//         json['createdate'] as String,
//         groupMemeberList,
//         tags,
//         json['groupname'] as String,
//         json['groupprofile'] as String,
//         json['lastmessage'] as String,
//         json['lastmessagetime'] as String,
//         json['userid'] as String,
//         json['username'] as String,
//         json['userprofilepic'] as String,

//       );
//     } else {
//       return GroupDetails(
//         json['chatid'] as String,
//         json['createdate'] as String,
//         <UserPersonalData>[] ,
//         <String>[],
//         json['groupname'] as String,
//         json['groupprofile'] as String,
//         json['lastmessage'] as String,
//         json['lastmessagetime'] as String,
//         json['userid'] as String,
//         json['username'] as String,
//         json['userprofilepic'] as String,
//       );
//     }
//   }
// }
