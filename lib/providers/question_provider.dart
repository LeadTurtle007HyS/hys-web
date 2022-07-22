import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import '../database/question_answer_repository.dart';
import '../models/network_request_genric.dart';
import '../database/social_repository.dart';
import '../models/questionModel.dart';
import '../models/social_feed_model.dart';

class QuestionProviders extends ChangeNotifier {
  QuestionAnswerRepository? _questionAnswerRepository;
  ApiResponse<List<Questions>>? _questionList;
  // List<PersonQuestion> _ques_pers_List = [];

  // List<PersonQuestion> get ques_pers_List => _ques_pers_List;

  ApiResponse<List<Questions>> get questionList => _questionList!;

  Questions? _questionPost;
  ApiResponse<List<SocialFeedModel>>? _socialFeedList;
  ApiResponse<List<SocialFeedModel>> get socialFeedList => _socialFeedList!;

  Questions get questionPost => _questionPost!;

  void setQuestionPostValues(Questions qPost) {
    _questionPost = qPost;
    notifyListeners();
  }

  bool get hasNextPage => _hasNextPage;
  bool get isFirstLoadRunning => _isFirstLoadRunning;
  bool get isLoadMoreRunning => _isLoadMoreRunning;

  int? pageNumber;
  String? _currentUserId;
  bool _hasNextPage = true;
  bool _isFirstLoadRunning = false;
  bool _isLoadMoreRunning = false;

  QuestionProviders() {
    pageNumber = 0;
    _questionAnswerRepository = QuestionAnswerRepository();
    _questionList = ApiResponse.loading("Loading");
    _currentUserId = FirebaseAuth.instance.currentUser!.uid;
  }

  setLoadMoreRunning(bool value) {
    _isLoadMoreRunning = value;
  }

  setFirstLoadRunning(bool value) {
    _isFirstLoadRunning = value;
  }

  setHasNextPage(bool value) {
    _hasNextPage = value;
  }

  refreshList(String userId) async {
    pageNumber = 0;
    _isFirstLoadRunning = true;
    try {
      List<Questions> movies =
          await _questionAnswerRepository!.fetchAllPostedQuestion(userId);
      _questionList = ApiResponse.completed(movies);
      notifyListeners();
    } catch (e) {
      _questionList = ApiResponse.error(e.toString());
      notifyListeners();
    }
  }

  fetchQuestionList(String userID) async {
    pageNumber = 0;
    //   _ques_pers_List = [];
    _questionList = ApiResponse.loading('Loading');
    await Future.delayed(Duration(milliseconds: 1));
    notifyListeners();
    try {
      List<Questions> movies =
          await _questionAnswerRepository!.fetchAllPostedQuestion(userID);
      _questionList = ApiResponse.completed(movies);
      for (int i = 0; i < _questionList!.data!.length; i++) {
        Questions sharedQuestion;
        int sharedQIndex = 0;
        if (_questionList!.data![i].question_type == 'shared') {
          for (int j = 0; j < _questionList!.data!.length; j++) {
            if (_questionList!.data![i].answer_preference ==
                _questionList!.data![j].question_id) {
              sharedQuestion = _questionList!.data![j];
              sharedQIndex = j;
            }
          }
        }
        String toughnessValue = 'low';
        if (_questionList!.data![i].high_toughness_count >
                _questionList!.data![i].medium_toughness_count &&
            _questionList!.data![i].high_toughness_count >
                _questionList!.data![i].low_toughness_count) {
          toughnessValue = 'high';
        } else if (_questionList!.data![i].medium_toughness_count >
                _questionList!.data![i].high_toughness_count &&
            _questionList!.data![i].medium_toughness_count >
                _questionList!.data![i].low_toughness_count) {
          toughnessValue = 'medium';
        } else if (_questionList!.data![i].low_toughness_count >
                _questionList!.data![i].medium_toughness_count &&
            _questionList!.data![i].low_toughness_count >
                _questionList!.data![i].high_toughness_count) {
          toughnessValue = 'low';
        }

        String examlikeValue = 'low';
        if (_questionList!.data![i].high_examlike_count >
                _questionList!.data![i].medium_examlike_count &&
            _questionList!.data![i].high_examlike_count >
                _questionList!.data![i].low_examlike_count) {
          examlikeValue = 'high';
        } else if (_questionList!.data![i].medium_examlike_count >
                _questionList!.data![i].high_examlike_count &&
            _questionList!.data![i].medium_examlike_count >
                _questionList!.data![i].low_examlike_count) {
          examlikeValue = 'medium';
        } else if (_questionList!.data![i].low_examlike_count >
                _questionList!.data![i].medium_examlike_count &&
            _questionList!.data![i].low_examlike_count >
                _questionList!.data![i].high_examlike_count) {
          examlikeValue = 'low';
        }
        // _ques_pers_List.add(PersonQuestion(
        //     null,
        //     _questionList!.data![i],
        //     i,
        //     sharedQuestion,
        //     sharedQIndex,
        //     _questionList!.data![i].user_id,
        //     _questionList!.data![i].question_id,
        //     '',
        //     _questionList!.data![i].question,
        //     '',
        //     '',
        //     _questionList!.data![i].profilepic,
        //     'question',
        //     "",
        //     "",
        //     "",
        //     _questionList!.data![i].school_name,
        //     _questionList!.data![i].grade.toString(),
        //     '',
        //     '',
        //     [],
        //     _questionList!.data![i].subject,
        //     _questionList!.data![i].topic,
        //     toughnessValue,
        //     examlikeValue));
      }
      //fetchFeedList(userID);
      notifyListeners();
    } catch (e) {
      _questionList = ApiResponse.error(e.toString());
      notifyListeners();
    }
  }

