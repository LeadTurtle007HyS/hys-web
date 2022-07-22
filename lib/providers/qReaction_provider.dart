import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../database/question_answer_repository.dart';
import '../models/network_request_genric.dart';
import '../models/qReactionModel.dart';

class QReactionProvider extends ChangeNotifier {
  QuestionAnswerRepository? _qReactionRepository;
  ApiResponse<List<QReactionModel>>? _qReactionList;
  ApiResponse<List<QReactionModel>> get qReactionList => _qReactionList!;
  String? _currentUserId;

  QReactionProvider() {
    _qReactionRepository = QuestionAnswerRepository();
    _qReactionList = ApiResponse.loading("Loading");
    _currentUserId = FirebaseAuth.instance.currentUser!.uid;
  }

  List<QReactionModel> _allLikes = [];
  List<QReactionModel> _allImp = [];
  List<QReactionModel> _allMyDoubtToo = [];

  List<QReactionModel> get allLikes => _allLikes;
  List<QReactionModel> get allImp => _allImp;
  List<QReactionModel> get allMyDoubtToo => _allMyDoubtToo;

  fetchQLikeReactionsList(String questionID) async {
    _qReactionList = ApiResponse.loading('Loading');
    notifyListeners();
    try {
      List<QReactionModel> movies =
          await _qReactionRepository!.fetchAllQLikeDetails(questionID);
      _qReactionList = ApiResponse.completed(movies);

      for (int i = 0; i < _qReactionList!.data!.length; i++) {
        if (_qReactionList!.data![i].likeType == 'like') {
          _allLikes.add(_qReactionList!.data![i]);
        } else if (_qReactionList!.data![i].likeType == 'markasimp') {
          _allImp.add(_qReactionList!.data![i]);
        } else if (_qReactionList!.data![i].likeType == 'mydoubttoo') {
          _allMyDoubtToo.add(_qReactionList!.data![i]);
        }
      }
      notifyListeners();
    } catch (e) {
      _qReactionList = ApiResponse.error(e.toString());
      notifyListeners();
    }
  }

  List<QReactionModel> _allExHigh = [];
  List<QReactionModel> _allExMedium = [];
  List<QReactionModel> _allExLow = [];

  List<QReactionModel> get allExHigh => _allExHigh;
  List<QReactionModel> get allExMedium => _allExMedium;
  List<QReactionModel> get allExLow => _allExLow;

  fetchQExamLikeReactionsList(String questionID) async {
    _qReactionList = ApiResponse.loading('Loading');
    notifyListeners();
    try {
      List<QReactionModel> movies =
          await _qReactionRepository!.fetchAllQExamLikeDetails(questionID);
      _qReactionList = ApiResponse.completed(movies);
      for (int i = 0; i < _qReactionList!.data!.length; i++) {
        if (_qReactionList!.data![i].likeType == 'high') {
          _allExHigh.add(_qReactionList!.data![i]);
        } else if (_qReactionList!.data![i].likeType == 'moderate') {
          _allExMedium.add(_qReactionList!.data![i]);
        } else if (_qReactionList!.data![i].likeType == 'low') {
          _allExLow.add(_qReactionList!.data![i]);
        }
      }
      notifyListeners();
    } catch (e) {
      _qReactionList = ApiResponse.error(e.toString());
      notifyListeners();
    }
  }

  List<QReactionModel> _allToughHigh = [];
  List<QReactionModel> _allToughMedium = [];
  List<QReactionModel> _allToughLow = [];

  List<QReactionModel> get allToughHigh => _allToughHigh;
  List<QReactionModel> get allToughMedium => _allToughMedium;
  List<QReactionModel> get allToughLow => _allToughLow;

  fetchQToughnessReactionsList(String questionID) async {
    _qReactionList = ApiResponse.loading('Loading');
    notifyListeners();
    try {
      List<QReactionModel> movies =
          await _qReactionRepository!.fetchAllQToughnessDetails(questionID);
      _qReactionList = ApiResponse.completed(movies);
      for (int i = 0; i < _qReactionList!.data!.length; i++) {
        if (_qReactionList!.data![i].likeType == 'high') {
          _allToughHigh.add(_qReactionList!.data![i]);
        } else if (_qReactionList!.data![i].likeType == 'medium') {
          _allToughMedium.add(_qReactionList!.data![i]);
        } else if (_qReactionList!.data![i].likeType == 'low') {
          _allToughLow.add(_qReactionList!.data![i]);
        }
      }
      notifyListeners();
    } catch (e) {
      _qReactionList = ApiResponse.error(e.toString());
      notifyListeners();
    }
  }
}
