import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../database/crud.dart';
import '../database/question_answer_repository.dart';
import '../models/answers_model.dart';
import '../models/network_request_genric.dart';
import '../models/questionModel.dart';
import '../models/user_profile_model.dart';

CrudMethods crudobj = CrudMethods();
QuerySnapshot? service;
QuerySnapshot? topics;
String _currentUserId = FirebaseAuth.instance.currentUser!.uid;

class ProfileProvider extends ChangeNotifier {
  QuestionAnswerRepository? _profielRepository;
  ApiResponse<List<ProfileModel>>? _profileDetailsList;
  ApiResponse<List<ProfileModel>> get profileDetailsList =>
      _profileDetailsList!;
  List<List<String>> _previousTopicList = [];
  List<String> _previousSubjectList = [];
  Box<dynamic>? userDataDB;

  List<List<String>> get previousTopicList => _previousTopicList;
  List<String> get previousSubjectList => _previousSubjectList;

  ApiResponse<List<Questions>>? _questionList;
  ApiResponse<List<Questions>> get questionList => _questionList!;

  ApiResponse<List<AnswerModel>>? _answerList;
  ApiResponse<List<AnswerModel>> get answerList => _answerList!;

  String _profilePic = "";

  String get profilePic => _profilePic;

  void setProfilePicValue(String val) {
    _profilePic = val;
    userDataDB!.put("profilepic", val);
    notifyListeners();
  }

  void setPreviousTopicList(List<List<String>> list) {
    _previousTopicList = list;
  }

  void setPreviousSubjectList(List<String> list) {
    _previousSubjectList = list;
  }

  List<List<String>> _topicList = [];
  List<String> _subjectList = [];

  List<List<String>> get topicList => _topicList;
  List<String> get subjectList => _subjectList;

  void setTopicList(List<List<String>> list) {
    _topicList = list;
  }

  void setSubjectList(List<String> list) {
    _subjectList = list;
  }

  String _preferredLang = "";

  String get preferredLang => _preferredLang;

  void setPreferredLangValue(String val) {
    _preferredLang = val;
  }

  String _personalHobbies = "";

  String get personalHobbies => _personalHobbies;

  void setPersonalHobbiesValue(String val) {
    _personalHobbies = val;
  }

  String _ambition = "";

  String get ambition => _ambition;

  void setAmbitionValue(String val) {
    _ambition = val;
  }

  String _novels = "";

  String get novels => _novels;

  void setNovelsValue(String val) {
    _novels = val;
  }

  String _dreamVacations = "";

  String get dreamVacations => _dreamVacations;

  void setDreamVacationsValue(String val) {
    _dreamVacations = val;
  }

  String _visitedPlaces = "";

  String get visitedPlaces => _visitedPlaces;

  void setPlacesVisitedValue(String val) {
    _visitedPlaces = val;
  }

  List<String> _strengthSubjectList = [];

  List<String> get strengthSubjectList => _strengthSubjectList;

  void setStrengthSubjectList(List<String> list) {
    _strengthSubjectList = list;
  }

  List<String> _strengthTopicList = [];

  List<String> get strengthTopicList => _strengthTopicList;

  void setStrengthTopicList(List<String> list) {
    _strengthTopicList = list;
  }

  List<String> _prviousStrengthSubjectList = [];

  List<String> get prviousStrengthSubjectList => _prviousStrengthSubjectList;

  void setPreviousStrengthSubjectList(List<String> list) {
    _prviousStrengthSubjectList = list;
  }

  List<String> _prviousTopicSubjectList = [];

  List<String> get prviousTopicSubjectList => _prviousTopicSubjectList;

  void setPreviousTopicSubjectList(List<String> list) {
    _prviousTopicSubjectList = list;
  }

  List<String> _weaknessSubjectList = [];

  List<String> get weaknessSubjectList => _weaknessSubjectList;

  void setWeaknessSubjectList(List<String> list) {
    _weaknessSubjectList = list;
  }

  List<String> _weaknessTopicList = [];

  List<String> get weaknessTopicList => _weaknessTopicList;

  void setWeaknessTopicList(List<String> list) {
    _weaknessTopicList = list;
  }

