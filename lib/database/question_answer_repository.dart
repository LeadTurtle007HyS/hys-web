import 'package:hive/hive.dart';

import '../constants/constants.dart';
import '../models/ans_reply_model.dart';
import '../models/answer_comment_model.dart';
import '../models/answers_model.dart';
import '../models/qReactionModel.dart';
import '../models/questionModel.dart';
import '../models/user_profile_model.dart';
import '../network/api_base_helper.dart';

class QuestionAnswerRepository {
  ApiBaseHelper _helper = ApiBaseHelper();
  Box<dynamic> allQuestionsLocalDB = Hive.box<dynamic>('allquestions');

  Future<List<Questions>> fetchAllPostedQuestion(String userID) async {
    var responseBody =
        await _helper.get(Constant.All_QUESTION_POST_PATH + userID) as List;
    return responseBody.map((data) => Questions.fromJson(data)).toList();
  }

  Future<List<AnswerModel>> fetchAllPostedAnswers(
      String userID, String qId) async {
    var responseBody = await _helper
        .get(Constant.All_ANSWER_POST_PATH + userID + "/" + qId) as List;
    return responseBody.map((data) => AnswerModel.fromJson(data)).toList();
  }

  Future<List<AnsReplyModel>> fetchAllPostedAnsReply(
      String userID, String cmtId) async {
    var responseBody = await _helper
        .get(Constant.All_ANSREPLY_GET_PATH + userID + "/" + cmtId) as List;
    return responseBody.map((data) => AnsReplyModel.fromJson(data)).toList();
  }

  Future<List<Questions>> fetchAllPostedQuestionFromLocalDB(
      String userID) async {
    var responseBody =
        await _helper.get(Constant.All_QUESTION_POST_PATH + userID) as List;
    return responseBody.map((data) => Questions.fromJson(data)).toList();
  }

  Future<void> updateQuestionsCount(dynamic body) async {
    _helper.put(Constant.UPDATE_QUESTION_DETAILS_COUNT_PATH, body);
  }

  Future<List<Questions>> fetchPostedQuestionDetails(
      String userID, String questionId) async {
    var responseBody = await _helper.get(
            Constant.QUESTIONS_POST_DETAILS_PATH + userID + "/" + questionId)
        as List;
    return responseBody.map((data) => Questions.fromJson(data)).toList();
  }

  Future<List<AnswerModel>> fetchPostedAnswerDetails(
      String userID, String answerID) async {
    var responseBody = await _helper.get(
        Constant.QNA_ANSWER_DETAILS_PATH + userID + "/" + answerID) as List;
    return responseBody.map((data) => AnswerModel.fromJson(data)).toList();
  }

  Future<List<AnswerCommentModel>> fetchPostedCommentDetails(
      String userID, String commentID) async {
    var responseBody = await _helper.get(
            Constant.QNA_ANSWER_COMMENT_DETAILS_PATH + userID + "/" + commentID)
        as List;
    return responseBody
        .map((data) => AnswerCommentModel.fromJson(data))
        .toList();
  }

  Future<List<Questions>> fetchPostedReplyDetails(
      String userID, String replyID) async {
    var responseBody = await _helper.get(
        Constant.QNA_ANSWER_COMMENT_REPLY_DETAILS_PATH +
            userID +
            "/" +
            replyID) as List;
    return responseBody.map((data) => Questions.fromJson(data)).toList();
  }

  Future<List<QReactionModel>> fetchAllQLikeDetails(String questionId) async {
    var responseBody = await _helper
        .get(Constant.All_QUESTIONLIKE_GET_PATH + questionId) as List;
    return responseBody.map((data) => QReactionModel.fromJson(data)).toList();
  }

  Future<List<QReactionModel>> fetchAllQExamLikeDetails(
      String questionId) async {
    var responseBody = await _helper
        .get(Constant.All_QUESTIONEXAMLIKEHOOD_GET_PATH + questionId) as List;
    return responseBody.map((data) => QReactionModel.fromJson(data)).toList();
  }

  Future<List<QReactionModel>> fetchAllQToughnessDetails(
      String questionId) async {
    var responseBody = await _helper
        .get(Constant.All_QUESTIONTOUGHNESS_GET_PATH + questionId) as List;
    return responseBody.map((data) => QReactionModel.fromJson(data)).toList();
  }

  Future<List<AnswerCommentModel>> fetchAnswerCommentList(
      String userID, String answerID) async {
    var responseBody = await _helper.get(
        Constant.ANSWER_COMMENT_LIST_PATH + userID + "/" + answerID) as List;
    return responseBody
        .map((data) => AnswerCommentModel.fromJson(data))
        .toList();
  }

  void deleteMyAnswer(String userID, String answerID) async {
    await _helper.get(Constant.DELETE_MY_ANSWER_PATH + userID + "/" + answerID)
        as List;
  }

  Future<List<ProfileModel>> fetchMyProfileDetials(String userID) async {
    var responseBody =
        await _helper.get(Constant.PROFILE_DETAILS_PATH + userID) as List;
    return responseBody.map((data) => ProfileModel.fromJson(data)).toList();
  }

  Future<List<Questions>> fetchAllMyPostedQuestion(String userID) async {
    var responseBody =
        await _helper.get(Constant.ALL_MY_POSTED_QUESTIONS + userID) as List;
    return responseBody.map((data) => Questions.fromJson(data)).toList();
  }

  Future<List<AnswerModel>> fetchAllMyPostedAnswers(String userID) async {
    var responseBody =
        await _helper.get(Constant.ALL_MY_POSTED_ANSWERS + userID) as List;
    return responseBody.map((data) => AnswerModel.fromJson(data)).toList();
  }
}