  // fetchFeedList(String userID) async {
  //   pageNumber=0;
  //   _isFirstLoadRunning = true;
  //   _socialFeedList = ApiResponse.loading('Loading');
  //   _ques_pers_List=[];
  //   notifyListeners();
  //   try {
  //           List<SocialFeedModel> movies = await _socialRepository.fetchAllSocialFeed_inONE(userID);
  //     //List<SocialFeedModel> movies = await _socialRepository.fetchAllSocialFeed((pageNumber*10).toString(),userID);
  //       if(movies.length<10)
  //       _hasNextPage=false;
  //        // allSocialPostLocalDB.put("LocalSocialFeed", movies as List<dynamic>);
  //      _socialFeedList = ApiResponse.completed(movies);
  //      for(int i=0;i<_socialFeedList.data.length;i++)
  //   {
  //     _ques_pers_List.add(PersonQuestion(
  //           null,
  //           null,
  //           null,
  //           null,
  //           _socialFeedList.data[i].user_id,
  //           _socialFeedList.data[i].post_id,
  //           '',
  //           (_socialFeedList.data[i].feedtype=="blog")?_socialFeedList.data[i].blog_intro:_socialFeedList.data[i].message,
  //           '',
  //           '',
  //           _socialFeedList.data[i].profilepic,
  //           (_socialFeedList.data[i].feedtype=="podcast")?"podcast":(_socialFeedList.data[i].feedtype=="blog")?"blog":(_socialFeedList.data[i].feedtype=="Mood")?"Mood":(_socialFeedList.data[i].feedtype=="cause|teachunprevilagedKids")?"cause|teachunprevilagedKids":"",
  //           _socialFeedList.data[i].school_name,
  //           _socialFeedList.data[i].grade.toString(),
  //           '',
  //           '',
  //           ["English","Hindi"],
  //           "",
  //           "",
  //           "",
  //         ""));
  //   }
  //      notifyListeners();
  //   } catch (e) {
  //     _socialFeedList = ApiResponse.error(e.toString());
  //     notifyListeners();
  //   }
  // }

