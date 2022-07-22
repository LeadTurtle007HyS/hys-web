// import 'dart:async';

// import 'package:flutter/material.dart';
// import 'package:hys/database/question_answer_repository.dart';
// import 'package:hys/models/answer_comment_model.dart';
// import '../models/answers_model.dart';
// import '../models/network_request_genric.dart';


// class AnswerCommentProvider extends ChangeNotifier {
//   QuestionAnswerRepository _questionAnswerRepositoryRepository;
//   ApiResponse<List<AnswerCommentModel>> _answerCommentList;
//   ApiResponse<List<AnswerCommentModel>> get answerCommentList => _answerCommentList;

//   AnswerModel answerModel;


//   // ignore: close_sinks
//   StreamController<bool> controller = StreamController<bool>.broadcast();

//   // ignore: non_constant_identifier_names
//   AnswerCommentProvider() {
//     _questionAnswerRepositoryRepository = QuestionAnswerRepository();
//   }

//   void setAnswerModel(AnswerModel data){
//     this.answerModel=data;
//   }

//   AnswerModel get getAnswerModel => answerModel;

//   fetchNotificationsList(String userID,String answerID) async {
//     _answerCommentList = ApiResponse.loading('Loading');
//     await Future.delayed(Duration(milliseconds: 1));
//     notifyListeners();
//     try {
//       List<AnswerCommentModel> answerCommentList = await _questionAnswerRepositoryRepository.fetchAnswerCommentList(userID,answerID);
//       _answerCommentList = ApiResponse.completed(answerCommentList.length!=0?answerCommentList:<AnswerCommentModel>[]);
//       notifyListeners();
//     } catch (e) {
//       _answerCommentList = ApiResponse.error(e.toString());
//       notifyListeners();
//     }
//   }

//   addAnswerComment(AnswerCommentModel answerCommentModel){
//     _answerCommentList.data.add(answerCommentModel);
//     answerModel.commentCount=answerModel.commentCount+1;
//     notifyListeners();
//   }

//   updateAnswerCommentLikeCount(String process,String likeType, int index){
//     if(process=="+"){
//       _answerCommentList.data[index].likeCount=_answerCommentList.data[index].likeCount+1;
//     }else{
//       _answerCommentList.data[index].likeCount=_answerCommentList.data[index].likeCount-1;
//     }
//     _answerCommentList.data[index].likeType=likeType;
//     notifyListeners();

//   }

//   updateAnswerCommentLikeType(String process, int index){
//     if(process=="+"){


//     }else{

//     }

//   }

//   updateAnswerVoteCount(String process , String voteType){
//     if(process=="+"){
//       answerModel.upvoteCount=answerModel.upvoteCount+1;
//     }else{
//       answerModel.upvoteCount=answerModel.upvoteCount-1;
//     }
//     answerModel.voteType=voteType;

//     notifyListeners();

//   }
//   updateAnswerDownVoteCount(String process , String voteType){
//     if(process=="+"){
//       answerModel.downvoteCount=answerModel.downvoteCount+1;
//     }else{
//       answerModel.downvoteCount=answerModel.downvoteCount-1;
//     }
//     answerModel.voteType=voteType;

//     notifyListeners();

//   }

//   updateAnswerReactionCount(String process , String reactionType){
//     if(process=="+" && answerModel.likeType==""){
//       answerModel.likeCount=answerModel.likeCount+1;
//       answerModel.likeType=reactionType;
//     }else if(process=="+" && answerModel.likeType!=""){
//       answerModel.likeType=reactionType;
//     }else{
//       answerModel.likeCount=answerModel.likeCount-1;
//       answerModel.likeType=reactionType;
//     }
//     notifyListeners();

//   }




// }
