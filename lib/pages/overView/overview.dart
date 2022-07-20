import 'dart:convert';
import 'dart:html';
import 'dart:typed_data';
import 'package:HyS/constants/style.dart';
import 'package:HyS/database/crud.dart';
import 'package:HyS/database/feedpostdb.dart';
import 'package:HyS/database/notificationdb.dart';
import 'package:HyS/pages/overView/cropimage.dart';
import 'package:HyS/pages/overView/dataload_crud.dart';
import 'package:HyS/pages/overView/notification_crud.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:draggable_widget/draggable_widget.dart';
import 'package:elegant_notification/elegant_notification.dart';
import 'package:expandable/expandable.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_custom_dialog/flutter_custom_dialog.dart';
import 'package:fluttericon/entypo_icons.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:oktoast/oktoast.dart';
import 'package:readmore/readmore.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:flutter_mentions/flutter_mentions.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_tex/flutter_tex.dart';
import 'package:fluttericon/typicons_icons.dart';
import 'package:flutter_placeholder_textlines/flutter_placeholder_textlines.dart';

import '../../main.dart';

class OverView extends StatefulWidget {
  @override
  _OverViewState createState() => _OverViewState();
}

class _OverViewState extends State<OverView> {
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
  Box<dynamic>? answerReplylikedLocalDB;

  Box<dynamic>? allQuestionsLocalDB;
  Box<dynamic>? allAnswersLocalDB;
  Box<dynamic>? allCommentsLocalDB;
  Box<dynamic>? allRepliesLocalDB;
  Box<dynamic>? allSavedQLocalDB;
  Box<dynamic>? allBookmarkedQLocalDB;

  Box<dynamic>? allSocialPostLocalDB;
  Box<dynamic>? allSocialCommentLocalDB;
  Box<dynamic>? allSocialRepliesLocalDB;

  final dragCotroller = DragController();
  String _currentUserId = FirebaseAuth.instance.currentUser!.uid;

  List<dynamic> allQuestionsData = [];
  List<dynamic> allAnswerData = [];

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

  String selectedSubject = "";
  String selectedTopic = "";
  List<List<String>> topicList = [];
  Box<dynamic>? topicListQLocalDB;
  List<String> subjectList = [];
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
  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();

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
  final databaseReference = FirebaseDatabase.instance.reference();
  NotificationCRUD notifyCRUD = NotificationCRUD();
  DataSnapshot? countData;
  QuerySnapshot? connectionStatus;

  List<GlobalKey>? KeyList;
  double? _x, _y;
  void _getOffset(GlobalKey key) {
    RenderBox renderBox = key.currentContext?.findRenderObject() as RenderBox;

    Size size = renderBox.size; // or _widgetKey.currentContext?.size
    print('Size: ${size.width}, ${size.height}');

    Offset offset = renderBox.localToGlobal(Offset.zero);
    print('Offset: ${offset.dx}, ${offset.dy}');
    print(
        'Position: ${(offset.dx + size.width) / 2}, ${(offset.dy + size.height) / 2}');
    setState(() {
      _x = offset.dx;
      _y = offset.dy;
    });
  }

  void initState() {
    userDataDB = Hive.box<dynamic>('userdata');
    questionlikedLocalDB = Hive.box<dynamic>('questionliked');
    questionsavedLocalDB = Hive.box<dynamic>('questionsaved');
    questionbookmarkedLocalDB = Hive.box<dynamic>('questionedbookmarked');
    questionexamlikelyhoodLocalDB = Hive.box<dynamic>('questionexamlikelyhood');
    questiontoughnessLocalDB = Hive.box<dynamic>('questiontoughness');
    questionmydoubttooLocalDB = Hive.box<dynamic>('questionmydoubttoo');
    questionmarkedimpLocalDB = Hive.box<dynamic>('questionmarkimp');
    questionreportLocalDB = Hive.box<dynamic>('questionreport');
    usertokendataLocalDB = Hive.box<dynamic>('usertokendata');
    questionaskReferenceLocalDB = Hive.box<dynamic>('questionaskreference');

    answerlikedLocalDB = Hive.box<dynamic>('answerliked');
    answervotesLocalDB = Hive.box<dynamic>('answervotes');
    answermarkasimpLocalDB = Hive.box<dynamic>("answermarkasimp");
    answerhelpfulLocalDB = Hive.box<dynamic>("answerhelpful");

    answerCommentlikedLocalDB = Hive.box<dynamic>('answercommentliked');
    answerCommentReplyLocalDB = Hive.box<dynamic>('answercommentreply');
    answerReplylikedLocalDB = Hive.box<dynamic>('ansSubcommentliked');

    allQuestionsLocalDB = Hive.box<dynamic>('allquestions');
    allAnswersLocalDB = Hive.box<dynamic>('allanswers');
    allCommentsLocalDB = Hive.box<dynamic>('allQcomments');
    allRepliesLocalDB = Hive.box<dynamic>('allQreplies');
    allSavedQLocalDB = Hive.box<dynamic>('allQsaved');
    allBookmarkedQLocalDB = Hive.box<dynamic>('allQbookmark');
    topicListQLocalDB = Hive.box<dynamic>('topiclist');

    allSocialPostLocalDB = Hive.box<dynamic>('allsocialposts');
    allSocialCommentLocalDB = Hive.box<dynamic>('allsocialcomments');
    allSocialRepliesLocalDB = Hive.box<dynamic>('allsocialreplies');

    _get_all_users_data_for_tagging();
    _get_all_questions_posted();
    _get_all_answers_posted();
    _get_all_answers_comment_posted();
    _get_all_answers_reply_posted();
    topicList = topicListQLocalDB!.get("topiclist");
    subjectList = topicListQLocalDB!.get("subjectlist");

    crudobj.getAllUserConnectionStatus().then((value) {
      setState(() {
        connectionStatus = value;
      });
    });

    super.initState();
  }

  void dispose() {
    databaseReference
        .child("hysweb")
        .child("qANDa")
        .child("jump_to_listview_index")
        .update({"$_currentUserId": 0});
    super.dispose();
  }

