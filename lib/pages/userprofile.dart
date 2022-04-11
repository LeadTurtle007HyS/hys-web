import 'dart:convert';
import 'dart:typed_data';

import 'package:HyS/constants/style.dart';
import 'package:HyS/database/crud.dart';
import 'package:HyS/database/notificationdb.dart';
import 'package:HyS/pages/overView/dataload_crud.dart';
import 'package:HyS/pages/overView/notification_crud.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:draggable_widget/draggable_widget.dart';
import 'package:elegant_notification/elegant_notification.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fadein/flutter_fadein.dart';
import 'package:flutter_mentions/flutter_mentions.dart';
import 'package:flutter_placeholder_textlines/flutter_placeholder_textlines.dart';
import 'package:flutter_tex/flutter_tex.dart';
import 'package:fluttericon/entypo_icons.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:oktoast/oktoast.dart';
import 'package:readmore/readmore.dart';
import 'package:search_page/search_page.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:universal_html/html.dart';
import 'package:url_launcher/url_launcher.dart';

import 'overView/network/network_crud.dart';

class UserProfile extends StatefulWidget {
  String? user_id;
  UserProfile(this.user_id);
  @override
  _UserProfileState createState() => _UserProfileState(this.user_id);
}

class Person {
  final String userid;
  final String username;
  final String userprofilepic;
  final int userindex;

  Person(this.userid, this.username, this.userprofilepic, this.userindex);
}