  List<Upload> _schoolExams = [];
  List<Upload> _classNotes = [];
  List<Upload> _compExams = [];
  List<Upload> _others = [];

  List<Upload> get schoolExams => _schoolExams;

  void setUplodSchoolExam(List<Upload> list) {
    _schoolExams = list;
  }

  List<Upload> get classNotes => _classNotes;

  void setUplodClassNotes(List<Upload> list) {
    _classNotes = list;
  }

  List<Upload> get compExams => _compExams;

  void setUplodCompExam(List<Upload> list) {
    _compExams = list;
  }

  List<Upload> get others => _others;

  void setUplodOtherFiles(List<Upload> list) {
    _others = list;
  }

  // ignore: non_constant_identifier_names
  ProfileProvider() {
    userDataDB = Hive.box<dynamic>('userdata');
    _profileDetailsList = ApiResponse.loading("Loading");
    _questionList = ApiResponse.loading("Loading");
    _profielRepository = QuestionAnswerRepository();
  }

  fetchProfileDetials(String userID) async {
    List<String> values = [];
    List<String> hobbiesValues = [];
    List<String> ambitionsValues = [];
    List<String> novelsValues = [];
    List<String> dreamVacationValues = [];
    List<String> visitedPlacesValues = [];
    List<String> currentStrengthValues = [];
    List<String> currentStrengthTopicValues = [];
    List<String> previousStrengthValues = [];
    List<String> previousStrengthTopicValues = [];
    List<String> weaknessSubjectValues = [];
    List<String> weaknessTopicValues = [];
    List<Upload> schoolExamValues = [];
    List<Upload> compExamValues = [];
    List<Upload> classNotesValues = [];
    List<Upload> othersValues = [];
    _profileDetailsList = ApiResponse.loading('Loading');
    await Future.delayed(Duration(milliseconds: 1));
    notifyListeners();
    try {
      List<ProfileModel> movies =
          await _profielRepository!.fetchMyProfileDetials(userID);
      _profileDetailsList = ApiResponse.completed(movies);
      if (_currentUserId == userID) {
        userDataDB!.put("first_name", _profileDetailsList!.data![0].firstName);
        userDataDB!.put("last_name", _profileDetailsList!.data![0].lastName);
        userDataDB!.put("email_id", _profileDetailsList!.data![0].emailId);
        userDataDB!.put("mobile_no", _profileDetailsList!.data![0].mobileNo);
        userDataDB!.put("address", _profileDetailsList!.data![0].address);
        userDataDB!.put("board", _profileDetailsList!.data![0].board);
        userDataDB!.put("city", _profileDetailsList!.data![0].city);
        userDataDB!.put("gender", _profileDetailsList!.data![0].gender);
        userDataDB!.put("grade", _profileDetailsList!.data![0].grade);
        userDataDB!.put("profilepic", _profileDetailsList!.data![0].profilepic);
        userDataDB!
            .put("school_address", _profileDetailsList!.data![0].schoolAddress);
        userDataDB!
            .put("school_city", _profileDetailsList!.data![0].schoolCity);
        userDataDB!.put("school_name", _profileDetailsList!.data![0].schoolNme);
        userDataDB!
            .put("school_state", _profileDetailsList!.data![0].schoolState);
        userDataDB!
            .put("school_street", _profileDetailsList!.data![0].schoolStreet);
        userDataDB!.put("state", _profileDetailsList!.data![0].state);
        userDataDB!.put("stream", _profileDetailsList!.data![0].stream);
        userDataDB!.put("street", _profileDetailsList!.data![0].street);
        userDataDB!.put("user_dob", _profileDetailsList!.data![0].userDob);
      }
      fetchAllSubjectsTopics(_profileDetailsList!.data![0].grade!,
          _profileDetailsList!.data![0].board!);
      notifyListeners();
      setProfilePicValue(_profileDetailsList!.data![0].profilepic!);
      for (int i = 0;
          i < _profileDetailsList!.data![0].preferredLanguages!.length;
          i++) {
        values.add(_profileDetailsList!
            .data![0].preferredLanguages![i].preferredLang!);
      }
      if (values.length >= 1) {
        setPreferredLangValue(
            values.toString().substring(1, values.toString().length - 1));
      }

      for (int i = 0; i < _profileDetailsList!.data![0].hobbies!.length; i++) {
        hobbiesValues
            .add(_profileDetailsList!.data![0].hobbies![i].userHobbies!);
      }
      if (hobbiesValues.length >= 1) {
        setPersonalHobbiesValue(hobbiesValues
            .toString()
            .substring(1, hobbiesValues.toString().length - 1));
      }

      for (int i = 0; i < _profileDetailsList!.data![0].ambition!.length; i++) {
        ambitionsValues
            .add(_profileDetailsList!.data![0].ambition![i].userAmbition);
      }
      if (ambitionsValues.length >= 1) {
        setAmbitionValue(ambitionsValues
            .toString()
            .substring(1, ambitionsValues.toString().length - 1));
      }

      for (int i = 0; i < _profileDetailsList!.data![0].novels!.length; i++) {
        novelsValues
            .add(_profileDetailsList!.data![0].novels![i].userNovelsRead!);
      }
      if (novelsValues.length >= 1) {
        setNovelsValue(novelsValues
            .toString()
            .substring(1, novelsValues.toString().length - 1));
      }

      for (int i = 0;
          i < _profileDetailsList!.data![0].dreamVacations!.length;
          i++) {
        dreamVacationValues.add(_profileDetailsList!
            .data![0].dreamVacations![i].userDreamVacations!);
      }
      if (dreamVacationValues.length >= 1) {
        setDreamVacationsValue(dreamVacationValues
            .toString()
            .substring(1, dreamVacationValues.toString().length - 1));
      }

      for (int i = 0;
          i < _profileDetailsList!.data![0].placesVisited!.length;
          i++) {
        visitedPlacesValues.add(
            _profileDetailsList!.data![0].placesVisited![i].userPlaceVisited!);
      }
      if (visitedPlacesValues.length >= 1) {
        setPlacesVisitedValue(visitedPlacesValues
            .toString()
            .substring(1, visitedPlacesValues.toString().length - 1));
      }

      for (int i = 0;
          i < _profileDetailsList!.data![0].strengths!.length;
          i++) {
        if (_profileDetailsList!.data![0].strengths![i].grade ==
            _profileDetailsList!.data![0].grade) {
          currentStrengthValues
              .add(_profileDetailsList!.data![0].strengths![i].subject!);
          currentStrengthTopicValues
              .add(_profileDetailsList!.data![0].strengths![i].topic!);
        }
        if (_profileDetailsList!.data![0].strengths![i].grade ==
            _profileDetailsList!.data![0].grade! - 1) {
          previousStrengthValues
              .add(_profileDetailsList!.data![0].strengths![i].subject!);
          previousStrengthTopicValues
              .add(_profileDetailsList!.data![0].strengths![i].topic!);
        }
      }
      for (int i = 0; i < _profileDetailsList!.data![0].weakness!.length; i++) {
        if (_profileDetailsList!.data![0].weakness![i].grade ==
            _profileDetailsList!.data![0].grade) {
          weaknessSubjectValues
              .add(_profileDetailsList!.data![0].weakness![i].subject!);
          weaknessTopicValues
              .add(_profileDetailsList!.data![0].weakness![i].topic!);
        }
      }

      for (int i = 0; i < _profileDetailsList!.data![0].uploads!.length; i++) {
        if (_profileDetailsList!.data![0].uploads![i].uploadType ==
            "Class Notes") {
          classNotesValues.add(_profileDetailsList!.data![0].uploads![i]);
        } else if (_profileDetailsList!.data![0].uploads![i].uploadType ==
            "School Exams") {
          schoolExamValues.add(_profileDetailsList!.data![0].uploads![i]);
        } else if (_profileDetailsList!.data![0].uploads![i].uploadType ==
            "Competitive Exams") {
          compExamValues.add(_profileDetailsList!.data![0].uploads![i]);
        } else if (_profileDetailsList!.data![0].uploads![i].uploadType ==
            "Others") {
          othersValues.add(_profileDetailsList!.data![0].uploads![i]);
        }
      }

      setPreviousStrengthSubjectList(previousStrengthValues.toSet().toList());
      setStrengthSubjectList(currentStrengthValues.toSet().toList());
      setStrengthTopicList(currentStrengthTopicValues.toSet().toList());
      setPreviousTopicSubjectList(previousStrengthTopicValues.toSet().toList());
      setWeaknessSubjectList(weaknessSubjectValues.toSet().toList());
      setWeaknessTopicList(weaknessTopicValues.toSet().toList());
      setUplodClassNotes(classNotesValues);
      setUplodSchoolExam(schoolExamValues);
      setUplodCompExam(compExamValues);
      setUplodOtherFiles(othersValues);

      notifyListeners();
    } catch (e) {
      _profileDetailsList = ApiResponse.error(e.toString());
      notifyListeners();
    }
  }

