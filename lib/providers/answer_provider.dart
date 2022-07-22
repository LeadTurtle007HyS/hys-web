// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';

// import '../QuestionFeed/dataload_crud.dart';
// import '../database/questionSection/questionModel.dart';
// import '../database/question_answer_repository.dart';
// import '../models/answer_comment_model.dart';
// import '../models/answers_model.dart';
// import '../models/network_request_genric.dart';
// import '../notification/notificationDB.dart';

// NotificationDB notificationDB = NotificationDB();
// DataLoadCRUD dataLoadCRUD = DataLoadCRUD();

// class AnswerProvider extends ChangeNotifier {
//   QuestionAnswerRepository _answerRepository;
//   ApiResponse<List<AnswerModel>> _answerList;
//   ApiResponse<List<AnswerModel>> get answerList => _answerList;

//   Questions questionPost;
//   String _currentUserId;
//   bool _qlikebutton = false;

//   bool get qlikebutton => _qlikebutton;

//   AnswerProvider() {
//     _currentUserId = FirebaseAuth.instance.currentUser.uid;
//     _answerList = ApiResponse.loading("Loading");
//     _answerRepository = QuestionAnswerRepository();
//   }
//   ////////////////////////////Questions//////////////////////////////////////
//   questionLikePopupHide() {
//     _qlikebutton = false;
//   }

//   questionLikePopupShow() {
//     _qlikebutton = true;
//   }

//   Questions get questions {
//     return questionPost;
//   }

//   void setQuestionModel(Questions questionModel) {
//     this.questionPost = questionModel;
//   }

//   ////////////////////////////Answers//////////////////////////////////////

//   fetchAnswerList(String qId) async {
//     _answerList = ApiResponse.loading('Loading');
//     await Future.delayed(Duration(milliseconds: 1));
//     notifyListeners();
//     try {
//       List<AnswerModel> feedList =
//           await _answerRepository.fetchAllPostedAnswers(_currentUserId, qId);
//       _answerList = ApiResponse.completed(
//           feedList.length > 0 ? feedList : <AnswerModel>[]);
//       notifyListeners();
//     } catch (e) {
//       _answerList = ApiResponse.error(e.toString());
//       notifyListeners();
//     }
//   }

//   deleteMyAnswer(String ansId) async {
//     try {
//       _answerRepository.deleteMyAnswer(_currentUserId, ansId);
//       notifyListeners();
//     } catch (e) {}
//   }

//   updateLikeType(String type, int index) {
//     answerList.data[index].likeType = type;
//     notifyListeners();
//   }

//   hideAllLikeAnswerPopup(List<int> likeButtonPopupRemove) {
//     for (int i = 0; i < likeButtonPopupRemove.length; i++) {
//       answerList.data[likeButtonPopupRemove[i]].answerLikeButton = "false";
//     }
//     notifyListeners();
//   }

//   hideShowLikeAnswerPopup(int index, bool isVisible) {
//     if (isVisible) {
//       answerList.data[index].answerLikeButton = "true";
//     } else {
//       answerList.data[index].answerLikeButton = "false";
//     }
//     notifyListeners();
//   }

//   updateAnsLikeDetails(int ansIndex, String likeType, String tokenValue,
//       String notifyTitle, String notifyMesssage) {
//     if (likeType == "like") {
//       if (answerList.data[ansIndex].likeType == "") {
//         dataLoadCRUD.updateAnswerReaction([
//           answerList.data[ansIndex].answerId,
//           _currentUserId,
//           'like',
//           likeType
//         ]);

//         dataLoadCRUD.updateAnswerCountData([
//           answerList.data[ansIndex].answerId,
//           _currentUserId,
//           answerList.data[ansIndex].commentCount,
//           answerList.data[ansIndex].likeCount + 1,
//           answerList.data[ansIndex].upvoteCount,
//           answerList.data[ansIndex].downvoteCount
//         ]);
//         ////////////////////////////notification//////////////////////////////////////
//         notificationDB.createNotification(
//             answerList.data[ansIndex].answerId,
//             "answer",
//             "yes",
//             "false",
//             answerList.data[ansIndex].userId,
//             tokenValue,
//             notifyMesssage,
//             notifyTitle,
//             "answer",
//             "reaction",
//             "+");
//         answerList.data[ansIndex].likeType = likeType;
//         answerList.data[ansIndex].likeCount++;
//       } else if (answerList.data[ansIndex].likeType == "like") {
//         //  dataLoadCRUD.updateAnswerReaction(
//         //       [answerList.data[ansIndex].answerId, _currentUserId, 'like', likeType]);