  Future<void> _get_all_users_data_for_tagging() async {
    final http.Response response = await http.get(
      Uri.parse(
          'https://hys-api.herokuapp.com/web_get_all_users_data_for_tagging'),
    );

    print("get_all_users_data_for_taggigng: ${response.statusCode}");
    if ((response.statusCode == 200) || (response.statusCode == 201)) {
      setState(() {
        List<dynamic> taggingData = json.decode(response.body);
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
        }
        print(_users);
      });
    }
  }

  Future<void> _get_all_questions_posted() async {
    allQuestionsData = [];
    _likecountbool = [];
    _answercountbool = [];
    _toughnesscountbool = [];
    _examlikelyhoodcountbool = [];
    _likecount = [];
    _answercount = [];
    _toughnesscount = [];
    _examlikelyhoodcount = [];
    _empressionscount = [];
    likebutton = [];
    examlikelyhoodbutton = [];
    toughnessbutton = [];
    allAnswersQIDwisebool = [];

    setState(() {
      allQuestionsData = allQuestionsLocalDB!.get("data");
      KeyList = List.generate(
          allQuestionsData.length, (index) => GlobalObjectKey(index));
      for (int i = 0; i < allQuestionsData.length; i++) {
        allAnswersQIDwisebool.add(false);
        _likecountbool.add(false);
        _answercountbool.add(false);
        _toughnesscountbool.add(false);
        _examlikelyhoodcountbool.add(false);
        likebutton.add(false);
        examlikelyhoodbutton.add(false);
        toughnessbutton.add(false);
        _likecount.add(allQuestionsData[i]["like_count"]);
        _answercount.add(allQuestionsData[i]["answer_count"]);
        _toughnesscount.add(allQuestionsData[i]["toughness_count"]);
        _examlikelyhoodcount.add(allQuestionsData[i]["examlikelyhood_count"]);
        _empressionscount.add(allQuestionsData[i]["view_count"]);
      }
    });
    _get_all_saved_question();
    _get_all_bookmarked_question();
  }

  Future<void> _get_all_answers_posted() async {
    allAnswerQuestionID = [];
    allAnswersQIDwise = [];
    isANSExpand = [];
    likebuttonAns = [];
    likeCountAns = [];
    commentCountAns = [];
    upvoteCountAns = [];
    downVoteCountAns = [];
    final http.Response response = await http.get(
      Uri.parse('https://hys-api.herokuapp.com/web_get_all_answer_posted'),
    );
    print("get_all_answer_posted: ${response.statusCode}");
    if ((response.statusCode == 200) || (response.statusCode == 201)) {
      setState(() {
        allAnswerData = json.decode(response.body);
        for (int i = 0; i < allAnswerData.length; i++) {
          if (allAnswerQuestionID.isEmpty) {
            allAnswerQuestionID.add(allAnswerData[i]["question_id"]);
            allAnswersQIDwise.add([]);
            isANSExpand.add([]);
            likebuttonAns.add([]);
            likeCountAns.add([]);
            commentCountAns.add([]);
            upvoteCountAns.add([]);
            downVoteCountAns.add([]);
          } else {
            int count = 0;
            for (int j = 0; j < allAnswerQuestionID.length; j++) {
              if (allAnswerData[i]["question_id"] == allAnswerQuestionID[j]) {
                count++;
                break;
              }
            }
            if (count == 0) {
              allAnswerQuestionID.add(allAnswerData[i]["question_id"]);
              allAnswersQIDwise.add([]);
              isANSExpand.add([]);
              likebuttonAns.add([]);
              likeCountAns.add([]);
              commentCountAns.add([]);
              upvoteCountAns.add([]);
              downVoteCountAns.add([]);
            }
          }
          int index = 0;
          for (int j = 0; j < allAnswerQuestionID.length; j++) {
            if (allAnswerData[i]["question_id"] == allAnswerQuestionID[j]) {
              index = j;
              break;
            }
          }
          allAnswersQIDwise[index].add(allAnswerData[i]);
          likeCountAns[index].add(allAnswerData[i]["like_count"]);
          commentCountAns[index].add(allAnswerData[i]["comment_count"]);
          upvoteCountAns[index].add(allAnswerData[i]["upvote_count"]);
          downVoteCountAns[index].add(allAnswerData[i]["downvote_count"]);
          isANSExpand[index].add(false);
          likebuttonAns[index].add(false);
        }
      });
    }
  }

  Future<void> _get_all_answers_comment_posted() async {
    allAnswerCommentData = [];
    allAnscmntAnswerID = [];
    allAnscmntANSIDwise = [];
    allAnscmntANSIDwisebool = [];
    isANSCMNTExpand = [];
    likebuttonAnscmnt = [];
    likeCountAnscmnt = [];
    replyCountAnscmnt = [];
    final http.Response response = await http.get(
      Uri.parse('https://hys-api.herokuapp.com/web_get_all_answer_comments'),
    );
    print("get_all_answer_comments: ${response.statusCode}");
    if ((response.statusCode == 200) || (response.statusCode == 201)) {
      setState(() {
        allAnswerCommentData = json.decode(response.body);
        for (int i = 0; i < allAnswerCommentData.length; i++) {
          if (allAnscmntAnswerID.isEmpty) {
            allAnscmntAnswerID.add(allAnswerCommentData[i]["answer_id"]);
            allAnscmntANSIDwise.add([]);
            isANSCMNTExpand.add([]);
            likebuttonAnscmnt.add([]);
            likeCountAnscmnt.add([]);
            replyCountAnscmnt.add([]);
            allAnscmntANSIDwisebool.add(false);
          } else {
            int count = 0;
            for (int j = 0; j < allAnscmntAnswerID.length; j++) {
              if (allAnswerCommentData[i]["answer_id"] ==
                  allAnscmntAnswerID[j]) {
                count++;
                break;
              }
            }
            if (count == 0) {
              allAnscmntAnswerID.add(allAnswerCommentData[i]["answer_id"]);
              allAnscmntANSIDwise.add([]);
              isANSCMNTExpand.add([]);
              likebuttonAnscmnt.add([]);
              likeCountAnscmnt.add([]);
              replyCountAnscmnt.add([]);
              allAnscmntANSIDwisebool.add(false);
            }
          }
          int index = 0;
          for (int j = 0; j < allAnscmntAnswerID.length; j++) {
            if (allAnswerCommentData[i]["answer_id"] == allAnscmntAnswerID[j]) {
              index = j;
              break;
            }
          }
          allAnscmntANSIDwise[index].add(allAnswerCommentData[i]);
          likeCountAnscmnt[index].add(allAnswerCommentData[i]["like_count"]);
          replyCountAnscmnt[index].add(allAnswerCommentData[i]["reply_count"]);
          isANSCMNTExpand[index].add(false);
          likebuttonAnscmnt[index].add(false);
        }
      });
    }
  }

  Future<void> _get_all_answers_reply_posted() async {
    allAnswerReplyData = [];
    allAnsreplyCommentID = [];
    allAnsReplyCMNTIDwise = [];
    allAnsReplyCMNTIDwisebool = [];
    isReplyCMNTExpand = [];
    likebuttonAnsReply = [];
    likeCountAnsReply = [];

    final http.Response response = await http.get(
      Uri.parse('https://hys-api.herokuapp.com/web_get_all_answer_reply'),
    );
    print("get_all_answer_reply: ${response.statusCode}");
    if ((response.statusCode == 200) || (response.statusCode == 201)) {
      setState(() {
        allAnswerReplyData = json.decode(response.body);
        for (int i = 0; i < allAnswerReplyData.length; i++) {
          if (allAnsreplyCommentID.isEmpty) {
            allAnsreplyCommentID.add(allAnswerReplyData[i]["comment_id"]);
            allAnsReplyCMNTIDwise.add([]);
            isReplyCMNTExpand.add([]);
            likebuttonAnsReply.add([]);
            likeCountAnsReply.add([]);
            allAnsReplyCMNTIDwisebool.add(false);
          } else {
            int count = 0;
            for (int j = 0; j < allAnsreplyCommentID.length; j++) {
              if (allAnswerReplyData[i]["comment_id"] ==
                  allAnsreplyCommentID[j]) {
                count++;
                break;
              }
            }
            if (count == 0) {
              allAnsreplyCommentID.add(allAnswerReplyData[i]["comment_id"]);
              allAnsReplyCMNTIDwise.add([]);
              isReplyCMNTExpand.add([]);
              likebuttonAnsReply.add([]);
              likeCountAnsReply.add([]);
              replyCountAnscmnt.add([]);
              allAnsReplyCMNTIDwisebool.add(false);
            }
          }
          int index = 0;
          for (int j = 0; j < allAnsreplyCommentID.length; j++) {
            if (allAnswerReplyData[i]["comment_id"] ==
                allAnsreplyCommentID[j]) {
              index = j;
              break;
            }
          }
          allAnsReplyCMNTIDwise[index].add(allAnswerReplyData[i]);
          likeCountAnsReply[index].add(allAnswerReplyData[i]["like_count"]);
          isReplyCMNTExpand[index].add(false);
          likebuttonAnsReply[index].add(false);
        }
        print(allAnsreplyCommentID);
        print(allAnsReplyCMNTIDwise);
      });
    }
  }

  List<dynamic> allSavedQuestions = [];
  List<bool> allQuestionWiseSavedOrNot = [];
  List<dynamic> allBookmakredQuestions = [];
  List<bool> allQuestionWiseBookmarkedOrNot = [];

  Future<void> _get_all_saved_question() async {
    allSavedQuestions = [];
    allQuestionWiseSavedOrNot = [];

    final http.Response response = await http.get(
      Uri.parse(
          'https://hys-api.herokuapp.com/web_get_question_saved_details/${_currentUserId}'),
    );
    print("get_question_saved_details: ${response.statusCode}");
    if ((response.statusCode == 200) || (response.statusCode == 201)) {
      setState(() {
        allSavedQuestions = json.decode(response.body);
        for (int i = 0; i < allQuestionsData.length; i++) {
          int count = 0;
          for (int j = 0; j < allSavedQuestions.length; j++) {
            if (allQuestionsData[i]["question_id"] ==
                allSavedQuestions[j]["question_id"]) {
              count++;
              break;
            }
          }
          if (count != 0) {
            allQuestionWiseSavedOrNot.add(true);
          } else {
            allQuestionWiseSavedOrNot.add(false);
          }
        }
        print("Saved: $allQuestionWiseSavedOrNot");
      });
    }
  }

  Future<void> _get_all_bookmarked_question() async {
    allBookmakredQuestions = [];
    allQuestionWiseBookmarkedOrNot = [];

    final http.Response response = await http.get(
      Uri.parse(
          'https://hys-api.herokuapp.com/web_get_question_bookmarked_details/${_currentUserId}'),
    );
    print("get_question_bookmarked_details: ${response.statusCode}");
    if ((response.statusCode == 200) || (response.statusCode == 201)) {
      setState(() {
        allBookmakredQuestions = json.decode(response.body);
        for (int i = 0; i < allQuestionsData.length; i++) {
          int count = 0;
          for (int j = 0; j < allBookmakredQuestions.length; j++) {
            if (allQuestionsData[i]["question_id"] ==
                allBookmakredQuestions[j]["question_id"]) {
              count++;
              break;
            }
          }
          if (count != 0) {
            allQuestionWiseBookmarkedOrNot.add(true);
          } else {
            allQuestionWiseBookmarkedOrNot.add(false);
          }
        }
        print("Saved: $allQuestionWiseSavedOrNot");
      });
    }
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
        "examlikelyhood_count": examlikelyhood,
        "like_count": like,
        "toughness_count": toughness,
        "answer_count": answer,
        "view_count": view,
        "impression_count": impression
      }),
    );
    print(response.statusCode);
    if ((response.statusCode == 200) || (response.statusCode == 201)) {
      setState(() {});
    }
  }

  double? _width;
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
    _width = MediaQuery.of(context).size.width;

    comparedate = DateFormat('yyyyMMddkkmm').format(DateTime.now());
    if (countData != null) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          //this logic is used to hide the like popup when you click or touch anywhere on screen
          if ((likebuttonpopupremove != null) ||
              (examlikelyhoodbuttonpopupremove != null) ||
              (toughnessbuttonpopupremove != null)) {
            for (int i = 0; i < likebuttonpopupremove.length; i++) {
              setState(() {
                likebutton[likebuttonpopupremove[i]] = false;
              });
            }
            for (int i = 0; i < examlikelyhoodbuttonpopupremove.length; i++) {
              setState(() {
                examlikelyhoodbutton[examlikelyhoodbuttonpopupremove[i]] =
                    false;
              });
            }
            for (int i = 0; i < toughnessbuttonpopupremove.length; i++) {
              setState(() {
                toughnessbutton[toughnessbuttonpopupremove[i]] = false;
              });
            }
          }
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: ScrollablePositionedList.builder(
          itemCount: allQuestionsData.length,
          shrinkWrap: true,
          initialScrollIndex: countData!.value["qANDa"]
              ["jump_to_listview_index"][_currentUserId],
          physics: BouncingScrollPhysics(),
          itemScrollController: itemScrollController,
          itemPositionsListener: itemPositionsListener,
          itemBuilder: (context, index) {
            return index == 0
                ? _ifIisZero()
                : _width! > 530
                    ? allQuestionsData[index]["question_type"] == 'shared'
                        ? _sharedQuestionFeedText(index)
                        : _questionFeedText(index)
                    : allQuestionsData[index]["question_type"] == 'shared'
                        ? _sharedQuestionFeedTextForSmallScreen(index)
                        : _questionFeedTextForsmallScreen(index);
          },
        ),
      );
    } else {
      return _loading();
    }
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

  _ifIisZero() {
    double _width = MediaQuery.of(context).size.width;
    return Column(
      children: [
        SizedBox(height: 40),
        _width > 530
            ? Container(
                width: 500,
                padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: light,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    InkWell(
                      onTap: () {
                        databaseReference
                            .child("hysweb")
                            .child("app_bar_navigation")
                            .child(FirebaseAuth.instance.currentUser!.uid)
                            .update({"$_currentUserId": 7});
                      },
                      child: CircleAvatar(
                        backgroundImage:
                            NetworkImage(userDataDB!.get("profilepic")),
                        radius: 25,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        _addQuestionPostDialog();
                      },
                      child: Container(
                          width: 350,
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              color: background),
                          child: Text(
                              "Ask your doubt, ${userDataDB!.get("first_name")}?",
                              style: TextStyle(
                                  color: lightGrey,
                                  fontSize: 16,
                                  fontWeight: FontWeight.normal))),
                    ),
                  ],
                ),
              )
            : Container(
                margin: EdgeInsets.only(left: 20, right: 20),
                padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: light,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    InkWell(
                      onTap: () {
                        databaseReference
                            .child("hysweb")
                            .child("app_bar_navigation")
                            .child(FirebaseAuth.instance.currentUser!.uid)
                            .update({"$_currentUserId": 7});
                      },
                      child: CircleAvatar(
                        backgroundImage:
                            NetworkImage(userDataDB!.get("profilepic")),
                        radius: 25,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        _addQuestionPostDialog();
                      },
                      child: Container(
                          width: 300,
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              color: background),
                          child: Text(
                              "Ask your doubt, ${userDataDB!.get("first_name")}?",
                              style: TextStyle(
                                  color: lightGrey,
                                  fontSize: 14,
                                  fontWeight: FontWeight.normal))),
                    ),
                  ],
                ),
              ),
        SizedBox(height: 20),
        _width > 530
            ? Container(
                width: 500,
                height: 70,
                padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: light,
                ),
                child: ListView.builder(
                    itemCount: _users.length,
                    scrollDirection: Axis.horizontal,
                    physics: BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      return Tooltip(
                        message: _users[index]["display"]!,
                        child: Container(
                          margin: const EdgeInsets.only(right: 20.0),
                          child: Stack(
                            children: [
                              CircleAvatar(
                                backgroundImage:
                                    NetworkImage(_users[index]["photo"]!),
                                radius: 25,
                              ),
                              Positioned(
                                bottom: 1,
                                right: 1,
                                child: Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                        color: Colors.green,
                                        borderRadius: BorderRadius.circular(30),
                                        border: Border.all(
                                            color: background, width: 1))),
                              )
                            ],
                          ),
                        ),
                      );
                    }))
            : Container(
                margin: EdgeInsets.only(left: 20, right: 20),
                height: 70,
                padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: light,
                ),
                child: ListView.builder(
                    itemCount: _users.length,
                    scrollDirection: Axis.horizontal,
                    physics: BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      return Tooltip(
                        message: _users[index]["display"]!,
                        child: Container(
                          margin: const EdgeInsets.only(right: 20.0),
                          child: Stack(
                            children: [
                              CircleAvatar(
                                backgroundImage:
                                    NetworkImage(_users[index]["photo"]!),
                                radius: 25,
                              ),
                              Positioned(
                                bottom: 1,
                                right: 1,
                                child: Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                        color: Colors.green,
                                        borderRadius: BorderRadius.circular(30),
                                        border: Border.all(
                                            color: background, width: 1))),
                              )
                            ],
                          ),
                        ),
                      );
                    })),
        (connectionStatus != null) ? _friendsSuggestion() : SizedBox(),
        _width > 530
            ? allQuestionsData[0]["question_type"] == 'shared'
                ? _sharedQuestionFeedText(0)
                : _questionFeedText(0)
            : allQuestionsData[0]["question_type"] == 'shared'
                ? _sharedQuestionFeedTextForSmallScreen(0)
                : _questionFeedTextForsmallScreen(0)
      ],
    );
  }

  _friendsSuggestion() {
    return Container(
        margin: EdgeInsets.only(top: 20),
        width: 500,
        padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: light,
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text("Best Peers connections for you!",
                    textAlign: TextAlign.start,
                    style:
                        TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              ],
            ),
            Container(
              height: 160,
              child: ListView.builder(
                itemCount: _users.length,
                scrollDirection: Axis.horizontal,
                physics: BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  bool isRequested = false;
                  for (int f = 0; f < connectionStatus!.docs.length; f++) {
                    if (connectionStatus!.docs[f].get("otheruserid") ==
                        _users[index]["id"]) {
                      if ((connectionStatus!.docs[f].get("isrequestaccepted") ==
                              false) &&
                          (connectionStatus!.docs[f].get("isfriend") == true) &&
                          ((connectionStatus!.docs[f].get("onlyfollowing") ==
                              false))) {
                        isRequested = true;
                      }
                    }
                  }
                  return Container(
                    width: 130,
                    padding: EdgeInsets.only(left: 10, right: 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        InkWell(
                            onTap: () {
                              {
                                // Navigator.push(
                                //     context,
                                //     MaterialPageRoute(
                                //         builder: (context) =>
                                //             OthersProfilePage(
                                //                 finalLogicForOldUsers[
                                //                     index][0],
                                //                 "")));
                              }
                            },
                            child: Container(
                              height: 80,
                              width: 80,
                              decoration: new BoxDecoration(
                                shape: BoxShape.circle,

                                // image: new Image.asset(_image.)
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10.0),
                                child: CachedNetworkImage(
                                  imageUrl: _users[index]["photo"]!,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(
                                      height: 80,
                                      width: 80,
                                      child: Image.asset(
                                        "assets/loadingimg.gif",
                                      )),
                                  errorWidget: (context, url, error) =>
                                      Icon(Icons.error),
                                ),
                              ),
                            )),
                        SizedBox(height: 5),
                        InkWell(
                          onTap: () {
                            if (_users[index]["id"] == _currentUserId) {
                              // Navigator.push(
                              //     context,
                              //     MaterialPageRoute(
                              //         builder: (context) =>
                              //             UserProfileDetails()));
                            } else {
                              // Navigator.push(
                              //     context,
                              //     MaterialPageRoute(
                              //         builder: (context) =>
                              //             OthersProfilePage(
                              //                 finalLogicForOldUsers[index]
                              //                     [0],
                              //                 "")));
                            }
                          },
                          child: Container(
                            child: Text(
                              _users[index]["display"].toString(),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                  fontWeight: FontWeight.w400),
                            ),
                          ),
                        ),
                        SizedBox(height: 5),
                        InkWell(
                          onTap: () async {
                            if (isRequested == false) {
                              ////////////////////////////notification//////////////////////////////////////
                              String notify_id =
                                  "ntf${_users[index]["id"]}frndreq$comparedate";
                              notifyCRUD.sendNotification([
                                notify_id,
                                "friendrequest",
                                "friend",
                                _currentUserId,
                                _users[index]["id"],
                                countData!.value["usertoken"]
                                    [_users[index]["id"]]["tokenid"],
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
                                  _users[index]["display"],
                                  _users[index]["photo"],
                                  _users[index]["id"],
                                  true,
                                  true,
                                  false,
                                  false,
                                  current_date,
                                  comparedate);
                              crudobj
                                  .getAllUserConnectionStatus()
                                  .then((value) {
                                setState(() {
                                  connectionStatus = value;
                                });
                              });
                            }
                          },
                          child: Container(
                            width: 100,
                            padding: EdgeInsets.only(top: 5, bottom: 5),
                            decoration: BoxDecoration(
                              color: isRequested == false
                                  ? Color.fromRGBO(88, 165, 196, 1)
                                  : Colors.grey[600],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Center(
                              child: Text(
                                isRequested == false ? 'Add Friend' : "Pending",
                                style: TextStyle(
                                  fontFamily: 'ProductSans',
                                  fontSize: 12,
                                  color: isRequested == false
                                      ? Colors.white70
                                      : Colors.white,
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
          ],
        ));
  }

  _questionFeedText(int index) {
    DateTime tempDate = DateTime.parse(
        allQuestionsData[index]["compare_date"].toString().substring(0, 8));
    String current_date = DateFormat.yMMMMd('en_US').format(tempDate);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          key: KeyList![index],
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
                            onTap: () {
                              databaseReference
                                  .child("hysweb")
                                  .child("app_bar_navigation")
                                  .child(FirebaseAuth.instance.currentUser!.uid)
                                  .update({
                                "$_currentUserId": 7,
                                "userid": allQuestionsData[index]["user_id"]
                              });
                            },
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
                                        )),
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
                                          text: allQuestionsData[index]
                                                      ["is_identity_visible"] ==
                                                  "true"
                                              ? allQuestionsData[index]["city"]
                                              : "",
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Color.fromRGBO(0, 0, 0, 0.5),
                                            fontWeight: FontWeight.normal,
                                          ),
                                        )
                                      ]),
                                ),
                                allQuestionsData[index]
                                            ["is_identity_visible"] ==
                                        "true"
                                    ? Text(
                                        allQuestionsData[index]["school_name"] +
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
                      onTap: () {},
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
                            fontSize: 16,
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
                                    fontSize: 12, sizeUnit: TeXViewSizeUnit.pt),
                                padding: TeXViewPadding.all(10),
                              )),
                        ]),
                        style: TeXViewStyle(
                          elevation: 10,
                          backgroundColor: Color.fromRGBO(242, 246, 248, 1),
                        ),
                      ),
                    ),
              Container(
                padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                            onTap: () {},
                            child: Container(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    _likecount[index].toString(),
                                    style: TextStyle(
                                        fontFamily: 'Nunito Sans',
                                        color: Color.fromRGBO(205, 61, 61, 1)),
                                  ),
                                  SizedBox(
                                    width: 4,
                                  ),
                                  Icon(Entypo.thumbs_up,
                                      color: Color.fromRGBO(0, 0, 0, 0.8),
                                      size: 14),
                                  Icon(Icons.done_all,
                                      color: Color.fromRGBO(0, 0, 0, 0.8),
                                      size: 14),
                                  Icon(Icons.pan_tool,
                                      color: Color.fromRGBO(0, 0, 0, 0.8),
                                      size: 11),
                                  SizedBox(width: 1),
                                ],
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {},
                            child: Container(
                              child: RichText(
                                text: TextSpan(
                                    text: _answercount[index].toString(),
                                    style: TextStyle(
                                      fontFamily: 'Nunito Sans',
                                      color: Color.fromRGBO(205, 61, 61, 1),
                                    ),
                                    children: <TextSpan>[
                                      TextSpan(
                                        text: ' Answers',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: dark,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                                    ]),
                              ),
                            ),
                          ),
                          Container(
                            child: Row(
                              children: [
                                Text(
                                  (_examlikelyhoodcount[index] +
                                          _toughnesscount[index])
                                      .toString(),
                                  style: TextStyle(
                                      fontFamily: 'Nunito Sans',
                                      color: Color.fromRGBO(205, 61, 61, 1)),
                                ),
                                SizedBox(
                                  width: 2,
                                ),
                                Icon(Entypo.gauge,
                                    color: Color.fromRGBO(0, 0, 0, 0.8),
                                    size: 13),
                                SizedBox(
                                  width: 4,
                                ),
                                Text(
                                  allQuestionsData[index]["view_count"]
                                      .toString(),
                                  style: TextStyle(
                                      fontFamily: 'Nunito Sans',
                                      color: Color.fromRGBO(205, 61, 61, 1)),
                                ),
                                SizedBox(
                                  width: 4,
                                ),
                                Icon(FontAwesome5.eye,
                                    color: Color.fromRGBO(0, 0, 0, 0.8),
                                    size: 12),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    Visibility(
                      visible: likebutton[index],
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [_showQuestionLikedDialog(index)],
                      ),
                    ),
                    Container(
                        margin: EdgeInsets.only(left: 2, right: 2, top: 5),
                        color: Colors.black.withOpacity(0.2),
                        height: 0.5,
                        width: MediaQuery.of(context).size.width),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                            icon: Icon(
                                (questionlikedLocalDB!.get(allQuestionsData[index]["question_id"]) ==
                                        "like")
                                    ? FontAwesome5.thumbs_up
                                    : (questionmarkedimpLocalDB!.get(allQuestionsData[index]
                                                ["question_id"]) ==
                                            "markasimp")
                                        ? Icons.done_all
                                        : (questionmydoubttooLocalDB!.get(
                                                    allQuestionsData[index]
                                                        ["question_id"]) ==
                                                "mydoubttoo")
                                            ? Icons.pan_tool
                                            : FontAwesome5.thumbs_up,
                                color: ((questionlikedLocalDB!.get(allQuestionsData[index]["question_id"]) == "like") ||
                                        (questionmarkedimpLocalDB!.get(
                                                allQuestionsData[index]
                                                    ["question_id"]) ==
                                            "markasimp") ||
                                        (questionmydoubttooLocalDB!
                                                .get(allQuestionsData[index]["question_id"]) ==
                                            "mydoubttoo"))
                                    ? Color(0xff0962ff)
                                    : Color.fromRGBO(0, 0, 0, 0.8),
                                size: 14),
                            onPressed: () {
                              setState(() {
                                likebutton[index] = !likebutton[index];
                                likebuttonpopupremove.add(index);
                              });
                            }),
                        IconButton(
                            icon: Icon(FontAwesome5.share,
                                color: Color.fromRGBO(0, 0, 0, 0.8), size: 14),
                            onPressed: () {
                              _shareQuestionPostDialog(index);
                            }),
                        IconButton(
                            icon: Icon(FontAwesome5.edit,
                                color: Color.fromRGBO(0, 0, 0, 0.8), size: 14),
                            onPressed: () {
                              setState(() {
                                latex = "";
                                answer = "";
                              });
                              _addAnswerPostDialog(index);
                            }),
                        IconButton(
                            icon: Icon(Entypo.gauge,
                                color: ((questionexamlikelyhoodLocalDB!.get(allQuestionsData[index]["question_id"]) ==
                                            "low") ||
                                        (questionexamlikelyhoodLocalDB!.get(
                                                allQuestionsData[index]
                                                    ["question_id"]) ==
                                            "moderate") ||
                                        (questionexamlikelyhoodLocalDB!.get(
                                                allQuestionsData[index]
                                                    ["question_id"]) ==
                                            "high") ||
                                        (questiontoughnessLocalDB!.get(allQuestionsData[index]["question_id"]) ==
                                            "low") ||
                                        (questiontoughnessLocalDB!.get(allQuestionsData[index]["question_id"]) ==
                                            "medium") ||
                                        (questiontoughnessLocalDB!
                                                .get(allQuestionsData[index]["question_id"]) ==
                                            "high"))
                                    ? Color(0xff0962ff)
                                    : Color.fromRGBO(0, 0, 0, 0.8),
                                size: 15),
                            onPressed: () {
                              setState(() {
                                likebutton[index] = false;
                                _showExamlikelihoodAndToughnessDialog(index);
                              });
                            }),
                        IconButton(
                            icon: Icon(FontAwesome5.ellipsis_v,
                                color: Color.fromRGBO(0, 0, 0, 0.8), size: 13),
                            onPressed: () {
                              setState(() {
                                likebutton[index] = false;
                              });
                              if (_currentUserId ==
                                  allQuestionsData[index]["user_id"]) {
                                MoreButtonForUser(index);
                              } else {
                                MoreButtonForViewer(index);
                              }
                            }),
                      ],
                    ),
                    Container(
                        margin: EdgeInsets.only(left: 2, right: 2, top: 5),
                        color: Colors.black.withOpacity(0.2),
                        height: 0.5,
                        width: MediaQuery.of(context).size.width),
                    SizedBox(height: 10),
                    _answerView(index)
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  _sharedQuestionFeedText(int index) {
    int i = -1;
    for (int k = 0; k < allQuestionsData.length; k++) {
      if (allQuestionsData[index]["answer_preference"] ==
          allQuestionsData[k]["question_id"]) {
        i = k;
      }
    }
    DateTime tempDate = DateTime.parse(
        allQuestionsData[index]["compare_date"].toString().substring(0, 8));
    String current_date = DateFormat.yMMMMd('en_US').format(tempDate);
    DateTime tempDate1 = DateTime.parse(
        allQuestionsData[i]["compare_date"].toString().substring(0, 8));
    String current_date1 = DateFormat.yMMMMd('en_US').format(tempDate1);
    return i != -1
        ? Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                key: KeyList![index],
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
                                  onTap: () {
                                    databaseReference
                                        .child("hysweb")
                                        .child("app_bar_navigation")
                                        .child(FirebaseAuth
                                            .instance.currentUser!.uid)
                                        .update({
                                      "$_currentUserId": 7,
                                      "userid": allQuestionsData[index]
                                          ["user_id"]
                                    });
                                  },
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
                                        "Shared on " + "$current_date",
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
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () {},
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
                            fontSize: 16,
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
                    ),
                    Container(
                      width: _width! < 600 ? _width! / 1.33 : 450,
                      padding: EdgeInsets.all(5),
                      margin: EdgeInsets.only(top: 20),
                      decoration: BoxDecoration(
                          color: Color.fromRGBO(242, 246, 248, 1),
                          border: Border.all(color: Colors.white, width: 2),
                          borderRadius: BorderRadius.circular(10)),
                      child: Column(children: [
                        Padding(
                          padding: const EdgeInsets.only(left: (5.0), right: 5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                child: Row(
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        databaseReference
                                            .child("hysweb")
                                            .child("app_bar_navigation")
                                            .child(FirebaseAuth
                                                .instance.currentUser!.uid)
                                            .update({
                                          "$_currentUserId": 7,
                                          "userid": allQuestionsData[i]
                                              ["user_id"]
                                        });
                                      },
                                      child: CircleAvatar(
                                        child: ClipOval(
                                          child: Container(
                                            child: CachedNetworkImage(
                                              imageUrl: allQuestionsData[i]
                                                  ["profilepic"],
                                              width: 30,
                                              height: 30,
                                              fit: BoxFit.cover,
                                              placeholder: (context, url) =>
                                                  Container(
                                                width: 30,
                                                height: 30,
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
                                                text: allQuestionsData[i][
                                                            "is_identity_visible"] ==
                                                        "true"
                                                    ? "${allQuestionsData[i]["first_name"]} ${allQuestionsData[i]["last_name"]}, "
                                                    : "HyS User",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: dark,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                children: <TextSpan>[
                                                  TextSpan(
                                                    text: allQuestionsData[i][
                                                                "is_identity_visible"] ==
                                                            "true"
                                                        ? allQuestionsData[i]
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
                                          allQuestionsData[i]
                                                      ["is_identity_visible"] ==
                                                  "true"
                                              ? Text(
                                                  _width! < 600
                                                      ? allQuestionsData[i]
                                                              ["school_name"] +
                                                          ",\n" +
                                                          "Grade " +
                                                          (allQuestionsData[i]
                                                                  ["grade"])
                                                              .toString()
                                                      : allQuestionsData[i]
                                                              ["school_name"] +
                                                          ", " +
                                                          "Grade " +
                                                          (allQuestionsData[i]
                                                                  ["grade"])
                                                              .toString(),
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Color.fromRGBO(
                                                        0, 0, 0, 0.5),
                                                    fontWeight:
                                                        FontWeight.normal,
                                                  ),
                                                )
                                              : SizedBox(),
                                          Text(
                                            "Posted on " + "$current_date1",
                                            style: const TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.normal,
                                              color:
                                                  Color.fromRGBO(0, 0, 0, 0.5),
                                            ),
                                          ),
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
                                    _showDialog(i);
                                  }),
                            ],
                          ),
                        ),
                        allQuestionsData[i]["question_type"] == "text"
                            ? InkWell(
                                onTap: () {},
                                child: Container(
                                  width: MediaQuery.of(context).size.width - 30,
                                  margin: EdgeInsets.fromLTRB(10, 10, 0, 2),
                                  child: ReadMoreText(
                                    allQuestionsData[i]["question"],
                                    textAlign: TextAlign.left,
                                    trimLines: 4,
                                    colorClickableText: Color(0xff0962ff),
                                    trimMode: TrimMode.Line,
                                    trimCollapsedText: 'read more',
                                    trimExpandedText: 'Show less',
                                    style: TextStyle(
                                      fontFamily: 'Nunito Sans',
                                      fontSize: 16,
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
                                        allQuestionsData[i]["question"],
                                        style: TeXViewStyle(
                                          fontStyle: TeXViewFontStyle(
                                              fontSize: 12,
                                              sizeUnit: TeXViewSizeUnit.pt),
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
                      ]),
                    ),
                    Container(
                      padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 8.0, right: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                InkWell(
                                  onTap: () {},
                                  child: Container(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          _likecount[index].toString(),
                                          style: TextStyle(
                                              fontFamily: 'Nunito Sans',
                                              color: Color.fromRGBO(
                                                  205, 61, 61, 1)),
                                        ),
                                        SizedBox(
                                          width: 4,
                                        ),
                                        Icon(Entypo.thumbs_up,
                                            color: Color.fromRGBO(0, 0, 0, 0.8),
                                            size: 14),
                                        Icon(Icons.done_all,
                                            color: Color.fromRGBO(0, 0, 0, 0.8),
                                            size: 14),
                                        Icon(Icons.pan_tool,
                                            color: Color.fromRGBO(0, 0, 0, 0.8),
                                            size: 11),
                                        SizedBox(width: 1),
                                      ],
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () {},
                                  child: Container(
                                    child: RichText(
                                      text: TextSpan(
                                          text: _answercount[index].toString(),
                                          style: TextStyle(
                                            fontFamily: 'Nunito Sans',
                                            color:
                                                Color.fromRGBO(205, 61, 61, 1),
                                          ),
                                          children: <TextSpan>[
                                            TextSpan(
                                              text: ' Answers',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: dark,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            )
                                          ]),
                                    ),
                                  ),
                                ),
                                Container(
                                  child: Row(
                                    children: [
                                      Text(
                                        (_examlikelyhoodcount[index] +
                                                _toughnesscount[index])
                                            .toString(),
                                        style: TextStyle(
                                            fontFamily: 'Nunito Sans',
                                            color:
                                                Color.fromRGBO(205, 61, 61, 1)),
                                      ),
                                      SizedBox(
                                        width: 2,
                                      ),
                                      Icon(Entypo.gauge,
                                          color: Color.fromRGBO(0, 0, 0, 0.8),
                                          size: 13),
                                      SizedBox(
                                        width: 4,
                                      ),
                                      Text(
                                        allQuestionsData[index]["view_count"]
                                            .toString(),
                                        style: TextStyle(
                                            fontFamily: 'Nunito Sans',
                                            color:
                                                Color.fromRGBO(205, 61, 61, 1)),
                                      ),
                                      SizedBox(
                                        width: 4,
                                      ),
                                      Icon(FontAwesome5.eye,
                                          color: Color.fromRGBO(0, 0, 0, 0.8),
                                          size: 12),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                          Visibility(
                            visible: likebutton[index],
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [_showQuestionLikedDialog(index)],
                            ),
                          ),
                          Container(
                              margin:
                                  EdgeInsets.only(left: 2, right: 2, top: 5),
                              color: Colors.black.withOpacity(0.2),
                              height: 0.5,
                              width: MediaQuery.of(context).size.width),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                  icon: Icon(
                                      (questionlikedLocalDB!.get(allQuestionsData[index]["question_id"]) ==
                                              "like")
                                          ? FontAwesome5.thumbs_up
                                          : (questionmarkedimpLocalDB!.get(
                                                      allQuestionsData[index]
                                                          ["question_id"]) ==
                                                  "markasimp")
                                              ? Icons.done_all
                                              : (questionmydoubttooLocalDB!.get(allQuestionsData[index]["question_id"]) ==
                                                      "mydoubttoo")
                                                  ? Icons.pan_tool
                                                  : FontAwesome5.thumbs_up,
                                      color: ((questionlikedLocalDB!.get(allQuestionsData[index]["question_id"]) == "like") ||
                                              (questionmarkedimpLocalDB!.get(
                                                      allQuestionsData[index]
                                                          ["question_id"]) ==
                                                  "markasimp") ||
                                              (questionmydoubttooLocalDB!.get(
                                                      allQuestionsData[index]
                                                          ["question_id"]) ==
                                                  "mydoubttoo"))
                                          ? Color(0xff0962ff)
                                          : Color.fromRGBO(0, 0, 0, 0.8),
                                      size: 14),
                                  onPressed: () {
                                    setState(() {
                                      likebutton[index] = !likebutton[index];
                                      likebuttonpopupremove.add(index);
                                    });
                                  }),
                              IconButton(
                                  icon: Icon(FontAwesome5.share,
                                      color: Color.fromRGBO(0, 0, 0, 0.8),
                                      size: 14),
                                  onPressed: () {
                                    _shareQuestionPostDialog(index);
                                  }),
                              IconButton(
                                  icon: Icon(FontAwesome5.edit,
                                      color: Color.fromRGBO(0, 0, 0, 0.8),
                                      size: 14),
                                  onPressed: () {
                                    setState(() {
                                      latex = "";
                                      answer = "";
                                    });
                                    _addAnswerPostDialog(index);
                                  }),
                              IconButton(
                                  icon: Icon(Entypo.gauge,
                                      color: ((questionexamlikelyhoodLocalDB!.get(allQuestionsData[index]["question_id"]) ==
                                                  "low") ||
                                              (questionexamlikelyhoodLocalDB!.get(allQuestionsData[index]["question_id"]) ==
                                                  "moderate") ||
                                              (questionexamlikelyhoodLocalDB!.get(
                                                      allQuestionsData[index]
                                                          ["question_id"]) ==
                                                  "high") ||
                                              (questiontoughnessLocalDB!.get(
                                                      allQuestionsData[index]
                                                          ["question_id"]) ==
                                                  "low") ||
                                              (questiontoughnessLocalDB!.get(allQuestionsData[index]["question_id"]) ==
                                                  "medium") ||
                                              (questiontoughnessLocalDB!
                                                      .get(allQuestionsData[index]["question_id"]) ==
                                                  "high"))
                                          ? Color(0xff0962ff)
                                          : Color.fromRGBO(0, 0, 0, 0.8),
                                      size: 15),
                                  onPressed: () {
                                    setState(() {
                                      likebutton[index] = false;
                                      _showExamlikelihoodAndToughnessDialog(
                                          index);
                                    });
                                  }),
                              IconButton(
                                  icon: Icon(FontAwesome5.ellipsis_v,
                                      color: Color.fromRGBO(0, 0, 0, 0.8),
                                      size: 13),
                                  onPressed: () {
                                    setState(() {
                                      likebutton[index] = false;
                                    });
                                    if (_currentUserId ==
                                        allQuestionsData[index]["user_id"]) {
                                      MoreButtonForUser(index);
                                    } else {
                                      MoreButtonForViewer(index);
                                    }
                                  }),
                            ],
                          ),
                          Container(
                              margin:
                                  EdgeInsets.only(left: 2, right: 2, top: 5),
                              color: Colors.black.withOpacity(0.2),
                              height: 0.5,
                              width: MediaQuery.of(context).size.width),
                          SizedBox(height: 10),
                          _answerView(index)
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          )
        : SizedBox();
  }

  _sharedQuestionFeedTextForSmallScreen(int index) {
    int i = -1;
    for (int k = 0; k < allQuestionsData.length; k++) {
      if (allQuestionsData[index]["answer_preference"] ==
          allQuestionsData[k]["question_id"]) {
        i = k;
      }
    }
    DateTime tempDate = DateTime.parse(
        allQuestionsData[index]["compare_date"].toString().substring(0, 8));
    String current_date = DateFormat.yMMMMd('en_US').format(tempDate);
    DateTime tempDate1 = DateTime.parse(
        allQuestionsData[i]["compare_date"].toString().substring(0, 8));
    String current_date1 = DateFormat.yMMMMd('en_US').format(tempDate);
    return i != -1
        ? Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                key: KeyList![index],
                padding: EdgeInsets.all(10),
                margin: EdgeInsets.only(top: 20),
                decoration: BoxDecoration(
                    color: Color.fromRGBO(242, 246, 248, 1),
                    borderRadius: BorderRadius.circular(10)),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            child: Row(
                              children: [
                                InkWell(
                                  onTap: () {
                                    databaseReference
                                        .child("hysweb")
                                        .child("app_bar_navigation")
                                        .child(FirebaseAuth
                                            .instance.currentUser!.uid)
                                        .update({
                                      "$_currentUserId": 7,
                                      "userid": allQuestionsData[index]
                                          ["user_id"]
                                    });
                                  },
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
                                        "Shared on " + "$current_date",
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
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () {},
                      child: Container(
                        width: _width! > 600
                            ? MediaQuery.of(context).size.width - 30
                            : MediaQuery.of(context).size.width / 1.8,
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
                            fontSize: 16,
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
                    ),
                    Container(
                      padding: EdgeInsets.only(top: 10, bottom: 10),
                      margin: EdgeInsets.only(top: 10),
                      decoration: BoxDecoration(
                          color: Color.fromRGBO(242, 246, 248, 1),
                          border: Border.all(color: Colors.white, width: 2),
                          borderRadius: BorderRadius.circular(10)),
                      child: Column(children: [
                        Padding(
                          padding: const EdgeInsets.only(left: (5.0), right: 5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                child: Row(
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        databaseReference
                                            .child("hysweb")
                                            .child("app_bar_navigation")
                                            .child(FirebaseAuth
                                                .instance.currentUser!.uid)
                                            .update({
                                          "$_currentUserId": 7,
                                          "userid": allQuestionsData[i]
                                              ["user_id"]
                                        });
                                      },
                                      child: CircleAvatar(
                                        child: ClipOval(
                                          child: Container(
                                            child: CachedNetworkImage(
                                              imageUrl: allQuestionsData[i]
                                                  ["profilepic"],
                                              width: 30,
                                              height: 30,
                                              fit: BoxFit.cover,
                                              placeholder: (context, url) =>
                                                  Container(
                                                width: 30,
                                                height: 30,
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
                                                text: allQuestionsData[i][
                                                            "is_identity_visible"] ==
                                                        "true"
                                                    ? "${allQuestionsData[i]["first_name"]} ${allQuestionsData[i]["last_name"]}, "
                                                    : "HyS User",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: dark,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                children: <TextSpan>[
                                                  TextSpan(
                                                    text: allQuestionsData[i][
                                                                "is_identity_visible"] ==
                                                            "true"
                                                        ? allQuestionsData[i]
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
                                          allQuestionsData[i]
                                                      ["is_identity_visible"] ==
                                                  "true"
                                              ? Text(
                                                  _width! < 600
                                                      ? allQuestionsData[i]
                                                              ["school_name"] +
                                                          ",\n" +
                                                          "Grade " +
                                                          (allQuestionsData[i]
                                                                  ["grade"])
                                                              .toString()
                                                      : allQuestionsData[i]
                                                              ["school_name"] +
                                                          ", " +
                                                          "Grade " +
                                                          (allQuestionsData[i]
                                                                  ["grade"])
                                                              .toString(),
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Color.fromRGBO(
                                                        0, 0, 0, 0.5),
                                                    fontWeight:
                                                        FontWeight.normal,
                                                  ),
                                                )
                                              : SizedBox(),
                                          Text(
                                            "Posted on " + "$current_date1",
                                            style: const TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.normal,
                                              color:
                                                  Color.fromRGBO(0, 0, 0, 0.5),
                                            ),
                                          ),
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
                                    _showDialog(i);
                                  }),
                            ],
                          ),
                        ),
                        allQuestionsData[i]["question_type"] == "text"
                            ? InkWell(
                                onTap: () {},
                                child: Container(
                                  width: MediaQuery.of(context).size.width - 30,
                                  margin: EdgeInsets.fromLTRB(10, 10, 0, 2),
                                  child: ReadMoreText(
                                    allQuestionsData[i]["question"],
                                    textAlign: TextAlign.left,
                                    trimLines: 4,
                                    colorClickableText: Color(0xff0962ff),
                                    trimMode: TrimMode.Line,
                                    trimCollapsedText: 'read more',
                                    trimExpandedText: 'Show less',
                                    style: TextStyle(
                                      fontFamily: 'Nunito Sans',
                                      fontSize: 16,
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
                                        allQuestionsData[i]["question"],
                                        style: TeXViewStyle(
                                          fontStyle: TeXViewFontStyle(
                                              fontSize: 12,
                                              sizeUnit: TeXViewSizeUnit.pt),
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
                      ]),
                    ),
                    Container(
                      padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 8.0, right: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                InkWell(
                                  onTap: () {},
                                  child: Container(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          _likecount[index].toString(),
                                          style: TextStyle(
                                              fontFamily: 'Nunito Sans',
                                              color: Color.fromRGBO(
                                                  205, 61, 61, 1)),
                                        ),
                                        SizedBox(
                                          width: 4,
                                        ),
                                        Icon(Entypo.thumbs_up,
                                            color: Color.fromRGBO(0, 0, 0, 0.8),
                                            size: 14),
                                        Icon(Icons.done_all,
                                            color: Color.fromRGBO(0, 0, 0, 0.8),
                                            size: 14),
                                        Icon(Icons.pan_tool,
                                            color: Color.fromRGBO(0, 0, 0, 0.8),
                                            size: 11),
                                        SizedBox(width: 1),
                                      ],
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () {},
                                  child: Container(
                                    child: RichText(
                                      text: TextSpan(
                                          text: _answercount[index].toString(),
                                          style: TextStyle(
                                            fontFamily: 'Nunito Sans',
                                            color:
                                                Color.fromRGBO(205, 61, 61, 1),
                                          ),
                                          children: <TextSpan>[
                                            TextSpan(
                                              text: ' Answers',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: dark,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            )
                                          ]),
                                    ),
                                  ),
                                ),
                                Container(
                                  child: Row(
                                    children: [
                                      Text(
                                        (_examlikelyhoodcount[index] +
                                                _toughnesscount[index])
                                            .toString(),
                                        style: TextStyle(
                                            fontFamily: 'Nunito Sans',
                                            color:
                                                Color.fromRGBO(205, 61, 61, 1)),
                                      ),
                                      SizedBox(
                                        width: 2,
                                      ),
                                      Icon(Entypo.gauge,
                                          color: Color.fromRGBO(0, 0, 0, 0.8),
                                          size: 13),
                                      SizedBox(
                                        width: 4,
                                      ),
                                      Text(
                                        allQuestionsData[index]["view_count"]
                                            .toString(),
                                        style: TextStyle(
                                            fontFamily: 'Nunito Sans',
                                            color:
                                                Color.fromRGBO(205, 61, 61, 1)),
                                      ),
                                      SizedBox(
                                        width: 4,
                                      ),
                                      Icon(FontAwesome5.eye,
                                          color: Color.fromRGBO(0, 0, 0, 0.8),
                                          size: 12),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                          Visibility(
                            visible: likebutton[index],
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [_showQuestionLikedDialog(index)],
                            ),
                          ),
                          Container(
                              margin:
                                  EdgeInsets.only(left: 2, right: 2, top: 5),
                              color: Colors.black.withOpacity(0.2),
                              height: 0.5,
                              width: MediaQuery.of(context).size.width),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                  icon: Icon(
                                      (questionlikedLocalDB!.get(allQuestionsData[index]["question_id"]) ==
                                              "like")
                                          ? FontAwesome5.thumbs_up
                                          : (questionmarkedimpLocalDB!.get(
                                                      allQuestionsData[index]
                                                          ["question_id"]) ==
                                                  "markasimp")
                                              ? Icons.done_all
                                              : (questionmydoubttooLocalDB!.get(allQuestionsData[index]["question_id"]) ==
                                                      "mydoubttoo")
                                                  ? Icons.pan_tool
                                                  : FontAwesome5.thumbs_up,
                                      color: ((questionlikedLocalDB!.get(allQuestionsData[index]["question_id"]) == "like") ||
                                              (questionmarkedimpLocalDB!.get(
                                                      allQuestionsData[index]
                                                          ["question_id"]) ==
                                                  "markasimp") ||
                                              (questionmydoubttooLocalDB!.get(
                                                      allQuestionsData[index]
                                                          ["question_id"]) ==
                                                  "mydoubttoo"))
                                          ? Color(0xff0962ff)
                                          : Color.fromRGBO(0, 0, 0, 0.8),
                                      size: 14),
                                  onPressed: () {
                                    setState(() {
                                      likebutton[index] = !likebutton[index];
                                      likebuttonpopupremove.add(index);
                                    });
                                  }),
                              IconButton(
                                  icon: Icon(FontAwesome5.share,
                                      color: Color.fromRGBO(0, 0, 0, 0.8),
                                      size: 14),
                                  onPressed: () {
                                    _shareQuestionPostDialog(index);
                                  }),
                              IconButton(
                                  icon: Icon(FontAwesome5.edit,
                                      color: Color.fromRGBO(0, 0, 0, 0.8),
                                      size: 14),
                                  onPressed: () {
                                    setState(() {
                                      latex = "";
                                      answer = "";
                                    });
                                    _addAnswerPostDialog(index);
                                  }),
                              IconButton(
                                  icon: Icon(Entypo.gauge,
                                      color: ((questionexamlikelyhoodLocalDB!.get(allQuestionsData[index]["question_id"]) ==
                                                  "low") ||
                                              (questionexamlikelyhoodLocalDB!.get(allQuestionsData[index]["question_id"]) ==
                                                  "moderate") ||
                                              (questionexamlikelyhoodLocalDB!.get(
                                                      allQuestionsData[index]
                                                          ["question_id"]) ==
                                                  "high") ||
                                              (questiontoughnessLocalDB!.get(
                                                      allQuestionsData[index]
                                                          ["question_id"]) ==
                                                  "low") ||
                                              (questiontoughnessLocalDB!.get(allQuestionsData[index]["question_id"]) ==
                                                  "medium") ||
                                              (questiontoughnessLocalDB!
                                                      .get(allQuestionsData[index]["question_id"]) ==
                                                  "high"))
                                          ? Color(0xff0962ff)
                                          : Color.fromRGBO(0, 0, 0, 0.8),
                                      size: 15),
                                  onPressed: () {
                                    setState(() {
                                      likebutton[index] = false;
                                      _showExamlikelihoodAndToughnessDialog(
                                          index);
                                    });
                                  }),
                              IconButton(
                                  icon: Icon(FontAwesome5.ellipsis_v,
                                      color: Color.fromRGBO(0, 0, 0, 0.8),
                                      size: 13),
                                  onPressed: () {
                                    setState(() {
                                      likebutton[index] = false;
                                    });
                                    if (_currentUserId ==
                                        allQuestionsData[index]["user_id"]) {
                                      MoreButtonForUser(index);
                                    } else {
                                      MoreButtonForViewer(index);
                                    }
                                  }),
                            ],
                          ),
                          Container(
                              margin:
                                  EdgeInsets.only(left: 2, right: 2, top: 5),
                              color: Colors.black.withOpacity(0.2),
                              height: 0.5,
                              width: MediaQuery.of(context).size.width),
                          SizedBox(height: 10),
                          _answerView(index)
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          )
        : SizedBox();
  }

  _questionFeedTextForsmallScreen(int index) {
    DateTime tempDate = DateTime.parse(
        allQuestionsData[index]["compare_date"].toString().substring(0, 8));
    String current_date = DateFormat.yMMMMd('en_US').format(tempDate);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          key: KeyList![index],
          padding: EdgeInsets.all(10),
          margin: EdgeInsets.all(20),
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
                            onTap: () {
                              databaseReference
                                  .child("hysweb")
                                  .child("app_bar_navigation")
                                  .child(FirebaseAuth.instance.currentUser!.uid)
                                  .update({
                                "$_currentUserId": 7,
                                "userid": allQuestionsData[index]["user_id"]
                              });
                            },
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
                                        )),
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
                                          text: allQuestionsData[index]
                                                      ["is_identity_visible"] ==
                                                  "true"
                                              ? allQuestionsData[index]["city"]
                                              : "",
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Color.fromRGBO(0, 0, 0, 0.5),
                                            fontWeight: FontWeight.normal,
                                          ),
                                        )
                                      ]),
                                ),
                                allQuestionsData[index]
                                            ["is_identity_visible"] ==
                                        "true"
                                    ? Text(
                                        allQuestionsData[index]["school_name"] +
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
                      onTap: () {},
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
                            fontSize: 16,
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
                                    fontSize: 12, sizeUnit: TeXViewSizeUnit.pt),
                                padding: TeXViewPadding.all(10),
                              )),
                        ]),
                        style: TeXViewStyle(
                          elevation: 10,
                          backgroundColor: Color.fromRGBO(242, 246, 248, 1),
                        ),
                      ),
                    ),
              Container(
                padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                            onTap: () {},
                            child: Container(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    _likecount[index].toString(),
                                    style: TextStyle(
                                        fontFamily: 'Nunito Sans',
                                        color: Color.fromRGBO(205, 61, 61, 1)),
                                  ),
                                  SizedBox(
                                    width: 4,
                                  ),
                                  Icon(Entypo.thumbs_up,
                                      color: Color.fromRGBO(0, 0, 0, 0.8),
                                      size: 14),
                                  Icon(Icons.done_all,
                                      color: Color.fromRGBO(0, 0, 0, 0.8),
                                      size: 14),
                                  Icon(Icons.pan_tool,
                                      color: Color.fromRGBO(0, 0, 0, 0.8),
                                      size: 11),
                                  SizedBox(width: 1),
                                ],
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {},
                            child: Container(
                              child: RichText(
                                text: TextSpan(
                                    text: _answercount[index].toString(),
                                    style: TextStyle(
                                      fontFamily: 'Nunito Sans',
                                      color: Color.fromRGBO(205, 61, 61, 1),
                                    ),
                                    children: <TextSpan>[
                                      TextSpan(
                                        text: ' Answers',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: dark,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                                    ]),
                              ),
                            ),
                          ),
                          Container(
                            child: Row(
                              children: [
                                Text(
                                  (_examlikelyhoodcount[index] +
                                          _toughnesscount[index])
                                      .toString(),
                                  style: TextStyle(
                                      fontFamily: 'Nunito Sans',
                                      color: Color.fromRGBO(205, 61, 61, 1)),
                                ),
                                SizedBox(
                                  width: 2,
                                ),
                                Icon(Entypo.gauge,
                                    color: Color.fromRGBO(0, 0, 0, 0.8),
                                    size: 13),
                                SizedBox(
                                  width: 4,
                                ),
                                Text(
                                  allQuestionsData[index]["view_count"]
                                      .toString(),
                                  style: TextStyle(
                                      fontFamily: 'Nunito Sans',
                                      color: Color.fromRGBO(205, 61, 61, 1)),
                                ),
                                SizedBox(
                                  width: 4,
                                ),
                                Icon(FontAwesome5.eye,
                                    color: Color.fromRGBO(0, 0, 0, 0.8),
                                    size: 12),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    Visibility(
                      visible: likebutton[index],
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [_showQuestionLikedDialog(index)],
                      ),
                    ),
                    Container(
                        margin: EdgeInsets.only(left: 2, right: 2, top: 5),
                        color: Colors.black.withOpacity(0.2),
                        height: 0.5,
                        width: MediaQuery.of(context).size.width),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                            icon: Icon(
                                (questionlikedLocalDB!.get(allQuestionsData[index]["question_id"]) ==
                                        "like")
                                    ? FontAwesome5.thumbs_up
                                    : (questionmarkedimpLocalDB!.get(allQuestionsData[index]
                                                ["question_id"]) ==
                                            "markasimp")
                                        ? Icons.done_all
                                        : (questionmydoubttooLocalDB!.get(
                                                    allQuestionsData[index]
                                                        ["question_id"]) ==
                                                "mydoubttoo")
                                            ? Icons.pan_tool
                                            : FontAwesome5.thumbs_up,
                                color: ((questionlikedLocalDB!.get(allQuestionsData[index]["question_id"]) == "like") ||
                                        (questionmarkedimpLocalDB!.get(
                                                allQuestionsData[index]
                                                    ["question_id"]) ==
                                            "markasimp") ||
                                        (questionmydoubttooLocalDB!
                                                .get(allQuestionsData[index]["question_id"]) ==
                                            "mydoubttoo"))
                                    ? Color(0xff0962ff)
                                    : Color.fromRGBO(0, 0, 0, 0.8),
                                size: 14),
                            onPressed: () {
                              setState(() {
                                likebutton[index] = !likebutton[index];
                                likebuttonpopupremove.add(index);
                              });
                            }),
                        IconButton(
                            icon: Icon(FontAwesome5.share,
                                color: Color.fromRGBO(0, 0, 0, 0.8), size: 14),
                            onPressed: () {
                              _shareQuestionPostDialog(index);
                            }),
                        IconButton(
                            icon: Icon(FontAwesome5.edit,
                                color: Color.fromRGBO(0, 0, 0, 0.8), size: 14),
                            onPressed: () {
                              setState(() {
                                latex = "";
                                answer = "";
                              });
                              _addAnswerPostDialog(index);
                            }),
                        IconButton(
                            icon: Icon(Entypo.gauge,
                                color: ((questionexamlikelyhoodLocalDB!.get(allQuestionsData[index]["question_id"]) ==
                                            "low") ||
                                        (questionexamlikelyhoodLocalDB!.get(
                                                allQuestionsData[index]
                                                    ["question_id"]) ==
                                            "moderate") ||
                                        (questionexamlikelyhoodLocalDB!.get(
                                                allQuestionsData[index]
                                                    ["question_id"]) ==
                                            "high") ||
                                        (questiontoughnessLocalDB!.get(allQuestionsData[index]["question_id"]) ==
                                            "low") ||
                                        (questiontoughnessLocalDB!.get(allQuestionsData[index]["question_id"]) ==
                                            "medium") ||
                                        (questiontoughnessLocalDB!
                                                .get(allQuestionsData[index]["question_id"]) ==
                                            "high"))
                                    ? Color(0xff0962ff)
                                    : Color.fromRGBO(0, 0, 0, 0.8),
                                size: 15),
                            onPressed: () {
                              setState(() {
                                likebutton[index] = false;
                                _showExamlikelihoodAndToughnessDialog(index);
                              });
                            }),
                        IconButton(
                            icon: Icon(FontAwesome5.ellipsis_v,
                                color: Color.fromRGBO(0, 0, 0, 0.8), size: 13),
                            onPressed: () {
                              setState(() {
                                likebutton[index] = false;
                              });
                              if (_currentUserId ==
                                  allQuestionsData[index]["user_id"]) {
                                MoreButtonForUser(index);
                              } else {
                                MoreButtonForViewer(index);
                              }
                            }),
                      ],
                    ),
                    Container(
                        margin: EdgeInsets.only(left: 2, right: 2, top: 5),
                        color: Colors.black.withOpacity(0.2),
                        height: 0.5,
                        width: MediaQuery.of(context).size.width),
                    SizedBox(height: 10),
                    _answerView(index)
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // this is button to show more options  of questions for other users
  MoreButtonForViewer(int i) {
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
                          SizedBox(width: 30),
                          Text(
                            "Options",
                            style: TextStyle(
                              fontSize: 20,
                              color: Color(0xCB000000),
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: Tab(
                                child: Icon(Icons.cancel_rounded,
                                    color: Colors.black45, size: 25)),
                          )
                        ],
                      ),
                      SizedBox(height: 20),
                      Container(height: 1, width: 500, color: Colors.grey[200]),
                    ],
                  ),
                  content: Container(
                    height: 300,
                    width: 500,
                    margin: EdgeInsets.only(left: 2, right: 2),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10)),
                      color: Colors.white,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: ListView(
                        physics: BouncingScrollPhysics(),
                        children: [
                          ExpandablePanel(
                            collapsed: SizedBox(),
                            header: Container(
                              height: 50,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.report_outlined,
                                    color: Colors.redAccent,
                                    size: 30,
                                  ),
                                  SizedBox(
                                    width: 12,
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Report',
                                        style: TextStyle(
                                          fontFamily: 'Nunito Sans',
                                          fontSize: 14,
                                          color: Colors.black87,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      SizedBox(
                                        height: 2,
                                      ),
                                      Text(
                                        'Report if irrelevant or having abusive content',
                                        style: TextStyle(
                                          fontFamily: 'Nunito Sans',
                                          fontSize: 11,
                                          color: Colors.black45,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      )
                                    ],
                                  )
                                ],
                              ),
                            ),
                            expanded: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                InkWell(
                                  onTap: () {},
                                  child: Container(
                                    decoration: BoxDecoration(
                                        border:
                                            Border.all(color: Colors.black12),
                                        borderRadius: BorderRadius.circular(3)),
                                    margin: EdgeInsets.all(2),
                                    padding: EdgeInsets.all(6),
                                    child: Center(
                                      child: Text(
                                        'Irrelevant',
                                        style: TextStyle(
                                          fontFamily: 'Nunito Sans',
                                          fontSize: 12,
                                          color: ("" == "irrelevant")
                                              ? Color(0xff0962ff)
                                              : Colors.black87,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () {},
                                  child: Container(
                                    decoration: BoxDecoration(
                                        border:
                                            Border.all(color: Colors.black12),
                                        borderRadius: BorderRadius.circular(3)),
                                    margin: EdgeInsets.all(2),
                                    padding: EdgeInsets.all(6),
                                    child: Center(
                                      child: Text(
                                        'Mark as a wrong question',
                                        style: TextStyle(
                                          fontFamily: 'Nunito Sans',
                                          fontSize: 12,
                                          color: ("" == "markaswrong")
                                              ? Color(0xff0962ff)
                                              : Colors.black87,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () {},
                                  child: Container(
                                    decoration: BoxDecoration(
                                        border:
                                            Border.all(color: Colors.black12),
                                        borderRadius: BorderRadius.circular(3)),
                                    margin: EdgeInsets.all(2),
                                    padding: EdgeInsets.all(6),
                                    child: Center(
                                      child: Text(
                                        'Abuse',
                                        style: TextStyle(
                                          fontFamily: 'Nunito Sans',
                                          fontSize: 12,
                                          color: ("" == "abuse")
                                              ? Color(0xff0962ff)
                                              : Colors.black87,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          InkWell(
                            onTap: () async {
                              if (allQuestionWiseSavedOrNot[i] == false) {
                                bool check = await dataLoad.addQuestionSaved([
                                  _currentUserId,
                                  allQuestionsData[i]["question_id"],
                                  comparedate
                                ]);
                                if (check = true) {
                                  setState(() {
                                    allQuestionWiseSavedOrNot[i] = true;
                                  });
                                }
                                ElegantNotification.success(
                                        title: Text("Saved!"),
                                        description:
                                            Text("Post is saved successfully."))
                                    .show(context);
                                Navigator.of(context).pop();
                              } else if (allQuestionWiseSavedOrNot[i] == true) {
                                bool check = await dataLoad
                                    .deleteQuestionSaved([
                                  _currentUserId,
                                  allQuestionsData[i]["question_id"]
                                ]);
                                if (check = true) {
                                  setState(() {
                                    allQuestionWiseSavedOrNot[i] = false;
                                  });
                                }
                                Navigator.of(context).pop();
                              }
                            },
                            child: Container(
                              height: 65,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.arrow_downward_rounded,
                                    color: allQuestionWiseSavedOrNot[i] != true
                                        ? Colors.black87
                                        : Color(0xff0962ff),
                                    size: 30,
                                  ),
                                  SizedBox(
                                    width: 12,
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Save',
                                        style: TextStyle(
                                          fontFamily: 'Nunito Sans',
                                          fontSize: 14,
                                          color: allQuestionWiseSavedOrNot[i] !=
                                                  true
                                              ? Colors.black87
                                              : Color(0xff0962ff),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      SizedBox(
                                        height: 2,
                                      ),
                                      Text(
                                        'Save this item for later',
                                        style: TextStyle(
                                          fontFamily: 'Nunito Sans',
                                          fontSize: 11,
                                          color: allQuestionWiseSavedOrNot[i] !=
                                                  true
                                              ? Colors.black45
                                              : Color(0xff0962ff),
                                          fontWeight: FontWeight.w400,
                                        ),
                                      )
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () async {
                              if (allQuestionWiseBookmarkedOrNot[i] == false) {
                                bool check = await dataLoad
                                    .addQuestionBookmarked([
                                  _currentUserId,
                                  allQuestionsData[i]["question_id"],
                                  comparedate
                                ]);
                                if (check = true) {
                                  setState(() {
                                    allQuestionWiseBookmarkedOrNot[i] = true;
                                  });
                                }
                                ElegantNotification.success(
                                    title: Text("Bookmarked!"),
                                    description:
                                        Text("Post is bookmarked successfully."));
                                Navigator.of(context).pop();
                              } else if (allQuestionWiseBookmarkedOrNot[i] ==
                                  true) {
                                bool check = await dataLoad
                                    .deleteQuestionBookmarked([
                                  _currentUserId,
                                  allQuestionsData[i]["question_id"]
                                ]);
                                if (check = true) {
                                  setState(() {
                                    allQuestionWiseBookmarkedOrNot[i] = false;
                                  });
                                }
                                Navigator.of(context).pop();
                              }
                            },
                            child: Container(
                              height: 65,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.bookmark_border,
                                    color: allQuestionWiseBookmarkedOrNot[i] !=
                                            true
                                        ? Colors.black87
                                        : Color(0xff0962ff),
                                    size: 30,
                                  ),
                                  SizedBox(
                                    width: 12,
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Bookmark',
                                        style: TextStyle(
                                          fontFamily: 'Nunito Sans',
                                          fontSize: 14,
                                          color: allQuestionWiseBookmarkedOrNot[
                                                      i] !=
                                                  true
                                              ? Colors.black87
                                              : Color(0xff0962ff),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      SizedBox(
                                        height: 2,
                                      ),
                                      Text(
                                        'Bookmark this to get follow up on the solution',
                                        style: TextStyle(
                                          fontFamily: 'Nunito Sans',
                                          fontSize: 11,
                                          color: allQuestionWiseBookmarkedOrNot[
                                                      i] !=
                                                  true
                                              ? Colors.black45
                                              : Color(0xff0962ff),
                                          fontWeight: FontWeight.w400,
                                        ),
                                      )
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {},
                            child: Container(
                              height: 65,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.book_outlined,
                                    color: false != true
                                        ? Colors.black87
                                        : Color(0xff0962ff),
                                    size: 30,
                                  ),
                                  SizedBox(
                                    width: 12,
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Ask reference',
                                        style: TextStyle(
                                          fontFamily: 'Nunito Sans',
                                          fontSize: 14,
                                          color: false != true
                                              ? Colors.black87
                                              : Color(0xff0962ff),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      SizedBox(
                                        height: 2,
                                      ),
                                      Text(
                                        'Ask reference of this question',
                                        style: TextStyle(
                                          fontFamily: 'Nunito Sans',
                                          fontSize: 11,
                                          color: false != true
                                              ? Colors.black45
                                              : Color(0xff0962ff),
                                          fontWeight: FontWeight.w400,
                                        ),
                                      )
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ));
            }));
  }

// this is button to show more options  of questions for the person who posted the question
  MoreButtonForUser(int i) {
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
                          SizedBox(width: 30),
                          Text(
                            "Options",
                            style: TextStyle(
                              fontSize: 20,
                              color: Color(0xCB000000),
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: Tab(
                                child: Icon(Icons.cancel_rounded,
                                    color: Colors.black45, size: 25)),
                          )
                        ],
                      ),
                      SizedBox(height: 20),
                      Container(height: 1, width: 500, color: Colors.grey[200]),
                    ],
                  ),
                  content: Container(
                    height: 100,
                    width: 500,
                    margin: EdgeInsets.only(left: 2, right: 2),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10)),
                      color: Colors.white,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: ListView(
                        physics: BouncingScrollPhysics(),
                        children: [
                          InkWell(
                            onTap: () {},
                            child: Container(
                              height: 65,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.edit,
                                    color: Colors.black87,
                                    size: 30,
                                  ),
                                  SizedBox(
                                    width: 12,
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Edit',
                                        style: TextStyle(
                                          fontFamily: 'Nunito Sans',
                                          fontSize: 14,
                                          color: Colors.black87,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      SizedBox(
                                        height: 2,
                                      ),
                                      Text(
                                        'Edit the question or add more relative reference.',
                                        style: TextStyle(
                                          fontFamily: 'Nunito Sans',
                                          fontSize: 11,
                                          color: Colors.black45,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      )
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ));
            }));
  }

  void tapCallbackHandler(String i) {}
//show answer
  _answerView(int qIndex) {
    int ansSelectID = -1;
    for (int i = 0; i < allAnswerQuestionID.length; i++) {
      if (allAnswerQuestionID[i] == allQuestionsData[qIndex]["question_id"]) {
        ansSelectID = i;
      }
    }

    return ansSelectID != -1
        ? Column(
            children: [
              SizedBox(height: 5),
              allAnswersQIDwise[ansSelectID].length > 1
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        InkWell(
                          onTap: () {
                            setState(() {
                              allAnswersQIDwisebool[qIndex] =
                                  !allAnswersQIDwisebool[qIndex];
                            });
                          },
                          child: Container(
                            child: Text(
                                allAnswersQIDwisebool[qIndex] == true
                                    ? "Hide answers"
                                    : "View ${allAnswersQIDwise[ansSelectID].length - 1} more answers",
                                style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black.withOpacity(0.6),
                                    fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    )
                  : SizedBox(),
              SizedBox(height: 5),
              Container(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: allAnswersQIDwisebool[qIndex] == true
                      ? allAnswersQIDwise[ansSelectID].length
                      : 1,
                  itemBuilder: (context, index) {
                    DateTime tempDate = DateTime.parse(
                        allAnswersQIDwise[ansSelectID][index]["compare_date"]
                            .toString()
                            .substring(0, 8));
                    String current_date =
                        DateFormat.yMMMMd('en_US').format(tempDate);
                    return Container(
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
                                    allAnswersQIDwise[ansSelectID][index]
                                            ["profilepic"]
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          allAnswersQIDwise[ansSelectID][index]
                                                      ["first_name"]
                                                  .toString() +
                                              " " +
                                              allAnswersQIDwise[ansSelectID]
                                                      [index]["last_name"]
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          allAnswersQIDwise[ansSelectID][index]
                                                      ["school_name"]
                                                  .toString() +
                                              " | Grade " +
                                              allAnswersQIDwise[ansSelectID]
                                                      [index]["grade"]
                                                  .toString(),
                                          style: TextStyle(
                                              color: Colors.black54,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w400),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
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
                                    allAnswersQIDwise[ansSelectID][index]
                                                    ["answer_type"]
                                                .toString() ==
                                            "text"
                                        ? InkWell(
                                            onTap: () {
                                              setState(() {
                                                isANSExpand[ansSelectID]
                                                        [index] =
                                                    !isANSExpand[ansSelectID]
                                                        [index];
                                              });
                                            },
                                            child: ReadMoreText(
                                              allAnswersQIDwise[ansSelectID]
                                                              [index]["answer"]
                                                          .toString()
                                                          .length >
                                                      40
                                                  ? isANSExpand[ansSelectID]
                                                              [index] ==
                                                          false
                                                      ? allAnswersQIDwise[ansSelectID]
                                                                      [index]
                                                                  ["answer"]
                                                              .toString()
                                                              .substring(
                                                                  0, 40) +
                                                          "......"
                                                      : allAnswersQIDwise[
                                                                  ansSelectID]
                                                              [index]["answer"]
                                                          .toString()
                                                  : allAnswersQIDwise[ansSelectID]
                                                          [index]["answer"]
                                                      .toString(),
                                              trimLines: 2,
                                              colorClickableText:
                                                  Color(0xff0962ff),
                                              trimMode: TrimMode.Line,
                                              trimCollapsedText: 'read more',
                                              trimExpandedText: 'Show less',
                                              style: const TextStyle(
                                                  color: Color.fromRGBO(
                                                      0, 0, 0, 0.8),
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w500),
                                              lessStyle: const TextStyle(
                                                  color: Color.fromRGBO(
                                                      0, 0, 0, 0.8),
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w500),
                                              moreStyle: const TextStyle(
                                                  color: Color.fromRGBO(
                                                      0, 0, 0, 0.8),
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                          )
                                        : allAnswersQIDwise[ansSelectID][index]
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
                                                      loadingWidgetBuilder:
                                                          (context) {
                                                        return Container(
                                                          width: 280,
                                                          child:
                                                              PlaceholderLines(
                                                            count: 2,
                                                            animate: true,
                                                            color: active,
                                                          ),
                                                        );
                                                      },
                                                      child: TeXViewColumn(
                                                          children: [
                                                            TeXViewInkWell(
                                                              id: "$qIndex",
                                                              onTap:
                                                                  tapCallbackHandler,
                                                              child: TeXViewDocument(
                                                                  allAnswersQIDwise[
                                                                              ansSelectID]
                                                                          [
                                                                          index]
                                                                      [
                                                                      "answer"],
                                                                  style:
                                                                      TeXViewStyle(
                                                                    fontStyle: TeXViewFontStyle(
                                                                        fontFamily:
                                                                            'Nunito Sans',
                                                                        fontWeight:
                                                                            TeXViewFontWeight
                                                                                .w400,
                                                                        fontSize:
                                                                            10,
                                                                        sizeUnit:
                                                                            TeXViewSizeUnit.pt),
                                                                    padding:
                                                                        TeXViewPadding
                                                                            .all(5),
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
                                                      allAnswersQIDwise[
                                                                  ansSelectID]
                                                              [index]["answer"]
                                                          .toString(),
                                                      height: 300,
                                                      fit: BoxFit.fill),
                                                ),
                                              )
                                  ],
                                ),
                              ),
                              Visibility(
                                visible: likebuttonAns[ansSelectID][index],
                                child: Container(
                                  padding: EdgeInsets.only(top: 5, bottom: 5),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      _showAnswerLikedDialog(
                                          qIndex, ansSelectID, index)
                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(1.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        likebuttonAns[ansSelectID][index] =
                                            !likebuttonAns[ansSelectID][index];
                                      },
                                      child: Text(
                                        "Like",
                                        style: TextStyle(
                                            color: ((answerlikedLocalDB!.get(allAnswersQIDwise[ansSelectID]
                                                                [index]
                                                            ["answer_id"]) ==
                                                        "like") ||
                                                    (answerlikedLocalDB!.get(allAnswersQIDwise[ansSelectID]
                                                                [index]
                                                            ["answer_id"]) ==
                                                        "markasimp") ||
                                                    (answerlikedLocalDB!.get(
                                                            allAnswersQIDwise[ansSelectID]
                                                                    [index]
                                                                ["answer_id"]) ==
                                                        "helpful"))
                                                ? Color(0xff0962ff)
                                                : Colors.black54,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                      " " +
                                          likeCountAns[ansSelectID][index]
                                              .toString() +
                                          " ",
                                      style: TextStyle(
                                          color: Colors.black54,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400),
                                    ),
                                    Icon(Entypo.thumbs_up,
                                        color: Color.fromRGBO(0, 0, 0, 0.8),
                                        size: 14),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                      " | ",
                                      style: TextStyle(
                                          color: Colors.black54,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700),
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    InkWell(
                                      onTap: () {
                                        _addCommentPostDialog(
                                            qIndex, ansSelectID, index);
                                      },
                                      child: Text(
                                        "Comments",
                                        style: TextStyle(
                                            color: Colors.black54,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                      " " +
                                          commentCountAns[ansSelectID][index]
                                              .toString() +
                                          " ",
                                      style: TextStyle(
                                          color: Colors.black54,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400),
                                    ),
                                    Icon(Icons.chat,
                                        color: Color.fromRGBO(0, 0, 0, 0.8),
                                        size: 14),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                      " | ",
                                      style: TextStyle(
                                          color: Colors.black54,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700),
                                    ),
                                    IconButton(
                                      padding: EdgeInsets.all(0),
                                      icon: Icon(Typicons.up_outline,
                                          color: (answervotesLocalDB!.get(
                                                      allAnswersQIDwise[
                                                                  ansSelectID]
                                                              [index]
                                                          ["answer_id"]) ==
                                                  "upvote")
                                              ? Color(0xff0962ff)
                                              : Color.fromRGBO(0, 0, 0, 0.8),
                                          size: 14),
                                      onPressed: () {
                                        if ((answervotesLocalDB!.get(
                                                allAnswersQIDwise[ansSelectID]
                                                    [index]["answer_id"]) ==
                                            "downvote")) {
                                          dataLoad.updateAnswerCountData([
                                            allAnswersQIDwise[ansSelectID]
                                                [index]["answer_id"],
                                            _currentUserId,
                                            commentCountAns[ansSelectID][index],
                                            likeCountAns[ansSelectID][index],
                                            upvoteCountAns[ansSelectID][index] +
                                                1,
                                            downVoteCountAns[ansSelectID]
                                                    [index] -
                                                1
                                          ]);
                                          setState(() {
                                            downVoteCountAns[ansSelectID]
                                                    [index] =
                                                downVoteCountAns[ansSelectID]
                                                        [index] -
                                                    1;
                                            upvoteCountAns[ansSelectID][index] =
                                                upvoteCountAns[ansSelectID]
                                                        [index] +
                                                    1;
                                          });
                                          answervotesLocalDB!.put(
                                              allAnswersQIDwise[ansSelectID]
                                                  [index]["answer_id"],
                                              "upvote");
                                        } else if ((answervotesLocalDB!.get(
                                                allAnswersQIDwise[ansSelectID]
                                                    [index]["answer_id"]) ==
                                            "upvote")) {
                                          dataLoad.updateAnswerCountData([
                                            allAnswersQIDwise[ansSelectID]
                                                [index]["answer_id"],
                                            _currentUserId,
                                            commentCountAns[ansSelectID][index],
                                            likeCountAns[ansSelectID][index],
                                            upvoteCountAns[ansSelectID][index] -
                                                1,
                                            downVoteCountAns[ansSelectID][index]
                                          ]);
                                          setState(() {
                                            upvoteCountAns[ansSelectID][index] =
                                                upvoteCountAns[ansSelectID]
                                                        [index] -
                                                    1;
                                          });
                                          answervotesLocalDB!.delete(
                                              allAnswersQIDwise[ansSelectID]
                                                  [index]["answer_id"]);
                                        } else {
                                          setState(() {
                                            upvoteCountAns[ansSelectID][index] =
                                                upvoteCountAns[ansSelectID]
                                                        [index] +
                                                    1;
                                          });
                                          dataLoad.updateAnswerCountData([
                                            allAnswersQIDwise[ansSelectID]
                                                [index]["answer_id"],
                                            _currentUserId,
                                            commentCountAns[ansSelectID][index],
                                            likeCountAns[ansSelectID][index],
                                            upvoteCountAns[ansSelectID][index] +
                                                1,
                                            downVoteCountAns[ansSelectID][index]
                                          ]);
                                          answervotesLocalDB!.put(
                                              allAnswersQIDwise[ansSelectID]
                                                  [index]["answer_id"],
                                              "upvote");
                                        }
                                      },
                                    ),
                                    Text(
                                      " " +
                                          upvoteCountAns[ansSelectID][index]
                                              .toString() +
                                          " ",
                                      style: TextStyle(
                                          color: Colors.black54,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400),
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                      " | ",
                                      style: TextStyle(
                                          color: Colors.black54,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700),
                                    ),
                                    IconButton(
                                      padding: EdgeInsets.all(0),
                                      icon: Icon(Typicons.down_outline,
                                          color: (answervotesLocalDB!.get(
                                                      allAnswersQIDwise[
                                                                  ansSelectID]
                                                              [index]
                                                          ["answer_id"]) ==
                                                  "downvote")
                                              ? Color(0xff0962ff)
                                              : Color.fromRGBO(0, 0, 0, 0.8),
                                          size: 14),
                                      onPressed: () {
                                        if (answervotesLocalDB!.get(
                                                allAnswersQIDwise[ansSelectID]
                                                    [index]["answer_id"]) ==
                                            "upvote") {
                                          setState(() {
                                            upvoteCountAns[ansSelectID][index] =
                                                upvoteCountAns[ansSelectID]
                                                        [index] -
                                                    1;

                                            downVoteCountAns[ansSelectID]
                                                    [index] =
                                                downVoteCountAns[ansSelectID]
                                                        [index] +
                                                    1;
                                          });
                                          dataLoad.updateAnswerCountData([
                                            allAnswersQIDwise[ansSelectID]
                                                [index]["answer_id"],
                                            _currentUserId,
                                            commentCountAns[ansSelectID][index],
                                            likeCountAns[ansSelectID][index],
                                            upvoteCountAns[ansSelectID][index] -
                                                1,
                                            downVoteCountAns[ansSelectID]
                                                    [index] +
                                                1
                                          ]);
                                          answervotesLocalDB!.put(
                                              allAnswersQIDwise[ansSelectID]
                                                  [index]["answer_id"],
                                              "downvote");
                                        } else if (answervotesLocalDB!.get(
                                                allAnswersQIDwise[ansSelectID]
                                                    [index]["answer_id"]) ==
                                            "downvote") {
                                          setState(() {
                                            downVoteCountAns[ansSelectID]
                                                    [index] =
                                                downVoteCountAns[ansSelectID]
                                                        [index] -
                                                    1;
                                          });
                                          dataLoad.updateAnswerCountData([
                                            allAnswersQIDwise[ansSelectID]
                                                [index]["answer_id"],
                                            _currentUserId,
                                            commentCountAns[ansSelectID][index],
                                            likeCountAns[ansSelectID][index],
                                            upvoteCountAns[ansSelectID][index],
                                            downVoteCountAns[ansSelectID]
                                                    [index] -
                                                1
                                          ]);
                                          answervotesLocalDB!.delete(
                                              allAnswersQIDwise[ansSelectID]
                                                  [index]["answer_id"]);
                                        } else {
                                          setState(() {
                                            downVoteCountAns[ansSelectID]
                                                    [index] =
                                                downVoteCountAns[ansSelectID]
                                                        [index] +
                                                    1;
                                          });
                                          dataLoad.updateAnswerCountData([
                                            allAnswersQIDwise[ansSelectID]
                                                [index]["answer_id"],
                                            _currentUserId,
                                            commentCountAns[ansSelectID][index],
                                            likeCountAns[ansSelectID][index],
                                            upvoteCountAns[ansSelectID][index],
                                            downVoteCountAns[ansSelectID]
                                                    [index] +
                                                1
                                          ]);
                                          answervotesLocalDB!.put(
                                              allAnswersQIDwise[ansSelectID]
                                                  [index]["answer_id"],
                                              "downvote");
                                        }
                                      },
                                    ),
                                    Text(
                                      " " +
                                          downVoteCountAns[ansSelectID][index]
                                              .toString() +
                                          " ",
                                      style: TextStyle(
                                          color: Colors.black54,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400),
                                    ),
                                  ],
                                ),
                              ),
                              _comment(qIndex, ansSelectID, index)
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          )
        : SizedBox();
  }

  _showAnswerLikedDialog(int qIndex, int ansSelectID, int ansIndex) {
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
                  decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.all(Radius.circular(5))),
                  message: "Like",
                  child: IconButton(
                    icon: Icon(FontAwesome5.thumbs_up,
                        size: 15,
                        color: (answerlikedLocalDB!.get(
                                    allAnswersQIDwise[ansSelectID][ansIndex]
                                        ["answer_id"]) ==
                                "like")
                            ? Color(0xff0962ff)
                            : Color(0xff0C2551)),
                    onPressed: () async {
                      if ((answerlikedLocalDB!.get(
                              allAnswersQIDwise[ansSelectID][ansIndex]
                                  ["answer_id"]) ==
                          "like")) {
                        answerlikedLocalDB!.delete(
                            allAnswersQIDwise[ansSelectID][ansIndex]
                                ["answer_id"]);

                        setState(() {
                          print(likeCountAns[ansSelectID][ansIndex]);
                          likeCountAns[ansSelectID][ansIndex] =
                              likeCountAns[ansSelectID][ansIndex] - 1;
                        });
                        dataLoad.updateAnswerCountData([
                          allAnswersQIDwise[ansSelectID][ansIndex]["answer_id"],
                          _currentUserId,
                          commentCountAns[ansSelectID][ansIndex],
                          likeCountAns[ansSelectID][ansIndex] - 1,
                          upvoteCountAns[ansSelectID][ansIndex],
                          downVoteCountAns[ansSelectID][ansIndex]
                        ]);
                        ////////////////////////////notification//////////////////////////////////////
                        String notify_id =
                            "ntf${allAnswersQIDwise[ansSelectID][ansIndex]["answer_id"]}$comparedate";
                        notifyCRUD.sendNotification([
                          notify_id,
                          "reaction",
                          "answer",
                          _currentUserId,
                          allAnswersQIDwise[ansSelectID][ansIndex]["user_id"],
                          countData!.value["usertoken"][
                              allAnswersQIDwise[ansSelectID][ansIndex]
                                  ["user_id"]]["tokenid"],
                          "You got one like!",
                          "${userDataDB!.get("first_name")} ${userDataDB!.get("last_name")} liked your answer.",
                          allQuestionsData[qIndex]["question_id"],
                          "question",
                          "false",
                          comparedate,
                          "deelte"
                        ]);
                        //////////////////////////////////////////////////////////////////////////
                      } else if ((answerlikedLocalDB!.get(
                                  allAnswersQIDwise[ansSelectID][ansIndex]
                                      ["answer_id"]) ==
                              "markasimp") ||
                          (answerlikedLocalDB!.get(
                                  allAnswersQIDwise[ansSelectID][ansIndex]
                                      ["answer_id"]) ==
                              "helpful")) {
                        answerlikedLocalDB!.put(
                            allAnswersQIDwise[ansSelectID][ansIndex]
                                ["answer_id"],
                            "like");
                      } else {
                        answerlikedLocalDB!.put(
                            allAnswersQIDwise[ansSelectID][ansIndex]
                                ["answer_id"],
                            "like");
                        setState(() {
                          print(likeCountAns[ansSelectID][ansIndex]);
                          likeCountAns[ansSelectID][ansIndex] =
                              likeCountAns[ansSelectID][ansIndex] + 1;
                        });
                        dataLoad.updateAnswerCountData([
                          allAnswersQIDwise[ansSelectID][ansIndex]["answer_id"],
                          _currentUserId,
                          commentCountAns[ansSelectID][ansIndex],
                          likeCountAns[ansSelectID][ansIndex] + 1,
                          upvoteCountAns[ansSelectID][ansIndex],
                          downVoteCountAns[ansSelectID][ansIndex]
                        ]);
                        ////////////////////////////notification//////////////////////////////////////
                        String notify_id =
                            "ntf${allAnswersQIDwise[ansSelectID][ansIndex]["answer_id"]}$comparedate";
                        notifyCRUD.sendNotification([
                          notify_id,
                          "reaction",
                          "answer",
                          _currentUserId,
                          allAnswersQIDwise[ansSelectID][ansIndex]["user_id"],
                          countData!.value["usertoken"][
                              allAnswersQIDwise[ansSelectID][ansIndex]
                                  ["user_id"]]["tokenid"],
                          "You got one like!",
                          "${userDataDB!.get("first_name")} ${userDataDB!.get("last_name")} liked your answer.",
                          allQuestionsData[qIndex]["question_id"],
                          "question",
                          "false",
                          comparedate,
                          "add"
                        ]);
                        //////////////////////////////////////////////////////////////////////////
                      }
                      likebuttonAns[ansSelectID][ansIndex] =
                          !likebuttonAns[ansSelectID][ansIndex];
                    },
                  ),
                ),
                // SizedBox(width:),
                Tooltip(
                  preferBelow: false,
                  decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.all(Radius.circular(5))),
                  message: "Mark As Important",
                  child: IconButton(
                    icon: Icon(Icons.done_all,
                        size: 15,
                        color: answermarkasimpLocalDB!.get(
                                    allAnswersQIDwise[ansSelectID][ansIndex]
                                        ["answer_id"]) ==
                                "markasimp"
                            ? Color(0xff0962ff)
                            : Color(0xff0C2551)),
                    onPressed: () async {
                      if ((answerlikedLocalDB!.get(
                              allAnswersQIDwise[ansSelectID][ansIndex]
                                  ["answer_id"]) ==
                          "markasimp")) {
                        ////////////////////////////notification//////////////////////////////////////
                        String notify_id =
                            "ntf${allAnswersQIDwise[ansSelectID][ansIndex]["answer_id"]}$comparedate";
                        notifyCRUD.sendNotification([
                          notify_id,
                          "reaction",
                          "answer",
                          _currentUserId,
                          allAnswersQIDwise[ansSelectID][ansIndex]["user_id"],
                          countData!.value["usertoken"][
                              allAnswersQIDwise[ansSelectID][ansIndex]
                                  ["user_id"]]["tokenid"],
                          "You got one reaction!",
                          "${userDataDB!.get("first_name")} ${userDataDB!.get("last_name")} marked your answer as important.",
                          allQuestionsData[qIndex]["question_id"],
                          "question",
                          "false",
                          comparedate,
                          "delete"
                        ]);
                        //////////////////////////////////////////////////////////////////////////
                        answerlikedLocalDB!.delete(
                            allAnswersQIDwise[ansSelectID][ansIndex]
                                ["answer_id"]);

                        setState(() {
                          print(likeCountAns[ansSelectID][ansIndex]);
                          likeCountAns[ansSelectID][ansIndex] =
                              likeCountAns[ansSelectID][ansIndex] - 1;
                        });
                        dataLoad.updateAnswerCountData([
                          allAnswersQIDwise[ansSelectID][ansIndex]["answer_id"],
                          _currentUserId,
                          commentCountAns[ansSelectID][ansIndex],
                          likeCountAns[ansSelectID][ansIndex] - 1,
                          upvoteCountAns[ansSelectID][ansIndex],
                          downVoteCountAns[ansSelectID][ansIndex]
                        ]);
                      } else if ((answerlikedLocalDB!.get(
                                  allAnswersQIDwise[ansSelectID][ansIndex]
                                      ["answer_id"]) ==
                              "like") ||
                          (answerlikedLocalDB!.get(
                                  allAnswersQIDwise[ansSelectID][ansIndex]
                                      ["answer_id"]) ==
                              "helpful")) {
                        answerlikedLocalDB!.put(
                            allAnswersQIDwise[ansSelectID][ansIndex]
                                ["answer_id"],
                            "markasimp");
                        ////////////////////////////notification//////////////////////////////////////
                        String notify_id =
                            "ntf${allAnswersQIDwise[ansSelectID][ansIndex]["answer_id"]}$comparedate";
                        notifyCRUD.sendNotification([
                          notify_id,
                          "reaction",
                          "answer",
                          _currentUserId,
                          allAnswersQIDwise[ansSelectID][ansIndex]["user_id"],
                          countData!.value["usertoken"][
                              allAnswersQIDwise[ansSelectID][ansIndex]
                                  ["user_id"]]["tokenid"],
                          "You got one reaction!",
                          "${userDataDB!.get("first_name")} ${userDataDB!.get("last_name")} marked your answer as important.",
                          allQuestionsData[qIndex]["question_id"],
                          "question",
                          "false",
                          comparedate,
                          "add"
                        ]);
                        //////////////////////////////////////////////////////////////////////////
                      } else {
                        setState(() {
                          print(likeCountAns[ansSelectID][ansIndex]);
                          likeCountAns[ansSelectID][ansIndex] =
                              likeCountAns[ansSelectID][ansIndex] + 1;
                        });
                        dataLoad.updateAnswerCountData([
                          allAnswersQIDwise[ansSelectID][ansIndex]["answer_id"],
                          _currentUserId,
                          commentCountAns[ansSelectID][ansIndex],
                          likeCountAns[ansSelectID][ansIndex] + 1,
                          upvoteCountAns[ansSelectID][ansIndex],
                          downVoteCountAns[ansSelectID][ansIndex]
                        ]);
                        ////////////////////////////notification//////////////////////////////////////
                        String notify_id =
                            "ntf${allAnswersQIDwise[ansSelectID][ansIndex]["answer_id"]}$comparedate";
                        notifyCRUD.sendNotification([
                          notify_id,
                          "reaction",
                          "answer",
                          _currentUserId,
                          allAnswersQIDwise[ansSelectID][ansIndex]["user_id"],
                          countData!.value["usertoken"][
                              allAnswersQIDwise[ansSelectID][ansIndex]
                                  ["user_id"]]["tokenid"],
                          "You got one reaction!",
                          "${userDataDB!.get("first_name")} ${userDataDB!.get("last_name")} marked your answer as important.",
                          allQuestionsData[qIndex]["question_id"],
                          "question",
                          "false",
                          comparedate,
                          "add"
                        ]);
                        //////////////////////////////////////////////////////////////////////////
                        answerlikedLocalDB!.put(
                            allAnswersQIDwise[ansSelectID][ansIndex]
                                ["answer_id"],
                            "markasimp");
                      }
                      likebuttonAns[ansSelectID][ansIndex] =
                          !likebuttonAns[ansSelectID][ansIndex];
                    },
                  ),
                ),
                Tooltip(
                  preferBelow: false,
                  decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.all(Radius.circular(5))),
                  message: "Mark As Helpful",
                  child: IconButton(
                    icon: Icon(Icons.pan_tool,
                        size: 15,
                        color: answerhelpfulLocalDB!.get(
                                    allAnswersQIDwise[ansSelectID][ansIndex]
                                        ["answer_id"]) ==
                                "helpful"
                            ? Color(0xff0962ff)
                            : Color(0xff0C2551)),
                    onPressed: () async {
                      if ((answerlikedLocalDB!.get(
                              allAnswersQIDwise[ansSelectID][ansIndex]
                                  ["answer_id"]) ==
                          "helpful")) {
                        answerlikedLocalDB!.delete(
                            allAnswersQIDwise[ansSelectID][ansIndex]
                                ["answer_id"]);
                        ////////////////////////////notification//////////////////////////////////////
                        String notify_id =
                            "ntf${allAnswersQIDwise[ansSelectID][ansIndex]["answer_id"]}$comparedate";
                        notifyCRUD.sendNotification([
                          notify_id,
                          "reaction",
                          "answer",
                          _currentUserId,
                          allAnswersQIDwise[ansSelectID][ansIndex]["user_id"],
                          countData!.value["usertoken"][
                              allAnswersQIDwise[ansSelectID][ansIndex]
                                  ["user_id"]]["tokenid"],
                          "You got one reaction!",
                          "${userDataDB!.get("first_name")} ${userDataDB!.get("last_name")} marked your answer as helpful.",
                          allQuestionsData[qIndex]["question_id"],
                          "question",
                          "false",
                          comparedate,
                          "delete"
                        ]);
                        //////////////////////////////////////////////////////////////////////////
                        setState(() {
                          print(likeCountAns[ansSelectID][ansIndex]);
                          likeCountAns[ansSelectID][ansIndex] =
                              likeCountAns[ansSelectID][ansIndex] - 1;
                        });
                        dataLoad.updateAnswerCountData([
                          allAnswersQIDwise[ansSelectID][ansIndex]["answer_id"],
                          _currentUserId,
                          commentCountAns[ansSelectID][ansIndex],
                          likeCountAns[ansSelectID][ansIndex] - 1,
                          upvoteCountAns[ansSelectID][ansIndex],
                          downVoteCountAns[ansSelectID][ansIndex]
                        ]);
                      } else if ((answerlikedLocalDB!.get(
                                  allAnswersQIDwise[ansSelectID][ansIndex]
                                      ["answer_id"]) ==
                              "like") ||
                          (answerlikedLocalDB!.get(
                                  allAnswersQIDwise[ansSelectID][ansIndex]
                                      ["answer_id"]) ==
                              "markasimp")) {
                        answerlikedLocalDB!.put(
                            allAnswersQIDwise[ansSelectID][ansIndex]
                                ["answer_id"],
                            "helpful");
                        ////////////////////////////notification//////////////////////////////////////
                        String notify_id =
                            "ntf${allAnswersQIDwise[ansSelectID][ansIndex]["answer_id"]}$comparedate";
                        notifyCRUD.sendNotification([
                          notify_id,
                          "reaction",
                          "answer",
                          _currentUserId,
                          allAnswersQIDwise[ansSelectID][ansIndex]["user_id"],
                          countData!.value["usertoken"][
                              allAnswersQIDwise[ansSelectID][ansIndex]
                                  ["user_id"]]["tokenid"],
                          "You got one reaction!",
                          "${userDataDB!.get("first_name")} ${userDataDB!.get("last_name")} marked your answer as helpful.",
                          allQuestionsData[qIndex]["question_id"],
                          "question",
                          "false",
                          comparedate,
                          "add"
                        ]);
                        //////////////////////////////////////////////////////////////////////////
                      } else {
                        setState(() {
                          print(likeCountAns[ansSelectID][ansIndex]);
                          likeCountAns[ansSelectID][ansIndex] =
                              likeCountAns[ansSelectID][ansIndex] + 1;
                        });
                        ////////////////////////////notification//////////////////////////////////////
                        String notify_id =
                            "ntf${allAnswersQIDwise[ansSelectID][ansIndex]["answer_id"]}$comparedate";
                        notifyCRUD.sendNotification([
                          notify_id,
                          "reaction",
                          "answer",
                          _currentUserId,
                          allAnswersQIDwise[ansSelectID][ansIndex]["user_id"],
                          countData!.value["usertoken"][
                              allAnswersQIDwise[ansSelectID][ansIndex]
                                  ["user_id"]]["tokenid"],
                          "You got one reaction!",
                          "${userDataDB!.get("first_name")} ${userDataDB!.get("last_name")} marked your answer as helpful.",
                          allQuestionsData[qIndex]["question_id"],
                          "question",
                          "false",
                          comparedate,
                          "add"
                        ]);
                        //////////////////////////////////////////////////////////////////////////
                        dataLoad.updateAnswerCountData([
                          allAnswersQIDwise[ansSelectID][ansIndex]["answer_id"],
                          _currentUserId,
                          commentCountAns[ansSelectID][ansIndex],
                          likeCountAns[ansSelectID][ansIndex] + 1,
                          upvoteCountAns[ansSelectID][ansIndex],
                          downVoteCountAns[ansSelectID][ansIndex]
                        ]);
                        answerlikedLocalDB!.put(
                            allAnswersQIDwise[ansSelectID][ansIndex]
                                ["answer_id"],
                            "helpful");
                      }
                      likebuttonAns[ansSelectID][ansIndex] =
                          !likebuttonAns[ansSelectID][ansIndex];
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  //comment
  _comment(int qIndex, int ansSelectID, int ansIndex) {
    int cmntSelectID = -1;
    for (int i = 0; i < allAnscmntAnswerID.length; i++) {
      if (allAnscmntAnswerID[i] ==
          allAnswersQIDwise[ansSelectID][ansIndex]["answer_id"]) {
        cmntSelectID = i;
      }
    }
    return cmntSelectID != -1
        ? Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 5),
              allAnscmntANSIDwise[cmntSelectID].length > 1
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        InkWell(
                          onTap: () {
                            setState(() {
                              allAnscmntANSIDwisebool[ansSelectID] =
                                  !allAnscmntANSIDwisebool[ansSelectID];
                            });
                          },
                          child: Container(
                            child: Text(
                                allAnscmntANSIDwisebool[ansSelectID] == true
                                    ? "Hide comments"
                                    : "View ${allAnscmntANSIDwise[cmntSelectID].length - 1} more comments",
                                style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black.withOpacity(0.6),
                                    fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    )
                  : SizedBox(),
              SizedBox(height: 5),
              Container(
                width: 350,
                child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: allAnscmntANSIDwisebool[ansSelectID] == false
                        ? 1
                        : allAnscmntANSIDwise[cmntSelectID].length,
                    itemBuilder: (context, i) {
                      DateTime tempDate = DateTime.parse(
                          allAnscmntANSIDwise[cmntSelectID][i]["compare_date"]
                              .toString()
                              .substring(0, 8));
                      String current_date =
                          DateFormat.yMMMMd('en_US').format(tempDate);
                      return Container(
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
                                      allAnscmntANSIDwise[cmntSelectID][i]
                                          ["profilepic"],
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
                                  width: 270,
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10))),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            allAnscmntANSIDwise[cmntSelectID][i]
                                                    ["first_name"] +
                                                " " +
                                                allAnscmntANSIDwise[
                                                        cmntSelectID][i]
                                                    ["last_name"],
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Text(
                                            "${allAnscmntANSIDwise[cmntSelectID][i]["school_name"]} | Grade ${allAnscmntANSIDwise[cmntSelectID][i]["grade"]}",
                                            style: TextStyle(
                                                color: Colors.black54,
                                                fontSize: 9,
                                                fontWeight: FontWeight.w400),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Commented on " + "$current_date",
                                            style: TextStyle(
                                                color: Colors.black54,
                                                fontSize: 9,
                                                fontWeight: FontWeight.w400),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 8,
                                      ),
                                      allAnscmntANSIDwise[cmntSelectID][i]
                                                  ["comment_type"] ==
                                              "text"
                                          ? InkWell(
                                              onTap: () {},
                                              child: Container(
                                                child: ReadMoreText(
                                                  allAnscmntANSIDwise[
                                                          cmntSelectID][i]
                                                      ["comment"],
                                                  trimLines: 4,
                                                  colorClickableText:
                                                      Color(0xff0962ff),
                                                  trimMode: TrimMode.Line,
                                                  trimCollapsedText:
                                                      'read more',
                                                  trimExpandedText: 'Show less',
                                                  style: TextStyle(
                                                      color: Color(0xFF4D4D4D),
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.w500),
                                                  lessStyle: TextStyle(
                                                      color: Color(0xFF4D4D4D),
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.w500),
                                                  moreStyle: TextStyle(
                                                      color: Color(0xFF4D4D4D),
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.w500),
                                                ),
                                              ),
                                            )
                                          : InkWell(
                                              child: Container(
                                                margin: EdgeInsets.all(5),
                                                child: Image.network(
                                                    allAnscmntANSIDwise[
                                                            cmntSelectID][i]
                                                        ["comment"],
                                                    height: 200,
                                                    fit: BoxFit.fill),
                                              ),
                                            ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          if (answerCommentlikedLocalDB!.get(
                                                  allAnscmntANSIDwise[
                                                          cmntSelectID][i]
                                                      ["comment_id"]) ==
                                              "like") {
                                            setState(() {
                                              likeCountAnscmnt[cmntSelectID]
                                                      [i] =
                                                  likeCountAnscmnt[cmntSelectID]
                                                          [i] -
                                                      1;
                                            });
                                            ////////////////////////////notification//////////////////////////////////////
                                            String notify_id =
                                                "ntf${allAnscmntANSIDwise[cmntSelectID][i]["comment_id"]}$comparedate";
                                            notifyCRUD.sendNotification([
                                              notify_id,
                                              "reaction",
                                              "comment",
                                              _currentUserId,
                                              allAnscmntANSIDwise[cmntSelectID]
                                                  [i]["user_id"],
                                              countData!.value["usertoken"][
                                                  allAnscmntANSIDwise[
                                                          cmntSelectID][i]
                                                      ["user_id"]]["tokenid"],
                                              "You got one like!",
                                              "${userDataDB!.get("first_name")} ${userDataDB!.get("last_name")} liked your comment.",
                                              allQuestionsData[qIndex]
                                                  ["question_id"],
                                              "question",
                                              "false",
                                              comparedate,
                                              "delete"
                                            ]);
                                            //////////////////////////////////////////////////////////////////////////
                                            answerCommentlikedLocalDB!.delete(
                                                allAnscmntANSIDwise[
                                                        cmntSelectID][i]
                                                    ["comment_id"]);
                                            dataLoad
                                                .updateAnswerCommentCountData([
                                              allAnscmntANSIDwise[cmntSelectID]
                                                  [i]["comment_id"],
                                              _currentUserId,
                                              likeCountAnscmnt[cmntSelectID]
                                                      [i] -
                                                  1,
                                              replyCountAnscmnt[cmntSelectID][i]
                                            ]);
                                          } else {
                                            answerCommentlikedLocalDB!.put(
                                                allAnscmntANSIDwise[
                                                        cmntSelectID][i]
                                                    ["comment_id"],
                                                "like");
                                            setState(() {
                                              likeCountAnscmnt[cmntSelectID]
                                                      [i] =
                                                  likeCountAnscmnt[cmntSelectID]
                                                          [i] +
                                                      1;
                                            });
                                            ////////////////////////////notification//////////////////////////////////////
                                            String notify_id =
                                                "ntf${allAnscmntANSIDwise[cmntSelectID][i]["comment_id"]}$comparedate";
                                            notifyCRUD.sendNotification([
                                              notify_id,
                                              "reaction",
                                              "comment",
                                              _currentUserId,
                                              allAnscmntANSIDwise[cmntSelectID]
                                                  [i]["user_id"],
                                              countData!.value["usertoken"][
                                                  allAnscmntANSIDwise[
                                                          cmntSelectID][i]
                                                      ["user_id"]]["tokenid"],
                                              "You got one like!",
                                              "${userDataDB!.get("first_name")} ${userDataDB!.get("last_name")} liked your comment.",
                                              allQuestionsData[qIndex]
                                                  ["question_id"],
                                              "question",
                                              "false",
                                              comparedate,
                                              "add"
                                            ]);
                                            //////////////////////////////////////////////////////////////////////////
                                            dataLoad
                                                .updateAnswerCommentCountData([
                                              allAnscmntANSIDwise[cmntSelectID]
                                                  [i]["comment_id"],
                                              _currentUserId,
                                              likeCountAnscmnt[cmntSelectID]
                                                      [i] +
                                                  1,
                                              replyCountAnscmnt[cmntSelectID][i]
                                            ]);
                                          }
                                        },
                                        child: Text(
                                          "Like",
                                          style: TextStyle(
                                              color: (answerCommentlikedLocalDB!
                                                          .get(allAnscmntANSIDwise[
                                                                  cmntSelectID][i]
                                                              ["comment_id"]) ==
                                                      "like")
                                                  ? Color(0xff0962ff)
                                                  : Colors.black54,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700),
                                        ),
                                      ),
                                      1 > 0
                                          ? SizedBox(
                                              width: 8,
                                            )
                                          : SizedBox(),
                                      1 > 0
                                          ? Text(
                                              " " +
                                                  likeCountAnscmnt[cmntSelectID]
                                                          [i]
                                                      .toString() +
                                                  " ",
                                              style: TextStyle(
                                                  color: Colors.black54,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w400),
                                            )
                                          : SizedBox(),
                                      1 > 0
                                          ? Icon(Entypo.thumbs_up,
                                              color:
                                                  Color.fromRGBO(0, 0, 0, 0.8),
                                              size: 14)
                                          : SizedBox(),
                                      SizedBox(
                                        width: 8,
                                      ),
                                      Text(
                                        " | ",
                                        style: TextStyle(
                                            color: Colors.black54,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700),
                                      ),
                                      SizedBox(
                                        width: 8,
                                      ),
                                      InkWell(
                                        onTap: () {
                                          _addreplyPostDialog(
                                              qIndex,
                                              ansSelectID,
                                              ansIndex,
                                              cmntSelectID,
                                              i);
                                        },
                                        child: Text(
                                          "Reply",
                                          style: TextStyle(
                                              color: Colors.black54,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700),
                                        ),
                                      ),
                                      1 > 0
                                          ? SizedBox(
                                              width: 8,
                                            )
                                          : SizedBox(),
                                      1 > 0
                                          ? InkWell(
                                              onTap: () {
                                                _viewreplyPostDialog(
                                                    qIndex,
                                                    ansSelectID,
                                                    ansIndex,
                                                    cmntSelectID,
                                                    i);
                                              },
                                              child: Text(
                                                " " +
                                                    replyCountAnscmnt[
                                                            cmntSelectID][i]
                                                        .toString() +
                                                    " ",
                                                style: TextStyle(
                                                    color: Colors.black54,
                                                    fontSize: 12,
                                                    fontWeight:
                                                        FontWeight.w400),
                                              ),
                                            )
                                          : SizedBox(),
                                      1 > 0
                                          ? Icon(Icons.chat,
                                              color:
                                                  Color.fromRGBO(0, 0, 0, 0.8),
                                              size: 14)
                                          : SizedBox(),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }),
              ),
            ],
          )
        : SizedBox();
  }

  //reply
  _reply(BuildContext context, int qIndex, int ansSelectID, int ansIndex,
      int cmntSelectID, int cmntIndex) {
    int replySelectID = -1;
    for (int i = 0; i < allAnsreplyCommentID.length; i++) {
      if (allAnsreplyCommentID[i] ==
          allAnscmntANSIDwise[cmntSelectID][cmntIndex]["comment_id"]) {
        replySelectID = i;
      }
    }
    print("check: ${allAnsReplyCMNTIDwisebool}");
    return replySelectID != -1
        ? Padding(
            padding: const EdgeInsets.only(left: 40.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 5),
                allAnsReplyCMNTIDwise[replySelectID].length > 1
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          InkWell(
                            onTap: () {
                              setState(() {
                                allAnsReplyCMNTIDwisebool[cmntSelectID] =
                                    !allAnsReplyCMNTIDwisebool[cmntSelectID];
                              });
                              Navigator.of(context).pop();
                              _viewreplyPostDialog(qIndex, ansSelectID,
                                  ansIndex, cmntSelectID, cmntIndex);
                            },
                            child: Container(
                              child: Text(
                                  allAnsReplyCMNTIDwisebool[cmntSelectID] ==
                                          true
                                      ? "Hide replies"
                                      : "View ${allAnsReplyCMNTIDwise[replySelectID].length - 1} more replies",
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black.withOpacity(0.6),
                                      fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      )
                    : SizedBox(),
                SizedBox(height: 5),
                Container(
                  width: 350,
                  child: ListView.builder(
                      shrinkWrap: true,
                      itemCount:
                          allAnsReplyCMNTIDwisebool[cmntSelectID] == false
                              ? 1
                              : allAnsReplyCMNTIDwise[replySelectID].length,
                      itemBuilder: (context, i) {
                        DateTime tempDate = DateTime.parse(
                            allAnsReplyCMNTIDwise[replySelectID][i]
                                    ["compare_date"]
                                .toString()
                                .substring(0, 8));
                        String current_date =
                            DateFormat.yMMMMd('en_US').format(tempDate);
                        return Container(
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
                                        allAnsReplyCMNTIDwise[replySelectID][i]
                                            ["profilepic"],
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
                                    width: 270,
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10))),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              allAnsReplyCMNTIDwise[
                                                          replySelectID][i]
                                                      ["first_name"] +
                                                  " " +
                                                  allAnsReplyCMNTIDwise[
                                                          replySelectID][i]
                                                      ["last_name"],
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
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Text(
                                              "${allAnsReplyCMNTIDwise[replySelectID][i]["school_name"]} | Grade ${allAnsReplyCMNTIDwise[replySelectID][i]["grade"]}",
                                              style: TextStyle(
                                                  color: Colors.black54,
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.w400),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Commented on " + "$current_date",
                                              style: TextStyle(
                                                  color: Colors.black54,
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.w400),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 8,
                                        ),
                                        allAnsReplyCMNTIDwise[replySelectID][i]
                                                    ["reply_type"] ==
                                                "text"
                                            ? InkWell(
                                                onTap: () {},
                                                child: Container(
                                                  child: ReadMoreText(
                                                    allAnsReplyCMNTIDwise[
                                                            replySelectID][i]
                                                        ["reply"],
                                                    trimLines: 4,
                                                    colorClickableText:
                                                        Color(0xff0962ff),
                                                    trimMode: TrimMode.Line,
                                                    trimCollapsedText:
                                                        'read more',
                                                    trimExpandedText:
                                                        'Show less',
                                                    style: TextStyle(
                                                        color:
                                                            Color(0xFF4D4D4D),
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.w500),
                                                    lessStyle: TextStyle(
                                                        color:
                                                            Color(0xFF4D4D4D),
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.w500),
                                                    moreStyle: TextStyle(
                                                        color:
                                                            Color(0xFF4D4D4D),
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.w500),
                                                  ),
                                                ),
                                              )
                                            : InkWell(
                                                child: Container(
                                                  margin: EdgeInsets.all(5),
                                                  child: Image.network(
                                                      allAnsReplyCMNTIDwise[
                                                              replySelectID][i]
                                                          ["reply"],
                                                      height: 200,
                                                      fit: BoxFit.fill),
                                                ),
                                              ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            if (answerReplylikedLocalDB!.get(
                                                    allAnsReplyCMNTIDwise[
                                                            replySelectID][i]
                                                        ["reply_id"]) ==
                                                "like") {
                                              setState(() {
                                                likeCountAnsReply[replySelectID]
                                                    [i] = likeCountAnsReply[
                                                        replySelectID][i] -
                                                    1;
                                              });
                                              ////////////////////////////notification//////////////////////////////////////
                                              String notify_id =
                                                  "ntf${allAnsReplyCMNTIDwise[replySelectID][i]["reply_id"]}$comparedate";
                                              notifyCRUD.sendNotification([
                                                notify_id,
                                                "reaction",
                                                "reply",
                                                _currentUserId,
                                                allAnsReplyCMNTIDwise[
                                                        replySelectID][i]
                                                    ["user_id"],
                                                countData!.value["usertoken"][
                                                    allAnsReplyCMNTIDwise[
                                                            replySelectID][i]
                                                        ["user_id"]]["tokenid"],
                                                "You got one like!",
                                                "${userDataDB!.get("first_name")} ${userDataDB!.get("last_name")} liked your reply.",
                                                allQuestionsData[qIndex]
                                                    ["question_id"],
                                                "question",
                                                "false",
                                                comparedate,
                                                "delete"
                                              ]);
                                              //////////////////////////////////////////////////////////////////////////
                                              dataLoad
                                                  .updateAnswerReplyCountData([
                                                allAnsReplyCMNTIDwise[
                                                        replySelectID][i]
                                                    ["reply_id"],
                                                _currentUserId,
                                                likeCountAnsReply[replySelectID]
                                                        [i] -
                                                    1
                                              ]);
                                              answerReplylikedLocalDB!.delete(
                                                  allAnsReplyCMNTIDwise[
                                                          replySelectID][i]
                                                      ["reply_id"]);
                                            } else {
                                              setState(() {
                                                likeCountAnsReply[replySelectID]
                                                    [i] = likeCountAnsReply[
                                                        replySelectID][i] +
                                                    1;
                                              });
                                              ////////////////////////////notification//////////////////////////////////////
                                              String notify_id =
                                                  "ntf${allAnsReplyCMNTIDwise[replySelectID][i]["reply_id"]}$comparedate";
                                              notifyCRUD.sendNotification([
                                                notify_id,
                                                "reaction",
                                                "reply",
                                                _currentUserId,
                                                allAnsReplyCMNTIDwise[
                                                        replySelectID][i]
                                                    ["user_id"],
                                                countData!.value["usertoken"][
                                                    allAnsReplyCMNTIDwise[
                                                            replySelectID][i]
                                                        ["user_id"]]["tokenid"],
                                                "You got one like!",
                                                "${userDataDB!.get("first_name")} ${userDataDB!.get("last_name")} liked your reply.",
                                                allQuestionsData[qIndex]
                                                    ["question_id"],
                                                "question",
                                                "false",
                                                comparedate,
                                                "add"
                                              ]);
                                              //////////////////////////////////////////////////////////////////////////
                                              dataLoad
                                                  .updateAnswerReplyCountData([
                                                allAnsReplyCMNTIDwise[
                                                        replySelectID][i]
                                                    ["reply_id"],
                                                _currentUserId,
                                                likeCountAnsReply[replySelectID]
                                                        [i] +
                                                    1
                                              ]);
                                              answerReplylikedLocalDB!.put(
                                                  allAnsReplyCMNTIDwise[
                                                          replySelectID][i]
                                                      ["reply_id"],
                                                  "like");
                                            }
                                          },
                                          child: Text(
                                            "Like",
                                            style: TextStyle(
                                                color: (answerReplylikedLocalDB!.get(
                                                            allAnsReplyCMNTIDwise[
                                                                    replySelectID]
                                                                [
                                                                i]["reply_id"]) ==
                                                        "like")
                                                    ? Color(0xff0962ff)
                                                    : Colors.black54,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w700),
                                          ),
                                        ),
                                        1 > 0
                                            ? SizedBox(
                                                width: 8,
                                              )
                                            : SizedBox(),
                                        1 > 0
                                            ? Text(
                                                " " +
                                                    likeCountAnsReply[
                                                            replySelectID][i]
                                                        .toString() +
                                                    " ",
                                                style: TextStyle(
                                                    color: Colors.black54,
                                                    fontSize: 12,
                                                    fontWeight:
                                                        FontWeight.w400),
                                              )
                                            : SizedBox(),
                                        1 > 0
                                            ? Icon(Entypo.thumbs_up,
                                                color: Color.fromRGBO(
                                                    0, 0, 0, 0.8),
                                                size: 14)
                                            : SizedBox(),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }),
                ),
              ],
            ),
          )
        : SizedBox();
  }

  void _viewreplyPostDialog(int qIndex, int ansSelectID, int ansIndex,
      int cmntSelectID, int cmntIndex) {
    showDialog(
        context: context,
        barrierColor: Colors.grey.withOpacity(0.2),
        barrierDismissible: false,
        builder: (_) => StatefulBuilder(builder: (context, setState) {
              return AlertDialog(
                backgroundColor: Color.fromRGBO(242, 246, 248, 1),
                contentPadding: EdgeInsets.all(20),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0)),
                title: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: Tab(
                              child: Icon(Icons.cancel_rounded,
                                  color: Colors.black45, size: 25)),
                        )
                      ],
                    ),
                    SizedBox(height: 20),
                    Container(height: 1, width: 500, color: Colors.grey[200]),
                  ],
                ),
                content: Container(
                  height: 500,
                  width: 600,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(height: 10),
                        Container(
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
                                        allAnscmntANSIDwise[cmntSelectID]
                                            [cmntIndex]["profilepic"],
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
                                    width: 270,
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10))),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              allAnscmntANSIDwise[cmntSelectID]
                                                          [cmntIndex]
                                                      ["first_name"] +
                                                  " " +
                                                  allAnscmntANSIDwise[
                                                          cmntSelectID]
                                                      [cmntIndex]["last_name"],
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
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Text(
                                              "${allAnscmntANSIDwise[cmntSelectID][cmntIndex]["school_name"]} | Grade ${allAnscmntANSIDwise[cmntSelectID][cmntIndex]["grade"]}",
                                              style: TextStyle(
                                                  color: Colors.black54,
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.w400),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Commented on " + "$current_date",
                                              style: TextStyle(
                                                  color: Colors.black54,
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.w400),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 8,
                                        ),
                                        allAnscmntANSIDwise[cmntSelectID]
                                                        [cmntIndex]
                                                    ["comment_type"] ==
                                                "text"
                                            ? InkWell(
                                                onTap: () {},
                                                child: Container(
                                                  child: ReadMoreText(
                                                    allAnscmntANSIDwise[
                                                            cmntSelectID]
                                                        [cmntIndex]["comment"],
                                                    trimLines: 4,
                                                    colorClickableText:
                                                        Color(0xff0962ff),
                                                    trimMode: TrimMode.Line,
                                                    trimCollapsedText:
                                                        'read more',
                                                    trimExpandedText:
                                                        'Show less',
                                                    style: TextStyle(
                                                        color:
                                                            Color(0xFF4D4D4D),
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.w500),
                                                    lessStyle: TextStyle(
                                                        color:
                                                            Color(0xFF4D4D4D),
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.w500),
                                                    moreStyle: TextStyle(
                                                        color:
                                                            Color(0xFF4D4D4D),
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.w500),
                                                  ),
                                                ),
                                              )
                                            : InkWell(
                                                child: Container(
                                                  margin: EdgeInsets.all(5),
                                                  child: Image.network(
                                                      allAnscmntANSIDwise[
                                                                  cmntSelectID]
                                                              [cmntIndex]
                                                          ["comment"],
                                                      height: 200,
                                                      fit: BoxFit.fill),
                                                ),
                                              ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            if (answerCommentlikedLocalDB!.get(
                                                    allAnscmntANSIDwise[
                                                                cmntSelectID]
                                                            [cmntIndex]
                                                        ["comment_id"]) ==
                                                "like") {
                                              setState(() {
                                                likeCountAnscmnt[cmntSelectID]
                                                        [cmntIndex] =
                                                    likeCountAnscmnt[
                                                                cmntSelectID]
                                                            [cmntIndex] -
                                                        1;
                                              });
                                              answerCommentlikedLocalDB!.delete(
                                                  allAnscmntANSIDwise[
                                                              cmntSelectID]
                                                          [cmntIndex]
                                                      ["comment_id"]);
                                              dataLoad
                                                  .updateAnswerCommentCountData([
                                                allAnscmntANSIDwise[
                                                        cmntSelectID][cmntIndex]
                                                    ["comment_id"],
                                                _currentUserId,
                                                likeCountAnscmnt[cmntSelectID]
                                                        [cmntIndex] -
                                                    1,
                                                replyCountAnscmnt[cmntSelectID]
                                                    [cmntIndex]
                                              ]);
                                            } else {
                                              answerCommentlikedLocalDB!.put(
                                                  allAnscmntANSIDwise[
                                                          cmntSelectID]
                                                      [cmntIndex]["comment_id"],
                                                  "like");
                                              setState(() {
                                                likeCountAnscmnt[cmntSelectID]
                                                        [cmntIndex] =
                                                    likeCountAnscmnt[
                                                                cmntSelectID]
                                                            [cmntIndex] +
                                                        1;
                                              });
                                              dataLoad
                                                  .updateAnswerCommentCountData([
                                                allAnscmntANSIDwise[
                                                        cmntSelectID][cmntIndex]
                                                    ["comment_id"],
                                                _currentUserId,
                                                likeCountAnscmnt[cmntSelectID]
                                                        [cmntIndex] +
                                                    1,
                                                replyCountAnscmnt[cmntSelectID]
                                                    [cmntIndex]
                                              ]);
                                            }
                                          },
                                          child: Text(
                                            "Like",
                                            style: TextStyle(
                                                color: (answerCommentlikedLocalDB!.get(
                                                            allAnscmntANSIDwise[
                                                                        cmntSelectID]
                                                                    [cmntIndex][
                                                                "comment_id"]) ==
                                                        "like")
                                                    ? Color(0xff0962ff)
                                                    : Colors.black54,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w700),
                                          ),
                                        ),
                                        1 > 0
                                            ? SizedBox(
                                                width: 8,
                                              )
                                            : SizedBox(),
                                        1 > 0
                                            ? Text(
                                                " " +
                                                    likeCountAnscmnt[
                                                                cmntSelectID]
                                                            [cmntIndex]
                                                        .toString() +
                                                    " ",
                                                style: TextStyle(
                                                    color: Colors.black54,
                                                    fontSize: 12,
                                                    fontWeight:
                                                        FontWeight.w400),
                                              )
                                            : SizedBox(),
                                        1 > 0
                                            ? Icon(Entypo.thumbs_up,
                                                color: Color.fromRGBO(
                                                    0, 0, 0, 0.8),
                                                size: 14)
                                            : SizedBox(),
                                        SizedBox(
                                          width: 8,
                                        ),
                                        Text(
                                          " | ",
                                          style: TextStyle(
                                              color: Colors.black54,
                                              fontSize: 15,
                                              fontWeight: FontWeight.w700),
                                        ),
                                        SizedBox(
                                          width: 8,
                                        ),
                                        InkWell(
                                          onTap: () {
                                            Navigator.of(context).pop();
                                            _addreplyPostDialog(
                                                qIndex,
                                                ansSelectID,
                                                ansIndex,
                                                cmntSelectID,
                                                cmntIndex);
                                          },
                                          child: Text(
                                            "Reply",
                                            style: TextStyle(
                                                color: Colors.black54,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w700),
                                          ),
                                        ),
                                        1 > 0
                                            ? SizedBox(
                                                width: 8,
                                              )
                                            : SizedBox(),
                                        1 > 0
                                            ? Text(
                                                " " +
                                                    replyCountAnscmnt[
                                                                cmntSelectID]
                                                            [cmntIndex]
                                                        .toString() +
                                                    " ",
                                                style: TextStyle(
                                                    color: Colors.black54,
                                                    fontSize: 12,
                                                    fontWeight:
                                                        FontWeight.w400),
                                              )
                                            : SizedBox(),
                                        1 > 0
                                            ? Icon(Icons.chat,
                                                color: Color.fromRGBO(
                                                    0, 0, 0, 0.8),
                                                size: 14)
                                            : SizedBox(),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20),
                        _reply(context, qIndex, ansSelectID, ansIndex,
                            cmntSelectID, cmntIndex),
                      ],
                    ),
                  ),
                ),
              );
            }));
  }

  //this widget show the attached documents with post
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
                        ////////////////////////////notification//////////////////////////////////////
                        String notify_id =
                            "ntf${allQuestionsData[index]["user_id"]}$comparedate";
                        notifyCRUD.sendNotification([
                          notify_id,
                          "reaction",
                          "question",
                          _currentUserId,
                          allQuestionsData[index]["user_id"],
                          countData!.value["usertoken"]
                              [allQuestionsData[index]["user_id"]]["tokenid"],
                          "You got one like!",
                          "${userDataDB!.get("first_name")} ${userDataDB!.get("last_name")} like your question.",
                          allQuestionsData[index]["question_id"],
                          "question",
                          "false",
                          comparedate,
                          "add"
                        ]);
                        //////////////////////////////////////////////////////////////////////////

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
                        ////////////////////////////notification//////////////////////////////////////
                        String notify_id =
                            "ntf${allQuestionsData[index]["user_id"]}$comparedate";
                        notifyCRUD.sendNotification([
                          notify_id,
                          "reaction",
                          "question",
                          _currentUserId,
                          allQuestionsData[index]["user_id"],
                          countData!.value["usertoken"]
                              [allQuestionsData[index]["user_id"]]["tokenid"],
                          "You got one like!",
                          "${userDataDB!.get("first_name")} ${userDataDB!.get("last_name")} like your question.",
                          allQuestionsData[index]["question_id"],
                          "question",
                          "false",
                          comparedate,
                          "add"
                        ]);
                        //////////////////////////////////////////////////////////////////////////
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
                        ////////////////////////////notification//////////////////////////////////////
                        String notify_id =
                            "ntf${allQuestionsData[index]["user_id"]}$comparedate";
                        notifyCRUD.sendNotification([
                          notify_id,
                          "reaction",
                          "question",
                          _currentUserId,
                          allQuestionsData[index]["user_id"],
                          countData!.value["usertoken"]
                              [allQuestionsData[index]["user_id"]]["tokenid"],
                          "You got one like!",
                          "${userDataDB!.get("first_name")} ${userDataDB!.get("last_name")} like your question.",
                          allQuestionsData[index]["question_id"],
                          "question",
                          "false",
                          comparedate,
                          "delete"
                        ]);
                        //////////////////////////////////////////////////////////////////////////
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

                        ////////////////////////////notification//////////////////////////////////////
                        String notify_id =
                            "ntf${allQuestionsData[index]["user_id"]}$comparedate";
                        notifyCRUD.sendNotification([
                          notify_id,
                          "reaction",
                          "question",
                          _currentUserId,
                          allQuestionsData[index]["user_id"],
                          countData!.value["usertoken"]
                              [allQuestionsData[index]["user_id"]]["tokenid"],
                          "You got one like!",
                          "${userDataDB!.get("first_name")} ${userDataDB!.get("last_name")} like your question.",
                          allQuestionsData[index]["question_id"],
                          "question",
                          "false",
                          comparedate,
                          "add"
                        ]);
                        //////////////////////////////////////////////////////////////////////////
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
                        ////////////////////////////notification//////////////////////////////////////
                        String notify_id =
                            "ntf${allQuestionsData[index]["user_id"]}$comparedate";
                        notifyCRUD.sendNotification([
                          notify_id,
                          "reaction",
                          "question",
                          _currentUserId,
                          allQuestionsData[index]["user_id"],
                          countData!.value["usertoken"]
                              [allQuestionsData[index]["user_id"]]["tokenid"],
                          "You got one mark as important!",
                          "${userDataDB!.get("first_name")} ${userDataDB!.get("last_name")} mark your question as important.",
                          allQuestionsData[index]["question_id"],
                          "question",
                          "false",
                          comparedate,
                          "add"
                        ]);
                        //////////////////////////////////////////////////////////////////////////
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
                        ////////////////////////////notification//////////////////////////////////////
                        String notify_id =
                            "ntf${allQuestionsData[index]["user_id"]}$comparedate";
                        notifyCRUD.sendNotification([
                          notify_id,
                          "reaction",
                          "question",
                          _currentUserId,
                          allQuestionsData[index]["user_id"],
                          countData!.value["usertoken"]
                              [allQuestionsData[index]["user_id"]]["tokenid"],
                          "You got one mark as important!",
                          "${userDataDB!.get("first_name")} ${userDataDB!.get("last_name")} mark your question as important.",
                          allQuestionsData[index]["question_id"],
                          "question",
                          "false",
                          comparedate,
                          "add"
                        ]);
                        //////////////////////////////////////////////////////////////////////////
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
                        ////////////////////////////notification//////////////////////////////////////
                        String notify_id =
                            "ntf${allQuestionsData[index]["user_id"]}$comparedate";
                        notifyCRUD.sendNotification([
                          notify_id,
                          "reaction",
                          "question",
                          _currentUserId,
                          allQuestionsData[index]["user_id"],
                          countData!.value["usertoken"]
                              [allQuestionsData[index]["user_id"]]["tokenid"],
                          "You got one mark as important!",
                          "${userDataDB!.get("first_name")} ${userDataDB!.get("last_name")} mark your question as important.",
                          allQuestionsData[index]["question_id"],
                          "question",
                          "false",
                          comparedate,
                          "delete"
                        ]);
                        //////////////////////////////////////////////////////////////////////////
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
                        ////////////////////////////notification//////////////////////////////////////
                        String notify_id =
                            "ntf${allQuestionsData[index]["user_id"]}$comparedate";
                        notifyCRUD.sendNotification([
                          notify_id,
                          "reaction",
                          "question",
                          _currentUserId,
                          allQuestionsData[index]["user_id"],
                          countData!.value["usertoken"]
                              [allQuestionsData[index]["user_id"]]["tokenid"],
                          "You got one mark as important!",
                          "${userDataDB!.get("first_name")} ${userDataDB!.get("last_name")} mark your question as important.",
                          allQuestionsData[index]["question_id"],
                          "question",
                          "false",
                          comparedate,
                          "add"
                        ]);
                        //////////////////////////////////////////////////////////////////////////
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
                          ////////////////////////////notification//////////////////////////////////////
                          String notify_id =
                              "ntf${allQuestionsData[index]["user_id"]}$comparedate";
                          notifyCRUD.sendNotification([
                            notify_id,
                            "reaction",
                            "question",
                            _currentUserId,
                            allQuestionsData[index]["user_id"],
                            countData!.value["usertoken"]
                                [allQuestionsData[index]["user_id"]]["tokenid"],
                            "You got one my doubt too!",
                            "${userDataDB!.get("first_name")} ${userDataDB!.get("last_name")} mark your question as my doubt too.",
                            allQuestionsData[index]["question_id"],
                            "question",
                            "false",
                            comparedate,
                            "add"
                          ]);
                          //////////////////////////////////////////////////////////////////////////
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
                          ////////////////////////////notification//////////////////////////////////////
                          String notify_id =
                              "ntf${allQuestionsData[index]["user_id"]}$comparedate";
                          notifyCRUD.sendNotification([
                            notify_id,
                            "reaction",
                            "question",
                            _currentUserId,
                            allQuestionsData[index]["user_id"],
                            countData!.value["usertoken"]
                                [allQuestionsData[index]["user_id"]]["tokenid"],
                            "You got one my doubt too!",
                            "${userDataDB!.get("first_name")} ${userDataDB!.get("last_name")} mark your question as my doubt too.",
                            allQuestionsData[index]["question_id"],
                            "question",
                            "false",
                            comparedate,
                            "add"
                          ]);
                          //////////////////////////////////////////////////////////////////////////
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
                          ////////////////////////////notification//////////////////////////////////////
                          String notify_id =
                              "ntf${allQuestionsData[index]["user_id"]}$comparedate";
                          notifyCRUD.sendNotification([
                            notify_id,
                            "reaction",
                            "question",
                            _currentUserId,
                            allQuestionsData[index]["user_id"],
                            countData!.value["usertoken"]
                                [allQuestionsData[index]["user_id"]]["tokenid"],
                            "You got one my doubt too!",
                            "${userDataDB!.get("first_name")} ${userDataDB!.get("last_name")} mark your question as my doubt too.",
                            allQuestionsData[index]["question_id"],
                            "question",
                            "false",
                            comparedate,
                            "delete"
                          ]);
                          //////////////////////////////////////////////////////////////////////////
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
                          ////////////////////////////notification//////////////////////////////////////
                          String notify_id =
                              "ntf${allQuestionsData[index]["user_id"]}$comparedate";
                          notifyCRUD.sendNotification([
                            notify_id,
                            "reaction",
                            "question",
                            _currentUserId,
                            allQuestionsData[index]["user_id"],
                            countData!.value["usertoken"]
                                [allQuestionsData[index]["user_id"]]["tokenid"],
                            "You got one my doubt too!",
                            "${userDataDB!.get("first_name")} ${userDataDB!.get("last_name")} mark your question as my doubt too.",
                            allQuestionsData[index]["question_id"],
                            "question",
                            "false",
                            comparedate,
                            "add"
                          ]);
                          //////////////////////////////////////////////////////////////////////////
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
                                  ////////////////////////////notification//////////////////////////////////////
                                  String notify_id =
                                      "ntf${allQuestionsData[index]["user_id"]}$comparedate";
                                  notifyCRUD.sendNotification([
                                    notify_id,
                                    "examlikelyhood",
                                    "question",
                                    _currentUserId,
                                    allQuestionsData[index]["user_id"],
                                    countData!.value["usertoken"]
                                            [allQuestionsData[index]["user_id"]]
                                        ["tokenid"],
                                    "Your question looks to be in exam!",
                                    "${userDataDB!.get("first_name")} ${userDataDB!.get("last_name")} thought your question is highly preferable in exam.",
                                    allQuestionsData[index]["question_id"],
                                    "question",
                                    "false",
                                    comparedate,
                                    "add"
                                  ]);
                                  //////////////////////////////////////////////////////////////////////////
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
                                  ////////////////////////////notification//////////////////////////////////////
                                  String notify_id =
                                      "ntf${allQuestionsData[index]["user_id"]}$comparedate";
                                  notifyCRUD.sendNotification([
                                    notify_id,
                                    "examlikelyhood",
                                    "question",
                                    _currentUserId,
                                    allQuestionsData[index]["user_id"],
                                    countData!.value["usertoken"]
                                            [allQuestionsData[index]["user_id"]]
                                        ["tokenid"],
                                    "Your question looks to be in exam!",
                                    "${userDataDB!.get("first_name")} ${userDataDB!.get("last_name")} thought your question is highly preferable in exam.",
                                    allQuestionsData[index]["question_id"],
                                    "question",
                                    "false",
                                    comparedate,
                                    "add"
                                  ]);
                                  //////////////////////////////////////////////////////////////////////////
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
                                  ////////////////////////////notification//////////////////////////////////////
                                  String notify_id =
                                      "ntf${allQuestionsData[index]["user_id"]}$comparedate";
                                  notifyCRUD.sendNotification([
                                    notify_id,
                                    "examlikelyhood",
                                    "question",
                                    _currentUserId,
                                    allQuestionsData[index]["user_id"],
                                    countData!.value["usertoken"]
                                            [allQuestionsData[index]["user_id"]]
                                        ["tokenid"],
                                    "Your question looks to be in exam!",
                                    "${userDataDB!.get("first_name")} ${userDataDB!.get("last_name")} thought your question is highly preferable in exam.",
                                    allQuestionsData[index]["question_id"],
                                    "question",
                                    "false",
                                    comparedate,
                                    "delete"
                                  ]);
                                  //////////////////////////////////////////////////////////////////////////
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
                                  ////////////////////////////notification//////////////////////////////////////
                                  String notify_id =
                                      "ntf${allQuestionsData[index]["user_id"]}$comparedate";
                                  notifyCRUD.sendNotification([
                                    notify_id,
                                    "examlikelyhood",
                                    "question",
                                    _currentUserId,
                                    allQuestionsData[index]["user_id"],
                                    countData!.value["usertoken"]
                                            [allQuestionsData[index]["user_id"]]
                                        ["tokenid"],
                                    "Your question looks to be in exam!",
                                    "${userDataDB!.get("first_name")} ${userDataDB!.get("last_name")} thought your question is highly preferable in exam.",
                                    allQuestionsData[index]["question_id"],
                                    "question",
                                    "false",
                                    comparedate,
                                    "add"
                                  ]);
                                  //////////////////////////////////////////////////////////////////////////
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
                                  ////////////////////////////notification//////////////////////////////////////
                                  String notify_id =
                                      "ntf${allQuestionsData[index]["user_id"]}$comparedate";
                                  notifyCRUD.sendNotification([
                                    notify_id,
                                    "examlikelyhood",
                                    "question",
                                    _currentUserId,
                                    allQuestionsData[index]["user_id"],
                                    countData!.value["usertoken"]
                                            [allQuestionsData[index]["user_id"]]
                                        ["tokenid"],
                                    "Your question looks to be in exam!",
                                    "${userDataDB!.get("first_name")} ${userDataDB!.get("last_name")} thought your question is moderately preferable in exam.",
                                    allQuestionsData[index]["question_id"],
                                    "question",
                                    "false",
                                    comparedate,
                                    "add"
                                  ]);
                                  //////////////////////////////////////////////////////////////////////////
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
                                  ////////////////////////////notification//////////////////////////////////////
                                  String notify_id =
                                      "ntf${allQuestionsData[index]["user_id"]}$comparedate";
                                  notifyCRUD.sendNotification([
                                    notify_id,
                                    "examlikelyhood",
                                    "question",
                                    _currentUserId,
                                    allQuestionsData[index]["user_id"],
                                    countData!.value["usertoken"]
                                            [allQuestionsData[index]["user_id"]]
                                        ["tokenid"],
                                    "Your question looks to be in exam!",
                                    "${userDataDB!.get("first_name")} ${userDataDB!.get("last_name")} thought your question is moderately preferable in exam.",
                                    allQuestionsData[index]["question_id"],
                                    "question",
                                    "false",
                                    comparedate,
                                    "add"
                                  ]);
                                  //////////////////////////////////////////////////////////////////////////
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
                                  ////////////////////////////notification//////////////////////////////////////
                                  String notify_id =
                                      "ntf${allQuestionsData[index]["user_id"]}$comparedate";
                                  notifyCRUD.sendNotification([
                                    notify_id,
                                    "examlikelyhood",
                                    "question",
                                    _currentUserId,
                                    allQuestionsData[index]["user_id"],
                                    countData!.value["usertoken"]
                                            [allQuestionsData[index]["user_id"]]
                                        ["tokenid"],
                                    "Your question looks to be in exam!",
                                    "${userDataDB!.get("first_name")} ${userDataDB!.get("last_name")} thought your question is moderately preferable in exam.",
                                    allQuestionsData[index]["question_id"],
                                    "question",
                                    "false",
                                    comparedate,
                                    "delete"
                                  ]);
                                  //////////////////////////////////////////////////////////////////////////
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
                                  ////////////////////////////notification//////////////////////////////////////
                                  String notify_id =
                                      "ntf${allQuestionsData[index]["user_id"]}$comparedate";
                                  notifyCRUD.sendNotification([
                                    notify_id,
                                    "examlikelyhood",
                                    "question",
                                    _currentUserId,
                                    allQuestionsData[index]["user_id"],
                                    countData!.value["usertoken"]
                                            [allQuestionsData[index]["user_id"]]
                                        ["tokenid"],
                                    "Your question looks to be in exam!",
                                    "${userDataDB!.get("first_name")} ${userDataDB!.get("last_name")} thought your question is moderately preferable in exam.",
                                    allQuestionsData[index]["question_id"],
                                    "question",
                                    "false",
                                    comparedate,
                                    "add"
                                  ]);
                                  //////////////////////////////////////////////////////////////////////////
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
                                  ////////////////////////////notification//////////////////////////////////////
                                  String notify_id =
                                      "ntf${allQuestionsData[index]["user_id"]}$comparedate";
                                  notifyCRUD.sendNotification([
                                    notify_id,
                                    "examlikelyhood",
                                    "question",
                                    _currentUserId,
                                    allQuestionsData[index]["user_id"],
                                    countData!.value["usertoken"]
                                            [allQuestionsData[index]["user_id"]]
                                        ["tokenid"],
                                    "Your question looks to be in exam!",
                                    "${userDataDB!.get("first_name")} ${userDataDB!.get("last_name")} thought your question is  preferable in exam.",
                                    allQuestionsData[index]["question_id"],
                                    "question",
                                    "false",
                                    comparedate,
                                    "add"
                                  ]);
                                  //////////////////////////////////////////////////////////////////////////
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
                                  ////////////////////////////notification//////////////////////////////////////
                                  String notify_id =
                                      "ntf${allQuestionsData[index]["user_id"]}$comparedate";
                                  notifyCRUD.sendNotification([
                                    notify_id,
                                    "examlikelyhood",
                                    "question",
                                    _currentUserId,
                                    allQuestionsData[index]["user_id"],
                                    countData!.value["usertoken"]
                                            [allQuestionsData[index]["user_id"]]
                                        ["tokenid"],
                                    "Your question looks to be in exam!",
                                    "${userDataDB!.get("first_name")} ${userDataDB!.get("last_name")} thought your question is  preferable in exam.",
                                    allQuestionsData[index]["question_id"],
                                    "question",
                                    "false",
                                    comparedate,
                                    "add"
                                  ]);
                                  //////////////////////////////////////////////////////////////////////////
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
                                  ////////////////////////////notification//////////////////////////////////////
                                  String notify_id =
                                      "ntf${allQuestionsData[index]["user_id"]}$comparedate";
                                  notifyCRUD.sendNotification([
                                    notify_id,
                                    "examlikelyhood",
                                    "question",
                                    _currentUserId,
                                    allQuestionsData[index]["user_id"],
                                    countData!.value["usertoken"]
                                            [allQuestionsData[index]["user_id"]]
                                        ["tokenid"],
                                    "Your question looks to be in exam!",
                                    "${userDataDB!.get("first_name")} ${userDataDB!.get("last_name")} thought your question is  preferable in exam.",
                                    allQuestionsData[index]["question_id"],
                                    "question",
                                    "false",
                                    comparedate,
                                    "delete"
                                  ]);
                                  //////////////////////////////////////////////////////////////////////////
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
                                  ////////////////////////////notification//////////////////////////////////////
                                  String notify_id =
                                      "ntf${allQuestionsData[index]["user_id"]}$comparedate";
                                  notifyCRUD.sendNotification([
                                    notify_id,
                                    "examlikelyhood",
                                    "question",
                                    _currentUserId,
                                    allQuestionsData[index]["user_id"],
                                    countData!.value["usertoken"]
                                            [allQuestionsData[index]["user_id"]]
                                        ["tokenid"],
                                    "Your question looks to be in exam!",
                                    "${userDataDB!.get("first_name")} ${userDataDB!.get("last_name")} thought your question is  preferable in exam.",
                                    allQuestionsData[index]["question_id"],
                                    "question",
                                    "false",
                                    comparedate,
                                    "add"
                                  ]);
                                  //////////////////////////////////////////////////////////////////////////
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
                                  ////////////////////////////notification//////////////////////////////////////
                                  String notify_id =
                                      "ntf${allQuestionsData[index]["user_id"]}$comparedate";
                                  notifyCRUD.sendNotification([
                                    notify_id,
                                    "toughness",
                                    "question",
                                    _currentUserId,
                                    allQuestionsData[index]["user_id"],
                                    countData!.value["usertoken"]
                                            [allQuestionsData[index]["user_id"]]
                                        ["tokenid"],
                                    "You asked a tough question!",
                                    "${userDataDB!.get("first_name")} ${userDataDB!.get("last_name")} marked your question as highly tough to solve.",
                                    allQuestionsData[index]["question_id"],
                                    "question",
                                    "false",
                                    comparedate,
                                    "add"
                                  ]);
                                  //////////////////////////////////////////////////////////////////////////
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
                                  ////////////////////////////notification//////////////////////////////////////
                                  String notify_id =
                                      "ntf${allQuestionsData[index]["user_id"]}$comparedate";
                                  notifyCRUD.sendNotification([
                                    notify_id,
                                    "toughness",
                                    "question",
                                    _currentUserId,
                                    allQuestionsData[index]["user_id"],
                                    countData!.value["usertoken"]
                                            [allQuestionsData[index]["user_id"]]
                                        ["tokenid"],
                                    "You asked a tough question!",
                                    "${userDataDB!.get("first_name")} ${userDataDB!.get("last_name")} marked your question as highly tough to solve.",
                                    allQuestionsData[index]["question_id"],
                                    "question",
                                    "false",
                                    comparedate,
                                    "add"
                                  ]);
                                  //////////////////////////////////////////////////////////////////////////
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
                                  ////////////////////////////notification//////////////////////////////////////
                                  String notify_id =
                                      "ntf${allQuestionsData[index]["user_id"]}$comparedate";
                                  notifyCRUD.sendNotification([
                                    notify_id,
                                    "toughness",
                                    "question",
                                    _currentUserId,
                                    allQuestionsData[index]["user_id"],
                                    countData!.value["usertoken"]
                                            [allQuestionsData[index]["user_id"]]
                                        ["tokenid"],
                                    "You asked a tough question!",
                                    "${userDataDB!.get("first_name")} ${userDataDB!.get("last_name")} marked your question as highly tough to solve.",
                                    allQuestionsData[index]["question_id"],
                                    "question",
                                    "false",
                                    comparedate,
                                    "delete"
                                  ]);
                                  //////////////////////////////////////////////////////////////////////////
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
                                  ////////////////////////////notification//////////////////////////////////////
                                  String notify_id =
                                      "ntf${allQuestionsData[index]["user_id"]}$comparedate";
                                  notifyCRUD.sendNotification([
                                    notify_id,
                                    "toughness",
                                    "question",
                                    _currentUserId,
                                    allQuestionsData[index]["user_id"],
                                    countData!.value["usertoken"]
                                            [allQuestionsData[index]["user_id"]]
                                        ["tokenid"],
                                    "You asked a tough question!",
                                    "${userDataDB!.get("first_name")} ${userDataDB!.get("last_name")} marked your question as highly tough to solve.",
                                    allQuestionsData[index]["question_id"],
                                    "question",
                                    "false",
                                    comparedate,
                                    "add"
                                  ]);
                                  //////////////////////////////////////////////////////////////////////////
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
                                  ////////////////////////////notification//////////////////////////////////////
                                  String notify_id =
                                      "ntf${allQuestionsData[index]["user_id"]}$comparedate";
                                  notifyCRUD.sendNotification([
                                    notify_id,
                                    "toughness",
                                    "question",
                                    _currentUserId,
                                    allQuestionsData[index]["user_id"],
                                    countData!.value["usertoken"]
                                            [allQuestionsData[index]["user_id"]]
                                        ["tokenid"],
                                    "You asked a tough question!",
                                    "${userDataDB!.get("first_name")} ${userDataDB!.get("last_name")} marked your question as moderately tough to solve.",
                                    allQuestionsData[index]["question_id"],
                                    "question",
                                    "false",
                                    comparedate,
                                    "add"
                                  ]);
                                  //////////////////////////////////////////////////////////////////////////
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
                                  ////////////////////////////notification//////////////////////////////////////
                                  String notify_id =
                                      "ntf${allQuestionsData[index]["user_id"]}$comparedate";
                                  notifyCRUD.sendNotification([
                                    notify_id,
                                    "toughness",
                                    "question",
                                    _currentUserId,
                                    allQuestionsData[index]["user_id"],
                                    countData!.value["usertoken"]
                                            [allQuestionsData[index]["user_id"]]
                                        ["tokenid"],
                                    "You asked a tough question!",
                                    "${userDataDB!.get("first_name")} ${userDataDB!.get("last_name")} marked your question as moderately tough to solve.",
                                    allQuestionsData[index]["question_id"],
                                    "question",
                                    "false",
                                    comparedate,
                                    "add"
                                  ]);
                                  //////////////////////////////////////////////////////////////////////////
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
                                  ////////////////////////////notification//////////////////////////////////////
                                  String notify_id =
                                      "ntf${allQuestionsData[index]["user_id"]}$comparedate";
                                  notifyCRUD.sendNotification([
                                    notify_id,
                                    "toughness",
                                    "question",
                                    _currentUserId,
                                    allQuestionsData[index]["user_id"],
                                    countData!.value["usertoken"]
                                            [allQuestionsData[index]["user_id"]]
                                        ["tokenid"],
                                    "You asked a tough question!",
                                    "${userDataDB!.get("first_name")} ${userDataDB!.get("last_name")} marked your question as moderately tough to solve.",
                                    allQuestionsData[index]["question_id"],
                                    "question",
                                    "false",
                                    comparedate,
                                    "delete"
                                  ]);
                                  //////////////////////////////////////////////////////////////////////////
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
                                  ////////////////////////////notification//////////////////////////////////////
                                  String notify_id =
                                      "ntf${allQuestionsData[index]["user_id"]}$comparedate";
                                  notifyCRUD.sendNotification([
                                    notify_id,
                                    "toughness",
                                    "question",
                                    _currentUserId,
                                    allQuestionsData[index]["user_id"],
                                    countData!.value["usertoken"]
                                            [allQuestionsData[index]["user_id"]]
                                        ["tokenid"],
                                    "You asked a tough question!",
                                    "${userDataDB!.get("first_name")} ${userDataDB!.get("last_name")} marked your question as moderately tough to solve.",
                                    allQuestionsData[index]["question_id"],
                                    "question",
                                    "false",
                                    comparedate,
                                    "add"
                                  ]);
                                  //////////////////////////////////////////////////////////////////////////
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
                                  ////////////////////////////notification//////////////////////////////////////
                                  String notify_id =
                                      "ntf${allQuestionsData[index]["user_id"]}$comparedate";
                                  notifyCRUD.sendNotification([
                                    notify_id,
                                    "toughness",
                                    "question",
                                    _currentUserId,
                                    allQuestionsData[index]["user_id"],
                                    countData!.value["usertoken"]
                                            [allQuestionsData[index]["user_id"]]
                                        ["tokenid"],
                                    "You asked a tough question!",
                                    "${userDataDB!.get("first_name")} ${userDataDB!.get("last_name")} marked your question as tough to solve.",
                                    allQuestionsData[index]["question_id"],
                                    "question",
                                    "false",
                                    comparedate,
                                    "add"
                                  ]);
                                  //////////////////////////////////////////////////////////////////////////
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
                                  ////////////////////////////notification//////////////////////////////////////
                                  String notify_id =
                                      "ntf${allQuestionsData[index]["user_id"]}$comparedate";
                                  notifyCRUD.sendNotification([
                                    notify_id,
                                    "toughness",
                                    "question",
                                    _currentUserId,
                                    allQuestionsData[index]["user_id"],
                                    countData!.value["usertoken"]
                                            [allQuestionsData[index]["user_id"]]
                                        ["tokenid"],
                                    "You asked a tough question!",
                                    "${userDataDB!.get("first_name")} ${userDataDB!.get("last_name")} marked your question as tough to solve.",
                                    allQuestionsData[index]["question_id"],
                                    "question",
                                    "false",
                                    comparedate,
                                    "add"
                                  ]);
                                  //////////////////////////////////////////////////////////////////////////
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
                                  ////////////////////////////notification//////////////////////////////////////
                                  String notify_id =
                                      "ntf${allQuestionsData[index]["user_id"]}$comparedate";
                                  notifyCRUD.sendNotification([
                                    notify_id,
                                    "toughness",
                                    "question",
                                    _currentUserId,
                                    allQuestionsData[index]["user_id"],
                                    countData!.value["usertoken"]
                                            [allQuestionsData[index]["user_id"]]
                                        ["tokenid"],
                                    "You asked a tough question!",
                                    "${userDataDB!.get("first_name")} ${userDataDB!.get("last_name")} marked your question as tough to solve.",
                                    allQuestionsData[index]["question_id"],
                                    "question",
                                    "false",
                                    comparedate,
                                    "delete"
                                  ]);
                                  //////////////////////////////////////////////////////////////////////////
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
                                  ////////////////////////////notification//////////////////////////////////////
                                  String notify_id =
                                      "ntf${allQuestionsData[index]["user_id"]}$comparedate";
                                  notifyCRUD.sendNotification([
                                    notify_id,
                                    "toughness",
                                    "question",
                                    _currentUserId,
                                    allQuestionsData[index]["user_id"],
                                    countData!.value["usertoken"]
                                            [allQuestionsData[index]["user_id"]]
                                        ["tokenid"],
                                    "You asked a tough question!",
                                    "${userDataDB!.get("first_name")} ${userDataDB!.get("last_name")} marked your question as tough to solve.",
                                    allQuestionsData[index]["question_id"],
                                    "question",
                                    "false",
                                    comparedate,
                                    "add"
                                  ]);
                                  //////////////////////////////////////////////////////////////////////////
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

  int askYourDoubtSteps = 0;

  int selectedSubjectIndex = -1;

  int selectedTopicIndex = -1;
  List data = [];
  void _addQuestionPostDialog() {
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
                        SizedBox(width: 30),
                        Text(
                          "Ask Your Doubt...",
                          style: TextStyle(
                            fontSize: 20,
                            color: Color(0xCB000000),
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            question = "";
                            latex = "";
                            askYourDoubtSteps = 0;
                            selectedSubjectIndex = -1;
                            selectedTopicIndex = -1;
                            data = [];
                            ocrImageURL = "";
                            referenceNotesAtttachedURL = "";
                            referenceVideoAtttachedURL = "";
                            referenceAudioAtttachedURL = "";
                            referenceTextAtttached = "";
                            notesAttached = false;
                            videoAttached = false;
                            audioAttached = false;
                            textAttached = false;
                            base64Image = "";
                            latex = "";
                            tex = [''];
                            questionType = "text";
                            callnow = false;
                            _selectedDate = '';
                            _selectedTime = '';
                            _endTime = '';
                            tagcount = 0;
                            tagids = [];
                            tagedUsersName = [];
                            markupptext = '';
                            tagedString = "";
                            useridentity = true;
                            isPostReady = false;
                            textbt = true;
                            videocallbt = false;
                            audiocallbt = false;
                            usercalllanguagepreference = "";
                            answerpreference = 1;
                            calltype = "";
                            selectedSubject = "";
                            selectedTopic = "";
                            Navigator.pop(context);
                          },
                          icon: Tab(
                              child: Icon(Icons.cancel_rounded,
                                  color: Colors.black45, size: 25)),
                        )
                      ],
                    ),
                    SizedBox(height: 20),
                    Container(height: 1, width: 500, color: Colors.grey[200]),
                  ],
                ),
                content: Container(
                  height: 470,
                  width: 500,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                              askYourDoubtSteps == 0
                                  ? "Choose subject"
                                  : askYourDoubtSteps == 1
                                      ? "Choose topic"
                                      : askYourDoubtSteps == 2
                                          ? "Choose question type"
                                          : "Post question",
                              style: TextStyle(
                                  fontSize: 16, color: Colors.black54)),
                          askYourDoubtSteps != 0
                              ? IconButton(
                                  onPressed: () {
                                    if (askYourDoubtSteps == 1) {
                                      setState(() {
                                        askYourDoubtSteps = 0;
                                      });
                                    } else if (askYourDoubtSteps == 2) {
                                      setState(() {
                                        askYourDoubtSteps = 1;
                                      });
                                    }
                                  },
                                  icon: Icon(Icons.arrow_back_ios,
                                      color: Colors.black54, size: 22))
                              : SizedBox(width: 20)
                        ],
                      ),
                      SizedBox(height: 10),
                      askYourDoubtSteps == 0
                          ? Container(
                              height: 350,
                              margin: EdgeInsets.fromLTRB(20, 0, 20, 0),
                              child: ListView.builder(
                                  itemCount: subjectList.length + 1,
                                  itemBuilder: (context, i) {
                                    return InkWell(
                                      onTap: () {
                                        setState(() {
                                          if (i == subjectList.length) {
                                            selectedSubject = "Others";
                                            askYourDoubtSteps = 1;
                                            selectedSubjectIndex = i;
                                          } else {
                                            selectedSubject = subjectList[i];
                                            askYourDoubtSteps = 1;
                                            selectedSubjectIndex = i;
                                          }
                                        });
                                      },
                                      child: Container(
                                        color: selectedSubjectIndex == i
                                            ? active
                                            : Colors.transparent,
                                        padding: EdgeInsets.all(10),
                                        child: Text(
                                            i == subjectList.length
                                                ? "Others"
                                                : subjectList[i],
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold)),
                                      ),
                                    );
                                  }),
                            )
                          : askYourDoubtSteps == 1
                              ? Container(
                                  height: 350,
                                  margin: EdgeInsets.fromLTRB(20, 0, 20, 0),
                                  child: ListView.builder(
                                      itemCount: selectedSubjectIndex ==
                                              subjectList.length
                                          ? otherTopicslist.length
                                          : topicList[selectedSubjectIndex]
                                              .length,
                                      itemBuilder: (context, i) {
                                        return InkWell(
                                          onTap: () {
                                            setState(() {
                                              selectedTopic =
                                                  selectedSubjectIndex ==
                                                          subjectList.length
                                                      ? otherTopicslist[i]
                                                      : topicList[
                                                          selectedSubjectIndex][i];
                                              askYourDoubtSteps = 2;
                                              selectedTopicIndex = i;
                                            });
                                          },
                                          child: Container(
                                            color: selectedTopicIndex == i
                                                ? active
                                                : Colors.transparent,
                                            padding: EdgeInsets.all(10),
                                            child: Text(
                                                selectedSubjectIndex ==
                                                        subjectList.length
                                                    ? otherTopicslist[i]
                                                    : topicList[
                                                            selectedSubjectIndex]
                                                        [i],
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          ),
                                        );
                                      }),
                                )
                              : askYourDoubtSteps == 2
                                  ? Container(
                                      height: 350,
                                      margin: EdgeInsets.fromLTRB(20, 0, 20, 0),
                                      child: Column(
                                        children: [
                                          SizedBox(
                                            height: 10,
                                          ),
                                          SizedBox(
                                            height: 30,
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    questionType = "ocr";
                                                    _pickImage(context);
                                                  });
                                                },
                                                child: Column(
                                                  children: [
                                                    Image.network(
                                                        "https://firebasestorage.googleapis.com/v0/b/hys-pro-41c66.appspot.com/o/assets%2Focr1.gif?alt=media&token=c0145d73-6635-4b39-a296-e2a851af5251",
                                                        height: 100,
                                                        width: 100),
                                                    SizedBox(
                                                      height: 7,
                                                    ),
                                                    Text(
                                                      "OCR",
                                                      style: TextStyle(
                                                        fontFamily:
                                                            'Nunito Sans',
                                                        fontSize: 15,
                                                        color:
                                                            Color(0xff0C2551),
                                                        fontWeight:
                                                            FontWeight.w700,
                                                      ),
                                                      textAlign:
                                                          TextAlign.center,
                                                    )
                                                  ],
                                                ),
                                              ),
                                              InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    questionType = "text";
                                                    askYourDoubtSteps = 3;
                                                  });
                                                },
                                                child: Column(
                                                  children: [
                                                    Image.network(
                                                        "https://firebasestorage.googleapis.com/v0/b/hys-pro-41c66.appspot.com/o/assets%2Ftyping.gif?alt=media&token=1a4b65b2-c497-438b-8c3a-a69dcfc7f67d",
                                                        height: 100,
                                                        width: 100),
                                                    SizedBox(
                                                      height: 7,
                                                    ),
                                                    Text(
                                                      "Keyboard",
                                                      style: TextStyle(
                                                        fontFamily:
                                                            'Nunito Sans',
                                                        fontSize: 15,
                                                        color:
                                                            Color(0xff0C2551),
                                                        fontWeight:
                                                            FontWeight.w700,
                                                      ),
                                                      textAlign:
                                                          TextAlign.center,
                                                    )
                                                  ],
                                                ),
                                              )
                                            ],
                                          ),
                                        ],
                                      ),
                                    )
                                  : Container(
                                      height: 350,
                                      margin: EdgeInsets.fromLTRB(20, 0, 20, 0),
                                      child: ListView(
                                        physics: BouncingScrollPhysics(),
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              CircleAvatar(
                                                child: ClipOval(
                                                  child: Container(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width /
                                                            10.34,
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width /
                                                            10.34,
                                                    child: CachedNetworkImage(
                                                      imageUrl: (userDataDB!
                                                              .get(
                                                                  "profilepic"))
                                                          .toString(),
                                                      fit: BoxFit.cover,
                                                      placeholder:
                                                          (context, url) =>
                                                              Container(
                                                        height: 30,
                                                        width: 30,
                                                        child: Image.network(
                                                          "https://firebasestorage.googleapis.com/v0/b/hys-pro-41c66.appspot.com/o/assets%2Floadingimg.gif?alt=media&token=4ca910f2-c584-4b3a-bbcb-2f1c01d93f67",
                                                        ),
                                                      ),
                                                      errorWidget: (context,
                                                              url, error) =>
                                                          Icon(Icons.error),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                width: 10,
                                              ),
                                              RichText(
                                                  text: TextSpan(
                                                      text: (userDataDB!.get(
                                                                  "first_name"))
                                                              .toString() +
                                                          " " +
                                                          (userDataDB!.get(
                                                                  "last_name"))
                                                              .toString(),
                                                      style: TextStyle(
                                                        fontFamily:
                                                            'Nunito Sans',
                                                        fontSize: 14,
                                                        color: Color.fromRGBO(
                                                            0, 0, 0, 0.7),
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                      children: <TextSpan>[
                                                    TextSpan(
                                                      text: '  asked',
                                                      style: TextStyle(
                                                        fontFamily:
                                                            'Nunito Sans',
                                                        fontSize: 12,
                                                        color: Color.fromRGBO(
                                                            0, 0, 0, 0.7),
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    )
                                                  ])),
                                              SizedBox(
                                                width: 15,
                                              ),
                                              InkWell(
                                                onTap: () {
                                                  _chooseUserIdentity();
                                                },
                                                child: Container(
                                                  padding: EdgeInsets.all(6),
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              100),
                                                      border: Border.all(
                                                          color:
                                                              Colors.black38)),
                                                  child: Center(
                                                    child: useridentity == true
                                                        ? Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceEvenly,
                                                            children: [
                                                              Icon(
                                                                  Icons
                                                                      .people_alt_outlined,
                                                                  color: Colors
                                                                      .black38,
                                                                  size: 16),
                                                              SizedBox(
                                                                width: 3,
                                                              ),
                                                              Text("Public",
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .black38,
                                                                      fontSize:
                                                                          12))
                                                            ],
                                                          )
                                                        : Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceEvenly,
                                                            children: [
                                                              Text("Anonymous",
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .black38,
                                                                      fontSize:
                                                                          12))
                                                            ],
                                                          ),
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                          SizedBox(
                                            height: 20,
                                          ),
                                          questionType == "text"
                                              ? Container(
                                                  child: TextFormField(
                                                    maxLines: 10,
                                                    initialValue: question,
                                                    keyboardType:
                                                        TextInputType.text,
                                                    cursorColor: Color.fromRGBO(
                                                        88, 165, 196, 1),
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        color: Color.fromRGBO(
                                                            88, 165, 196, 1),
                                                        fontWeight:
                                                            FontWeight.w500),
                                                    validator: (val) => ((val!
                                                            .isEmpty))
                                                        ? 'Ask your doubt here, you can\'t kept it blank'
                                                        : null,
                                                    onChanged: (val) {
                                                      setState(
                                                          () => question = val);
                                                    },
                                                    decoration: InputDecoration(
                                                      fillColor: Color.fromRGBO(
                                                          245, 245, 245, 1),
                                                      filled: true,
                                                      counterText: '',
                                                      hintText:
                                                          'Ask your doubt here',
                                                      hintStyle: TextStyle(
                                                          fontSize: 16,
                                                          color:
                                                              Colors.grey[300],
                                                          fontWeight:
                                                              FontWeight.w600),
                                                      alignLabelWithHint: false,
                                                      contentPadding:
                                                          new EdgeInsets
                                                                  .symmetric(
                                                              vertical: 10.0,
                                                              horizontal: 10),
                                                      errorStyle: TextStyle(
                                                          color: Color.fromRGBO(
                                                              240, 20, 41, 1)),
                                                      focusColor:
                                                          Color.fromRGBO(
                                                              88, 165, 196, 1),
                                                      focusedBorder:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                        borderSide: BorderSide(
                                                            color:
                                                                Color.fromRGBO(
                                                                    245,
                                                                    245,
                                                                    245,
                                                                    1)),
                                                      ),
                                                      enabledBorder:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                        borderSide: BorderSide(
                                                          color: Color.fromRGBO(
                                                              245, 245, 245, 1),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              : TeXView(
                                                  child:
                                                      TeXViewColumn(children: [
                                                    TeXViewDocument(latex,
                                                        style: TeXViewStyle(
                                                          fontStyle:
                                                              TeXViewFontStyle(
                                                                  fontSize: 8,
                                                                  sizeUnit:
                                                                      TeXViewSizeUnit
                                                                          .pt),
                                                          padding:
                                                              TeXViewPadding
                                                                  .all(10),
                                                        )),
                                                  ]),
                                                  style: TeXViewStyle(
                                                    elevation: 10,
                                                    backgroundColor:
                                                        Colors.white,
                                                  ),
                                                ),
                                          SizedBox(
                                            height: 20,
                                          ),
                                          Container(
                                            height: 50,
                                            width: 400,
                                            child: FlutterMentions(
                                              key: key,
                                              keyboardType: TextInputType.text,
                                              cursorColor: Color.fromRGBO(
                                                  88, 165, 196, 1),
                                              decoration: InputDecoration(
                                                fillColor: Color.fromRGBO(
                                                    245, 245, 245, 1),
                                                filled: true,
                                                counterText: '',
                                                hintText: '@Tag someone here',
                                                hintStyle: TextStyle(
                                                    fontSize: 13,
                                                    color: Colors.grey[350],
                                                    fontWeight:
                                                        FontWeight.w600),
                                                alignLabelWithHint: false,
                                                contentPadding:
                                                    new EdgeInsets.symmetric(
                                                        vertical: 10.0,
                                                        horizontal: 10),
                                                errorStyle: TextStyle(
                                                    color: Color.fromRGBO(
                                                        240, 20, 41, 1)),
                                                focusColor: Color.fromRGBO(
                                                    88, 165, 196, 1),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  borderSide: BorderSide(
                                                      color: Color.fromRGBO(
                                                          245, 245, 245, 1)),
                                                ),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  borderSide: BorderSide(
                                                    color: Color.fromRGBO(
                                                        245, 245, 245, 1),
                                                  ),
                                                ),
                                              ),
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: Color.fromRGBO(
                                                      88, 165, 196, 1),
                                                  fontWeight: FontWeight.w500),
                                              suggestionPosition:
                                                  SuggestionPosition.Bottom,
                                              onMarkupChanged: (val) {
                                                setState(() {
                                                  markupptext = val;
                                                });
                                              },
                                              onEditingComplete: () {
                                                setState(() {
                                                  tagids.clear();
                                                  for (int l = 0;
                                                      l < markupptext.length;
                                                      l++) {
                                                    int k = l;
                                                    if (markupptext.substring(
                                                            k, k + 1) ==
                                                        "@") {
                                                      String test1 = markupptext
                                                          .substring(k);
                                                      tagids.add(
                                                          test1.substring(
                                                              4,
                                                              test1.indexOf(
                                                                  "__]")));
                                                    }
                                                  }
                                                  print(tagids);
                                                });
                                              },
                                              onSuggestionVisibleChanged:
                                                  (val) {
                                                setState(() {
                                                  _showList = val;
                                                });
                                              },
                                              onChanged: (val) {
                                                setState(() {
                                                  tagedString = val;
                                                });
                                              },
                                              onSearchChanged: (
                                                trigger,
                                                value,
                                              ) {
                                                print(
                                                    'again | $trigger | $value ');
                                              },
                                              hideSuggestionList: false,
                                              minLines: 1,
                                              maxLines: 5,
                                              mentions: [
                                                Mention(
                                                    trigger: r'@',
                                                    style: TextStyle(
                                                      color: Color.fromRGBO(
                                                          88, 165, 196, 1),
                                                    ),
                                                    matchAll: false,
                                                    data: _users,
                                                    suggestionBuilder: (data) {
                                                      return Container(
                                                        padding:
                                                            EdgeInsets.all(10),
                                                        decoration: BoxDecoration(
                                                            color: Colors.white,
                                                            border: Border(
                                                                top: BorderSide(
                                                                    color: Color(
                                                                        0xFFE0E1E4)))),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: <Widget>[
                                                            CircleAvatar(
                                                              backgroundImage:
                                                                  NetworkImage(
                                                                data['photo'],
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              width: 20.0,
                                                            ),
                                                            Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: <
                                                                  Widget>[
                                                                Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Text(data[
                                                                        'display']),
                                                                  ],
                                                                ),
                                                                SizedBox(
                                                                  height: 3,
                                                                ),
                                                                Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Text(
                                                                      '${data['full_name']}',
                                                                      style:
                                                                          TextStyle(
                                                                        color: Color(
                                                                            0xFFAAABAD),
                                                                        fontSize:
                                                                            11,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ],
                                                            )
                                                          ],
                                                        ),
                                                      );
                                                    }),
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          ((notesAttached == true) ||
                                                  (videoAttached == true) ||
                                                  (audioAttached == true) ||
                                                  (textAttached == true))
                                              ? Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    (notesAttached == true)
                                                        ? SizedBox(
                                                            width: 30,
                                                          )
                                                        : SizedBox(),
                                                    (notesAttached == true)
                                                        ? GestureDetector(
                                                            onTap: () async {
                                                              _launchInBrowser(
                                                                  referenceNotesAtttachedURL);
                                                            },
                                                            onLongPress: () {
                                                              setState(() {
                                                                notesAttached =
                                                                    false;
                                                                referenceAudioAtttachedURL =
                                                                    "";
                                                              });
                                                            },
                                                            child: Container(
                                                              width: 50,
                                                              height: 50,
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: Color(
                                                                    0xffffffff),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            5),
                                                                boxShadow: [
                                                                  BoxShadow(
                                                                    offset:
                                                                        Offset(
                                                                            12,
                                                                            11),
                                                                    blurRadius:
                                                                        15,
                                                                    color: Color(
                                                                            0xffaaaaaa)
                                                                        .withOpacity(
                                                                            0.1),
                                                                  )
                                                                ],
                                                              ),
                                                              //
                                                              child: Center(
                                                                child: Icon(
                                                                    Icons
                                                                        .file_copy_outlined,
                                                                    color: Color(
                                                                        0xFFD60808),
                                                                    size: 25),
                                                              ),
                                                            ),
                                                          )
                                                        : SizedBox(),
                                                    (videoAttached == true)
                                                        ? SizedBox(
                                                            width: 30,
                                                          )
                                                        : SizedBox(),
                                                    (videoAttached == true)
                                                        ? GestureDetector(
                                                            onTap: () async {
                                                              _launchInBrowser(
                                                                  referenceVideoAtttachedURL);
                                                            },
                                                            onLongPress: () {
                                                              setState(() {
                                                                videoAttached =
                                                                    false;
                                                                referenceVideoAtttachedURL =
                                                                    "";
                                                              });
                                                            },
                                                            child: Container(
                                                              width: 50,
                                                              height: 50,
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: Color(
                                                                    0xffffffff),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            5),
                                                                boxShadow: [
                                                                  BoxShadow(
                                                                    offset:
                                                                        Offset(
                                                                            12,
                                                                            11),
                                                                    blurRadius:
                                                                        15,
                                                                    color: Color(
                                                                            0xffaaaaaa)
                                                                        .withOpacity(
                                                                            0.1),
                                                                  )
                                                                ],
                                                              ),
                                                              //
                                                              child: Center(
                                                                child: Icon(
                                                                    Icons
                                                                        .video_call_outlined,
                                                                    color: Color(
                                                                        0xFFD60808),
                                                                    size: 25),
                                                              ),
                                                            ),
                                                          )
                                                        : SizedBox(),
                                                    (audioAttached == true)
                                                        ? SizedBox(
                                                            width: 30,
                                                          )
                                                        : SizedBox(),
                                                    (audioAttached == true)
                                                        ? GestureDetector(
                                                            onTap: () async {
                                                              _launchInBrowser(
                                                                  referenceAudioAtttachedURL);
                                                            },
                                                            onLongPress: () {
                                                              setState(() {
                                                                audioAttached =
                                                                    false;
                                                                referenceAudioAtttachedURL =
                                                                    "";
                                                              });
                                                            },
                                                            child: Container(
                                                              width: 50,
                                                              height: 50,
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: Color(
                                                                    0xffffffff),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            5),
                                                                boxShadow: [
                                                                  BoxShadow(
                                                                    offset:
                                                                        Offset(
                                                                            12,
                                                                            11),
                                                                    blurRadius:
                                                                        15,
                                                                    color: Color(
                                                                            0xffaaaaaa)
                                                                        .withOpacity(
                                                                            0.1),
                                                                  )
                                                                ],
                                                              ),
                                                              //
                                                              child: Center(
                                                                child: Icon(
                                                                    Icons
                                                                        .audiotrack_outlined,
                                                                    color: Color(
                                                                        0xFFD60808),
                                                                    size: 25),
                                                              ),
                                                            ),
                                                          )
                                                        : SizedBox(),
                                                    (textAttached == true)
                                                        ? SizedBox(
                                                            width: 30,
                                                          )
                                                        : SizedBox(),
                                                    (textAttached == true)
                                                        ? GestureDetector(
                                                            onTap: () {
                                                              pickTextReferenceDialog(
                                                                  referenceTextAtttached);
                                                            },
                                                            onLongPress: () {
                                                              setState(() {
                                                                textAttached =
                                                                    false;
                                                              });
                                                            },
                                                            child: Container(
                                                              width: 50,
                                                              height: 50,
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: Color(
                                                                    0xffffffff),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            5),
                                                                boxShadow: [
                                                                  BoxShadow(
                                                                    offset:
                                                                        Offset(
                                                                            12,
                                                                            11),
                                                                    blurRadius:
                                                                        15,
                                                                    color: Color(
                                                                            0xffaaaaaa)
                                                                        .withOpacity(
                                                                            0.1),
                                                                  )
                                                                ],
                                                              ),
                                                              //
                                                              child: Center(
                                                                child: Icon(
                                                                    Icons
                                                                        .text_fields_outlined,
                                                                    color: Color(
                                                                        0xFFD60808),
                                                                    size: 25),
                                                              ),
                                                            ),
                                                          )
                                                        : SizedBox(),
                                                  ],
                                                )
                                              : SizedBox(),
                                          SizedBox(
                                            height: 20,
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Add Reference   ',
                                                style: TextStyle(
                                                  fontFamily: 'Nunito Sans',
                                                  fontSize: 15,
                                                  color: Color.fromRGBO(
                                                      88, 165, 196, 1),
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              Text(
                                                '(Optional)',
                                                style: TextStyle(
                                                  fontFamily: 'Nunito Sans',
                                                  fontSize: 12,
                                                  color: Colors.black45,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 10),
                                          _reference(context),
                                          SizedBox(height: 20),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Preferred Answer Type   ',
                                                style: TextStyle(
                                                  fontFamily: 'Nunito Sans',
                                                  fontSize: 15,
                                                  color: Color.fromRGBO(
                                                      88, 165, 196, 1),
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              Text(
                                                '(Optional)',
                                                style: TextStyle(
                                                  fontFamily: 'Nunito Sans',
                                                  fontSize: 12,
                                                  color: Colors.black45,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 10),
                                          _answertpe(context),
                                          (videocallbt == true) ||
                                                  (audiocallbt == true)
                                              ? SizedBox(height: 20)
                                              : SizedBox(),
                                          (videocallbt == true) ||
                                                  (audiocallbt == true)
                                              ? _calltime(context)
                                              : SizedBox(),
                                          SizedBox(height: 20),
                                        ],
                                      ),
                                    ),
                      SizedBox(height: 20),
                      askYourDoubtSteps == 3
                          ? Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(5),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.deepPurple.withOpacity(0.1),
                                    spreadRadius: 5,
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                child: Container(
                                    width: double.infinity,
                                    height: 40,
                                    child: Center(
                                        child: Text("Post",
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: ((question != "") ||
                                                        (latex != ""))
                                                    ? Colors.white
                                                    : Colors.grey[400])))),
                                onPressed: () async {
                                  if ((question != "") || (latex != "")) {
                                    setState(() {
                                      Dialogs.showLoadingDialog(
                                          context, _keyLoader);
                                      tagids.clear();
                                      tagedUsersName.clear();
                                      print(markupptext);
                                      for (int l = 0;
                                          l < markupptext.length - 4;
                                          l++) {
                                        int k = l;
                                        if (markupptext.substring(k, k + 1) ==
                                            "@") {
                                          String test1 =
                                              markupptext.substring(k);
                                          print(
                                              "tagid ${test1.substring(4, test1.indexOf("__]"))}");
                                          tagids.add(test1.substring(
                                              4, test1.indexOf("__]")));
                                        }

                                        if (markupptext.substring(k, k + 3) ==
                                            "(__") {
                                          String test2 =
                                              markupptext.substring(k);
                                          print(test2);
                                          tagedUsersName.add(test2.substring(
                                              3, test2.indexOf("__)")));
                                          print(
                                              "tagusername ${test2.substring(3, test2.indexOf("__)"))}");
                                        }
                                      }
                                      print(tagedUsersName);
                                      print(tagids);
                                      data = [
                                        _currentUserId + comparedate,
                                        _currentUserId,
                                        0,
                                        answerpreference.toString(),
                                        referenceAudioAtttachedURL,
                                        _selectedDate,
                                        _endTime,
                                        callnow.toString(),
                                        usercalllanguagepreference,
                                        _selectedTime,
                                        3,
                                        3,
                                        0,
                                        0,
                                        userDataDB!.get("grade"),
                                        0,
                                        referenceNotesAtttachedURL,
                                        ocrImageURL,
                                        comparedate,
                                        question != ""
                                            ? question
                                            : latex != ""
                                                ? latex
                                                : "na",
                                        questionType,
                                        useridentity.toString(),
                                        selectedSubject,
                                        selectedTopic,
                                        referenceTextAtttached,
                                        0,
                                        referenceVideoAtttachedURL,
                                        0
                                      ];
                                    });
                                    if (tagids.isNotEmpty) {
                                      for (int i = 0; i < tagids.length; i++) {
                                        await dataLoad
                                            .postUsertaggedInQuestionData([
                                          _currentUserId + comparedate,
                                          tagids[i]
                                        ]);
                                      }
                                    }
                                    bool x = await dataLoad
                                        .postUserQuestionData(data);
                                    if (x == true) {
                                      allQuestionsData.insert(0, {
                                        "first_name":
                                            userDataDB!.get("first_name"),
                                        "last_name":
                                            userDataDB!.get("last_name"),
                                        "profilepic":
                                            userDataDB!.get("profilepic"),
                                        "school_name":
                                            userDataDB!.get("school_name"),
                                        "question_id": data[0],
                                        "user_id": data[1],
                                        "answer_count": data[2],
                                        "answer_preference": data[3],
                                        "audio_reference": data[4],
                                        "call_date": data[5],
                                        "call_end_time": data[6],
                                        "call_now": data[7],
                                        "call_preferred_lang": data[8],
                                        "call_start_time": data[9],
                                        "answer_credit": data[10],
                                        "question_credit": data[11],
                                        "view_count": data[12],
                                        "examlikelyhood_count": data[13],
                                        "grade": data[14],
                                        "like_count": data[15],
                                        "note_reference": data[16],
                                        "ocr_image": data[17],
                                        "compare_date": data[18],
                                        "question": data[19],
                                        "question_type": data[20],
                                        "is_identity_visible": data[21],
                                        "subject": data[22],
                                        "topic": data[23],
                                        "text_reference": data[24],
                                        "toughness_count": data[25],
                                        "video_reference": data[26],
                                        "impression_count": data[27]
                                      });
                                      allQuestionsLocalDB!
                                          .put("data", allQuestionsData);

                                      ElegantNotification.success(
                                        title: Text("Congrats,"),
                                        description:
                                            Text("Your question posted successfully."),
                                      );

                                      question = "";
                                      latex = "";
                                      askYourDoubtSteps = 0;
                                      selectedSubjectIndex = -1;
                                      selectedTopicIndex = -1;
                                      data = [];
                                      ocrImageURL = "";
                                      referenceNotesAtttachedURL = "";
                                      referenceVideoAtttachedURL = "";
                                      referenceAudioAtttachedURL = "";
                                      referenceTextAtttached = "";
                                      notesAttached = false;
                                      videoAttached = false;
                                      audioAttached = false;
                                      textAttached = false;
                                      base64Image = "";
                                      latex = "";
                                      tex = [''];
                                      questionType = "text";
                                      callnow = false;
                                      _selectedDate = '';
                                      _selectedTime = '';
                                      _endTime = '';
                                      tagcount = 0;
                                      tagids = [];
                                      tagedUsersName = [];
                                      markupptext = '';
                                      tagedString = "";
                                      useridentity = true;
                                      isPostReady = false;
                                      textbt = true;
                                      videocallbt = false;
                                      audiocallbt = false;
                                      usercalllanguagepreference = "";
                                      answerpreference = 1;
                                      calltype = "";
                                      selectedSubject = "";
                                      selectedTopic = "";
                                      Navigator.of(_keyLoader.currentContext!,
                                              rootNavigator: true)
                                          .pop();
                                      Navigator.of(context).pop();
                                    } else {
                                      ElegantNotification.error(
                                        title: Text("Error..."),
                                        description: Text("Something wrong."),
                                      );
                                    }
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  primary: ((question != "") || (latex != ""))
                                      ? active
                                      : Colors.white54,
                                  onPrimary: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                ),
                              ),
                            )
                          : SizedBox(),
                    ],
                  ),
                ),
              );
            }));
  }

  String sharecomment = "";
  void _shareQuestionPostDialog(int questionIndex) {
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
                        SizedBox(width: 30),
                        Text(
                          "Share question",
                          style: TextStyle(
                            fontSize: 20,
                            color: Color(0xCB000000),
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            question = "";
                            latex = "";
                            askYourDoubtSteps = 0;
                            selectedSubjectIndex = -1;
                            selectedTopicIndex = -1;
                            sharecomment = "";
                            data = [];
                            ocrImageURL = "";
                            referenceNotesAtttachedURL = "";
                            referenceVideoAtttachedURL = "";
                            referenceAudioAtttachedURL = "";
                            referenceTextAtttached = "";
                            notesAttached = false;
                            videoAttached = false;
                            audioAttached = false;
                            textAttached = false;
                            base64Image = "";
                            latex = "";
                            tex = [''];
                            questionType = "text";
                            callnow = false;
                            _selectedDate = '';
                            _selectedTime = '';
                            _endTime = '';
                            tagcount = 0;
                            tagids = [];
                            tagedUsersName = [];
                            markupptext = '';
                            tagedString = "";
                            useridentity = true;
                            isPostReady = false;
                            textbt = true;
                            videocallbt = false;
                            audiocallbt = false;
                            usercalllanguagepreference = "";
                            answerpreference = 1;
                            calltype = "";
                            selectedSubject = "";
                            selectedTopic = "";
                            Navigator.pop(context);
                          },
                          icon: Tab(
                              child: Icon(Icons.cancel_rounded,
                                  color: Colors.black45, size: 25)),
                        )
                      ],
                    ),
                    SizedBox(height: 20),
                    Container(height: 1, width: 500, color: Colors.grey[200]),
                  ],
                ),
                content: Container(
                  height: 470,
                  width: 500,
                  child: ListView(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(5),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.deepPurple.withOpacity(0.1),
                                  spreadRadius: 5,
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              child: Container(
                                  width: 100,
                                  height: 40,
                                  child: Center(
                                      child: Text("Post",
                                          style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: (sharecomment != "")
                                                  ? Colors.white
                                                  : Colors.grey[400])))),
                              onPressed: () async {
                                if (sharecomment != "") {
                                  setState(() {
                                    tagids.clear();
                                    tagedUsersName.clear();
                                    print(markupptext);
                                    for (int l = 0;
                                        l < markupptext.length - 4;
                                        l++) {
                                      int k = l;
                                      if (markupptext.substring(k, k + 1) ==
                                          "@") {
                                        String test1 = markupptext.substring(k);
                                        print(
                                            "tagid ${test1.substring(4, test1.indexOf("__]"))}");
                                        tagids.add(test1.substring(
                                            4, test1.indexOf("__]")));
                                      }

                                      if (markupptext.substring(k, k + 3) ==
                                          "(__") {
                                        String test2 = markupptext.substring(k);
                                        print(test2);
                                        tagedUsersName.add(test2.substring(
                                            3, test2.indexOf("__)")));
                                        print(
                                            "tagusername ${test2.substring(3, test2.indexOf("__)"))}");
                                      }
                                    }
                                    print(tagedUsersName);
                                    print(tagids);
                                    data = [
                                      _currentUserId + comparedate,
                                      _currentUserId,
                                      0,
                                      allQuestionsData[questionIndex]
                                          ["question_id"],
                                      "",
                                      "",
                                      "",
                                      "",
                                      "",
                                      "",
                                      0,
                                      0,
                                      0,
                                      0,
                                      userDataDB!.get("grade"),
                                      0,
                                      "",
                                      "",
                                      comparedate,
                                      sharecomment,
                                      "shared",
                                      useridentity.toString(),
                                      "",
                                      "",
                                      "",
                                      0,
                                      "",
                                      0
                                    ];
                                  });
                                  if (tagids.isNotEmpty) {
                                    for (int i = 0; i < tagids.length; i++) {
                                      await dataLoad
                                          .postUsertaggedInQuestionData([
                                        _currentUserId + comparedate,
                                        tagids[i]
                                      ]);
                                    }
                                  }
                                  bool x =
                                      await dataLoad.postUserQuestionData(data);
                                  if (x == true) {
                                    allQuestionsData.insert(0, {
                                      "first_name":
                                          userDataDB!.get("first_name"),
                                      "last_name": userDataDB!.get("last_name"),
                                      "profilepic":
                                          userDataDB!.get("profilepic"),
                                      "school_name":
                                          userDataDB!.get("school_name"),
                                      "question_id": data[0],
                                      "user_id": data[1],
                                      "answer_count": data[2],
                                      "answer_preference": data[3],
                                      "audio_reference": data[4],
                                      "call_date": data[5],
                                      "call_end_time": data[6],
                                      "call_now": data[7],
                                      "call_preferred_lang": data[8],
                                      "call_start_time": data[9],
                                      "answer_credit": data[10],
                                      "question_credit": data[11],
                                      "view_count": data[12],
                                      "examlikelyhood_count": data[13],
                                      "grade": data[14],
                                      "like_count": data[15],
                                      "note_reference": data[16],
                                      "ocr_image": data[17],
                                      "compare_date": data[18],
                                      "question": data[19],
                                      "question_type": data[20],
                                      "is_identity_visible": data[21],
                                      "subject": data[22],
                                      "topic": data[23],
                                      "text_reference": data[24],
                                      "toughness_count": data[25],
                                      "video_reference": data[26],
                                      "impression_count": data[27]
                                    });
                                    allQuestionsLocalDB!
                                        .put("data", allQuestionsData);
                                    ElegantNotification.success(
                                      title: Text("Congrats,"),
                                      description:
                                          Text("Your shared question posted successfully."),
                                    );

                                    question = "";
                                    latex = "";
                                    askYourDoubtSteps = 0;
                                    selectedSubjectIndex = -1;
                                    selectedTopicIndex = -1;
                                    data = [];
                                    ocrImageURL = "";
                                    referenceNotesAtttachedURL = "";
                                    referenceVideoAtttachedURL = "";
                                    referenceAudioAtttachedURL = "";
                                    referenceTextAtttached = "";
                                    notesAttached = false;
                                    videoAttached = false;
                                    audioAttached = false;
                                    textAttached = false;
                                    base64Image = "";
                                    latex = "";
                                    sharecomment = "";
                                    tex = [''];
                                    questionType = "text";
                                    callnow = false;
                                    _selectedDate = '';
                                    _selectedTime = '';
                                    _endTime = '';
                                    tagcount = 0;
                                    tagids = [];
                                    tagedUsersName = [];
                                    markupptext = '';
                                    tagedString = "";
                                    useridentity = true;
                                    isPostReady = false;
                                    textbt = true;
                                    videocallbt = false;
                                    audiocallbt = false;
                                    usercalllanguagepreference = "";
                                    answerpreference = 1;
                                    calltype = "";
                                    selectedSubject = "";
                                    selectedTopic = "";
                                    Navigator.of(context).pop();
                                  } else {
                                    ElegantNotification.error(
                                      title:Text( "Error..."),
                                      description: Text("Something wrong."),
                                    );
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                primary: (sharecomment != "")
                                    ? active
                                    : Colors.white54,
                                onPrimary: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 20)
                        ],
                      ),
                      SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            child: ClipOval(
                              child: Container(
                                width:
                                    MediaQuery.of(context).size.width / 10.34,
                                height:
                                    MediaQuery.of(context).size.width / 10.34,
                                child: CachedNetworkImage(
                                  imageUrl: (userDataDB!.get("profilepic"))
                                      .toString(),
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(
                                    height: 30,
                                    width: 30,
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
                          SizedBox(
                            width: 10,
                          ),
                          RichText(
                              text: TextSpan(
                                  text: (userDataDB!.get("first_name"))
                                          .toString() +
                                      " " +
                                      (userDataDB!.get("last_name")).toString(),
                                  style: TextStyle(
                                    fontFamily: 'Nunito Sans',
                                    fontSize: 14,
                                    color: Color.fromRGBO(0, 0, 0, 0.7),
                                    fontWeight: FontWeight.bold,
                                  ),
                                  children: <TextSpan>[
                                TextSpan(
                                  text: '  shared',
                                  style: TextStyle(
                                    fontFamily: 'Nunito Sans',
                                    fontSize: 12,
                                    color: Color.fromRGBO(0, 0, 0, 0.7),
                                    fontWeight: FontWeight.w500,
                                  ),
                                )
                              ])),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.only(
                            left: (20.0), right: 10, top: 10, bottom: 10),
                        child: FlutterMentions(
                          key: key,
                          autofocus: true,
                          keyboardType: TextInputType.text,
                          cursorColor: Color(0xff0962ff),
                          style: TextStyle(
                              fontSize: 15,
                              color: Color(0xff0962ff),
                              fontWeight: FontWeight.w500),
                          decoration: new InputDecoration(
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              hintText: "What do you want to talk about?",
                              hintStyle: TextStyle(
                                  color: Colors.black45, fontSize: 15)),
                          suggestionPosition: SuggestionPosition.Bottom,
                          onMarkupChanged: (val) {
                            setState(() {
                              markupptext = val;
                            });
                          },
                          onEditingComplete: () {
                            setState(() {
                              tagids.clear();
                              for (int l = 0; l < markupptext.length; l++) {
                                int k = l;
                                if (markupptext.substring(k, k + 1) == "@") {
                                  String test1 = markupptext.substring(k);
                                  tagids.add(
                                      test1.substring(4, test1.indexOf("__]")));
                                }
                              }
                              print(tagids);
                            });
                          },
                          onSuggestionVisibleChanged: (val) {
                            setState(() {
                              _showList = val;
                            });
                          },
                          onChanged: (val) {
                            setState(() {
                              sharecomment = val;
                            });
                          },
                          onSearchChanged: (
                            trigger,
                            value,
                          ) {
                            print('again | $trigger | $value ');
                          },
                          hideSuggestionList: false,
                          minLines: 1,
                          maxLines: 3,
                          mentions: [
                            Mention(
                                trigger: r'@',
                                style: TextStyle(
                                  color: Color(0xff0C2551),
                                ),
                                matchAll: false,
                                data: _users,
                                suggestionBuilder: (data) {
                                  return Container(
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border(
                                            top: BorderSide(
                                                color: Color(0xFFE0E1E4)))),
                                    padding: EdgeInsets.all(10.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: <Widget>[
                                        CircleAvatar(
                                          backgroundImage: NetworkImage(
                                            data['photo'],
                                          ),
                                        ),
                                        SizedBox(
                                          width: 20.0,
                                        ),
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Text(data['display']),
                                              ],
                                            ),
                                            SizedBox(
                                              height: 3,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Text(
                                                  '${data['full_name']}',
                                                  style: TextStyle(
                                                    color: Color(0xFFAAABAD),
                                                    fontSize: 11,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  );
                                }),
                          ],
                        ),
                      ),
                      allQuestionsData[questionIndex]["question_type"] == "text"
                          ? InkWell(
                              onTap: () {},
                              child: Container(
                                padding: EdgeInsets.all(10),
                                color: Color.fromRGBO(242, 246, 248, 1),
                                width: _width! > 530 ? 450 : _width! - 30,
                                margin: EdgeInsets.fromLTRB(10, 10, 0, 2),
                                child: ReadMoreText(
                                  allQuestionsData[questionIndex]["question"],
                                  textAlign: TextAlign.left,
                                  trimLines: 4,
                                  colorClickableText: Color(0xff0962ff),
                                  trimMode: TrimMode.Line,
                                  trimCollapsedText: 'read more',
                                  trimExpandedText: 'Show less',
                                  style: TextStyle(
                                    fontFamily: 'Nunito Sans',
                                    fontSize: 16,
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
                                      allQuestionsData[questionIndex]
                                          ["question"],
                                      style: TeXViewStyle(
                                        fontStyle: TeXViewFontStyle(
                                            fontSize: 12,
                                            sizeUnit: TeXViewSizeUnit.pt),
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
              );
            }));
  }

  void _chooseUserIdentity() {
    showDialog(
        context: context,
        barrierColor: Colors.grey.withOpacity(0.2),
        barrierDismissible: false,
        builder: (_) => StatefulBuilder(builder: (context, setState) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0)),
                content: Container(
                  height: 150,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      InkWell(
                        onTap: () {
                          setState(() {
                            useridentity = true;
                            Navigator.of(context).pop();
                            Navigator.of(context).pop();
                            _addQuestionPostDialog();
                          });
                        },
                        child: Container(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    "Public",
                                    style: TextStyle(
                                      color: Colors.black45,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 15,
                                    ),
                                    textAlign: TextAlign.start,
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  useridentity == true
                                      ? Icon(Icons.check_outlined,
                                          color: Colors.green, size: 15)
                                      : SizedBox()
                                ],
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              Text(
                                "Others will see your identity alongside with this question on your profile and in their feeds.",
                                style: TextStyle(
                                  color: Colors.black45,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.start,
                              ),
                            ],
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          setState(() {
                            useridentity = false;
                            Navigator.of(context).pop();
                            Navigator.of(context).pop();
                            _addQuestionPostDialog();
                          });
                        },
                        child: Container(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    "Anonymous",
                                    style: TextStyle(
                                      color: Colors.black45,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 15,
                                    ),
                                    textAlign: TextAlign.start,
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  useridentity == false
                                      ? Icon(Icons.check_outlined,
                                          color: Colors.green, size: 15)
                                      : SizedBox()
                                ],
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              Text(
                                "Your identity will never be associated with question.",
                                style: TextStyle(
                                  color: Colors.black45,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.start,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }));
  }

  String ocrImageURL = "";
  String referenceNotesAtttachedURL = "";
  String referenceVideoAtttachedURL = "";
  String referenceAudioAtttachedURL = "";
  String referenceTextAtttached = "";

  bool notesAttached = false;
  bool videoAttached = false;
  bool audioAttached = false;
  bool textAttached = false;

  _reference(BuildContext context) {
    return Container(
        height: 90,
        child: ListView(
          scrollDirection: Axis.horizontal,
          physics: BouncingScrollPhysics(),
          children: [
            InkWell(
              onTap: () async {
                _pickNotes(context);
              },
              child: Container(
                width: 90,
                height: 80,
                margin: EdgeInsets.only(right: 20, left: 20),
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: notesAttached == true
                      ? Color.fromRGBO(88, 165, 196, 1)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Center(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.note_add_outlined,
                        color: notesAttached == false
                            ? Color.fromRGBO(88, 165, 196, 1)
                            : Colors.white,
                        size: 25),
                    SizedBox(height: 10),
                    Text(
                      "Notes",
                      style: TextStyle(
                        fontFamily: 'Nunito Sans',
                        fontSize: 12,
                        color: notesAttached == false
                            ? Color.fromRGBO(88, 165, 196, 1)
                            : Colors.white,
                      ),
                    )
                  ],
                )),
              ),
            ),
            InkWell(
              onTap: () async {
                _pickVideo(context);
              },
              child: Container(
                width: 90,
                height: 80,
                margin: EdgeInsets.only(right: 20, left: 20),
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: videoAttached == true
                      ? Color.fromRGBO(88, 165, 196, 1)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Center(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.video_label_outlined,
                        color: videoAttached == false
                            ? Color.fromRGBO(88, 165, 196, 1)
                            : Colors.white,
                        size: 25),
                    SizedBox(height: 10),
                    Text(
                      "Video\nExplainer",
                      style: TextStyle(
                        fontFamily: 'Nunito Sans',
                        fontSize: 12,
                        color: videoAttached == false
                            ? Color.fromRGBO(88, 165, 196, 1)
                            : Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    )
                  ],
                )),
              ),
            ),
            InkWell(
              onTap: () {
                _pickAudio(context);
              },
              child: Container(
                width: 90,
                height: 80,
                margin: EdgeInsets.only(right: 20, left: 20),
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: audioAttached == true
                      ? Color.fromRGBO(88, 165, 196, 1)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Center(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.music_note_outlined,
                        color: audioAttached == false
                            ? Color.fromRGBO(88, 165, 196, 1)
                            : Colors.white,
                        size: 25),
                    SizedBox(height: 10),
                    Text(
                      "Audio\nExplainer",
                      style: TextStyle(
                        fontFamily: 'Nunito Sans',
                        fontSize: 12,
                        color: audioAttached == false
                            ? Color.fromRGBO(88, 165, 196, 1)
                            : Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    )
                  ],
                )),
              ),
            ),
            InkWell(
              onTap: () {
                pickTextReferenceDialog("");
              },
              child: Container(
                width: 90,
                height: 80,
                margin: EdgeInsets.only(right: 20, left: 20),
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: textAttached == true
                      ? Color.fromRGBO(88, 165, 196, 1)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Center(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.bookmark_border_outlined,
                        color: textAttached == false
                            ? Color.fromRGBO(88, 165, 196, 1)
                            : Colors.white,
                        size: 25),
                    SizedBox(height: 10),
                    Text(
                      "Reference",
                      style: TextStyle(
                        fontFamily: 'Nunito Sans',
                        fontSize: 12,
                        color: textAttached == false
                            ? Color.fromRGBO(88, 165, 196, 1)
                            : Colors.white,
                      ),
                    )
                  ],
                )),
              ),
            ),
          ],
        ));
  }

  double progress = 0.0;
  String base64Image = "";
  Map? totaldata;
  String latex = "";
  List tex = [''];

  void _pickImage(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      Uint8List? file = result.files.first.bytes;
      String fileName = result.files.first.name;

      var cropResult = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (ctx) => Cropper(file!),
        ),
      );
      var _image = await cropResult;
      if (_image != null) {
        base64Image = base64Encode(_image);
        Dialogs.showLoadingDialog(context, _keyLoader);
        final http.Response response = await http.post(
          Uri.parse('https://api.mathpix.com/v3/text'),
          headers: <String, String>{
            'Content-Type': 'application/json',
            'app_id': 'shubham_sparrowrms_in_f5ee1d_512d15',
            'app_key': 'a95e398dbb1b1faf2af3',
          },
          body: jsonEncode(<String, dynamic>{
            "src": "data:image/jpeg;base64," + base64Image,
            "formats": ["text", "data"],
            "data_options": {"include_asciimath": false, "include_latex": true}
          }),
        );

        print(response.statusCode);

        if ((response.statusCode == 200) || (response.statusCode == 201)) {
          setState(() {
            totaldata = json.decode(response.body);
            latex = totaldata!["text"];
            print(totaldata!["data"]);
            for (int i = 0; i < totaldata!["data"].length; i++) {
              tex.add(totaldata!["data"][i]['value']);
            }
          });
          //image upload on FB Storage
          UploadTask task = FirebaseStorage.instance
              .ref()
              .child("userQuestionOCR/$_currentUserId/$fileName")
              .putData(_image);

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
                  .ref("userQuestionOCR/$_currentUserId/$fileName")
                  .getDownloadURL();
              if (downloadURL != null) {
                Navigator.of(_keyLoader.currentContext!, rootNavigator: true)
                    .pop(); //close the dialoge
                setState(() {
                  ocrImageURL = downloadURL;
                  print(downloadURL);
                  notesAttached = true;
                  progress = 0.0;

                  askYourDoubtSteps = 3;
                });

                Navigator.of(context).pop();
                _addQuestionPostDialog();
              }
            }
          });
        }
      }
    }
  }

  void _pickNotes(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      Dialogs.showLoadingDialog(context, _keyLoader);

      Uint8List? file = result.files.first.bytes;
      String fileName = result.files.first.name;
      UploadTask task = FirebaseStorage.instance
          .ref()
          .child("userNotesReference/$_currentUserId/$fileName")
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
              .ref("userNotesReference/$_currentUserId/$fileName")
              .getDownloadURL();
          if (downloadURL != null) {
            Navigator.of(_keyLoader.currentContext!, rootNavigator: true)
                .pop(); //close the dialoge
            setState(() {
              referenceNotesAtttachedURL = downloadURL;
              print(downloadURL);
              notesAttached = true;
              progress = 0.0;
            });
            Navigator.of(context).pop();
            ElegantNotification.success(
              title:Text( "Congrats,"),
              description: Text("You attatched note successfully."),
            );
            _addQuestionPostDialog();
          }
        }
      });
    }
  }

  void _pickVideo(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      Uint8List? file = result.files.first.bytes;
      String fileName = result.files.first.name;
      Dialogs.showLoadingDialog(context, _keyLoader);
      UploadTask task = FirebaseStorage.instance
          .ref()
          .child("userVideoReference/$_currentUserId/$fileName")
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
              .ref("userVideoReference/$_currentUserId/$fileName")
              .getDownloadURL();
          if (downloadURL != null) {
            Navigator.of(_keyLoader.currentContext!, rootNavigator: true)
                .pop(); //close the dialoge
            setState(() {
              referenceVideoAtttachedURL = downloadURL;
              print(downloadURL);
              videoAttached = true;
              progress = 0.0;
            });
            Navigator.of(context).pop();
            ElegantNotification.success(
              title: Text("Congrats,"),
              description: Text("You attatched video file successfully."),
            );

            _addQuestionPostDialog();
          }
        }
      });
    }
  }

  void _pickAudio(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      Uint8List? file = result.files.first.bytes;
      String fileName = result.files.first.name;
      Dialogs.showLoadingDialog(context, _keyLoader);
      UploadTask task = FirebaseStorage.instance
          .ref()
          .child("userAudioReference/$_currentUserId/$fileName")
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
              .ref("userAudioReference/$_currentUserId/$fileName")
              .getDownloadURL();
          if (downloadURL != null) {
            setState(() {
              Navigator.of(_keyLoader.currentContext!, rootNavigator: true)
                  .pop(); //close the dialoge
              referenceVideoAtttachedURL = downloadURL;
              print(downloadURL);
              audioAttached = true;
              progress = 0.0;
            });

            Navigator.of(context).pop();
            ElegantNotification.success(
              title:Text( "Congrats,"),
              description: Text("You attatched audio file successfully."),
            );

            _addQuestionPostDialog();
          }
        }
      });
    }
  }

  void pickTextReferenceDialog(String x) {
    showDialog(
        context: context,
        barrierColor: Colors.grey.withOpacity(0.2),
        barrierDismissible: false,
        builder: (_) => StatefulBuilder(builder: (context, setState) {
              return AlertDialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0)),
                  content: Container(
                    height: 200,
                    child: Column(
                      children: [
                        SizedBox(height: 30),
                        Container(
                          padding:
                              EdgeInsets.only(left: 15, right: 15, bottom: 5),
                          child: TextFormField(
                            maxLines: 4,
                            initialValue: x,
                            keyboardType: TextInputType.text,
                            cursorColor: Color.fromRGBO(88, 165, 196, 1),
                            style: TextStyle(
                                fontSize: 12,
                                color: Color.fromRGBO(88, 165, 196, 1),
                                fontWeight: FontWeight.w500),
                            onChanged: (val) {
                              setState(() => referenceTextAtttached = val);
                            },
                            decoration: InputDecoration(
                              fillColor: Color.fromRGBO(245, 245, 245, 1),
                              filled: true,
                              counterText: '',
                              hintText:
                                  'Add reference like Book Name, Page No.',
                              hintStyle: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[350],
                                  fontWeight: FontWeight.w600),
                              alignLabelWithHint: false,
                              contentPadding: new EdgeInsets.symmetric(
                                  vertical: 10.0, horizontal: 10),
                              errorStyle: TextStyle(
                                  color: Color.fromRGBO(240, 20, 41, 1)),
                              focusColor: Color.fromRGBO(88, 165, 196, 1),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                    color: Color.fromRGBO(245, 245, 245, 1)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: Color.fromRGBO(245, 245, 245, 1),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: EdgeInsets.all(5),
                              width: 160,
                              child: RaisedButton(
                                  shape: RoundedRectangleBorder(
                                      side: BorderSide(
                                          color:
                                              Color.fromRGBO(88, 165, 196, 1)),
                                      borderRadius:
                                          BorderRadius.circular(100.0)),
                                  color: Color.fromRGBO(88, 165, 196, 1),
                                  splashColor: Color.fromRGBO(88, 165, 196, 1),
                                  child: Center(
                                      child: Text(
                                    'Save',
                                    style: GoogleFonts.raleway(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 14),
                                  )),
                                  onPressed: () {
                                    if (referenceTextAtttached != "") {
                                      setState(() {
                                        textAttached = true;
                                        Navigator.pop(context);
                                      });
                                    }
                                  }),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ));
            }));
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

  _answertpe(BuildContext context) {
    return Container(
        height: 80,
        child: ListView(
          scrollDirection: Axis.horizontal,
          physics: BouncingScrollPhysics(),
          children: [
            InkWell(
              onTap: () {
                setState(() {
                  textbt = true;
                });
              },
              child: Container(
                width: 70,
                height: 70,
                margin: EdgeInsets.only(right: 20, left: 20),
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: textbt == false
                      ? Colors.white
                      : Color.fromRGBO(88, 165, 196, 1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Center(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.note_add_outlined,
                        color: textbt == true
                            ? Colors.white
                            : Color.fromRGBO(88, 165, 196, 1),
                        size: 25),
                    SizedBox(height: 10),
                    Text(
                      "Text",
                      style: TextStyle(
                          fontFamily: 'Nunito Sans',
                          fontSize: 12,
                          color: textbt == true
                              ? Colors.white
                              : Color.fromRGBO(88, 165, 196, 1)),
                    )
                  ],
                )),
              ),
            ),
            InkWell(
              onTap: () {
                setState(() {
                  videocallbt = !videocallbt;
                  audiocallbt = false;
                  answerpreference = 2;
                  if (videocallbt == true) {
                    _chooseYourPreferredLanguage();
                  } else {
                    usercalllanguagepreference = "";
                    calltype = "Video";
                    Navigator.of(context).pop();
                    _addQuestionPostDialog();
                  }
                });
              },
              child: Container(
                width: 70,
                height: 70,
                margin: EdgeInsets.only(right: 20, left: 20),
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: videocallbt == false
                      ? Colors.white
                      : Color.fromRGBO(88, 165, 196, 1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Center(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.video_label_outlined,
                        color: videocallbt == true
                            ? Colors.white
                            : Color.fromRGBO(88, 165, 196, 1),
                        size: 25),
                    SizedBox(height: 10),
                    Text(
                      "Video\nCall",
                      style: TextStyle(
                        fontFamily: 'Nunito Sans',
                        fontSize: 12,
                        color: videocallbt == true
                            ? Colors.white
                            : Color.fromRGBO(88, 165, 196, 1),
                      ),
                      textAlign: TextAlign.center,
                    )
                  ],
                )),
              ),
            ),
            InkWell(
              onTap: () {
                setState(() {
                  videocallbt = false;
                  audiocallbt = !audiocallbt;
                  answerpreference = 3;
                  calltype = "Audio";
                  if (audiocallbt == true) {
                    _chooseYourPreferredLanguage();
                  } else {
                    usercalllanguagepreference = "";
                    Navigator.of(context).pop();
                    _addQuestionPostDialog();
                  }
                });
              },
              child: Container(
                width: 70,
                height: 70,
                margin: EdgeInsets.only(right: 20, left: 20),
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: audiocallbt == false
                      ? Colors.white
                      : Color.fromRGBO(88, 165, 196, 1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Center(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.music_note_outlined,
                        color: audiocallbt == true
                            ? Colors.white
                            : Color.fromRGBO(88, 165, 196, 1),
                        size: 25),
                    SizedBox(height: 10),
                    Text(
                      "Audio\nCall",
                      style: TextStyle(
                        fontFamily: 'Nunito Sans',
                        fontSize: 12,
                        color: audiocallbt == true
                            ? Colors.white
                            : Color.fromRGBO(88, 165, 196, 1),
                      ),
                      textAlign: TextAlign.center,
                    )
                  ],
                )),
              ),
            ),
            usercalllanguagepreference != ""
                ? InkWell(
                    onTap: () {
                      setState(() {
                        _chooseYourPreferredLanguage();
                      });
                    },
                    child: Container(
                      width: 70,
                      height: 70,
                      margin: EdgeInsets.only(right: 20, left: 20),
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: usercalllanguagepreference == ""
                            ? Colors.white
                            : Color.fromRGBO(88, 165, 196, 1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Center(
                          child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.language_outlined,
                              color: usercalllanguagepreference != ""
                                  ? Colors.white
                                  : Color.fromRGBO(88, 165, 196, 1),
                              size: 25),
                          SizedBox(height: 10),
                          Text(
                            "Prefered\nLanguage",
                            style: TextStyle(
                              fontFamily: 'Nunito Sans',
                              fontSize: 12,
                              color: usercalllanguagepreference != ""
                                  ? Colors.white
                                  : Color.fromRGBO(88, 165, 196, 1),
                            ),
                          )
                        ],
                      )),
                    ),
                  )
                : SizedBox(),
          ],
        ));
  }

  void _chooseYourPreferredLanguage() {
    List preferedLanguages = userDataDB!.get("preferred_lang");
    showDialog(
        context: context,
        barrierColor: Colors.grey.withOpacity(0.2),
        barrierDismissible: false,
        builder: (_) => StatefulBuilder(builder: (context, setState) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0)),
                title: Text(
                  "Choose Preferred Language",
                  style: TextStyle(fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                content: Container(
                    height: preferedLanguages.length.toDouble() * 30,
                    width: 200,
                    child: ListView.builder(
                      itemCount: preferedLanguages.length,
                      itemBuilder: ((BuildContext context, int i) {
                        return InkWell(
                          onTap: () {
                            setState(() {
                              usercalllanguagepreference =
                                  preferedLanguages[i][0];
                              Navigator.of(context).pop();
                              Navigator.of(context).pop();
                              _addQuestionPostDialog();
                            });
                          },
                          child: Container(
                            color: usercalllanguagepreference ==
                                    preferedLanguages[i][0]
                                ? Color.fromRGBO(88, 165, 196, 1)
                                : Colors.white,
                            padding: EdgeInsets.fromLTRB(30, 5, 30, 5),
                            child: Text(preferedLanguages[i][0]),
                          ),
                        );
                      }),
                    )),
              );
            }));
  }

  _calltime(BuildContext context) {
    return Container(
      height: 80,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          InkWell(
            onTap: () {
              setState(() {
                callnow = !callnow;
              });
            },
            child: Container(
              width: 70,
              height: 70,
              margin: EdgeInsets.only(right: 20),
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: callnow == false
                    ? Colors.white
                    : Color.fromRGBO(88, 165, 196, 1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Center(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.call,
                      color: callnow == true
                          ? Colors.white
                          : Color.fromRGBO(88, 165, 196, 1),
                      size: 25),
                  SizedBox(height: 10),
                  Text(
                    "Now",
                    style: TextStyle(
                      fontFamily: 'Nunito Sans',
                      fontSize: 13,
                      color: callnow == true
                          ? Colors.white
                          : Color.fromRGBO(88, 165, 196, 1),
                    ),
                  )
                ],
              )),
            ),
          ),
          InkWell(
            onTap: () {
              setState(() {
                callnow = false;
              });
              showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(Duration(days: 1)))
                  .then((value) {
                setState(() {
                  callnow = false;
                  _dTime = value!;
                  _selectedDate = DateFormat("dd/MM/yyyy").format(_dTime!);
                  print(
                    _selectedDate.substring(0, 10),
                  );
                  Navigator.of(context).pop();
                  _addQuestionPostDialog();
                });
              });
            },
            child: Container(
              height: 70,
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Date",
                      style: TextStyle(
                        fontFamily: 'Nunito Sans',
                        fontSize: 12,
                        color: Color.fromRGBO(88, 165, 196, 1),
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    InkWell(
                      child: Text(
                          _dTime == null
                              ? "dd/MM/yyyy"
                              : _selectedDate.toString(),
                          textAlign: TextAlign.center,
                          style: GoogleFonts.raleway(
                              color: _dTime == null
                                  ? Colors.grey[350]
                                  : Color.fromRGBO(88, 165, 196, 1),
                              fontSize: _dTime == null ? 12 : 12)),
                    ),
                  ],
                ),
              ),
            ),
          ),
          InkWell(
            onTap: () {
              if (_dTime != null) {
                setState(() {
                  callnow = false;
                });
                showTimePicker(context: context, initialTime: TimeOfDay.now())
                    .then((value) {
                  var x;
                  var y;
                  setState(() {
                    callnow = false;
                    _td = value;
                    x = DateTime(00, 00, 00, _td!.hour, _td!.minute);
                    y = DateTime(00, 00, 00, _td!.hour, _td!.minute)
                        .add(Duration(minutes: 10));
                    _selectedTime = DateFormat("HH:mm").format(x);
                    _endTime = DateFormat("HH:mm").format(y);
                    print(_selectedTime);
                    print(_endTime);
                    Navigator.of(context).pop();
                    _addQuestionPostDialog();
                  });
                });
              }
            },
            child: Container(
              height: 70,
              margin: EdgeInsets.only(top: 2),
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Time Start",
                      style: TextStyle(
                        fontFamily: 'Nunito Sans',
                        fontSize: 12,
                        color: Color.fromRGBO(88, 165, 196, 1),
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    InkWell(
                      child: Text(
                          _selectedTime == ""
                              ? "00:00"
                              : _selectedTime.toString(),
                          textAlign: TextAlign.center,
                          style: GoogleFonts.raleway(
                              color: _selectedTime == ""
                                  ? Colors.grey[350]
                                  : Color.fromRGBO(88, 165, 196, 1),
                              fontSize: _dTime == null ? 12 : 12)),
                    ),
                  ],
                ),
              ),
            ),
          ),
          InkWell(
            child: Container(
              height: 70,
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Time End",
                      style: TextStyle(
                        fontFamily: 'Nunito Sans',
                        fontSize: 12,
                        color: Color.fromRGBO(88, 165, 196, 1),
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    InkWell(
                      child: Text(
                          _endTime == "" ? "00:00" : _endTime.toString(),
                          textAlign: TextAlign.center,
                          style: GoogleFonts.raleway(
                              color: _endTime == ""
                                  ? Colors.grey[350]
                                  : Color.fromRGBO(88, 165, 196, 1),
                              fontSize: _dTime == null ? 12 : 12)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

//Answer Post

  bool ansPostVisibility = false;
  String answerType = 'text';
  String answer = "";
  String ansocrImageURL = "";
  String ansImageURL = "";
  String ansreferenceNotesAtttachedURL = "";
  String ansreferenceVideoAtttachedURL = "";
  String ansreferenceAudioAtttachedURL = "";
  String ansreferenceTextAtttached = "";

  bool ansnotesAttached = false;
  bool ansvideoAttached = false;
  bool ansaudioAttached = false;
  bool anstextAttached = false;

  void _addAnswerPostDialog(int qIndex) {
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
                        SizedBox(width: 30),
                        Text(
                          "Post your answer",
                          style: TextStyle(
                            fontSize: 20,
                            color: Color(0xCB000000),
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            ansPostVisibility = false;
                            answerType = 'text';
                            answer = "";
                            ansocrImageURL = "";
                            ansreferenceNotesAtttachedURL = "";
                            ansreferenceVideoAtttachedURL = "";
                            ansreferenceAudioAtttachedURL = "";
                            ansreferenceTextAtttached = "";
                            ansImageURL = "";
                            ansnotesAttached = false;
                            ansvideoAttached = false;
                            ansaudioAttached = false;
                            anstextAttached = false;
                            Navigator.pop(context);
                          },
                          icon: Tab(
                              child: Icon(Icons.cancel_rounded,
                                  color: Colors.black45, size: 25)),
                        )
                      ],
                    ),
                    SizedBox(height: 20),
                    Container(height: 1, width: 500, color: Colors.grey[200]),
                  ],
                ),
                content: Container(
                  height: 470,
                  width: 500,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                                ansPostVisibility == false
                                    ? "Choose answer type"
                                    : "Post answer",
                                style: TextStyle(
                                    fontSize: 16, color: Colors.black54)),
                            ansPostVisibility == true
                                ? IconButton(
                                    onPressed: () {
                                      if (ansPostVisibility == true) {
                                        setState(() {
                                          ansPostVisibility = false;
                                        });
                                      }
                                    },
                                    icon: Icon(Icons.arrow_back_ios,
                                        color: Colors.black54, size: 22))
                                : SizedBox(width: 20)
                          ],
                        ),
                        SizedBox(height: 10),
                        ansPostVisibility == true
                            ? Container(
                                margin: EdgeInsets.fromLTRB(20, 0, 20, 0),
                                padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                                decoration: BoxDecoration(
                                    color: Color.fromRGBO(242, 246, 248, 1),
                                    borderRadius: BorderRadius.circular(10)),
                                child: allQuestionsData[qIndex]
                                            ["question_type"] ==
                                        "text"
                                    ? InkWell(
                                        child: Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width -
                                              30,
                                          margin:
                                              EdgeInsets.fromLTRB(10, 10, 0, 2),
                                          child: ReadMoreText(
                                            allQuestionsData[qIndex]
                                                ["question"],
                                            textAlign: TextAlign.left,
                                            trimLines: 4,
                                            colorClickableText:
                                                Color(0xff0962ff),
                                            trimMode: TrimMode.Line,
                                            trimCollapsedText: 'read more',
                                            trimExpandedText: 'Show less',
                                            style: TextStyle(
                                              fontFamily: 'Nunito Sans',
                                              fontSize: 16,
                                              color:
                                                  Color.fromRGBO(0, 0, 0, 0.8),
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
                                        margin:
                                            EdgeInsets.fromLTRB(1, 10, 1, 10),
                                        child: TeXView(
                                          child: TeXViewColumn(children: [
                                            TeXViewDocument(
                                                allQuestionsData[qIndex]
                                                    ["question"],
                                                style: TeXViewStyle(
                                                  fontStyle: TeXViewFontStyle(
                                                      fontSize: 12,
                                                      sizeUnit:
                                                          TeXViewSizeUnit.pt),
                                                  padding:
                                                      TeXViewPadding.all(10),
                                                )),
                                          ]),
                                          style: TeXViewStyle(
                                            elevation: 10,
                                            backgroundColor: Color.fromRGBO(
                                                242, 246, 248, 1),
                                          ),
                                        ),
                                      ),
                              )
                            : SizedBox(),
                        SizedBox(height: 10),
                        ansPostVisibility == false
                            ? Container(
                                height: 350,
                                margin: EdgeInsets.fromLTRB(20, 0, 20, 0),
                                child: Column(
                                  children: [
                                    SizedBox(
                                      height: 10,
                                    ),
                                    SizedBox(
                                      height: 30,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            setState(() {
                                              answerType = "ocr";
                                              _anspickImage(context, qIndex);
                                            });
                                          },
                                          child: Column(
                                            children: [
                                              Image.network(
                                                  "https://firebasestorage.googleapis.com/v0/b/hys-pro-41c66.appspot.com/o/assets%2Focr1.gif?alt=media&token=c0145d73-6635-4b39-a296-e2a851af5251",
                                                  height: 100,
                                                  width: 100),
                                              SizedBox(
                                                height: 7,
                                              ),
                                              Text(
                                                "OCR",
                                                style: TextStyle(
                                                  fontFamily: 'Nunito Sans',
                                                  fontSize: 15,
                                                  color: Color(0xff0C2551),
                                                  fontWeight: FontWeight.w700,
                                                ),
                                                textAlign: TextAlign.center,
                                              )
                                            ],
                                          ),
                                        ),
                                        InkWell(
                                          onTap: () {
                                            setState(() {
                                              answerType = "text";
                                              ansPostVisibility = true;
                                            });
                                          },
                                          child: Column(
                                            children: [
                                              Image.network(
                                                  "https://firebasestorage.googleapis.com/v0/b/hys-pro-41c66.appspot.com/o/assets%2Ftyping.gif?alt=media&token=1a4b65b2-c497-438b-8c3a-a69dcfc7f67d",
                                                  height: 100,
                                                  width: 100),
                                              SizedBox(
                                                height: 7,
                                              ),
                                              Text(
                                                "Keyboard",
                                                style: TextStyle(
                                                  fontFamily: 'Nunito Sans',
                                                  fontSize: 15,
                                                  color: Color(0xff0C2551),
                                                  fontWeight: FontWeight.w700,
                                                ),
                                                textAlign: TextAlign.center,
                                              )
                                            ],
                                          ),
                                        ),
                                        InkWell(
                                          onTap: () {
                                            setState(() {
                                              answerType = "image";
                                              _pickImageAnswer(context, qIndex);
                                            });
                                          },
                                          child: Column(
                                            children: [
                                              Image.network(
                                                  "https://firebasestorage.googleapis.com/v0/b/hys-pro-41c66.appspot.com/o/assets%2Fgallery.png?alt=media&token=09a32fa6-5e7c-4139-94e5-d4d74e5f5d6a",
                                                  height: 100,
                                                  width: 100),
                                              SizedBox(
                                                height: 7,
                                              ),
                                              Text(
                                                "Image",
                                                style: TextStyle(
                                                  fontFamily: 'Nunito Sans',
                                                  fontSize: 15,
                                                  color: Color(0xff0C2551),
                                                  fontWeight: FontWeight.w700,
                                                ),
                                                textAlign: TextAlign.center,
                                              )
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              )
                            : Container(
                                height: 350,
                                margin: EdgeInsets.fromLTRB(20, 0, 20, 0),
                                child: ListView(
                                  physics: BouncingScrollPhysics(),
                                  children: [
                                    SizedBox(
                                      height: 20,
                                    ),
                                    answerType == "text"
                                        ? Container(
                                            child: TextFormField(
                                              maxLines: 10,
                                              initialValue: question,
                                              keyboardType: TextInputType.text,
                                              cursorColor: Color.fromRGBO(
                                                  88, 165, 196, 1),
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  color: Color.fromRGBO(
                                                      88, 165, 196, 1),
                                                  fontWeight: FontWeight.w500),
                                              validator: (val) => ((val!
                                                      .isEmpty))
                                                  ? 'Leave your answer here, you can\'t kept it blank'
                                                  : null,
                                              onChanged: (val) {
                                                setState(() => answer = val);
                                              },
                                              decoration: InputDecoration(
                                                fillColor: Color.fromRGBO(
                                                    245, 245, 245, 1),
                                                filled: true,
                                                counterText: '',
                                                hintText: 'Your answer...',
                                                hintStyle: TextStyle(
                                                    fontSize: 18,
                                                    color: Colors.grey[300],
                                                    fontWeight:
                                                        FontWeight.w600),
                                                alignLabelWithHint: false,
                                                contentPadding:
                                                    new EdgeInsets.symmetric(
                                                        vertical: 10.0,
                                                        horizontal: 10),
                                                errorStyle: TextStyle(
                                                    color: Color.fromRGBO(
                                                        240, 20, 41, 1)),
                                                focusColor: Color.fromRGBO(
                                                    88, 165, 196, 1),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  borderSide: BorderSide(
                                                      color: Color.fromRGBO(
                                                          245, 245, 245, 1)),
                                                ),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  borderSide: BorderSide(
                                                    color: Color.fromRGBO(
                                                        245, 245, 245, 1),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          )
                                        : answerType == 'ocr'
                                            ? TeXView(
                                                child: TeXViewColumn(children: [
                                                  TeXViewDocument(latex,
                                                      style: TeXViewStyle(
                                                        fontStyle:
                                                            TeXViewFontStyle(
                                                                fontSize: 8,
                                                                sizeUnit:
                                                                    TeXViewSizeUnit
                                                                        .pt),
                                                        padding:
                                                            TeXViewPadding.all(
                                                                10),
                                                      )),
                                                ]),
                                                style: TeXViewStyle(
                                                  elevation: 10,
                                                  backgroundColor: Colors.white,
                                                ),
                                              )
                                            : Container(
                                                height: 100,
                                                child: CachedNetworkImage(
                                                  imageUrl: ansImageURL,
                                                  fit: BoxFit.contain,
                                                  placeholder: (context, url) =>
                                                      Container(
                                                    height: 30,
                                                    width: 30,
                                                    child: Image.network(
                                                      "https://firebasestorage.googleapis.com/v0/b/hys-pro-41c66.appspot.com/o/assets%2Floadingimg.gif?alt=media&token=4ca910f2-c584-4b3a-bbcb-2f1c01d93f67",
                                                    ),
                                                  ),
                                                  errorWidget:
                                                      (context, url, error) =>
                                                          Icon(Icons.error),
                                                ),
                                              ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Container(
                                      height: 50,
                                      width: 400,
                                      child: FlutterMentions(
                                        key: key,
                                        keyboardType: TextInputType.text,
                                        cursorColor:
                                            Color.fromRGBO(88, 165, 196, 1),
                                        decoration: InputDecoration(
                                          fillColor:
                                              Color.fromRGBO(245, 245, 245, 1),
                                          filled: true,
                                          counterText: '',
                                          hintText: '@Tag someone here',
                                          hintStyle: TextStyle(
                                              fontSize: 13,
                                              color: Colors.grey[350],
                                              fontWeight: FontWeight.w600),
                                          alignLabelWithHint: false,
                                          contentPadding:
                                              new EdgeInsets.symmetric(
                                                  vertical: 10.0,
                                                  horizontal: 10),
                                          errorStyle: TextStyle(
                                              color: Color.fromRGBO(
                                                  240, 20, 41, 1)),
                                          focusColor:
                                              Color.fromRGBO(88, 165, 196, 1),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            borderSide: BorderSide(
                                                color: Color.fromRGBO(
                                                    245, 245, 245, 1)),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            borderSide: BorderSide(
                                              color: Color.fromRGBO(
                                                  245, 245, 245, 1),
                                            ),
                                          ),
                                        ),
                                        style: TextStyle(
                                            fontSize: 12,
                                            color:
                                                Color.fromRGBO(88, 165, 196, 1),
                                            fontWeight: FontWeight.w500),
                                        suggestionPosition:
                                            SuggestionPosition.Bottom,
                                        onMarkupChanged: (val) {
                                          setState(() {
                                            markupptext = val;
                                          });
                                        },
                                        onEditingComplete: () {
                                          setState(() {
                                            tagids.clear();
                                            for (int l = 0;
                                                l < markupptext.length;
                                                l++) {
                                              int k = l;
                                              if (markupptext.substring(
                                                      k, k + 1) ==
                                                  "@") {
                                                String test1 =
                                                    markupptext.substring(k);
                                                tagids.add(test1.substring(
                                                    4, test1.indexOf("__]")));
                                              }
                                            }
                                            print(tagids);
                                          });
                                        },
                                        onSuggestionVisibleChanged: (val) {
                                          setState(() {
                                            _showList = val;
                                          });
                                        },
                                        onChanged: (val) {
                                          setState(() {
                                            tagedString = val;
                                          });
                                        },
                                        onSearchChanged: (
                                          trigger,
                                          value,
                                        ) {
                                          print('again | $trigger | $value ');
                                        },
                                        hideSuggestionList: false,
                                        minLines: 1,
                                        maxLines: 5,
                                        mentions: [
                                          Mention(
                                              trigger: r'@',
                                              style: TextStyle(
                                                color: Color.fromRGBO(
                                                    88, 165, 196, 1),
                                              ),
                                              matchAll: false,
                                              data: _users,
                                              suggestionBuilder: (data) {
                                                return Container(
                                                  padding: EdgeInsets.all(10),
                                                  decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      border: Border(
                                                          top: BorderSide(
                                                              color: Color(
                                                                  0xFFE0E1E4)))),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: <Widget>[
                                                      CircleAvatar(
                                                        backgroundImage:
                                                            NetworkImage(
                                                          data['photo'],
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: 20.0,
                                                      ),
                                                      Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: <Widget>[
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(data[
                                                                  'display']),
                                                            ],
                                                          ),
                                                          SizedBox(
                                                            height: 3,
                                                          ),
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                '${data['full_name']}',
                                                                style:
                                                                    TextStyle(
                                                                  color: Color(
                                                                      0xFFAAABAD),
                                                                  fontSize: 11,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      )
                                                    ],
                                                  ),
                                                );
                                              }),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    ((ansnotesAttached == true) ||
                                            (ansvideoAttached == true) ||
                                            (ansaudioAttached == true) ||
                                            (anstextAttached == true))
                                        ? Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              (notesAttached == true)
                                                  ? SizedBox(
                                                      width: 30,
                                                    )
                                                  : SizedBox(),
                                              (notesAttached == true)
                                                  ? GestureDetector(
                                                      onTap: () async {
                                                        _launchInBrowser(
                                                            ansreferenceNotesAtttachedURL);
                                                      },
                                                      onLongPress: () {
                                                        setState(() {
                                                          ansnotesAttached =
                                                              false;
                                                          ansreferenceAudioAtttachedURL =
                                                              "";
                                                        });
                                                      },
                                                      child: Container(
                                                        width: 40,
                                                        height: 40,
                                                        decoration:
                                                            BoxDecoration(
                                                          color:
                                                              Color(0xffffffff),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(5),
                                                          boxShadow: [
                                                            BoxShadow(
                                                              offset: Offset(
                                                                  12, 11),
                                                              blurRadius: 15,
                                                              color: Color(
                                                                      0xffaaaaaa)
                                                                  .withOpacity(
                                                                      0.1),
                                                            )
                                                          ],
                                                        ),
                                                        //
                                                        child: Center(
                                                          child: Icon(
                                                              Icons
                                                                  .file_copy_outlined,
                                                              color: Color(
                                                                  0xFFD60808),
                                                              size: 25),
                                                        ),
                                                      ),
                                                    )
                                                  : SizedBox(),
                                              (ansvideoAttached == true)
                                                  ? SizedBox(
                                                      width: 30,
                                                    )
                                                  : SizedBox(),
                                              (ansvideoAttached == true)
                                                  ? GestureDetector(
                                                      onTap: () async {
                                                        _launchInBrowser(
                                                            ansreferenceVideoAtttachedURL);
                                                      },
                                                      onLongPress: () {
                                                        setState(() {
                                                          ansvideoAttached =
                                                              false;
                                                          ansreferenceVideoAtttachedURL =
                                                              "";
                                                        });
                                                      },
                                                      child: Container(
                                                        width: 40,
                                                        height: 40,
                                                        decoration:
                                                            BoxDecoration(
                                                          color:
                                                              Color(0xffffffff),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(5),
                                                          boxShadow: [
                                                            BoxShadow(
                                                              offset: Offset(
                                                                  12, 11),
                                                              blurRadius: 15,
                                                              color: Color(
                                                                      0xffaaaaaa)
                                                                  .withOpacity(
                                                                      0.1),
                                                            )
                                                          ],
                                                        ),
                                                        //
                                                        child: Center(
                                                          child: Icon(
                                                              Icons
                                                                  .video_call_outlined,
                                                              color: Color(
                                                                  0xFFD60808),
                                                              size: 25),
                                                        ),
                                                      ),
                                                    )
                                                  : SizedBox(),
                                              (ansaudioAttached == true)
                                                  ? SizedBox(
                                                      width: 30,
                                                    )
                                                  : SizedBox(),
                                              (ansaudioAttached == true)
                                                  ? GestureDetector(
                                                      onTap: () async {
                                                        _launchInBrowser(
                                                            ansreferenceAudioAtttachedURL);
                                                      },
                                                      onLongPress: () {
                                                        setState(() {
                                                          ansaudioAttached =
                                                              false;
                                                          ansreferenceAudioAtttachedURL =
                                                              "";
                                                        });
                                                      },
                                                      child: Container(
                                                        width: 40,
                                                        height: 40,
                                                        decoration:
                                                            BoxDecoration(
                                                          color:
                                                              Color(0xffffffff),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(5),
                                                          boxShadow: [
                                                            BoxShadow(
                                                              offset: Offset(
                                                                  12, 11),
                                                              blurRadius: 15,
                                                              color: Color(
                                                                      0xffaaaaaa)
                                                                  .withOpacity(
                                                                      0.1),
                                                            )
                                                          ],
                                                        ),
                                                        //
                                                        child: Center(
                                                          child: Icon(
                                                              Icons
                                                                  .audiotrack_outlined,
                                                              color: Color(
                                                                  0xFFD60808),
                                                              size: 25),
                                                        ),
                                                      ),
                                                    )
                                                  : SizedBox(),
                                              (anstextAttached == true)
                                                  ? SizedBox(
                                                      width: 30,
                                                    )
                                                  : SizedBox(),
                                              (anstextAttached == true)
                                                  ? GestureDetector(
                                                      onTap: () {
                                                        pickTextReferenceDialog(
                                                            ansreferenceTextAtttached);
                                                      },
                                                      onLongPress: () {
                                                        setState(() {
                                                          anstextAttached =
                                                              false;
                                                        });
                                                      },
                                                      child: Container(
                                                        width: 40,
                                                        height: 40,
                                                        decoration:
                                                            BoxDecoration(
                                                          color:
                                                              Color(0xffffffff),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(5),
                                                          boxShadow: [
                                                            BoxShadow(
                                                              offset: Offset(
                                                                  12, 11),
                                                              blurRadius: 15,
                                                              color: Color(
                                                                      0xffaaaaaa)
                                                                  .withOpacity(
                                                                      0.1),
                                                            )
                                                          ],
                                                        ),
                                                        //
                                                        child: Center(
                                                          child: Icon(
                                                              Icons
                                                                  .text_fields_outlined,
                                                              color: Color(
                                                                  0xFFD60808),
                                                              size: 25),
                                                        ),
                                                      ),
                                                    )
                                                  : SizedBox(),
                                            ],
                                          )
                                        : SizedBox(),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Add Reference   ',
                                          style: TextStyle(
                                            fontFamily: 'Nunito Sans',
                                            fontSize: 15,
                                            color:
                                                Color.fromRGBO(88, 165, 196, 1),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Text(
                                          '(Optional)',
                                          style: TextStyle(
                                            fontFamily: 'Nunito Sans',
                                            fontSize: 12,
                                            color: Colors.black45,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 10),
                                    _ansreference(context, qIndex),
                                  ],
                                ),
                              ),
                        SizedBox(height: 20),
                        ansPostVisibility == true
                            ? Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(5),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.deepPurple.withOpacity(0.1),
                                      spreadRadius: 5,
                                      blurRadius: 10,
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  child: Container(
                                      width: double.infinity,
                                      height: 40,
                                      child: Center(
                                          child: Text("Post",
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                  color: ((answer != "") ||
                                                          (latex != ""))
                                                      ? Colors.white
                                                      : Colors.grey[400])))),
                                  onPressed: () async {
                                    if ((answer != "") ||
                                        (latex != "") ||
                                        (ansImageURL != "")) {
                                      Dialogs.showLoadingDialog(
                                          context, _keyLoader);
                                      String ansID = "";
                                      setState(() {
                                        tagids.clear();
                                        tagedUsersName.clear();
                                        print(markupptext);
                                        for (int l = 0;
                                            l < markupptext.length - 4;
                                            l++) {
                                          int k = l;
                                          if (markupptext.substring(k, k + 1) ==
                                              "@") {
                                            String test1 =
                                                markupptext.substring(k);
                                            print(
                                                "tagid ${test1.substring(4, test1.indexOf("__]"))}");
                                            tagids.add(test1.substring(
                                                4, test1.indexOf("__]")));
                                          }

                                          if (markupptext.substring(k, k + 3) ==
                                              "(__") {
                                            String test2 =
                                                markupptext.substring(k);
                                            print(test2);
                                            tagedUsersName.add(test2.substring(
                                                3, test2.indexOf("__)")));
                                            print(
                                                "tagusername ${test2.substring(3, test2.indexOf("__)"))}");
                                          }
                                        }
                                        print(tagedUsersName);
                                        print(tagids);
                                        ansID = allQuestionsData[qIndex]
                                                ["question_id"] +
                                            comparedate;
                                        data = [
                                          ansID,
                                          allQuestionsData[qIndex]
                                              ["question_id"],
                                          _currentUserId,
                                          0,
                                          ansreferenceAudioAtttachedURL,
                                          0,
                                          0,
                                          0,
                                          ansreferenceNotesAtttachedURL,
                                          ocrImageURL,
                                          comparedate,
                                          answer != ""
                                              ? answer
                                              : latex != ""
                                                  ? latex
                                                  : ansImageURL != ""
                                                      ? ansImageURL
                                                      : "na",
                                          answerType,
                                          ansreferenceTextAtttached,
                                          ansreferenceVideoAtttachedURL
                                        ];
                                      });
                                      if (tagids.isNotEmpty) {
                                        for (int i = 0;
                                            i < tagids.length;
                                            i++) {
                                          await dataLoad
                                              .postUsertaggedInAnswerData(
                                                  [ansID, tagids[i]]);
                                        }
                                      }
                                      bool x = await dataLoad
                                          .postUserAnswerData(data);
                                      if (x == true) {
                                        ////////////////////////////notification//////////////////////////////////////
                                        String notify_id =
                                            "ntf${allQuestionsData[qIndex]["user_id"]}$comparedate";
                                        notifyCRUD.sendNotification([
                                          notify_id,
                                          "answerpost",
                                          "question",
                                          _currentUserId,
                                          allQuestionsData[qIndex]["user_id"],
                                          countData!.value["usertoken"][
                                              allQuestionsData[qIndex]
                                                  ["user_id"]]["tokenid"],
                                          "You got one more answer!",
                                          "${userDataDB!.get("first_name")} ${userDataDB!.get("last_name")} answered your question.",
                                          allQuestionsData[qIndex]
                                              ["question_id"],
                                          "question",
                                          "false",
                                          comparedate,
                                          "add"
                                        ]);
                                        //////////////////////////////////////////////////////////////////////////
                                        ElegantNotification.success(
                                          title: Text("Congrats,"),
                                          description:
                                              Text("Your answer posted successfully."),
                                        );

                                        _update_count(
                                            _currentUserId,
                                            allQuestionsData[qIndex]
                                                ["question_id"],
                                            "answer",
                                            "+",
                                            qIndex);
                                        ansPostVisibility = false;
                                        answer = "";
                                        latex = "";
                                        ansocrImageURL = "";
                                        ansreferenceNotesAtttachedURL = "";
                                        ansreferenceVideoAtttachedURL = "";
                                        ansreferenceAudioAtttachedURL = "";
                                        ansreferenceTextAtttached = "";
                                        ansnotesAttached = false;
                                        ansvideoAttached = false;
                                        ansaudioAttached = false;
                                        anstextAttached = false;
                                        base64Image = "";
                                        latex = "";
                                        tex = [''];

                                        tagcount = 0;
                                        tagids = [];
                                        tagedUsersName = [];
                                        markupptext = '';
                                        tagedString = "";
                                        _get_all_answers_posted();
                                        Navigator.of(_keyLoader.currentContext!,
                                                rootNavigator: true)
                                            .pop();
                                        Navigator.of(context).pop();
                                      } else {
                                        ElegantNotification.error(
                                          title: Text("error..."),
                                          description: Text("Something wrong."),
                                        );
                                      }
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    primary: ((answer != "") || (latex != ""))
                                        ? active
                                        : Colors.white54,
                                    onPrimary: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                  ),
                                ),
                              )
                            : SizedBox(),
                      ],
                    ),
                  ),
                ),
              );
            }));
  }

  _ansreference(BuildContext context, int qIndex) {
    return Container(
        height: 80,
        child: ListView(
          scrollDirection: Axis.horizontal,
          physics: BouncingScrollPhysics(),
          children: [
            InkWell(
              onTap: () async {
                _anspickNotes(context, qIndex);
              },
              child: Container(
                width: 70,
                height: 70,
                margin: EdgeInsets.only(right: 20, left: 20),
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: ansnotesAttached == true
                      ? Color.fromRGBO(88, 165, 196, 1)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Center(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.note_add_outlined,
                        color: ansnotesAttached == false
                            ? Color.fromRGBO(88, 165, 196, 1)
                            : Colors.white,
                        size: 25),
                    SizedBox(height: 10),
                    Text(
                      "Notes",
                      style: TextStyle(
                        fontFamily: 'Nunito Sans',
                        fontSize: 12,
                        color: ansnotesAttached == false
                            ? Color.fromRGBO(88, 165, 196, 1)
                            : Colors.white,
                      ),
                    )
                  ],
                )),
              ),
            ),
            InkWell(
              onTap: () async {
                _anspickVideo(context, qIndex);
              },
              child: Container(
                width: 70,
                height: 70,
                margin: EdgeInsets.only(right: 20, left: 20),
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: ansvideoAttached == true
                      ? Color.fromRGBO(88, 165, 196, 1)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Center(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.video_label_outlined,
                        color: ansvideoAttached == false
                            ? Color.fromRGBO(88, 165, 196, 1)
                            : Colors.white,
                        size: 25),
                    SizedBox(height: 10),
                    Text(
                      "Video\nExplainer",
                      style: TextStyle(
                        fontFamily: 'Nunito Sans',
                        fontSize: 12,
                        color: ansvideoAttached == false
                            ? Color.fromRGBO(88, 165, 196, 1)
                            : Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    )
                  ],
                )),
              ),
            ),
            InkWell(
              onTap: () {
                _anspickAudio(context, qIndex);
              },
              child: Container(
                width: 70,
                height: 70,
                margin: EdgeInsets.only(right: 20, left: 20),
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: ansaudioAttached == true
                      ? Color.fromRGBO(88, 165, 196, 1)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Center(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.music_note_outlined,
                        color: ansaudioAttached == false
                            ? Color.fromRGBO(88, 165, 196, 1)
                            : Colors.white,
                        size: 25),
                    SizedBox(height: 10),
                    Text(
                      "Audio\nExplainer",
                      style: TextStyle(
                        fontFamily: 'Nunito Sans',
                        fontSize: 12,
                        color: ansaudioAttached == false
                            ? Color.fromRGBO(88, 165, 196, 1)
                            : Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    )
                  ],
                )),
              ),
            ),
            InkWell(
              onTap: () {
                anspickTextReferenceDialog("");
              },
              child: Container(
                width: 70,
                height: 70,
                margin: EdgeInsets.only(right: 20, left: 20),
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: anstextAttached == true
                      ? Color.fromRGBO(88, 165, 196, 1)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Center(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.bookmark_border_outlined,
                        color: anstextAttached == false
                            ? Color.fromRGBO(88, 165, 196, 1)
                            : Colors.white,
                        size: 25),
                    SizedBox(height: 10),
                    Text(
                      "Reference",
                      style: TextStyle(
                        fontFamily: 'Nunito Sans',
                        fontSize: 12,
                        color: anstextAttached == false
                            ? Color.fromRGBO(88, 165, 196, 1)
                            : Colors.white,
                      ),
                    )
                  ],
                )),
              ),
            ),
          ],
        ));
  }

  void _anspickImage(BuildContext context, int qIndex) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      Uint8List? file = result.files.first.bytes;
      String fileName = result.files.first.name;

      var cropResult = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (ctx) => Cropper(file!),
        ),
      );
      var _image = await cropResult;
      if (_image != null) {
        base64Image = base64Encode(_image);
        Dialogs.showLoadingDialog(context, _keyLoader);
        final http.Response response = await http.post(
          Uri.parse('https://api.mathpix.com/v3/text'),
          headers: <String, String>{
            'Content-Type': 'application/json',
            'app_id': 'shubham_sparrowrms_in_f5ee1d_512d15',
            'app_key': 'a95e398dbb1b1faf2af3',
          },
          body: jsonEncode(<String, dynamic>{
            "src": "data:image/jpeg;base64," + base64Image,
            "formats": ["text", "data"],
            "data_options": {"include_asciimath": false, "include_latex": true}
          }),
        );

        print(response.statusCode);

        if ((response.statusCode == 200) || (response.statusCode == 201)) {
          setState(() {
            totaldata = json.decode(response.body);
            latex = totaldata!["text"];
            print(totaldata!["data"]);
            for (int i = 0; i < totaldata!["data"].length; i++) {
              tex.add(totaldata!["data"][i]['value']);
            }
          });
          //image upload on FB Storage
          UploadTask task = FirebaseStorage.instance
              .ref()
              .child("userAnswerOCR/$_currentUserId/$fileName")
              .putData(_image);

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
                  .ref("userAnswerOCR/$_currentUserId/$fileName")
                  .getDownloadURL();
              if (downloadURL != null) {
                Navigator.of(_keyLoader.currentContext!, rootNavigator: true)
                    .pop(); //close the dialoge
                setState(() {
                  ansocrImageURL = downloadURL;
                  print(downloadURL);
                  ansnotesAttached = true;
                  progress = 0.0;
                  ansPostVisibility = true;
                });

                Navigator.of(context).pop();
                _addAnswerPostDialog(qIndex);
              }
            }
          });
        }
      }
    }
  }

  void _pickImageAnswer(BuildContext context, int qIndex) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      Dialogs.showLoadingDialog(context, _keyLoader);

      Uint8List? file = result.files.first.bytes;
      String fileName = result.files.first.name;
      UploadTask task = FirebaseStorage.instance
          .ref()
          .child("userAnswer/$_currentUserId/$fileName")
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
              .ref("userAnswer/$_currentUserId/$fileName")
              .getDownloadURL();
          if (downloadURL != null) {
            Navigator.of(_keyLoader.currentContext!, rootNavigator: true)
                .pop(); //close the dialoge
            setState(() {
              ansImageURL = downloadURL;
              print(downloadURL);
              progress = 0.0;
              ansPostVisibility = true;
            });

            Navigator.of(context).pop();

            _addAnswerPostDialog(qIndex);
          }
        }
      });
    }
  }

  void _anspickNotes(BuildContext context, int qIndex) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      Dialogs.showLoadingDialog(context, _keyLoader);

      Uint8List? file = result.files.first.bytes;
      String fileName = result.files.first.name;
      UploadTask task = FirebaseStorage.instance
          .ref()
          .child("userNotesReference/$_currentUserId/$fileName")
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
              .ref("userNotesReference/$_currentUserId/$fileName")
              .getDownloadURL();
          if (downloadURL != null) {
            Navigator.of(_keyLoader.currentContext!, rootNavigator: true)
                .pop(); //close the dialoge
            setState(() {
              ansreferenceNotesAtttachedURL = downloadURL;
              print(downloadURL);
              ansnotesAttached = true;
              progress = 0.0;
            });

            Navigator.of(context).pop();
            _addAnswerPostDialog(qIndex);
            ElegantNotification.success(
              title: Text("Congrats,"),
              description: Text("You attatched note successfully."),
            );
          }
        }
      });
    }
  }

  void _anspickVideo(BuildContext context, int qIndex) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      Uint8List? file = result.files.first.bytes;
      String fileName = result.files.first.name;
      Dialogs.showLoadingDialog(context, _keyLoader);
      UploadTask task = FirebaseStorage.instance
          .ref()
          .child("userVideoReference/$_currentUserId/$fileName")
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
              .ref("userVideoReference/$_currentUserId/$fileName")
              .getDownloadURL();
          if (downloadURL != null) {
            Navigator.of(_keyLoader.currentContext!, rootNavigator: true)
                .pop(); //close the dialoge
            setState(() {
              ansreferenceVideoAtttachedURL = downloadURL;
              print(downloadURL);
              ansvideoAttached = true;
              progress = 0.0;
            });

            Navigator.of(context).pop();
            _addAnswerPostDialog(qIndex);
            ElegantNotification.success(
              title: Text("Congrats,"),
              description: Text("You attatched video file successfully."),
            );
          }
        }
      });
    }
  }

  void _anspickAudio(BuildContext context, int qIndex) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      Uint8List? file = result.files.first.bytes;
      String fileName = result.files.first.name;
      Dialogs.showLoadingDialog(context, _keyLoader);
      UploadTask task = FirebaseStorage.instance
          .ref()
          .child("userAudioReference/$_currentUserId/$fileName")
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
              .ref("userAudioReference/$_currentUserId/$fileName")
              .getDownloadURL();
          if (downloadURL != null) {
            Navigator.of(_keyLoader.currentContext!, rootNavigator: true)
                .pop(); //close the dialoge
            setState(() {
              ansreferenceVideoAtttachedURL = downloadURL;
              print(downloadURL);
              ansaudioAttached = true;
              progress = 0.0;
            });

            Navigator.of(context).pop();
            _addAnswerPostDialog(qIndex);
            ElegantNotification.success(
              title: Text("Congrats,"),
              description:Text( "You attatched audio file successfully."),
            );
          }
        }
      });
    }
  }

  void anspickTextReferenceDialog(String x) {
    showDialog(
        context: context,
        barrierColor: Colors.grey.withOpacity(0.2),
        builder: (_) => StatefulBuilder(builder: (context, setState) {
              return AlertDialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0)),
                  content: Container(
                    height: 200,
                    child: Column(
                      children: [
                        SizedBox(height: 30),
                        Container(
                          padding:
                              EdgeInsets.only(left: 15, right: 15, bottom: 5),
                          child: TextFormField(
                            maxLines: 4,
                            initialValue: x,
                            keyboardType: TextInputType.text,
                            cursorColor: Color.fromRGBO(88, 165, 196, 1),
                            style: TextStyle(
                                fontSize: 12,
                                color: Color.fromRGBO(88, 165, 196, 1),
                                fontWeight: FontWeight.w500),
                            onChanged: (val) {
                              setState(() => ansreferenceTextAtttached = val);
                            },
                            decoration: InputDecoration(
                              fillColor: Color.fromRGBO(245, 245, 245, 1),
                              filled: true,
                              counterText: '',
                              hintText:
                                  'Add reference like Book Name, Page No.',
                              hintStyle: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[350],
                                  fontWeight: FontWeight.w600),
                              alignLabelWithHint: false,
                              contentPadding: new EdgeInsets.symmetric(
                                  vertical: 10.0, horizontal: 10),
                              errorStyle: TextStyle(
                                  color: Color.fromRGBO(240, 20, 41, 1)),
                              focusColor: Color.fromRGBO(88, 165, 196, 1),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                    color: Color.fromRGBO(245, 245, 245, 1)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: Color.fromRGBO(245, 245, 245, 1),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: EdgeInsets.all(5),
                              width: 160,
                              child: RaisedButton(
                                  shape: RoundedRectangleBorder(
                                      side: BorderSide(
                                          color:
                                              Color.fromRGBO(88, 165, 196, 1)),
                                      borderRadius:
                                          BorderRadius.circular(100.0)),
                                  color: Color.fromRGBO(88, 165, 196, 1),
                                  splashColor: Color.fromRGBO(88, 165, 196, 1),
                                  child: Center(
                                      child: Text(
                                    'Save',
                                    style: GoogleFonts.raleway(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 14),
                                  )),
                                  onPressed: () {
                                    if (ansreferenceTextAtttached != "") {
                                      setState(() {
                                        anstextAttached = true;
                                        Navigator.pop(context);
                                      });
                                    }
                                  }),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ));
            }));
  }

//Comment Post

  bool cmntPostVisibility = false;
  String commentType = 'text';
  String comment = "";
  String cmntImageURL = "";
  String cmntreferenceNotesAtttachedURL = "";
  String cmntreferenceVideoAtttachedURL = "";
  String cmntreferenceAudioAtttachedURL = "";
  String cmntreferenceTextAtttached = "";

  bool cmntnotesAttached = false;
  bool cmntvideoAttached = false;
  bool cmntaudioAttached = false;
  bool cmnttextAttached = false;

  void _addCommentPostDialog(int qIndex, int ansSelectID, int ansIndex) {
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
                        SizedBox(width: 30),
                        Text(
                          "Post your comment",
                          style: TextStyle(
                            fontSize: 20,
                            color: Color(0xCB000000),
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            cmntPostVisibility = false;
                            commentType = 'text';
                            comment = "";
                            cmntreferenceNotesAtttachedURL = "";
                            cmntreferenceVideoAtttachedURL = "";
                            cmntreferenceAudioAtttachedURL = "";
                            cmntreferenceTextAtttached = "";
                            cmntImageURL = "";
                            cmntnotesAttached = false;
                            cmntvideoAttached = false;
                            cmntaudioAttached = false;
                            cmnttextAttached = false;
                            Navigator.pop(context);
                          },
                          icon: Tab(
                              child: Icon(Icons.cancel_rounded,
                                  color: Colors.black45, size: 25)),
                        )
                      ],
                    ),
                    SizedBox(height: 20),
                    Container(height: 1, width: 500, color: Colors.grey[200]),
                  ],
                ),
                content: Container(
                  height: 470,
                  width: 500,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                                cmntPostVisibility == false
                                    ? "Choose comment type"
                                    : "Post comment",
                                style: TextStyle(
                                    fontSize: 16, color: Colors.black54)),
                            cmntPostVisibility == true
                                ? IconButton(
                                    onPressed: () {
                                      if (cmntPostVisibility == true) {
                                        setState(() {
                                          cmntPostVisibility = false;
                                        });
                                      }
                                    },
                                    icon: Icon(Icons.arrow_back_ios,
                                        color: Colors.black54, size: 22))
                                : SizedBox(width: 20)
                          ],
                        ),
                        SizedBox(height: 10),
                        cmntPostVisibility == true
                            ? Container(
                                margin: EdgeInsets.fromLTRB(20, 0, 20, 0),
                                padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                                decoration: BoxDecoration(
                                    color: Color.fromRGBO(242, 246, 248, 1),
                                    borderRadius: BorderRadius.circular(10)),
                                child: allAnswersQIDwise[ansSelectID][ansIndex]
                                            ["answer_type"] ==
                                        "text"
                                    ? InkWell(
                                        child: Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width -
                                              30,
                                          margin:
                                              EdgeInsets.fromLTRB(10, 10, 0, 2),
                                          child: ReadMoreText(
                                            allAnswersQIDwise[ansSelectID]
                                                [ansIndex]["answer"],
                                            textAlign: TextAlign.left,
                                            trimLines: 4,
                                            colorClickableText:
                                                Color(0xff0962ff),
                                            trimMode: TrimMode.Line,
                                            trimCollapsedText: 'read more',
                                            trimExpandedText: 'Show less',
                                            style: TextStyle(
                                              fontFamily: 'Nunito Sans',
                                              fontSize: 16,
                                              color:
                                                  Color.fromRGBO(0, 0, 0, 0.8),
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
                                    : allAnswersQIDwise[ansSelectID][ansIndex]
                                                ["answer_type"] ==
                                            "ocr"
                                        ? Container(
                                            margin: EdgeInsets.fromLTRB(
                                                1, 10, 1, 10),
                                            child: TeXView(
                                              child: TeXViewColumn(children: [
                                                TeXViewDocument(
                                                    allAnswersQIDwise[
                                                            ansSelectID]
                                                        [ansIndex]["answer"],
                                                    style: TeXViewStyle(
                                                      fontStyle:
                                                          TeXViewFontStyle(
                                                              fontSize: 12,
                                                              sizeUnit:
                                                                  TeXViewSizeUnit
                                                                      .pt),
                                                      padding:
                                                          TeXViewPadding.all(
                                                              10),
                                                    )),
                                              ]),
                                              style: TeXViewStyle(
                                                elevation: 10,
                                                backgroundColor: Color.fromRGBO(
                                                    242, 246, 248, 1),
                                              ),
                                            ),
                                          )
                                        : SizedBox(),
                              )
                            : SizedBox(),
                        SizedBox(height: 10),
                        cmntPostVisibility == false
                            ? Container(
                                height: 350,
                                margin: EdgeInsets.fromLTRB(20, 0, 20, 0),
                                child: Column(
                                  children: [
                                    SizedBox(
                                      height: 10,
                                    ),
                                    SizedBox(
                                      height: 30,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            setState(() {
                                              commentType = "text";
                                              cmntPostVisibility = true;
                                            });
                                          },
                                          child: Column(
                                            children: [
                                              Image.network(
                                                  "https://firebasestorage.googleapis.com/v0/b/hys-pro-41c66.appspot.com/o/assets%2Ftyping.gif?alt=media&token=1a4b65b2-c497-438b-8c3a-a69dcfc7f67d",
                                                  height: 100,
                                                  width: 100),
                                              SizedBox(
                                                height: 7,
                                              ),
                                              Text(
                                                "Keyboard",
                                                style: TextStyle(
                                                  fontFamily: 'Nunito Sans',
                                                  fontSize: 15,
                                                  color: Color(0xff0C2551),
                                                  fontWeight: FontWeight.w700,
                                                ),
                                                textAlign: TextAlign.center,
                                              )
                                            ],
                                          ),
                                        ),
                                        InkWell(
                                          onTap: () {
                                            setState(() {
                                              commentType = "image";
                                              _pickImageComment(context, qIndex,
                                                  ansSelectID, ansIndex);
                                            });
                                          },
                                          child: Column(
                                            children: [
                                              Image.network(
                                                  "https://firebasestorage.googleapis.com/v0/b/hys-pro-41c66.appspot.com/o/assets%2Fgallery.png?alt=media&token=09a32fa6-5e7c-4139-94e5-d4d74e5f5d6a",
                                                  height: 100,
                                                  width: 100),
                                              SizedBox(
                                                height: 7,
                                              ),
                                              Text(
                                                "Image",
                                                style: TextStyle(
                                                  fontFamily: 'Nunito Sans',
                                                  fontSize: 15,
                                                  color: Color(0xff0C2551),
                                                  fontWeight: FontWeight.w700,
                                                ),
                                                textAlign: TextAlign.center,
                                              )
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              )
                            : Container(
                                height: 350,
                                margin: EdgeInsets.fromLTRB(20, 0, 20, 0),
                                child: ListView(
                                  physics: BouncingScrollPhysics(),
                                  children: [
                                    SizedBox(
                                      height: 20,
                                    ),
                                    commentType == "text"
                                        ? Container(
                                            child: TextFormField(
                                              maxLines: 10,
                                              initialValue: comment,
                                              keyboardType: TextInputType.text,
                                              cursorColor: Color.fromRGBO(
                                                  88, 165, 196, 1),
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  color: Color.fromRGBO(
                                                      88, 165, 196, 1),
                                                  fontWeight: FontWeight.w500),
                                              validator: (val) => ((val!
                                                      .isEmpty))
                                                  ? 'Leave your comment here, you can\'t kept it blank'
                                                  : null,
                                              onChanged: (val) {
                                                setState(() => comment = val);
                                              },
                                              decoration: InputDecoration(
                                                fillColor: Color.fromRGBO(
                                                    245, 245, 245, 1),
                                                filled: true,
                                                counterText: '',
                                                hintText: 'Your comment...',
                                                hintStyle: TextStyle(
                                                    fontSize: 18,
                                                    color: Colors.grey[300],
                                                    fontWeight:
                                                        FontWeight.w600),
                                                alignLabelWithHint: false,
                                                contentPadding:
                                                    new EdgeInsets.symmetric(
                                                        vertical: 10.0,
                                                        horizontal: 10),
                                                errorStyle: TextStyle(
                                                    color: Color.fromRGBO(
                                                        240, 20, 41, 1)),
                                                focusColor: Color.fromRGBO(
                                                    88, 165, 196, 1),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  borderSide: BorderSide(
                                                      color: Color.fromRGBO(
                                                          245, 245, 245, 1)),
                                                ),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  borderSide: BorderSide(
                                                    color: Color.fromRGBO(
                                                        245, 245, 245, 1),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          )
                                        : Container(
                                            height: 100,
                                            child: CachedNetworkImage(
                                              imageUrl: cmntImageURL,
                                              fit: BoxFit.contain,
                                              placeholder: (context, url) =>
                                                  Container(
                                                height: 30,
                                                width: 30,
                                                child: Image.network(
                                                  "https://firebasestorage.googleapis.com/v0/b/hys-pro-41c66.appspot.com/o/assets%2Floadingimg.gif?alt=media&token=4ca910f2-c584-4b3a-bbcb-2f1c01d93f67",
                                                ),
                                              ),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      Icon(Icons.error),
                                            ),
                                          ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Container(
                                      height: 50,
                                      width: 400,
                                      child: FlutterMentions(
                                        key: key,
                                        keyboardType: TextInputType.text,
                                        cursorColor:
                                            Color.fromRGBO(88, 165, 196, 1),
                                        decoration: InputDecoration(
                                          fillColor:
                                              Color.fromRGBO(245, 245, 245, 1),
                                          filled: true,
                                          counterText: '',
                                          hintText: '@Tag someone here',
                                          hintStyle: TextStyle(
                                              fontSize: 13,
                                              color: Colors.grey[350],
                                              fontWeight: FontWeight.w600),
                                          alignLabelWithHint: false,
                                          contentPadding:
                                              new EdgeInsets.symmetric(
                                                  vertical: 10.0,
                                                  horizontal: 10),
                                          errorStyle: TextStyle(
                                              color: Color.fromRGBO(
                                                  240, 20, 41, 1)),
                                          focusColor:
                                              Color.fromRGBO(88, 165, 196, 1),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            borderSide: BorderSide(
                                                color: Color.fromRGBO(
                                                    245, 245, 245, 1)),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            borderSide: BorderSide(
                                              color: Color.fromRGBO(
                                                  245, 245, 245, 1),
                                            ),
                                          ),
                                        ),
                                        style: TextStyle(
                                            fontSize: 12,
                                            color:
                                                Color.fromRGBO(88, 165, 196, 1),
                                            fontWeight: FontWeight.w500),
                                        suggestionPosition:
                                            SuggestionPosition.Bottom,
                                        onMarkupChanged: (val) {
                                          setState(() {
                                            markupptext = val;
                                          });
                                        },
                                        onEditingComplete: () {
                                          setState(() {
                                            tagids.clear();
                                            for (int l = 0;
                                                l < markupptext.length;
                                                l++) {
                                              int k = l;
                                              if (markupptext.substring(
                                                      k, k + 1) ==
                                                  "@") {
                                                String test1 =
                                                    markupptext.substring(k);
                                                tagids.add(test1.substring(
                                                    4, test1.indexOf("__]")));
                                              }
                                            }
                                            print(tagids);
                                          });
                                        },
                                        onSuggestionVisibleChanged: (val) {
                                          setState(() {
                                            _showList = val;
                                          });
                                        },
                                        onChanged: (val) {
                                          setState(() {
                                            tagedString = val;
                                          });
                                        },
                                        onSearchChanged: (
                                          trigger,
                                          value,
                                        ) {
                                          print('again | $trigger | $value ');
                                        },
                                        hideSuggestionList: false,
                                        minLines: 1,
                                        maxLines: 5,
                                        mentions: [
                                          Mention(
                                              trigger: r'@',
                                              style: TextStyle(
                                                color: Color.fromRGBO(
                                                    88, 165, 196, 1),
                                              ),
                                              matchAll: false,
                                              data: _users,
                                              suggestionBuilder: (data) {
                                                return Container(
                                                  padding: EdgeInsets.all(10),
                                                  decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      border: Border(
                                                          top: BorderSide(
                                                              color: Color(
                                                                  0xFFE0E1E4)))),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: <Widget>[
                                                      CircleAvatar(
                                                        backgroundImage:
                                                            NetworkImage(
                                                          data['photo'],
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: 20.0,
                                                      ),
                                                      Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: <Widget>[
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(data[
                                                                  'display']),
                                                            ],
                                                          ),
                                                          SizedBox(
                                                            height: 3,
                                                          ),
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                '${data['full_name']}',
                                                                style:
                                                                    TextStyle(
                                                                  color: Color(
                                                                      0xFFAAABAD),
                                                                  fontSize: 11,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      )
                                                    ],
                                                  ),
                                                );
                                              }),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    ((cmntnotesAttached == true) ||
                                            (cmntvideoAttached == true) ||
                                            (cmntaudioAttached == true) ||
                                            (cmnttextAttached == true))
                                        ? Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              (cmntnotesAttached == true)
                                                  ? SizedBox(
                                                      width: 30,
                                                    )
                                                  : SizedBox(),
                                              (cmntnotesAttached == true)
                                                  ? GestureDetector(
                                                      onTap: () async {
                                                        _launchInBrowser(
                                                            cmntreferenceNotesAtttachedURL);
                                                      },
                                                      onLongPress: () {
                                                        setState(() {
                                                          cmntnotesAttached =
                                                              false;
                                                          cmntreferenceAudioAtttachedURL =
                                                              "";
                                                        });
                                                      },
                                                      child: Container(
                                                        width: 40,
                                                        height: 40,
                                                        decoration:
                                                            BoxDecoration(
                                                          color:
                                                              Color(0xffffffff),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(5),
                                                          boxShadow: [
                                                            BoxShadow(
                                                              offset: Offset(
                                                                  12, 11),
                                                              blurRadius: 15,
                                                              color: Color(
                                                                      0xffaaaaaa)
                                                                  .withOpacity(
                                                                      0.1),
                                                            )
                                                          ],
                                                        ),
                                                        //
                                                        child: Center(
                                                          child: Icon(
                                                              Icons
                                                                  .file_copy_outlined,
                                                              color: Color(
                                                                  0xFFD60808),
                                                              size: 25),
                                                        ),
                                                      ),
                                                    )
                                                  : SizedBox(),
                                              (cmntvideoAttached == true)
                                                  ? SizedBox(
                                                      width: 30,
                                                    )
                                                  : SizedBox(),
                                              (cmntvideoAttached == true)
                                                  ? GestureDetector(
                                                      onTap: () async {
                                                        _launchInBrowser(
                                                            cmntreferenceVideoAtttachedURL);
                                                      },
                                                      onLongPress: () {
                                                        setState(() {
                                                          cmntvideoAttached =
                                                              false;
                                                          cmntreferenceVideoAtttachedURL =
                                                              "";
                                                        });
                                                      },
                                                      child: Container(
                                                        width: 40,
                                                        height: 40,
                                                        decoration:
                                                            BoxDecoration(
                                                          color:
                                                              Color(0xffffffff),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(5),
                                                          boxShadow: [
                                                            BoxShadow(
                                                              offset: Offset(
                                                                  12, 11),
                                                              blurRadius: 15,
                                                              color: Color(
                                                                      0xffaaaaaa)
                                                                  .withOpacity(
                                                                      0.1),
                                                            )
                                                          ],
                                                        ),
                                                        //
                                                        child: Center(
                                                          child: Icon(
                                                              Icons
                                                                  .video_call_outlined,
                                                              color: Color(
                                                                  0xFFD60808),
                                                              size: 25),
                                                        ),
                                                      ),
                                                    )
                                                  : SizedBox(),
                                              (cmntaudioAttached == true)
                                                  ? SizedBox(
                                                      width: 30,
                                                    )
                                                  : SizedBox(),
                                              (cmntaudioAttached == true)
                                                  ? GestureDetector(
                                                      onTap: () async {
                                                        _launchInBrowser(
                                                            cmntreferenceAudioAtttachedURL);
                                                      },
                                                      onLongPress: () {
                                                        setState(() {
                                                          cmntaudioAttached =
                                                              false;
                                                          cmntreferenceAudioAtttachedURL =
                                                              "";
                                                        });
                                                      },
                                                      child: Container(
                                                        width: 40,
                                                        height: 40,
                                                        decoration:
                                                            BoxDecoration(
                                                          color:
                                                              Color(0xffffffff),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(5),
                                                          boxShadow: [
                                                            BoxShadow(
                                                              offset: Offset(
                                                                  12, 11),
                                                              blurRadius: 15,
                                                              color: Color(
                                                                      0xffaaaaaa)
                                                                  .withOpacity(
                                                                      0.1),
                                                            )
                                                          ],
                                                        ),
                                                        //
                                                        child: Center(
                                                          child: Icon(
                                                              Icons
                                                                  .audiotrack_outlined,
                                                              color: Color(
                                                                  0xFFD60808),
                                                              size: 25),
                                                        ),
                                                      ),
                                                    )
                                                  : SizedBox(),
                                              (cmnttextAttached == true)
                                                  ? SizedBox(
                                                      width: 30,
                                                    )
                                                  : SizedBox(),
                                              (cmnttextAttached == true)
                                                  ? GestureDetector(
                                                      onTap: () {
                                                        pickTextReferenceDialog(
                                                            cmntreferenceTextAtttached);
                                                      },
                                                      onLongPress: () {
                                                        setState(() {
                                                          cmnttextAttached =
                                                              false;
                                                        });
                                                      },
                                                      child: Container(
                                                        width: 40,
                                                        height: 40,
                                                        decoration:
                                                            BoxDecoration(
                                                          color:
                                                              Color(0xffffffff),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(5),
                                                          boxShadow: [
                                                            BoxShadow(
                                                              offset: Offset(
                                                                  12, 11),
                                                              blurRadius: 15,
                                                              color: Color(
                                                                      0xffaaaaaa)
                                                                  .withOpacity(
                                                                      0.1),
                                                            )
                                                          ],
                                                        ),
                                                        //
                                                        child: Center(
                                                          child: Icon(
                                                              Icons
                                                                  .text_fields_outlined,
                                                              color: Color(
                                                                  0xFFD60808),
                                                              size: 25),
                                                        ),
                                                      ),
                                                    )
                                                  : SizedBox(),
                                            ],
                                          )
                                        : SizedBox(),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Add Reference   ',
                                          style: TextStyle(
                                            fontFamily: 'Nunito Sans',
                                            fontSize: 15,
                                            color:
                                                Color.fromRGBO(88, 165, 196, 1),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Text(
                                          '(Optional)',
                                          style: TextStyle(
                                            fontFamily: 'Nunito Sans',
                                            fontSize: 12,
                                            color: Colors.black45,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 10),
                                    _cmntreference(
                                        context, qIndex, ansSelectID, ansIndex),
                                  ],
                                ),
                              ),
                        SizedBox(height: 20),
                        cmntPostVisibility == true
                            ? Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(5),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.deepPurple.withOpacity(0.1),
                                      spreadRadius: 5,
                                      blurRadius: 10,
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  child: Container(
                                      width: double.infinity,
                                      height: 40,
                                      child: Center(
                                          child: Text("Post",
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                  color: ((comment != "") ||
                                                          (cmntImageURL != ""))
                                                      ? Colors.white
                                                      : Colors.grey[400])))),
                                  onPressed: () async {
                                    if ((comment != "") ||
                                        (cmntImageURL != "")) {
                                      Dialogs.showLoadingDialog(
                                          context, _keyLoader);
                                      String cmtID = "";
                                      setState(() {
                                        tagids.clear();
                                        tagedUsersName.clear();
                                        print(markupptext);
                                        for (int l = 0;
                                            l < markupptext.length - 4;
                                            l++) {
                                          int k = l;
                                          if (markupptext.substring(k, k + 1) ==
                                              "@") {
                                            String test1 =
                                                markupptext.substring(k);
                                            print(
                                                "tagid ${test1.substring(4, test1.indexOf("__]"))}");
                                            tagids.add(test1.substring(
                                                4, test1.indexOf("__]")));
                                          }

                                          if (markupptext.substring(k, k + 3) ==
                                              "(__") {
                                            String test2 =
                                                markupptext.substring(k);
                                            print(test2);
                                            tagedUsersName.add(test2.substring(
                                                3, test2.indexOf("__)")));
                                            print(
                                                "tagusername ${test2.substring(3, test2.indexOf("__)"))}");
                                          }
                                        }
                                        print(tagedUsersName);
                                        print(tagids);
                                        cmtID = "cmnt" +
                                            _currentUserId +
                                            comparedate;
                                        data = [
                                          cmtID,
                                          allAnswersQIDwise[ansSelectID]
                                              [ansIndex]["answer_id"],
                                          allQuestionsData[qIndex]
                                              ["question_id"],
                                          _currentUserId,
                                          0,
                                          0,
                                          comment != ""
                                              ? comment
                                              : cmntImageURL != ""
                                                  ? cmntImageURL
                                                  : "na",
                                          commentType,
                                          cmntreferenceNotesAtttachedURL,
                                          cmntreferenceAudioAtttachedURL,
                                          cmntreferenceTextAtttached,
                                          cmntreferenceVideoAtttachedURL,
                                          comparedate
                                        ];
                                      });
                                      // if (tagids.isNotEmpty) {
                                      //   for (int i = 0;
                                      //       i < tagids.length;
                                      //       i++) {
                                      //     await dataLoad
                                      //         .postUsertaggedInAnswerData(
                                      //             [ansID, tagids[i]]);
                                      //   }
                                      // }
                                      bool x = await dataLoad
                                          .postUserAnswerCommentData(data);
                                      if (x == true) {
                                        setState(() {
                                          commentCountAns[ansSelectID]
                                                  [ansIndex] =
                                              commentCountAns[ansSelectID]
                                                      [ansIndex] +
                                                  1;
                                        });
                                        dataLoad.updateAnswerCountData([
                                          allAnswersQIDwise[ansSelectID]
                                              [ansIndex]["answer_id"],
                                          _currentUserId,
                                          commentCountAns[ansSelectID]
                                                  [ansIndex] +
                                              1,
                                          likeCountAns[ansSelectID][ansIndex],
                                          upvoteCountAns[ansSelectID]
                                                  [ansIndex] +
                                              1,
                                          downVoteCountAns[ansSelectID]
                                                  [ansIndex] -
                                              1
                                        ]);
                                        ////////////////////////////notification//////////////////////////////////////
                                        String notify_id =
                                            "ntf${allAnswersQIDwise[ansSelectID][ansIndex]["answer_id"]}$comparedate";
                                        notifyCRUD.sendNotification([
                                          notify_id,
                                          "commentpost",
                                          "reply",
                                          _currentUserId,
                                          allAnswersQIDwise[ansSelectID]
                                              [ansIndex]["user_id"],
                                          countData!.value["usertoken"][
                                                  allAnswersQIDwise[ansSelectID]
                                                      [ansIndex]["user_id"]]
                                              ["tokenid"],
                                          "You got one comment!",
                                          "${userDataDB!.get("first_name")} ${userDataDB!.get("last_name")} commented on your answer.",
                                          allQuestionsData[qIndex]
                                              ["question_id"],
                                          "question",
                                          "false",
                                          comparedate,
                                          "add"
                                        ]);
                                        //////////////////////////////////////////////////////////////////////////
                                        ElegantNotification.success(
                                          title: Text("Congrats,"),
                                          description:
                                              Text("Your comment posted successfully."),
                                        );

                                        // _update_count(
                                        //     _currentUserId,
                                        //     allQuestionsData[qIndex]
                                        //         ["question_id"],
                                        //     "answer",
                                        //     "+",
                                        //     qIndex);
                                        cmntPostVisibility = false;
                                        comment = "";
                                        cmntreferenceNotesAtttachedURL = "";
                                        cmntreferenceVideoAtttachedURL = "";
                                        cmntreferenceAudioAtttachedURL = "";
                                        cmntreferenceTextAtttached = "";
                                        cmntnotesAttached = false;
                                        cmntvideoAttached = false;
                                        cmntaudioAttached = false;
                                        cmnttextAttached = false;
                                        base64Image = "";
                                        tagcount = 0;
                                        tagids = [];
                                        tagedUsersName = [];
                                        markupptext = '';
                                        tagedString = "";
                                        _get_all_questions_posted();
                                        _get_all_answers_posted();
                                        _get_all_answers_comment_posted();
                                        Navigator.of(_keyLoader.currentContext!,
                                                rootNavigator: true)
                                            .pop();
                                        Navigator.of(context).pop();
                                      } else {
                                        ElegantNotification.error(
                                          title: Text("Error..."),
                                          description: Text("Something wrong."),
                                        );
                                      }
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    primary: ((comment != "") ||
                                            (cmntImageURL != ""))
                                        ? active
                                        : Colors.white54,
                                    onPrimary: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                  ),
                                ),
                              )
                            : SizedBox(),
                      ],
                    ),
                  ),
                ),
              );
            }));
  }

  _cmntreference(
      BuildContext context, int qIndex, int ansSelectID, int ansIndex) {
    return Container(
        height: 80,
        child: ListView(
          scrollDirection: Axis.horizontal,
          physics: BouncingScrollPhysics(),
          children: [
            InkWell(
              onTap: () async {
                _cmntpickNotes(context, qIndex, ansSelectID, ansIndex);
              },
              child: Container(
                width: 70,
                height: 70,
                margin: EdgeInsets.only(right: 20, left: 20),
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: cmntnotesAttached == true
                      ? Color.fromRGBO(88, 165, 196, 1)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Center(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.note_add_outlined,
                        color: cmntnotesAttached == false
                            ? Color.fromRGBO(88, 165, 196, 1)
                            : Colors.white,
                        size: 25),
                    SizedBox(height: 10),
                    Text(
                      "Notes",
                      style: TextStyle(
                        fontFamily: 'Nunito Sans',
                        fontSize: 12,
                        color: cmntnotesAttached == false
                            ? Color.fromRGBO(88, 165, 196, 1)
                            : Colors.white,
                      ),
                    )
                  ],
                )),
              ),
            ),
            InkWell(
              onTap: () async {
                _cmntpickVideo(context, qIndex, ansSelectID, ansIndex);
              },
              child: Container(
                width: 70,
                height: 70,
                margin: EdgeInsets.only(right: 20, left: 20),
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: cmntvideoAttached == true
                      ? Color.fromRGBO(88, 165, 196, 1)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Center(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.video_label_outlined,
                        color: cmntvideoAttached == false
                            ? Color.fromRGBO(88, 165, 196, 1)
                            : Colors.white,
                        size: 25),
                    SizedBox(height: 10),
                    Text(
                      "Video\nExplainer",
                      style: TextStyle(
                        fontFamily: 'Nunito Sans',
                        fontSize: 12,
                        color: cmntvideoAttached == false
                            ? Color.fromRGBO(88, 165, 196, 1)
                            : Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    )
                  ],
                )),
              ),
            ),
            InkWell(
              onTap: () {
                _cmntpickAudio(context, qIndex, ansSelectID, ansIndex);
              },
              child: Container(
                width: 70,
                height: 70,
                margin: EdgeInsets.only(right: 20, left: 20),
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: cmntaudioAttached == true
                      ? Color.fromRGBO(88, 165, 196, 1)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Center(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.music_note_outlined,
                        color: cmntaudioAttached == false
                            ? Color.fromRGBO(88, 165, 196, 1)
                            : Colors.white,
                        size: 25),
                    SizedBox(height: 10),
                    Text(
                      "Audio\nExplainer",
                      style: TextStyle(
                        fontFamily: 'Nunito Sans',
                        fontSize: 12,
                        color: cmntaudioAttached == false
                            ? Color.fromRGBO(88, 165, 196, 1)
                            : Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    )
                  ],
                )),
              ),
            ),
            InkWell(
              onTap: () {
                cmntpickTextReferenceDialog("");
              },
              child: Container(
                width: 70,
                height: 70,
                margin: EdgeInsets.only(right: 20, left: 20),
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: cmnttextAttached == true
                      ? Color.fromRGBO(88, 165, 196, 1)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Center(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.bookmark_border_outlined,
                        color: cmnttextAttached == false
                            ? Color.fromRGBO(88, 165, 196, 1)
                            : Colors.white,
                        size: 25),
                    SizedBox(height: 10),
                    Text(
                      "Reference",
                      style: TextStyle(
                        fontFamily: 'Nunito Sans',
                        fontSize: 12,
                        color: cmnttextAttached == false
                            ? Color.fromRGBO(88, 165, 196, 1)
                            : Colors.white,
                      ),
                    )
                  ],
                )),
              ),
            ),
          ],
        ));
  }

  void _pickImageComment(
      BuildContext context, int qIndex, int ansSelectID, int ansIndex) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      Dialogs.showLoadingDialog(context, _keyLoader);

      Uint8List? file = result.files.first.bytes;
      String fileName = result.files.first.name;
      UploadTask task = FirebaseStorage.instance
          .ref()
          .child("userAnswer/$_currentUserId/$fileName")
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
              .ref("userAnswer/$_currentUserId/$fileName")
              .getDownloadURL();
          if (downloadURL != null) {
            Navigator.of(_keyLoader.currentContext!, rootNavigator: true)
                .pop(); //close the dialoge
            setState(() {
              cmntImageURL = downloadURL;
              print(downloadURL);
              progress = 0.0;
              cmntPostVisibility = true;
            });

            Navigator.of(context).pop();

            _addCommentPostDialog(qIndex, ansSelectID, ansIndex);
          }
        }
      });
    }
  }

  void _cmntpickNotes(
      BuildContext context, int qIndex, int ansSelectID, int ansIndex) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      Dialogs.showLoadingDialog(context, _keyLoader);

      Uint8List? file = result.files.first.bytes;
      String fileName = result.files.first.name;
      UploadTask task = FirebaseStorage.instance
          .ref()
          .child("userNotesReference/$_currentUserId/$fileName")
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
              .ref("userNotesReference/$_currentUserId/$fileName")
              .getDownloadURL();
          if (downloadURL != null) {
            Navigator.of(_keyLoader.currentContext!, rootNavigator: true)
                .pop(); //close the dialoge
            setState(() {
              cmntreferenceNotesAtttachedURL = downloadURL;
              print(downloadURL);
              cmntnotesAttached = true;
              progress = 0.0;
            });

            Navigator.of(context).pop();
            _addCommentPostDialog(qIndex, ansSelectID, ansIndex);
            ElegantNotification.success(
              title: Text("Congrats,"),
              description: Text("You attatched note successfully."),
            );
          }
        }
      });
    }
  }

  void _cmntpickVideo(
      BuildContext context, int qIndex, int ansSelectID, int ansIndex) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      Uint8List? file = result.files.first.bytes;
      String fileName = result.files.first.name;
      Dialogs.showLoadingDialog(context, _keyLoader);
      UploadTask task = FirebaseStorage.instance
          .ref()
          .child("userVideoReference/$_currentUserId/$fileName")
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
              .ref("userVideoReference/$_currentUserId/$fileName")
              .getDownloadURL();
          if (downloadURL != null) {
            Navigator.of(_keyLoader.currentContext!, rootNavigator: true)
                .pop(); //close the dialoge
            setState(() {
              cmntreferenceVideoAtttachedURL = downloadURL;
              print(downloadURL);
              cmntvideoAttached = true;
              progress = 0.0;
            });

            Navigator.of(context).pop();
            _addCommentPostDialog(qIndex, ansSelectID, ansIndex);
          }
        }
      });
    }
  }

  void _cmntpickAudio(
      BuildContext context, int qIndex, int ansSelectID, int ansIndex) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      Uint8List? file = result.files.first.bytes;
      String fileName = result.files.first.name;
      Dialogs.showLoadingDialog(context, _keyLoader);
      UploadTask task = FirebaseStorage.instance
          .ref()
          .child("userAudioReference/$_currentUserId/$fileName")
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
              .ref("userAudioReference/$_currentUserId/$fileName")
              .getDownloadURL();
          if (downloadURL != null) {
            Navigator.of(_keyLoader.currentContext!, rootNavigator: true)
                .pop(); //close the dialoge
            setState(() {
              cmntreferenceVideoAtttachedURL = downloadURL;
              print(downloadURL);
              cmntaudioAttached = true;
              progress = 0.0;
            });

            Navigator.of(context).pop();
            ElegantNotification.success(
              title:Text( "Congrats,"),
              description:Text( "You attatched audio file successfully."),
            );
            _addCommentPostDialog(qIndex, ansSelectID, ansIndex);
          }
        }
      });
    }
  }

  void cmntpickTextReferenceDialog(String x) {
    showDialog(
        context: context,
        barrierColor: Colors.grey.withOpacity(0.2),
        builder: (_) => StatefulBuilder(builder: (context, setState) {
              return AlertDialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0)),
                  content: Container(
                    height: 200,
                    child: Column(
                      children: [
                        SizedBox(height: 30),
                        Container(
                          padding:
                              EdgeInsets.only(left: 15, right: 15, bottom: 5),
                          child: TextFormField(
                            maxLines: 4,
                            keyboardType: TextInputType.text,
                            cursorColor: Color.fromRGBO(88, 165, 196, 1),
                            style: TextStyle(
                                fontSize: 12,
                                color: Color.fromRGBO(88, 165, 196, 1),
                                fontWeight: FontWeight.w500),
                            onChanged: (val) {
                              setState(() => cmntreferenceTextAtttached = val);
                            },
                            decoration: InputDecoration(
                              fillColor: Color.fromRGBO(245, 245, 245, 1),
                              filled: true,
                              counterText: '',
                              hintText:
                                  'Add reference like Book Name, Page No.',
                              hintStyle: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[350],
                                  fontWeight: FontWeight.w600),
                              alignLabelWithHint: false,
                              contentPadding: new EdgeInsets.symmetric(
                                  vertical: 10.0, horizontal: 10),
                              errorStyle: TextStyle(
                                  color: Color.fromRGBO(240, 20, 41, 1)),
                              focusColor: Color.fromRGBO(88, 165, 196, 1),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                    color: Color.fromRGBO(245, 245, 245, 1)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: Color.fromRGBO(245, 245, 245, 1),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: EdgeInsets.all(5),
                              width: 160,
                              child: RaisedButton(
                                  shape: RoundedRectangleBorder(
                                      side: BorderSide(
                                          color:
                                              Color.fromRGBO(88, 165, 196, 1)),
                                      borderRadius:
                                          BorderRadius.circular(100.0)),
                                  color: Color.fromRGBO(88, 165, 196, 1),
                                  splashColor: Color.fromRGBO(88, 165, 196, 1),
                                  child: Center(
                                      child: Text(
                                    'Save',
                                    style: GoogleFonts.raleway(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 14),
                                  )),
                                  onPressed: () {
                                    if (ansreferenceTextAtttached != "") {
                                      setState(() {
                                        anstextAttached = true;
                                        Navigator.pop(context);
                                      });
                                    }
                                  }),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ));
            }));
  }

  //Reply Post

  bool replyPostVisibility = false;
  String replyType = 'text';
  String reply = "";
  String replyImageURL = "";

  void _addreplyPostDialog(int qIndex, int ansSelectID, int ansIndex,
      int cmntSelectID, int cmntIndex) {
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
                        SizedBox(width: 30),
                        Text(
                          "Post your reply",
                          style: TextStyle(
                            fontSize: 20,
                            color: Color(0xCB000000),
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            replyPostVisibility = false;
                            replyType = 'text';
                            reply = "";
                            replyImageURL = "";
                            Navigator.pop(context);
                          },
                          icon: Tab(
                              child: Icon(Icons.cancel_rounded,
                                  color: Colors.black45, size: 25)),
                        )
                      ],
                    ),
                    SizedBox(height: 20),
                    Container(height: 1, width: 500, color: Colors.grey[200]),
                  ],
                ),
                content: Container(
                  height: 470,
                  width: 500,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                                replyPostVisibility == false
                                    ? "Choose reply type"
                                    : "Post reply",
                                style: TextStyle(
                                    fontSize: 16, color: Colors.black54)),
                            replyPostVisibility == true
                                ? IconButton(
                                    onPressed: () {
                                      if (replyPostVisibility == true) {
                                        setState(() {
                                          replyPostVisibility = false;
                                        });
                                      }
                                    },
                                    icon: Icon(Icons.arrow_back_ios,
                                        color: Colors.black54, size: 22))
                                : SizedBox(width: 20)
                          ],
                        ),
                        SizedBox(height: 10),
                        replyPostVisibility == true
                            ? Container(
                                margin: EdgeInsets.fromLTRB(20, 0, 20, 0),
                                padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                                decoration: BoxDecoration(
                                    color: Color.fromRGBO(242, 246, 248, 1),
                                    borderRadius: BorderRadius.circular(10)),
                                child: allAnscmntANSIDwise[cmntSelectID]
                                            [cmntIndex]["comment_type"] ==
                                        "text"
                                    ? InkWell(
                                        child: Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width -
                                              30,
                                          margin:
                                              EdgeInsets.fromLTRB(10, 10, 0, 2),
                                          child: ReadMoreText(
                                            allAnscmntANSIDwise[cmntSelectID]
                                                [cmntIndex]["comment"],
                                            textAlign: TextAlign.left,
                                            trimLines: 4,
                                            colorClickableText:
                                                Color(0xff0962ff),
                                            trimMode: TrimMode.Line,
                                            trimCollapsedText: 'read more',
                                            trimExpandedText: 'Show less',
                                            style: TextStyle(
                                              fontFamily: 'Nunito Sans',
                                              fontSize: 16,
                                              color:
                                                  Color.fromRGBO(0, 0, 0, 0.8),
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
                                    : InkWell(
                                        child: Container(
                                          margin: EdgeInsets.all(5),
                                          child: Image.network(
                                              allAnscmntANSIDwise[cmntSelectID]
                                                  [cmntIndex]["comment"],
                                              height: 200,
                                              fit: BoxFit.fill),
                                        ),
                                      ),
                              )
                            : SizedBox(),
                        SizedBox(height: 10),
                        replyPostVisibility == false
                            ? Container(
                                height: 350,
                                margin: EdgeInsets.fromLTRB(20, 0, 20, 0),
                                child: Column(
                                  children: [
                                    SizedBox(
                                      height: 10,
                                    ),
                                    SizedBox(
                                      height: 30,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            setState(() {
                                              replyType = "text";
                                              replyPostVisibility = true;
                                            });
                                          },
                                          child: Column(
                                            children: [
                                              Image.network(
                                                  "https://firebasestorage.googleapis.com/v0/b/hys-pro-41c66.appspot.com/o/assets%2Ftyping.gif?alt=media&token=1a4b65b2-c497-438b-8c3a-a69dcfc7f67d",
                                                  height: 100,
                                                  width: 100),
                                              SizedBox(
                                                height: 7,
                                              ),
                                              Text(
                                                "Keyboard",
                                                style: TextStyle(
                                                  fontFamily: 'Nunito Sans',
                                                  fontSize: 15,
                                                  color: Color(0xff0C2551),
                                                  fontWeight: FontWeight.w700,
                                                ),
                                                textAlign: TextAlign.center,
                                              )
                                            ],
                                          ),
                                        ),
                                        InkWell(
                                          onTap: () {
                                            setState(() {
                                              replyType = "image";
                                              _pickImagereply(
                                                  context,
                                                  qIndex,
                                                  ansSelectID,
                                                  ansIndex,
                                                  cmntSelectID,
                                                  cmntIndex);
                                            });
                                          },
                                          child: Column(
                                            children: [
                                              Image.network(
                                                  "https://firebasestorage.googleapis.com/v0/b/hys-pro-41c66.appspot.com/o/assets%2Fgallery.png?alt=media&token=09a32fa6-5e7c-4139-94e5-d4d74e5f5d6a",
                                                  height: 100,
                                                  width: 100),
                                              SizedBox(
                                                height: 7,
                                              ),
                                              Text(
                                                "Image",
                                                style: TextStyle(
                                                  fontFamily: 'Nunito Sans',
                                                  fontSize: 15,
                                                  color: Color(0xff0C2551),
                                                  fontWeight: FontWeight.w700,
                                                ),
                                                textAlign: TextAlign.center,
                                              )
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              )
                            : Container(
                                height: 350,
                                margin: EdgeInsets.fromLTRB(20, 0, 20, 0),
                                child: ListView(
                                  physics: BouncingScrollPhysics(),
                                  children: [
                                    SizedBox(
                                      height: 20,
                                    ),
                                    replyType == "text"
                                        ? Container(
                                            child: TextFormField(
                                              maxLines: 10,
                                              initialValue: reply,
                                              keyboardType: TextInputType.text,
                                              cursorColor: Color.fromRGBO(
                                                  88, 165, 196, 1),
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  color: Color.fromRGBO(
                                                      88, 165, 196, 1),
                                                  fontWeight: FontWeight.w500),
                                              validator: (val) => ((val!
                                                      .isEmpty))
                                                  ? 'Leave your reply here, you can\'t kept it blank'
                                                  : null,
                                              onChanged: (val) {
                                                setState(() => reply = val);
                                              },
                                              decoration: InputDecoration(
                                                fillColor: Color.fromRGBO(
                                                    245, 245, 245, 1),
                                                filled: true,
                                                counterText: '',
                                                hintText: 'Your reply...',
                                                hintStyle: TextStyle(
                                                    fontSize: 18,
                                                    color: Colors.grey[300],
                                                    fontWeight:
                                                        FontWeight.w600),
                                                alignLabelWithHint: false,
                                                contentPadding:
                                                    new EdgeInsets.symmetric(
                                                        vertical: 10.0,
                                                        horizontal: 10),
                                                errorStyle: TextStyle(
                                                    color: Color.fromRGBO(
                                                        240, 20, 41, 1)),
                                                focusColor: Color.fromRGBO(
                                                    88, 165, 196, 1),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  borderSide: BorderSide(
                                                      color: Color.fromRGBO(
                                                          245, 245, 245, 1)),
                                                ),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  borderSide: BorderSide(
                                                    color: Color.fromRGBO(
                                                        245, 245, 245, 1),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          )
                                        : Container(
                                            height: 100,
                                            child: CachedNetworkImage(
                                              imageUrl: replyImageURL,
                                              fit: BoxFit.contain,
                                              placeholder: (context, url) =>
                                                  Container(
                                                height: 30,
                                                width: 30,
                                                child: Image.network(
                                                  "https://firebasestorage.googleapis.com/v0/b/hys-pro-41c66.appspot.com/o/assets%2Floadingimg.gif?alt=media&token=4ca910f2-c584-4b3a-bbcb-2f1c01d93f67",
                                                ),
                                              ),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      Icon(Icons.error),
                                            ),
                                          ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Container(
                                      height: 50,
                                      width: 400,
                                      child: FlutterMentions(
                                        key: key,
                                        keyboardType: TextInputType.text,
                                        cursorColor:
                                            Color.fromRGBO(88, 165, 196, 1),
                                        decoration: InputDecoration(
                                          fillColor:
                                              Color.fromRGBO(245, 245, 245, 1),
                                          filled: true,
                                          counterText: '',
                                          hintText: '@Tag someone here',
                                          hintStyle: TextStyle(
                                              fontSize: 13,
                                              color: Colors.grey[350],
                                              fontWeight: FontWeight.w600),
                                          alignLabelWithHint: false,
                                          contentPadding:
                                              new EdgeInsets.symmetric(
                                                  vertical: 10.0,
                                                  horizontal: 10),
                                          errorStyle: TextStyle(
                                              color: Color.fromRGBO(
                                                  240, 20, 41, 1)),
                                          focusColor:
                                              Color.fromRGBO(88, 165, 196, 1),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            borderSide: BorderSide(
                                                color: Color.fromRGBO(
                                                    245, 245, 245, 1)),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            borderSide: BorderSide(
                                              color: Color.fromRGBO(
                                                  245, 245, 245, 1),
                                            ),
                                          ),
                                        ),
                                        style: TextStyle(
                                            fontSize: 12,
                                            color:
                                                Color.fromRGBO(88, 165, 196, 1),
                                            fontWeight: FontWeight.w500),
                                        suggestionPosition:
                                            SuggestionPosition.Bottom,
                                        onMarkupChanged: (val) {
                                          setState(() {
                                            markupptext = val;
                                          });
                                        },
                                        onEditingComplete: () {
                                          setState(() {
                                            tagids.clear();
                                            for (int l = 0;
                                                l < markupptext.length;
                                                l++) {
                                              int k = l;
                                              if (markupptext.substring(
                                                      k, k + 1) ==
                                                  "@") {
                                                String test1 =
                                                    markupptext.substring(k);
                                                tagids.add(test1.substring(
                                                    4, test1.indexOf("__]")));
                                              }
                                            }
                                            print(tagids);
                                          });
                                        },
                                        onSuggestionVisibleChanged: (val) {
                                          setState(() {
                                            _showList = val;
                                          });
                                        },
                                        onChanged: (val) {
                                          setState(() {
                                            tagedString = val;
                                          });
                                        },
                                        onSearchChanged: (
                                          trigger,
                                          value,
                                        ) {
                                          print('again | $trigger | $value ');
                                        },
                                        hideSuggestionList: false,
                                        minLines: 1,
                                        maxLines: 5,
                                        mentions: [
                                          Mention(
                                              trigger: r'@',
                                              style: TextStyle(
                                                color: Color.fromRGBO(
                                                    88, 165, 196, 1),
                                              ),
                                              matchAll: false,
                                              data: _users,
                                              suggestionBuilder: (data) {
                                                return Container(
                                                  padding: EdgeInsets.all(10),
                                                  decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      border: Border(
                                                          top: BorderSide(
                                                              color: Color(
                                                                  0xFFE0E1E4)))),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: <Widget>[
                                                      CircleAvatar(
                                                        backgroundImage:
                                                            NetworkImage(
                                                          data['photo'],
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: 20.0,
                                                      ),
                                                      Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: <Widget>[
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(data[
                                                                  'display']),
                                                            ],
                                                          ),
                                                          SizedBox(
                                                            height: 3,
                                                          ),
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                '${data['full_name']}',
                                                                style:
                                                                    TextStyle(
                                                                  color: Color(
                                                                      0xFFAAABAD),
                                                                  fontSize: 11,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      )
                                                    ],
                                                  ),
                                                );
                                              }),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                  ],
                                ),
                              ),
                        replyPostVisibility == true
                            ? Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(5),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.deepPurple.withOpacity(0.1),
                                      spreadRadius: 5,
                                      blurRadius: 10,
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  child: Container(
                                      width: double.infinity,
                                      height: 40,
                                      child: Center(
                                          child: Text("Post",
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                  color: ((reply != "") ||
                                                          (replyImageURL != ""))
                                                      ? Colors.white
                                                      : Colors.grey[400])))),
                                  onPressed: () async {
                                    if ((reply != "") ||
                                        (replyImageURL != "")) {
                                      Dialogs.showLoadingDialog(
                                          context, _keyLoader);
                                      String replyID = "";
                                      setState(() {
                                        tagids.clear();
                                        tagedUsersName.clear();
                                        print(markupptext);
                                        for (int l = 0;
                                            l < markupptext.length - 4;
                                            l++) {
                                          int k = l;
                                          if (markupptext.substring(k, k + 1) ==
                                              "@") {
                                            String test1 =
                                                markupptext.substring(k);
                                            print(
                                                "tagid ${test1.substring(4, test1.indexOf("__]"))}");
                                            tagids.add(test1.substring(
                                                4, test1.indexOf("__]")));
                                          }

                                          if (markupptext.substring(k, k + 3) ==
                                              "(__") {
                                            String test2 =
                                                markupptext.substring(k);
                                            print(test2);
                                            tagedUsersName.add(test2.substring(
                                                3, test2.indexOf("__)")));
                                            print(
                                                "tagusername ${test2.substring(3, test2.indexOf("__)"))}");
                                          }
                                        }
                                        print(tagedUsersName);
                                        print(tagids);
                                        replyID = "reply" +
                                            _currentUserId +
                                            comparedate;
                                        data = [
                                          replyID,
                                          allAnscmntANSIDwise[cmntSelectID]
                                              [cmntIndex]["comment_id"],
                                          allAnswersQIDwise[ansSelectID]
                                              [ansIndex]["answer_id"],
                                          allQuestionsData[qIndex]
                                              ["question_id"],
                                          _currentUserId,
                                          reply != ""
                                              ? reply
                                              : replyImageURL != ""
                                                  ? replyImageURL
                                                  : "na",
                                          replyType,
                                          0,
                                          comparedate
                                        ];
                                      });
                                      // if (tagids.isNotEmpty) {
                                      //   for (int i = 0;
                                      //       i < tagids.length;
                                      //       i++) {
                                      //     await dataLoad
                                      //         .postUsertaggedInAnswerData(
                                      //             [ansID, tagids[i]]);
                                      //   }
                                      // }
                                      bool x = await dataLoad
                                          .postUserAnswerReplyData(data);
                                      if (x == true) {
                                        setState(() {
                                          replyCountAnscmnt[cmntSelectID]
                                                  [cmntIndex] =
                                              replyCountAnscmnt[cmntSelectID]
                                                      [cmntIndex] +
                                                  1;
                                        });
                                        dataLoad.updateAnswerCommentCountData([
                                          allAnscmntANSIDwise[cmntSelectID]
                                              [cmntIndex]["comment_id"],
                                          _currentUserId,
                                          allAnscmntANSIDwise[cmntSelectID]
                                              [cmntIndex]["like_count"],
                                          allAnscmntANSIDwise[cmntSelectID]
                                                  [cmntIndex]["reply_count"] +
                                              1
                                        ]);
                                        ////////////////////////////notification//////////////////////////////////////
                                        String notify_id =
                                            "ntf${allQuestionsData[qIndex]["user_id"]}$comparedate";
                                        notifyCRUD.sendNotification([
                                          notify_id,
                                          "replypost",
                                          "comment",
                                          _currentUserId,
                                          allAnscmntANSIDwise[cmntSelectID]
                                              [cmntIndex]["user_id"],
                                          countData!.value["usertoken"][
                                              allAnscmntANSIDwise[cmntSelectID]
                                                      [cmntIndex]
                                                  ["user_id"]]["tokenid"],
                                          "You got one reply!",
                                          "${userDataDB!.get("first_name")} ${userDataDB!.get("last_name")} replied on your comment.",
                                          allQuestionsData[qIndex]
                                              ["question_id"],
                                          "question",
                                          "false",
                                          comparedate,
                                          "add"
                                        ]);
                                        //////////////////////////////////////////////////////////////////////////
                                        ElegantNotification.success(
                                          title:Text( "Congrats,"),
                                          description:
                                              Text("Your reply posted successfully."),
                                        );

                                        // _update_count(
                                        //     _currentUserId,
                                        //     allQuestionsData[qIndex]
                                        //         ["question_id"],
                                        //     "answer",
                                        //     "+",
                                        //     qIndex);
                                        replyPostVisibility = false;
                                        reply = "";

                                        tagcount = 0;
                                        tagids = [];
                                        tagedUsersName = [];

                                        tagedString = "";
                                        _get_all_questions_posted();
                                        _get_all_answers_posted();
                                        _get_all_answers_comment_posted();
                                        _get_all_answers_reply_posted();
                                        Navigator.of(_keyLoader.currentContext!,
                                                rootNavigator: true)
                                            .pop();
                                        Navigator.of(context).pop();
                                      } else {
                                        ElegantNotification.error(
                                          title:Text( "Error..."),
                                          description:Text( "Something wrong."),
                                        );
                                      }
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    primary:
                                        ((reply != "") || (replyImageURL != ""))
                                            ? active
                                            : Colors.white54,
                                    onPrimary: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                  ),
                                ),
                              )
                            : SizedBox(),
                      ],
                    ),
                  ),
                ),
              );
            }));
  }

  void _pickImagereply(BuildContext context, int qIndex, int ansSelectID,
      int ansIndex, int cmntSelectID, int cmntIndex) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      Dialogs.showLoadingDialog(context, _keyLoader);

      Uint8List? file = result.files.first.bytes;
      String fileName = result.files.first.name;
      UploadTask task = FirebaseStorage.instance
          .ref()
          .child("userAnswerReply/$_currentUserId/$fileName")
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
              .ref("userAnswerReply/$_currentUserId/$fileName")
              .getDownloadURL();
          if (downloadURL != null) {
            Navigator.of(_keyLoader.currentContext!, rootNavigator: true)
                .pop(); //close the dialoge
            setState(() {
              replyImageURL = downloadURL;
              print(downloadURL);
              progress = 0.0;
              replyPostVisibility = true;
            });

            Navigator.of(context).pop();

            _addreplyPostDialog(
                qIndex, ansSelectID, ansIndex, cmntSelectID, cmntIndex);
          }
        }
      });
    }
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