  fetchAllSubjectsTopics(int grade, String board) {
    crudobj
        .getSubjectListSingleGradeWise(
            grade.toString(), "Central Board of Secondary Education (CBSE)")
        .then((value) {
      service = value;
      if (service != null) {
        crudobj
            .getTopicSubjectList("Central Board of Secondary Education (CBSE)")
            .then((value) {
          topics = value;
          if (topics != null) {
            List<String> subjectsL = [];
            List<List<String>> topicsL = [];
            for (int i = 0; i < service!.docs.length; i++) {
              List<String> subjectTopics = [];
              subjectsL.add(service!.docs[i].get("subject"));
              for (int j = 0; j < topics!.docs.length; j++) {
                if ((topics!.docs[j].get("grade") == grade.toString()) &&
                    (topics!.docs[j].get("subject") ==
                        service!.docs[i].get("subject"))) {
                  subjectTopics.add(topics!.docs[j].get("topic"));
                }
              }
              topicsL.add(subjectTopics);
            }
            setSubjectList(subjectsL);
            setTopicList(topicsL);
            notifyListeners();
          }
        });
      }
    });

    if (grade - 1 > 7) {
      crudobj
          .getSubjectListSingleGradeWise((grade - 1).toString(),
              "Central Board of Secondary Education (CBSE)")
          .then((value) {
        service = value;
        if (service != null) {
          crudobj
              .getTopicSubjectList(
                  "Central Board of Secondary Education (CBSE)")
              .then((value) {
            topics = value;
            if (topics != null) {
              List<String> subjectsL = [];
              List<List<String>> topicsL = [];
              for (int i = 0; i < service!.docs.length; i++) {
                List<String> subjectTopics = [];
                subjectsL.add(service!.docs[i].get("subject"));
                for (int j = 0; j < topics!.docs.length; j++) {
                  if ((topics!.docs[j].get("grade") ==
                          (grade - 1).toString()) &&
                      (topics!.docs[j].get("subject") ==
                          service!.docs[i].get("subject"))) {
                    subjectTopics.add(topics!.docs[j].get("topic"));
                  }
                }
                topicsL.add(subjectTopics);
              }
              setPreviousSubjectList(subjectsL);
              setPreviousTopicList(topicsL);
              notifyListeners();
            }
          });
        }
      });
    }
    notifyListeners();
  }