//         dataLoadCRUD.updateAnswerCountData([
//           answerList.data[ansIndex].answerId,
//           _currentUserId,
//           answerList.data[ansIndex].commentCount,
//           answerList.data[ansIndex].likeCount - 1,
//           answerList.data[ansIndex].upvoteCount,
//           answerList.data[ansIndex].downvoteCount
//         ]);
//         ////////////////////////////notification//////////////////////////////////////
//         notificationDB.createNotification(
//             answerList.data[ansIndex].answerId,
//             "answer",
//             "no",
//             "false",
//             answerList.data[ansIndex].userId,
//             tokenValue,
//             notifyMesssage,
//             notifyTitle,
//             "answer",
//             "reaction",
//             "-");
//         answerList.data[ansIndex].likeType = "";
//         answerList.data[ansIndex].likeCount--;
//       } else {
//         dataLoadCRUD.updateAnswerReaction([
//           answerList.data[ansIndex].answerId,
//           _currentUserId,
//           'like',
//           likeType
//         ]);
//         answerList.data[ansIndex].likeType = likeType;
//       }
//     } else if (likeType == "markasimp") {
//       if (answerList.data[ansIndex].likeType == "") {
//         dataLoadCRUD.updateAnswerReaction([
//           answerList.data[ansIndex].answerId,
//           _currentUserId,
//           'like',
//           likeType
//         ]);

//         dataLoadCRUD.updateAnswerCountData([
//           answerList.data[ansIndex].answerId,
//           _currentUserId,
//           answerList.data[ansIndex].commentCount,
//           answerList.data[ansIndex].likeCount + 1,
//           answerList.data[ansIndex].upvoteCount,
//           answerList.data[ansIndex].downvoteCount
//         ]);
//         ////////////////////////////notification//////////////////////////////////////
//         notificationDB.createNotification(
//             answerList.data[ansIndex].answerId,
//             "answer",
//             "yes",
//             "false",
//             answerList.data[ansIndex].userId,
//             tokenValue,
//             notifyMesssage,
//             notifyTitle,
//             "answer",
//             "reaction",
//             "+");
//         answerList.data[ansIndex].likeType = likeType;
//         answerList.data[ansIndex].likeCount++;
//       } else if (answerList.data[ansIndex].likeType == "markasimp") {
//         //  dataLoadCRUD.updateAnswerReaction(
//         //       [answerList.data[ansIndex].answerId, _currentUserId, 'like', likeType]);

//         dataLoadCRUD.updateAnswerCountData([
//           answerList.data[ansIndex].answerId,
//           _currentUserId,
//           answerList.data[ansIndex].commentCount,
//           answerList.data[ansIndex].likeCount - 1,
//           answerList.data[ansIndex].upvoteCount,
//           answerList.data[ansIndex].downvoteCount
//         ]);
//         ////////////////////////////notification//////////////////////////////////////
//         notificationDB.createNotification(
//             answerList.data[ansIndex].answerId,
//             "answer",
//             "no",
//             "false",
//             answerList.data[ansIndex].userId,
//             tokenValue,
//             notifyMesssage,
//             notifyTitle,
//             "answer",
//             "reaction",
//             "-");
//         answerList.data[ansIndex].likeType = "";
//         answerList.data[ansIndex].likeCount--;
//       } else {
//         dataLoadCRUD.updateAnswerReaction([
//           answerList.data[ansIndex].answerId,
//           _currentUserId,
//           'like',
//           likeType
//         ]);
//         answerList.data[ansIndex].likeType = likeType;
//       }
//     } else if (likeType == "helpful") {
//       if (answerList.data[ansIndex].likeType == "") {
//         dataLoadCRUD.updateAnswerReaction([
//           answerList.data[ansIndex].answerId,
//           _currentUserId,
//           'like',
//           likeType
//         ]);

