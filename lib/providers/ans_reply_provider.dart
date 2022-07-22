// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:hys/models/ans_reply_model.dart';

// import '../QuestionFeed/dataload_crud.dart';
// import '../database/question_answer_repository.dart';
// import '../models/answer_comment_model.dart';
// import '../models/network_request_genric.dart';
// import '../notification/notificationDB.dart';

// NotificationDB notificationDB = NotificationDB();
// DataLoadCRUD dataLoadCRUD = DataLoadCRUD();

// class AnsReplyProvider extends ChangeNotifier {
//   QuestionAnswerRepository _ansReplyRepository;
//   ApiResponse<List<AnsReplyModel>> _replyList;
//   ApiResponse<List<AnsReplyModel>> get replyList => _replyList;
//   AnswerCommentModel _commentPost;
//   AnswerCommentModel get commentPost => _commentPost;
//   String _currentUserId;

//   AnsReplyProvider() {
//     _currentUserId = FirebaseAuth.instance.currentUser.uid;
//     _replyList = ApiResponse.loading("Loading");
//     _ansReplyRepository = QuestionAnswerRepository();
//   }

//   void setCommentModel(AnswerCommentModel commentModel) {
//     this._commentPost = commentModel;
//   }

//   fetchAnsReplyList(String cmntId) async {
//     _replyList = ApiResponse.loading('Loading');
//     await Future.delayed(Duration(milliseconds: 1));
//     notifyListeners();
//     try {
//       List<AnsReplyModel> feedList = await _ansReplyRepository
//           .fetchAllPostedAnsReply(_currentUserId, cmntId);
//       _replyList = ApiResponse.completed(
//           feedList.length > 0 ? feedList : <AnsReplyModel>[]);
//       notifyListeners();
//     } catch (e) {
//       _replyList = ApiResponse.error(e.toString());
//       notifyListeners();
//     }
//   }

//   updateReplyLikeDetails(AnsReplyModel replyPost, String likeType,
//       String tokenValue, String notifyTitle, String notifyMesssage) {
//     if (replyPost.likeType == "") {
//       dataLoadCRUD.updateAnswerReplyCountData(
//           [replyPost.replyId, _currentUserId, replyPost.likeCount + 1]);
//       replyPost.likeType = 'like';
//       replyPost.likeCount++;
//       ////////////////////////////notification//////////////////////////////////////
//       notificationDB.createNotification(
//           replyPost.replyId,
//           "reply",
//           "yes",
//           "false",
//           replyPost.userId,
//           tokenValue,
//           notifyMesssage,
//           notifyTitle,
//           "reply",
//           "reaction",
//           "+");
//     } else {
//       dataLoadCRUD.updateAnswerReplyCountData(
//           [replyPost.replyId, _currentUserId, replyPost.likeCount - 1]);
//       replyPost.likeType = '';
//       replyPost.likeCount--;
//       ////////////////////////////notification//////////////////////////////////////
//       notificationDB.createNotification(
//           replyPost.replyId,
//           "reply",
//           "yes",
//           "false",
//           replyPost.userId,
//           tokenValue,
//           notifyMesssage,
//           notifyTitle,
//           "reply",
//           "reaction",
//           "-");
//     }
//     notifyListeners();
//   }
// }