  List<Questions> _myPostedQ = [];
  List<Questions> get myPostedQ => _myPostedQ;

  void setMyPostedQ(List<Questions> list) {
    _myPostedQ = list;
  }

  List<Questions> _myAnswersQ = [];
  List<Questions> get myAnswersQ => _myAnswersQ;

  fetchMyQuestionList(String userID) async {
    List<Questions> myPostedQList = [];
    _questionList = ApiResponse.loading('Loading');
    await Future.delayed(Duration(milliseconds: 1));
    notifyListeners();
    try {
      List<Questions> movies =
          await _profielRepository!.fetchAllMyPostedQuestion(userID);
      _questionList = ApiResponse.completed(movies);
      fetchAllMyPostedAnswerList(userID);
      for (int i = 0; i < _questionList!.data!.length; i++) {
        if (_questionList!.data![i].user_id == userID) {
          myPostedQList.add(_questionList!.data![i]);
        }
      }
      setMyPostedQ(myPostedQList);
      notifyListeners();
    } catch (e) {
      _questionList = ApiResponse.error(e.toString());
      notifyListeners();
    }
  }

  void setMyAnswerQ(List<Questions> list) {
    _myAnswersQ = list;
  }

  fetchAllMyPostedAnswerList(String userid) async {
    List<Questions> myAnsweredQList = [];
    _answerList = ApiResponse.loading('Loading');
    await Future.delayed(Duration(milliseconds: 1));
    notifyListeners();
    try {
      List<AnswerModel> feedList =
          await _profielRepository!.fetchAllMyPostedAnswers(userid);
      _answerList = ApiResponse.completed(
          feedList.length > 0 ? feedList : <AnswerModel>[]);
      for (int i = 0; i < _questionList!.data!.length; i++) {
        int count = 0;
        for (int j = 0; j < _answerList!.data!.length; j++) {
          if (_questionList!.data![i].question_id ==
              _answerList!.data![j].questionId) {
            if (count == 0) {
              myAnsweredQList.add(_questionList!.data![i]);
              count++;
            }
          }
        }
      }
      setMyAnswerQ(myAnsweredQList);
      notifyListeners();
    } catch (e) {
      _answerList = ApiResponse.error(e.toString());
      notifyListeners();
    }
  }

