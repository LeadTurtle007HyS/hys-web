// import 'package:cloud_firestore/cloud_firestore.dart';

// class AllMessageModel {
//   String chatid;
//   String createdate;
//   bool isblocked;
//   String lastmessage;
//   String lastmessagetime;
//   String otheruserid;
//   String otherusername;
//   String otheruserprofilepic;
//   String userid;
//   String username;
//   String userprofilepic;


//   AllMessageModel({this.chatid, this.createdate, this.isblocked,
//       this.lastmessage, this.lastmessagetime, this.otheruserid,
//       this.otherusername, this.otheruserprofilepic, this.userid, this.username,
//       this.userprofilepic});

//   factory AllMessageModel.fromDocumentSnapshot({ DocumentSnapshot<Map<String, dynamic>> doc}) {
//     return AllMessageModel(
//         chatid: doc.data()["chatid"],
//         createdate: doc.data()["createdate"],
//         isblocked: doc.data()["isblocked"],
//         lastmessage: doc.data()["lastmessage"],
//         lastmessagetime: doc.data()["lastmessagetime"],
//         otheruserid: doc.data()["otheruserid"],
//         otherusername: doc.data()["otherusername"],
//         otheruserprofilepic: doc.data()["otheruserprofilepic"],
//         userid: doc.data()["userid"],
//         username: doc.data()["username"],
//         userprofilepic: doc.data()["userprofilepic"]
//     );
//   }
// }