  updateQuestionDetailsCountValue(String userId, String questionId,
      String updateCountValue, String symbol, Questions qPost) async {
    setQuestionPostValues(qPost);
    int examLikelyHood = updateCountValue == "examlikelyhood"
        ? symbol == "+"
            ? (questionPost.examlikelyhood_count) + 1
            : (questionPost.examlikelyhood_count) - 1
        : (questionPost.examlikelyhood_count);
    int like = updateCountValue == "like"
        ? symbol == "+"
            ? (questionPost.like_count) + 1
            : (questionPost.like_count) - 1
        : (questionPost.like_count);
    int toughness = updateCountValue == "toughness"
        ? symbol == "+"
            ? (questionPost.toughness_count) + 1
            : (questionPost.toughness_count) - 1
        : (questionPost.toughness_count);
    int answer = updateCountValue == "answer"
        ? symbol == "+"
            ? (questionPost.answer_count) + 1
            : (questionPost.answer_count) - 1
        : (questionPost.answer_count);
    int view = updateCountValue == "view"
        ? symbol == "+"
            ? (questionPost.view_count) + 1
            : (questionPost.view_count) - 1
        : (questionPost.answer_count);
    int impression = updateCountValue == "impression"
        ? symbol == "+"
            ? (questionPost.impression_count) + 1
            : (questionPost.impression_count) - 1
        : (questionPost.impression_count);
    print("examlikelyhood: ${examLikelyHood.toString()}");
    print("like: ${like.toString()}");
    print("toughness: ${toughness.toString()}");
    print("answer: ${answer.toString()}");
    print("view: ${view.toString()}");
    print("impression: ${impression.toString()}");
    questionPost.examlikelyhood_count = examLikelyHood;
    questionPost.like_count = like;
    questionPost.toughness_count = toughness;
    questionPost.answer_count = answer;
    questionPost.impression_count = impression;
    questionPost.view_count = view;

    notifyListeners();

    var body = jsonEncode(<String, dynamic>{
      "user_id": userId,
      "question_id": questionId,
      "examlikelyhood_count": examLikelyHood,
      "like_count": like,
      "toughness_count": toughness,
      "answer_count": answer,
      "view_count": view,
      "impression_count": impression
    });

    _questionAnswerRepository!.updateQuestionsCount(body);
  }

  updateLikeType(String type, Questions qPost) {
    setQuestionPostValues(qPost);
    questionPost.like_type = type;
    notifyListeners();
  }

  updateExamLikeHoodType(String type, Questions qPost) {
    setQuestionPostValues(qPost);
    questionPost.examlikelyhood_type = type;
    notifyListeners();
  }

  updateToughnessType(String type, Questions qPost) {
    setQuestionPostValues(qPost);
    questionPost.toughness_type = type;
    notifyListeners();
  }

  hideAllLikeQuestionPopup(List<int> likeButtonPopupRemove,
      List<int> examLikelyHoodPopupRemove, List<int> toughnessPopupRemove) {
    for (int i = 0; i < likeButtonPopupRemove.length; i++) {
      questionList.data![likeButtonPopupRemove[i]].isLikeButtonExpanded =
          "false";
    }
    for (int i = 0; i < examLikelyHoodPopupRemove.length; i++) {
      questionList.data![examLikelyHoodPopupRemove[i]]
          .isExamlikelyhoodButtonExpanded = "false";
    }
    for (int i = 0; i < toughnessPopupRemove.length; i++) {
      questionList.data![toughnessPopupRemove[i]].isToughnessButtonExpanded =
          "false";
    }
    notifyListeners();
  }

  hideShowLikeQuestionPopup(int index, bool isVisible) {
    if (isVisible) {
      questionList.data![index].isLikeButtonExpanded = "true";
    } else {
      questionList.data![index].isLikeButtonExpanded = "false";
    }
    notifyListeners();
  }

  hideShowExamLikeHoodQuestionPopup(int index, bool isVisible) {
    if (isVisible) {
      questionList.data![index].isExamlikelyhoodButtonExpanded = "true";
    } else {
      questionList.data![index].isExamlikelyhoodButtonExpanded = "false";
    }
    notifyListeners();
  }

  hideShowToughnessQuestionPopup(int index, bool isVisible) {
    if (isVisible) {
      questionList.data![index].isToughnessButtonExpanded = "true";
    } else {
      questionList.data![index].isToughnessButtonExpanded = "false";
    }
    notifyListeners();
  }
}