  String _achievementTittle = "";
  String get achievementTittle => _achievementTittle;

  setAchievementTittleValue(String val) {
    _achievementTittle = val;
    notifyListeners();
  }

  String _achievementDesc = "";
  String get achievementDesc => _achievementDesc;

  setAchievementDescValue(String val) {
    _achievementDesc = val;
    notifyListeners();
  }

  String _achievementurl = "";
  String get achievementurl => _achievementurl;

  setAchievementUrlValue(String val) {
    _achievementurl = val;
    notifyListeners();
  }

  List<String> _scoreCardSubject = ["English", "Matrhematics", "Science"];
  List<String> _scoreCardSubjectsMarks = ["", "", ""];
  String _totalScore = "0";

  List<String> get scoreCardSubject => _scoreCardSubject;
  List<String> get scoreCardSubjectsMarks => _scoreCardSubjectsMarks;
  String get totalScore => _totalScore;

  List<TextEditingController> _textControlList = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController()
  ];

  List<TextEditingController> get textControlList => _textControlList;

  TextEditingController? _totalScoreController;

  TextEditingController get totalScoreController => _totalScoreController!;

  addValueToScoreCard(String subject) {
    _scoreCardSubject.add(subject);
    _scoreCardSubjectsMarks.add("");
    _textControlList.add(TextEditingController());
    notifyListeners();
  }

  removeValueToScoreCard(int index) {
    _scoreCardSubject.removeAt(index);
    _scoreCardSubjectsMarks.removeAt(index);
    _textControlList.removeAt(index);
    notifyListeners();
  }

  setValueToScoreCardMark(String marks, int index) {
    _scoreCardSubjectsMarks[index] = marks;
    notifyListeners();
  }

  setPrivacyValue(List<int> data) {
    _profileDetailsList!.data![0].privacy![0].address = data[0];
    _profileDetailsList!.data![0].privacy![0].ambition = data[1];
    _profileDetailsList!.data![0].privacy![0].dreamvacations = data[2];
    _profileDetailsList!.data![0].privacy![0].email = data[3];
    _profileDetailsList!.data![0].privacy![0].friends = data[4];
    _profileDetailsList!.data![0].privacy![0].mygroups = data[5];
    _profileDetailsList!.data![0].privacy![0].hobbies = data[6];
    _profileDetailsList!.data![0].privacy![0].privacyLibrary = data[7];
    _profileDetailsList!.data![0].privacy![0].mobileno = data[8];
    _profileDetailsList!.data![0].privacy![0].novels = data[9];
    _profileDetailsList!.data![0].privacy![0].placesvisited = data[10];
    _profileDetailsList!.data![0].privacy![0].schooladdress = data[11];
    _profileDetailsList!.data![0].privacy![0].scorecards = data[12];
    _profileDetailsList!.data![0].privacy![0].uploads = data[13];
    _profileDetailsList!.data![0].privacy![0].weakness = data[14];
    notifyListeners();
  }
}