//         dataLoadCRUD.updateAnswerCountData([
//           answerList.data[ansIndex].answerId,
//           _currentUserId,
//           answerList.data[ansIndex].commentCount,
//           answerList.data[ansIndex].likeCount + 1,
//           answerList.data[ansIndex].upvoteCount,
//           answerList.data[ansIndex].downvoteCount
//         ]);
//         ////////////////////////////notification//////////////////////////////////////
//         notificationDB.createNotification(
//             answerList.data[ansIndex].answerId,
//             "answer",
//             "yes",
//             "false",
//             answerList.data[ansIndex].userId,
//             tokenValue,
//             notifyMesssage,
//             notifyTitle,
//             "answer",
//             "reaction",
//             "+");
//         answerList.data[ansIndex].likeType = likeType;
//         answerList.data[ansIndex].likeCount++;
//       } else if (answerList.data[ansIndex].likeType == "helpful") {
//         //  dataLoadCRUD.updateAnswerReaction(
//         //       [answerList.data[ansIndex].answerId, _currentUserId, 'like', likeType]);

//         dataLoadCRUD.updateAnswerCountData([
//           answerList.data[ansIndex].answerId,
//           _currentUserId,
//           answerList.data[ansIndex].commentCount,
//           answerList.data[ansIndex].likeCount - 1,
//           answerList.data[ansIndex].upvoteCount,
//           answerList.data[ansIndex].downvoteCount
//         ]);
//         ////////////////////////////notification//////////////////////////////////////
//         notificationDB.createNotification(
//             answerList.data[ansIndex].answerId,
//             "answer",
//             "no",
//             "false",
//             answerList.data[ansIndex].userId,
//             tokenValue,
//             notifyMesssage,
//             notifyTitle,
//             "answer",
//             "reaction",
//             "-");
//         answerList.data[ansIndex].likeType = "";
//         answerList.data[ansIndex].likeCount--;
//       } else {
//         dataLoadCRUD.updateAnswerReaction([
//           answerList.data[ansIndex].answerId,
//           _currentUserId,
//           'like',
//           likeType
//         ]);
//         answerList.data[ansIndex].likeType = likeType;
//       }
//     }

//     notifyListeners();
//   }

//   updateAnsUpvoteDetails(int ansIndex, String voteType, String tokenValue,
//       String notifyTitle, String notifyMesssage) {
//     if (answerList.data[ansIndex].voteType == "") {
//       if (voteType == 'upvote') {
//         dataLoadCRUD.updateAnswerCountData([
//           answerList.data[ansIndex].answerId,
//           _currentUserId,
//           answerList.data[ansIndex].commentCount,
//           answerList.data[ansIndex].likeCount,
//           answerList.data[ansIndex].upvoteCount + 1,
//           answerList.data[ansIndex].downvoteCount
//         ]);
//         answerList.data[ansIndex].upvoteCount++;
//       } else if (voteType == 'downvote') {
//         dataLoadCRUD.updateAnswerCountData([
//           answerList.data[ansIndex].answerId,
//           _currentUserId,
//           answerList.data[ansIndex].commentCount,
//           answerList.data[ansIndex].likeCount,
//           answerList.data[ansIndex].upvoteCount,
//           answerList.data[ansIndex].downvoteCount + 1
//         ]);
//         answerList.data[ansIndex].downvoteCount++;
//       }
//       answerList.data[ansIndex].voteType = voteType;
//       ////////////////////////////notification//////////////////////////////////////
//       notificationDB.createNotification(
//           answerList.data[ansIndex].answerId,
//           "answer",
//           "yes",
//           "false",
//           answerList.data[ansIndex].userId,
//           tokenValue,
//           notifyMesssage,
//           notifyTitle,
//           "answer",
//           "reaction",
//           "+");
//     } else if (answerList.data[ansIndex].voteType == "upvote") {
//       if (voteType == 'upvote') {
//         dataLoadCRUD.updateAnswerCountData([
//           answerList.data[ansIndex].answerId,
//           _currentUserId,
//           answerList.data[ansIndex].commentCount,
//           answerList.data[ansIndex].likeCount,
//           answerList.data[ansIndex].upvoteCount - 1,
//           answerList.data[ansIndex].downvoteCount
//         ]);
//         answerList.data[ansIndex].voteType = "";
//         answerList.data[ansIndex].upvoteCount--;
//         notificationDB.createNotification(
//             answerList.data[ansIndex].answerId,
//             "answer",
//             "no",
//             "false",
//             answerList.data[ansIndex].userId,
//             tokenValue,
//             notifyMesssage,
//             notifyTitle,
//             "answer",
//             "reaction",
//             "-");
//       } else if (voteType == 'downvote') {
//         dataLoadCRUD.updateAnswerCountData([
//           answerList.data[ansIndex].answerId,
//           _currentUserId,
//           answerList.data[ansIndex].commentCount,
//           answerList.data[ansIndex].likeCount,
//           answerList.data[ansIndex].upvoteCount - 1,
//           answerList.data[ansIndex].downvoteCount + 1
//         ]);
//         answerList.data[ansIndex].downvoteCount++;
//         answerList.data[ansIndex].upvoteCount--;
//         answerList.data[ansIndex].voteType = voteType;
//         ////////////////////////////notification//////////////////////////////////////
//         notificationDB.createNotification(
//             answerList.data[ansIndex].answerId,
//             "answer",
//             "no",
//             "false",
//             answerList.data[ansIndex].userId,
//             tokenValue,
//             notifyMesssage,
//             notifyTitle,
//             "answer",
//             "reaction",
//             "+");
//       }
//     } else if (answerList.data[ansIndex].voteType == "downvote") {
//       if (voteType == 'downvote') {
//         dataLoadCRUD.updateAnswerCountData([
//           answerList.data[ansIndex].answerId,
//           _currentUserId,
//           answerList.data[ansIndex].commentCount,
//           answerList.data[ansIndex].likeCount,
//           answerList.data[ansIndex].upvoteCount,
//           answerList.data[ansIndex].downvoteCount - 1
//         ]);
//         answerList.data[ansIndex].downvoteCount--;
//         answerList.data[ansIndex].voteType = "";
//         notificationDB.createNotification(
//             answerList.data[ansIndex].answerId,
//             "answer",
//             "no",
//             "false",
//             answerList.data[ansIndex].userId,
//             tokenValue,
//             notifyMesssage,
//             notifyTitle,
//             "answer",
//             "reaction",
//             "-");
//       } else if (voteType == 'upvote') {
//         dataLoadCRUD.updateAnswerCountData([
//           answerList.data[ansIndex].answerId,
//           _currentUserId,
//           answerList.data[ansIndex].commentCount,
//           answerList.data[ansIndex].likeCount,
//           answerList.data[ansIndex].upvoteCount + 1,
//           answerList.data[ansIndex].downvoteCount - 1
//         ]);
//         answerList.data[ansIndex].downvoteCount--;
//         answerList.data[ansIndex].upvoteCount++;
//         answerList.data[ansIndex].voteType = voteType;
//         ////////////////////////////notification//////////////////////////////////////
//         notificationDB.createNotification(
//             answerList.data[ansIndex].answerId,
//             "answer",
//             "no",
//             "false",
//             answerList.data[ansIndex].userId,
//             tokenValue,
//             notifyMesssage,
//             notifyTitle,
//             "answer",
//             "reaction",
//             "+");
//       }
//     }
//     notifyListeners();
//   }