class _UserProfileState extends State<UserProfile>
    with SingleTickerProviderStateMixin {
  String? user_id;
  _UserProfileState(this.user_id);
  Box<dynamic>? userDataDB;
  Box<dynamic>? questionlikedLocalDB;
  Box<dynamic>? questionbookmarkedLocalDB;
  Box<dynamic>? questionsavedLocalDB;
  Box<dynamic>? questiontoughnessLocalDB;
  Box<dynamic>? questionexamlikelyhoodLocalDB;
  Box<dynamic>? questionmydoubttooLocalDB;
  Box<dynamic>? questionmarkedimpLocalDB;
  Box<dynamic>? questionreportLocalDB;
  Box<dynamic>? questionaskReferenceLocalDB;
  Box<dynamic>? usertokendataLocalDB;
  Box<dynamic>? answerlikedLocalDB;
  Box<dynamic>? answervotesLocalDB;
  Box<dynamic>? answermarkasimpLocalDB;
  Box<dynamic>? answerhelpfulLocalDB;
  Box<dynamic>? answerCommentlikedLocalDB;
  Box<dynamic>? answerCommentReplyLocalDB;

  final dragCotroller = DragController();
  String _currentUserId = FirebaseAuth.instance.currentUser!.uid;
  List strengthSubject = [];
  List weaknessSubject = [];
  List<dynamic> selectedUserStrengthData = [];
  List<dynamic> allQuestionsWeaknessData = [];
  List<dynamic> selectedUserData = [];
  List<dynamic> userQuestionsData = [];
  List<dynamic> allQuestionsData = [];
  List<dynamic> allAnswerData = [];
  List<dynamic> userAnswerData = [];
  Map<String, List<int>> indexAnswers = {};
  NotificationCRUD notifyCRUD = NotificationCRUD();

  List<dynamic> allAnswerQuestionID = [];
  List<dynamic> allAnswersQIDwise = [];
  List<dynamic> allAnswersQIDwisebool = [];
  List<dynamic> isANSExpand = [];
  List<dynamic> likebuttonAns = [];
  List<dynamic> likeCountAns = [];
  List<dynamic> commentCountAns = [];
  List<dynamic> upvoteCountAns = [];
  List<dynamic> downVoteCountAns = [];

  List<dynamic> allAnswerCommentData = [];
  List<dynamic> allAnscmntAnswerID = [];
  List<dynamic> allAnscmntANSIDwise = [];
  List<dynamic> allAnscmntANSIDwisebool = [];
  List<dynamic> isANSCMNTExpand = [];
  List<dynamic> likebuttonAnscmnt = [];
  List<dynamic> likeCountAnscmnt = [];
  List<dynamic> replyCountAnscmnt = [];

  List<dynamic> allAnswerReplyData = [];
  List<dynamic> allAnsreplyCommentID = [];
  List<dynamic> allAnsReplyCMNTIDwise = [];
  List<dynamic> allAnsReplyCMNTIDwisebool = [];
  List<dynamic> isReplyCMNTExpand = [];
  List<dynamic> likebuttonAnsReply = [];
  List<dynamic> likeCountAnsReply = [];
  List priviousYRStrengthSubjects = [];

  List<String> subjectsList = [];

  Map<dynamic, dynamic> userData = {};
  bool dataLoaded = false;
  String selectedSubject = "";
  String selectedTopic = "";
  List<List<String>> topicList = [];
  QuerySnapshot? service;
  QuerySnapshot? topics;
  QuerySnapshot? subjects;
  QuerySnapshot? strengthData;
  QuerySnapshot? notificationToken;
  List<String> otherTopicslist = [
    "Social",
    "Environment",
    "Sports",
    "Politics",
    "General Knowledge",
    "Others"
  ];
  CrudMethods crudobj = CrudMethods();
  DataLoadCRUD dataLoad = DataLoadCRUD();
  String question = '';
  String questionType = 'text';

  GlobalKey<FlutterMentionsState> key = GlobalKey<FlutterMentionsState>();
  int tagcount = 0;
  List<String> tagids = [];
  List<String> tagedUsersName = [];
  String markupptext = '';
  bool _showList = false;
  String tagedString = "";
  bool useridentity = true;
  bool isPostReady = false;
  bool textbt = true;
  bool videocallbt = false;
  bool audiocallbt = false;
  String usercalllanguagepreference = "";
  int answerpreference = 1;
  String calltype = "";
  var _users = [
    {
      'id': 'OMjugi0iu8NEZd6MnKRKa7SkhGJ3',
      'display': 'Vivek Sharma',
      'full_name': 'DPS | Grade 7',
      'photo':
          'https://images.pexels.com/photos/220453/pexels-photo-220453.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=650&w=940'
    },
  ];

  List userPreferredLang = [];
  bool callnow = false;
  DateTime? _dTime;
  String _selectedDate = '';
  TimeOfDay? _td;
  String _selectedTime = '';
  String _endTime = '';
  final GlobalKey<State> _keyLoader = new GlobalKey<State>();

  String current_date = DateFormat.yMMMMd('en_US').format(DateTime.now());
  String current_time = DateTime.now().toString().substring(11, 15);
  String starttime = DateTime.now().toString();
  String current_onlyDate = (DateFormat('yyyyMMddkkmm').format(DateTime.now()))
      .toString()
      .substring(0, 8);
  String comparedate = DateFormat('yyyyMMddkkmm').format(DateTime.now());
  final PushNotificationDB _notificationdb = PushNotificationDB();

  //final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  //String token = "";

  //token generated for user device to get notification on that device using token
  // Future getToken() async {
  //   final fcmToken = await _fcm.getToken();
  //   setState(() {
  //     token = fcmToken!;
  //     if (token != "") {
  //       _notificationdb.updateTokenData(
  //           _currentUserId, {"token": token, "createdat": current_date});
  //     }
  //   });
  //   return fcmToken;
  // }

  List<bool> _likecountbool = [];
  List<bool> _answercountbool = [];
  List<bool> _toughnesscountbool = [];
  List<bool> _examlikelyhoodcountbool = [];

  List<int> _likecount = [];
  List<int> _answercount = [];
  List<int> _toughnesscount = [];
  List<int> _examlikelyhoodcount = [];
  List<int> _empressionscount = [];

  List<bool> likebutton = [];
  List<bool> examlikelyhoodbutton = [];
  List<bool> toughnessbutton = [];

  List<int> likebuttonpopupremove = [];
  List<int> examlikelyhoodbuttonpopupremove = [];
  List<int> toughnessbuttonpopupremove = [];

  List<dynamic> taggingData = [];
  List<dynamic> allPostData = [];
  List<dynamic> allPostLikeData = [];
  List<dynamic> allImagesData = [];
  List<dynamic> allVideosData = [];
  List<dynamic> userUploadsData = [];
  List<dynamic> uploadFilesData = [];
  List<dynamic> userAchievementsData = [];
  List<dynamic> userScorecardData = [];
  List<int> achScoreData = [];
  List<List<int>> achWiseScoreData = [];
  List<dynamic> allTaggedUsersData = [];
  List<dynamic> allMoodPostData = [];
  List<dynamic> allCausePostData = [];
  List<dynamic> allBIdeasPostData = [];
  List<dynamic> allProjectsPostData = [];
  List<dynamic> isBIdeasPostExpanded = [];
  List<dynamic> isProjectPostExpanded = [];
  List<dynamic> allCommentPostData = [];
  List<bool> isPostExpanded = [];
  List selectedUserflag = [];
  List selectedUserID = [];
  NetworkCRUD networkCRUD = NetworkCRUD();
  ScrollController? _scrollController;

  List<dynamic> allPostwiseCmntData = [];
  List<dynamic> allPostCommentIDs = [];
  List<dynamic> isCommentExpanded = [];
  List<dynamic> commentLikeCount = [];
  List<dynamic> commentReplyeCount = [];
  List<dynamic> isShowAllComment = [];

  List<dynamic> allReplyPostData = [];
  List<dynamic> allPostwiseReplyData = [];
  List<dynamic> allCmntReplyIDs = [];
  List<dynamic> isReplyExpanded = [];
  List<dynamic> ReplyLikeCount = [];
  List<dynamic> isShowAllReply = [];
  String beforeTag = '';
  TabController? _tabcontroller;
  Map<String, List<String>> map = {};
  Map<String, List<String>> mapMain = {};
  Map<String, int> qMap = {};
  Map<String, int> aMap = {};
  List<bool> strengthSubjectListBool = [];
  List<bool> weaknessSubjectListBool = [];
  List<String> subjectList = [];
  QuerySnapshot? snapSubject;
  QuerySnapshot? snap;
  var total;
  var totalSubjects;
  var totalTopics;
  List<bool> selectedBTList = [];
  List<bool> _checkselectedBTList = [];
  List<bool> selectallBTList = [];
  List<bool> deselectallBTList = [];
  double progress = 0.0;
  String base64Image = "";
  Map? totaldata;
  String latex = "";
  List tex = [''];
  final databaseReference = FirebaseDatabase.instance.reference();
  DataSnapshot? countData;
  List<dynamic> userPrivacy = [];
  List<dynamic> userPrivacyLocal = [];

  QuerySnapshot? connectionStatus;
  QuerySnapshot? allConnections;
  int totalfriendsCount = 0;
  int totalFollowersCount = 0;
  int totalFollowingCount = 0;
  bool isRequestAcceptedByMe = true;

  final List<Tab> myTabs = <Tab>[
    Tab(
        child: Row(children: [
      Text('Profile',
          style: TextStyle(
            fontFamily: 'SEGOEUI',
            fontSize: 15,
          ))
    ])),
    Tab(
        child: Row(children: [
      Text('Strengths',
          style: TextStyle(
            fontFamily: 'SEGOEUI',
            fontSize: 15,
          ))
    ])),
    Tab(
        child: Row(children: [
      Text('Weaknesses',
          style: TextStyle(
            fontFamily: 'SEGOEUI',
            fontSize: 15,
          ))
    ])),
    Tab(
        child: Row(children: [
      Text('Questions',
          style: TextStyle(
            fontFamily: 'SEGOEUI',
            fontSize: 15,
          ))
    ])),
    Tab(
        child: Row(children: [
      Text('Answers',
          style: TextStyle(
            fontFamily: 'SEGOEUI',
            fontSize: 15,
          ))
    ])),
    Tab(
        child: Row(children: [
      Text('Uploads',
          style: TextStyle(
            fontFamily: 'SEGOEUI',
            fontSize: 15,
          ))
    ])),
    Tab(
        child: Row(children: [
      Text('Achievements',
          style: TextStyle(
            fontFamily: 'SEGOEUI',
            fontSize: 15,
          ))
    ])),
    Tab(
        child: Row(children: [
      Text('Library',
          style: TextStyle(
            fontFamily: 'SEGOEUI',
            fontSize: 15,
          ))
    ])),
    Tab(
        child: Row(children: [
      Text('My Groups',
          style: TextStyle(
            fontFamily: 'SEGOEUI',
            fontSize: 15,
          ))
    ]))
  ];

  final List<String> _scrollImg = [
    "assets/shortcuts/mood.png",
    "assets/shortcuts/blog1.png",
    "assets/shortcuts/cause1.png",
    "assets/shortcuts/helpgroup.png",
    "assets/shortcuts/podcast.png",
    "assets/shortcuts/rebel.png",
    "assets/shortcuts/books.png",
    "assets/shortcuts/businessideas.png",
    "assets/shortcuts/examq.png",
    "assets/shortcuts/projects1.png",
    "assets/shortcuts/uploads.png",
    "assets/shortcuts/talents.png",
    "assets/shortcuts/predictq.png",
  ];

  final List<String> _scrollName = [
    "Feelings",
    "Blog",
    "Cause",
    "Help Group",
    "Podcast",
    "Rebel",
    "Discuss",
    "Ideas",
    "Discuss",
    "Projects",
    "Uploads",
    "Showcase",
    "Predict",
  ];

  final List<String> _scrollPostType = [
    "Mood",
    "blog",
    "EventUnderprivilegeByTeaching",
    "Helpgroup",
    "podcast",
    "rebel",
    "books",
    "businessideas",
    "examq",
    "projectdiscuss",
    "uploads",
    "talent",
    "predict"
  ];

  Future<void> _get_user_data() async {
    final http.Response response = await http.get(
      Uri.parse(
          'https://hys-api.herokuapp.com/web_get_user_data/${this.user_id}'),
    );

    print("get_user_data: ${response.statusCode}");
    if ((response.statusCode == 200) || (response.statusCode == 201)) {
      setState(() {
        selectedUserData = json.decode(response.body);
        for (int i = 0; i < taggingData.length; i++) {}
        crudobj
            .getSubjectAndTopicList(selectedUserData[0]["grade"].toString())
            .then((value) {
          setState(() {
            snap = value;
            if (snap != null) {
              total = snap!.docs.length;
              for (int i = 0; i < total; i++) {
                List<String> topicsList = [];
                subjectList.add(snap!.docs[i].get('subject').toString());
                crudobj
                    .getTopicSubjectListGradeSubjectWise(
                        selectedUserData[0]["grade"].toString(),
                        snap!.docs[i].get('subject'))
                    .then((value) {
                  setState(() {
                    snapSubject = value;
                    if (snapSubject != null) {
                      totalTopics = snapSubject!.docs.length;

                      for (int j = 0; j < totalTopics; j++) {
                        topicsList.add(snapSubject!.docs[j].get('topic'));
                      }
                      map[snap!.docs[i].get('subject')] = topicsList;
                    }
                  });
                });
              }
            }
          });
        });
      });
    }
  }

  Future<void> _get_user_languagePreference_Data() async {
    final http.Response response = await http.get(
      Uri.parse(
          'https://hys-api.herokuapp.com/web_get_user_preferred_languages_data/${this.user_id}'),
    );

    print("get_user_preferred_languages_data: ${response.statusCode}");
    if ((response.statusCode == 200) || (response.statusCode == 201)) {
      setState(() {
        List<dynamic> x = json.decode(response.body);
        for (int i = 0; i < x.length; i++) {
          userPreferredLang.add(x[i][0]);
        }
      });
    }
  }

  Future<void> _get_user_strength_Data() async {
    final http.Response response = await http.get(
      Uri.parse(
          'https://hys-api.herokuapp.com/web_get_user_strength_data/${this.user_id}'),
    );

    print("get_user_preferred_languages_data: ${response.statusCode}");
    if ((response.statusCode == 200) || (response.statusCode == 201)) {
      setState(() {
        selectedUserStrengthData = json.decode(response.body);
        for (int i = 0; i < selectedUserStrengthData.length; i++) {
          int count = 0;
          for (int j = 0; j < strengthSubject.length; j++) {
            if (strengthSubject[j] == selectedUserStrengthData[i]["subject"]) {
              count++;
            }
          }
          if (count == 0) {
            strengthSubject.add(selectedUserStrengthData[i]["subject"]);
            print("strengthSubject:$strengthSubject");
          }
        }
      });
    }
  }

  Future<void> _get_user_weakness_Data() async {
    final http.Response response = await http.get(
      Uri.parse(
          'https://hys-api.herokuapp.com/web_get_user_weakness_data/${this.user_id}'),
    );

    print("get_user_preferred_languages_data: ${response.statusCode}");
    if ((response.statusCode == 200) || (response.statusCode == 201)) {
      setState(() {
        allQuestionsWeaknessData = json.decode(response.body);
        for (int i = 0; i < allQuestionsWeaknessData.length; i++) {
          int count = 0;
          for (int j = 0; j < weaknessSubject.length; j++) {
            if (weaknessSubject[j] == allQuestionsWeaknessData[i]["subject"]) {
              count++;
            }
          }
          if (count == 0) {
            weaknessSubject.add(allQuestionsWeaknessData[i]["subject"]);
            print("weaknessSubject:$weaknessSubject");
          }
        }
      });
    }
  }

  Future<void> _get_user_questions_posted() async {
    userQuestionsData = [];
    final http.Response response = await http.get(
      Uri.parse(
          'https://hys-api.herokuapp.com/web_get_user_questions_posted/${this.user_id}'),
    );
    print("get_user_questions_posted: ${response.statusCode}");
    if ((response.statusCode == 200) || (response.statusCode == 201)) {
      setState(() {
        userQuestionsData = json.decode(response.body);
        for (int i = 0; i < userQuestionsData.length; i++) {
          if (qMap.containsKey(userQuestionsData[i]['subject']) == true) {
            qMap[userQuestionsData[i]['subject']] =
                qMap[userQuestionsData[i]['subject']!]! + 1;
          } else {
            qMap[userQuestionsData[i]['subject']] = 1;
          }
        }
      });
    }
  }

  Future<void> _get_user_answers_posted() async {
    aMap.clear();
    indexAnswers.clear();
    final http.Response response = await http.get(
      Uri.parse(
          'https://hys-api.herokuapp.com/web_get_user_answers_posted/${this.user_id}'),
    );
    print("get_user_answer_posted: ${response.statusCode}");
    if ((response.statusCode == 200) || (response.statusCode == 201)) {
      setState(() {
        userAnswerData = json.decode(response.body);
        for (int j = 0; j < userAnswerData.length; j++) {
          if (aMap.containsKey(userAnswerData[j]['subject']) == false) {
            aMap[userAnswerData[j]['subject']] = 1;
          } else {
            aMap[userAnswerData[j]['subject']] =
                aMap[userAnswerData[j]['subject']!]! + 1;
          }
          if (indexAnswers.containsKey(userAnswerData[j]['subject']) == false) {
            indexAnswers[userAnswerData[j]['subject']] = [j];
          } else {
            List<int> x = indexAnswers[userAnswerData[j]['subject']]!;
            x.add(j);

            indexAnswers[userAnswerData[j]['subject']] = x;
          }
        }
      });
    }
  }

  Future<void> _get_all_questions_posted() async {
    allQuestionsData = [];

    final http.Response response = await http.get(
      Uri.parse('https://hys-api.herokuapp.com/web_get_all_questions_posted'),
    );
    print("get_all_questions_posted: ${response.statusCode}");
    if ((response.statusCode == 200) || (response.statusCode == 201)) {
      setState(() {
        allQuestionsData = json.decode(response.body);
      });
    }
  }

  Future<void> _get_all_answers_posted() async {
    final http.Response response = await http.get(
      Uri.parse('https://hys-api.herokuapp.com/web_get_all_answer_posted'),
    );
    print("get_all_answer_posted: ${response.statusCode}");
    if ((response.statusCode == 200) || (response.statusCode == 201)) {
      setState(() {
        allAnswerData = json.decode(response.body);
      });
    }
  }

  Future<void> _get_all_users_data_for_tagging() async {
    final http.Response response = await http.get(
      Uri.parse(
          'https://hys-api.herokuapp.com/web_get_all_users_data_for_tagging'),
    );

    print("get_all_users_data_for_taggigng: ${response.statusCode}");
    if ((response.statusCode == 200) || (response.statusCode == 201)) {
      setState(() {
        taggingData = json.decode(response.body);
        for (int i = 0; i < taggingData.length; i++) {
          if (taggingData[i]["user_id"].toString() !=
              userDataDB!.get("user_id")) {
            _users.add({
              'id': taggingData[i]["user_id"].toString(),
              'display': taggingData[i]["first_name"].toString() +
                  " " +
                  taggingData[i]["last_name"].toString(),
              'full_name': taggingData[i]["school_name"].toString() +
                  " | " +
                  taggingData[i]["grade"].toString(),
              'photo': taggingData[i]["profilepic"].toString()
            });
          }
          selectedUserflag.add(false);
        }
      });
    }
  }

  Future<void> _get_all_post_details() async {
    final http.Response response = await http.get(
      Uri.parse('https://hys-api.herokuapp.com/web_get_all_sm_posts'),
    );

    print("get_all_sm_posts: ${response.statusCode}");
    if ((response.statusCode == 200) || (response.statusCode == 201)) {
      isShowAllComment = [];
      isPostExpanded = [];
      setState(() {
        allPostData = json.decode(response.body);
        for (int i = 0; i < allPostData.length; i++) {
          isPostExpanded.add(false);
          isShowAllComment.add(false);
          allPostLikeData.add("likeinit");
        }
      });
    }
  }

  Future<void> _get_all_attached_images() async {
    final http.Response response = await http.get(
      Uri.parse('https://hys-api.herokuapp.com/web_get_all_sm_images'),
    );

    print("get_all_sm_images: ${response.statusCode}");
    if ((response.statusCode == 200) || (response.statusCode == 201)) {
      setState(() {
        allImagesData = json.decode(response.body);
      });
    }
  }

  Future<void> _get_all_attached_videos() async {
    final http.Response response = await http.get(
      Uri.parse('https://hys-api.herokuapp.com/web_get_all_sm_videos'),
    );

    print("get_all_sm_videos: ${response.statusCode}");
    if ((response.statusCode == 200) || (response.statusCode == 201)) {
      setState(() {
        allVideosData = json.decode(response.body);
      });
    }
  }

  Future<void> _get_all_tagged_users() async {
    final http.Response response = await http.get(
      Uri.parse('https://hys-api.herokuapp.com/web_get_all_sm_usertagged'),
    );

    print("get_all_sm_usertagged: ${response.statusCode}");
    if ((response.statusCode == 200) || (response.statusCode == 201)) {
      setState(() {
        allTaggedUsersData = json.decode(response.body);
      });
    }
  }

  Future<void> _get_all_mood_post_details() async {
    final http.Response response = await http.get(
      Uri.parse('https://hys-api.herokuapp.com/web_get_all_sm_mood_posts'),
    );

    print("get_all_sm_mood_posts: ${response.statusCode}");
    if ((response.statusCode == 200) || (response.statusCode == 201)) {
      setState(() {
        allMoodPostData = json.decode(response.body);
      });
    }
  }

  Future<void> _get_all_comment_post_details() async {
    comparedate = DateFormat('yyyyMMddkkmm').format(DateTime.now());
    allCommentPostData = [];
    allPostwiseCmntData = [];
    allPostCommentIDs = [];
    isCommentExpanded = [];
    commentLikeCount = [];
    commentReplyeCount = [];

    final http.Response response = await http.get(
      Uri.parse('https://hys-api.herokuapp.com/web_get_all_sm_comment_posts'),
    );

    print("get_all_sm_comment_posts: ${response.statusCode}");
    if ((response.statusCode == 200) || (response.statusCode == 201)) {
      setState(() {
        allCommentPostData = json.decode(response.body);
        for (int i = 0; i < allCommentPostData.length; i++) {
          if (allPostCommentIDs.isEmpty) {
            allPostCommentIDs.add(allCommentPostData[i]["post_id"]);
            allPostwiseCmntData.add([]);
            isCommentExpanded.add([]);
            commentLikeCount.add([]);
            commentReplyeCount.add([]);
          } else {
            int count = 0;
            for (int j = 0; j < allPostCommentIDs.length; j++) {
              if (allPostCommentIDs[j] == allCommentPostData[i]["post_id"]) {
                count++;
                break;
              }
            }
            if (count == 0) {
              allPostCommentIDs.add(allCommentPostData[i]["post_id"]);
              allPostwiseCmntData.add([]);
              isCommentExpanded.add([]);
              commentLikeCount.add([]);
              commentReplyeCount.add([]);
            }
          }
          for (int j = 0; j < allPostCommentIDs.length; j++) {
            if (allPostCommentIDs[j] == allCommentPostData[i]["post_id"]) {
              allPostwiseCmntData[j].add(allCommentPostData[i]);
              isCommentExpanded[j].add(false);
              commentLikeCount[j].add(allCommentPostData[i]["like_count"]);
              commentReplyeCount[j].add(allCommentPostData[i]["reply_count"]);
            }
          }
        }
      });
    }
  }

  Future<void> _get_all_reply_post_details() async {
    comparedate = DateFormat('yyyyMMddkkmm').format(DateTime.now());
    allReplyPostData = [];
    allPostwiseReplyData = [];
    allCmntReplyIDs = [];
    isReplyExpanded = [];
    ReplyLikeCount = [];
    isShowAllReply = [];

    final http.Response response = await http.get(
      Uri.parse('https://hys-api.herokuapp.com/web_get_all_sm_reply_posts'),
    );

    print("get_all_sm_reply_posts: ${response.statusCode}");
    if ((response.statusCode == 200) || (response.statusCode == 201)) {
      setState(() {
        allReplyPostData = json.decode(response.body);
        for (int i = 0; i < allReplyPostData.length; i++) {
          if (allCmntReplyIDs.isEmpty) {
            allCmntReplyIDs.add(allReplyPostData[i]["comment_id"]);
            allPostwiseReplyData.add([]);
            isReplyExpanded.add([]);
            ReplyLikeCount.add([]);
            isShowAllReply.add(false);
          } else {
            int count = 0;
            for (int j = 0; j < allCmntReplyIDs.length; j++) {
              if (allCmntReplyIDs[j] == allReplyPostData[i]["comment_id"]) {
                count++;
                break;
              }
            }
            if (count == 0) {
              allCmntReplyIDs.add(allReplyPostData[i]["comment_id"]);
              allPostwiseReplyData.add([]);
              isReplyExpanded.add([]);
              ReplyLikeCount.add([]);
              isShowAllReply.add(false);
            }
          }
          for (int j = 0; j < allCmntReplyIDs.length; j++) {
            if (allCmntReplyIDs[j] == allReplyPostData[i]["comment_id"]) {
              allPostwiseReplyData[j].add(allReplyPostData[i]);
              isReplyExpanded[j].add(false);
              ReplyLikeCount[j].add(allReplyPostData[i]["like_count"]);
            }
          }
        }
      });
    }
  }

  Future<void> _get_all_cause_post_details() async {
    final http.Response response = await http.get(
      Uri.parse('https://hys-api.herokuapp.com/web_get_all_sm_cause_posts'),
    );

    print("get_all_sm_cause_posts: ${response.statusCode}");
    if ((response.statusCode == 200) || (response.statusCode == 201)) {
      setState(() {
        allCausePostData = json.decode(response.body);
      });
    }
  }

  Future<void> _get_all_bideas_post_details() async {
    final http.Response response = await http.get(
      Uri.parse('https://hys-api.herokuapp.com/web_get_all_sm_bideas_posts'),
    );

    print("get_all_sm_bideas_posts: ${response.statusCode}");
    if ((response.statusCode == 200) || (response.statusCode == 201)) {
      setState(() {
        allBIdeasPostData = json.decode(response.body);
        for (int i = 0; i < allBIdeasPostData.length; i++) {
          setState(() {
            isBIdeasPostExpanded.add(false);
          });
        }
      });
    }
  }

  Future<void> _get_all_project_post_details() async {
    final http.Response response = await http.get(
      Uri.parse('https://hys-api.herokuapp.com/web_get_all_sm_project_posts'),
    );

    print("get_all_sm_project_posts: ${response.statusCode}");
    if ((response.statusCode == 200) || (response.statusCode == 201)) {
      setState(() {
        allProjectsPostData = json.decode(response.body);
        for (int i = 0; i < allProjectsPostData.length; i++) {
          setState(() {
            isProjectPostExpanded.add(false);
          });
        }
      });
    }
  }

  List<String> uploadTypeList = [
    "School Exams",
    "Class Notes",
    "Cometitve Exams",
    "Others"
  ];
  List<List<String>> subjectsOfUploads = [];
  Future<void> _get_user_uploads() async {
    final http.Response response = await http.get(
      Uri.parse(
          'https://hys-api.herokuapp.com/web_get_user_uploads/${this.user_id}'),
    );

    print("get_user_uploads: ${response.statusCode}");
    if ((response.statusCode == 200) || (response.statusCode == 201)) {
      setState(() {
        userUploadsData = json.decode(response.body);
        for (int i = 0; i < uploadTypeList.length; i++) {
          List<String> subjects = [];
          for (int j = 0; j < userUploadsData.length; j++) {
            if ((userUploadsData[j]["upload_type"] == uploadTypeList[i])) {
              if (subjects.isEmpty) {
                subjects.add(userUploadsData[j]["subject"]);
              } else {
                int count = 0;
                for (int k = 0; k < subjects.length; k++) {
                  if ((userUploadsData[j]["subject"] == subjects[k])) {
                    count++;
                    break;
                  }
                }
                if (count == 0) {
                  subjects.add(userUploadsData[j]["subject"]);
                }
              }
            }
          }
          subjectsOfUploads.add(subjects);
        }
      });
    }
  }

  Future<void> _get_all_upload_files_details() async {
    final http.Response response = await http.get(
      Uri.parse('https://hys-api.herokuapp.com/web_get_user_upload_files'),
    );

    print("get_user_upload_files: ${response.statusCode}");
    if ((response.statusCode == 200) || (response.statusCode == 201)) {
      setState(() {
        uploadFilesData = json.decode(response.body);
      });
    }
  }

  Future<void> _get_user_achievement_details() async {
    userAchievementsData = [];
    userScorecardData = [];
    achScoreData = [];
    achWiseScoreData = [];
    final http.Response response = await http.get(
      Uri.parse(
          'https://hys-api.herokuapp.com/web_get_user_achievement_details/${this.user_id}'),
    );

    print("get_user_achievement_details: ${response.statusCode}");
    if ((response.statusCode == 200) || (response.statusCode == 201)) {
      setState(() {
        userAchievementsData = json.decode(response.body);
        _get_user_scorecard_details();
      });
    }
  }

  Future<void> _get_user_scorecard_details() async {
    final http.Response response = await http.get(
      Uri.parse(
          'https://hys-api.herokuapp.com/web_get_user_scorecard_details/${this.user_id}'),
    );

    print("get_user_scorecard_details: ${response.statusCode}");
    if ((response.statusCode == 200) || (response.statusCode == 201)) {
      setState(() {
        userScorecardData = json.decode(response.body);
      });
    }
  }

  Future<void> _get_user_privacy_details() async {
    userPrivacyLocal = [];
    userPrivacy = [];
    final http.Response response = await http.get(
      Uri.parse(
          'https://hys-api.herokuapp.com/web_get_user_privacy/${this.user_id}'),
    );

    print("get_user_privacy: ${response.statusCode}");
    if ((response.statusCode == 200) || (response.statusCode == 201)) {
      setState(() {
        userPrivacy = json.decode(response.body);
        userPrivacyLocal = userPrivacy;
      });
    }
  }

  PanelController _pc = new PanelController();
  List<String> finalSelectedStrengthSubjects = [];
  List<List<String>> finalSelectedStrengthTopics = [];
  List<String> subjectListStrength = [];
  List<bool> boolSubjectList = [];
  List<List<String>> topicListStrength = [];
  List<List<bool>> boolTopicsList = [];
  List<int> selectedtopicsbysubject = [];
  int panelSubjectIndex = 0;
  int totalselectedTopiccount = 0;
  List<Person> myfollowings = [];
  List<Person> myfollowers = [];
  List<Person> myfriends = [];
  QuerySnapshot? myConnections;
  QuerySnapshot? allUserData;

  _loadStrengthWeaknessData() {
    subjectListStrength = [];
    boolSubjectList = [];
    selectedtopicsbysubject = [];
    topicListStrength = [];
    boolTopicsList = [];

    crudobj
        .getGradeSubjectList("Central Board of Secondary Education (CBSE)")
        .then((value) {
      setState(() {
        subjects = value;
        if ((subjects != null)) {
          for (int i = 0; i < subjects!.docs.length; i++) {
            if ((subjects!.docs[i].get("grade") ==
                (userDataDB!.get("grade") - 1).toString())) {
              subjectListStrength.add(subjects!.docs[i].get("subject"));
              boolSubjectList.add(false);
              selectedtopicsbysubject.add(0);
            }
          }
          crudobj
              .getTopicSubjectList(
                  "Central Board of Secondary Education (CBSE)")
              .then((value) {
            setState(() {
              topics = value;
              if (topics != null) {
                for (int i = 0; i < subjectListStrength.length; i++) {
                  List<String> subjectTopics = [];
                  List<bool> boolsubjectTopics = [];
                  for (int j = 0; j < topics!.docs.length; j++) {
                    if ((topics!.docs[j].get("grade") ==
                            (userDataDB!.get("grade") - 1).toString()) &&
                        (topics!.docs[j].get("subject") ==
                            subjectListStrength[i])) {
                      subjectTopics.add(topics!.docs[j].get("topic"));
                      boolsubjectTopics.add(false);
                    }
                  }
                  topicListStrength.add(subjectTopics);
                  boolTopicsList.add(boolsubjectTopics);
                }
              }
            });
          });
        }
      });
    });
  }

  void _call_apis() {
    _get_user_data();
    _get_user_achievement_details();
    _get_user_languagePreference_Data();
    _get_user_strength_Data();
    _get_all_upload_files_details();
    _get_user_weakness_Data();
    _get_user_uploads();
    _get_user_questions_posted();
    _get_user_answers_posted();
    _get_all_questions_posted();
    _get_all_answers_posted();
    _get_all_users_data_for_tagging();
    _loadStrengthWeaknessData();
    _get_all_attached_images();
    _get_all_attached_videos();
    _get_all_tagged_users();
    _get_all_post_details();
    _get_user_privacy_details();
    _get_all_upload_files_details();
    _get_all_mood_post_details();
    _get_all_comment_post_details();
    _get_all_reply_post_details();
    _get_all_cause_post_details();
    _get_all_bideas_post_details();
    _get_all_project_post_details();
  }

  void initState() {
    userDataDB = Hive.box<dynamic>('userdata');
    _call_apis();
    _tabcontroller = TabController(length: 9, vsync: this);
    _scrollController = ScrollController();
    connectionStatusCall();
    crudobj.getAllUserData().then((value) {
      setState(() {
        allUserData = value;
        if (allUserData != null) {
          crudobj.getUserConnection().then((value) {
            setState(() {
              myConnections = value;
              if (myConnections != null) {
                for (int k = 0; k < myConnections!.docs.length; k++) {
                  if ((myConnections!.docs[k].get("userid") == this.user_id) &&
                      (myConnections!.docs[k].get("isfollowing") == true)) {
                    for (int d = 0; d < allUserData!.docs.length; d++) {
                      if (allUserData!.docs[d].get("userid") ==
                          myConnections!.docs[k].get("otheruserid")) {
                        myfollowings.add(Person(
                            allUserData!.docs[d].get("userid"),
                            allUserData!.docs[d].get("firstname") +
                                " " +
                                allUserData!.docs[d].get("lastname"),
                            allUserData!.docs[d].get("profilepic"),
                            d));
                      }
                    }
                  }

                  if ((myConnections!.docs[k].get("otheruserid") ==
                          this.user_id) &&
                      (myConnections!.docs[k].get("isfollowing") == true)) {
                    for (int d = 0; d < allUserData!.docs.length; d++) {
                      if (allUserData!.docs[d].get("userid") ==
                          myConnections!.docs[k].get("userid")) {
                        myfollowers.add(Person(
                            allUserData!.docs[d].get("userid"),
                            allUserData!.docs[d].get("firstname") +
                                " " +
                                allUserData!.docs[d].get("lastname"),
                            allUserData!.docs[d].get("profilepic"),
                            d));
                      }
                    }
                  }
                  if (((myConnections!.docs[k].get("isrequestaccepted") ==
                          true) &&
                      (myConnections!.docs[k].get("isfriend") == true))) {
                    if (myConnections!.docs[k].get("userid") == this.user_id) {
                      for (int d = 0; d < allUserData!.docs.length; d++) {
                        if (allUserData!.docs[d].get("userid") ==
                            myConnections!.docs[k].get("otheruserid")) {
                          myfriends.add(Person(
                              allUserData!.docs[d].get("userid"),
                              allUserData!.docs[d].get("firstname") +
                                  " " +
                                  allUserData!.docs[d].get("lastname"),
                              allUserData!.docs[d].get("profilepic"),
                              d));
                        }
                      }
                    }
                  }
                }
              }
            });
          });
        }
      });
    });

    super.initState();
  }

  void connectionStatusCall() {
    totalfriendsCount = 0;
    totalFollowersCount = 0;
    totalFollowingCount = 0;
    isRequestAcceptedByMe = true;
    //  connectionStatus = null;
    crudobj.getUserConnectionStatus(this.user_id!).then((value) {
      setState(() {
        connectionStatus = value;
      });
    });

    crudobj.getUserConnection().then((value) {
      setState(() {
        allConnections = value;
        if (allConnections != null) {
          for (int i = 0; i < allConnections!.docs.length; i++) {
            if (allConnections!.docs[i].get("userid") == this.user_id) {
              if (allConnections!.docs[i].get("isfollowing") == true) {
                totalFollowingCount++;
              }
              if ((allConnections!.docs[i].get("isfriend") == true) &&
                  (allConnections!.docs[i].get("isrequestaccepted") == true)) {
                totalfriendsCount++;
              }
            }
            if (allConnections!.docs[i].get("otheruserid") == this.user_id) {
              if (allConnections!.docs[i].get("isfollowing") == true) {
                totalFollowersCount++;
              }
            }
            if ((allConnections!.docs[i].get("otheruserid") ==
                    _currentUserId) &&
                (allConnections!.docs[i].get("userid") == this.user_id)) {
              if ((allConnections!.docs[i].get("isrequestaccepted") == false)) {
                setState(() {
                  isRequestAcceptedByMe = false;
                });
              } else {
                setState(() {
                  isRequestAcceptedByMe = true;
                });
              }
            }
          }
        }
      });
    });
  }

  int checking = 0;
  @override
  Widget build(BuildContext context) {
    databaseReference.child("hysweb").once().then((DataSnapshot snapshot) {
      setState(() {
        if (mounted) {
          setState(() {
            countData = snapshot;
          });
        }
      });
    });
    if ((selectedUserStrengthData.isNotEmpty) &&
        (allQuestionsWeaknessData.isNotEmpty) &&
        (userPreferredLang.isNotEmpty) &&
        (connectionStatus != null) &&
        (allConnections != null) &&
        (myConnections != null) &&
        (allUserData != null) &&
        (selectedUserData.isNotEmpty) &&
        (snap != null) &&
        (snapSubject != null)) {
      if (checking == 0) {
        for (int i = 0; i < userAchievementsData.length; i++) {
          if (userAchievementsData[i]["ach_type"] == "scorecard") {
            achScoreData.add(i);
            List<int> scoreIDs = [];
            for (int j = 0; j < userScorecardData.length; j++) {
              if (userScorecardData[j]["achievement_id"] ==
                  userAchievementsData[i]["achievement_id"]) {
                scoreIDs.add(j);
              }
            }
            achWiseScoreData.add(scoreIDs);
          }
        }
        checking++;
      }
      String friendButtonText = isRequestAcceptedByMe == false
          ? "Accept"
          : connectionStatus!.docs.length == 0
              ? 'Add Friend'
              : ((connectionStatus!.docs[0].get("isrequestaccepted") ==
                          false) &&
                      (connectionStatus!.docs[0].get("isfriend") == true) &&
                      ((connectionStatus!.docs[0].get("onlyfollowing") ==
                          false)))
                  ? "Cancel Request"
                  : ((connectionStatus!.docs[0].get("isrequestaccepted") ==
                              true) &&
                          (connectionStatus!.docs[0].get("isfriend") == true) &&
                          ((connectionStatus!.docs[0].get("onlyfollowing") ==
                              false)))
                      ? "Friends"
                      : "Add Friend";
      return SlidingUpPanel(
        controller: _pc,
        minHeight: 1,
        maxHeight: MediaQuery.of(context).size.height - 400,
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                width: 500,
                child: Column(
                  children: [
                    SizedBox(
                      height: 30,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        IconButton(
                          onPressed: () {
                            databaseReference
                                .child("hysweb")
                                .child("qANDa")
                                .child("jump_to_listview_index")
                                .update({"$_currentUserId": 0});

                            databaseReference
                                .child("hysweb")
                                .child("social")
                                .child("jump_to_listview_index")
                                .update({"$_currentUserId": 0});
                            databaseReference
                                .child("hysweb")
                                .child("app_bar_navigation")
                                .child(FirebaseAuth.instance.currentUser!.uid)
                                .update({"$_currentUserId": 1});
                          },
                          icon: Tab(
                              child: Icon(Icons.arrow_back_ios_outlined,
                                  color: Colors.black54, size: 20)),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          InkWell(
                            onTap: () {},
                            child: CircleAvatar(
                              radius: 40,
                              backgroundColor: Colors.white,
                              backgroundImage: NetworkImage(
                                  selectedUserData[0]['profilepic']),
                            ),
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    "${selectedUserData[0]['first_name']} ${selectedUserData[0]['last_name']}",
                                    style: GoogleFonts.montserrat(
                                        textStyle: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w700,
                                    )),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 2,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                      "${selectedUserData[0]['school_name']}, ${selectedUserData[0]['city']}",
                                      style: TextStyle(
                                          color: Colors.black87,
                                          fontSize: 13,
                                          fontWeight: FontWeight.normal)),
                                ],
                              ),
                              SizedBox(
                                height: 2,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                      "Grade: " +
                                          selectedUserData[0]['grade']
                                              .toString(),
                                      style: TextStyle(
                                          color: Colors.black87,
                                          fontSize: 12,
                                          fontWeight: FontWeight.normal)),
                                ],
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  InkWell(
                                    onTap: () {
                                      if (myfollowings.length > 0) {
                                        showSearch(
                                          context: context,
                                          delegate: SearchPage<Person>(
                                              onQueryUpdate: (s) => print(s),
                                              items: myfollowings,
                                              suggestion: ListView.builder(
                                                itemCount: myfollowings.length,
                                                itemBuilder: (context, index) {
                                                  final Person person =
                                                      myfollowings[index];
                                                  return InkWell(
                                                    onTap: () {
                                                      databaseReference
                                                          .child("hysweb")
                                                          .child(
                                                              "app_bar_navigation")
                                                          .child(FirebaseAuth
                                                              .instance
                                                              .currentUser!
                                                              .uid)
                                                          .update({
                                                        "$_currentUserId": 5,
                                                        "userid": person.userid
                                                      });
                                                    },
                                                    child: Container(
                                                      margin: EdgeInsets.all(2),
                                                      padding:
                                                          EdgeInsets.all(2),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        children: [
                                                          InkWell(
                                                              onTap: () {
                                                                databaseReference
                                                                    .child(
                                                                        "hysweb")
                                                                    .child(
                                                                        "app_bar_navigation")
                                                                    .child(FirebaseAuth
                                                                        .instance
                                                                        .currentUser!
                                                                        .uid)
                                                                    .update({
                                                                  "$_currentUserId":
                                                                      5,
                                                                  "userid":
                                                                      person
                                                                          .userid
                                                                });
                                                              },
                                                              child: Container(
                                                                margin:
                                                                    EdgeInsets
                                                                        .all(
                                                                            10),
                                                                height: 45,
                                                                width: 45,
                                                                decoration:
                                                                    new BoxDecoration(
                                                                  shape: BoxShape
                                                                      .circle,
                                                                ),
                                                                child:
                                                                    ClipRRect(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              25.0),
                                                                  child:
                                                                      CachedNetworkImage(
                                                                    imageUrl: person
                                                                        .userprofilepic,
                                                                    fit: BoxFit
                                                                        .cover,
                                                                    placeholder:
                                                                        (context,
                                                                                url) =>
                                                                            Container(
                                                                      height:
                                                                          30,
                                                                      width: 30,
                                                                      child: Image
                                                                          .network(
                                                                        "https://firebasestorage.googleapis.com/v0/b/hys-pro-41c66.appspot.com/o/assets%2Floadingimg.gif?alt=media&token=4ca910f2-c584-4b3a-bbcb-2f1c01d93f67",
                                                                      ),
                                                                    ),
                                                                    errorWidget: (context,
                                                                            url,
                                                                            error) =>
                                                                        Icon(Icons
                                                                            .error),
                                                                  ),
                                                                ),
                                                              )),
                                                          SizedBox(
                                                            width: 5,
                                                          ),
                                                          Text(
                                                            person.username,
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  'Nunito Sans',
                                                              fontSize: 18,
                                                              color: Color
                                                                  .fromRGBO(
                                                                      0,
                                                                      0,
                                                                      0,
                                                                      0.8),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                              failure: Center(
                                                child:
                                                    Text('No person found :('),
                                              ),
                                              filter: (person) =>
                                                  [person.username],
                                              builder: (person) => InkWell(
                                                    onTap: () {
                                                      databaseReference
                                                          .child("hysweb")
                                                          .child(
                                                              "app_bar_navigation")
                                                          .child(FirebaseAuth
                                                              .instance
                                                              .currentUser!
                                                              .uid)
                                                          .update({
                                                        "$_currentUserId": 5,
                                                        "userid": person.userid
                                                      });
                                                    },
                                                    child: Container(
                                                      margin: EdgeInsets.all(2),
                                                      padding:
                                                          EdgeInsets.all(2),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        children: [
                                                          InkWell(
                                                              onTap: () {
                                                                databaseReference
                                                                    .child(
                                                                        "hysweb")
                                                                    .child(
                                                                        "app_bar_navigation")
                                                                    .child(FirebaseAuth
                                                                        .instance
                                                                        .currentUser!
                                                                        .uid)
                                                                    .update({
                                                                  "$_currentUserId":
                                                                      5,
                                                                  "userid":
                                                                      person
                                                                          .userid
                                                                });
                                                              },
                                                              child: Container(
                                                                margin:
                                                                    EdgeInsets
                                                                        .all(
                                                                            10),
                                                                height: 45,
                                                                width: 45,
                                                                decoration:
                                                                    new BoxDecoration(
                                                                  shape: BoxShape
                                                                      .circle,
                                                                ),
                                                                child:
                                                                    ClipRRect(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              25.0),
                                                                  child:
                                                                      CachedNetworkImage(
                                                                    imageUrl: person
                                                                        .userprofilepic,
                                                                    fit: BoxFit
                                                                        .cover,
                                                                    placeholder:
                                                                        (context,
                                                                                url) =>
                                                                            Container(
                                                                      height:
                                                                          30,
                                                                      width: 30,
                                                                      child: Image
                                                                          .network(
                                                                        "https://firebasestorage.googleapis.com/v0/b/hys-pro-41c66.appspot.com/o/assets%2Floadingimg.gif?alt=media&token=4ca910f2-c584-4b3a-bbcb-2f1c01d93f67",
                                                                      ),
                                                                    ),
                                                                    errorWidget: (context,
                                                                            url,
                                                                            error) =>
                                                                        Icon(Icons
                                                                            .error),
                                                                  ),
                                                                ),
                                                              )),
                                                          SizedBox(
                                                            width: 5,
                                                          ),
                                                          Text(
                                                            person.username,
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  'Nunito Sans',
                                                              fontSize: 18,
                                                              color: Color
                                                                  .fromRGBO(
                                                                      0,
                                                                      0,
                                                                      0,
                                                                      0.8),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  )),
                                        );
                                      }
                                    },
                                    child: Container(
                                      child: Text(
                                          "${totalFollowingCount.toString()} Following  |  ",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: Colors.black54,
                                              fontSize: 15,
                                              fontWeight: FontWeight.w800)),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      if (myfollowers.length > 0) {
                                        showSearch(
                                          context: context,
                                          delegate: SearchPage<Person>(
                                              onQueryUpdate: (s) => print(s),
                                              items: myfollowings,
                                              suggestion: ListView.builder(
                                                itemCount: myfollowers.length,
                                                itemBuilder: (context, index) {
                                                  final Person person =
                                                      myfollowers[index];
                                                  return InkWell(
                                                    onTap: () {
                                                      databaseReference
                                                          .child("hysweb")
                                                          .child(
                                                              "app_bar_navigation")
                                                          .child(FirebaseAuth
                                                              .instance
                                                              .currentUser!
                                                              .uid)
                                                          .update({
                                                        "$_currentUserId": 5,
                                                        "userid": person.userid
                                                      });
                                                    },
                                                    child: Container(
                                                      margin: EdgeInsets.all(2),
                                                      padding:
                                                          EdgeInsets.all(2),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        children: [
                                                          InkWell(
                                                              onTap: () {
                                                                databaseReference
                                                                    .child(
                                                                        "hysweb")
                                                                    .child(
                                                                        "app_bar_navigation")
                                                                    .child(FirebaseAuth
                                                                        .instance
                                                                        .currentUser!
                                                                        .uid)
                                                                    .update({
                                                                  "$_currentUserId":
                                                                      5,
                                                                  "userid":
                                                                      person
                                                                          .userid
                                                                });
                                                              },
                                                              child: Container(
                                                                margin:
                                                                    EdgeInsets
                                                                        .all(
                                                                            10),
                                                                height: 45,
                                                                width: 45,
                                                                decoration:
                                                                    new BoxDecoration(
                                                                  shape: BoxShape
                                                                      .circle,
                                                                ),
                                                                child:
                                                                    ClipRRect(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              25.0),
                                                                  child:
                                                                      CachedNetworkImage(
                                                                    imageUrl: person
                                                                        .userprofilepic,
                                                                    fit: BoxFit
                                                                        .cover,
                                                                    placeholder:
                                                                        (context,
                                                                                url) =>
                                                                            Container(
                                                                      height:
                                                                          30,
                                                                      width: 30,
                                                                      child: Image
                                                                          .network(
                                                                        "https://firebasestorage.googleapis.com/v0/b/hys-pro-41c66.appspot.com/o/assets%2Floadingimg.gif?alt=media&token=4ca910f2-c584-4b3a-bbcb-2f1c01d93f67",
                                                                      ),
                                                                    ),
                                                                    errorWidget: (context,
                                                                            url,
                                                                            error) =>
                                                                        Icon(Icons
                                                                            .error),
                                                                  ),
                                                                ),
                                                              )),
                                                          SizedBox(
                                                            width: 5,
                                                          ),
                                                          Text(
                                                            person.username,
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  'Nunito Sans',
                                                              fontSize: 18,
                                                              color: Color
                                                                  .fromRGBO(
                                                                      0,
                                                                      0,
                                                                      0,
                                                                      0.8),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                              failure: Center(
                                                child:
                                                    Text('No person found :('),
                                              ),
                                              filter: (person) =>
                                                  [person.username],
                                              builder: (person) => InkWell(
                                                    onTap: () {
                                                      databaseReference
                                                          .child("hysweb")
                                                          .child(
                                                              "app_bar_navigation")
                                                          .child(FirebaseAuth
                                                              .instance
                                                              .currentUser!
                                                              .uid)
                                                          .update({
                                                        "$_currentUserId": 5,
                                                        "userid": person.userid
                                                      });
                                                    },
                                                    child: Container(
                                                      margin: EdgeInsets.all(2),
                                                      padding:
                                                          EdgeInsets.all(2),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        children: [
                                                          InkWell(
                                                              onTap: () {
                                                                databaseReference
                                                                    .child(
                                                                        "hysweb")
                                                                    .child(
                                                                        "app_bar_navigation")
                                                                    .child(FirebaseAuth
                                                                        .instance
                                                                        .currentUser!
                                                                        .uid)
                                                                    .update({
                                                                  "$_currentUserId":
                                                                      5,
                                                                  "userid":
                                                                      person
                                                                          .userid
                                                                });
                                                              },
                                                              child: Container(
                                                                margin:
                                                                    EdgeInsets
                                                                        .all(
                                                                            10),
                                                                height: 45,
                                                                width: 45,
                                                                decoration:
                                                                    new BoxDecoration(
                                                                  shape: BoxShape
                                                                      .circle,
                                                                ),
                                                                child:
                                                                    ClipRRect(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              25.0),
                                                                  child:
                                                                      CachedNetworkImage(
                                                                    imageUrl: person
                                                                        .userprofilepic,
                                                                    fit: BoxFit
                                                                        .cover,
                                                                    placeholder:
                                                                        (context,
                                                                                url) =>
                                                                            Container(
                                                                      height:
                                                                          30,
                                                                      width: 30,
                                                                      child: Image
                                                                          .network(
                                                                        "https://firebasestorage.googleapis.com/v0/b/hys-pro-41c66.appspot.com/o/assets%2Floadingimg.gif?alt=media&token=4ca910f2-c584-4b3a-bbcb-2f1c01d93f67",
                                                                      ),
                                                                    ),
                                                                    errorWidget: (context,
                                                                            url,
                                                                            error) =>
                                                                        Icon(Icons
                                                                            .error),
                                                                  ),
                                                                ),
                                                              )),
                                                          SizedBox(
                                                            width: 5,
                                                          ),
                                                          Text(
                                                            person.username,
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  'Nunito Sans',
                                                              fontSize: 18,
                                                              color: Color
                                                                  .fromRGBO(
                                                                      0,
                                                                      0,
                                                                      0,
                                                                      0.8),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  )),
                                        );
                                      }
                                    },
                                    child: Container(
                                      child: Text(
                                          "${totalFollowersCount.toString()} Followers  |  ",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: Colors.black54,
                                              fontSize: 15,
                                              fontWeight: FontWeight.w800)),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      if ((myfriends.length > 0) &&
                                          (userPrivacyLocal[0]["friends"] ==
                                              true)) {
                                        showSearch(
                                          context: context,
                                          delegate: SearchPage<Person>(
                                              onQueryUpdate: (s) => print(s),
                                              items: myfriends,
                                              suggestion: ListView.builder(
                                                itemCount: myfollowings.length,
                                                itemBuilder: (context, index) {
                                                  final Person person =
                                                      myfollowings[index];
                                                  return InkWell(
                                                    onTap: () {
                                                      databaseReference
                                                          .child("hysweb")
                                                          .child(
                                                              "app_bar_navigation")
                                                          .child(FirebaseAuth
                                                              .instance
                                                              .currentUser!
                                                              .uid)
                                                          .update({
                                                        "$_currentUserId": 5,
                                                        "userid": person.userid
                                                      });
                                                    },
                                                    child: Container(
                                                      margin: EdgeInsets.all(2),
                                                      padding:
                                                          EdgeInsets.all(2),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        children: [
                                                          InkWell(
                                                              onTap: () {
                                                                databaseReference
                                                                    .child(
                                                                        "hysweb")
                                                                    .child(
                                                                        "app_bar_navigation")
                                                                    .child(FirebaseAuth
                                                                        .instance
                                                                        .currentUser!
                                                                        .uid)
                                                                    .update({
                                                                  "$_currentUserId":
                                                                      5,
                                                                  "userid":
                                                                      person
                                                                          .userid
                                                                });
                                                              },
                                                              child: Container(
                                                                margin:
                                                                    EdgeInsets
                                                                        .all(
                                                                            10),
                                                                height: 45,
                                                                width: 45,
                                                                decoration:
                                                                    new BoxDecoration(
                                                                  shape: BoxShape
                                                                      .circle,
                                                                ),
                                                                child:
                                                                    ClipRRect(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              25.0),
                                                                  child:
                                                                      CachedNetworkImage(
                                                                    imageUrl: person
                                                                        .userprofilepic,
                                                                    fit: BoxFit
                                                                        .cover,
                                                                    placeholder:
                                                                        (context,
                                                                                url) =>
                                                                            Container(
                                                                      height:
                                                                          30,
                                                                      width: 30,
                                                                      child: Image
                                                                          .network(
                                                                        "https://firebasestorage.googleapis.com/v0/b/hys-pro-41c66.appspot.com/o/assets%2Floadingimg.gif?alt=media&token=4ca910f2-c584-4b3a-bbcb-2f1c01d93f67",
                                                                      ),
                                                                    ),
                                                                    errorWidget: (context,
                                                                            url,
                                                                            error) =>
                                                                        Icon(Icons
                                                                            .error),
                                                                  ),
                                                                ),
                                                              )),
                                                          SizedBox(
                                                            width: 5,
                                                          ),
                                                          Text(
                                                            person.username,
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  'Nunito Sans',
                                                              fontSize: 18,
                                                              color: Color
                                                                  .fromRGBO(
                                                                      0,
                                                                      0,
                                                                      0,
                                                                      0.8),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                              failure: Center(
                                                child:
                                                    Text('No person found :('),
                                              ),
                                              filter: (person) =>
                                                  [person.username],
                                              builder: (person) => InkWell(
                                                    onTap: () {
                                                      databaseReference
                                                          .child("hysweb")
                                                          .child(
                                                              "app_bar_navigation")
                                                          .child(FirebaseAuth
                                                              .instance
                                                              .currentUser!
                                                              .uid)
                                                          .update({
                                                        "$_currentUserId": 5,
                                                        "userid": person.userid
                                                      });
                                                    },
                                                    child: Container(
                                                      margin: EdgeInsets.all(2),
                                                      padding:
                                                          EdgeInsets.all(2),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        children: [
                                                          InkWell(
                                                              onTap: () {
                                                                databaseReference
                                                                    .child(
                                                                        "hysweb")
                                                                    .child(
                                                                        "app_bar_navigation")
                                                                    .child(FirebaseAuth
                                                                        .instance
                                                                        .currentUser!
                                                                        .uid)
                                                                    .update({
                                                                  "$_currentUserId":
                                                                      5,
                                                                  "userid":
                                                                      person
                                                                          .userid
                                                                });
                                                              },
                                                              child: Container(
                                                                margin:
                                                                    EdgeInsets
                                                                        .all(
                                                                            10),
                                                                height: 45,
                                                                width: 45,
                                                                decoration:
                                                                    new BoxDecoration(
                                                                  shape: BoxShape
                                                                      .circle,
                                                                ),
                                                                child:
                                                                    ClipRRect(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              25.0),
                                                                  child:
                                                                      CachedNetworkImage(
                                                                    imageUrl: person
                                                                        .userprofilepic,
                                                                    fit: BoxFit
                                                                        .cover,
                                                                    placeholder:
                                                                        (context,
                                                                                url) =>
                                                                            Container(
                                                                      height:
                                                                          30,
                                                                      width: 30,
                                                                      child: Image
                                                                          .network(
                                                                        "https://firebasestorage.googleapis.com/v0/b/hys-pro-41c66.appspot.com/o/assets%2Floadingimg.gif?alt=media&token=4ca910f2-c584-4b3a-bbcb-2f1c01d93f67",
                                                                      ),
                                                                    ),
                                                                    errorWidget: (context,
                                                                            url,
                                                                            error) =>
                                                                        Icon(Icons
                                                                            .error),
                                                                  ),
                                                                ),
                                                              )),
                                                          SizedBox(
                                                            width: 5,
                                                          ),
                                                          Text(
                                                            person.username,
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  'Nunito Sans',
                                                              fontSize: 18,
                                                              color: Color
                                                                  .fromRGBO(
                                                                      0,
                                                                      0,
                                                                      0,
                                                                      0.8),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  )),
                                        );
                                      }
                                      // else {
                                      //   Fluttertoast.showToast(
                                      //       msg:
                                      //           "${personalData.docs[0].get("firstname")}'s friend list is private.",
                                      //       toastLength: Toast.LENGTH_SHORT,
                                      //       gravity: ToastGravity.BOTTOM,
                                      //       timeInSecForIosWeb: 10,
                                      //       backgroundColor:
                                      //           Color.fromRGBO(37, 36, 36, 1.0),
                                      //       textColor: Colors.white,
                                      //       fontSize: 12.0);
                                      // }
                                    },
                                    child: Container(
                                      child: Text(
                                          "${totalfriendsCount.toString()} Friends",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: Colors.black54,
                                              fontSize: 15,
                                              fontWeight: FontWeight.w800)),
                                    ),
                                  ),
                                  SizedBox(width: 30),
                                  InkWell(
                                    onTap: () {
                                      _settings();
                                    },
                                    child: Container(
                                      child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Image.network(
                                                'https://firebasestorage.googleapis.com/v0/b/hys-pro-41c66.appspot.com/o/assets%2Fsettings.png?alt=media&token=73ecc7ff-06d0-41be-b052-ce15caa10646',
                                                width: 17,
                                                height: 17),
                                            SizedBox(
                                              height: 70,
                                            )
                                          ]),
                                    ),
                                  )
                                ],
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    this.user_id != _currentUserId
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              isRequestAcceptedByMe == false
                                  ? Container(
                                      height: 40,
                                      width: 150,
                                      child: RaisedButton(
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8.0)),
                                          color:
                                              Color.fromRGBO(88, 165, 196, 1),
                                          splashColor:
                                              Color.fromRGBO(88, 165, 196, 1),
                                          child: Center(
                                            child: Text(
                                              "Accept",
                                              style: GoogleFonts.raleway(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 14),
                                            ),
                                          ),
                                          onPressed: () async {
                                            for (int k = 0;
                                                k < allConnections!.docs.length;
                                                k++) {
                                              if ((allConnections!.docs[k]
                                                          .get("otheruserid") ==
                                                      _currentUserId) &&
                                                  (allConnections!.docs[k]
                                                          .get("userid") ==
                                                      this.user_id)) {
                                                crudobj
                                                    .updateUserConnectionData(
                                                        allConnections!
                                                            .docs[k].id,
                                                        {
                                                      "isfriend": true,
                                                      "isfollowing": true,
                                                      "onlyfollowing": false,
                                                      "isrequestaccepted": true
                                                    });

                                                connectionStatusCall();
                                              }
                                            }
                                            crudobj.addUserInConnection(
                                                selectedUserData[0]
                                                        ['first_name'] +
                                                    " " +
                                                    selectedUserData[0]
                                                        ['last_name'],
                                                selectedUserData[0]
                                                    ['profilepic'],
                                                this.user_id,
                                                true,
                                                true,
                                                true,
                                                false,
                                                current_date,
                                                comparedate);
                                            ////////////////////////////notification//////////////////////////////////////
                                            String notify_id =
                                                "ntf${this.user_id}frndreq$comparedate";
                                            notifyCRUD.sendNotification([
                                              notify_id,
                                              "friendrequest",
                                              "friend",
                                              _currentUserId,
                                              this.user_id,
                                              countData!.value["usertoken"]
                                                  [this.user_id]["tokenid"],
                                              "Listen!",
                                              "${userDataDB!.get("first_name")} ${userDataDB!.get("last_name")} accepted your friend request.",
                                              "accepted",
                                              "friend",
                                              "false",
                                              comparedate,
                                              "add"
                                            ]);
                                            //////////////////////////////////////////////////////////////////////////

                                            connectionStatusCall();
                                          }),
                                    )
                                  : Container(
                                      height: 40,
                                      width: 150,
                                      child: RaisedButton(
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8.0)),
                                          color: Colors.white,
                                          splashColor: Colors.blue,
                                          child: Center(
                                            child: Text(
                                              connectionStatus!.docs.length == 0
                                                  ? 'Follow'
                                                  : connectionStatus!.docs[0].get(
                                                              "isfollowing") ==
                                                          true
                                                      ? "Following"
                                                      : "Follow",
                                              style: GoogleFonts.raleway(
                                                  color: Color(0xff0C2551),
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 14),
                                            ),
                                          ),
                                          onPressed: () async {
                                            setState(() {
                                              {
                                                if (connectionStatus!
                                                        .docs.length ==
                                                    0) {
                                                  ////////////////////////////notification//////////////////////////////////////
                                                  String notify_id =
                                                      "ntf${this.user_id}frndreq$comparedate";
                                                  notifyCRUD.sendNotification([
                                                    notify_id,
                                                    "friendrequest",
                                                    "friend",
                                                    _currentUserId,
                                                    this.user_id,
                                                    countData!.value[
                                                                "usertoken"]
                                                            [this.user_id]
                                                        ["tokenid"],
                                                    "Someone started following you!",
                                                    "${userDataDB!.get("first_name")} ${userDataDB!.get("last_name")} started following you.",
                                                    "follow",
                                                    "friend",
                                                    "false",
                                                    comparedate,
                                                    "add"
                                                  ]);
                                                  //////////////////////////////////////////////////////////////////////////
                                                  crudobj.addUserInConnection(
                                                      selectedUserData[0]
                                                              ['first_name'] +
                                                          " " +
                                                          selectedUserData[0]
                                                              ['last_name'],
                                                      selectedUserData[0]
                                                          ['profilepic'],
                                                      this.user_id,
                                                      true,
                                                      false,
                                                      false,
                                                      true,
                                                      current_date,
                                                      comparedate);
                                                  connectionStatusCall();
                                                } else {
                                                  if (connectionStatus!.docs[0]
                                                          .get("isfollowing") ==
                                                      true) {
                                                    crudobj
                                                        .updateUserConnectionData(
                                                            connectionStatus!
                                                                .docs[0].id,
                                                            {
                                                          "isfollowing": false
                                                        });
                                                    connectionStatusCall();
                                                  } else if (connectionStatus!
                                                          .docs[0]
                                                          .get("isfollowing") ==
                                                      false) {
                                                    ////////////////////////////notification//////////////////////////////////////
                                                    String notify_id =
                                                        "ntf${this.user_id}frndreq$comparedate";
                                                    notifyCRUD
                                                        .sendNotification([
                                                      notify_id,
                                                      "friendrequest",
                                                      "friend",
                                                      _currentUserId,
                                                      this.user_id,
                                                      countData!.value[
                                                                  "usertoken"]
                                                              [this.user_id]
                                                          ["tokenid"],
                                                      "Someone started following you!",
                                                      "${userDataDB!.get("first_name")} ${userDataDB!.get("last_name")} started following you.",
                                                      "follow",
                                                      "friend",
                                                      "false",
                                                      comparedate,
                                                      "add"
                                                    ]);
                                                    //////////////////////////////////////////////////////////////////////////
                                                    crudobj
                                                        .updateUserConnectionData(
                                                            connectionStatus!
                                                                .docs[0].id,
                                                            {
                                                          "isfollowing": true
                                                        });
                                                    connectionStatusCall();
                                                  }
                                                }
                                              }
                                            });
                                          }),
                                    ),
                              isRequestAcceptedByMe == false
                                  ? Container(
                                      height: 40,
                                      width: 150,
                                      child: RaisedButton(
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8.0)),
                                          color: Colors.white,
                                          splashColor: Colors.blue,
                                          child: Center(
                                            child: Text(
                                              "Delete",
                                              style: GoogleFonts.raleway(
                                                  color: Color(0xff0C2551),
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 14),
                                            ),
                                          ),
                                          onPressed: () async {
                                            for (int k = 0;
                                                k < allConnections!.docs.length;
                                                k++) {
                                              if ((allConnections!.docs[k]
                                                          .get("userid") ==
                                                      _currentUserId) &&
                                                  (allConnections!.docs[k]
                                                          .get("otheruserid") ==
                                                      this.user_id)) {
                                                crudobj
                                                    .deleteUserConnectionData(
                                                        allConnections!
                                                            .docs[k].id);

                                                connectionStatusCall();
                                              }
                                              if ((allConnections!.docs[k]
                                                          .get("otheruserid") ==
                                                      _currentUserId) &&
                                                  (allConnections!.docs[k]
                                                          .get("userid") ==
                                                      this.user_id)) {
                                                crudobj
                                                    .deleteUserConnectionData(
                                                        allConnections!
                                                            .docs[k].id);

                                                connectionStatusCall();
                                              }
                                            }
                                          }),
                                    )
                                  : Container(
                                      height: 40,
                                      width: 150,
                                      child: RaisedButton(
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8.0)),
                                          color:
                                              Color.fromRGBO(88, 165, 196, 1),
                                          splashColor:
                                              Color.fromRGBO(88, 165, 196, 1),
                                          child: Center(
                                            child: Text(
                                              friendButtonText,
                                              style: GoogleFonts.raleway(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 14),
                                            ),
                                          ),
                                          onPressed: () async {
                                            setState(() {
                                              {
                                                if (connectionStatus!
                                                        .docs.length ==
                                                    0) {
                                                  ////////////////////////////notification//////////////////////////////////////
                                                  String notify_id =
                                                      "ntf${this.user_id}frndreq$comparedate";
                                                  notifyCRUD.sendNotification([
                                                    notify_id,
                                                    "friendrequest",
                                                    "friend",
                                                    _currentUserId,
                                                    this.user_id,
                                                    countData!.value[
                                                                "usertoken"]
                                                            [this.user_id]
                                                        ["tokenid"],
                                                    "Someone looking for you!",
                                                    "${userDataDB!.get("first_name")} ${userDataDB!.get("last_name")} sent you friend request.",
                                                    "sent",
                                                    "friend",
                                                    "false",
                                                    comparedate,
                                                    "add"
                                                  ]);
                                                  //////////////////////////////////////////////////////////////////////////

                                                  crudobj.addUserInConnection(
                                                      selectedUserData[0]
                                                              ['first_name'] +
                                                          " " +
                                                          selectedUserData[0]
                                                              ['last_name'],
                                                      selectedUserData[0]
                                                          ['profilepic'],
                                                      this.user_id,
                                                      true,
                                                      true,
                                                      false,
                                                      false,
                                                      current_date,
                                                      comparedate);
                                                  connectionStatusCall();
                                                } else {
                                                  if ((connectionStatus!.docs[0]
                                                              .get(
                                                                  "isrequestaccepted") ==
                                                          false) &&
                                                      (connectionStatus!.docs[0]
                                                              .get(
                                                                  "isfriend") ==
                                                          true) &&
                                                      ((connectionStatus!
                                                              .docs[0]
                                                              .get(
                                                                  "onlyfollowing") ==
                                                          false))) {
                                                    print("cancel request");
                                                    showBarModalBottomSheet(
                                                        context: context,
                                                        builder: (context) =>
                                                            _cancelSentRequestOptions(
                                                                context));
                                                  }
                                                  if ((connectionStatus!.docs[0].get(
                                                              "isrequestaccepted") ==
                                                          true) &&
                                                      (connectionStatus!.docs[0]
                                                              .get(
                                                                  "isfriend") ==
                                                          true) &&
                                                      ((connectionStatus!
                                                              .docs[0]
                                                              .get(
                                                                  "onlyfollowing") ==
                                                          false))) {
                                                    print("unfriend");
                                                    showBarModalBottomSheet(
                                                        context: context,
                                                        builder: (context) =>
                                                            _unFriendOptions(
                                                                context));
                                                  }
                                                  if ((connectionStatus!.docs[0].get(
                                                              "isrequestaccepted") ==
                                                          false) &&
                                                      (connectionStatus!.docs[0]
                                                              .get(
                                                                  "isfriend") ==
                                                          false) &&
                                                      ((connectionStatus!
                                                              .docs[0]
                                                              .get(
                                                                  "onlyfollowing") ==
                                                          true))) {
                                                    ////////////////////////////notification//////////////////////////////////////
                                                    String notify_id =
                                                        "ntf${this.user_id}frndreq$comparedate";
                                                    notifyCRUD
                                                        .sendNotification([
                                                      notify_id,
                                                      "friendrequest",
                                                      "friend",
                                                      _currentUserId,
                                                      this.user_id,
                                                      countData!.value[
                                                                  "usertoken"]
                                                              [this.user_id]
                                                          ["tokenid"],
                                                      "Listen!",
                                                      "${userDataDB!.get("first_name")} ${userDataDB!.get("last_name")} accepted your friend request.",
                                                      "accepted",
                                                      "friend",
                                                      "false",
                                                      comparedate,
                                                      "add"
                                                    ]);
                                                    //////////////////////////////////////////////////////////////////////////
                                                    crudobj
                                                        .updateUserConnectionData(
                                                            connectionStatus!
                                                                .docs[0].id,
                                                            {
                                                          "isfriend": true,
                                                          "isfollowing": true,
                                                          "onlyfollowing":
                                                              false,
                                                        });
                                                    connectionStatusCall();
                                                  }
                                                }
                                              }
                                            });
                                          }),
                                    ),
                            ],
                          )
                        : SizedBox(),
                    SizedBox(
                      height: 20,
                    )
                  ],
                ),
              ),
              Container(
                height: 8,
                width: 500,
                color: Colors.grey[300],
              ),
              showoldstrength == true ? _onPageNotification() : SizedBox(),
              SizedBox(height: 30),
              SizedBox(
                width: 500,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        child: Center(
                            child: Column(children: [
                          SizedBox(
                            height: 10,
                          ),
                          Text("HYS Rank"),
                          SizedBox(
                            height: 2,
                          ),
                          Text("597",
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Color.fromRGBO(205, 61, 61, 2))),
                        ])),
                        height: 52,
                        width: 100,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                  color: const Color(0xFF000000),
                                  offset: Offset(0, 1),
                                  blurRadius: 8,
                                  spreadRadius: -4),
                            ],
                            borderRadius:
                                BorderRadius.all(Radius.elliptical(70, 70))),
                      ),
                      Container(
                        height: 52,
                        width: 100,
                        child: Center(
                            child: Column(
                          children: [
                            SizedBox(
                              height: 10,
                            ),
                            Text("Credit Score"),
                            SizedBox(height: 2),
                            Text("1397",
                                style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: Color.fromRGBO(205, 61, 61, 2))),
                          ],
                        )),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                  color: const Color(0xFF000000),
                                  offset: Offset(0, 1),
                                  blurRadius: 8,
                                  spreadRadius: -4),
                            ],
                            borderRadius:
                                BorderRadius.all(Radius.elliptical(70, 70))),
                      ),
                      Container(
                        height: 52,
                        width: 100,
                        child: Center(
                            child: Column(
                          children: [
                            SizedBox(
                              height: 10,
                            ),
                            Text("Amazon \nCoupons",
                                style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: Color.fromRGBO(205, 61, 61, 2))),
                          ],
                        )),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                  color: const Color(0xFF000000),
                                  offset: Offset(0, 0),
                                  blurRadius: 8,
                                  spreadRadius: -4),
                            ],
                            borderRadius:
                                BorderRadius.all(Radius.elliptical(70, 70))),
                      )
                    ]),
              ),
              SizedBox(height: 30),
              Container(
                height: 8,
                width: 500,
                color: Colors.grey[300],
              ),
              SizedBox(
                width: 500,
                child: TabBar(
                  tabs: myTabs,
                  labelColor: Color.fromRGBO(205, 61, 61, 2),
                  isScrollable: true,
                  labelStyle: TextStyle(fontWeight: FontWeight.bold),
                  unselectedLabelColor: Colors.black,
                  unselectedLabelStyle:
                      TextStyle(fontWeight: FontWeight.normal),
                  indicator: UnderlineTabIndicator(
                      borderSide: BorderSide(
                          width: 5.0, color: Color.fromRGBO(205, 61, 61, 0.7))),
                  indicatorSize: TabBarIndicatorSize.label,
                  physics: BouncingScrollPhysics(),
                  controller: _tabcontroller,
                ),
              ),
              SizedBox(
                  width: 500,
                  height: 600,
                  child: TabBarView(
                      controller: _tabcontroller,
                      physics: BouncingScrollPhysics(),
                      children: [
                        _profile(),
                        _strengths(),
                        _weaknesses(),
                        _questions(),
                        _answers(),
                        _uploads(),
                        fun(),
                        SizedBox(),
                        SizedBox()
                      ])),
            ],
          ),
        ),
        panel: _panel(context),
      );
    } else {
      return _loading();
    }
  }

  _panel(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(10, 50, 10, 10),
      child: ListView.builder(
        itemCount: topicListStrength.length != 0
            ? topicListStrength[panelSubjectIndex].length
            : 0,
        itemBuilder: ((BuildContext context, int index) {
          return InkWell(
            onTap: () {
              setState(() {
                boolTopicsList[panelSubjectIndex][index] =
                    !boolTopicsList[panelSubjectIndex][index];
                if (boolTopicsList[panelSubjectIndex][index] == true) {
                  selectedtopicsbysubject[panelSubjectIndex]++;
                  totalselectedTopiccount++;
                } else {
                  selectedtopicsbysubject[panelSubjectIndex]--;
                  totalselectedTopiccount--;
                }
              });
            },
            child: Container(
              padding: EdgeInsets.all(10),
              margin: EdgeInsets.only(bottom: 10),
              color: boolTopicsList[panelSubjectIndex][index] == true
                  ? Color.fromRGBO(88, 165, 196, 1)
                  : Colors.white,
              child: Text(topicListStrength[panelSubjectIndex][index],
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            ),
          );
        }),
      ),
    );
  }

  bool showoldstrength = true;

  _cancelSentRequestOptions(BuildContext context) {
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) => Container(
            height: 200,
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                ListTile(
                  title: Text("Cancel Request"),
                  onTap: () async {
                    for (int k = 0; k < allConnections!.docs.length; k++) {
                      if ((allConnections!.docs[k].get("userid") ==
                              _currentUserId) &&
                          (allConnections!.docs[k].get("otheruserid") ==
                              this.user_id)) {
                        crudobj.deleteUserConnectionData(
                            allConnections!.docs[k].id);

                        connectionStatusCall();
                      }
                      if ((allConnections!.docs[k].get("otheruserid") ==
                              _currentUserId) &&
                          (allConnections!.docs[k].get("userid") ==
                              this.user_id)) {
                        crudobj.deleteUserConnectionData(
                            allConnections!.docs[k].id);

                        connectionStatusCall();
                      }
                    }
                  },
                ),
                SizedBox(
                  height: 5,
                ),
                ListTile(
                  title: Text("Cancel"),
                  onTap: () async {},
                ),
              ],
            )));
  }

  _unFriendOptions(BuildContext context) {
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) => Container(
            height: 200,
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                ListTile(
                  title: Text("Unfriend"),
                  onTap: () async {
                    for (int k = 0; k < allConnections!.docs.length; k++) {
                      if ((allConnections!.docs[k].get("userid") ==
                              _currentUserId) &&
                          (allConnections!.docs[k].get("otheruserid") ==
                              this.user_id)) {
                        crudobj.deleteUserConnectionData(
                            allConnections!.docs[k].id);

                        connectionStatusCall();
                      }
                      if ((allConnections!.docs[k].get("otheruserid") ==
                              _currentUserId) &&
                          (allConnections!.docs[k].get("userid") ==
                              this.user_id)) {
                        crudobj.deleteUserConnectionData(
                            allConnections!.docs[k].id);

                        connectionStatusCall();
                      }
                    }
                  },
                ),
                SizedBox(
                  height: 5,
                ),
                ListTile(
                  title: Text("Cancel"),
                  onTap: () async {},
                ),
              ],
            )));
  }

  _onPageNotification() {
    int count = 0;
    bool show = true;
    String grade = (userDataDB!.get("grade") - 1).toString();
    for (int i = 0; i < selectedUserStrengthData.length; i++) {
      if ((selectedUserStrengthData[i]["grade"]).toString() == grade) {
        count++;
        break;
      }
    }
    if (count != 0) {
      setState(() {
        show = false;
      });
    }

    return show == true
        ? (userDataDB!.get("grade")).toString() == "7"
            ? SizedBox()
            : Container(
                width: 500,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          onPressed: () {
                            setState(() {
                              showoldstrength = false;
                            });
                          },
                          icon: Tab(
                              child: Icon(Icons.cancel_rounded,
                                  color: Colors.grey[400], size: 18)),
                        )
                      ],
                    ),
                    Text("Do you like to help grade ${grade}th students?",
                        style: TextStyle(
                            color: Colors.black87,
                            fontSize: 17,
                            fontWeight: FontWeight.w500)),
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        InkWell(
                          onTap: () async {
                            _addGPlusOneStrength();
                          },
                          child: Material(
                            elevation: 3,
                            borderRadius: BorderRadius.circular(5),
                            child: Container(
                              padding: EdgeInsets.all(8),
                              width: 50,
                              decoration: BoxDecoration(
                                  color: Color.fromRGBO(88, 165, 196, 1),
                                  borderRadius: BorderRadius.circular(5)),
                              child: Center(
                                child: Text("Yes",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800)),
                              ),
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () async {
                            setState(() {
                              showoldstrength = false;
                            });
                          },
                          child: Material(
                            elevation: 3,
                            borderRadius: BorderRadius.circular(5),
                            child: Container(
                              padding: EdgeInsets.all(8),
                              width: 50,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(5)),
                              child: Center(
                                child: Text("No",
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800)),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      height: 8,
                      width: 500,
                      color: Colors.grey[300],
                    ),
                  ],
                ))
        : SizedBox();
  }

  String addStrengthProcess = "viewsubjects";
  void _addGPlusOneStrength() {
    showDialog(
        context: context,
        barrierColor: Colors.grey.withOpacity(0.2),
        barrierDismissible: false,
        builder: (_) => StatefulBuilder(builder: (context, setState) {
              return AlertDialog(
                contentPadding: EdgeInsets.all(20),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0)),
                title: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        addStrengthProcess != "viewsubjects"
                            ? IconButton(
                                onPressed: () {
                                  setState(() {
                                    addStrengthProcess = "viewsubjects";
                                  });
                                },
                                icon: const Tab(
                                    child: Icon(Icons.arrow_back_ios_outlined,
                                        color: Colors.black45, size: 25)),
                              )
                            : SizedBox(),
                        Text(
                          "Add strengths",
                          style: const TextStyle(
                            fontSize: 20,
                            color: Color(0xCB000000),
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          icon: const Tab(
                              child: Icon(Icons.cancel_rounded,
                                  color: Colors.black45, size: 25)),
                        )
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(height: 1, width: 500, color: Colors.grey[200]),
                  ],
                ),
                content: addStrengthProcess == "viewsubjects"
                    ? SizedBox(
                        height: 470,
                        width: 500,
                        child: FadeIn(
                          child: InkWell(
                            child: Container(
                              height: 450,
                              width: 500,
                              margin: EdgeInsets.all(30),
                              child: ListView(
                                shrinkWrap: true,
                                children: [
                                  SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 15.0),
                                        child: Text(
                                          'Share Your\nKnowledge!',
                                          style: TextStyle(
                                            fontFamily: 'Nunito Sans',
                                            fontSize: 25,
                                            color: Color(0xCB000000),
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                      ),
                                      InkWell(
                                        child: Container(
                                          margin: const EdgeInsets.only(
                                              right: 15.0),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.deepPurple
                                                    .withOpacity(0.1),
                                                spreadRadius: 10,
                                                blurRadius: 20,
                                              ),
                                            ],
                                          ),
                                          child: ElevatedButton(
                                            child: Container(
                                                width: 70,
                                                height: 40,
                                                child: Center(
                                                    child: Text("SUBMIT"))),
                                            onPressed: () async {
                                              print("button pressed");
                                              setState(() {
                                                if (totalselectedTopiccount >
                                                    0) {
                                                  List<String>
                                                      finalSelectedSubjects =
                                                      [];
                                                  List<List<String>>
                                                      finalSelectedTopics = [];
                                                  for (int a = 0;
                                                      a <
                                                          selectedtopicsbysubject
                                                              .length;
                                                      a++) {
                                                    List<String>
                                                        selectedFinaltopics =
                                                        [];
                                                    if (selectedtopicsbysubject[
                                                            a] >
                                                        0) {
                                                      finalSelectedSubjects.add(
                                                          subjectListStrength[
                                                              a]);
                                                    }
                                                    for (int b = 0;
                                                        b <
                                                            topicListStrength[a]
                                                                .length;
                                                        b++) {
                                                      if (boolTopicsList[a]
                                                              [b] ==
                                                          true) {
                                                        selectedFinaltopics.add(
                                                            topicListStrength[a]
                                                                [b]);
                                                      }
                                                    }
                                                    if (selectedFinaltopics
                                                            .length >
                                                        0)
                                                      finalSelectedTopics.add(
                                                          selectedFinaltopics);
                                                  }
                                                  print(finalSelectedTopics);
                                                  print(finalSelectedSubjects);
                                                  finalSelectedStrengthSubjects =
                                                      finalSelectedSubjects;
                                                  finalSelectedStrengthTopics =
                                                      finalSelectedTopics;
                                                  finalSelectedSubjects = [];
                                                  finalSelectedTopics = [];
                                                  _post_userStrengthData();
                                                  Navigator.of(context).pop();
                                                }
                                              });
                                            },
                                            style: ElevatedButton.styleFrom(
                                              primary: active,
                                              onPrimary: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width /
                                                            102.4),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          top: 10, left: 15),
                                      child: Text(
                                        'Select topics based on subject in which you are best.\nIt helps others if they need help on topic in which you are best.',
                                        style: TextStyle(
                                          fontFamily: 'Product Sans',
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color:
                                              Color.fromRGBO(88, 165, 196, 1),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    height: 600,
                                    margin: EdgeInsets.all(30),
                                    child: GridView.count(
                                        shrinkWrap: true,
                                        controller: _scrollController,
                                        childAspectRatio: 1,
                                        crossAxisCount: 2,
                                        padding: EdgeInsets.all(10),
                                        children: List.generate(
                                            subjectList.length, (index) {
                                          return InkWell(
                                              onTap: () {
                                                setState(() {
                                                  print(
                                                      topicListStrength[index]);
                                                  panelSubjectIndex = index;
                                                  addStrengthProcess =
                                                      "viewTopics";
                                                });
                                              },
                                              child: Container(
                                                  height: 25,
                                                  width: 25,
                                                  margin: EdgeInsets.all(10),
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                      color:
                                                          selectedtopicsbysubject[index] >
                                                                  0
                                                              ? Color.fromRGBO(
                                                                  88,
                                                                  165,
                                                                  196,
                                                                  1)
                                                              : Colors
                                                                  .transparent),
                                                  child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        _showImage(
                                                            subjectList[index]),
                                                        SizedBox(
                                                          height: 5,
                                                        ),
                                                        Text(
                                                          subjectList[index],
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(
                                                              fontSize: 14),
                                                        )
                                                      ])));
                                        })),
                                  ),
                                  SizedBox(
                                    height: 100,
                                  )
                                ],
                              ),
                            ),
                          ),
                          duration: Duration(milliseconds: 250),
                          curve: Curves.easeIn,
                        ),
                      )
                    : Container(
                        height: 470,
                        width: 500,
                        padding: EdgeInsets.all(10),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: topicListStrength.length != 0
                              ? topicListStrength[panelSubjectIndex].length
                              : 0,
                          itemBuilder: ((BuildContext context, int index) {
                            return InkWell(
                              onTap: () {
                                setState(() {
                                  boolTopicsList[panelSubjectIndex][index] =
                                      !boolTopicsList[panelSubjectIndex][index];
                                  if (boolTopicsList[panelSubjectIndex]
                                          [index] ==
                                      true) {
                                    selectedtopicsbysubject[
                                        panelSubjectIndex]++;
                                    totalselectedTopiccount++;
                                  } else {
                                    selectedtopicsbysubject[
                                        panelSubjectIndex]--;
                                    totalselectedTopiccount--;
                                  }
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.all(10),
                                margin: EdgeInsets.only(bottom: 10),
                                color: boolTopicsList[panelSubjectIndex]
                                            [index] ==
                                        true
                                    ? Color.fromRGBO(88, 165, 196, 1)
                                    : Colors.white,
                                child: Text(
                                    topicListStrength[panelSubjectIndex][index],
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600)),
                              ),
                            );
                          }),
                        ),
                      ),
              );
            }));
  }

  Future<void> _post_userStrengthData() async {
    for (int d = 0; d < finalSelectedStrengthSubjects.length; d++) {
      for (int e = 0; e < finalSelectedStrengthTopics[d].length; e++) {
        final http.Response response = await http.post(
          Uri.parse('https://hys-api.herokuapp.com/web_add_user_strength_data'),
          headers: <String, String>{
            'Content-Type': 'application/json',
            "Access-Control_Allow_Origin": "*"
          },
          body: jsonEncode(<String, dynamic>{
            "user_id": _currentUserId,
            "grade": userDataDB!.get("grade") - 1,
            "subject": finalSelectedStrengthSubjects[d],
            "topic": finalSelectedStrengthTopics[d][e]
          }),
        );
        print(d + e + response.statusCode);
      }
    }
  }

  String settingStep = "all";
  void _settings() {
    showDialog(
        context: context,
        barrierColor: Colors.grey.withOpacity(0.2),
        barrierDismissible: false,
        builder: (_) => StatefulBuilder(builder: (context, setState) {
              return AlertDialog(
                contentPadding: EdgeInsets.all(20),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0)),
                title: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        settingStep != "all"
                            ? IconButton(
                                onPressed: () {
                                  setState(() {
                                    settingStep = "all";
                                  });
                                },
                                icon: const Tab(
                                    child: Icon(Icons.arrow_back_ios_outlined,
                                        color: Colors.black45, size: 25)),
                              )
                            : SizedBox(),
                        Text(
                          "Settings",
                          style: const TextStyle(
                            fontSize: 20,
                            color: Color(0xCB000000),
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          icon: const Tab(
                              child: Icon(Icons.cancel_rounded,
                                  color: Colors.black45, size: 25)),
                        )
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(height: 1, width: 500, color: Colors.grey[200]),
                  ],
                ),
                content: SizedBox(
                  height: 470,
                  width: 500,
                  child: settingStep == "all"
                      ? ListView(
                          children: [
                            SizedBox(
                              height: 20,
                            ),
                            ListTile(
                              title: Text("Personal Details",
                                  style: TextStyle(
                                      color: Colors.black87,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600)),
                              trailing: Icon(Icons.arrow_forward_ios_outlined,
                                  size: 16),
                              onTap: () {
                                setState(() {
                                  settingStep = "personal";
                                });
                              },
                            ),
                            SizedBox(
                              height: 30,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  width: 300,
                                  child: Text(
                                      "Do you want to show your friends to others?",
                                      style: TextStyle(
                                          color: Colors.black87,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500)),
                                ),
                                Container(
                                  child: Row(
                                    children: [
                                      InkWell(
                                        onTap: () async {
                                          if (userPrivacyLocal[0]["friends"] ==
                                              0) {
                                            setState(() {
                                              userPrivacyLocal[0]["friends"] =
                                                  1;
                                              networkCRUD
                                                  .updateUserPrivacyDetails([
                                                _currentUserId,
                                                userPrivacyLocal[0]["address"],
                                                userPrivacyLocal[0]["ambition"],
                                                userPrivacyLocal[0]
                                                    ["dreamvacations"],
                                                userPrivacyLocal[0]["email"],
                                                userPrivacyLocal[0]["friends"],
                                                userPrivacyLocal[0]["mygroups"],
                                                userPrivacyLocal[0]["hobbies"],
                                                userPrivacyLocal[0]["library"],
                                                userPrivacyLocal[0]["mobileno"],
                                                userPrivacyLocal[0]["novels"],
                                                userPrivacyLocal[0]
                                                    ["placesvisited"],
                                                userPrivacyLocal[0]
                                                    ["schooladdress"],
                                                userPrivacyLocal[0]
                                                    ["scorecards"],
                                                userPrivacyLocal[0]["uploads"],
                                                userPrivacyLocal[0]["weakness"],
                                                comparedate
                                              ]);
                                            });
                                          }
                                        },
                                        child: Container(
                                          padding: EdgeInsets.all(8),
                                          margin: EdgeInsets.all(8),
                                          width: 50,
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Colors.black45),
                                              color: userPrivacyLocal[0]
                                                          ["friends"] ==
                                                      1
                                                  ? Color.fromRGBO(
                                                      88, 165, 196, 1)
                                                  : Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(5)),
                                          child: Center(
                                            child: Text("Yes",
                                                style: TextStyle(
                                                    color: userPrivacyLocal[0]
                                                                ["friends"] ==
                                                            0
                                                        ? Colors.black
                                                        : Colors.white,
                                                    fontSize: 15,
                                                    fontWeight:
                                                        FontWeight.w800)),
                                          ),
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () async {
                                          if (userPrivacyLocal[0]["friends"] ==
                                              1) {
                                            setState(() {
                                              userPrivacyLocal[0]["friends"] =
                                                  0;
                                              networkCRUD
                                                  .updateUserPrivacyDetails([
                                                _currentUserId,
                                                userPrivacyLocal[0]["address"],
                                                userPrivacyLocal[0]["ambition"],
                                                userPrivacyLocal[0]
                                                    ["dreamvacations"],
                                                userPrivacyLocal[0]["email"],
                                                userPrivacyLocal[0]["friends"],
                                                userPrivacyLocal[0]["mygroups"],
                                                userPrivacyLocal[0]["hobbies"],
                                                userPrivacyLocal[0]["library"],
                                                userPrivacyLocal[0]["mobileno"],
                                                userPrivacyLocal[0]["novels"],
                                                userPrivacyLocal[0]
                                                    ["placesvisited"],
                                                userPrivacyLocal[0]
                                                    ["schooladdress"],
                                                userPrivacyLocal[0]
                                                    ["scorecards"],
                                                userPrivacyLocal[0]["uploads"],
                                                userPrivacyLocal[0]["weakness"],
                                                comparedate
                                              ]);
                                            });
                                          }
                                        },
                                        child: Container(
                                          padding: EdgeInsets.all(8),
                                          margin: EdgeInsets.all(8),
                                          width: 50,
                                          decoration: BoxDecoration(
                                              color: userPrivacyLocal[0]
                                                          ["friends"] ==
                                                      0
                                                  ? Color.fromRGBO(
                                                      88, 165, 196, 1)
                                                  : Colors.white,
                                              border: Border.all(
                                                  color: Colors.black45),
                                              borderRadius:
                                                  BorderRadius.circular(5)),
                                          child: Center(
                                            child: Text("No",
                                                style: TextStyle(
                                                    color: userPrivacyLocal[0]
                                                                ["friends"] ==
                                                            1
                                                        ? Colors.black
                                                        : Colors.white,
                                                    fontSize: 15,
                                                    fontWeight:
                                                        FontWeight.w800)),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  width: 300,
                                  child: Text(
                                      "Do you want to show your weakness to others?",
                                      style: TextStyle(
                                          color: Colors.black87,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500)),
                                ),
                                Container(
                                  child: Row(
                                    children: [
                                      InkWell(
                                        onTap: () async {
                                          if (userPrivacyLocal[0]["weakness"] ==
                                              0) {
                                            setState(() {
                                              userPrivacyLocal[0]["weakness"] =
                                                  1;
                                              networkCRUD
                                                  .updateUserPrivacyDetails([
                                                _currentUserId,
                                                userPrivacyLocal[0]["address"],
                                                userPrivacyLocal[0]["ambition"],
                                                userPrivacyLocal[0]
                                                    ["dreamvacations"],
                                                userPrivacyLocal[0]["email"],
                                                userPrivacyLocal[0]["friends"],
                                                userPrivacyLocal[0]["mygroups"],
                                                userPrivacyLocal[0]["hobbies"],
                                                userPrivacyLocal[0]["library"],
                                                userPrivacyLocal[0]["mobileno"],
                                                userPrivacyLocal[0]["novels"],
                                                userPrivacyLocal[0]
                                                    ["placesvisited"],
                                                userPrivacyLocal[0]
                                                    ["schooladdress"],
                                                userPrivacyLocal[0]
                                                    ["scorecards"],
                                                userPrivacyLocal[0]["uploads"],
                                                userPrivacyLocal[0]["weakness"],
                                                comparedate
                                              ]);
                                            });
                                          }
                                        },
                                        child: Container(
                                          padding: EdgeInsets.all(8),
                                          margin: EdgeInsets.all(8),
                                          width: 50,
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Colors.black45),
                                              color: userPrivacyLocal[0]
                                                          ["weakness"] ==
                                                      1
                                                  ? Color.fromRGBO(
                                                      88, 165, 196, 1)
                                                  : Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(5)),
                                          child: Center(
                                            child: Text("Yes",
                                                style: TextStyle(
                                                    color: userPrivacyLocal[0]
                                                                ["weakness"] ==
                                                            0
                                                        ? Colors.black
                                                        : Colors.white,
                                                    fontSize: 15,
                                                    fontWeight:
                                                        FontWeight.w800)),
                                          ),
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () async {
                                          if (userPrivacyLocal[0]["weakness"] ==
                                              1) {
                                            setState(() {
                                              userPrivacyLocal[0]["weakness"] =
                                                  0;
                                            });
                                          }
                                        },
                                        child: Container(
                                          padding: EdgeInsets.all(8),
                                          margin: EdgeInsets.all(8),
                                          width: 50,
                                          decoration: BoxDecoration(
                                              color: userPrivacyLocal[0]
                                                          ["weakness"] ==
                                                      0
                                                  ? Color.fromRGBO(
                                                      88, 165, 196, 1)
                                                  : Colors.white,
                                              border: Border.all(
                                                  color: Colors.black45),
                                              borderRadius:
                                                  BorderRadius.circular(5)),
                                          child: Center(
                                            child: Text("No",
                                                style: TextStyle(
                                                    color: userPrivacyLocal[0]
                                                                ["weakness"] ==
                                                            1
                                                        ? Colors.black
                                                        : Colors.white,
                                                    fontSize: 15,
                                                    fontWeight:
                                                        FontWeight.w800)),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  width: 300,
                                  child: Text(
                                      "Do you want to show your uploads to others?",
                                      style: TextStyle(
                                          color: Colors.black87,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500)),
                                ),
                                Container(
                                  child: Row(
                                    children: [
                                      InkWell(
                                        onTap: () async {
                                          if (userPrivacyLocal[0]["uploads"] ==
                                              0) {
                                            setState(() {
                                              userPrivacyLocal[0]["uploads"] =
                                                  1;
                                              networkCRUD
                                                  .updateUserPrivacyDetails([
                                                _currentUserId,
                                                userPrivacyLocal[0]["address"],
                                                userPrivacyLocal[0]["ambition"],
                                                userPrivacyLocal[0]
                                                    ["dreamvacations"],
                                                userPrivacyLocal[0]["email"],
                                                userPrivacyLocal[0]["friends"],
                                                userPrivacyLocal[0]["mygroups"],
                                                userPrivacyLocal[0]["hobbies"],
                                                userPrivacyLocal[0]["library"],
                                                userPrivacyLocal[0]["mobileno"],
                                                userPrivacyLocal[0]["novels"],
                                                userPrivacyLocal[0]
                                                    ["placesvisited"],
                                                userPrivacyLocal[0]
                                                    ["schooladdress"],
                                                userPrivacyLocal[0]
                                                    ["scorecards"],
                                                userPrivacyLocal[0]["uploads"],
                                                userPrivacyLocal[0]["weakness"],
                                                comparedate
                                              ]);
                                            });
                                          }
                                        },
                                        child: Container(
                                          padding: EdgeInsets.all(8),
                                          margin: EdgeInsets.all(8),
                                          width: 50,
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Colors.black45),
                                              color: userPrivacyLocal[0]
                                                          ["uploads"] ==
                                                      1
                                                  ? Color.fromRGBO(
                                                      88, 165, 196, 1)
                                                  : Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(5)),
                                          child: Center(
                                            child: Text("Yes",
                                                style: TextStyle(
                                                    color: userPrivacyLocal[0]
                                                                ["uploads"] ==
                                                            0
                                                        ? Colors.black
                                                        : Colors.white,
                                                    fontSize: 15,
                                                    fontWeight:
                                                        FontWeight.w800)),
                                          ),
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () async {
                                          if (userPrivacyLocal[0]["uploads"] ==
                                              1) {
                                            setState(() {
                                              userPrivacyLocal[0]["uploads"] =
                                                  0;
                                              networkCRUD
                                                  .updateUserPrivacyDetails([
                                                _currentUserId,
                                                userPrivacyLocal[0]["address"],
                                                userPrivacyLocal[0]["ambition"],
                                                userPrivacyLocal[0]
                                                    ["dreamvacations"],
                                                userPrivacyLocal[0]["email"],
                                                userPrivacyLocal[0]["friends"],
                                                userPrivacyLocal[0]["mygroups"],
                                                userPrivacyLocal[0]["hobbies"],
                                                userPrivacyLocal[0]["library"],
                                                userPrivacyLocal[0]["mobileno"],
                                                userPrivacyLocal[0]["novels"],
                                                userPrivacyLocal[0]
                                                    ["placesvisited"],
                                                userPrivacyLocal[0]
                                                    ["schooladdress"],
                                                userPrivacyLocal[0]
                                                    ["scorecards"],
                                                userPrivacyLocal[0]["uploads"],
                                                userPrivacyLocal[0]["weakness"],
                                                comparedate
                                              ]);
                                            });
                                          }
                                        },
                                        child: Container(
                                          padding: EdgeInsets.all(8),
                                          margin: EdgeInsets.all(8),
                                          width: 50,
                                          decoration: BoxDecoration(
                                              color: userPrivacyLocal[0]
                                                          ["uploads"] ==
                                                      0
                                                  ? Color.fromRGBO(
                                                      88, 165, 196, 1)
                                                  : Colors.white,
                                              border: Border.all(
                                                  color: Colors.black45),
                                              borderRadius:
                                                  BorderRadius.circular(5)),
                                          child: Center(
                                            child: Text("No",
                                                style: TextStyle(
                                                    color: userPrivacyLocal[0]
                                                                ["uploads"] ==
                                                            1
                                                        ? Colors.black
                                                        : Colors.white,
                                                    fontSize: 15,
                                                    fontWeight:
                                                        FontWeight.w800)),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  width: 300,
                                  child: Text(
                                      "Do you want to show your Scorecard to others?",
                                      style: TextStyle(
                                          color: Colors.black87,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500)),
                                ),
                                Container(
                                  child: Row(
                                    children: [
                                      InkWell(
                                        onTap: () async {
                                          if (userPrivacyLocal[0]
                                                  ["scorecards"] ==
                                              0) {
                                            setState(() {
                                              userPrivacyLocal[0]
                                                  ["scorecards"] = 1;
                                              networkCRUD
                                                  .updateUserPrivacyDetails([
                                                _currentUserId,
                                                userPrivacyLocal[0]["address"],
                                                userPrivacyLocal[0]["ambition"],
                                                userPrivacyLocal[0]
                                                    ["dreamvacations"],
                                                userPrivacyLocal[0]["email"],
                                                userPrivacyLocal[0]["friends"],
                                                userPrivacyLocal[0]["mygroups"],
                                                userPrivacyLocal[0]["hobbies"],
                                                userPrivacyLocal[0]["library"],
                                                userPrivacyLocal[0]["mobileno"],
                                                userPrivacyLocal[0]["novels"],
                                                userPrivacyLocal[0]
                                                    ["placesvisited"],
                                                userPrivacyLocal[0]
                                                    ["schooladdress"],
                                                userPrivacyLocal[0]
                                                    ["scorecards"],
                                                userPrivacyLocal[0]["uploads"],
                                                userPrivacyLocal[0]["weakness"],
                                                comparedate
                                              ]);
                                            });
                                          }
                                        },
                                        child: Container(
                                          padding: EdgeInsets.all(8),
                                          margin: EdgeInsets.all(8),
                                          width: 50,
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Colors.black45),
                                              color: userPrivacyLocal[0]
                                                          ["scorecards"] ==
                                                      1
                                                  ? Color.fromRGBO(
                                                      88, 165, 196, 1)
                                                  : Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(5)),
                                          child: Center(
                                            child: Text("Yes",
                                                style: TextStyle(
                                                    color: userPrivacyLocal[0][
                                                                "scorecards"] ==
                                                            0
                                                        ? Colors.black
                                                        : Colors.white,
                                                    fontSize: 15,
                                                    fontWeight:
                                                        FontWeight.w800)),
                                          ),
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () async {
                                          if (userPrivacyLocal[0]
                                                  ["scorecards"] ==
                                              1) {
                                            setState(() {
                                              userPrivacyLocal[0]
                                                  ["scorecards"] = 0;
                                              networkCRUD
                                                  .updateUserPrivacyDetails([
                                                _currentUserId,
                                                userPrivacyLocal[0]["address"],
                                                userPrivacyLocal[0]["ambition"],
                                                userPrivacyLocal[0]
                                                    ["dreamvacations"],
                                                userPrivacyLocal[0]["email"],
                                                userPrivacyLocal[0]["friends"],
                                                userPrivacyLocal[0]["mygroups"],
                                                userPrivacyLocal[0]["hobbies"],
                                                userPrivacyLocal[0]["library"],
                                                userPrivacyLocal[0]["mobileno"],
                                                userPrivacyLocal[0]["novels"],
                                                userPrivacyLocal[0]
                                                    ["placesvisited"],
                                                userPrivacyLocal[0]
                                                    ["schooladdress"],
                                                userPrivacyLocal[0]
                                                    ["scorecards"],
                                                userPrivacyLocal[0]["uploads"],
                                                userPrivacyLocal[0]["weakness"],
                                                comparedate
                                              ]);
                                            });
                                          }
                                        },
                                        child: Container(
                                          padding: EdgeInsets.all(8),
                                          margin: EdgeInsets.all(8),
                                          width: 50,
                                          decoration: BoxDecoration(
                                              color: userPrivacyLocal[0]
                                                          ["scorecards"] ==
                                                      0
                                                  ? Color.fromRGBO(
                                                      88, 165, 196, 1)
                                                  : Colors.white,
                                              border: Border.all(
                                                  color: Colors.black45),
                                              borderRadius:
                                                  BorderRadius.circular(5)),
                                          child: Center(
                                            child: Text("No",
                                                style: TextStyle(
                                                    color: userPrivacyLocal[0][
                                                                "scorecards"] ==
                                                            1
                                                        ? Colors.black
                                                        : Colors.white,
                                                    fontSize: 15,
                                                    fontWeight:
                                                        FontWeight.w800)),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  width: 300,
                                  child: Text(
                                      "Do you want to show your library to others?",
                                      style: TextStyle(
                                          color: Colors.black87,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500)),
                                ),
                                Container(
                                  child: Row(
                                    children: [
                                      InkWell(
                                        onTap: () async {
                                          if (userPrivacyLocal[0]["library"] ==
                                              0) {
                                            setState(() {
                                              userPrivacyLocal[0]["library"] =
                                                  1;
                                              networkCRUD
                                                  .updateUserPrivacyDetails([
                                                _currentUserId,
                                                userPrivacyLocal[0]["address"],
                                                userPrivacyLocal[0]["ambition"],
                                                userPrivacyLocal[0]
                                                    ["dreamvacations"],
                                                userPrivacyLocal[0]["email"],
                                                userPrivacyLocal[0]["friends"],
                                                userPrivacyLocal[0]["mygroups"],
                                                userPrivacyLocal[0]["hobbies"],
                                                userPrivacyLocal[0]["library"],
                                                userPrivacyLocal[0]["mobileno"],
                                                userPrivacyLocal[0]["novels"],
                                                userPrivacyLocal[0]
                                                    ["placesvisited"],
                                                userPrivacyLocal[0]
                                                    ["schooladdress"],
                                                userPrivacyLocal[0]
                                                    ["scorecards"],
                                                userPrivacyLocal[0]["uploads"],
                                                userPrivacyLocal[0]["weakness"],
                                                comparedate
                                              ]);
                                            });
                                          }
                                        },
                                        child: Container(
                                          padding: EdgeInsets.all(8),
                                          margin: EdgeInsets.all(8),
                                          width: 50,
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Colors.black45),
                                              color: userPrivacyLocal[0]
                                                          ["library"] ==
                                                      1
                                                  ? Color.fromRGBO(
                                                      88, 165, 196, 1)
                                                  : Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(5)),
                                          child: Center(
                                            child: Text("Yes",
                                                style: TextStyle(
                                                    color: userPrivacyLocal[0]
                                                                ["library"] ==
                                                            0
                                                        ? Colors.black
                                                        : Colors.white,
                                                    fontSize: 15,
                                                    fontWeight:
                                                        FontWeight.w800)),
                                          ),
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () async {
                                          if (userPrivacyLocal[0]["library"] ==
                                              1) {
                                            setState(() {
                                              userPrivacyLocal[0]["library"] =
                                                  0;
                                              networkCRUD
                                                  .updateUserPrivacyDetails([
                                                _currentUserId,
                                                userPrivacyLocal[0]["address"],
                                                userPrivacyLocal[0]["ambition"],
                                                userPrivacyLocal[0]
                                                    ["dreamvacations"],
                                                userPrivacyLocal[0]["email"],
                                                userPrivacyLocal[0]["friends"],
                                                userPrivacyLocal[0]["mygroups"],
                                                userPrivacyLocal[0]["hobbies"],
                                                userPrivacyLocal[0]["library"],
                                                userPrivacyLocal[0]["mobileno"],
                                                userPrivacyLocal[0]["novels"],
                                                userPrivacyLocal[0]
                                                    ["placesvisited"],
                                                userPrivacyLocal[0]
                                                    ["schooladdress"],
                                                userPrivacyLocal[0]
                                                    ["scorecards"],
                                                userPrivacyLocal[0]["uploads"],
                                                userPrivacyLocal[0]["weakness"],
                                                comparedate
                                              ]);
                                            });
                                          }
                                        },
                                        child: Container(
                                          padding: EdgeInsets.all(8),
                                          margin: EdgeInsets.all(8),
                                          width: 50,
                                          decoration: BoxDecoration(
                                              color: userPrivacyLocal[0]
                                                          ["library"] ==
                                                      0
                                                  ? Color.fromRGBO(
                                                      88, 165, 196, 1)
                                                  : Colors.white,
                                              border: Border.all(
                                                  color: Colors.black45),
                                              borderRadius:
                                                  BorderRadius.circular(5)),
                                          child: Center(
                                            child: Text("No",
                                                style: TextStyle(
                                                    color: userPrivacyLocal[0]
                                                                ["library"] ==
                                                            1
                                                        ? Colors.black
                                                        : Colors.white,
                                                    fontSize: 15,
                                                    fontWeight:
                                                        FontWeight.w800)),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  width: 300,
                                  child: Text(
                                      "Do you want to show your groups to others?",
                                      style: TextStyle(
                                          color: Colors.black87,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500)),
                                ),
                                Container(
                                  child: Row(
                                    children: [
                                      InkWell(
                                        onTap: () async {
                                          if (userPrivacyLocal[0]["mygroups"] ==
                                              0) {
                                            setState(() {
                                              userPrivacyLocal[0]["mygroups"] =
                                                  1;
                                              networkCRUD
                                                  .updateUserPrivacyDetails([
                                                _currentUserId,
                                                userPrivacyLocal[0]["address"],
                                                userPrivacyLocal[0]["ambition"],
                                                userPrivacyLocal[0]
                                                    ["dreamvacations"],
                                                userPrivacyLocal[0]["email"],
                                                userPrivacyLocal[0]["friends"],
                                                userPrivacyLocal[0]["mygroups"],
                                                userPrivacyLocal[0]["hobbies"],
                                                userPrivacyLocal[0]["library"],
                                                userPrivacyLocal[0]["mobileno"],
                                                userPrivacyLocal[0]["novels"],
                                                userPrivacyLocal[0]
                                                    ["placesvisited"],
                                                userPrivacyLocal[0]
                                                    ["schooladdress"],
                                                userPrivacyLocal[0]
                                                    ["scorecards"],
                                                userPrivacyLocal[0]["uploads"],
                                                userPrivacyLocal[0]["weakness"],
                                                comparedate
                                              ]);
                                            });
                                          }
                                        },
                                        child: Container(
                                          padding: EdgeInsets.all(8),
                                          margin: EdgeInsets.all(8),
                                          width: 50,
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Colors.black45),
                                              color: userPrivacyLocal[0]
                                                          ["mygroups"] ==
                                                      1
                                                  ? Color.fromRGBO(
                                                      88, 165, 196, 1)
                                                  : Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(5)),
                                          child: Center(
                                            child: Text("Yes",
                                                style: TextStyle(
                                                    color: userPrivacyLocal[0]
                                                                ["mygroups"] ==
                                                            0
                                                        ? Colors.black
                                                        : Colors.white,
                                                    fontSize: 15,
                                                    fontWeight:
                                                        FontWeight.w800)),
                                          ),
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () async {
                                          if (userPrivacyLocal[0]["mygroups"] ==
                                              1) {
                                            setState(() {
                                              userPrivacyLocal[0]["mygroups"] =
                                                  0;
                                              networkCRUD
                                                  .updateUserPrivacyDetails([
                                                _currentUserId,
                                                userPrivacyLocal[0]["address"],
                                                userPrivacyLocal[0]["ambition"],
                                                userPrivacyLocal[0]
                                                    ["dreamvacations"],
                                                userPrivacyLocal[0]["email"],
                                                userPrivacyLocal[0]["friends"],
                                                userPrivacyLocal[0]["mygroups"],
                                                userPrivacyLocal[0]["hobbies"],
                                                userPrivacyLocal[0]["library"],
                                                userPrivacyLocal[0]["mobileno"],
                                                userPrivacyLocal[0]["novels"],
                                                userPrivacyLocal[0]
                                                    ["placesvisited"],
                                                userPrivacyLocal[0]
                                                    ["schooladdress"],
                                                userPrivacyLocal[0]
                                                    ["scorecards"],
                                                userPrivacyLocal[0]["uploads"],
                                                userPrivacyLocal[0]["weakness"],
                                                comparedate
                                              ]);
                                            });
                                          }
                                        },
                                        child: Container(
                                          padding: EdgeInsets.all(8),
                                          margin: EdgeInsets.all(8),
                                          width: 50,
                                          decoration: BoxDecoration(
                                              color: userPrivacyLocal[0]
                                                          ["mygroups"] ==
                                                      0
                                                  ? Color.fromRGBO(
                                                      88, 165, 196, 1)
                                                  : Colors.white,
                                              border: Border.all(
                                                  color: Colors.black45),
                                              borderRadius:
                                                  BorderRadius.circular(5)),
                                          child: Center(
                                            child: Text("No",
                                                style: TextStyle(
                                                    color: userPrivacyLocal[0]
                                                                ["mygroups"] ==
                                                            1
                                                        ? Colors.black
                                                        : Colors.white,
                                                    fontSize: 15,
                                                    fontWeight:
                                                        FontWeight.w800)),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                            SizedBox(
                              height: 40,
                            ),
                          ],
                        )
                      : ListView(
                          children: [
                            Text("Personal Details",
                                style: TextStyle(
                                    color: Colors.black87,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800)),
                            SizedBox(
                              height: 40,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text("What do you want to show others?",
                                    style: TextStyle(
                                        color: Colors.black87,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600)),
                              ],
                            ),
                            SizedBox(
                              height: 30,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  width: 300,
                                  child: Text("Email ID",
                                      style: TextStyle(
                                          color: Colors.black87,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500)),
                                ),
                                Container(
                                  child: Row(
                                    children: [
                                      InkWell(
                                        onTap: () async {
                                          if (userPrivacyLocal[0]["email"] ==
                                              0) {
                                            setState(() {
                                              userPrivacyLocal[0]["email"] = 1;
                                              networkCRUD
                                                  .updateUserPrivacyDetails([
                                                _currentUserId,
                                                userPrivacyLocal[0]["address"],
                                                userPrivacyLocal[0]["ambition"],
                                                userPrivacyLocal[0]
                                                    ["dreamvacations"],
                                                userPrivacyLocal[0]["email"],
                                                userPrivacyLocal[0]["friends"],
                                                userPrivacyLocal[0]["mygroups"],
                                                userPrivacyLocal[0]["hobbies"],
                                                userPrivacyLocal[0]["library"],
                                                userPrivacyLocal[0]["mobileno"],
                                                userPrivacyLocal[0]["novels"],
                                                userPrivacyLocal[0]
                                                    ["placesvisited"],
                                                userPrivacyLocal[0]
                                                    ["schooladdress"],
                                                userPrivacyLocal[0]
                                                    ["scorecards"],
                                                userPrivacyLocal[0]["uploads"],
                                                userPrivacyLocal[0]["weakness"],
                                                comparedate
                                              ]);
                                            });
                                          }
                                        },
                                        child: Container(
                                          padding: EdgeInsets.all(8),
                                          margin: EdgeInsets.all(8),
                                          width: 50,
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Colors.black45),
                                              color: userPrivacyLocal[0]
                                                          ["email"] ==
                                                      1
                                                  ? Color.fromRGBO(
                                                      88, 165, 196, 1)
                                                  : Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(5)),
                                          child: Center(
                                            child: Text("Yes",
                                                style: TextStyle(
                                                    color: userPrivacyLocal[0]
                                                                ["email"] ==
                                                            0
                                                        ? Colors.black
                                                        : Colors.white,
                                                    fontSize: 15,
                                                    fontWeight:
                                                        FontWeight.w800)),
                                          ),
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () async {
                                          if (userPrivacyLocal[0]["email"] ==
                                              1) {
                                            setState(() {
                                              userPrivacyLocal[0]["email"] = 0;
                                              networkCRUD
                                                  .updateUserPrivacyDetails([
                                                _currentUserId,
                                                userPrivacyLocal[0]["address"],
                                                userPrivacyLocal[0]["ambition"],
                                                userPrivacyLocal[0]
                                                    ["dreamvacations"],
                                                userPrivacyLocal[0]["email"],
                                                userPrivacyLocal[0]["friends"],
                                                userPrivacyLocal[0]["mygroups"],
                                                userPrivacyLocal[0]["hobbies"],
                                                userPrivacyLocal[0]["library"],
                                                userPrivacyLocal[0]["mobileno"],
                                                userPrivacyLocal[0]["novels"],
                                                userPrivacyLocal[0]
                                                    ["placesvisited"],
                                                userPrivacyLocal[0]
                                                    ["schooladdress"],
                                                userPrivacyLocal[0]
                                                    ["scorecards"],
                                                userPrivacyLocal[0]["uploads"],
                                                userPrivacyLocal[0]["weakness"],
                                                comparedate
                                              ]);
                                            });
                                          }
                                        },
                                        child: Container(
                                          padding: EdgeInsets.all(8),
                                          margin: EdgeInsets.all(8),
                                          width: 50,
                                          decoration: BoxDecoration(
                                              color: userPrivacyLocal[0]
                                                          ["email"] ==
                                                      0
                                                  ? Color.fromRGBO(
                                                      88, 165, 196, 1)
                                                  : Colors.white,
                                              border: Border.all(
                                                  color: Colors.black45),
                                              borderRadius:
                                                  BorderRadius.circular(5)),
                                          child: Center(
                                            child: Text("No",
                                                style: TextStyle(
                                                    color: userPrivacyLocal[0]
                                                                ["email"] ==
                                                            1
                                                        ? Colors.black
                                                        : Colors.white,
                                                    fontSize: 15,
                                                    fontWeight:
                                                        FontWeight.w800)),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  width: 300,
                                  child: Text("Mobile Number",
                                      style: TextStyle(
                                          color: Colors.black87,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500)),
                                ),
                                Container(
                                  child: Row(
                                    children: [
                                      InkWell(
                                        onTap: () async {
                                          if (userPrivacyLocal[0]["mobileno"] ==
                                              0) {
                                            setState(() {
                                              userPrivacyLocal[0]["mobileno"] =
                                                  1;
                                              networkCRUD
                                                  .updateUserPrivacyDetails([
                                                _currentUserId,
                                                userPrivacyLocal[0]["address"],
                                                userPrivacyLocal[0]["ambition"],
                                                userPrivacyLocal[0]
                                                    ["dreamvacations"],
                                                userPrivacyLocal[0]["email"],
                                                userPrivacyLocal[0]["friends"],
                                                userPrivacyLocal[0]["mygroups"],
                                                userPrivacyLocal[0]["hobbies"],
                                                userPrivacyLocal[0]["library"],
                                                userPrivacyLocal[0]["mobileno"],
                                                userPrivacyLocal[0]["novels"],
                                                userPrivacyLocal[0]
                                                    ["placesvisited"],
                                                userPrivacyLocal[0]
                                                    ["schooladdress"],
                                                userPrivacyLocal[0]
                                                    ["scorecards"],
                                                userPrivacyLocal[0]["uploads"],
                                                userPrivacyLocal[0]["weakness"],
                                                comparedate
                                              ]);
                                            });
                                          }
                                        },
                                        child: Container(
                                          padding: EdgeInsets.all(8),
                                          margin: EdgeInsets.all(8),
                                          width: 50,
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Colors.black45),
                                              color: userPrivacyLocal[0]
                                                          ["mobileno"] ==
                                                      1
                                                  ? Color.fromRGBO(
                                                      88, 165, 196, 1)
                                                  : Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(5)),
                                          child: Center(
                                            child: Text("Yes",
                                                style: TextStyle(
                                                    color: userPrivacyLocal[0]
                                                                ["mobileno"] ==
                                                            0
                                                        ? Colors.black
                                                        : Colors.white,
                                                    fontSize: 15,
                                                    fontWeight:
                                                        FontWeight.w800)),
                                          ),
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () async {
                                          if (userPrivacyLocal[0]["mobileno"] ==
                                              1) {
                                            setState(() {
                                              userPrivacyLocal[0]["mobileno"] =
                                                  0;
                                              networkCRUD
                                                  .updateUserPrivacyDetails([
                                                _currentUserId,
                                                userPrivacyLocal[0]["address"],
                                                userPrivacyLocal[0]["ambition"],
                                                userPrivacyLocal[0]
                                                    ["dreamvacations"],
                                                userPrivacyLocal[0]["email"],
                                                userPrivacyLocal[0]["friends"],
                                                userPrivacyLocal[0]["mygroups"],
                                                userPrivacyLocal[0]["hobbies"],
                                                userPrivacyLocal[0]["library"],
                                                userPrivacyLocal[0]["mobileno"],
                                                userPrivacyLocal[0]["novels"],
                                                userPrivacyLocal[0]
                                                    ["placesvisited"],
                                                userPrivacyLocal[0]
                                                    ["schooladdress"],
                                                userPrivacyLocal[0]
                                                    ["scorecards"],
                                                userPrivacyLocal[0]["uploads"],
                                                userPrivacyLocal[0]["weakness"],
                                                comparedate
                                              ]);
                                            });
                                          }
                                        },
                                        child: Container(
                                          padding: EdgeInsets.all(8),
                                          margin: EdgeInsets.all(8),
                                          width: 50,
                                          decoration: BoxDecoration(
                                              color: userPrivacyLocal[0]
                                                          ["mobileno"] ==
                                                      0
                                                  ? Color.fromRGBO(
                                                      88, 165, 196, 1)
                                                  : Colors.white,
                                              border: Border.all(
                                                  color: Colors.black45),
                                              borderRadius:
                                                  BorderRadius.circular(5)),
                                          child: Center(
                                            child: Text("No",
                                                style: TextStyle(
                                                    color: userPrivacyLocal[0]
                                                                ["mobileno"] ==
                                                            1
                                                        ? Colors.black
                                                        : Colors.white,
                                                    fontSize: 15,
                                                    fontWeight:
                                                        FontWeight.w800)),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  width: 300,
                                  child: Text("Address",
                                      style: TextStyle(
                                          color: Colors.black87,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500)),
                                ),
                                Container(
                                  child: Row(
                                    children: [
                                      InkWell(
                                        onTap: () async {
                                          if (userPrivacyLocal[0]["address"] ==
                                              0) {
                                            setState(() {
                                              userPrivacyLocal[0]["address"] =
                                                  1;
                                              networkCRUD
                                                  .updateUserPrivacyDetails([
                                                _currentUserId,
                                                userPrivacyLocal[0]["address"],
                                                userPrivacyLocal[0]["ambition"],
                                                userPrivacyLocal[0]
                                                    ["dreamvacations"],
                                                userPrivacyLocal[0]["email"],
                                                userPrivacyLocal[0]["friends"],
                                                userPrivacyLocal[0]["mygroups"],
                                                userPrivacyLocal[0]["hobbies"],
                                                userPrivacyLocal[0]["library"],
                                                userPrivacyLocal[0]["mobileno"],
                                                userPrivacyLocal[0]["novels"],
                                                userPrivacyLocal[0]
                                                    ["placesvisited"],
                                                userPrivacyLocal[0]
                                                    ["schooladdress"],
                                                userPrivacyLocal[0]
                                                    ["scorecards"],
                                                userPrivacyLocal[0]["uploads"],
                                                userPrivacyLocal[0]["weakness"],
                                                comparedate
                                              ]);
                                            });
                                          }
                                        },
                                        child: Container(
                                          padding: EdgeInsets.all(8),
                                          margin: EdgeInsets.all(8),
                                          width: 50,
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Colors.black45),
                                              color: userPrivacyLocal[0]
                                                          ["address"] ==
                                                      1
                                                  ? Color.fromRGBO(
                                                      88, 165, 196, 1)
                                                  : Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(5)),
                                          child: Center(
                                            child: Text("Yes",
                                                style: TextStyle(
                                                    color: userPrivacyLocal[0]
                                                                ["address"] ==
                                                            0
                                                        ? Colors.black
                                                        : Colors.white,
                                                    fontSize: 15,
                                                    fontWeight:
                                                        FontWeight.w800)),
                                          ),
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () async {
                                          if (userPrivacyLocal[0]["address"] ==
                                              1) {
                                            setState(() {
                                              userPrivacyLocal[0]["address"] =
                                                  0;
                                              networkCRUD
                                                  .updateUserPrivacyDetails([
                                                _currentUserId,
                                                userPrivacyLocal[0]["address"],
                                                userPrivacyLocal[0]["ambition"],
                                                userPrivacyLocal[0]
                                                    ["dreamvacations"],
                                                userPrivacyLocal[0]["email"],
                                                userPrivacyLocal[0]["friends"],
                                                userPrivacyLocal[0]["mygroups"],
                                                userPrivacyLocal[0]["hobbies"],
                                                userPrivacyLocal[0]["library"],
                                                userPrivacyLocal[0]["mobileno"],
                                                userPrivacyLocal[0]["novels"],
                                                userPrivacyLocal[0]
                                                    ["placesvisited"],
                                                userPrivacyLocal[0]
                                                    ["schooladdress"],
                                                userPrivacyLocal[0]
                                                    ["scorecards"],
                                                userPrivacyLocal[0]["uploads"],
                                                userPrivacyLocal[0]["weakness"],
                                                comparedate
                                              ]);
                                            });
                                          }
                                        },
                                        child: Container(
                                          padding: EdgeInsets.all(8),
                                          margin: EdgeInsets.all(8),
                                          width: 50,
                                          decoration: BoxDecoration(
                                              color: userPrivacyLocal[0]
                                                          ["address"] ==
                                                      0
                                                  ? Color.fromRGBO(
                                                      88, 165, 196, 1)
                                                  : Colors.white,
                                              border: Border.all(
                                                  color: Colors.black45),
                                              borderRadius:
                                                  BorderRadius.circular(5)),
                                          child: Center(
                                            child: Text("No",
                                                style: TextStyle(
                                                    color: userPrivacyLocal[0]
                                                                ["address"] ==
                                                            1
                                                        ? Colors.black
                                                        : Colors.white,
                                                    fontSize: 15,
                                                    fontWeight:
                                                        FontWeight.w800)),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  width: 300,
                                  child: Text("School Address",
                                      style: TextStyle(
                                          color: Colors.black87,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500)),
                                ),
                                Container(
                                  child: Row(
                                    children: [
                                      InkWell(
                                        onTap: () async {
                                          if (userPrivacyLocal[0]
                                                  ["schooladdress"] ==
                                              0) {
                                            setState(() {
                                              userPrivacyLocal[0]
                                                  ["schooladdress"] = 1;
                                              networkCRUD
                                                  .updateUserPrivacyDetails([
                                                _currentUserId,
                                                userPrivacyLocal[0]["address"],
                                                userPrivacyLocal[0]["ambition"],
                                                userPrivacyLocal[0]
                                                    ["dreamvacations"],
                                                userPrivacyLocal[0]["email"],
                                                userPrivacyLocal[0]["friends"],
                                                userPrivacyLocal[0]["mygroups"],
                                                userPrivacyLocal[0]["hobbies"],
                                                userPrivacyLocal[0]["library"],
                                                userPrivacyLocal[0]["mobileno"],
                                                userPrivacyLocal[0]["novels"],
                                                userPrivacyLocal[0]
                                                    ["placesvisited"],
                                                userPrivacyLocal[0]
                                                    ["schooladdress"],
                                                userPrivacyLocal[0]
                                                    ["scorecards"],
                                                userPrivacyLocal[0]["uploads"],
                                                userPrivacyLocal[0]["weakness"],
                                                comparedate
                                              ]);
                                            });
                                          }
                                        },
                                        child: Container(
                                          padding: EdgeInsets.all(8),
                                          margin: EdgeInsets.all(8),
                                          width: 50,
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Colors.black45),
                                              color: userPrivacyLocal[0]
                                                          ["schooladdress"] ==
                                                      1
                                                  ? Color.fromRGBO(
                                                      88, 165, 196, 1)
                                                  : Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(5)),
                                          child: Center(
                                            child: Text("Yes",
                                                style: TextStyle(
                                                    color: userPrivacyLocal[0][
                                                                "schooladdress"] ==
                                                            0
                                                        ? Colors.black
                                                        : Colors.white,
                                                    fontSize: 15,
                                                    fontWeight:
                                                        FontWeight.w800)),
                                          ),
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () async {
                                          if (userPrivacyLocal[0]
                                                  ["schooladdress"] ==
                                              1) {
                                            setState(() {
                                              userPrivacyLocal[0]
                                                  ["schooladdress"] = 0;
                                              networkCRUD
                                                  .updateUserPrivacyDetails([
                                                _currentUserId,
                                                userPrivacyLocal[0]["address"],
                                                userPrivacyLocal[0]["ambition"],
                                                userPrivacyLocal[0]
                                                    ["dreamvacations"],
                                                userPrivacyLocal[0]["email"],
                                                userPrivacyLocal[0]["friends"],
                                                userPrivacyLocal[0]["mygroups"],
                                                userPrivacyLocal[0]["hobbies"],
                                                userPrivacyLocal[0]["library"],
                                                userPrivacyLocal[0]["mobileno"],
                                                userPrivacyLocal[0]["novels"],
                                                userPrivacyLocal[0]
                                                    ["placesvisited"],
                                                userPrivacyLocal[0]
                                                    ["schooladdress"],
                                                userPrivacyLocal[0]
                                                    ["scorecards"],
                                                userPrivacyLocal[0]["uploads"],
                                                userPrivacyLocal[0]["weakness"],
                                                comparedate
                                              ]);
                                            });
                                          }
                                        },
                                        child: Container(
                                          padding: EdgeInsets.all(8),
                                          margin: EdgeInsets.all(8),
                                          width: 50,
                                          decoration: BoxDecoration(
                                              color: userPrivacyLocal[0]
                                                          ["schooladdress"] ==
                                                      0
                                                  ? Color.fromRGBO(
                                                      88, 165, 196, 1)
                                                  : Colors.white,
                                              border: Border.all(
                                                  color: Colors.black45),
                                              borderRadius:
                                                  BorderRadius.circular(5)),
                                          child: Center(
                                            child: Text("No",
                                                style: TextStyle(
                                                    color: userPrivacyLocal[0][
                                                                "schooladdress"] ==
                                                            1
                                                        ? Colors.black
                                                        : Colors.white,
                                                    fontSize: 15,
                                                    fontWeight:
                                                        FontWeight.w800)),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  width: 300,
                                  child: Text("Hobbies",
                                      style: TextStyle(
                                          color: Colors.black87,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500)),
                                ),
                                Container(
                                  child: Row(
                                    children: [
                                      InkWell(
                                        onTap: () async {
                                          if (userPrivacyLocal[0]["hobbies"] ==
                                              0) {
                                            setState(() {
                                              userPrivacyLocal[0]["hobbies"] =
                                                  1;
                                              networkCRUD
                                                  .updateUserPrivacyDetails([
                                                _currentUserId,
                                                userPrivacyLocal[0]["address"],
                                                userPrivacyLocal[0]["ambition"],
                                                userPrivacyLocal[0]
                                                    ["dreamvacations"],
                                                userPrivacyLocal[0]["email"],
                                                userPrivacyLocal[0]["friends"],
                                                userPrivacyLocal[0]["mygroups"],
                                                userPrivacyLocal[0]["hobbies"],
                                                userPrivacyLocal[0]["library"],
                                                userPrivacyLocal[0]["mobileno"],
                                                userPrivacyLocal[0]["novels"],
                                                userPrivacyLocal[0]
                                                    ["placesvisited"],
                                                userPrivacyLocal[0]
                                                    ["schooladdress"],
                                                userPrivacyLocal[0]
                                                    ["scorecards"],
                                                userPrivacyLocal[0]["uploads"],
                                                userPrivacyLocal[0]["weakness"],
                                                comparedate
                                              ]);
                                            });
                                          }
                                        },
                                        child: Container(
                                          padding: EdgeInsets.all(8),
                                          margin: EdgeInsets.all(8),
                                          width: 50,
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Colors.black45),
                                              color: userPrivacyLocal[0]
                                                          ["hobbies"] ==
                                                      1
                                                  ? Color.fromRGBO(
                                                      88, 165, 196, 1)
                                                  : Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(5)),
                                          child: Center(
                                            child: Text("Yes",
                                                style: TextStyle(
                                                    color: userPrivacyLocal[0]
                                                                ["hobbies"] ==
                                                            0
                                                        ? Colors.black
                                                        : Colors.white,
                                                    fontSize: 15,
                                                    fontWeight:
                                                        FontWeight.w800)),
                                          ),
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () async {
                                          if (userPrivacyLocal[0]["hobbies"] ==
                                              1) {
                                            setState(() {
                                              userPrivacyLocal[0]["hobbies"] =
                                                  0;
                                              networkCRUD
                                                  .updateUserPrivacyDetails([
                                                _currentUserId,
                                                userPrivacyLocal[0]["address"],
                                                userPrivacyLocal[0]["ambition"],
                                                userPrivacyLocal[0]
                                                    ["dreamvacations"],
                                                userPrivacyLocal[0]["email"],
                                                userPrivacyLocal[0]["friends"],
                                                userPrivacyLocal[0]["mygroups"],
                                                userPrivacyLocal[0]["hobbies"],
                                                userPrivacyLocal[0]["library"],
                                                userPrivacyLocal[0]["mobileno"],
                                                userPrivacyLocal[0]["novels"],
                                                userPrivacyLocal[0]
                                                    ["placesvisited"],
                                                userPrivacyLocal[0]
                                                    ["schooladdress"],
                                                userPrivacyLocal[0]
                                                    ["scorecards"],
                                                userPrivacyLocal[0]["uploads"],
                                                userPrivacyLocal[0]["weakness"],
                                                comparedate
                                              ]);
                                            });
                                          }
                                        },
                                        child: Container(
                                          padding: EdgeInsets.all(8),
                                          margin: EdgeInsets.all(8),
                                          width: 50,
                                          decoration: BoxDecoration(
                                              color: userPrivacyLocal[0]
                                                          ["hobbies"] ==
                                                      0
                                                  ? Color.fromRGBO(
                                                      88, 165, 196, 1)
                                                  : Colors.white,
                                              border: Border.all(
                                                  color: Colors.black45),
                                              borderRadius:
                                                  BorderRadius.circular(5)),
                                          child: Center(
                                            child: Text("No",
                                                style: TextStyle(
                                                    color: userPrivacyLocal[0]
                                                                ["hobbies"] ==
                                                            1
                                                        ? Colors.black
                                                        : Colors.white,
                                                    fontSize: 15,
                                                    fontWeight:
                                                        FontWeight.w800)),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  width: 300,
                                  child: Text("Ambition",
                                      style: TextStyle(
                                          color: Colors.black87,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500)),
                                ),
                                Container(
                                  child: Row(
                                    children: [
                                      InkWell(
                                        onTap: () async {
                                          if (userPrivacyLocal[0]["ambition"] ==
                                              0) {
                                            setState(() {
                                              userPrivacyLocal[0]["ambition"] =
                                                  1;
                                              networkCRUD
                                                  .updateUserPrivacyDetails([
                                                _currentUserId,
                                                userPrivacyLocal[0]["address"],
                                                userPrivacyLocal[0]["ambition"],
                                                userPrivacyLocal[0]
                                                    ["dreamvacations"],
                                                userPrivacyLocal[0]["email"],
                                                userPrivacyLocal[0]["friends"],
                                                userPrivacyLocal[0]["mygroups"],
                                                userPrivacyLocal[0]["hobbies"],
                                                userPrivacyLocal[0]["library"],
                                                userPrivacyLocal[0]["mobileno"],
                                                userPrivacyLocal[0]["novels"],
                                                userPrivacyLocal[0]
                                                    ["placesvisited"],
                                                userPrivacyLocal[0]
                                                    ["schooladdress"],
                                                userPrivacyLocal[0]
                                                    ["scorecards"],
                                                userPrivacyLocal[0]["uploads"],
                                                userPrivacyLocal[0]["weakness"],
                                                comparedate
                                              ]);
                                            });
                                          }
                                        },
                                        child: Container(
                                          padding: EdgeInsets.all(8),
                                          margin: EdgeInsets.all(8),
                                          width: 50,
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Colors.black45),
                                              color: userPrivacyLocal[0]
                                                          ["ambition"] ==
                                                      1
                                                  ? Color.fromRGBO(
                                                      88, 165, 196, 1)
                                                  : Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(5)),
                                          child: Center(
                                            child: Text("Yes",
                                                style: TextStyle(
                                                    color: userPrivacyLocal[0]
                                                                ["ambition"] ==
                                                            0
                                                        ? Colors.black
                                                        : Colors.white,
                                                    fontSize: 15,
                                                    fontWeight:
                                                        FontWeight.w800)),
                                          ),
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () async {
                                          if (userPrivacyLocal[0]["ambition"] ==
                                              1) {
                                            setState(() {
                                              userPrivacyLocal[0]["ambition"] =
                                                  0;
                                              networkCRUD
                                                  .updateUserPrivacyDetails([
                                                _currentUserId,
                                                userPrivacyLocal[0]["address"],
                                                userPrivacyLocal[0]["ambition"],
                                                userPrivacyLocal[0]
                                                    ["dreamvacations"],
                                                userPrivacyLocal[0]["email"],
                                                userPrivacyLocal[0]["friends"],
                                                userPrivacyLocal[0]["mygroups"],
                                                userPrivacyLocal[0]["hobbies"],
                                                userPrivacyLocal[0]["library"],
                                                userPrivacyLocal[0]["mobileno"],
                                                userPrivacyLocal[0]["novels"],
                                                userPrivacyLocal[0]
                                                    ["placesvisited"],
                                                userPrivacyLocal[0]
                                                    ["schooladdress"],
                                                userPrivacyLocal[0]
                                                    ["scorecards"],
                                                userPrivacyLocal[0]["uploads"],
                                                userPrivacyLocal[0]["weakness"],
                                                comparedate
                                              ]);
                                            });
                                          }
                                        },
                                        child: Container(
                                          padding: EdgeInsets.all(8),
                                          margin: EdgeInsets.all(8),
                                          width: 50,
                                          decoration: BoxDecoration(
                                              color: userPrivacyLocal[0]
                                                          ["ambition"] ==
                                                      0
                                                  ? Color.fromRGBO(
                                                      88, 165, 196, 1)
                                                  : Colors.white,
                                              border: Border.all(
                                                  color: Colors.black45),
                                              borderRadius:
                                                  BorderRadius.circular(5)),
                                          child: Center(
                                            child: Text("No",
                                                style: TextStyle(
                                                    color: userPrivacyLocal[0]
                                                                ["ambition"] ==
                                                            1
                                                        ? Colors.black
                                                        : Colors.white,
                                                    fontSize: 15,
                                                    fontWeight:
                                                        FontWeight.w800)),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  width: 300,
                                  child: Text("Novels Read",
                                      style: TextStyle(
                                          color: Colors.black87,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500)),
                                ),
                                Container(
                                  child: Row(
                                    children: [
                                      InkWell(
                                        onTap: () async {
                                          if (userPrivacyLocal[0]["novels"] ==
                                              0) {
                                            setState(() {
                                              userPrivacyLocal[0]["novels"] = 1;
                                              networkCRUD
                                                  .updateUserPrivacyDetails([
                                                _currentUserId,
                                                userPrivacyLocal[0]["address"],
                                                userPrivacyLocal[0]["ambition"],
                                                userPrivacyLocal[0]
                                                    ["dreamvacations"],
                                                userPrivacyLocal[0]["email"],
                                                userPrivacyLocal[0]["friends"],
                                                userPrivacyLocal[0]["mygroups"],
                                                userPrivacyLocal[0]["hobbies"],
                                                userPrivacyLocal[0]["library"],
                                                userPrivacyLocal[0]["mobileno"],
                                                userPrivacyLocal[0]["novels"],
                                                userPrivacyLocal[0]
                                                    ["placesvisited"],
                                                userPrivacyLocal[0]
                                                    ["schooladdress"],
                                                userPrivacyLocal[0]
                                                    ["scorecards"],
                                                userPrivacyLocal[0]["uploads"],
                                                userPrivacyLocal[0]["weakness"],
                                                comparedate
                                              ]);
                                            });
                                          }
                                        },
                                        child: Container(
                                          padding: EdgeInsets.all(8),
                                          margin: EdgeInsets.all(8),
                                          width: 50,
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Colors.black45),
                                              color: userPrivacyLocal[0]
                                                          ["novels"] ==
                                                      1
                                                  ? Color.fromRGBO(
                                                      88, 165, 196, 1)
                                                  : Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(5)),
                                          child: Center(
                                            child: Text("Yes",
                                                style: TextStyle(
                                                    color: userPrivacyLocal[0]
                                                                ["novels"] ==
                                                            0
                                                        ? Colors.black
                                                        : Colors.white,
                                                    fontSize: 15,
                                                    fontWeight:
                                                        FontWeight.w800)),
                                          ),
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () async {
                                          if (userPrivacyLocal[0]["novels"] ==
                                              1) {
                                            setState(() {
                                              userPrivacyLocal[0]["novels"] = 0;
                                              networkCRUD
                                                  .updateUserPrivacyDetails([
                                                _currentUserId,
                                                userPrivacyLocal[0]["address"],
                                                userPrivacyLocal[0]["ambition"],
                                                userPrivacyLocal[0]
                                                    ["dreamvacations"],
                                                userPrivacyLocal[0]["email"],
                                                userPrivacyLocal[0]["friends"],
                                                userPrivacyLocal[0]["mygroups"],
                                                userPrivacyLocal[0]["hobbies"],
                                                userPrivacyLocal[0]["library"],
                                                userPrivacyLocal[0]["mobileno"],
                                                userPrivacyLocal[0]["novels"],
                                                userPrivacyLocal[0]
                                                    ["placesvisited"],
                                                userPrivacyLocal[0]
                                                    ["schooladdress"],
                                                userPrivacyLocal[0]
                                                    ["scorecards"],
                                                userPrivacyLocal[0]["uploads"],
                                                userPrivacyLocal[0]["weakness"],
                                                comparedate
                                              ]);
                                            });
                                          }
                                        },
                                        child: Container(
                                          padding: EdgeInsets.all(8),
                                          margin: EdgeInsets.all(8),
                                          width: 50,
                                          decoration: BoxDecoration(
                                              color: userPrivacyLocal[0]
                                                          ["novels"] ==
                                                      0
                                                  ? Color.fromRGBO(
                                                      88, 165, 196, 1)
                                                  : Colors.white,
                                              border: Border.all(
                                                  color: Colors.black45),
                                              borderRadius:
                                                  BorderRadius.circular(5)),
                                          child: Center(
                                            child: Text("No",
                                                style: TextStyle(
                                                    color: userPrivacyLocal[0]
                                                                ["novels"] ==
                                                            1
                                                        ? Colors.black
                                                        : Colors.white,
                                                    fontSize: 15,
                                                    fontWeight:
                                                        FontWeight.w800)),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  width: 300,
                                  child: Text("Places Visited",
                                      style: TextStyle(
                                          color: Colors.black87,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500)),
                                ),
                                Container(
                                  child: Row(
                                    children: [
                                      InkWell(
                                        onTap: () async {
                                          if (userPrivacyLocal[0]
                                                  ["placesvisited"] ==
                                              0) {
                                            setState(() {
                                              userPrivacyLocal[0]
                                                  ["placesvisited"] = 1;
                                              networkCRUD
                                                  .updateUserPrivacyDetails([
                                                _currentUserId,
                                                userPrivacyLocal[0]["address"],
                                                userPrivacyLocal[0]["ambition"],
                                                userPrivacyLocal[0]
                                                    ["dreamvacations"],
                                                userPrivacyLocal[0]["email"],
                                                userPrivacyLocal[0]["friends"],
                                                userPrivacyLocal[0]["mygroups"],
                                                userPrivacyLocal[0]["hobbies"],
                                                userPrivacyLocal[0]["library"],
                                                userPrivacyLocal[0]["mobileno"],
                                                userPrivacyLocal[0]["novels"],
                                                userPrivacyLocal[0]
                                                    ["placesvisited"],
                                                userPrivacyLocal[0]
                                                    ["schooladdress"],
                                                userPrivacyLocal[0]
                                                    ["scorecards"],
                                                userPrivacyLocal[0]["uploads"],
                                                userPrivacyLocal[0]["weakness"],
                                                comparedate
                                              ]);
                                            });
                                          }
                                        },
                                        child: Container(
                                          padding: EdgeInsets.all(8),
                                          margin: EdgeInsets.all(8),
                                          width: 50,
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Colors.black45),
                                              color: userPrivacyLocal[0]
                                                          ["placesvisited"] ==
                                                      1
                                                  ? Color.fromRGBO(
                                                      88, 165, 196, 1)
                                                  : Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(5)),
                                          child: Center(
                                            child: Text("Yes",
                                                style: TextStyle(
                                                    color: userPrivacyLocal[0][
                                                                "placesvisited"] ==
                                                            0
                                                        ? Colors.black
                                                        : Colors.white,
                                                    fontSize: 15,
                                                    fontWeight:
                                                        FontWeight.w800)),
                                          ),
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () async {
                                          if (userPrivacyLocal[0]
                                                  ["placesvisited"] ==
                                              1) {
                                            setState(() {
                                              userPrivacyLocal[0]
                                                  ["placesvisited"] = 0;
                                              networkCRUD
                                                  .updateUserPrivacyDetails([
                                                _currentUserId,
                                                userPrivacyLocal[0]["address"],
                                                userPrivacyLocal[0]["ambition"],
                                                userPrivacyLocal[0]
                                                    ["dreamvacations"],
                                                userPrivacyLocal[0]["email"],
                                                userPrivacyLocal[0]["friends"],
                                                userPrivacyLocal[0]["mygroups"],
                                                userPrivacyLocal[0]["hobbies"],
                                                userPrivacyLocal[0]["library"],
                                                userPrivacyLocal[0]["mobileno"],
                                                userPrivacyLocal[0]["novels"],
                                                userPrivacyLocal[0]
                                                    ["placesvisited"],
                                                userPrivacyLocal[0]
                                                    ["schooladdress"],
                                                userPrivacyLocal[0]
                                                    ["scorecards"],
                                                userPrivacyLocal[0]["uploads"],
                                                userPrivacyLocal[0]["weakness"],
                                                comparedate
                                              ]);
                                            });
                                          }
                                        },
                                        child: Container(
                                          padding: EdgeInsets.all(8),
                                          margin: EdgeInsets.all(8),
                                          width: 50,
                                          decoration: BoxDecoration(
                                              color: userPrivacyLocal[0]
                                                          ["placesvisited"] ==
                                                      0
                                                  ? Color.fromRGBO(
                                                      88, 165, 196, 1)
                                                  : Colors.white,
                                              border: Border.all(
                                                  color: Colors.black45),
                                              borderRadius:
                                                  BorderRadius.circular(5)),
                                          child: Center(
                                            child: Text("No",
                                                style: TextStyle(
                                                    color: userPrivacyLocal[0][
                                                                "placesvisited"] ==
                                                            1
                                                        ? Colors.black
                                                        : Colors.white,
                                                    fontSize: 15,
                                                    fontWeight:
                                                        FontWeight.w800)),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  width: 300,
                                  child: Text("Dream Vacations",
                                      style: TextStyle(
                                          color: Colors.black87,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500)),
                                ),
                                Container(
                                  child: Row(
                                    children: [
                                      InkWell(
                                        onTap: () async {
                                          if (userPrivacyLocal[0]
                                                  ["dreamvacations"] ==
                                              0) {
                                            setState(() {
                                              userPrivacyLocal[0]
                                                  ["dreamvacations"] = 1;
                                              networkCRUD
                                                  .updateUserPrivacyDetails([
                                                _currentUserId,
                                                userPrivacyLocal[0]["address"],
                                                userPrivacyLocal[0]["ambition"],
                                                userPrivacyLocal[0]
                                                    ["dreamvacations"],
                                                userPrivacyLocal[0]["email"],
                                                userPrivacyLocal[0]["friends"],
                                                userPrivacyLocal[0]["mygroups"],
                                                userPrivacyLocal[0]["hobbies"],
                                                userPrivacyLocal[0]["library"],
                                                userPrivacyLocal[0]["mobileno"],
                                                userPrivacyLocal[0]["novels"],
                                                userPrivacyLocal[0]
                                                    ["placesvisited"],
                                                userPrivacyLocal[0]
                                                    ["schooladdress"],
                                                userPrivacyLocal[0]
                                                    ["scorecards"],
                                                userPrivacyLocal[0]["uploads"],
                                                userPrivacyLocal[0]["weakness"],
                                                comparedate
                                              ]);
                                            });
                                          }
                                        },
                                        child: Container(
                                          padding: EdgeInsets.all(8),
                                          margin: EdgeInsets.all(8),
                                          width: 50,
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Colors.black45),
                                              color: userPrivacyLocal[0]
                                                          ["dreamvacations"] ==
                                                      1
                                                  ? Color.fromRGBO(
                                                      88, 165, 196, 1)
                                                  : Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(5)),
                                          child: Center(
                                            child: Text("Yes",
                                                style: TextStyle(
                                                    color: userPrivacyLocal[0][
                                                                "dreamvacations"] ==
                                                            0
                                                        ? Colors.black
                                                        : Colors.white,
                                                    fontSize: 15,
                                                    fontWeight:
                                                        FontWeight.w800)),
                                          ),
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () async {
                                          if (userPrivacyLocal[0]
                                                  ["dreamvacations"] ==
                                              1) {
                                            setState(() {
                                              userPrivacyLocal[0]
                                                  ["dreamvacations"] = 0;
                                              networkCRUD
                                                  .updateUserPrivacyDetails([
                                                _currentUserId,
                                                userPrivacyLocal[0]["address"],
                                                userPrivacyLocal[0]["ambition"],
                                                userPrivacyLocal[0]
                                                    ["dreamvacations"],
                                                userPrivacyLocal[0]["email"],
                                                userPrivacyLocal[0]["friends"],
                                                userPrivacyLocal[0]["mygroups"],
                                                userPrivacyLocal[0]["hobbies"],
                                                userPrivacyLocal[0]["library"],
                                                userPrivacyLocal[0]["mobileno"],
                                                userPrivacyLocal[0]["novels"],
                                                userPrivacyLocal[0]
                                                    ["placesvisited"],
                                                userPrivacyLocal[0]
                                                    ["schooladdress"],
                                                userPrivacyLocal[0]
                                                    ["scorecards"],
                                                userPrivacyLocal[0]["uploads"],
                                                userPrivacyLocal[0]["weakness"],
                                                comparedate
                                              ]);
                                            });
                                          }
                                        },
                                        child: Container(
                                          padding: EdgeInsets.all(8),
                                          margin: EdgeInsets.all(8),
                                          width: 50,
                                          decoration: BoxDecoration(
                                              color: userPrivacyLocal[0]
                                                          ["dreamvacations"] ==
                                                      0
                                                  ? Color.fromRGBO(
                                                      88, 165, 196, 1)
                                                  : Colors.white,
                                              border: Border.all(
                                                  color: Colors.black45),
                                              borderRadius:
                                                  BorderRadius.circular(5)),
                                          child: Center(
                                            child: Text("No",
                                                style: TextStyle(
                                                    color: userPrivacyLocal[0][
                                                                "dreamvacations"] ==
                                                            1
                                                        ? Colors.black
                                                        : Colors.white,
                                                    fontSize: 15,
                                                    fontWeight:
                                                        FontWeight.w800)),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                            SizedBox(
                              height: 40,
                            ),
                          ],
                        ),
                ),
              );
            }));
  }

  _profile() {
    List lang = userPreferredLang;
    return ListView(physics: BouncingScrollPhysics(), children: [
      Padding(
        padding: const EdgeInsets.only(left: 12, top: 20),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            SizedBox(
              width: 100,
              child: Text(
                "Name",
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
            SizedBox(
              width: 220,
              child: Text(selectedUserData[0]['first_name'] +
                  ' ' +
                  selectedUserData[0]['last_name']),
            ),
          ]),
          SizedBox(
            height: 10,
          ),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            SizedBox(
              width: 100,
              child: Text(
                "Gender",
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
            SizedBox(width: 220, child: Text(selectedUserData[0]['gender']))
          ]),
          SizedBox(
            height: 10,
          ),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            SizedBox(
              width: 100,
              child: Text(
                "School",
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
            SizedBox(
                width: 220, child: Text(selectedUserData[0]['school_name']))
          ]),
          SizedBox(
            height: 10,
          ),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            SizedBox(
              width: 100,
              child: Text(
                "Grade",
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
            SizedBox(
                width: 220,
                child: Text(selectedUserData[0]['grade'].toString()))
          ]),
          SizedBox(
            height: 10,
          ),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            SizedBox(
              width: 100,
              child: Text(
                "Area",
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
            SizedBox(
                width: 220,
                child: Text(selectedUserData[0]['address'] == null
                    ? ""
                    : selectedUserData[0]['address']))
          ]),
          SizedBox(
            height: 10,
          ),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            SizedBox(
              width: 100,
              child: Text(
                "Place",
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
            SizedBox(
                width: 220,
                child: Text(selectedUserData[0]['street'] == null
                    ? ""
                    : selectedUserData[0]['street']))
          ]),
          SizedBox(
            height: 10,
          ),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            SizedBox(
              width: 100,
              child: Text(
                "Hometown",
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
            SizedBox(
              width: 220,
              child: Text(selectedUserData[0]['city'] == null
                  ? ""
                  : selectedUserData[0]['city']),
            ),
          ]),
          SizedBox(
            height: 10,
          ),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            SizedBox(
              width: 100,
              child: Text(
                "Languages Spoken",
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
            SizedBox(
                width: 220,
                child: Text(
                    lang.toString().substring(1, lang.toString().length - 1))),
          ]),
          SizedBox(
            height: 10,
          ),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            SizedBox(
              width: 100,
              child: Text(
                "Hobbies",
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
            SizedBox(
              width: 220,
              child: Text(""),
            ),
          ]),
          SizedBox(
            height: 10,
          ),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            SizedBox(
              width: 100,
              child: Text(
                "Ambition",
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
            SizedBox(
              width: 220,
              child: Text(""),
            ),
          ]),
          SizedBox(
            height: 10,
          ),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            SizedBox(
              width: 100,
              child: Text(
                "Novels Read",
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
            SizedBox(
              width: 220,
              child: Text(""),
            ),
          ]),
          SizedBox(
            height: 10,
          ),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            SizedBox(
              width: 100,
              child: Text(
                "Places Visited",
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
            SizedBox(
              width: 220,
              child: Text(""),
            ),
          ]),
          SizedBox(
            height: 10,
          ),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            SizedBox(
              width: 100,
              child: Text(
                "Dream Vacations",
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
            SizedBox(
              width: 220,
              child: Text(""),
            ),
          ]),
        ]),
      ),
    ]);
  }

  _mapCreate() {
    subjectsList.clear();

    int length = map.length;

    if (map != null) {
      for (int i = 0; i < length; i++) {
        subjectsList.add(map.keys.elementAt(i));
        strengthSubjectListBool.add(false);
        weaknessSubjectListBool.add(false);
      }
    }
  }

  int len = 0;
  String selectedSubjectForStrengthORWeakness = '';
  List<String> selectedTopicForStrengthORWeakness = [];

  _showTopics(String subject2, String logic) {
    List<String> topics2;
    topics2 = map[subject2]!;
    setState(() {
      selectedSubjectForStrengthORWeakness = subject2;
      selectedTopicForStrengthORWeakness = map[subject2]!;
    });
    for (int i = 0; i < topics2.length; i++) {
      selectedBTList.add(false);
      selectallBTList.add(true);
      deselectallBTList.add(false);
    }
    len = selectedUserStrengthData.length;
    initializeSelected(len);
    _ViewStrengthORWeaknessTopics(subject2, topics2, logic);
  }

  void initializeSelected(len) {
    for (int i = 0; i < len; i++) {
      if (selectedUserStrengthData[i]['grade'].toString() ==
          selectedUserData[0]["grade"].toString()) {
        if (selectedUserStrengthData[i]['subject'] ==
            selectedSubjectForStrengthORWeakness) {
          selectedBTList[selectedTopicForStrengthORWeakness
              .indexOf(selectedUserStrengthData[i]['topic'])] = true;
        }
      }
    }
    setState(() {
      _checkselectedBTList = selectedBTList;
    });
    print(_checkselectedBTList);
  }

  Map<String, String> imageMap = {
    'Political Science/Civics':
        'https://firebasestorage.googleapis.com/v0/b/hys-pro-41c66.appspot.com/o/assets%2FcivicsIcon.png?alt=media&token=cc6cd9db-5ebe-4590-b5c4-8ee0317af757',
    'Geography':
        'https://firebasestorage.googleapis.com/v0/b/hys-pro-41c66.appspot.com/o/assets%2FgeogIcon.png?alt=media&token=ca048ebe-76cf-456d-9b0b-4b0ea15db5ca',
    'History':
        'https://firebasestorage.googleapis.com/v0/b/hys-pro-41c66.appspot.com/o/assets%2FhistoryIcon.png?alt=media&token=15a0d685-8f3a-45d7-ab12-2e52535afae1',
    'Mathematics':
        'https://firebasestorage.googleapis.com/v0/b/hys-pro-41c66.appspot.com/o/assets%2FmathIcon.png?alt=media&token=ea1db370-52bc-4ec8-8565-1cc5b3488d00',
    'Physics':
        'https://firebasestorage.googleapis.com/v0/b/hys-pro-41c66.appspot.com/o/assets%2FphysicsIcon.png?alt=media&token=2d7e7b49-2462-4971-a87a-a8482eb0aa64',
    'Chemistry':
        'https://firebasestorage.googleapis.com/v0/b/hys-pro-41c66.appspot.com/o/assets%2FchemistryIcon1.png?alt=media&token=6d867120-ccd0-457a-a9e1-398692775c96',
    'Biology':
        'https://firebasestorage.googleapis.com/v0/b/hys-pro-41c66.appspot.com/o/assets%2FbioIcon.png?alt=media&token=144f8f4f-2455-485c-8752-123e26a70cf1',
    'others':
        'https://firebasestorage.googleapis.com/v0/b/hys-pro-41c66.appspot.com/o/assets%2FothersIcon2.png?alt=media&token=c03f4cf4-70fb-4b1e-88a7-69c88e834251',
    'Economics':
        'https://firebasestorage.googleapis.com/v0/b/hys-pro-41c66.appspot.com/o/assets%2FecoIcon2.jpg?alt=media&token=d2234daa-7153-4765-ae69-b66c87ff6958',
  };

  bool flag = false;
  _showImage(String sub) {
    if (imageMap.containsKey(sub) == true) {
      flag = true;
    } else
      flag = false;
    return Image.network(
        imageMap.containsKey(sub) == true
            ? imageMap[sub]!
            : imageMap["others"]!,
        width: 25,
        height: 25);
  }

  _strengths() {
    _mapCreate();
    return Container(
      width: 500,
      padding: const EdgeInsets.only(top: 30.0, left: 3),
      child: GridView.count(
          childAspectRatio: 1,
          crossAxisCount: 3,
          padding: EdgeInsets.all(10),
          children: List.generate(subjectsList.length, (index) {
            for (int k = 0; k < strengthSubject.length; k++) {
              if (strengthSubject[k] == subjectsList[index]) {
                setState(() {
                  strengthSubjectListBool[index] = true;
                });
              }
            }

            return InkWell(
                onTap: () {
                  _showTopics(subjectsList[index], "strength");
                  mapMain.clear();
                },
                child: Container(
                    height: 25,
                    width: 25,
                    margin: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: strengthSubjectListBool[index] == true
                            ? Color.fromRGBO(88, 165, 196, 1)
                            : Colors.transparent),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _showImage(subjectsList[index]),
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                            subjectsList[index],
                            textAlign: TextAlign.center,
                          )
                        ])));
          })),
    );
  }

  _weaknesses() {
    _mapCreate();
    return Container(
      width: 500,
      padding: const EdgeInsets.only(top: 30.0, left: 3),
      child: GridView.count(
          childAspectRatio: 1,
          crossAxisCount: 3,
          padding: EdgeInsets.all(10),
          children: List.generate(subjectsList.length, (index) {
            for (int k = 0; k < weaknessSubject.length; k++) {
              if (weaknessSubject[k] == subjectsList[index]) {
                weaknessSubjectListBool[index] = true;
              }
            }
            return InkWell(
                onTap: () {
                  _showTopics(subjectsList[index], "weakness");
                },
                child: Container(
                  height: 25,
                  width: 25,
                  margin: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: weaknessSubjectListBool[index] == true
                          ? Color.fromRGBO(88, 165, 196, 1)
                          : Colors.transparent),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _showImage(subjectsList[index]),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          subjectsList[index],
                          textAlign: TextAlign.center,
                        )
                      ]),
                ));
          })),
    );
  }

  _questions() {
    return Container(
      width: 500,
      padding: const EdgeInsets.only(top: 30.0, left: 3),
      child: GridView.count(
          childAspectRatio: 1,
          crossAxisCount: 3,
          padding: EdgeInsets.all(10),
          children: List.generate(qMap.length, (index) {
            return InkWell(
                onTap: () {
                  List<int> questionIndex = [];
                  for (int i = 0; i < allQuestionsData.length; i++) {
                    if ((allQuestionsData[i]["subject"] ==
                            qMap.keys.elementAt(index)) &&
                        (allQuestionsData[i]["user_id"] == this.user_id)) {
                      questionIndex.add(i);
                    }
                  }
                  _ViewUsersQUestions(
                      qMap.keys.elementAt(index), questionIndex);
                },
                child: Container(
                  height: 25,
                  width: 25,
                  margin: EdgeInsets.all(10),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _showImage(qMap.keys.elementAt(index)),
                        SizedBox(
                          height: 5,
                        ),
                        Text(qMap.keys.elementAt(index)),
                        SizedBox(height: 5),
                        Text(
                            qMap.values.elementAt(index).toString() +
                                " Questions",
                            style:
                                TextStyle(color: Colors.black38, fontSize: 12))
                      ]),
                ));
          })),
    );
  }

  _answers() {
    return Container(
      width: 300,
      padding: const EdgeInsets.only(top: 30.0, left: 3),
      child: GridView.count(
          childAspectRatio: 1,
          crossAxisCount: 3,
          padding: EdgeInsets.all(10),
          children: List.generate(aMap.length, (index) {
            return InkWell(
                onTap: () {
                  List<int> questionIndex = [];
                  List<List<int>> answerIndexQwise = [];
                  for (int i = 0; i < allQuestionsData.length; i++) {
                    if ((allQuestionsData[i]["subject"] ==
                            aMap.keys.elementAt(index)) &&
                        (allQuestionsData[i]["user_id"] == this.user_id)) {
                      questionIndex.add(i);
                    }
                  }
                  for (int i = 0; i < questionIndex.length; i++) {
                    List<int> check = [];
                    for (int j = 0; j < allAnswerData.length; j++) {
                      if (allAnswerData[j]["question_id"] ==
                          allQuestionsData[questionIndex[i]]["question_id"]) {
                        check.add(j);
                      }
                    }
                    answerIndexQwise.add(check);
                  }
                  print(questionIndex);
                  print(answerIndexQwise);
                  _viewUsersAnswers(aMap.keys.elementAt(index), questionIndex,
                      answerIndexQwise);
                },
                child: Container(
                  height: 25,
                  width: 25,
                  margin: EdgeInsets.all(10),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _showImage(aMap.keys.elementAt(index)),
                        SizedBox(
                          height: 5,
                        ),
                        Text(aMap.keys.elementAt(index)),
                        SizedBox(height: 5),
                        Text(
                            aMap.values.elementAt(index).toString() +
                                " Answers",
                            style:
                                TextStyle(color: Colors.black38, fontSize: 12))
                      ]),
                ));
          })),
    );
  }

  _uploads() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(left: 3, right: 3),
      width: 300,
      child: ListView(
        children: [
          SizedBox(height: 50),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              InkWell(
                onTap: () {
                  _ViewUploads("School Exams", subjectsOfUploads[0]);
                },
                child: Container(
                  padding: EdgeInsets.all(10),
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.transparent),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.network(
                          "https://firebasestorage.googleapis.com/v0/b/hys-pro-41c66.appspot.com/o/assets%2Fschoolnotes.png?alt=media&token=bd04f441-9737-4589-86e0-e8b5f8fa8c65",
                          height: 45,
                          width: 45,
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          "School Exams",
                          textAlign: TextAlign.center,
                        )
                      ]),
                ),
              ),
              InkWell(
                  onTap: () {
                    _ViewUploads("Class Notes", subjectsOfUploads[1]);
                  },
                  child: Container(
                    padding: EdgeInsets.all(10),
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.transparent),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.network(
                            "https://firebasestorage.googleapis.com/v0/b/hys-pro-41c66.appspot.com/o/assets%2Fclassnotes.jpg?alt=media&token=0506d559-9b1d-4a00-ad1d-c9729efccceb",
                            height: 45,
                            width: 45,
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                            "Class Notes",
                            textAlign: TextAlign.center,
                          )
                        ]),
                  )),
            ],
          ),
          SizedBox(
            height: 30,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              InkWell(
                  onTap: () {
                    _ViewUploads("Cometitve Exams", subjectsOfUploads[2]);
                  },
                  child: Container(
                    padding: EdgeInsets.all(10),
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.transparent),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.network(
                            "https://firebasestorage.googleapis.com/v0/b/hys-pro-41c66.appspot.com/o/assets%2Fcompetitiveexam.jpg?alt=media&token=b071ae9b-04d3-4ade-bf36-4aac71d7dd60",
                            height: 40,
                            width: 40,
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                            "Competitive Exam",
                            textAlign: TextAlign.center,
                          )
                        ]),
                  )),
              InkWell(
                  onTap: () {
                    _ViewUploads("Others", subjectsOfUploads[3]);
                  },
                  child: Container(
                    padding: EdgeInsets.all(10),
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.transparent),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.network(
                            "https://firebasestorage.googleapis.com/v0/b/hys-pro-41c66.appspot.com/o/assets%2Fothernotes.jpg?alt=media&token=3d9053ff-f1f4-4ebe-a115-3286298762e6",
                            height: 35,
                            width: 35,
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                            "Others",
                            textAlign: TextAlign.center,
                          )
                        ]),
                  )),
            ],
          ),
        ],
      ),
    );
  }

  fun() {
    return userAchievementsData.length == 0
        ? whenNoAchievement()
        : ListView.builder(
            itemCount: userAchievementsData.length,
            itemBuilder: (BuildContext context, int i) {
              return i == 0 ? ifIisZeroAchivement() : _achivement(i);
            });
  }

  whenNoAchievement() {
    return Center(
      child: this.user_id == _currentUserId
          ? Column(
              children: [
                SizedBox(
                  height: 70,
                ),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    _addAchievements();
                  },
                ),
                SizedBox(
                  height: 5,
                ),
                Text("Add Achievements")
              ],
            )
          : Column(
              children: [
                SizedBox(
                  height: 70,
                ),
                Text("No Achievements")
              ],
            ),
    );
  }

  ifIisZeroAchivement() {
    return Column(
      children: [
        SizedBox(
            height: 20,
            child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              this.user_id == _currentUserId
                  ? Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: InkWell(
                        onTap: () {
                          _addAchievements();
                        },
                        child: Container(
                            width: 20,
                            height: 20,
                            child: Icon(Icons.add, size: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(300),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                    offset: Offset(0, 5),
                                    blurRadius: 8,
                                    spreadRadius: -4)
                              ],
                            )),
                      ),
                    )
                  : SizedBox()
            ])),
        _achivement(0)
      ],
    );
  }

  _achivement(int i) {
    int check = -1;
    for (int k = 0; k < achScoreData.length; k++) {
      if (i == achScoreData[k]) {
        check = k;
      }
    }
    return userAchievementsData[i]["ach_type"] == "achievement"
        ? Container(
            padding: EdgeInsets.all(10),
            margin: EdgeInsets.all(7),
            decoration: BoxDecoration(
                color: Color.fromRGBO(242, 246, 248, 1),
                borderRadius: BorderRadius.all(Radius.circular(20))),
            child: Column(
              children: [
                Text(
                  userAchievementsData[i]["ach_title"],
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
                SizedBox(
                  height: 10,
                ),
                userAchievementsData[i]["ach_image_url"] != ""
                    ? InkWell(
                        onTap: () {},
                        child: Container(
                            height: 200,
                            width: 300,
                            child: CachedNetworkImage(
                              imageUrl: userAchievementsData[i]
                                  ["ach_image_url"],
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Image.network(
                                "https://firebasestorage.googleapis.com/v0/b/hys-pro-41c66.appspot.com/o/assets%2Floadingimg.gif?alt=media&token=4ca910f2-c584-4b3a-bbcb-2f1c01d93f67",
                              ),
                              errorWidget: (context, url, error) =>
                                  Icon(Icons.error),
                            )),
                      )
                    : SizedBox(),
                SizedBox(
                  height: 10,
                ),
                userAchievementsData[i]["ach_description"] != ""
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            userAchievementsData[i]["ach_description"],
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w400),
                          ),
                        ],
                      )
                    : SizedBox(),
                SizedBox(
                  height: 10,
                ),
              ],
            ))
        : check != -1
            ? Container(
                padding: EdgeInsets.all(10),
                margin: EdgeInsets.all(7),
                decoration: BoxDecoration(
                    color: Color.fromRGBO(242, 246, 248, 1),
                    borderRadius: BorderRadius.all(Radius.circular(20))),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(userAchievementsData[i]["scorecard_school_name"],
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w700)),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(userAchievementsData[i]["scorecard_board_name"],
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w500)),
                      ],
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                            "Grade: " +
                                userAchievementsData[i]["scorecard_grade"]
                                    .toString(),
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w500)),
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    for (int k = 0; k < achWiseScoreData[check].length; k++)
                      Container(
                        margin: EdgeInsets.only(bottom: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Container(
                              width: 120,
                              padding: EdgeInsets.all(10),
                              color: Colors.grey[300],
                              child: Text(
                                  userScorecardData[achWiseScoreData[check][k]]
                                      ["subject"],
                                  textAlign: TextAlign.center),
                            ),
                            Container(
                              width: 100,
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey[300]!)),
                              child: Text(
                                  userScorecardData[achWiseScoreData[check][k]]
                                      ["marks"],
                                  textAlign: TextAlign.center),
                            ),
                          ],
                        ),
                      ),
                    Container(
                      margin: EdgeInsets.only(bottom: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            width: 120,
                            padding: EdgeInsets.all(10),
                            color: Colors.grey[300],
                            child: Text(
                              "Total Score",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                          Container(
                            width: 100,
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[300]!)),
                            child: Text(
                                userAchievementsData[i]
                                    ["scorecard_total_score"],
                                style: TextStyle(fontWeight: FontWeight.w700),
                                textAlign: TextAlign.center),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              )
            : SizedBox();
  }

  bool toggle = true;
  String engMarks = "";
  String mathMarks = "";
  String sciMarks = "";
  String socialSciMarks = "";
  List<String> scoreCardSubject = ["English", "Matrhematics", "Science"];
  List<String> scoreCardSubjectsMarks = ["", "", ""];
  String totalScore = "";
  bool isImageAttached = false;
  String achievementDesc = "";
  String achievementTittle = "";
  String imgCameraUrl = "";

  void _pickAchievement(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      Dialogs.showLoadingDialog(context, _keyLoader);

      Uint8List? file = result.files.first.bytes;
      String fileName = result.files.first.name;
      UploadTask task = FirebaseStorage.instance
          .ref()
          .child("userAchievement/$_currentUserId/$fileName")
          .putData(file!);

      task.snapshotEvents.listen((event) async {
        setState(() {
          progress = ((event.bytesTransferred.toDouble() /
                      event.totalBytes.toDouble()) *
                  100)
              .roundToDouble();
        });
        if (progress == 100) {
          print(progress);
          String downloadURL = await FirebaseStorage.instance
              .ref("userAchievement/$_currentUserId/$fileName")
              .getDownloadURL();
          if (downloadURL != null) {
            Navigator.of(_keyLoader.currentContext!, rootNavigator: true)
                .pop(); //close the dialoge
            setState(() {
              print(downloadURL);
              imgCameraUrl = downloadURL;
              isImageAttached = true;
              progress = 0.0;
            });
            Navigator.of(context).pop();
            ElegantNotification.success(
              title: "Congrats,",
              description: "You attached video successfully.",
            );

            _addAchievements();
          }
        }
      });
    }
  }

  void _addAchievements() {
    showDialog(
        context: context,
        barrierColor: Colors.grey.withOpacity(0.2),
        barrierDismissible: false,
        builder: (_) => StatefulBuilder(builder: (context, setState) {
              return AlertDialog(
                contentPadding: EdgeInsets.all(20),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0)),
                title: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        uploaProcess != "viewsubjects"
                            ? IconButton(
                                onPressed: () {
                                  setState(() {
                                    uploaProcess = "viewsubjects";
                                  });
                                },
                                icon: const Tab(
                                    child: Icon(Icons.arrow_back_ios_outlined,
                                        color: Colors.black45, size: 25)),
                              )
                            : SizedBox(),
                        Text(
                          "Achievement",
                          style: const TextStyle(
                            fontSize: 20,
                            color: Color(0xCB000000),
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          icon: const Tab(
                              child: Icon(Icons.cancel_rounded,
                                  color: Colors.black45, size: 25)),
                        )
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(height: 1, width: 500, color: Colors.grey[200]),
                  ],
                ),
                content: SizedBox(
                  height: 470,
                  width: 500,
                  child: ListView(
                    children: [
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          InkWell(
                            onTap: () {
                              setState(() {
                                toggle = true;
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.all(10),
                              color: toggle == true
                                  ? Color.fromRGBO(88, 165, 196, 1)
                                  : Colors.transparent,
                              child: Center(
                                child: Text("Achievement",
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        color: toggle == true
                                            ? Colors.white
                                            : Colors.black87)),
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              setState(() {
                                toggle = false;
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.all(10),
                              color: toggle == false
                                  ? Color.fromRGBO(88, 165, 196, 1)
                                  : Colors.transparent,
                              child: Center(
                                child: Text("Score Card",
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        color: toggle == false
                                            ? Colors.white
                                            : Colors.black87)),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      toggle == true
                          ? Container(
                              child: Column(
                                children: [
                                  isImageAttached == false
                                      ? InkWell(
                                          onTap: () {
                                            _pickAchievement(context);
                                          },
                                          child: Container(
                                            child: Column(
                                              children: [
                                                IconButton(
                                                  icon: Icon(
                                                      Icons
                                                          .add_a_photo_outlined,
                                                      color: Color.fromRGBO(
                                                          88, 165, 196, 1)),
                                                  onPressed: () {
                                                    _pickAchievement(context);
                                                  },
                                                ),
                                                SizedBox(
                                                  height: 5,
                                                ),
                                                Text("Attachment",
                                                    style: TextStyle(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Color.fromRGBO(
                                                            88, 165, 196, 1))),
                                              ],
                                            ),
                                          ),
                                        )
                                      : InkWell(
                                          onTap: () {},
                                          onLongPress: () {
                                            setState(() {
                                              isImageAttached = false;

                                              imgCameraUrl = "";
                                            });
                                          },
                                          child: Container(
                                            child: Image.network(imgCameraUrl,
                                                height: 200, width: 250),
                                          ),
                                        ),
                                  SizedBox(height: 15),
                                  Container(
                                    padding:
                                        EdgeInsets.only(left: 30, right: 30),
                                    child: TextFormField(
                                      keyboardType: TextInputType.text,
                                      initialValue: achievementTittle,
                                      cursorColor: Color(0xff0962ff),
                                      style: TextStyle(
                                          fontSize: 15,
                                          color: Color(0xff0962ff),
                                          fontWeight: FontWeight.bold),
                                      validator: (val) => ((val!.isEmpty))
                                          ? 'Enter tittle for your achievement'
                                          : null,
                                      onChanged: (val) {
                                        setState(() {
                                          achievementTittle = val;
                                        });
                                      },
                                      decoration: InputDecoration(
                                        fillColor: Colors.white,
                                        filled: true,
                                        counterText: '',
                                        hintText: 'Tittle',
                                        hintStyle: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey[350],
                                            fontWeight: FontWeight.w600),
                                        alignLabelWithHint: false,
                                        contentPadding: EdgeInsets.symmetric(
                                            vertical: 10.0, horizontal: 10),
                                        errorStyle: TextStyle(
                                            color:
                                                Color.fromRGBO(240, 20, 41, 1)),
                                        focusColor: Color(0xff0962ff),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          borderSide: BorderSide(
                                              color: Color(0xff0962ff)),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          borderSide: BorderSide(
                                            color: Colors.grey[350]!,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 15),
                                  Container(
                                    padding:
                                        EdgeInsets.only(left: 30, right: 30),
                                    child: TextFormField(
                                      minLines: 6,
                                      maxLines: 7,
                                      keyboardType: TextInputType.text,
                                      initialValue: achievementDesc,
                                      cursorColor: Color(0xff0962ff),
                                      style: TextStyle(
                                          fontSize: 15,
                                          color: Color(0xff0962ff),
                                          fontWeight: FontWeight.bold),
                                      validator: (val) => ((val!.isEmpty))
                                          ? 'Write down few words about your achievement'
                                          : null,
                                      onChanged: (val) {
                                        setState(() {
                                          achievementDesc = val;
                                        });
                                      },
                                      decoration: InputDecoration(
                                        fillColor: Colors.white,
                                        filled: true,
                                        counterText: '',
                                        hintText: 'Description',
                                        hintStyle: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey[350],
                                            fontWeight: FontWeight.w600),
                                        alignLabelWithHint: false,
                                        contentPadding:
                                            new EdgeInsets.symmetric(
                                                vertical: 10.0, horizontal: 10),
                                        errorStyle: TextStyle(
                                            color:
                                                Color.fromRGBO(240, 20, 41, 1)),
                                        focusColor: Color(0xff0962ff),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          borderSide: BorderSide(
                                              color: Color(0xff0962ff)),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          borderSide: BorderSide(
                                            color: Colors.grey[350]!,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 15),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        height: 50,
                                        width: 350,
                                        child: RaisedButton(
                                            shape: RoundedRectangleBorder(
                                                side: BorderSide(
                                                  color: Color.fromRGBO(
                                                      70, 167, 216, 1),
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(8.0)),
                                            color:
                                                Color.fromRGBO(70, 167, 216, 1),
                                            splashColor:
                                                Color.fromRGBO(70, 167, 216, 1),
                                            child: Center(
                                                child: Text(
                                              'Save',
                                              style: TextStyle(
                                                fontFamily: 'Product Sans',
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white,
                                              ),
                                            )),
                                            onPressed: () async {
                                              if (toggle == true) {
                                                {
                                                  if ((isImageAttached ==
                                                          true) &&
                                                      (achievementDesc != "") &&
                                                      (achievementTittle !=
                                                          "")) {
                                                    setState(() {
                                                      String achID = "ach" +
                                                          _currentUserId +
                                                          comparedate;
                                                      networkCRUD
                                                          .addUserAchievementDetails([
                                                        achID,
                                                        _currentUserId,
                                                        userDataDB!
                                                            .get("school_name"),
                                                        userDataDB!
                                                            .get("board"),
                                                        achievementDesc,
                                                        imgCameraUrl,
                                                        achievementTittle,
                                                        userDataDB!
                                                            .get("grade")
                                                            .toString(),
                                                        totalScore,
                                                        toggle == true
                                                            ? "achievement"
                                                            : "scorecard",
                                                        comparedate
                                                      ]);
                                                    });
                                                    ElegantNotification.success(
                                                      title: "Congrats,",
                                                      description:
                                                          "Your achievement saved successfully.",
                                                    );

                                                    _call_apis();
                                                    achievementDesc = "";
                                                    achievementTittle = "";
                                                    imgCameraUrl = "";
                                                    Navigator.of(context).pop();
                                                  }
                                                }
                                              }
                                            }),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 50,
                                  ),
                                ],
                              ),
                            )
                          : Container(
                              child: Column(
                                children: [
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(userDataDB!.get("school_name"),
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w700)),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(userDataDB!.get("board"),
                                          style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w500)),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                          "Grade: " +
                                              userDataDB!
                                                  .get("grade")
                                                  .toString(),
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w500)),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Container(
                                    height: (70 * scoreCardSubject.length)
                                        .toDouble(),
                                    child: ListView.builder(
                                      controller: _scrollController,
                                      itemCount: scoreCardSubject.length,
                                      itemBuilder: (context, i) {
                                        return Container(
                                          margin: EdgeInsets.only(bottom: 10),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              Container(
                                                width: 120,
                                                padding: EdgeInsets.all(10),
                                                color: Colors.grey[300],
                                                child: Text(scoreCardSubject[i],
                                                    textAlign:
                                                        TextAlign.center),
                                              ),
                                              Container(
                                                width: 100,
                                                child: TextFormField(
                                                  keyboardType:
                                                      TextInputType.text,
                                                  cursorColor:
                                                      Color(0xff0962ff),
                                                  style: TextStyle(
                                                      fontSize: 15,
                                                      color: Color(0xff0962ff),
                                                      fontWeight:
                                                          FontWeight.bold),
                                                  validator: (val) => ((val!
                                                          .isEmpty))
                                                      ? 'Enter subject marks here'
                                                      : null,
                                                  onChanged: (val) {
                                                    setState(() {
                                                      scoreCardSubjectsMarks[
                                                          i] = val;
                                                    });
                                                  },
                                                  decoration: InputDecoration(
                                                    fillColor: Colors.white,
                                                    filled: true,
                                                    counterText: '',
                                                    hintText: '%',
                                                    hintStyle: TextStyle(
                                                        fontSize: 13,
                                                        color: Colors.black45,
                                                        fontWeight:
                                                            FontWeight.w600),
                                                    alignLabelWithHint: false,
                                                    contentPadding:
                                                        new EdgeInsets
                                                                .symmetric(
                                                            horizontal: 10),
                                                    errorStyle: TextStyle(
                                                        color: Color.fromRGBO(
                                                            240, 20, 41, 1)),
                                                    focusColor:
                                                        Color(0xff0962ff),
                                                    focusedBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color: Color(
                                                              0xff0962ff)),
                                                    ),
                                                    enabledBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color:
                                                            Colors.grey[300]!,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(bottom: 10),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Container(
                                          width: 120,
                                          padding: EdgeInsets.all(10),
                                          color: Colors.grey[300],
                                          child: Text("Total Score",
                                              textAlign: TextAlign.center),
                                        ),
                                        Container(
                                          width: 100,
                                          child: TextFormField(
                                            keyboardType: TextInputType.text,
                                            cursorColor: Color(0xff0962ff),
                                            style: TextStyle(
                                                fontSize: 15,
                                                color: Color(0xff0962ff),
                                                fontWeight: FontWeight.bold),
                                            validator: (val) => ((val!.isEmpty))
                                                ? 'Enter total marks here'
                                                : null,
                                            onChanged: (val) {
                                              setState(() {
                                                totalScore = val;
                                              });
                                            },
                                            decoration: InputDecoration(
                                              fillColor: Colors.white,
                                              filled: true,
                                              counterText: '',
                                              hintText: '%',
                                              hintStyle: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.black45,
                                                  fontWeight: FontWeight.w600),
                                              alignLabelWithHint: false,
                                              contentPadding:
                                                  new EdgeInsets.symmetric(
                                                      horizontal: 10),
                                              errorStyle: TextStyle(
                                                  color: Color.fromRGBO(
                                                      240, 20, 41, 1)),
                                              focusColor: Color(0xff0962ff),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Color(0xff0962ff)),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: Colors.grey[300]!,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          _showScorerCardSubjectsDialog();
                                        },
                                        child: Container(
                                          padding: EdgeInsets.only(right: 20),
                                          child: Text("Add More",
                                              style: TextStyle(
                                                color: Color.fromRGBO(
                                                    70, 167, 216, 1),
                                              )),
                                        ),
                                      )
                                    ],
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        height: 50,
                                        width: 350,
                                        child: RaisedButton(
                                            shape: RoundedRectangleBorder(
                                                side: BorderSide(
                                                  color: Color.fromRGBO(
                                                      70, 167, 216, 1),
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(8.0)),
                                            color:
                                                Color.fromRGBO(70, 167, 216, 1),
                                            splashColor:
                                                Color.fromRGBO(70, 167, 216, 1),
                                            child: Center(
                                                child: Text(
                                              'Save',
                                              style: TextStyle(
                                                fontFamily: 'Product Sans',
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white,
                                              ),
                                            )),
                                            onPressed: () async {
                                              {
                                                if (toggle == false) {
                                                  int count = 0;
                                                  String achID = "ach" +
                                                      _currentUserId +
                                                      comparedate;
                                                  for (int k = 0;
                                                      k <
                                                          scoreCardSubjectsMarks
                                                              .length;
                                                      k++) {
                                                    if (scoreCardSubjectsMarks[
                                                            k] ==
                                                        "") {
                                                      count++;
                                                      break;
                                                    }
                                                  }
                                                  if (count == 0) {
                                                    networkCRUD
                                                        .addUserAchievementDetails([
                                                      achID,
                                                      _currentUserId,
                                                      userDataDB!
                                                          .get("school_name"),
                                                      userDataDB!.get("board"),
                                                      achievementDesc,
                                                      imgCameraUrl,
                                                      achievementTittle,
                                                      userDataDB!
                                                          .get("grade")
                                                          .toString(),
                                                      totalScore,
                                                      toggle == true
                                                          ? "achievement"
                                                          : "scorecard",
                                                      comparedate
                                                    ]);

                                                    for (int i = 0;
                                                        i <
                                                            scoreCardSubject
                                                                .length;
                                                        i++) {
                                                      networkCRUD
                                                          .addUserScorecardDetails([
                                                        achID,
                                                        _currentUserId,
                                                        scoreCardSubject[i],
                                                        scoreCardSubjectsMarks[
                                                            i]
                                                      ]);
                                                    }
                                                    ElegantNotification.success(
                                                      title: "Congrats,",
                                                      description:
                                                          "Your scorecard saved successfully.",
                                                    );

                                                    _call_apis();
                                                    Navigator.of(context).pop();
                                                  }
                                                }
                                              }
                                            }),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 50,
                                  ),
                                ],
                              ),
                            ),
                    ],
                  ),
                ),
              );
            }));
  }

  void _showScorerCardSubjectsDialog() {
    AlertDialog alertDialog = AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      content: Container(
          height: 300,
          width: 300,
          child: ListView.builder(
            itemCount: subjectsList.length,
            itemBuilder: (context, i) {
              return i == 0
                  ? ifIisZero(0)
                  : InkWell(
                      onTap: () {
                        if ((subjectsList[i] != "English") &&
                            ((subjectsList[i] != "Mathematics") &&
                                (subjectsList[i] != "Science"))) {
                          scoreCardSubject.add(subjectsList[i]);
                          scoreCardSubjectsMarks.add("");

                          Navigator.of(context).pop();
                          Navigator.of(context).pop();
                          _addAchievements();
                        } else {
                          Navigator.of(context).pop();
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.all(10),
                        child: Center(
                          child: Text(subjectsList[i],
                              textAlign: TextAlign.center),
                        ),
                      ),
                    );
            },
          )),
    );
    showDialog(context: context, builder: (_) => alertDialog);
  }

  ifIisZero(int i) {
    return Column(
      children: [
        Container(
            padding: EdgeInsets.all(10),
            child: Text("Choose Subject",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                textAlign: TextAlign.center)),
        SizedBox(
          height: 20,
        ),
        InkWell(
          onTap: () {
            if ((subjectsList[i] != "English") &&
                ((subjectsList[i] != "Mathematics") &&
                    (subjectsList[i] != "Science"))) {
              scoreCardSubject.add(subjectsList[i]);
              scoreCardSubjectsMarks.add("");

              Navigator.of(context).pop();
              Navigator.of(context).pop();
              _addAchievements();
            }
          },
          child: Container(
            padding: EdgeInsets.all(10),
            child: Center(
              child: Text(subjectsList[i], textAlign: TextAlign.center),
            ),
          ),
        )
      ],
    );
  }

  String uploaProcess = "viewsubjects";
  List<int> uploadIndexes = [];
  List<int> allUploadFileIndexes = [];
  List<List<int>> uploadFileIndexsesUploadIDWise = [];

  void _ViewUploads(String upload_type, List<String> _subjectList) {
    showDialog(
        context: context,
        barrierColor: Colors.grey.withOpacity(0.2),
        barrierDismissible: false,
        builder: (_) => StatefulBuilder(builder: (context, setState) {
              return AlertDialog(
                contentPadding: EdgeInsets.all(20),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0)),
                title: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        uploaProcess != "viewsubjects"
                            ? IconButton(
                                onPressed: () {
                                  setState(() {
                                    uploaProcess = "viewsubjects";
                                  });
                                },
                                icon: const Tab(
                                    child: Icon(Icons.arrow_back_ios_outlined,
                                        color: Colors.black45, size: 25)),
                              )
                            : SizedBox(),
                        Text(
                          upload_type,
                          style: const TextStyle(
                            fontSize: 20,
                            color: Color(0xCB000000),
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            uploaProcess = "viewsubjects";
                            uploadIndexes = [];
                            allUploadFileIndexes = [];
                            uploadFileIndexsesUploadIDWise = [];
                            Navigator.of(context).pop();
                          },
                          icon: const Tab(
                              child: Icon(Icons.cancel_rounded,
                                  color: Colors.black45, size: 25)),
                        )
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(height: 1, width: 500, color: Colors.grey[200]),
                  ],
                ),
                content: uploaProcess == "viewsubjects"
                    ? SizedBox(
                        height: 470,
                        width: 500,
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: GridView.count(
                              childAspectRatio: 1,
                              crossAxisCount: 3,
                              padding: EdgeInsets.all(10),
                              children:
                                  List.generate(_subjectList.length, (index) {
                                return InkWell(
                                    onTap: () {
                                      setState(() {
                                        uploadIndexes = [];
                                        uploadFileIndexsesUploadIDWise = [];
                                      });
                                      for (int i = 0;
                                          i < userUploadsData.length;
                                          i++) {
                                        if ((userUploadsData[i]["subject"] ==
                                                _subjectList[index]) &&
                                            (userUploadsData[i]
                                                    ["upload_type"] ==
                                                upload_type)) {
                                          uploadIndexes.add(i);
                                        }
                                      }

                                      for (int j = 0;
                                          j < uploadIndexes.length;
                                          j++) {
                                        List<int> uploadFileIndexes = [];

                                        for (int k = 0;
                                            k < uploadFilesData.length;
                                            k++) {
                                          if (userUploadsData[uploadIndexes[j]]
                                                  ["upload_id"] ==
                                              uploadFilesData[k]["upload_id"]) {
                                            uploadFileIndexes.add(k);
                                            allUploadFileIndexes.add(k);
                                          }
                                        }
                                        uploadFileIndexsesUploadIDWise
                                            .add(uploadFileIndexes);
                                      }

                                      setState(() {
                                        uploaProcess = 'viewtopics';
                                      });
                                    },
                                    child: Container(
                                      height: 25,
                                      width: 25,
                                      margin: EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          color: Colors.transparent),
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            _showImage(_subjectList[index]),
                                            SizedBox(
                                              height: 5,
                                            ),
                                            Text(
                                              ((_subjectList[index] == "") ||
                                                      (_subjectList[index] ==
                                                          null))
                                                  ? "Others"
                                                  : _subjectList[index],
                                              textAlign: TextAlign.center,
                                            )
                                          ]),
                                    ));
                              })),
                        ),
                      )
                    : uploaProcess == "viewtopics"
                        ? SizedBox(
                            height: 470,
                            width: 500,
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: ListView.builder(
                                itemCount: allUploadFileIndexes.length,
                                itemBuilder: (context, i) {
                                  return InkWell(
                                    onTap: () async {
                                      window.location.assign(uploadFilesData[
                                          allUploadFileIndexes[i]]["file_url"]);
                                      // _launchInBrowser(uploadFilesData[
                                      //     allUploadFileIndexes[i]]["file_url"]);
                                    },
                                    child: Container(
                                      height: 80,
                                      width: 500,
                                      padding: EdgeInsets.all(5),
                                      child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Icon(Icons.file_present),
                                            SizedBox(
                                              width: 30,
                                            ),
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                    uploadFilesData[
                                                        allUploadFileIndexes[
                                                            i]]["file_name"],
                                                    style: TextStyle(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.w600)),
                                                SizedBox(height: 5),
                                                Text(
                                                    uploadFilesData[
                                                                allUploadFileIndexes[
                                                                    i]]
                                                            ["createdate"]
                                                        .toString()
                                                        .substring(5, 17),
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w400)),
                                              ],
                                            )
                                          ]),
                                    ),
                                  );
                                },
                              ),
                            ),
                          )
                        : SizedBox(),
              );
            }));
  }

  void _ViewStrengthORWeaknessTopics(
      String subject, List<String> topics, String logicFor) {
    showDialog(
        context: context,
        barrierColor: Colors.grey.withOpacity(0.2),
        barrierDismissible: false,
        builder: (_) => StatefulBuilder(builder: (context, setState) {
              return AlertDialog(
                contentPadding: EdgeInsets.all(20),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0)),
                title: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(width: 30),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              subject,
                              style: const TextStyle(
                                fontSize: 20,
                                color: Color(0xCB000000),
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                                'Grade: ' +
                                    selectedUserData[0]["grade"].toString(),
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.normal)),
                          ],
                        ),
                        IconButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          icon: const Tab(
                              child: Icon(Icons.cancel_rounded,
                                  color: Colors.black45, size: 25)),
                        )
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(height: 1, width: 500, color: Colors.grey[200]),
                  ],
                ),
                content: SizedBox(
                  height: 470,
                  width: 500,
                  child: Column(children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 2, top: 6, right: 2),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon: Icon(Icons.arrow_back_ios_outlined,
                                    size: 20, color: Color(0xCB000000)),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                              Text('Topics',
                                  style: TextStyle(
                                    fontSize: 15,
                                  )),
                              _currentUserId == this.user_id
                                  ? InkWell(
                                      onTap: () {
                                        // setState(() {
                                        //   if (selectall == false) {
                                        //     selectedBTList = selectallBTList;

                                        //     selectall = true;
                                        //   } else {
                                        //     selectedBTList = deselectallBTList;

                                        //     selectall = false;
                                        //   }
                                        // });
                                      },
                                      child: Container(
                                        margin: EdgeInsets.only(right: 10),
                                        padding: EdgeInsets.only(
                                            left: 8,
                                            right: 8,
                                            top: 5,
                                            bottom: 5),
                                        decoration: BoxDecoration(
                                            color:
                                                Color.fromRGBO(88, 165, 196, 1),
                                            borderRadius:
                                                BorderRadius.circular(3)),
                                        child: Text(
                                          "Select all",
                                          style: TextStyle(
                                            fontFamily: 'Nunito Sans',
                                            fontSize: 17,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    )
                                  : SizedBox(
                                      width: 5,
                                    )
                            ],
                          ),
                          SizedBox(height: 30),
                          Container(
                            margin: EdgeInsets.only(left: 10, right: 10),
                            child: ListView.builder(
                                shrinkWrap: true,
                                controller: _scrollController,
                                physics: BouncingScrollPhysics(),
                                itemCount: topics.length,
                                itemBuilder: (BuildContext context, int k) {
                                  return InkWell(
                                    onTap: () {
                                      if (_currentUserId == this.user_id) {
                                        setState(() {
                                          //   selectedBTList[k] = !selectedBTList[k];
                                        });
                                      }
                                    },
                                    child: Container(
                                      margin:
                                          EdgeInsets.only(top: 10, bottom: 10),
                                      padding:
                                          EdgeInsets.only(top: 2, bottom: 2),
                                      color: selectedBTList[k] == false
                                          ? Colors.transparent
                                          : Color.fromRGBO(70, 167, 216, 1),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Container(
                                              child: Text(topics[k],
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color:
                                                          selectedBTList[k] ==
                                                                  false
                                                              ? Color.fromRGBO(
                                                                  62,
                                                                  98,
                                                                  116,
                                                                  1)
                                                              : Colors.white)),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          _currentUserId == this.user_id
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      height: 45,
                                      width: 120,
                                      child: RaisedButton(
                                          shape: RoundedRectangleBorder(
                                              side: BorderSide(
                                                color: Color.fromRGBO(
                                                    70, 167, 216, 1),
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8.0)),
                                          color:
                                              Color.fromRGBO(70, 167, 216, 1),
                                          splashColor:
                                              Color.fromRGBO(70, 167, 216, 1),
                                          child: Center(
                                            child: false == false
                                                ? Text(
                                                    'Update',
                                                    style: TextStyle(
                                                      fontFamily:
                                                          'Product Sans',
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Colors.white,
                                                    ),
                                                  )
                                                : Container(
                                                    height: 14,
                                                    width: 14,
                                                    child:
                                                        CircularProgressIndicator(
                                                      valueColor:
                                                          AlwaysStoppedAnimation<
                                                                  Color>(
                                                              Colors.white),
                                                    ),
                                                  ),
                                          ),
                                          onPressed: () {
                                            // setState(() {
                                            //   loading = true;
                                            //   for (int k = 0; k < subjectTopics.length; k++) {
                                            //     if (selectedBTList[k] == true) {
                                            //       selectedTopics.add(subjectTopics[k]);
                                            //     }
                                            //   }
                                            // });
                                            // print(selectedTopics);
                                            // for (int i = 0; i < len; i++) {
                                            //   if (strengthData.docs[i].get('grade') == grade) {
                                            //     if (strengthData.docs[i].get('subject') ==
                                            //         subject) {
                                            //       crudobj.deleteUserStrengthData(
                                            //           strengthData.docs[i].id);
                                            //     }
                                            //   }
                                            // }
                                            // for (int j = 0; j < selectedTopics.length; j++) {
                                            //   crudobj.addUserStrengthGradeSubjectTopicData(
                                            //       this.grade,
                                            //       this.subject,
                                            //       selectedTopics[j],
                                            //       current_date,
                                            //       comparedate);
                                            // }

                                            // selectedTopics.clear();

                                            // for (int i = 0; i < subjectTopics.length; i++) {
                                            //   selectedBTList.add(false);
                                            //   selectallBTList.add(true);
                                            //   deselectallBTList.add(false);
                                            // }
                                            // crudobj.getUserStrengthData(uid).then((value) {
                                            //   setState(() {
                                            //     strengthData = value;
                                            //     if (strengthData != null) {
                                            //       len = strengthData.docs.length;
                                            //       initializeSelected(len);
                                            //       loading = false;
                                            //     }
                                            //   });
                                            // });
                                            // Fluttertoast.showToast(
                                            //     msg: "Updated successfully!",
                                            //     toastLength: Toast.LENGTH_SHORT,
                                            //     gravity: ToastGravity.BOTTOM,
                                            //     timeInSecForIosWeb: 10,
                                            //     backgroundColor: Color.fromRGBO(37, 36, 36, 1.0),
                                            //     textColor: Colors.white,
                                            //     fontSize: 12.0);
                                            // Navigator.of(context).pop();
                                            // Navigator.of(context).pop();
                                          }),
                                    ),
                                  ],
                                )
                              : SizedBox(),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                  ]),
                ),
              );
            }));
  }

  void _ViewUsersQUestions(String subject, List<int> qIndex) {
    showDialog(
        context: context,
        barrierColor: Colors.grey.withOpacity(0.2),
        barrierDismissible: false,
        builder: (_) => StatefulBuilder(builder: (context, setState) {
              return AlertDialog(
                contentPadding: EdgeInsets.all(20),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0)),
                title: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(width: 30),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              subject,
                              style: const TextStyle(
                                fontSize: 20,
                                color: Color(0xCB000000),
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                                'Grade: ' +
                                    selectedUserData[0]["grade"].toString(),
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.normal)),
                          ],
                        ),
                        IconButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          icon: const Tab(
                              child: Icon(Icons.cancel_rounded,
                                  color: Colors.black45, size: 25)),
                        )
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(height: 1, width: 500, color: Colors.grey[200]),
                  ],
                ),
                content: SizedBox(
                  height: 500,
                  width: 550,
                  child: Column(children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 2, top: 6, right: 2),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Questions',
                                  style: TextStyle(
                                    fontSize: 15,
                                  )),
                            ],
                          ),
                          SizedBox(height: 30),
                          Container(
                            height: 400,
                            child: ListView.builder(
                                shrinkWrap: true,
                                controller: _scrollController,
                                physics: BouncingScrollPhysics(),
                                itemCount: qIndex.length,
                                itemBuilder: (cntx, index) {
                                  return _questionFeedText(qIndex[index]);
                                }),
                          ),
                        ],
                      ),
                    ),
                  ]),
                ),
              );
            }));
  }

  void _viewUsersAnswers(
      String subject, List<int> qIndex, List<List<int>> ansIndex) {
    showDialog(
        context: context,
        barrierColor: Colors.grey.withOpacity(0.2),
        barrierDismissible: false,
        builder: (_) => StatefulBuilder(builder: (context, setState) {
              return AlertDialog(
                contentPadding: EdgeInsets.all(20),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0)),
                title: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(width: 30),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              subject,
                              style: const TextStyle(
                                fontSize: 20,
                                color: Color(0xCB000000),
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                                'Grade: ' +
                                    selectedUserData[0]["grade"].toString(),
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.normal)),
                          ],
                        ),
                        IconButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          icon: const Tab(
                              child: Icon(Icons.cancel_rounded,
                                  color: Colors.black45, size: 25)),
                        )
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(height: 1, width: 500, color: Colors.grey[200]),
                  ],
                ),
                content: SizedBox(
                  height: 500,
                  width: 550,
                  child: Column(children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 2, top: 6, right: 2),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Answers',
                                  style: TextStyle(
                                    fontSize: 15,
                                  )),
                            ],
                          ),
                          SizedBox(height: 30),
                          Container(
                            height: 400,
                            child: ListView.builder(
                                shrinkWrap: true,
                                controller: _scrollController,
                                physics: BouncingScrollPhysics(),
                                itemCount: qIndex.length,
                                itemBuilder: (cntx, index) {
                                  return _questionFeedTextForAnswers(
                                      qIndex[index], ansIndex[index]);
                                }),
                          ),
                        ],
                      ),
                    ),
                  ]),
                ),
              );
            }));
  }

  _questionFeedText(int index) {
    DateTime tempDate = DateTime.parse(
        allQuestionsData[index]["compare_date"].toString().substring(0, 8));
    String current_date = DateFormat.yMMMMd('en_US').format(tempDate);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: () {
            Navigator.of(context).pop();
            databaseReference
                .child("hysweb")
                .child("qANDa")
                .child("jump_to_listview_index")
                .update({"$_currentUserId": index});
            databaseReference
                .child("hysweb")
                .child("app_bar_navigation")
                .child(FirebaseAuth.instance.currentUser!.uid)
                .update({"$_currentUserId": 1});
          },
          child: Container(
            width: 500,
            padding: EdgeInsets.all(10),
            margin: EdgeInsets.only(top: 20),
            decoration: BoxDecoration(
                color: Color.fromRGBO(242, 246, 248, 1),
                borderRadius: BorderRadius.circular(10)),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: (15.0), right: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        child: Row(
                          children: [
                            InkWell(
                              child: CircleAvatar(
                                child: ClipOval(
                                  child: Container(
                                    child: CachedNetworkImage(
                                      imageUrl: allQuestionsData[index]
                                          ["profilepic"],
                                      width: 40,
                                      height: 40,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => Container(
                                        width: 40,
                                        height: 40,
                                        color: Colors.white,
                                        child: Image.network(
                                          "https://firebasestorage.googleapis.com/v0/b/hys-pro-41c66.appspot.com/o/assets%2Floadingimg.gif?alt=media&token=4ca910f2-c584-4b3a-bbcb-2f1c01d93f67",
                                        ),
                                      ),
                                      errorWidget: (context, url, error) =>
                                          Icon(Icons.error),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Container(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  RichText(
                                    text: TextSpan(
                                        text: allQuestionsData[index]
                                                    ["is_identity_visible"] ==
                                                "true"
                                            ? "${allQuestionsData[index]["first_name"]} ${allQuestionsData[index]["last_name"]}, "
                                            : "HyS User",
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: dark,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        children: <TextSpan>[
                                          TextSpan(
                                            text: allQuestionsData[index][
                                                        "is_identity_visible"] ==
                                                    "true"
                                                ? allQuestionsData[index]
                                                    ["city"]
                                                : "",
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color:
                                                  Color.fromRGBO(0, 0, 0, 0.5),
                                              fontWeight: FontWeight.normal,
                                            ),
                                          )
                                        ]),
                                  ),
                                  allQuestionsData[index]
                                              ["is_identity_visible"] ==
                                          "true"
                                      ? Text(
                                          allQuestionsData[index]
                                                  ["school_name"] +
                                              ", " +
                                              "Grade " +
                                              (allQuestionsData[index]["grade"])
                                                  .toString(),
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Color.fromRGBO(0, 0, 0, 0.5),
                                            fontWeight: FontWeight.normal,
                                          ),
                                        )
                                      : SizedBox(),
                                  Text(
                                    "Posted on " + "$current_date",
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.normal,
                                      color: Color.fromRGBO(0, 0, 0, 0.5),
                                    ),
                                  ),
                                  // ((tagedusername.length > 0) &&
                                  //         (tagedusername[0] != "") &&
                                  //         (tagedusername != null))
                                  //     ? RichText(
                                  //         text: TextSpan(
                                  //             text: ' ${tagedusername[0]}',
                                  //             style: TextStyle(
                                  //                 fontFamily: 'Nunito Sans',
                                  //                 fontSize: 11,
                                  //                 fontWeight: FontWeight.normal,
                                  //                 color: Color(0xff0C2551)),
                                  //             children: <TextSpan>[
                                  //               (tagedusername.length > 1)
                                  //                   ? TextSpan(
                                  //                       text: ' &',
                                  //                       style: TextStyle(
                                  //                           fontFamily:
                                  //                               'Nunito Sans',
                                  //                           fontSize: 11,
                                  //                           fontWeight:
                                  //                               FontWeight.normal,
                                  //                           color:
                                  //                               Color(0xff0C2551)),
                                  //                       recognizer:
                                  //                           TapGestureRecognizer()
                                  //                             ..onTap = () {
                                  //                               // navigate to desired screen
                                  //                             })
                                  //                   : TextSpan(
                                  //                       text: '',
                                  //                     ),
                                  //               (tagedusername.length > 1)
                                  //                   ? TextSpan(
                                  //                       text:
                                  //                           ' ${tagedusername.length - 1} more',
                                  //                       style: TextStyle(
                                  //                           fontFamily:
                                  //                               'Nunito Sans',
                                  //                           fontSize: 11,
                                  //                           fontWeight:
                                  //                               FontWeight.normal,
                                  //                           color:
                                  //                               Color(0xff0C2551)),
                                  //                       recognizer:
                                  //                           TapGestureRecognizer()
                                  //                             ..onTap = () {
                                  //                               // navigate to desired screen
                                  //                             })
                                  //                   : TextSpan(
                                  //                       text: '',
                                  //                     )
                                  //             ]),
                                  //       )
                                  //     : SizedBox(),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                          icon: const Icon(
                            Icons.description,
                            size: 18,
                            color: Color.fromRGBO(0, 0, 0, 0.8),
                          ),
                          onPressed: () async {
                            _showDialog(index);
                          }),
                    ],
                  ),
                ),
                allQuestionsData[index]["question_type"] == "text"
                    ? InkWell(
                        onTap: () {
                          Navigator.of(context).pop();
                          databaseReference
                              .child("hysweb")
                              .child("qANDa")
                              .child("jump_to_listview_index")
                              .update({"$_currentUserId": index});
                          databaseReference
                              .child("hysweb")
                              .child("app_bar_navigation")
                              .child(FirebaseAuth.instance.currentUser!.uid)
                              .update({"$_currentUserId": 1});
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width - 30,
                          margin: EdgeInsets.fromLTRB(10, 10, 0, 2),
                          child: ReadMoreText(
                            allQuestionsData[index]["question"],
                            textAlign: TextAlign.left,
                            trimLines: 4,
                            colorClickableText: Color(0xff0962ff),
                            trimMode: TrimMode.Line,
                            trimCollapsedText: 'read more',
                            trimExpandedText: 'Show less',
                            style: TextStyle(
                              fontFamily: 'Nunito Sans',
                              fontSize: 13,
                              color: Color.fromRGBO(0, 0, 0, 0.8),
                              fontWeight: FontWeight.w400,
                            ),
                            lessStyle: TextStyle(
                              fontFamily: 'Nunito Sans',
                              fontSize: 12,
                              color: Color(0xff0962ff),
                              fontWeight: FontWeight.w700,
                            ),
                            moreStyle: TextStyle(
                              fontFamily: 'Nunito Sans',
                              fontSize: 12,
                              color: Color(0xff0962ff),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      )
                    : Container(
                        margin: EdgeInsets.fromLTRB(1, 10, 1, 10),
                        child: TeXView(
                          child: TeXViewColumn(children: [
                            TeXViewDocument(allQuestionsData[index]["question"],
                                style: TeXViewStyle(
                                  fontStyle: TeXViewFontStyle(
                                      fontSize: 8,
                                      sizeUnit: TeXViewSizeUnit.Pt),
                                  padding: TeXViewPadding.all(10),
                                )),
                          ]),
                          style: TeXViewStyle(
                            elevation: 10,
                            backgroundColor: Color.fromRGBO(242, 246, 248, 1),
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  _questionFeedTextForAnswers(int index, List<int> ansIndexList) {
    DateTime tempDate = DateTime.parse(
        allQuestionsData[index]["compare_date"].toString().substring(0, 8));
    String current_date = DateFormat.yMMMMd('en_US').format(tempDate);
    return ansIndexList.isNotEmpty
        ? Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: () {
                  Navigator.of(context).pop();
                  databaseReference
                      .child("hysweb")
                      .child("qANDa")
                      .child("jump_to_listview_index")
                      .update({"$_currentUserId": index});
                  databaseReference
                      .child("hysweb")
                      .child("app_bar_navigation")
                      .child(FirebaseAuth.instance.currentUser!.uid)
                      .update({"$_currentUserId": 1});
                },
                child: Container(
                  width: 500,
                  padding: EdgeInsets.all(10),
                  margin: EdgeInsets.only(top: 20),
                  decoration: BoxDecoration(
                      color: Color.fromRGBO(242, 246, 248, 1),
                      borderRadius: BorderRadius.circular(10)),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: (15.0), right: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              child: Row(
                                children: [
                                  InkWell(
                                    child: CircleAvatar(
                                      child: ClipOval(
                                        child: Container(
                                          child: CachedNetworkImage(
                                            imageUrl: allQuestionsData[index]
                                                ["profilepic"],
                                            width: 40,
                                            height: 40,
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) =>
                                                Container(
                                              width: 40,
                                              height: 40,
                                              color: Colors.white,
                                              child: Image.network(
                                                "https://firebasestorage.googleapis.com/v0/b/hys-pro-41c66.appspot.com/o/assets%2Floadingimg.gif?alt=media&token=4ca910f2-c584-4b3a-bbcb-2f1c01d93f67",
                                              ),
                                            ),
                                            errorWidget:
                                                (context, url, error) =>
                                                    Icon(Icons.error),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Container(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        RichText(
                                          text: TextSpan(
                                              text: allQuestionsData[index][
                                                          "is_identity_visible"] ==
                                                      "true"
                                                  ? "${allQuestionsData[index]["first_name"]} ${allQuestionsData[index]["last_name"]}, "
                                                  : "HyS User",
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: dark,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              children: <TextSpan>[
                                                TextSpan(
                                                  text: allQuestionsData[index][
                                                              "is_identity_visible"] ==
                                                          "true"
                                                      ? allQuestionsData[index]
                                                          ["city"]
                                                      : "",
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Color.fromRGBO(
                                                        0, 0, 0, 0.5),
                                                    fontWeight:
                                                        FontWeight.normal,
                                                  ),
                                                )
                                              ]),
                                        ),
                                        allQuestionsData[index]
                                                    ["is_identity_visible"] ==
                                                "true"
                                            ? Text(
                                                allQuestionsData[index]
                                                        ["school_name"] +
                                                    ", " +
                                                    "Grade " +
                                                    (allQuestionsData[index]
                                                            ["grade"])
                                                        .toString(),
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Color.fromRGBO(
                                                      0, 0, 0, 0.5),
                                                  fontWeight: FontWeight.normal,
                                                ),
                                              )
                                            : SizedBox(),
                                        Text(
                                          "Posted on " + "$current_date",
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.normal,
                                            color: Color.fromRGBO(0, 0, 0, 0.5),
                                          ),
                                        ),
                                        // ((tagedusername.length > 0) &&
                                        //         (tagedusername[0] != "") &&
                                        //         (tagedusername != null))
                                        //     ? RichText(
                                        //         text: TextSpan(
                                        //             text: ' ${tagedusername[0]}',
                                        //             style: TextStyle(
                                        //                 fontFamily: 'Nunito Sans',
                                        //                 fontSize: 11,
                                        //                 fontWeight: FontWeight.normal,
                                        //                 color: Color(0xff0C2551)),
                                        //             children: <TextSpan>[
                                        //               (tagedusername.length > 1)
                                        //                   ? TextSpan(
                                        //                       text: ' &',
                                        //                       style: TextStyle(
                                        //                           fontFamily:
                                        //                               'Nunito Sans',
                                        //                           fontSize: 11,
                                        //                           fontWeight:
                                        //                               FontWeight.normal,
                                        //                           color:
                                        //                               Color(0xff0C2551)),
                                        //                       recognizer:
                                        //                           TapGestureRecognizer()
                                        //                             ..onTap = () {
                                        //                               // navigate to desired screen
                                        //                             })
                                        //                   : TextSpan(
                                        //                       text: '',
                                        //                     ),
                                        //               (tagedusername.length > 1)
                                        //                   ? TextSpan(
                                        //                       text:
                                        //                           ' ${tagedusername.length - 1} more',
                                        //                       style: TextStyle(
                                        //                           fontFamily:
                                        //                               'Nunito Sans',
                                        //                           fontSize: 11,
                                        //                           fontWeight:
                                        //                               FontWeight.normal,
                                        //                           color:
                                        //                               Color(0xff0C2551)),
                                        //                       recognizer:
                                        //                           TapGestureRecognizer()
                                        //                             ..onTap = () {
                                        //                               // navigate to desired screen
                                        //                             })
                                        //                   : TextSpan(
                                        //                       text: '',
                                        //                     )
                                        //             ]),
                                        //       )
                                        //     : SizedBox(),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                                icon: const Icon(
                                  Icons.description,
                                  size: 18,
                                  color: Color.fromRGBO(0, 0, 0, 0.8),
                                ),
                                onPressed: () async {
                                  _showDialog(index);
                                }),
                          ],
                        ),
                      ),
                      allQuestionsData[index]["question_type"] == "text"
                          ? InkWell(
                              onTap: () {
                                Navigator.of(context).pop();
                                databaseReference
                                    .child("hysweb")
                                    .child("qANDa")
                                    .child("jump_to_listview_index")
                                    .update({"$_currentUserId": index});
                                databaseReference
                                    .child("hysweb")
                                    .child("app_bar_navigation")
                                    .child(
                                        FirebaseAuth.instance.currentUser!.uid)
                                    .update({"$_currentUserId": 1});
                              },
                              child: Container(
                                width: MediaQuery.of(context).size.width - 30,
                                margin: EdgeInsets.fromLTRB(10, 10, 0, 2),
                                child: ReadMoreText(
                                  allQuestionsData[index]["question"],
                                  textAlign: TextAlign.left,
                                  trimLines: 4,
                                  colorClickableText: Color(0xff0962ff),
                                  trimMode: TrimMode.Line,
                                  trimCollapsedText: 'read more',
                                  trimExpandedText: 'Show less',
                                  style: TextStyle(
                                    fontFamily: 'Nunito Sans',
                                    fontSize: 13,
                                    color: Color.fromRGBO(0, 0, 0, 0.8),
                                    fontWeight: FontWeight.w400,
                                  ),
                                  lessStyle: TextStyle(
                                    fontFamily: 'Nunito Sans',
                                    fontSize: 12,
                                    color: Color(0xff0962ff),
                                    fontWeight: FontWeight.w700,
                                  ),
                                  moreStyle: TextStyle(
                                    fontFamily: 'Nunito Sans',
                                    fontSize: 12,
                                    color: Color(0xff0962ff),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            )
                          : Container(
                              margin: EdgeInsets.fromLTRB(1, 10, 1, 10),
                              child: TeXView(
                                child: TeXViewColumn(children: [
                                  TeXViewDocument(
                                      allQuestionsData[index]["question"],
                                      style: TeXViewStyle(
                                        fontStyle: TeXViewFontStyle(
                                            fontSize: 8,
                                            sizeUnit: TeXViewSizeUnit.Pt),
                                        padding: TeXViewPadding.all(10),
                                      )),
                                ]),
                                style: TeXViewStyle(
                                  elevation: 10,
                                  backgroundColor:
                                      Color.fromRGBO(242, 246, 248, 1),
                                ),
                              ),
                            ),
                    ],
                  ),
                ),
              ),
              ((ansIndexList.isNotEmpty))
                  ? _answerView(index, ansIndexList)
                  : SizedBox()
            ],
          )
        : SizedBox();
  }

  _answerView(int qIndex, List<int> ansIndexList) {
    return Container(
      margin: EdgeInsets.only(left: 30),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: ansIndexList.length,
        itemBuilder: (context, index) {
          DateTime tempDate = DateTime.parse(allAnswerData[ansIndexList[index]]
                  ["compare_date"]
              .toString()
              .substring(0, 8));
          String current_date = DateFormat.yMMMMd('en_US').format(tempDate);
          return InkWell(
            onTap: () {
              Navigator.of(context).pop();
              databaseReference
                  .child("hysweb")
                  .child("qANDa")
                  .child("jump_to_listview_index")
                  .update({"$_currentUserId": qIndex});
              databaseReference
                  .child("hysweb")
                  .child("app_bar_navigation")
                  .child(FirebaseAuth.instance.currentUser!.uid)
                  .update({"$_currentUserId": 1});
            },
            child: Container(
              margin: EdgeInsets.only(right: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 35,
                    width: 35,
                    margin: EdgeInsets.all(10),
                    child: CircleAvatar(
                      child: ClipOval(
                        child: Container(
                          child: Image.network(
                            allAnswerData[ansIndexList[index]]["profilepic"]
                                .toString(),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 10),
                      Container(
                        width: 300,
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  allAnswerData[ansIndexList[index]]
                                              ["first_name"]
                                          .toString() +
                                      " " +
                                      allAnswerData[ansIndexList[index]]
                                              ["last_name"]
                                          .toString(),
                                  style: TextStyle(
                                      color: Color(0xFF4D4D4D),
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w700),
                                ),
                                InkWell(
                                  onTap: () {},
                                  child: Container(
                                    child: Icon(
                                      Icons.more_horiz_outlined,
                                      size: 17,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  allAnswerData[ansIndexList[index]]
                                              ["school_name"]
                                          .toString() +
                                      " | Grade " +
                                      allAnswerData[ansIndexList[index]]
                                              ["grade"]
                                          .toString(),
                                  style: TextStyle(
                                      color: Colors.black54,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w400),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  "Answered on " + "$current_date",
                                  style: TextStyle(
                                      color: Colors.black54,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w400),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 8,
                            ),
                            allAnswerData[ansIndexList[index]]["answer_type"]
                                        .toString() ==
                                    "text"
                                ? InkWell(
                                    child: ReadMoreText(
                                      allAnswerData[ansIndexList[index]]
                                              ["answer"]
                                          .toString(),
                                      trimLines: 2,
                                      colorClickableText: Color(0xff0962ff),
                                      trimMode: TrimMode.Line,
                                      trimCollapsedText: 'read more',
                                      trimExpandedText: 'Show less',
                                      style: const TextStyle(
                                          color: Color.fromRGBO(0, 0, 0, 0.8),
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500),
                                      lessStyle: const TextStyle(
                                          color: Color.fromRGBO(0, 0, 0, 0.8),
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500),
                                      moreStyle: const TextStyle(
                                          color: Color.fromRGBO(0, 0, 0, 0.8),
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  )
                                : allAnswerData[ansIndexList[index]]
                                                ["answer_type"]
                                            .toString() ==
                                        "ocr"
                                    ? InkWell(
                                        onTap: () {},
                                        child: Container(
                                          padding: EdgeInsets.all(5),
                                          child: SizedBox(
                                            height: 300,
                                            child: TeXView(
                                              loadingWidgetBuilder: (context) {
                                                return Container(
                                                  width: 280,
                                                  child: PlaceholderLines(
                                                    count: 2,
                                                    animate: true,
                                                    color: active,
                                                  ),
                                                );
                                              },
                                              child: TeXViewColumn(children: [
                                                TeXViewInkWell(
                                                  id: "$index",
                                                  child: TeXViewDocument(
                                                      allAnswerData[
                                                          ansIndexList[
                                                              index]]["answer"],
                                                      style: TeXViewStyle(
                                                        fontStyle: TeXViewFontStyle(
                                                            fontFamily:
                                                                'Nunito Sans',
                                                            fontWeight:
                                                                TeXViewFontWeight
                                                                    .w400,
                                                            fontSize: 10,
                                                            sizeUnit:
                                                                TeXViewSizeUnit
                                                                    .Pt),
                                                        padding:
                                                            TeXViewPadding.all(
                                                                5),
                                                      )),
                                                ),
                                              ]),
                                              style: TeXViewStyle(
                                                  backgroundColor:
                                                      Colors.white),
                                            ),
                                          ),
                                        ),
                                      )
                                    : InkWell(
                                        onTap: () {},
                                        child: Container(
                                          margin: EdgeInsets.all(5),
                                          child: Image.network(
                                              allAnswerData[ansIndexList[index]]
                                                      ["answer"]
                                                  .toString(),
                                              height: 300,
                                              fit: BoxFit.fill),
                                        ),
                                      )
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showDialog(int index) {
    AlertDialog alertDialog = AlertDialog(
      backgroundColor: Color.fromRGBO(88, 165, 196, 1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "GET ATTATCHED \nREFERENCE",
            style: TextStyle(
              fontFamily: 'Nunito Sans',
              fontSize: 20,
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      content: Container(
        height: 220,
        child: Column(
          children: [
            SizedBox(
              height: 15,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () {
                        setState(() {
                          if (allQuestionsData[index]["note_reference"] != "") {
                            _launchInBrowser(
                                allQuestionsData[index]["note_reference"]);
                          }
                        });
                      },
                      icon: Tab(
                          child: Icon(Icons.picture_as_pdf,
                              color: (allQuestionsData[index]
                                          ["note_reference"] !=
                                      "")
                                  ? Colors.redAccent
                                  : Color(0xFFFFFFFF),
                              size: 40)),
                    ),
                    SizedBox(
                      height: 7,
                    ),
                    Text(
                      "Notes",
                      style: TextStyle(
                        fontFamily: 'Nunito Sans',
                        fontSize: 12,
                        color: (allQuestionsData[index]["note_reference"] != "")
                            ? Colors.redAccent
                            : Color(0xFFFFFFFF),
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    )
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () {
                        setState(() {
                          if (allQuestionsData[index]["video_reference"] !=
                              "") {
                            _launchInBrowser(
                                allQuestionsData[index]["video_reference"]);
                          }
                        });
                      },
                      icon: Tab(
                          child: Icon(Icons.video_label,
                              color: (allQuestionsData[index]
                                          ["video_reference"] !=
                                      "")
                                  ? Colors.redAccent
                                  : Color(0xFFFFFFFF),
                              size: 40)),
                    ),
                    SizedBox(
                      height: 7,
                    ),
                    Text(
                      "Video",
                      style: TextStyle(
                        fontFamily: 'Nunito Sans',
                        fontSize: 12,
                        color:
                            (allQuestionsData[index]["video_reference"] != "")
                                ? Colors.redAccent
                                : Color(0xFFFFFFFF),
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    )
                  ],
                )
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () {
                        setState(() {
                          if (allQuestionsData[index]["audio_reference"] !=
                              "") {
                            _launchInBrowser(
                                allQuestionsData[index]["audio_reference"]);
                          }
                        });
                      },
                      icon: Tab(
                          child: Icon(Icons.audiotrack,
                              color: (allQuestionsData[index]
                                          ["audio_reference"] !=
                                      "")
                                  ? Colors.redAccent
                                  : Color(0xFFFFFFFF),
                              size: 40)),
                    ),
                    SizedBox(
                      height: 7,
                    ),
                    Text(
                      "Audio",
                      style: TextStyle(
                        fontFamily: 'Nunito Sans',
                        fontSize: 12,
                        color:
                            (allQuestionsData[index]["audio_reference"] != "")
                                ? Colors.redAccent
                                : Color(0xFFFFFFFF),
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    )
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            content: ListTile(
                              title: Text("Reference"),
                              subtitle: Text(
                                  "${allQuestionsData[index]["text_reference"]}"),
                            ),
                            actions: <Widget>[
                              FlatButton(
                                child: Text('Ok'),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                            ],
                          ),
                        );
                      },
                      icon: Tab(
                          child: Icon(Icons.text_fields,
                              color: (allQuestionsData[index]
                                          ["text_reference"] !=
                                      "")
                                  ? Colors.redAccent
                                  : Color(0xFFFFFFFF),
                              size: 40)),
                    ),
                    SizedBox(
                      height: 7,
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            content: ListTile(
                              title: Text("Reference"),
                              subtitle: Text(
                                  "${allQuestionsData[index]["text_reference"]}"),
                            ),
                            actions: <Widget>[
                              FlatButton(
                                child: Text('Ok'),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                            ],
                          ),
                        );
                      },
                      child: Text(
                        "Book\nReference",
                        style: TextStyle(
                          fontFamily: 'Nunito Sans',
                          fontSize: 12,
                          color:
                              (allQuestionsData[index]["text_reference"] != "")
                                  ? Colors.redAccent
                                  : Color(0xFFFFFFFF),
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    );
    showDialog(context: context, builder: (_) => alertDialog);
  }

  Future<void> _launchInBrowser(String url) async {
    if (await canLaunch(url)) {
      await launch(
        url,
        forceSafariVC: false,
        forceWebView: false,
      );
    } else {
      throw 'Could not launch $url';
    }
  }

  void _showExamlikelihoodAndToughnessDialog(int index) {
    showDialog(
        context: context,
        barrierColor: Colors.grey.withOpacity(0.2),
        builder: (_) => StatefulBuilder(builder: (context, setState) {
              return AlertDialog(
                backgroundColor: Color(0xFFFFFFFF),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0)),
                content: Container(
                  height: 220,
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 15,
                      ),
                      Text(
                        "Examlikelihood",
                        style: TextStyle(
                          fontFamily: 'Nunito Sans',
                          fontSize: 20,
                          color: Color(0xFF0C0D5A),
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Container(
                        width: 250,
                        height: 35,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(color: Colors.black12)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            InkWell(
                              onTap: () async {
                                if ((questionexamlikelyhoodLocalDB!.get(
                                        allQuestionsData[index]
                                            ["question_id"]) ==
                                    "low")) {
                                  questionexamlikelyhoodLocalDB!.delete(
                                      allQuestionsData[index]["question_id"]);
                                  questionexamlikelyhoodLocalDB!.put(
                                      allQuestionsData[index]["question_id"],
                                      "high");

                                  _delete_questions_examlikelyhood_details(
                                      allQuestionsData[index]["user_id"],
                                      allQuestionsData[index]["question_id"]);
                                  _add_questions_examlikelyhood_details(
                                      allQuestionsData[index]["user_id"],
                                      allQuestionsData[index]["question_id"],
                                      "high");
                                } else if ((questionexamlikelyhoodLocalDB!.get(
                                        allQuestionsData[index]
                                            ["question_id"]) ==
                                    "moderate")) {
                                  questionexamlikelyhoodLocalDB!.delete(
                                      allQuestionsData[index]["question_id"]);
                                  questionexamlikelyhoodLocalDB!.put(
                                      allQuestionsData[index]["question_id"],
                                      "high");
                                  _delete_questions_examlikelyhood_details(
                                      allQuestionsData[index]["user_id"],
                                      allQuestionsData[index]["question_id"]);
                                  _add_questions_examlikelyhood_details(
                                      allQuestionsData[index]["user_id"],
                                      allQuestionsData[index]["question_id"],
                                      "high");
                                } else if ((questionexamlikelyhoodLocalDB!.get(
                                        allQuestionsData[index]
                                            ["question_id"]) ==
                                    "high")) {
                                  questionexamlikelyhoodLocalDB!.delete(
                                      allQuestionsData[index]["question_id"]);
                                  setState(() {
                                    _examlikelyhoodcount[index] =
                                        _examlikelyhoodcount[index] - 1;
                                  });
                                  _update_count(
                                      allQuestionsData[index]["user_id"],
                                      allQuestionsData[index]["question_id"],
                                      'examlikelyhood',
                                      "-",
                                      index);
                                  _delete_questions_examlikelyhood_details(
                                      allQuestionsData[index]["user_id"],
                                      allQuestionsData[index]["question_id"]);
                                } else {
                                  setState(() {
                                    _examlikelyhoodcount[index] =
                                        _examlikelyhoodcount[index] + 1;
                                  });
                                  questionexamlikelyhoodLocalDB!.put(
                                      allQuestionsData[index]["question_id"],
                                      "high");
                                  _update_count(
                                      allQuestionsData[index]["user_id"],
                                      allQuestionsData[index]["question_id"],
                                      'examlikelyhood',
                                      "+",
                                      index);
                                  _add_questions_examlikelyhood_details(
                                      allQuestionsData[index]["user_id"],
                                      allQuestionsData[index]["question_id"],
                                      "high");
                                }
                                Navigator.of(context).pop();
                              },
                              child: Container(
                                padding: EdgeInsets.all(5),
                                child: Center(
                                  child: Text(
                                    "High",
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: (questionexamlikelyhoodLocalDB!
                                                    .get(allQuestionsData[index]
                                                        ["question_id"]) ==
                                                "high")
                                            ? Color(0xff0962ff)
                                            : Color(0xff0C2551)),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () async {
                                if ((questionexamlikelyhoodLocalDB!.get(
                                        allQuestionsData[index]
                                            ["question_id"]) ==
                                    "low")) {
                                  questionexamlikelyhoodLocalDB!.delete(
                                      allQuestionsData[index]["question_id"]);
                                  questionexamlikelyhoodLocalDB!.put(
                                      allQuestionsData[index]["question_id"],
                                      "moderate");
                                  _delete_questions_examlikelyhood_details(
                                      allQuestionsData[index]["user_id"],
                                      allQuestionsData[index]["question_id"]);
                                  _add_questions_examlikelyhood_details(
                                      allQuestionsData[index]["user_id"],
                                      allQuestionsData[index]["question_id"],
                                      "moderate");
                                } else if ((questionexamlikelyhoodLocalDB!.get(
                                        allQuestionsData[index]
                                            ["question_id"]) ==
                                    "high")) {
                                  questionexamlikelyhoodLocalDB!.delete(
                                      allQuestionsData[index]["question_id"]);
                                  questionexamlikelyhoodLocalDB!.put(
                                      allQuestionsData[index]["question_id"],
                                      "moderate");
                                  _delete_questions_examlikelyhood_details(
                                      allQuestionsData[index]["user_id"],
                                      allQuestionsData[index]["question_id"]);
                                  _add_questions_examlikelyhood_details(
                                      allQuestionsData[index]["user_id"],
                                      allQuestionsData[index]["question_id"],
                                      "moderate");
                                } else if ((questionexamlikelyhoodLocalDB!.get(
                                        allQuestionsData[index]
                                            ["question_id"]) ==
                                    "moderate")) {
                                  questionexamlikelyhoodLocalDB!.delete(
                                      allQuestionsData[index]["question_id"]);
                                  setState(() {
                                    _examlikelyhoodcount[index] =
                                        _examlikelyhoodcount[index] - 1;
                                  });
                                  _update_count(
                                      allQuestionsData[index]["user_id"],
                                      allQuestionsData[index]["question_id"],
                                      'examlikelyhood',
                                      "-",
                                      index);
                                  _delete_questions_examlikelyhood_details(
                                      allQuestionsData[index]["user_id"],
                                      allQuestionsData[index]["question_id"]);
                                } else {
                                  setState(() {
                                    _examlikelyhoodcount[index] =
                                        _examlikelyhoodcount[index] + 1;
                                  });
                                  questionexamlikelyhoodLocalDB!.put(
                                      allQuestionsData[index]["question_id"],
                                      "moderate");
                                  _update_count(
                                      allQuestionsData[index]["user_id"],
                                      allQuestionsData[index]["question_id"],
                                      'examlikelyhood',
                                      "+",
                                      index);
                                  _add_questions_examlikelyhood_details(
                                      allQuestionsData[index]["user_id"],
                                      allQuestionsData[index]["question_id"],
                                      "moderate");
                                }
                                Navigator.of(context).pop();
                              },
                              child: Container(
                                padding: EdgeInsets.all(5),
                                child: Center(
                                  child: Text(
                                    "Moderate",
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: (questionexamlikelyhoodLocalDB!
                                                    .get(allQuestionsData[index]
                                                        ["question_id"]) ==
                                                "moderate")
                                            ? Color(0xff0962ff)
                                            : Color(0xff0C2551)),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () async {
                                if ((questionexamlikelyhoodLocalDB!.get(
                                        allQuestionsData[index]
                                            ["question_id"]) ==
                                    "high")) {
                                  questionexamlikelyhoodLocalDB!.delete(
                                      allQuestionsData[index]["question_id"]);
                                  questionexamlikelyhoodLocalDB!.put(
                                      allQuestionsData[index]["question_id"],
                                      "low");
                                  _delete_questions_examlikelyhood_details(
                                      allQuestionsData[index]["user_id"],
                                      allQuestionsData[index]["question_id"]);
                                  _add_questions_examlikelyhood_details(
                                      allQuestionsData[index]["user_id"],
                                      allQuestionsData[index]["question_id"],
                                      "low");
                                } else if ((questionexamlikelyhoodLocalDB!.get(
                                        allQuestionsData[index]
                                            ["question_id"]) ==
                                    "moderate")) {
                                  questionexamlikelyhoodLocalDB!.delete(
                                      allQuestionsData[index]["question_id"]);
                                  questionexamlikelyhoodLocalDB!.put(
                                      allQuestionsData[index]["question_id"],
                                      "low");
                                  _delete_questions_examlikelyhood_details(
                                      allQuestionsData[index]["user_id"],
                                      allQuestionsData[index]["question_id"]);
                                  _add_questions_examlikelyhood_details(
                                      allQuestionsData[index]["user_id"],
                                      allQuestionsData[index]["question_id"],
                                      "low");
                                } else if ((questionexamlikelyhoodLocalDB!.get(
                                        allQuestionsData[index]
                                            ["question_id"]) ==
                                    "low")) {
                                  questionexamlikelyhoodLocalDB!.delete(
                                      allQuestionsData[index]["question_id"]);
                                  setState(() {
                                    _examlikelyhoodcount[index] =
                                        _examlikelyhoodcount[index] - 1;
                                  });
                                  _update_count(
                                      allQuestionsData[index]["user_id"],
                                      allQuestionsData[index]["question_id"],
                                      'examlikelyhood',
                                      "-",
                                      index);
                                  _delete_questions_examlikelyhood_details(
                                      allQuestionsData[index]["user_id"],
                                      allQuestionsData[index]["question_id"]);
                                } else {
                                  setState(() {
                                    _examlikelyhoodcount[index] =
                                        _examlikelyhoodcount[index] + 1;
                                  });
                                  questionexamlikelyhoodLocalDB!.put(
                                      allQuestionsData[index]["question_id"],
                                      "low");
                                  _update_count(
                                      allQuestionsData[index]["user_id"],
                                      allQuestionsData[index]["question_id"],
                                      'examlikelyhood',
                                      "+",
                                      index);
                                  _add_questions_examlikelyhood_details(
                                      allQuestionsData[index]["user_id"],
                                      allQuestionsData[index]["question_id"],
                                      "low");
                                }
                                Navigator.of(context).pop();
                              },
                              child: Container(
                                padding: EdgeInsets.all(5),
                                child: Center(
                                  child: Text(
                                    "Low",
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: (questionexamlikelyhoodLocalDB!
                                                    .get(allQuestionsData[index]
                                                        ["question_id"]) ==
                                                "low")
                                            ? Color(0xff0962ff)
                                            : Color(0xff0C2551)),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 25,
                      ),
                      Text(
                        "Toughness",
                        style: TextStyle(
                          fontFamily: 'Nunito Sans',
                          fontSize: 20,
                          color: Color(0xFF0C0D5A),
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Container(
                        width: 250,
                        height: 35,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(color: Colors.black12)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            InkWell(
                              onTap: () async {
                                if ((questiontoughnessLocalDB!.get(
                                        allQuestionsData[index]
                                            ["question_id"]) ==
                                    "low")) {
                                  questiontoughnessLocalDB!.delete(
                                      allQuestionsData[index]["question_id"]);
                                  questiontoughnessLocalDB!.put(
                                      allQuestionsData[index]["question_id"],
                                      "high");
                                  _delete_questions_toughness_details(
                                      allQuestionsData[index]["user_id"],
                                      allQuestionsData[index]["question_id"]);
                                  _add_questions_toughness_details(
                                      allQuestionsData[index]["user_id"],
                                      allQuestionsData[index]["question_id"],
                                      "high");
                                } else if ((questiontoughnessLocalDB!.get(
                                        allQuestionsData[index]
                                            ["question_id"]) ==
                                    "medium")) {
                                  questiontoughnessLocalDB!.delete(
                                      allQuestionsData[index]["question_id"]);
                                  questiontoughnessLocalDB!.put(
                                      allQuestionsData[index]["question_id"],
                                      "high");
                                  _delete_questions_toughness_details(
                                      allQuestionsData[index]["user_id"],
                                      allQuestionsData[index]["question_id"]);
                                  _add_questions_toughness_details(
                                      allQuestionsData[index]["user_id"],
                                      allQuestionsData[index]["question_id"],
                                      "high");
                                } else if ((questiontoughnessLocalDB!.get(
                                        allQuestionsData[index]
                                            ["question_id"]) ==
                                    "high")) {
                                  questiontoughnessLocalDB!.delete(
                                      allQuestionsData[index]["question_id"]);
                                  setState(() {
                                    _examlikelyhoodcount[index] =
                                        _examlikelyhoodcount[index] - 1;
                                  });
                                  _delete_questions_toughness_details(
                                      allQuestionsData[index]["user_id"],
                                      allQuestionsData[index]["question_id"]);
                                  _update_count(
                                      allQuestionsData[index]["user_id"],
                                      allQuestionsData[index]["question_id"],
                                      'toughness',
                                      "-",
                                      index);
                                } else {
                                  setState(() {
                                    _examlikelyhoodcount[index] =
                                        _examlikelyhoodcount[index] + 1;
                                  });
                                  questiontoughnessLocalDB!.put(
                                      allQuestionsData[index]["question_id"],
                                      "high");
                                  _update_count(
                                      allQuestionsData[index]["user_id"],
                                      allQuestionsData[index]["question_id"],
                                      'toughness',
                                      "+",
                                      index);
                                  _add_questions_toughness_details(
                                      allQuestionsData[index]["user_id"],
                                      allQuestionsData[index]["question_id"],
                                      "high");
                                }
                                Navigator.of(context).pop();
                              },
                              child: Container(
                                padding: const EdgeInsets.all(5),
                                child: Center(
                                  child: Text(
                                    "High",
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: (questiontoughnessLocalDB!.get(
                                                    allQuestionsData[index]
                                                        ["question_id"]) ==
                                                "high")
                                            ? Color(0xff0962ff)
                                            : Color(0xff0C2551)),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () async {
                                if ((questiontoughnessLocalDB!.get(
                                        allQuestionsData[index]
                                            ["question_id"]) ==
                                    "low")) {
                                  questiontoughnessLocalDB!.delete(
                                      allQuestionsData[index]["question_id"]);
                                  questiontoughnessLocalDB!.put(
                                      allQuestionsData[index]["question_id"],
                                      "medium");
                                  _delete_questions_toughness_details(
                                      allQuestionsData[index]["user_id"],
                                      allQuestionsData[index]["question_id"]);
                                  _add_questions_toughness_details(
                                      allQuestionsData[index]["user_id"],
                                      allQuestionsData[index]["question_id"],
                                      "medium");
                                } else if ((questiontoughnessLocalDB!.get(
                                        allQuestionsData[index]
                                            ["question_id"]) ==
                                    "high")) {
                                  questiontoughnessLocalDB!.delete(
                                      allQuestionsData[index]["question_id"]);
                                  questiontoughnessLocalDB!.put(
                                      allQuestionsData[index]["question_id"],
                                      "medium");
                                  _delete_questions_toughness_details(
                                      allQuestionsData[index]["user_id"],
                                      allQuestionsData[index]["question_id"]);
                                  _add_questions_toughness_details(
                                      allQuestionsData[index]["user_id"],
                                      allQuestionsData[index]["question_id"],
                                      "medium");
                                } else if ((questiontoughnessLocalDB!.get(
                                        allQuestionsData[index]
                                            ["question_id"]) ==
                                    "medium")) {
                                  questiontoughnessLocalDB!.delete(
                                      allQuestionsData[index]["question_id"]);
                                  setState(() {
                                    _examlikelyhoodcount[index] =
                                        _examlikelyhoodcount[index] - 1;
                                  });
                                  _delete_questions_toughness_details(
                                      allQuestionsData[index]["user_id"],
                                      allQuestionsData[index]["question_id"]);
                                  _update_count(
                                      allQuestionsData[index]["user_id"],
                                      allQuestionsData[index]["question_id"],
                                      'toughness',
                                      "-",
                                      index);
                                } else {
                                  setState(() {
                                    _examlikelyhoodcount[index] =
                                        _examlikelyhoodcount[index] + 1;
                                  });
                                  questiontoughnessLocalDB!.put(
                                      allQuestionsData[index]["question_id"],
                                      "medium");
                                  _update_count(
                                      allQuestionsData[index]["user_id"],
                                      allQuestionsData[index]["question_id"],
                                      'toughness',
                                      "+",
                                      index);
                                  _add_questions_toughness_details(
                                      allQuestionsData[index]["user_id"],
                                      allQuestionsData[index]["question_id"],
                                      "medium");
                                }
                                Navigator.of(context).pop();
                              },
                              child: Container(
                                padding: EdgeInsets.all(5),
                                child: Center(
                                  child: Text(
                                    "Meduim",
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: (questiontoughnessLocalDB!.get(
                                                    allQuestionsData[index]
                                                        ["question_id"]) ==
                                                "medium")
                                            ? Color(0xff0962ff)
                                            : Color(0xff0C2551)),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () async {
                                if ((questiontoughnessLocalDB!.get(
                                        allQuestionsData[index]
                                            ["question_id"]) ==
                                    "high")) {
                                  questiontoughnessLocalDB!.delete(
                                      allQuestionsData[index]["question_id"]);
                                  questiontoughnessLocalDB!.put(
                                      allQuestionsData[index]["question_id"],
                                      "low");
                                  _delete_questions_toughness_details(
                                      allQuestionsData[index]["user_id"],
                                      allQuestionsData[index]["question_id"]);
                                  _add_questions_toughness_details(
                                      allQuestionsData[index]["user_id"],
                                      allQuestionsData[index]["question_id"],
                                      "low");
                                } else if ((questiontoughnessLocalDB!.get(
                                        allQuestionsData[index]
                                            ["question_id"]) ==
                                    "medium")) {
                                  questiontoughnessLocalDB!.delete(
                                      allQuestionsData[index]["question_id"]);
                                  questiontoughnessLocalDB!.put(
                                      allQuestionsData[index]["question_id"],
                                      "low");
                                  _delete_questions_toughness_details(
                                      allQuestionsData[index]["user_id"],
                                      allQuestionsData[index]["question_id"]);
                                  _add_questions_toughness_details(
                                      allQuestionsData[index]["user_id"],
                                      allQuestionsData[index]["question_id"],
                                      "low");
                                } else if ((questiontoughnessLocalDB!.get(
                                        allQuestionsData[index]
                                            ["question_id"]) ==
                                    "low")) {
                                  questiontoughnessLocalDB!.delete(
                                      allQuestionsData[index]["question_id"]);
                                  setState(() {
                                    _examlikelyhoodcount[index] =
                                        _examlikelyhoodcount[index] - 1;
                                  });
                                  _delete_questions_toughness_details(
                                      allQuestionsData[index]["user_id"],
                                      allQuestionsData[index]["question_id"]);
                                  _update_count(
                                      allQuestionsData[index]["user_id"],
                                      allQuestionsData[index]["question_id"],
                                      'toughness',
                                      "-",
                                      index);
                                } else {
                                  setState(() {
                                    _examlikelyhoodcount[index] =
                                        _examlikelyhoodcount[index] + 1;
                                  });
                                  questiontoughnessLocalDB!.put(
                                      allQuestionsData[index]["question_id"],
                                      "low");
                                  _update_count(
                                      allQuestionsData[index]["user_id"],
                                      allQuestionsData[index]["question_id"],
                                      'toughness',
                                      "+",
                                      index);
                                  _add_questions_toughness_details(
                                      allQuestionsData[index]["user_id"],
                                      allQuestionsData[index]["question_id"],
                                      "low");
                                }
                                Navigator.of(context).pop();
                              },
                              child: Container(
                                padding: EdgeInsets.all(5),
                                child: Center(
                                  child: Text(
                                    "Low",
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: (questiontoughnessLocalDB!.get(
                                                    allQuestionsData[index]
                                                        ["question_id"]) ==
                                                "low")
                                            ? Color(0xff0962ff)
                                            : Color(0xff0C2551)),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }));
  }

  Future<void> _add_questions_examlikelyhood_details(
      String user_id, String question_id, String examlikelyhood_level) async {
    final http.Response response = await http.post(
      Uri.parse(
          'https://hys-api.herokuapp.com/web_add_questions_examlikelyhood_details'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        "Access-Control_Allow_Origin": "*"
      },
      body: jsonEncode(<String, dynamic>{
        "user_id": user_id,
        "question_id": question_id,
        "examlikelyhood_level": examlikelyhood_level
      }),
    );
    print(response.statusCode);
  }

  Future<void> _delete_questions_examlikelyhood_details(
      String user_id, String question_id) async {
    final http.Response response = await http.delete(
      Uri.parse(
          'https://hys-api.herokuapp.com/web_delete_questions_examlikelyhood_details'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        "Access-Control_Allow_Origin": "*"
      },
      body: jsonEncode(
          <String, dynamic>{"user_id": user_id, "question_id": question_id}),
    );
    print(response.statusCode);
  }

  Future<void> _add_questions_toughness_details(
      String user_id, String question_id, String toughness_level) async {
    final http.Response response = await http.post(
      Uri.parse(
          'https://hys-api.herokuapp.com/web_add_questions_toughness_details'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        "Access-Control_Allow_Origin": "*"
      },
      body: jsonEncode(<String, dynamic>{
        "user_id": user_id,
        "question_id": question_id,
        "toughness_level": toughness_level
      }),
    );
    print(response.statusCode);
  }

  Future<void> _delete_questions_toughness_details(
      String user_id, String question_id) async {
    final http.Response response = await http.delete(
      Uri.parse(
          'https://hys-api.herokuapp.com/web_delete_questions_toughness_details'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        "Access-Control_Allow_Origin": "*"
      },
      body: jsonEncode(
          <String, dynamic>{"user_id": user_id, "question_id": question_id}),
    );
    print(response.statusCode);
  }

  Future<void> _update_count(String user_id, String question_id,
      String update_count_value, String symbol, int index) async {
    int examlikelyhood = update_count_value == "examlikelyhood"
        ? symbol == "+"
            ? (allQuestionsData[index]["examlikelyhood_count"]) + 1
            : (allQuestionsData[index]["examlikelyhood_count"]) - 1
        : (allQuestionsData[index]["examlikelyhood_count"]);
    int like = update_count_value == "like"
        ? symbol == "+"
            ? (allQuestionsData[index]["like_count"]) + 1
            : (allQuestionsData[index]["like_count"]) - 1
        : (allQuestionsData[index]["like_count"]);
    int toughness = update_count_value == "toughness"
        ? symbol == "+"
            ? (allQuestionsData[index]["toughness_count"]) + 1
            : (allQuestionsData[index]["toughness_count"]) - 1
        : (allQuestionsData[index]["toughness_count"]);
    int answer = update_count_value == "answer"
        ? symbol == "+"
            ? (allQuestionsData[index]["answer_count"]) + 1
            : (allQuestionsData[index]["answer_count"]) - 1
        : (allQuestionsData[index]["answer_count"]);
    int view = update_count_value == "view"
        ? symbol == "+"
            ? (allQuestionsData[index]["view_count"]) + 1
            : (allQuestionsData[index]["view_count"]) - 1
        : (allQuestionsData[index]["view_count"]);
    int impression = update_count_value == "impression"
        ? symbol == "+"
            ? (allQuestionsData[index]["impression_count"]) + 1
            : (allQuestionsData[index]["impression_count"]) - 1
        : (allQuestionsData[index]["impression_count"]);
    print("examlikelyhood: ${examlikelyhood.toString()}");
    print("like: ${like.toString()}");
    print("toughness: ${toughness.toString()}");
    print("answer: ${answer.toString()}");
    print("view: ${view.toString()}");
    print("impression: ${impression.toString()}");
    final http.Response response = await http.put(
      Uri.parse(
          'https://hys-api.herokuapp.com/web_update_counts_in_question_details'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        "Access-Control_Allow_Origin": "*"
      },
      body: jsonEncode(<String, dynamic>{
        "user_id": user_id,
        "question_id": question_id,
        "examlikelyhood_count": examlikelyhood.toDouble(),
        "like_count": like.toDouble(),
        "toughness_count": toughness.toDouble(),
        "answer_count": answer.toDouble(),
        "view_count": view.toDouble(),
        "impression_count": impression.toDouble()
      }),
    );
    print(response.statusCode);
    if ((response.statusCode == 200) || (response.statusCode == 201)) {
      setState(() {});
    }
  }

  _showQuestionLikedDialog(int index) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Column(
        children: [
          Container(
            width: 150,
            height: 35,
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(100),
                border: Border.all(color: Colors.black12)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Tooltip(
                  preferBelow: false,
                  decoration: const BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.all(Radius.circular(5))),
                  message: "Like",
                  child: IconButton(
                    icon: Icon(FontAwesome5.thumbs_up,
                        size: 15,
                        color: (questionlikedLocalDB!.get(
                                    allQuestionsData[index]["question_id"]) ==
                                "like")
                            ? Color(0xff0962ff)
                            : Color(0xff0C2551)),
                    onPressed: () async {
                      if (questionmarkedimpLocalDB!
                              .get(allQuestionsData[index]["question_id"]) ==
                          "markasimp") {
                        questionmarkedimpLocalDB!
                            .delete(allQuestionsData[index]["question_id"]);
                        questionlikedLocalDB!.put(
                            allQuestionsData[index]["question_id"], "like");
                        _delete_questions_like_details(
                            allQuestionsData[index]["user_id"],
                            allQuestionsData[index]["question_id"]);
                        _add_questions_like_details(
                            allQuestionsData[index]["user_id"],
                            allQuestionsData[index]["question_id"],
                            "like");
                      } else if ((questionmydoubttooLocalDB!
                              .get(allQuestionsData[index]["question_id"]) ==
                          "mydoubttoo")) {
                        questionmydoubttooLocalDB!
                            .delete(allQuestionsData[index]["question_id"]);
                        questionlikedLocalDB!.put(
                            allQuestionsData[index]["question_id"], "like");
                        _delete_questions_like_details(
                            allQuestionsData[index]["user_id"],
                            allQuestionsData[index]["question_id"]);
                        _add_questions_like_details(
                            allQuestionsData[index]["user_id"],
                            allQuestionsData[index]["question_id"],
                            "like");
                      } else if ((questionlikedLocalDB!
                              .get(allQuestionsData[index]["question_id"]) ==
                          "like")) {
                        questionlikedLocalDB!
                            .delete(allQuestionsData[index]["question_id"]);
                        setState(() {
                          _likecount[index] = _likecount[index] - 1;
                        });
                        _delete_questions_like_details(
                            allQuestionsData[index]["user_id"],
                            allQuestionsData[index]["question_id"]);
                        _update_count(
                            allQuestionsData[index]["user_id"],
                            allQuestionsData[index]["question_id"],
                            'like',
                            "-",
                            index);
                      } else {
                        setState(() {
                          _likecount[index] = _likecount[index] + 1;
                        });
                        questionlikedLocalDB!.put(
                            allQuestionsData[index]["question_id"], "like");
                        _update_count(
                            allQuestionsData[index]["user_id"],
                            allQuestionsData[index]["question_id"],
                            'like',
                            "+",
                            index);
                        _add_questions_like_details(
                            allQuestionsData[index]["user_id"],
                            allQuestionsData[index]["question_id"],
                            "like");
                      }
                      setState(() {
                        likebutton[index] = false;
                      });
                    },
                  ),
                ),
                Tooltip(
                  preferBelow: false,
                  decoration: const BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.all(Radius.circular(5))),
                  message: "Mark As Important",
                  child: IconButton(
                    icon: Icon(Icons.done_all,
                        size: 15,
                        color: questionmarkedimpLocalDB!.get(
                                    allQuestionsData[index]["question_id"]) ==
                                "markasimp"
                            ? Color(0xff0962ff)
                            : Color(0xff0C2551)),
                    onPressed: () async {
                      if (questionlikedLocalDB!
                              .get(allQuestionsData[index]["question_id"]) ==
                          "like") {
                        questionlikedLocalDB!
                            .delete(allQuestionsData[index]["question_id"]);
                        questionmarkedimpLocalDB!.put(
                            allQuestionsData[index]["question_id"],
                            "markasimp");
                        _delete_questions_like_details(
                            allQuestionsData[index]["user_id"],
                            allQuestionsData[index]["question_id"]);
                        _add_questions_like_details(
                            allQuestionsData[index]["user_id"],
                            allQuestionsData[index]["question_id"],
                            "markasimp");
                      } else if ((questionmydoubttooLocalDB!
                              .get(allQuestionsData[index]["question_id"]) ==
                          "mydoubttoo")) {
                        questionmydoubttooLocalDB!
                            .delete(allQuestionsData[index]["question_id"]);
                        questionmarkedimpLocalDB!.put(
                            allQuestionsData[index]["question_id"],
                            "markasimp");
                        _delete_questions_like_details(
                            allQuestionsData[index]["user_id"],
                            allQuestionsData[index]["question_id"]);
                        _add_questions_like_details(
                            allQuestionsData[index]["user_id"],
                            allQuestionsData[index]["question_id"],
                            "markasimp");
                      } else if ((questionmarkedimpLocalDB!
                              .get(allQuestionsData[index]["question_id"]) ==
                          "markasimp")) {
                        questionmarkedimpLocalDB!
                            .delete(allQuestionsData[index]["question_id"]);
                        setState(() {
                          _likecount[index] = _likecount[index] - 1;
                        });
                        _update_count(
                            allQuestionsData[index]["user_id"],
                            allQuestionsData[index]["question_id"],
                            'markasimp',
                            "-",
                            index);

                        _delete_questions_like_details(
                            allQuestionsData[index]["user_id"],
                            allQuestionsData[index]["question_id"]);
                      } else {
                        setState(() {
                          _likecount[index] = _likecount[index] + 1;
                        });
                        questionmarkedimpLocalDB!.put(
                            allQuestionsData[index]["question_id"],
                            "markasimp");
                        _update_count(
                            allQuestionsData[index]["user_id"],
                            allQuestionsData[index]["question_id"],
                            'markasimp',
                            "+",
                            index);

                        _add_questions_like_details(
                            allQuestionsData[index]["user_id"],
                            allQuestionsData[index]["question_id"],
                            "markasimp");
                      }
                      setState(() {
                        likebutton[index] = false;
                      });
                    },
                  ),
                ),
                Tooltip(
                  preferBelow: false,
                  decoration: const BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.all(Radius.circular(5))),
                  message: "My doubt too",
                  child: IconButton(
                      icon: Icon(Icons.pan_tool,
                          size: 15,
                          color: questionmydoubttooLocalDB!.get(
                                      allQuestionsData[index]["question_id"]) ==
                                  "mydoubttoo"
                              ? Color(0xff0962ff)
                              : Color(0xff0C2551)),
                      onPressed: () async {
                        if ((questionmarkedimpLocalDB!
                                .get(allQuestionsData[index]["question_id"]) ==
                            "markasimp")) {
                          questionmarkedimpLocalDB!
                              .delete(allQuestionsData[index]["question_id"]);
                          questionmydoubttooLocalDB!.put(
                              allQuestionsData[index]["question_id"],
                              "mydoubttoo");

                          _delete_questions_like_details(
                              allQuestionsData[index]["user_id"],
                              allQuestionsData[index]["question_id"]);
                          _add_questions_like_details(
                              allQuestionsData[index]["user_id"],
                              allQuestionsData[index]["question_id"],
                              "mydoubttoo");
                        } else if ((questionlikedLocalDB!
                                .get(allQuestionsData[index]["question_id"]) ==
                            "like")) {
                          questionlikedLocalDB!
                              .delete(allQuestionsData[index]["question_id"]);
                          questionmydoubttooLocalDB!.put(
                              allQuestionsData[index]["question_id"],
                              "mydoubttoo");

                          _delete_questions_like_details(
                              allQuestionsData[index]["user_id"],
                              allQuestionsData[index]["question_id"]);
                          _add_questions_like_details(
                              allQuestionsData[index]["user_id"],
                              allQuestionsData[index]["question_id"],
                              "mydoubttoo");
                        } else if ((questionmydoubttooLocalDB!
                                .get(allQuestionsData[index]["question_id"]) ==
                            "mydoubttoo")) {
                          questionmydoubttooLocalDB!
                              .delete(allQuestionsData[index]["question_id"]);
                          setState(() {
                            _likecount[index] = _likecount[index] - 1;
                          });
                          _update_count(
                              allQuestionsData[index]["user_id"],
                              allQuestionsData[index]["question_id"],
                              'mydoubttoo',
                              "-",
                              index);

                          _delete_questions_like_details(
                              allQuestionsData[index]["user_id"],
                              allQuestionsData[index]["question_id"]);
                        } else {
                          setState(() {
                            _likecount[index] = _likecount[index] + 1;
                          });
                          questionmydoubttooLocalDB!.put(
                              allQuestionsData[index]["question_id"],
                              "mydoubttoo");
                          _update_count(
                              allQuestionsData[index]["user_id"],
                              allQuestionsData[index]["question_id"],
                              'mydoubttoo',
                              "+",
                              index);

                          _add_questions_like_details(
                              allQuestionsData[index]["user_id"],
                              allQuestionsData[index]["question_id"],
                              "mydoubttoo");
                        }
                        setState(() {
                          likebutton[index] = false;
                        });
                      }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _add_questions_like_details(
      String user_id, String question_id, String like_type) async {
    final http.Response response = await http.post(
      Uri.parse('https://hys-api.herokuapp.com/web_add_questions_like_details'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        "Access-Control_Allow_Origin": "*"
      },
      body: jsonEncode(<String, dynamic>{
        "user_id": user_id,
        "question_id": question_id,
        "like_type": like_type
      }),
    );
    print(response.statusCode);
  }

  Future<void> _delete_questions_like_details(
      String user_id, String question_id) async {
    final http.Response response = await http.delete(
      Uri.parse(
          'https://hys-api.herokuapp.com/web_delete_questions_like_details'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        "Access-Control_Allow_Origin": "*"
      },
      body: jsonEncode(
          <String, dynamic>{"user_id": user_id, "question_id": question_id}),
    );
    print(response.statusCode);
  }

  Widget _loading() {
    return Center(
      child: Container(
          height: 50.0,
          margin: EdgeInsets.only(left: 10.0, right: 10.0),
          child: Center(
              child: CircularProgressIndicator(
            valueColor:
                AlwaysStoppedAnimation<Color>(Color.fromRGBO(88, 165, 196, 1)),
          ))),
    );
  }
}

class Dialogs {
  static Future<void> showLoadingDialog(
      BuildContext context, GlobalKey key) async {
    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new WillPopScope(
              onWillPop: () async => false,
              child: SimpleDialog(
                  key: key,
                  backgroundColor: Colors.black54,
                  children: <Widget>[
                    Center(
                      child: Column(children: [
                        CircularProgressIndicator(),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          "Please Wait....",
                          style: TextStyle(color: Colors.blueAccent),
                        )
                      ]),
                    )
                  ]));
        });
  }
}