//   ////////////////////////////Comments//////////////////////////////////////
//   updateCommentLikeDetails(AnswerCommentModel comment, String likeType,
//       String tokenValue, String notifyTitle, String notifyMesssage) {
//     if (comment.likeType == '') {
//       dataLoadCRUD.updateAnswerCommentCountData([
//         comment.commentId,
//         _currentUserId,
//         comment.likeCount + 1,
//         comment.replyCount
//       ]);
//       dataLoadCRUD.updateAnswerCommentReaction([
//         comment.commentId,
//         _currentUserId,
//         comment.likeType,
//       ]);

//       comment.likeType = 'like';
//       comment.likeCount++;
//       ////////////////////////////notification//////////////////////////////////////
//       notificationDB.createNotification(
//           comment.commentId,
//           "comment",
//           "yes",
//           "false",
//           comment.userId,
//           tokenValue,
//           notifyMesssage,
//           notifyTitle,
//           "comment",
//           "reaction",
//           "+");
//     } else {
//       dataLoadCRUD.updateAnswerCommentCountData([
//         comment.commentId,
//         _currentUserId,
//         comment.likeCount - 1,
//         comment.replyCount
//       ]);
//       dataLoadCRUD.updateAnswerCommentReaction([
//         comment.commentId,
//         _currentUserId,
//         comment.likeType,
//       ]);
//       comment.likeType = '';
//       comment.likeCount--;
//       ////////////////////////////notification//////////////////////////////////////
//       notificationDB.createNotification(
//           comment.commentId,
//           "comment",
//           "no",
//           "false",
//           comment.userId,
//           tokenValue,
//           notifyMesssage,
//           notifyTitle,
//           "comment",
//           "reaction",
//           "-");
//     }
//     notifyListeners();
//   }
// }
