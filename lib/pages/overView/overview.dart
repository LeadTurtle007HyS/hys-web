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
import 'package:flutter/gestures.dart';
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
import 'package:provider/provider.dart';
import '../../constants/constants.dart';
import '../../main.dart';
import '../../models/answers_model.dart';
import '../../models/network_request_genric.dart';
import '../../models/questionModel.dart';
import '../../providers/answer_provider.dart';
import '../../providers/question_provider.dart';

class OverView extends StatefulWidget {
  @override
  _OverViewState createState() => _OverViewState();
}

class _OverViewState extends State<OverView> {
  Box<dynamic>? userDataDB;
  Box<dynamic>? topicListQLocalDB;

  final dragCotroller = DragController();
  String _currentUserId = FirebaseAuth.instance.currentUser!.uid;

  String selectedSubject = "";
  String selectedTopic = "";
  List<List<String>> topicList = [];
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

  // List<GlobalKey>? KeyList;
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

  QuerySnapshot? service;
  QuerySnapshot? topics;

  String ocrImageURL = "";
  String referenceNotesAtttachedURL = "";
  String referenceVideoAtttachedURL = "";
  String referenceAudioAtttachedURL = "";
  String referenceTextAtttached = "";

  bool notesAttached = false;
  bool videoAttached = false;
  bool audioAttached = false;
  bool textAttached = false;

  double progress = 0.0;
  String base64Image = "";
  Map? totaldata;
  String latex = "";
  List tex = [''];

  @override
  void initState() {
    userDataDB = Hive.box<dynamic>('userdata');
    _get_all_users_data_for_tagging();
    QuestionProviders questionProvider =
        Provider.of<QuestionProviders>(context, listen: false);

    // ques_pers_list1 = questionProvider.ques_pers_List;

    // SocialFeedProvider socialFeedProvider = Provider.of<SocialFeedProvider>(context,listen: false);
    // socialFeedProvider.fetchFeedList(_currentUserId);

    questionProvider.fetchQuestionList(_currentUserId);
    topicListQLocalDB = Hive.box<dynamic>('topiclist');
    crudobj
        .getSubjectListSingleGradeWise((userDataDB!.get("grade")).toString(),
            "Central Board of Secondary Education (CBSE)")
        .then((value) {
      service = value;
      if (service != null) {
        crudobj
            .getTopicSubjectList("Central Board of Secondary Education (CBSE)")
            .then((value) {
          topics = value;
          if (topics != null) {
            for (int i = 0; i < service!.docs.length; i++) {
              List<String> subjectTopics = [];
              subjectList.add(service!.docs[i].get("subject"));
              for (int j = 0; j < topics!.docs.length; j++) {
                if ((topics!.docs[j].get("grade") ==
                        (userDataDB!.get("grade")).toString()) &&
                    (topics!.docs[j].get("subject") ==
                        service!.docs[i].get("subject"))) {
                  subjectTopics.add(topics!.docs[j].get("topic"));
                }
              }
              topicList.add(subjectTopics);
            }

            topicListQLocalDB!.put("topiclist", topicList);
            topicListQLocalDB!.put("subjectlist", subjectList);
          }
        });
      }
    });
    crudobj.getAllUserConnectionStatus().then((value) {
      setState(() {
        connectionStatus = value;
      });
    });

    super.initState();
  }

  @override
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
      Uri.parse(Constant.BASE_URL + 'get_all_users_data_for_tagging'),
    );

    if ((response.statusCode == 200) || (response.statusCode == 201)) {
      setState(() {
        List<dynamic> taggingData = json.decode(response.body);

        for (int i = 0; i < taggingData.length; i++) {
          if (taggingData[i]["user_id"].toString() != _currentUserId) {
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
      });
    }
  }

  Future<void> updateCount(String userId, String questionId,
      String updateCountValue, String symbol, Questions qPost) async {
    QuestionProviders allQuestionProviders =
        Provider.of<QuestionProviders>(context, listen: false);
    allQuestionProviders.updateQuestionDetailsCountValue(
        userId, questionId, updateCountValue, symbol, qPost);
  }

  Future<void> updateLikeType(String type, Questions qPost) async {
    QuestionProviders allQuestionProviders =
        Provider.of<QuestionProviders>(context, listen: false);
    allQuestionProviders.updateLikeType(type, qPost);
  }

  Future<void> updateExamLikelyType(String type, Questions qPost) async {
    QuestionProviders allQuestionProviders =
        Provider.of<QuestionProviders>(context, listen: false);
    allQuestionProviders.updateExamLikeHoodType(type, qPost);
  }

  Future<void> updateToughNessType(String type, Questions qPost) async {
    QuestionProviders allQuestionProviders =
        Provider.of<QuestionProviders>(context, listen: false);
    allQuestionProviders.updateToughnessType(type, qPost);
  }

  showHideLikePopup(Questions questionModel, int index) {
    QuestionProviders allQuestionProviders =
        Provider.of<QuestionProviders>(context, listen: false);
    if (questionModel.isLikeButtonExpanded == "false") {
      allQuestionProviders.hideShowLikeQuestionPopup(index, true);
      likebuttonpopupremove.add(index);
    } else {
      allQuestionProviders.hideShowLikeQuestionPopup(index, false);
      likebuttonpopupremove.remove(index);
    }
  }

  hideLikePopup(int index) {
    QuestionProviders allQuestionProviders =
        Provider.of<QuestionProviders>(context, listen: false);
    allQuestionProviders.hideShowLikeQuestionPopup(index, false);
    likebuttonpopupremove.remove(index);
  }

  Future<void> _pullRefresh() async {
    QuestionProviders allQuestionProviders =
        Provider.of<QuestionProviders>(context, listen: false);
    allQuestionProviders.refreshList(_currentUserId);
  }

  double? _width;
  @override
  Widget build(BuildContext context) {
    QuestionProviders allQuestionProviders =
        Provider.of<QuestionProviders>(context);

    databaseReference.child("hysweb").once().then((snapshot) {
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
              allQuestionProviders.hideAllLikeQuestionPopup(
                  likebuttonpopupremove,
                  examlikelyhoodbuttonpopupremove,
                  toughnessbuttonpopupremove);
            }
            FocusScope.of(context).requestFocus(new FocusNode());
          },
          child: allQuestionProviders.questionList.status == Status.LOADING
              ? _loading()
              : allQuestionProviders.questionList.status == Status.COMPLETED
                  ? _body(allQuestionProviders.questionList.data!)
                  : Center(
                      child: Text(allQuestionProviders.questionList.message),
                    ));
    } else {
      return _loading();
    }
  }

  _body(List<Questions> questionsData) {
    return ScrollablePositionedList.builder(
      itemCount: questionsData.length,
      shrinkWrap: true,
      initialScrollIndex: countData!.value["qANDa"]["jump_to_listview_index"]
          [_currentUserId],
      physics: BouncingScrollPhysics(),
      itemScrollController: itemScrollController,
      itemPositionsListener: itemPositionsListener,
      itemBuilder: (context, index) {
        return index == 0
            ? _ifIisZero(questionsData[index])
            : questionsData[index].question_type == 'shared'
                ? _sharedQuestionFeedText(questionsData[index], index)
                : _questionFeedText(questionsData[index], index);
      },
    );
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

  _ifIisZero(Questions question) {
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
        //  (connectionStatus != null) ? _friendsSuggestion() : SizedBox(),
        question.question_type == 'shared'
            ? _sharedQuestionFeedText(question, 0)
            : _questionFeedText(question, 0)
      ],
    );
  }

  _questionFeedText(Questions question, int index) {
    List _taglist = question.tag_list != null ? question.tag_list : [];
    double _width = MediaQuery.of(context).size.width;
    DateTime tempDate =
        DateTime.parse(question.compare_date.toString().substring(0, 8));
    String current_date = DateFormat.yMMMMd('en_US').format(tempDate);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          //key: KeyList![index],
          width: _width > 530 ? 500 : _width,
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
                                "userid": question.user_id
                              });
                            },
                            child: CircleAvatar(
                              child: ClipOval(
                                child: Container(
                                  child: CachedNetworkImage(
                                    imageUrl: question.profilepic,
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
                                      text: question.is_identity_visible ==
                                              "true"
                                          ? "${question.first_name} ${question.last_name}, "
                                          : "HyS User",
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: dark,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      children: <TextSpan>[
                                        TextSpan(
                                          text: question.is_identity_visible ==
                                                  "true"
                                              ? question.city
                                              : "",
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Color.fromRGBO(0, 0, 0, 0.5),
                                            fontWeight: FontWeight.normal,
                                          ),
                                        )
                                      ]),
                                ),
                                question.is_identity_visible == "true"
                                    ? Text(
                                        question.school_name +
                                            ", " +
                                            "Grade " +
                                            (question.grade).toString(),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Color.fromRGBO(0, 0, 0, 0.5),
                                          fontWeight: FontWeight.normal,
                                        ),
                                      )
                                    : SizedBox(),
                                Text(
                                  "posted on " + "$current_date",
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.normal,
                                    color: Color.fromRGBO(0, 0, 0, 0.5),
                                  ),
                                ),
                                ((_taglist.isNotEmpty))
                                    ? RichText(
                                        text: TextSpan(
                                            text:
                                                'with ${_taglist[0]["first_name"]} ${_taglist[0]["last_name"]}',
                                            style: TextStyle(
                                                fontFamily: 'Nunito Sans',
                                                fontSize: 11,
                                                fontWeight: FontWeight.normal,
                                                color: Color(0xff0C2551)),
                                            children: <TextSpan>[
                                              (_taglist.length > 1)
                                                  ? TextSpan(
                                                      text: ' &',
                                                      style: TextStyle(
                                                          fontFamily:
                                                              'Nunito Sans',
                                                          fontSize: 11,
                                                          fontWeight:
                                                              FontWeight.normal,
                                                          color: Color(
                                                              0xff0C2551)),
                                                      recognizer:
                                                          TapGestureRecognizer()
                                                            ..onTap = () {
                                                              // navigate to desired screen
                                                            })
                                                  : TextSpan(
                                                      text: '',
                                                    ),
                                              (_taglist.length > 1)
                                                  ? TextSpan(
                                                      text:
                                                          ' ${_taglist.length - 1} more',
                                                      style: TextStyle(
                                                          fontFamily:
                                                              'Nunito Sans',
                                                          fontSize: 11,
                                                          fontWeight:
                                                              FontWeight.normal,
                                                          color: Color(
                                                              0xff0C2551)),
                                                      recognizer:
                                                          TapGestureRecognizer()
                                                            ..onTap = () {
                                                              // navigate to desired screen
                                                            })
                                                  : TextSpan(
                                                      text: '',
                                                    )
                                            ]),
                                      )
                                    : SizedBox(),
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
                          _showDialog(question);
                        }),
                  ],
                ),
              ),
              question.question_type == "text"
                  ? InkWell(
                      onTap: () {},
                      child: Container(
                        width: MediaQuery.of(context).size.width - 30,
                        margin: EdgeInsets.fromLTRB(10, 10, 0, 2),
                        child: ReadMoreText(
                          question.question,
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
                          TeXViewDocument(question.question,
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
                                    question.like_count.toString(),
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
                            onTap: () {
                              setState(() {
                                if (question.answer_count > 0) {
                                  _viewAnswerDialog(question, index);
                                }
                              });
                            },
                            child: Container(
                              child: RichText(
                                text: TextSpan(
                                    text: question.answer_count.toString(),
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
                                  (question.examlikelyhood_count +
                                          question.toughness_count)
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
                                  question.view_count.toString(),
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
                      visible: question.isLikeButtonExpanded == 'true',
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [_showQuestionLikedDialog(question, index)],
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
                                (question.like_type == "like")
                                    ? FontAwesome5.thumbs_up
                                    : (question.like_type == "markasimp")
                                        ? Icons.done_all
                                        : (question.like_type == "mydoubttoo")
                                            ? Icons.pan_tool
                                            : FontAwesome5.thumbs_up,
                                color: ((question.like_type == "like") ||
                                        (question.like_type == "markasimp") ||
                                        (question.like_type == "mydoubttoo"))
                                    ? Color(0xff0962ff)
                                    : Color.fromRGBO(0, 0, 0, 0.8),
                                size: 14),
                            onPressed: () {
                              showHideLikePopup(question, index);
                            }),
                        IconButton(
                            icon: Icon(FontAwesome5.share,
                                color: Color.fromRGBO(0, 0, 0, 0.8), size: 14),
                            onPressed: () {
                              _shareQuestionPostDialog(question, index);
                            }),
                        IconButton(
                            icon: Icon(FontAwesome5.edit,
                                color: Color.fromRGBO(0, 0, 0, 0.8), size: 14),
                            onPressed: () {
                              setState(() {
                                latex = "";
                                answer = "";
                              });
                              _addAnswerPostDialog(question, index);
                            }),
                        IconButton(
                            icon: Icon(Entypo.gauge,
                                color: ((question.examlikelyhood_type ==
                                            "low") ||
                                        (question.examlikelyhood_type ==
                                            "moderate") ||
                                        (question.examlikelyhood_type ==
                                            "high") ||
                                        (question.toughness_type == "low") ||
                                        (question.toughness_type == "medium") ||
                                        (question.toughness_type == "high"))
                                    ? Color(0xff0962ff)
                                    : Color.fromRGBO(0, 0, 0, 0.8),
                                size: 15),
                            onPressed: () {
                              setState(() {
                                hideLikePopup(index);
                                _showExamlikelihoodAndToughnessDialog(
                                    question, index);
                              });
                            }),
                        IconButton(
                            icon: Icon(FontAwesome5.ellipsis_v,
                                color: Color.fromRGBO(0, 0, 0, 0.8), size: 13),
                            onPressed: () {
                              if (_currentUserId == question.question_id) {
                                MoreButtonForUser(index);
                              } else {
                                MoreButtonForViewer(question, index);
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
                    //  _answerView(index)
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  //shared question post where the asked question content is OCR
  _sharedQuestionFeedText(Questions questionsModel, int listIndex) {
    List _taglist = (questionsModel.shared_question_details != null &&
            questionsModel.shared_question_details.length > 0 &&
            questionsModel.shared_question_details[0].tag_list != null)
        ? questionsModel.shared_question_details[0].tag_list
        : [];
    double _width = MediaQuery.of(context).size.width;
    DateTime tempDate =
        DateTime.parse(questionsModel.compare_date.toString().substring(0, 8));
    String current_date = DateFormat.yMMMMd('en_US').format(tempDate);
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Container(
        width: _width > 530 ? 500 : _width,
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
                              "userid": questionsModel.user_id
                            });
                          },
                          child: CircleAvatar(
                            child: ClipOval(
                              child: Container(
                                child: CachedNetworkImage(
                                  imageUrl: questionsModel.profilepic,
                                  width:
                                      MediaQuery.of(context).size.width / 10.34,
                                  height:
                                      MediaQuery.of(context).size.width / 10.34,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(
                                    width: MediaQuery.of(context).size.width /
                                        10.34,
                                    height: MediaQuery.of(context).size.width /
                                        10.34,
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
                                    text: questionsModel.is_identity_visible ==
                                            "true"
                                        ? "${questionsModel.first_name} ${questionsModel.last_name}, "
                                        : "HyS User",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: dark,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    children: <TextSpan>[
                                      TextSpan(
                                        text: questionsModel
                                                    .is_identity_visible ==
                                                "true"
                                            ? questionsModel.city
                                            : "",
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Color.fromRGBO(0, 0, 0, 0.5),
                                          fontWeight: FontWeight.normal,
                                        ),
                                      )
                                    ]),
                              ),
                              questionsModel.is_identity_visible == "true"
                                  ? Text(
                                      questionsModel.school_name +
                                          ", " +
                                          "Grade " +
                                          (questionsModel.grade).toString(),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color.fromRGBO(0, 0, 0, 0.5),
                                        fontWeight: FontWeight.normal,
                                      ),
                                    )
                                  : SizedBox(),
                              Text(
                                "Shared on $current_date",
                                style: TextStyle(
                                  fontFamily: 'Nunito Sans',
                                  fontSize: 11,
                                  fontWeight: FontWeight.normal,
                                  color: Color.fromRGBO(0, 0, 0, 0.5),
                                ),
                              ),
                              _taglist.isNotEmpty
                                  ? RichText(
                                      text: TextSpan(
                                          text:
                                              'with ${_taglist[0]['first_name']} ${_taglist[0]['last_name']}',
                                          style: TextStyle(
                                              fontFamily: 'Nunito Sans',
                                              fontSize: 11,
                                              fontWeight: FontWeight.normal,
                                              color: Color(0xff0C2551)),
                                          children: <TextSpan>[
                                            (_taglist.length > 1)
                                                ? TextSpan(
                                                    text: ' &',
                                                    style: TextStyle(
                                                        fontFamily:
                                                            'Nunito Sans',
                                                        fontSize: 11,
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        color:
                                                            Color(0xff0C2551)),
                                                    recognizer:
                                                        TapGestureRecognizer()
                                                          ..onTap = () {
                                                            // navigate to desired screen
                                                          })
                                                : TextSpan(
                                                    text: '',
                                                  ),
                                            (_taglist.length > 1)
                                                ? TextSpan(
                                                    text:
                                                        ' ${_taglist.length - 1} more',
                                                    style: TextStyle(
                                                        fontFamily:
                                                            'Nunito Sans',
                                                        fontSize: 11,
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        color:
                                                            Color(0xff0C2551)),
                                                    recognizer:
                                                        TapGestureRecognizer()
                                                          ..onTap = () {
                                                            // navigate to desired screen
                                                          })
                                                : TextSpan(
                                                    text: '',
                                                  )
                                          ]),
                                    )
                                  : SizedBox(),
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
                  questionsModel.question,
                  textAlign: TextAlign.left,
                  trimLines: 4,
                  colorClickableText: Color(0xff0962ff),
                  trimMode: TrimMode.Line,
                  trimCollapsedText: 'read more',
                  trimExpandedText: 'Show less',
                  style: TextStyle(
                    fontFamily: 'Nunito Sans',
                    fontSize: 14,
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
            _sharedQuestion(questionsModel),
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
                                  questionsModel.like_count.toString(),
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
                          onTap: () {
                            setState(() {
                              if (questionsModel.answer_count > 0) {
                                _viewAnswerDialog(questionsModel, listIndex);
                              }
                            });
                          },
                          child: Container(
                            child: RichText(
                              text: TextSpan(
                                  text: questionsModel.answer_count.toString(),
                                  style: TextStyle(
                                    fontFamily: 'Nunito Sans',
                                    color: Color.fromRGBO(205, 61, 61, 1),
                                  ),
                                  children: <TextSpan>[
                                    TextSpan(
                                      text: ' Answers',
                                      style: TextStyle(
                                        fontFamily: 'Nunito Sans',
                                        fontSize: 12,
                                        color: Color.fromRGBO(0, 0, 0, 0.8),
                                        fontWeight: FontWeight.w500,
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
                                (questionsModel.examlikelyhood_count +
                                        questionsModel.toughness_count)
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
                                questionsModel.view_count.toString(),
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
                    visible: questionsModel.isLikeButtonExpanded == "true",
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        _showQuestionLikedDialog(questionsModel, listIndex)
                      ],
                    ),
                  ),
                  Container(
                      margin: EdgeInsets.only(left: 2, right: 2, top: 5),
                      color: Colors.white54,
                      height: 1,
                      width: MediaQuery.of(context).size.width),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                          icon: Icon(
                              (questionsModel.like_type == "like")
                                  ? FontAwesome5.thumbs_up
                                  : (questionsModel.like_type == "markasimp")
                                      ? Icons.done_all
                                      : (questionsModel.like_type ==
                                              "mydoubttoo")
                                          ? Icons.pan_tool
                                          : FontAwesome5.thumbs_up,
                              color: ((questionsModel.like_type == "like") ||
                                      (questionsModel.like_type ==
                                          "markasimp") ||
                                      (questionsModel.like_type ==
                                          "mydoubttoo"))
                                  ? Color(0xff0962ff)
                                  : Color.fromRGBO(0, 0, 0, 0.8),
                              size: 14),
                          onPressed: () {
                            showHideLikePopup(questionsModel, listIndex);
                          }),
                      IconButton(
                          icon: Icon(FontAwesome5.share,
                              color: Color.fromRGBO(0, 0, 0, 0.8), size: 14),
                          onPressed: () {
                            _shareQuestionPostDialog(questionsModel, listIndex);
                          }),
                      IconButton(
                          icon: Icon(FontAwesome5.edit,
                              color: Color.fromRGBO(0, 0, 0, 0.8), size: 14),
                          onPressed: () {
                            setState(() {
                              latex = "";
                              answer = "";
                            });
                            _addAnswerPostDialog(questionsModel, listIndex);
                          }),
                      IconButton(
                          icon: Icon(Entypo.gauge,
                              color: ((questionsModel.examlikelyhood_type ==
                                          "low") ||
                                      (questionsModel.examlikelyhood_type ==
                                          "moderate") ||
                                      (questionsModel.examlikelyhood_type ==
                                          "high") ||
                                      (questionsModel.toughness_type ==
                                          "low") ||
                                      (questionsModel.toughness_type ==
                                          "medium") ||
                                      (questionsModel.toughness_type == "high"))
                                  ? Color(0xff0962ff)
                                  : Color.fromRGBO(0, 0, 0, 0.8),
                              size: 15),
                          onPressed: () {
                            hideLikePopup(listIndex);
                            _showExamlikelihoodAndToughnessDialog(
                                questionsModel, listIndex);
                          }),
                      IconButton(
                          icon: Icon(FontAwesome5.ellipsis_v,
                              color: Color.fromRGBO(0, 0, 0, 0.8), size: 13),
                          onPressed: () {
                            if (_currentUserId == questionsModel.question_id) {
                              MoreButtonForUser(listIndex);
                            } else {
                              MoreButtonForViewer(questionsModel, listIndex);
                            }
                          }),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      )
    ]);
  }

  //question container for shared post
  _sharedQuestion(Questions questionsModel) {
    List _taglist = (questionsModel.shared_question_details != null &&
            questionsModel.shared_question_details.length > 0 &&
            questionsModel.shared_question_details[0].tag_list != null)
        ? questionsModel.shared_question_details[0].tag_list
        : [];
    DateTime tempDate1 = DateTime.parse(questionsModel
        .shared_question_details[0].compare_date
        .toString()
        .substring(0, 8));
    String current_date1 = DateFormat.yMMMMd('en_US').format(tempDate1);
    return Container(
      width: _width! < 600 ? _width! / 1.33 : 450,
      padding: EdgeInsets.all(5),
      margin: EdgeInsets.only(top: 20),
      decoration: BoxDecoration(
          color: Color.fromRGBO(242, 246, 248, 1),
          border: Border.all(color: Colors.white, width: 2),
          borderRadius: BorderRadius.circular(10)),
      child: Column(
        children: [
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
                              .child(FirebaseAuth.instance.currentUser!.uid)
                              .update({
                            "$_currentUserId": 7,
                            "userid": questionsModel
                                .shared_question_details[0].user_id
                          });
                        },
                        child: CircleAvatar(
                          child: ClipOval(
                            child: Container(
                              width: MediaQuery.of(context).size.width / 10.34,
                              height: MediaQuery.of(context).size.width / 10.34,
                              child: questionsModel.shared_question_details[0]
                                          .is_identity_visible ==
                                      "true"
                                  ? CachedNetworkImage(
                                      imageUrl: questionsModel
                                          .shared_question_details[0]
                                          .profilepic,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => Container(
                                          height: 30,
                                          width: 30,
                                          child: Image.asset(
                                            "assets/loadingimg.gif",
                                          )),
                                      errorWidget: (context, url, error) =>
                                          Icon(Icons.error),
                                    )
                                  : Container(
                                      height: 30,
                                      width: 30,
                                      child: Image.asset(
                                        "assets/boy5.jpg",
                                      )),
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
                                  text: questionsModel
                                              .shared_question_details[0]
                                              .is_identity_visible ==
                                          "true"
                                      ? "${questionsModel.shared_question_details[0].first_name} ${questionsModel.shared_question_details[0].last_name}"
                                      : "HyS User",
                                  style: TextStyle(
                                    fontFamily: 'Nunito Sans',
                                    fontSize: 15,
                                    color: Color.fromRGBO(0, 0, 0, 0.8),
                                    fontWeight: FontWeight.bold,
                                  ),
                                  children: <TextSpan>[
                                    TextSpan(
                                      text: questionsModel
                                                  .shared_question_details[0]
                                                  .is_identity_visible ==
                                              "true"
                                          ? ', ${questionsModel.shared_question_details[0].city}'
                                          : "",
                                      style: TextStyle(
                                        fontFamily: 'Nunito Sans',
                                        fontSize: 11,
                                        color: Color.fromRGBO(0, 0, 0, 0.7),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    )
                                  ]),
                            ),
                            questionsModel.shared_question_details[0]
                                        .is_identity_visible ==
                                    "true"
                                ? Text(
                                    questionsModel.shared_question_details[0]
                                                .school_name
                                                .toString()
                                                .length >
                                            25
                                        ? questionsModel
                                                .shared_question_details[0]
                                                .school_name
                                                .toString()
                                                .substring(0, 25) +
                                            "..., " +
                                            "Grade " +
                                            questionsModel
                                                .shared_question_details[0]
                                                .grade
                                                .toString()
                                        : questionsModel
                                                .shared_question_details[0]
                                                .school_name
                                                .toString() +
                                            "..., " +
                                            "Grade " +
                                            questionsModel
                                                .shared_question_details[0]
                                                .grade
                                                .toString(),
                                    style: TextStyle(
                                      fontFamily: 'Nunito Sans',
                                      fontSize: 11,
                                      color: Color.fromRGBO(0, 0, 0, 0.5),
                                      fontWeight: FontWeight.normal,
                                    ),
                                  )
                                : SizedBox(),
                            Text(
                              "Posted on $current_date",
                              style: TextStyle(
                                fontFamily: 'Nunito Sans',
                                fontSize: 11,
                                fontWeight: FontWeight.normal,
                                color: Color.fromRGBO(0, 0, 0, 0.5),
                              ),
                            ),
                            _taglist.isNotEmpty
                                ? RichText(
                                    text: TextSpan(
                                        text:
                                            'with ${_taglist[0]['first_name']} ${_taglist[0]['last_name']}',
                                        style: TextStyle(
                                            fontFamily: 'Nunito Sans',
                                            fontSize: 11,
                                            fontWeight: FontWeight.normal,
                                            color: Color(0xff0C2551)),
                                        children: <TextSpan>[
                                          (_taglist.length > 1)
                                              ? TextSpan(
                                                  text: ' &',
                                                  style: TextStyle(
                                                      fontFamily: 'Nunito Sans',
                                                      fontSize: 11,
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      color: Color(0xff0C2551)),
                                                  recognizer:
                                                      TapGestureRecognizer()
                                                        ..onTap = () {
                                                          // navigate to desired screen
                                                        })
                                              : TextSpan(
                                                  text: '',
                                                ),
                                          (_taglist.length > 1)
                                              ? TextSpan(
                                                  text:
                                                      ' ${_taglist.length - 1} more',
                                                  style: TextStyle(
                                                      fontFamily: 'Nunito Sans',
                                                      fontSize: 11,
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      color: Color(0xff0C2551)),
                                                  recognizer:
                                                      TapGestureRecognizer()
                                                        ..onTap = () {
                                                          // navigate to desired screen
                                                        })
                                              : TextSpan(
                                                  text: '',
                                                )
                                        ]),
                                  )
                                : SizedBox(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                    icon: Icon(
                      Icons.description,
                      size: 16,
                      color: Color.fromRGBO(0, 0, 0, 0.8),
                    ),
                    onPressed: () {
                      _showDialog(questionsModel);
                    }),
              ],
            ),
          ),
          questionsModel.shared_question_details[0].question_type == "text"
              ? InkWell(
                  onTap: () {},
                  child: Container(
                    width: MediaQuery.of(context).size.width - 30,
                    margin: EdgeInsets.fromLTRB(10, 10, 0, 2),
                    child: ReadMoreText(
                      questionsModel.shared_question_details[0].question,
                      textAlign: TextAlign.left,
                      trimLines: 4,
                      colorClickableText: Color(0xff0962ff),
                      trimMode: TrimMode.Line,
                      trimCollapsedText: 'read more',
                      trimExpandedText: 'Show less',
                      style: TextStyle(
                        fontFamily: 'Nunito Sans',
                        fontSize: 14,
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
              : InkWell(
                  onTap: () {},
                  child: Container(
                    padding: EdgeInsets.all(5),
                    child: SizedBox(
                      child: TeXView(
                        loadingWidgetBuilder: (context) {
                          return Container(
                            width: MediaQuery.of(context).size.width / 1.31,
                            child: PlaceholderLines(
                              count: 2,
                              animate: true,
                              color: Colors.white,
                            ),
                          );
                        },
                        child: TeXViewColumn(children: [
                          TeXViewInkWell(
                            id: "0",
                            child: TeXViewDocument(
                                questionsModel
                                    .shared_question_details[0].question,
                                style: TeXViewStyle(
                                  fontStyle: TeXViewFontStyle(
                                      fontFamily: 'Nunito Sans',
                                      fontWeight: TeXViewFontWeight.w400,
                                      fontSize: 9,
                                      sizeUnit: TeXViewSizeUnit.pt),
                                  padding: TeXViewPadding.only(
                                      left: 5, right: 5, top: 5),
                                )),
                          ),
                        ]),
                        style: TeXViewStyle(
                          elevation: 10,
                          backgroundColor: Color.fromRGBO(242, 246, 248, 1),
                        ),
                      ),
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  //this is button to show more options  of questions for other users
  MoreButtonForViewer(Questions questionsModel, int i) {
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
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
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
                                          color: Colors.black87,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
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
                                          color: Colors.black87,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
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
                                          color: Colors.black87,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            collapsed: SizedBox(),
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          InkWell(
                            onLongPress: () {},
                            onTap: () async {
                              if (questionsModel.is_save == "") {
                                setState(() {
                                  questionsModel.is_save = _currentUserId;
                                });
                                ElegantNotification.success(
                                        title: Text("Saved!"),
                                        description:
                                            Text("Post is saved successfully."))
                                    .show(context);
                              } else {
                                setState(() {
                                  questionsModel.is_save = "";
                                });
                              }
                              dataLoad.addQuestionSaved([
                                _currentUserId,
                                questionsModel.question_id,
                                comparedate
                              ]);
                              Navigator.of(context).pop();
                            },
                            child: Container(
                              height: 65,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.arrow_downward_rounded,
                                    color: questionsModel.is_save == ""
                                        ? Colors.redAccent
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
                                          color: questionsModel.is_save == ""
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
                                          color: questionsModel.is_save == ""
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
                            onLongPress: () {},
                            onTap: () async {
                              if (questionsModel.is_bookmark == "") {
                                setState(() {
                                  questionsModel.is_bookmark = _currentUserId;
                                });
                                ElegantNotification.success(
                                        title: Text("Bookmarked!"),
                                        description: Text(
                                            "Post is bookmarked successfully."))
                                    .show(context);
                              } else {
                                setState(() {
                                  questionsModel.is_bookmark = "";
                                });
                              }
                              dataLoad.addQuestionBookmarked([
                                _currentUserId,
                                questionsModel.question_id,
                                comparedate
                              ]);
                              Navigator.of(context).pop();
                            },
                            child: Container(
                              height: 65,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.bookmark_border,
                                    color: questionsModel.is_bookmark == ""
                                        ? Colors.redAccent
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
                                          color:
                                              questionsModel.is_bookmark == ""
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
                                          color:
                                              questionsModel.is_bookmark == ""
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
                            onTap: () {
                              Navigator.of(context).pop();
                            },
                            child: Container(
                              height: 65,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.book_outlined,
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
                                        'Ask reference',
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
                                        'Ask reference of this question',
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

//this is button to show more options  of questions for the person who posted the question
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

  List<bool> anslikebutton = [];
  List<int> anslikebuttonpopupremove = [];

  ansShowHideLikePopup(AnswerModel answerModel, int index) {
    AnswerProvider answerProviders =
        Provider.of<AnswerProvider>(context, listen: false);
    if (answerModel.answerLikeButton == "false") {
      answerProviders.hideShowLikeAnswerPopup(index, true);
      anslikebuttonpopupremove.add(index);
    } else {
      answerProviders.hideShowLikeAnswerPopup(index, false);
      anslikebuttonpopupremove.remove(index);
    }
  }

  ansHideLikePopup(int index) {
    AnswerProvider answerProviders =
        Provider.of<AnswerProvider>(context, listen: false);
    answerProviders.hideShowLikeAnswerPopup(index, false);
    anslikebuttonpopupremove.remove(index);
  }

  void _viewAnswerDialog(Questions question, int qIndex) {
    AnswerProvider answerProvider =
        Provider.of<AnswerProvider>(context, listen: false);
    answerProvider.fetchAnswerList(question.question_id);
    showDialog(
        context: context,
        barrierColor: Colors.grey.withOpacity(0.2),
        barrierDismissible: false,
        builder: (_) =>
            Consumer<AnswerProvider>(builder: (context, answerProvider, _) {
              return answerProvider.answerList.status == Status.LOADING
                  ? _loading()
                  : answerProvider.answerList.status == Status.COMPLETED
                      ? AlertDialog(
                          backgroundColor: Color.fromARGB(255, 255, 255, 255),
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
                              Container(
                                  height: 1,
                                  width: 500,
                                  color: Colors.grey[200]),
                            ],
                          ),
                          content: Container(
                              height: 500,
                              width: 600,
                              child: SingleChildScrollView(
                                  child: Column(children: [
                                question.question_type == 'shared'
                                    ? _sharedQuestionFeedText(question, qIndex)
                                    : _questionFeedText(question, qIndex),
                                SizedBox(height: 10),
                                answerProvider.answerList.status ==
                                        Status.LOADING
                                    ? _loading()
                                    : answerProvider.answerList.status ==
                                            Status.COMPLETED
                                        ? _answerView(
                                            answerProvider.answerList.data!,
                                            question,
                                            qIndex,
                                            answerProvider)
                                        : Center(
                                            child: Text(answerProvider
                                                .answerList.message),
                                          )
                              ]))),
                        )
                      : Center(
                          child: Text(answerProvider.answerList.message),
                        );
            }));
  }

  //show answer
  _answerView(List<AnswerModel> answerPost, Questions question, int qIndex,
      AnswerProvider answerProvider) {
    return Column(
      children: [
        Container(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: answerPost.length,
            itemBuilder: (context, index) {
              DateTime tempDate = DateTime.parse(
                  answerPost[index].compareDate.toString().substring(0, 8));
              String current_date = DateFormat.yMMMMd('en_US').format(tempDate);
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
                              answerPost[index].profilepic.toString(),
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
                              color: Color.fromRGBO(242, 246, 248, 1),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10))),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    "${answerPost[index].firstName} ${answerPost[index].lastName}",
                                    style: TextStyle(
                                        color: Color(0xFF4D4D4D),
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w700),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      //             if (_currentUserId == answerPost.userId) {
                                      //   answerMoreButtonForUser(answerPost);
                                      // } else {
                                      //   answerMoreButtonForViewer(i);
                                      // }
                                    },
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
                                    answerPost[index]
                                                .schoolName
                                                .toString()
                                                .length >
                                            25
                                        ? answerPost[index]
                                                .schoolName
                                                .toString()
                                                .substring(0, 25) +
                                            "..., " +
                                            "Grade " +
                                            answerPost[index].grade.toString()
                                        : answerPost[index]
                                                .schoolName
                                                .toString() +
                                            "..., " +
                                            "Grade " +
                                            answerPost[index].grade.toString(),
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
                              answerPost[index].answerType == "text"
                                  ? InkWell(
                                      child: ReadMoreText(
                                        answerPost[index].answer,
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
                                  : answerPost[index].answerType == "ocr"
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
                                                    onTap: tapCallbackHandler,
                                                    child: TeXViewDocument(
                                                        answerPost[index]
                                                            .answer,
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
                                                                      .pt),
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
                                                answerPost[index]
                                                    .image
                                                    .toString(),
                                                height: 300,
                                                fit: BoxFit.fill),
                                          ),
                                        ),
                              SizedBox(
                                height: 4,
                              ),
                              Row(
                                children: [
                                  answerPost[index].videoReference != null &&
                                          answerPost[index]
                                              .videoReference
                                              .isNotEmpty
                                      ? InkWell(
                                          onTap: () {
                                            // Navigator.push(
                                            //   context,
                                            //   MaterialPageRoute(
                                            //     builder: (context) {
                                            //       return Video_Player(
                                            //           "https://firebasestorage.googleapis.com/v0/b/hys-pro-41c66.appspot.com/o/userVideoReference%2Fvideothumbnail.jpg?alt=media&token=1279e004-3caa-4586-960b-90ca67d9c5a3",
                                            //           answerPost[index].videoReference);
                                            //     },
                                            //   ),
                                            // );
                                          },
                                          child: Material(
                                            elevation: 1,
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            child: Container(
                                                padding: EdgeInsets.all(4),
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5),
                                                    color: Color(0xFFE9A81D)),
                                                child: Center(
                                                    child: Icon(
                                                        Icons.play_arrow,
                                                        color: Colors.white,
                                                        size: 15))),
                                          ),
                                        )
                                      : SizedBox(),
                                  answerPost[index].videoReference != null &&
                                          answerPost[index]
                                              .videoReference
                                              .isNotEmpty
                                      ? SizedBox(
                                          width: 20,
                                        )
                                      : SizedBox(),
                                  answerPost[index].audioReference != null &&
                                          answerPost[index]
                                              .audioReference
                                              .isNotEmpty
                                      ? InkWell(
                                          onTap: () async {
                                            _launchInBrowser(answerPost[index]
                                                .audioReference);
                                            // await _audioPlayer
                                            //     .play(answerPost[index].audioReference);

                                            // _playAudioFileDialog(
                                            //     context, answerPost[index].audioReference);
                                          },
                                          child: Material(
                                            elevation: 1,
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            child: Container(
                                                padding: EdgeInsets.all(4),
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5),
                                                    color: Color(0xFFDB0A03)),
                                                child: Center(
                                                    child: Icon(Icons.mic,
                                                        color: Colors.white,
                                                        size: 15))),
                                          ),
                                        )
                                      : SizedBox(),
                                  answerPost[index].audioReference != null &&
                                          answerPost[index]
                                              .audioReference
                                              .isNotEmpty
                                      ? SizedBox(
                                          width: 20,
                                        )
                                      : SizedBox(),
                                  answerPost[index].noteReference != null &&
                                          answerPost[index]
                                              .noteReference
                                              .isNotEmpty
                                      ? InkWell(
                                          onTap: () {
                                            // _launchInWebViewOrVC(
                                            //     answerPost[index].noteReference);
                                          },
                                          child: Material(
                                            elevation: 1,
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            child: Container(
                                                padding: EdgeInsets.all(4),
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5),
                                                    color: Color(0xFF197E00)),
                                                child: Center(
                                                    child: Icon(
                                                        Icons
                                                            .description_outlined,
                                                        color: Colors.white,
                                                        size: 15))),
                                          ),
                                        )
                                      : SizedBox(),
                                  answerPost[index].noteReference != null &&
                                          answerPost[index]
                                              .noteReference
                                              .isNotEmpty
                                      ? SizedBox(
                                          width: 20,
                                        )
                                      : SizedBox(),
                                  answerPost[index].textReference != null &&
                                          answerPost[index]
                                              .textReference
                                              .isNotEmpty
                                      ? InkWell(
                                          onTap: () async {
                                            showDialog(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                content: ListTile(
                                                  title: Text("Reference"),
                                                  subtitle: Text(
                                                      "${answerPost[index].textReference}"),
                                                ),
                                                actions: <Widget>[
                                                  FlatButton(
                                                    child: Text('Ok'),
                                                    onPressed: () =>
                                                        Navigator.of(context)
                                                            .pop(),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                          child: Material(
                                            elevation: 1,
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            child: Container(
                                                padding: EdgeInsets.all(4),
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5),
                                                    color: Color(0xFF630191)),
                                                child: Center(
                                                    child: Icon(
                                                        Icons.text_fields,
                                                        color: Colors.white,
                                                        size: 15))),
                                          ),
                                        )
                                      : SizedBox(),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Visibility(
                          visible: answerPost[index].answerLikeButton == 'true',
                          child: Container(
                            padding: EdgeInsets.only(top: 5, bottom: 5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                _showAnswerLikedDialog(
                                    answerPost[index], index, answerProvider)
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(1.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              IconButton(
                                  onPressed: () {
                                    setState(() {
                                      ansShowHideLikePopup(
                                          answerPost[index], index);
                                    });
                                  },
                                  icon: Icon(
                                      answerPost[index].likeType == ''
                                          ? FontAwesome5.thumbs_up
                                          : answerPost[index].likeType == 'like'
                                              ? FontAwesome5.thumbs_up
                                              : answerPost[index].likeType ==
                                                      'markasimp'
                                                  ? Icons.done_all
                                                  : answerPost[index]
                                                              .likeType ==
                                                          'helpful'
                                                      ? Icons.pan_tool
                                                      : FontAwesome5.thumbs_up,
                                      color: answerPost[index].likeType == ''
                                          ? Colors.black54
                                          : Color(0xff0962ff),
                                      size: 14)),
                              SizedBox(
                                width: 5,
                              ),
                              answerPost[index].likeCount > 0
                                  ? Text(
                                      " ${answerPost[index].likeCount.toString()} ",
                                      style: TextStyle(
                                          color: Colors.black54,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400),
                                    )
                                  : SizedBox(),
                              SizedBox(
                                width: 3,
                              ),
                              Text(
                                " | ",
                                style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700),
                              ),
                              SizedBox(
                                width: 3,
                              ),
                              IconButton(
                                  onPressed: () {},
                                  icon: Icon(Icons.chat,
                                      color: Colors.black54, size: 14)),
                              answerPost[index].commentCount > 0
                                  ? Text(
                                      " ${answerPost[index].commentCount.toString()} ",
                                      style: TextStyle(
                                          color: Colors.black54,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400),
                                    )
                                  : SizedBox(),
                              SizedBox(
                                width: 3,
                              ),
                              Text(
                                " | ",
                                style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700),
                              ),
                              Tooltip(
                                preferBelow: true,
                                decoration: BoxDecoration(
                                    color: Colors.black54,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(5))),
                                message: "UpVote",
                                child: IconButton(
                                  icon: Icon(Typicons.up_outline,
                                      color:
                                          answerPost[index].voteType == 'upvote'
                                              ? Color(0xff0962ff)
                                              : Colors.black54,
                                      size: 14),
                                  onPressed: () {
                                    answerProvider.updateAnsUpvoteDetails(
                                        index,
                                        'upvote',
                                        countData!.value["usertoken"]
                                                [answerPost[index].userId]
                                            ["tokenid"],
                                        "You got a vote",
                                        "${userDataDB!.get('first_name')} ${userDataDB!.get('last_name')} voted your answer as up.");
                                  },
                                ),
                              ),
                              answerPost[index].upvoteCount > 0
                                  ? Text(
                                      " ${answerPost[index].upvoteCount.toString()} ",
                                      style: TextStyle(
                                          color: Colors.black54,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400),
                                    )
                                  : SizedBox(),
                              Text(
                                " | ",
                                style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700),
                              ),
                              Tooltip(
                                preferBelow: true,
                                decoration: BoxDecoration(
                                    color: Colors.black54,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(5))),
                                message: "DownVote",
                                child: IconButton(
                                  icon: Icon(Typicons.down_outline,
                                      color: answerPost[index].voteType ==
                                              'downvote'
                                          ? Color(0xff0962ff)
                                          : Colors.black54,
                                      size: 14),
                                  onPressed: () {
                                    answerProvider.updateAnsUpvoteDetails(
                                        index,
                                        'downvote',
                                        countData!.value["usertoken"]
                                                [answerPost[index].userId]
                                            ["tokenid"],
                                        "You got a vote",
                                        "${userDataDB!.get('first_name')} ${userDataDB!.get('last_name')} voted your answer as down.");
                                  },
                                ),
                              ),
                              answerPost[index].downvoteCount > 0
                                  ? Text(
                                      " ${answerPost[index].downvoteCount.toString()} ",
                                      style: TextStyle(
                                          color: Colors.black54,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400),
                                    )
                                  : SizedBox(),
                            ],
                          ),
                        ),
                        // _comment(qIndex, ansSelectID, index)
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  _showAnswerLikedDialog(
      AnswerModel answerPost, int ansIndex, AnswerProvider answerProvider) {
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
                        color: (answerPost.likeType == 'like')
                            ? Color(0xff0962ff)
                            : Color(0xff0C2551)),
                    onPressed: () async {
                      answerProvider.updateAnsLikeDetails(
                          ansIndex,
                          'like',
                          countData!.value["usertoken"][answerPost.userId]
                              ["tokenid"],
                          "You got a like",
                          "${userDataDB!.get('first_name')} ${userDataDB!.get('last_name')} like your answer.");
                      answerProvider
                          .hideAllLikeAnswerPopup(anslikebuttonpopupremove);
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
                        color: answerPost.likeType == "markasimp"
                            ? Color(0xff0962ff)
                            : Color(0xff0C2551)),
                    onPressed: () async {
                      answerProvider.updateAnsLikeDetails(
                          ansIndex,
                          'markasimp',
                          countData!.value["usertoken"][answerPost.userId]
                              ["tokenid"],
                          "You got a like",
                          "${userDataDB!.get('first_name')} ${userDataDB!.get('last_name')} marked your answer as important.");
                      answerProvider
                          .hideAllLikeAnswerPopup(anslikebuttonpopupremove);
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
                        color: answerPost.likeType == "helpful"
                            ? Color(0xff0962ff)
                            : Color(0xff0C2551)),
                    onPressed: () async {
                      answerProvider.updateAnsLikeDetails(
                          ansIndex,
                          'helpful',
                          countData!.value["usertoken"][answerPost.userId]
                              ["tokenid"],
                          "You got a like",
                          "${userDataDB!.get('first_name')} ${userDataDB!.get('last_name')} marked your answer as helpful.");
                      answerProvider
                          .hideAllLikeAnswerPopup(anslikebuttonpopupremove);
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

//   //comment
//   _comment(int qIndex, int ansSelectID, int ansIndex) {
//     int cmntSelectID = -1;
//     for (int i = 0; i < allAnscmntAnswerID.length; i++) {
//       if (allAnscmntAnswerID[i] ==
//           allAnswersQIDwise[ansSelectID][ansIndex]["answer_id"]) {
//         cmntSelectID = i;
//       }
//     }
//     return cmntSelectID != -1
//         ? Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               SizedBox(height: 5),
//               allAnscmntANSIDwise[cmntSelectID].length > 1
//                   ? Row(
//                       mainAxisAlignment: MainAxisAlignment.start,
//                       children: [
//                         InkWell(
//                           onTap: () {
//                             setState(() {
//                               allAnscmntANSIDwisebool[ansSelectID] =
//                                   !allAnscmntANSIDwisebool[ansSelectID];
//                             });
//                           },
//                           child: Container(
//                             child: Text(
//                                 allAnscmntANSIDwisebool[ansSelectID] == true
//                                     ? "Hide comments"
//                                     : "View ${allAnscmntANSIDwise[cmntSelectID].length - 1} more comments",
//                                 style: TextStyle(
//                                     fontSize: 14,
//                                     color: Colors.black.withOpacity(0.6),
//                                     fontWeight: FontWeight.bold)),
//                           ),
//                         ),
//                       ],
//                     )
//                   : SizedBox(),
//               SizedBox(height: 5),
//               Container(
//                 width: 350,
//                 child: ListView.builder(
//                     shrinkWrap: true,
//                     itemCount: allAnscmntANSIDwisebool[ansSelectID] == false
//                         ? 1
//                         : allAnscmntANSIDwise[cmntSelectID].length,
//                     itemBuilder: (context, i) {
//                       DateTime tempDate = DateTime.parse(
//                           allAnscmntANSIDwise[cmntSelectID][i]["compare_date"]
//                               .toString()
//                               .substring(0, 8));
//                       String current_date =
//                           DateFormat.yMMMMd('en_US').format(tempDate);
//                       return Container(
//                         margin: EdgeInsets.only(right: 10),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.start,
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Container(
//                               height: 35,
//                               width: 35,
//                               margin: EdgeInsets.all(10),
//                               child: CircleAvatar(
//                                 child: ClipOval(
//                                   child: Container(
//                                     child: Image.network(
//                                       allAnscmntANSIDwise[cmntSelectID][i]
//                                           ["profilepic"],
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                             Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 SizedBox(height: 10),
//                                 Container(
//                                   width: 270,
//                                   padding: EdgeInsets.all(10),
//                                   decoration: BoxDecoration(
//                                       color: Colors.white,
//                                       borderRadius: BorderRadius.all(
//                                           Radius.circular(10))),
//                                   child: Column(
//                                     mainAxisAlignment: MainAxisAlignment.start,
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       Row(
//                                         mainAxisAlignment:
//                                             MainAxisAlignment.spaceBetween,
//                                         crossAxisAlignment:
//                                             CrossAxisAlignment.center,
//                                         children: [
//                                           Text(
//                                             allAnscmntANSIDwise[cmntSelectID][i]
//                                                     ["first_name"] +
//                                                 " " +
//                                                 allAnscmntANSIDwise[
//                                                         cmntSelectID][i]
//                                                     ["last_name"],
//                                             style: TextStyle(
//                                                 color: Color(0xFF4D4D4D),
//                                                 fontSize: 13.5,
//                                                 fontWeight: FontWeight.w700),
//                                           ),
//                                           InkWell(
//                                             onTap: () {},
//                                             child: Container(
//                                               child: Icon(
//                                                 Icons.more_horiz_outlined,
//                                                 size: 17,
//                                                 color: Colors.black54,
//                                               ),
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                       Row(
//                                         mainAxisAlignment:
//                                             MainAxisAlignment.start,
//                                         children: [
//                                           Text(
//                                             "${allAnscmntANSIDwise[cmntSelectID][i]["school_name"]} | Grade ${allAnscmntANSIDwise[cmntSelectID][i]["grade"]}",
//                                             style: TextStyle(
//                                                 color: Colors.black54,
//                                                 fontSize: 9,
//                                                 fontWeight: FontWeight.w400),
//                                           ),
//                                         ],
//                                       ),
//                                       Row(
//                                         mainAxisAlignment:
//                                             MainAxisAlignment.start,
//                                         children: [
//                                           Text(
//                                             "Commented on " + "$current_date",
//                                             style: TextStyle(
//                                                 color: Colors.black54,
//                                                 fontSize: 9,
//                                                 fontWeight: FontWeight.w400),
//                                           ),
//                                         ],
//                                       ),
//                                       SizedBox(
//                                         height: 8,
//                                       ),
//                                       allAnscmntANSIDwise[cmntSelectID][i]
//                                                   ["comment_type"] ==
//                                               "text"
//                                           ? InkWell(
//                                               onTap: () {},
//                                               child: Container(
//                                                 child: ReadMoreText(
//                                                   allAnscmntANSIDwise[
//                                                           cmntSelectID][i]
//                                                       ["comment"],
//                                                   trimLines: 4,
//                                                   colorClickableText:
//                                                       Color(0xff0962ff),
//                                                   trimMode: TrimMode.Line,
//                                                   trimCollapsedText:
//                                                       'read more',
//                                                   trimExpandedText: 'Show less',
//                                                   style: TextStyle(
//                                                       color: Color(0xFF4D4D4D),
//                                                       fontSize: 13,
//                                                       fontWeight:
//                                                           FontWeight.w500),
//                                                   lessStyle: TextStyle(
//                                                       color: Color(0xFF4D4D4D),
//                                                       fontSize: 13,
//                                                       fontWeight:
//                                                           FontWeight.w500),
//                                                   moreStyle: TextStyle(
//                                                       color: Color(0xFF4D4D4D),
//                                                       fontSize: 13,
//                                                       fontWeight:
//                                                           FontWeight.w500),
//                                                 ),
//                                               ),
//                                             )
//                                           : InkWell(
//                                               child: Container(
//                                                 margin: EdgeInsets.all(5),
//                                                 child: Image.network(
//                                                     allAnscmntANSIDwise[
//                                                             cmntSelectID][i]
//                                                         ["comment"],
//                                                     height: 200,
//                                                     fit: BoxFit.fill),
//                                               ),
//                                             ),
//                                     ],
//                                   ),
//                                 ),
//                                 Padding(
//                                   padding: const EdgeInsets.all(10.0),
//                                   child: Row(
//                                     mainAxisAlignment: MainAxisAlignment.start,
//                                     children: [
//                                       InkWell(
//                                         onTap: () {
//                                           if (answerCommentlikedLocalDB!.get(
//                                                   allAnscmntANSIDwise[
//                                                           cmntSelectID][i]
//                                                       ["comment_id"]) ==
//                                               "like") {
//                                             setState(() {
//                                               likeCountAnscmnt[cmntSelectID]
//                                                       [i] =
//                                                   likeCountAnscmnt[cmntSelectID]
//                                                           [i] -
//                                                       1;
//                                             });
//                                             ////////////////////////////notification//////////////////////////////////////
//                                             String notify_id =
//                                                 "ntf${allAnscmntANSIDwise[cmntSelectID][i]["comment_id"]}$comparedate";
//                                             notifyCRUD.sendNotification([
//                                               notify_id,
//                                               "reaction",
//                                               "comment",
//                                               _currentUserId,
//                                               allAnscmntANSIDwise[cmntSelectID]
//                                                   [i]["user_id"],
//                                               countData!.value["usertoken"][
//                                                   allAnscmntANSIDwise[
//                                                           cmntSelectID][i]
//                                                       ["user_id"]]["tokenid"],
//                                               "You got one like!",
//                                               "${userDataDB!.get("first_name")} ${userDataDB!.get("last_name")} liked your comment.",
//                                               allQuestionsData[qIndex]
//                                                   ["question_id"],
//                                               "question",
//                                               "false",
//                                               comparedate,
//                                               "delete"
//                                             ]);
//                                             //////////////////////////////////////////////////////////////////////////
//                                             answerCommentlikedLocalDB!.delete(
//                                                 allAnscmntANSIDwise[
//                                                         cmntSelectID][i]
//                                                     ["comment_id"]);
//                                             dataLoad
//                                                 .updateAnswerCommentCountData([
//                                               allAnscmntANSIDwise[cmntSelectID]
//                                                   [i]["comment_id"],
//                                               _currentUserId,
//                                               likeCountAnscmnt[cmntSelectID]
//                                                       [i] -
//                                                   1,
//                                               replyCountAnscmnt[cmntSelectID][i]
//                                             ]);
//                                           } else {
//                                             answerCommentlikedLocalDB!.put(
//                                                 allAnscmntANSIDwise[
//                                                         cmntSelectID][i]
//                                                     ["comment_id"],
//                                                 "like");
//                                             setState(() {
//                                               likeCountAnscmnt[cmntSelectID]
//                                                       [i] =
//                                                   likeCountAnscmnt[cmntSelectID]
//                                                           [i] +
//                                                       1;
//                                             });
//                                             ////////////////////////////notification//////////////////////////////////////
//                                             String notify_id =
//                                                 "ntf${allAnscmntANSIDwise[cmntSelectID][i]["comment_id"]}$comparedate";
//                                             notifyCRUD.sendNotification([
//                                               notify_id,
//                                               "reaction",
//                                               "comment",
//                                               _currentUserId,
//                                               allAnscmntANSIDwise[cmntSelectID]
//                                                   [i]["user_id"],
//                                               countData!.value["usertoken"][
//                                                   allAnscmntANSIDwise[
//                                                           cmntSelectID][i]
//                                                       ["user_id"]]["tokenid"],
//                                               "You got one like!",
//                                               "${userDataDB!.get("first_name")} ${userDataDB!.get("last_name")} liked your comment.",
//                                               allQuestionsData[qIndex]
//                                                   ["question_id"],
//                                               "question",
//                                               "false",
//                                               comparedate,
//                                               "add"
//                                             ]);
//                                             //////////////////////////////////////////////////////////////////////////
//                                             dataLoad
//                                                 .updateAnswerCommentCountData([
//                                               allAnscmntANSIDwise[cmntSelectID]
//                                                   [i]["comment_id"],
//                                               _currentUserId,
//                                               likeCountAnscmnt[cmntSelectID]
//                                                       [i] +
//                                                   1,
//                                               replyCountAnscmnt[cmntSelectID][i]
//                                             ]);
//                                           }
//                                         },
//                                         child: Text(
//                                           "Like",
//                                           style: TextStyle(
//                                               color: (answerCommentlikedLocalDB!
//                                                           .get(allAnscmntANSIDwise[
//                                                                   cmntSelectID][i]
//                                                               ["comment_id"]) ==
//                                                       "like")
//                                                   ? Color(0xff0962ff)
//                                                   : Colors.black54,
//                                               fontSize: 12,
//                                               fontWeight: FontWeight.w700),
//                                         ),
//                                       ),
//                                       1 > 0
//                                           ? SizedBox(
//                                               width: 8,
//                                             )
//                                           : SizedBox(),
//                                       1 > 0
//                                           ? Text(
//                                               " " +
//                                                   likeCountAnscmnt[cmntSelectID]
//                                                           [i]
//                                                       .toString() +
//                                                   " ",
//                                               style: TextStyle(
//                                                   color: Colors.black54,
//                                                   fontSize: 12,
//                                                   fontWeight: FontWeight.w400),
//                                             )
//                                           : SizedBox(),
//                                       1 > 0
//                                           ? Icon(Entypo.thumbs_up,
//                                               color:
//                                                   Color.fromRGBO(0, 0, 0, 0.8),
//                                               size: 14)
//                                           : SizedBox(),
//                                       SizedBox(
//                                         width: 8,
//                                       ),
//                                       Text(
//                                         " | ",
//                                         style: TextStyle(
//                                             color: Colors.black54,
//                                             fontSize: 15,
//                                             fontWeight: FontWeight.w700),
//                                       ),
//                                       SizedBox(
//                                         width: 8,
//                                       ),
//                                       InkWell(
//                                         onTap: () {
//                                           _addreplyPostDialog(
//                                               qIndex,
//                                               ansSelectID,
//                                               ansIndex,
//                                               cmntSelectID,
//                                               i);
//                                         },
//                                         child: Text(
//                                           "Reply",
//                                           style: TextStyle(
//                                               color: Colors.black54,
//                                               fontSize: 12,
//                                               fontWeight: FontWeight.w700),
//                                         ),
//                                       ),
//                                       1 > 0
//                                           ? SizedBox(
//                                               width: 8,
//                                             )
//                                           : SizedBox(),
//                                       1 > 0
//                                           ? InkWell(
//                                               onTap: () {
//                                                 _viewreplyPostDialog(
//                                                     qIndex,
//                                                     ansSelectID,
//                                                     ansIndex,
//                                                     cmntSelectID,
//                                                     i);
//                                               },
//                                               child: Text(
//                                                 " " +
//                                                     replyCountAnscmnt[
//                                                             cmntSelectID][i]
//                                                         .toString() +
//                                                     " ",
//                                                 style: TextStyle(
//                                                     color: Colors.black54,
//                                                     fontSize: 12,
//                                                     fontWeight:
//                                                         FontWeight.w400),
//                                               ),
//                                             )
//                                           : SizedBox(),
//                                       1 > 0
//                                           ? Icon(Icons.chat,
//                                               color:
//                                                   Color.fromRGBO(0, 0, 0, 0.8),
//                                               size: 14)
//                                           : SizedBox(),
//                                     ],
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       );
//                     }),
//               ),
//             ],
//           )
//         : SizedBox();
//   }

//   //reply
//   _reply(BuildContext context, int qIndex, int ansSelectID, int ansIndex,
//       int cmntSelectID, int cmntIndex) {
//     int replySelectID = -1;
//     for (int i = 0; i < allAnsreplyCommentID.length; i++) {
//       if (allAnsreplyCommentID[i] ==
//           allAnscmntANSIDwise[cmntSelectID][cmntIndex]["comment_id"]) {
//         replySelectID = i;
//       }
//     }
//     print("check: ${allAnsReplyCMNTIDwisebool}");
//     return replySelectID != -1
//         ? Padding(
//             padding: const EdgeInsets.only(left: 40.0),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 SizedBox(height: 5),
//                 allAnsReplyCMNTIDwise[replySelectID].length > 1
//                     ? Row(
//                         mainAxisAlignment: MainAxisAlignment.start,
//                         children: [
//                           InkWell(
//                             onTap: () {
//                               setState(() {
//                                 allAnsReplyCMNTIDwisebool[cmntSelectID] =
//                                     !allAnsReplyCMNTIDwisebool[cmntSelectID];
//                               });
//                               Navigator.of(context).pop();
//                               _viewreplyPostDialog(qIndex, ansSelectID,
//                                   ansIndex, cmntSelectID, cmntIndex);
//                             },
//                             child: Container(
//                               child: Text(
//                                   allAnsReplyCMNTIDwisebool[cmntSelectID] ==
//                                           true
//                                       ? "Hide replies"
//                                       : "View ${allAnsReplyCMNTIDwise[replySelectID].length - 1} more replies",
//                                   style: TextStyle(
//                                       fontSize: 14,
//                                       color: Colors.black.withOpacity(0.6),
//                                       fontWeight: FontWeight.bold)),
//                             ),
//                           ),
//                         ],
//                       )
//                     : SizedBox(),
//                 SizedBox(height: 5),
//                 Container(
//                   width: 350,
//                   child: ListView.builder(
//                       shrinkWrap: true,
//                       itemCount:
//                           allAnsReplyCMNTIDwisebool[cmntSelectID] == false
//                               ? 1
//                               : allAnsReplyCMNTIDwise[replySelectID].length,
//                       itemBuilder: (context, i) {
//                         DateTime tempDate = DateTime.parse(
//                             allAnsReplyCMNTIDwise[replySelectID][i]
//                                     ["compare_date"]
//                                 .toString()
//                                 .substring(0, 8));
//                         String current_date =
//                             DateFormat.yMMMMd('en_US').format(tempDate);
//                         return Container(
//                           margin: EdgeInsets.only(right: 10),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.start,
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Container(
//                                 height: 35,
//                                 width: 35,
//                                 margin: EdgeInsets.all(10),
//                                 child: CircleAvatar(
//                                   child: ClipOval(
//                                     child: Container(
//                                       child: Image.network(
//                                         allAnsReplyCMNTIDwise[replySelectID][i]
//                                             ["profilepic"],
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                               Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   SizedBox(height: 10),
//                                   Container(
//                                     width: 270,
//                                     padding: EdgeInsets.all(10),
//                                     decoration: BoxDecoration(
//                                         color: Colors.white,
//                                         borderRadius: BorderRadius.all(
//                                             Radius.circular(10))),
//                                     child: Column(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.start,
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       children: [
//                                         Row(
//                                           mainAxisAlignment:
//                                               MainAxisAlignment.spaceBetween,
//                                           crossAxisAlignment:
//                                               CrossAxisAlignment.center,
//                                           children: [
//                                             Text(
//                                               allAnsReplyCMNTIDwise[
//                                                           replySelectID][i]
//                                                       ["first_name"] +
//                                                   " " +
//                                                   allAnsReplyCMNTIDwise[
//                                                           replySelectID][i]
//                                                       ["last_name"],
//                                               style: TextStyle(
//                                                   color: Color(0xFF4D4D4D),
//                                                   fontSize: 13.5,
//                                                   fontWeight: FontWeight.w700),
//                                             ),
//                                             InkWell(
//                                               onTap: () {},
//                                               child: Container(
//                                                 child: Icon(
//                                                   Icons.more_horiz_outlined,
//                                                   size: 17,
//                                                   color: Colors.black54,
//                                                 ),
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                         Row(
//                                           mainAxisAlignment:
//                                               MainAxisAlignment.start,
//                                           children: [
//                                             Text(
//                                               "${allAnsReplyCMNTIDwise[replySelectID][i]["school_name"]} | Grade ${allAnsReplyCMNTIDwise[replySelectID][i]["grade"]}",
//                                               style: TextStyle(
//                                                   color: Colors.black54,
//                                                   fontSize: 9,
//                                                   fontWeight: FontWeight.w400),
//                                             ),
//                                           ],
//                                         ),
//                                         Row(
//                                           mainAxisAlignment:
//                                               MainAxisAlignment.start,
//                                           children: [
//                                             Text(
//                                               "Commented on " + "$current_date",
//                                               style: TextStyle(
//                                                   color: Colors.black54,
//                                                   fontSize: 9,
//                                                   fontWeight: FontWeight.w400),
//                                             ),
//                                           ],
//                                         ),
//                                         SizedBox(
//                                           height: 8,
//                                         ),
//                                         allAnsReplyCMNTIDwise[replySelectID][i]
//                                                     ["reply_type"] ==
//                                                 "text"
//                                             ? InkWell(
//                                                 onTap: () {},
//                                                 child: Container(
//                                                   child: ReadMoreText(
//                                                     allAnsReplyCMNTIDwise[
//                                                             replySelectID][i]
//                                                         ["reply"],
//                                                     trimLines: 4,
//                                                     colorClickableText:
//                                                         Color(0xff0962ff),
//                                                     trimMode: TrimMode.Line,
//                                                     trimCollapsedText:
//                                                         'read more',
//                                                     trimExpandedText:
//                                                         'Show less',
//                                                     style: TextStyle(
//                                                         color:
//                                                             Color(0xFF4D4D4D),
//                                                         fontSize: 13,
//                                                         fontWeight:
//                                                             FontWeight.w500),
//                                                     lessStyle: TextStyle(
//                                                         color:
//                                                             Color(0xFF4D4D4D),
//                                                         fontSize: 13,
//                                                         fontWeight:
//                                                             FontWeight.w500),
//                                                     moreStyle: TextStyle(
//                                                         color:
//                                                             Color(0xFF4D4D4D),
//                                                         fontSize: 13,
//                                                         fontWeight:
//                                                             FontWeight.w500),
//                                                   ),
//                                                 ),
//                                               )
//                                             : InkWell(
//                                                 child: Container(
//                                                   margin: EdgeInsets.all(5),
//                                                   child: Image.network(
//                                                       allAnsReplyCMNTIDwise[
//                                                               replySelectID][i]
//                                                           ["reply"],
//                                                       height: 200,
//                                                       fit: BoxFit.fill),
//                                                 ),
//                                               ),
//                                       ],
//                                     ),
//                                   ),
//                                   Padding(
//                                     padding: const EdgeInsets.all(10.0),
//                                     child: Row(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.start,
//                                       children: [
//                                         InkWell(
//                                           onTap: () {
//                                             if (answerReplylikedLocalDB!.get(
//                                                     allAnsReplyCMNTIDwise[
//                                                             replySelectID][i]
//                                                         ["reply_id"]) ==
//                                                 "like") {
//                                               setState(() {
//                                                 likeCountAnsReply[replySelectID]
//                                                     [i] = likeCountAnsReply[
//                                                         replySelectID][i] -
//                                                     1;
//                                               });
//                                               ////////////////////////////notification//////////////////////////////////////
//                                               String notify_id =
//                                                   "ntf${allAnsReplyCMNTIDwise[replySelectID][i]["reply_id"]}$comparedate";
//                                               notifyCRUD.sendNotification([
//                                                 notify_id,
//                                                 "reaction",
//                                                 "reply",
//                                                 _currentUserId,
//                                                 allAnsReplyCMNTIDwise[
//                                                         replySelectID][i]
//                                                     ["user_id"],
//                                                 countData!.value["usertoken"][
//                                                     allAnsReplyCMNTIDwise[
//                                                             replySelectID][i]
//                                                         ["user_id"]]["tokenid"],
//                                                 "You got one like!",
//                                                 "${userDataDB!.get("first_name")} ${userDataDB!.get("last_name")} liked your reply.",
//                                                 allQuestionsData[qIndex]
//                                                     ["question_id"],
//                                                 "question",
//                                                 "false",
//                                                 comparedate,
//                                                 "delete"
//                                               ]);
//                                               //////////////////////////////////////////////////////////////////////////
//                                               dataLoad
//                                                   .updateAnswerReplyCountData([
//                                                 allAnsReplyCMNTIDwise[
//                                                         replySelectID][i]
//                                                     ["reply_id"],
//                                                 _currentUserId,
//                                                 likeCountAnsReply[replySelectID]
//                                                         [i] -
//                                                     1
//                                               ]);
//                                               answerReplylikedLocalDB!.delete(
//                                                   allAnsReplyCMNTIDwise[
//                                                           replySelectID][i]
//                                                       ["reply_id"]);
//                                             } else {
//                                               setState(() {
//                                                 likeCountAnsReply[replySelectID]
//                                                     [i] = likeCountAnsReply[
//                                                         replySelectID][i] +
//                                                     1;
//                                               });
//                                               ////////////////////////////notification//////////////////////////////////////
//                                               String notify_id =
//                                                   "ntf${allAnsReplyCMNTIDwise[replySelectID][i]["reply_id"]}$comparedate";
//                                               notifyCRUD.sendNotification([
//                                                 notify_id,
//                                                 "reaction",
//                                                 "reply",
//                                                 _currentUserId,
//                                                 allAnsReplyCMNTIDwise[
//                                                         replySelectID][i]
//                                                     ["user_id"],
//                                                 countData!.value["usertoken"][
//                                                     allAnsReplyCMNTIDwise[
//                                                             replySelectID][i]
//                                                         ["user_id"]]["tokenid"],
//                                                 "You got one like!",
//                                                 "${userDataDB!.get("first_name")} ${userDataDB!.get("last_name")} liked your reply.",
//                                                 allQuestionsData[qIndex]
//                                                     ["question_id"],
//                                                 "question",
//                                                 "false",
//                                                 comparedate,
//                                                 "add"
//                                               ]);
//                                               //////////////////////////////////////////////////////////////////////////
//                                               dataLoad
//                                                   .updateAnswerReplyCountData([
//                                                 allAnsReplyCMNTIDwise[
//                                                         replySelectID][i]
//                                                     ["reply_id"],
//                                                 _currentUserId,
//                                                 likeCountAnsReply[replySelectID]
//                                                         [i] +
//                                                     1
//                                               ]);
//                                               answerReplylikedLocalDB!.put(
//                                                   allAnsReplyCMNTIDwise[
//                                                           replySelectID][i]
//                                                       ["reply_id"],
//                                                   "like");
//                                             }
//                                           },
//                                           child: Text(
//                                             "Like",
//                                             style: TextStyle(
//                                                 color: (answerReplylikedLocalDB!.get(
//                                                             allAnsReplyCMNTIDwise[
//                                                                     replySelectID]
//                                                                 [
//                                                                 i]["reply_id"]) ==
//                                                         "like")
//                                                     ? Color(0xff0962ff)
//                                                     : Colors.black54,
//                                                 fontSize: 12,
//                                                 fontWeight: FontWeight.w700),
//                                           ),
//                                         ),
//                                         1 > 0
//                                             ? SizedBox(
//                                                 width: 8,
//                                               )
//                                             : SizedBox(),
//                                         1 > 0
//                                             ? Text(
//                                                 " " +
//                                                     likeCountAnsReply[
//                                                             replySelectID][i]
//                                                         .toString() +
//                                                     " ",
//                                                 style: TextStyle(
//                                                     color: Colors.black54,
//                                                     fontSize: 12,
//                                                     fontWeight:
//                                                         FontWeight.w400),
//                                               )
//                                             : SizedBox(),
//                                         1 > 0
//                                             ? Icon(Entypo.thumbs_up,
//                                                 color: Color.fromRGBO(
//                                                     0, 0, 0, 0.8),
//                                                 size: 14)
//                                             : SizedBox(),
//                                       ],
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ],
//                           ),
//                         );
//                       }),
//                 ),
//               ],
//             ),
//           )
//         : SizedBox();
//   }

//   void _viewreplyPostDialog(int qIndex, int ansSelectID, int ansIndex,
//       int cmntSelectID, int cmntIndex) {
//     showDialog(
//         context: context,
//         barrierColor: Colors.grey.withOpacity(0.2),
//         barrierDismissible: false,
//         builder: (_) => StatefulBuilder(builder: (context, setState) {
//               return AlertDialog(
//                 backgroundColor: Color.fromRGBO(242, 246, 248, 1),
//                 contentPadding: EdgeInsets.all(20),
//                 shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10.0)),
//                 title: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.end,
//                       children: [
//                         IconButton(
//                           onPressed: () {
//                             Navigator.pop(context);
//                           },
//                           icon: Tab(
//                               child: Icon(Icons.cancel_rounded,
//                                   color: Colors.black45, size: 25)),
//                         )
//                       ],
//                     ),
//                     SizedBox(height: 20),
//                     Container(height: 1, width: 500, color: Colors.grey[200]),
//                   ],
//                 ),
//                 content: Container(
//                   height: 500,
//                   width: 600,
//                   child: SingleChildScrollView(
//                     child: Column(
//                       children: [
//                         SizedBox(height: 10),
//                         Container(
//                           margin: EdgeInsets.only(right: 10),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.start,
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Container(
//                                 height: 35,
//                                 width: 35,
//                                 margin: EdgeInsets.all(10),
//                                 child: CircleAvatar(
//                                   child: ClipOval(
//                                     child: Container(
//                                       child: Image.network(
//                                         allAnscmntANSIDwise[cmntSelectID]
//                                             [cmntIndex]["profilepic"],
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                               Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   SizedBox(height: 10),
//                                   Container(
//                                     width: 270,
//                                     padding: EdgeInsets.all(10),
//                                     decoration: BoxDecoration(
//                                         color: Colors.white,
//                                         borderRadius: BorderRadius.all(
//                                             Radius.circular(10))),
//                                     child: Column(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.start,
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       children: [
//                                         Row(
//                                           mainAxisAlignment:
//                                               MainAxisAlignment.spaceBetween,
//                                           crossAxisAlignment:
//                                               CrossAxisAlignment.center,
//                                           children: [
//                                             Text(
//                                               allAnscmntANSIDwise[cmntSelectID]
//                                                           [cmntIndex]
//                                                       ["first_name"] +
//                                                   " " +
//                                                   allAnscmntANSIDwise[
//                                                           cmntSelectID]
//                                                       [cmntIndex]["last_name"],
//                                               style: TextStyle(
//                                                   color: Color(0xFF4D4D4D),
//                                                   fontSize: 13.5,
//                                                   fontWeight: FontWeight.w700),
//                                             ),
//                                             InkWell(
//                                               onTap: () {},
//                                               child: Container(
//                                                 child: Icon(
//                                                   Icons.more_horiz_outlined,
//                                                   size: 17,
//                                                   color: Colors.black54,
//                                                 ),
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                         Row(
//                                           mainAxisAlignment:
//                                               MainAxisAlignment.start,
//                                           children: [
//                                             Text(
//                                               "${allAnscmntANSIDwise[cmntSelectID][cmntIndex]["school_name"]} | Grade ${allAnscmntANSIDwise[cmntSelectID][cmntIndex]["grade"]}",
//                                               style: TextStyle(
//                                                   color: Colors.black54,
//                                                   fontSize: 9,
//                                                   fontWeight: FontWeight.w400),
//                                             ),
//                                           ],
//                                         ),
//                                         Row(
//                                           mainAxisAlignment:
//                                               MainAxisAlignment.start,
//                                           children: [
//                                             Text(
//                                               "Commented on " + "$current_date",
//                                               style: TextStyle(
//                                                   color: Colors.black54,
//                                                   fontSize: 9,
//                                                   fontWeight: FontWeight.w400),
//                                             ),
//                                           ],
//                                         ),
//                                         SizedBox(
//                                           height: 8,
//                                         ),
//                                         allAnscmntANSIDwise[cmntSelectID]
//                                                         [cmntIndex]
//                                                     ["comment_type"] ==
//                                                 "text"
//                                             ? InkWell(
//                                                 onTap: () {},
//                                                 child: Container(
//                                                   child: ReadMoreText(
//                                                     allAnscmntANSIDwise[
//                                                             cmntSelectID]
//                                                         [cmntIndex]["comment"],
//                                                     trimLines: 4,
//                                                     colorClickableText:
//                                                         Color(0xff0962ff),
//                                                     trimMode: TrimMode.Line,
//                                                     trimCollapsedText:
//                                                         'read more',
//                                                     trimExpandedText:
//                                                         'Show less',
//                                                     style: TextStyle(
//                                                         color:
//                                                             Color(0xFF4D4D4D),
//                                                         fontSize: 13,
//                                                         fontWeight:
//                                                             FontWeight.w500),
//                                                     lessStyle: TextStyle(
//                                                         color:
//                                                             Color(0xFF4D4D4D),
//                                                         fontSize: 13,
//                                                         fontWeight:
//                                                             FontWeight.w500),
//                                                     moreStyle: TextStyle(
//                                                         color:
//                                                             Color(0xFF4D4D4D),
//                                                         fontSize: 13,
//                                                         fontWeight:
//                                                             FontWeight.w500),
//                                                   ),
//                                                 ),
//                                               )
//                                             : InkWell(
//                                                 child: Container(
//                                                   margin: EdgeInsets.all(5),
//                                                   child: Image.network(
//                                                       allAnscmntANSIDwise[
//                                                                   cmntSelectID]
//                                                               [cmntIndex]
//                                                           ["comment"],
//                                                       height: 200,
//                                                       fit: BoxFit.fill),
//                                                 ),
//                                               ),
//                                       ],
//                                     ),
//                                   ),
//                                   Padding(
//                                     padding: const EdgeInsets.all(10.0),
//                                     child: Row(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.start,
//                                       children: [
//                                         InkWell(
//                                           onTap: () {
//                                             if (answerCommentlikedLocalDB!.get(
//                                                     allAnscmntANSIDwise[
//                                                                 cmntSelectID]
//                                                             [cmntIndex]
//                                                         ["comment_id"]) ==
//                                                 "like") {
//                                               setState(() {
//                                                 likeCountAnscmnt[cmntSelectID]
//                                                         [cmntIndex] =
//                                                     likeCountAnscmnt[
//                                                                 cmntSelectID]
//                                                             [cmntIndex] -
//                                                         1;
//                                               });
//                                               answerCommentlikedLocalDB!.delete(
//                                                   allAnscmntANSIDwise[
//                                                               cmntSelectID]
//                                                           [cmntIndex]
//                                                       ["comment_id"]);
//                                               dataLoad
//                                                   .updateAnswerCommentCountData([
//                                                 allAnscmntANSIDwise[
//                                                         cmntSelectID][cmntIndex]
//                                                     ["comment_id"],
//                                                 _currentUserId,
//                                                 likeCountAnscmnt[cmntSelectID]
//                                                         [cmntIndex] -
//                                                     1,
//                                                 replyCountAnscmnt[cmntSelectID]
//                                                     [cmntIndex]
//                                               ]);
//                                             } else {
//                                               answerCommentlikedLocalDB!.put(
//                                                   allAnscmntANSIDwise[
//                                                           cmntSelectID]
//                                                       [cmntIndex]["comment_id"],
//                                                   "like");
//                                               setState(() {
//                                                 likeCountAnscmnt[cmntSelectID]
//                                                         [cmntIndex] =
//                                                     likeCountAnscmnt[
//                                                                 cmntSelectID]
//                                                             [cmntIndex] +
//                                                         1;
//                                               });
//                                               dataLoad
//                                                   .updateAnswerCommentCountData([
//                                                 allAnscmntANSIDwise[
//                                                         cmntSelectID][cmntIndex]
//                                                     ["comment_id"],
//                                                 _currentUserId,
//                                                 likeCountAnscmnt[cmntSelectID]
//                                                         [cmntIndex] +
//                                                     1,
//                                                 replyCountAnscmnt[cmntSelectID]
//                                                     [cmntIndex]
//                                               ]);
//                                             }
//                                           },
//                                           child: Text(
//                                             "Like",
//                                             style: TextStyle(
//                                                 color: (answerCommentlikedLocalDB!.get(
//                                                             allAnscmntANSIDwise[
//                                                                         cmntSelectID]
//                                                                     [cmntIndex][
//                                                                 "comment_id"]) ==
//                                                         "like")
//                                                     ? Color(0xff0962ff)
//                                                     : Colors.black54,
//                                                 fontSize: 12,
//                                                 fontWeight: FontWeight.w700),
//                                           ),
//                                         ),
//                                         1 > 0
//                                             ? SizedBox(
//                                                 width: 8,
//                                               )
//                                             : SizedBox(),
//                                         1 > 0
//                                             ? Text(
//                                                 " " +
//                                                     likeCountAnscmnt[
//                                                                 cmntSelectID]
//                                                             [cmntIndex]
//                                                         .toString() +
//                                                     " ",
//                                                 style: TextStyle(
//                                                     color: Colors.black54,
//                                                     fontSize: 12,
//                                                     fontWeight:
//                                                         FontWeight.w400),
//                                               )
//                                             : SizedBox(),
//                                         1 > 0
//                                             ? Icon(Entypo.thumbs_up,
//                                                 color: Color.fromRGBO(
//                                                     0, 0, 0, 0.8),
//                                                 size: 14)
//                                             : SizedBox(),
//                                         SizedBox(
//                                           width: 8,
//                                         ),
//                                         Text(
//                                           " | ",
//                                           style: TextStyle(
//                                               color: Colors.black54,
//                                               fontSize: 15,
//                                               fontWeight: FontWeight.w700),
//                                         ),
//                                         SizedBox(
//                                           width: 8,
//                                         ),
//                                         InkWell(
//                                           onTap: () {
//                                             Navigator.of(context).pop();
//                                             _addreplyPostDialog(
//                                                 qIndex,
//                                                 ansSelectID,
//                                                 ansIndex,
//                                                 cmntSelectID,
//                                                 cmntIndex);
//                                           },
//                                           child: Text(
//                                             "Reply",
//                                             style: TextStyle(
//                                                 color: Colors.black54,
//                                                 fontSize: 12,
//                                                 fontWeight: FontWeight.w700),
//                                           ),
//                                         ),
//                                         1 > 0
//                                             ? SizedBox(
//                                                 width: 8,
//                                               )
//                                             : SizedBox(),
//                                         1 > 0
//                                             ? Text(
//                                                 " " +
//                                                     replyCountAnscmnt[
//                                                                 cmntSelectID]
//                                                             [cmntIndex]
//                                                         .toString() +
//                                                     " ",
//                                                 style: TextStyle(
//                                                     color: Colors.black54,
//                                                     fontSize: 12,
//                                                     fontWeight:
//                                                         FontWeight.w400),
//                                               )
//                                             : SizedBox(),
//                                         1 > 0
//                                             ? Icon(Icons.chat,
//                                                 color: Color.fromRGBO(
//                                                     0, 0, 0, 0.8),
//                                                 size: 14)
//                                             : SizedBox(),
//                                       ],
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ],
//                           ),
//                         ),
//                         SizedBox(height: 20),
//                         _reply(context, qIndex, ansSelectID, ansIndex,
//                             cmntSelectID, cmntIndex),
//                       ],
//                     ),
//                   ),
//                 ),
//               );
//             }));
//   }

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

  //this widget show the attached documents with post
  void _showDialog(Questions questionsModel) {
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
                        if (questionsModel.question_type == "shared") {
                          if (questionsModel
                                  .shared_question_details[0].note_reference !=
                              "") {
                            _launchInBrowser(questionsModel
                                .shared_question_details[0].note_reference);
                          }
                        } else {
                          if (questionsModel.note_reference != "") {
                            _launchInBrowser(questionsModel.note_reference);
                          } else {
                            ElegantNotification.info(
                              title: Text("Hey,"),
                              description: Text("No attachment found."),
                            );
                          }
                        }
                      },
                      icon: Tab(
                          child: Icon(Icons.picture_as_pdf,
                              color: (questionsModel.note_reference != "")
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
                        color: (questionsModel.note_reference != "")
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
                        if (questionsModel.question_type == "shared") {
                          if (questionsModel
                                  .shared_question_details[0].video_reference !=
                              "") {
                            _launchInBrowser(questionsModel
                                .shared_question_details[0].video_reference);
                          }
                        } else {
                          if (questionsModel.video_reference != "") {
                            _launchInBrowser(questionsModel.video_reference);
                          } else {
                            ElegantNotification.info(
                              title: Text("Hey,"),
                              description: Text("No attachment found."),
                            );
                          }
                        }
                      },
                      icon: Tab(
                          child: Icon(Icons.video_label,
                              color: (questionsModel.video_reference != "")
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
                        color: (questionsModel.video_reference != "")
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
                        if (questionsModel.question_type == "shared") {
                          if (questionsModel
                                  .shared_question_details[0].audio_reference !=
                              "") {
                            _launchInBrowser(questionsModel
                                .shared_question_details[0].audio_reference);
                          }
                        } else {
                          if (questionsModel.audio_reference != "") {
                            _launchInBrowser(questionsModel.audio_reference);
                          } else {
                            ElegantNotification.info(
                              title: Text("Hey,"),
                              description: Text("No attachment found."),
                            );
                          }
                        }
                      },
                      icon: Tab(
                          child: Icon(Icons.audiotrack,
                              color: (questionsModel.audio_reference != "")
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
                        color: (questionsModel.audio_reference != "")
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
                        if (questionsModel.question_type == "shared") {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              content: ListTile(
                                title: Text("Reference"),
                                subtitle: Text(
                                    "${questionsModel.shared_question_details[0].text_reference}"),
                              ),
                              actions: <Widget>[
                                FlatButton(
                                  child: Text('Ok'),
                                  onPressed: () => Navigator.of(context).pop(),
                                ),
                              ],
                            ),
                          );
                        } else {
                          if (questionsModel.text_reference != "") {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                content: ListTile(
                                  title: Text("Reference"),
                                  subtitle:
                                      Text("${questionsModel.text_reference}"),
                                ),
                                actions: <Widget>[
                                  FlatButton(
                                    child: Text('Ok'),
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                  ),
                                ],
                              ),
                            );
                          } else {
                            ElegantNotification.info(
                              title: Text("Hey,"),
                              description: Text("No attachment found."),
                            );
                          }
                        }
                      },
                      icon: Tab(
                          child: Icon(Icons.text_fields,
                              color: (questionsModel.text_reference != "")
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
                              subtitle:
                                  Text("${questionsModel.text_reference}"),
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
                          color: (questionsModel.text_reference != "")
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

  _showQuestionLikedDialog(Questions questionsModel, int index) {
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
                        color: questionsModel.like_type == "like"
                            ? Color(0xff0962ff)
                            : Color(0xff0C2551)),
                    onPressed: () async {
                      if (questionsModel.like_type == "markasimp") {
                        _add_questions_like_details(questionsModel.user_id,
                            questionsModel.question_id, "like");
                        updateLikeType("like", questionsModel);
                        ////////////////////////////notification//////////////////////////////////////
                        notifyCRUD.createNotification(
                            questionsModel.question_id,
                            "question",
                            "no",
                            "false",
                            questionsModel.user_id,
                            countData!.value["usertoken"]
                                [questionsModel.user_id]["tokenid"],
                            "${userDataDB!.get('first_name')} ${userDataDB!.get('last_name')} like your question.",
                            "You got a like",
                            "question",
                            "reaction",
                            "+");
                        /////////////////////////////////////////////////////////////////////////////
                      } else if (questionsModel.like_type == "mydoubttoo") {
                        _add_questions_like_details(questionsModel.user_id,
                            questionsModel.question_id, "like");
                        updateLikeType("like", questionsModel);
                        ////////////////////////////notification//////////////////////////////////////
                        notifyCRUD.createNotification(
                            questionsModel.question_id,
                            "question",
                            "no",
                            "false",
                            questionsModel.user_id,
                            countData!.value["usertoken"]
                                [questionsModel.user_id]["tokenid"],
                            "${userDataDB!.get('first_name')} ${userDataDB!.get('last_name')} like your question.",
                            "You got a like",
                            "question",
                            "reaction",
                            "+");
                        /////////////////////////////////////////////////////////////////////////////
                      } else if (questionsModel.like_type == "like") {
                        _delete_questions_like_details(
                            questionsModel.user_id, questionsModel.question_id);
                        updateCount(
                            questionsModel.question_id,
                            questionsModel.question_id,
                            'like',
                            "-",
                            questionsModel);
                        updateLikeType("", questionsModel);
                        ////////////////////////////notification//////////////////////////////////////
                        notifyCRUD.createNotification(
                            questionsModel.question_id,
                            "question",
                            "no",
                            "false",
                            questionsModel.user_id,
                            countData!.value["usertoken"]
                                [questionsModel.user_id]["tokenid"],
                            "${userDataDB!.get('first_name')} ${userDataDB!.get('last_name')} like your question.",
                            "You got a like",
                            "question",
                            "reaction",
                            "-");
                        /////////////////////////////////////////////////////////////////////////////
                      } else {
                        updateCount(
                            questionsModel.user_id,
                            questionsModel.question_id,
                            'like',
                            "+",
                            questionsModel);
                        _add_questions_like_details(questionsModel.user_id,
                            questionsModel.question_id, "like");
                        updateLikeType("like", questionsModel);
                        ////////////////////////////notification//////////////////////////////////////
                        notifyCRUD.createNotification(
                            questionsModel.question_id,
                            "question",
                            "yes",
                            "false",
                            questionsModel.user_id,
                            countData!.value["usertoken"]
                                [questionsModel.user_id]["tokenid"],
                            "${userDataDB!.get('first_name')} ${userDataDB!.get('last_name')} like your question.",
                            "You got a like",
                            "question",
                            "reaction",
                            "+");
                        /////////////////////////////////////////////////////////////////////////////
                      }
                      hideLikePopup(index);
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
                        color: questionsModel.like_type == "markasimp"
                            ? Color(0xff0962ff)
                            : Color(0xff0C2551)),
                    onPressed: () async {
                      if (questionsModel.like_type == "like") {
                        _add_questions_like_details(questionsModel.question_id,
                            questionsModel.question_id, "markasimp");
                        updateLikeType("markasimp", questionsModel);
                        ////////////////////////////notification//////////////////////////////////////
                        notifyCRUD.createNotification(
                            questionsModel.question_id,
                            "question",
                            "no",
                            "false",
                            questionsModel.user_id,
                            countData!.value["usertoken"]
                                [questionsModel.user_id]["tokenid"],
                            "${userDataDB!.get('first_name')} ${userDataDB!.get('last_name')} marked your question as important.",
                            "You got a like",
                            "question",
                            "reaction",
                            "+");
                        /////////////////////////////////////////////////////////////////////////////
                      } else if ((questionsModel.like_type == "mydoubttoo")) {
                        _add_questions_like_details(questionsModel.user_id,
                            questionsModel.question_id, "markasimp");
                        updateLikeType("markasimp", questionsModel);
                        ////////////////////////////notification//////////////////////////////////////
                        notifyCRUD.createNotification(
                            questionsModel.question_id,
                            "question",
                            "no",
                            "false",
                            questionsModel.user_id,
                            countData!.value["usertoken"]
                                [questionsModel.user_id]["tokenid"],
                            "${userDataDB!.get('first_name')} ${userDataDB!.get('last_name')} marked your question as important.",
                            "You got a like",
                            "question",
                            "reaction",
                            "+");
                        /////////////////////////////////////////////////////////////////////////////
                      } else if ((questionsModel.like_type == "markasimp")) {
                        updateCount(
                            questionsModel.question_id,
                            questionsModel.question_id,
                            'like',
                            "-",
                            questionsModel);
                        updateLikeType("", questionsModel);
                        _delete_questions_like_details(
                            questionsModel.user_id, questionsModel.question_id);
                        ////////////////////////////notification//////////////////////////////////////
                        notifyCRUD.createNotification(
                            questionsModel.question_id,
                            "question",
                            "no",
                            "false",
                            questionsModel.user_id,
                            countData!.value["usertoken"]
                                [questionsModel.user_id]["tokenid"],
                            "${userDataDB!.get('first_name')} ${userDataDB!.get('last_name')} marked your question as important.",
                            "You got a like",
                            "question",
                            "reaction",
                            "-");
                        /////////////////////////////////////////////////////////////////////////////
                      } else {
                        updateCount(
                            questionsModel.question_id,
                            questionsModel.question_id,
                            'like',
                            "+",
                            questionsModel);
                        updateLikeType("markasimp", questionsModel);
                        _add_questions_like_details(questionsModel.user_id,
                            questionsModel.question_id, "markasimp");
                        ////////////////////////////notification//////////////////////////////////////
                        notifyCRUD.createNotification(
                            questionsModel.question_id,
                            "question",
                            "yes",
                            "false",
                            questionsModel.user_id,
                            countData!.value["usertoken"]
                                [questionsModel.user_id]["tokenid"],
                            "${userDataDB!.get('first_name')} ${userDataDB!.get('last_name')} marked your question as important.",
                            "You got a like",
                            "question",
                            "reaction",
                            "+");
                        /////////////////////////////////////////////////////////////////////////////
                      }
                      hideLikePopup(index);
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
                          color: questionsModel.like_type == "mydoubttoo"
                              ? Color(0xff0962ff)
                              : Color(0xff0C2551)),
                      onPressed: () async {
                        if (questionsModel.like_type == "markasimp") {
                          _add_questions_like_details(questionsModel.user_id,
                              questionsModel.question_id, "mydoubttoo");
                          updateLikeType("mydoubttoo", questionsModel);
                          ////////////////////////////notification//////////////////////////////////////
                          String genderVar = userDataDB!.get('gender') == "MALE"
                              ? "his"
                              : "her";
                          notifyCRUD.createNotification(
                              questionsModel.question_id,
                              "question",
                              "no",
                              "false",
                              questionsModel.user_id,
                              countData!.value["usertoken"]
                                  [questionsModel.user_id]["tokenid"],
                              "${userDataDB!.get('first_name')} ${userDataDB!.get('last_name')} marked your question as $genderVar doubt too.",
                              "You got a like",
                              "question",
                              "reaction",
                              "+");
                          /////////////////////////////////////////////////////////////////////////////
                        } else if ((questionsModel.like_type == "like")) {
                          _add_questions_like_details(questionsModel.user_id,
                              questionsModel.question_id, "mydoubttoo");
                          updateLikeType("mydoubttoo", questionsModel);
                          ////////////////////////////notification//////////////////////////////////////
                          String genderVar = userDataDB!.get('gender') == "MALE"
                              ? "his"
                              : "her";
                          notifyCRUD.createNotification(
                              questionsModel.question_id,
                              "question",
                              "no",
                              "false",
                              questionsModel.user_id,
                              countData!.value["usertoken"]
                                  [questionsModel.user_id]["tokenid"],
                              "${userDataDB!.get('first_name')} ${userDataDB!.get('last_name')} marked your question as $genderVar doubt too.",
                              "You got a like",
                              "question",
                              "reaction",
                              "+");
                          /////////////////////////////////////////////////////////////////////////////
                        } else if ((questionsModel.like_type == "mydoubttoo")) {
                          updateCount(
                              questionsModel.user_id,
                              questionsModel.question_id,
                              'like',
                              "-",
                              questionsModel);
                          updateLikeType("", questionsModel);
                          _delete_questions_like_details(questionsModel.user_id,
                              questionsModel.question_id);
                          ////////////////////////////notification//////////////////////////////////////
                          String genderVar = userDataDB!.get('gender') == "MALE"
                              ? "his"
                              : "her";
                          notifyCRUD.createNotification(
                              questionsModel.question_id,
                              "question",
                              "no",
                              "false",
                              questionsModel.user_id,
                              countData!.value["usertoken"]
                                  [questionsModel.user_id]["tokenid"],
                              "${userDataDB!.get('first_name')} ${userDataDB!.get('last_name')} marked your question as $genderVar doubt too.",
                              "You got a like",
                              "question",
                              "reaction",
                              "-");
                          /////////////////////////////////////////////////////////////////////////////
                        } else {
                          updateCount(
                              questionsModel.user_id,
                              questionsModel.question_id,
                              'like',
                              "+",
                              questionsModel);
                          updateLikeType("mydoubttoo", questionsModel);
                          _add_questions_like_details(questionsModel.user_id,
                              questionsModel.question_id, "mydoubttoo");
                          ////////////////////////////notification//////////////////////////////////////
                          String genderVar = userDataDB!.get('gender') == "MALE"
                              ? "his"
                              : "her";
                          notifyCRUD.createNotification(
                              questionsModel.question_id,
                              "question",
                              "yes",
                              "false",
                              questionsModel.user_id,
                              countData!.value["usertoken"]
                                  [questionsModel.user_id]["tokenid"],
                              "${userDataDB!.get('first_name')} ${userDataDB!.get('last_name')} marked your question as $genderVar doubt too.",
                              "You got a like",
                              "question",
                              "reaction",
                              "+");
                          /////////////////////////////////////////////////////////////////////////////
                        }
                        hideLikePopup(index);
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
      Uri.parse(Constant.BASE_URL + 'add_questions_like_details'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        "Access-Control_Allow_Origin": "*"
      },
      body: jsonEncode(<String, dynamic>{
        "user_id": _currentUserId,
        "question_id": question_id,
        "like_type": like_type
      }),
    );
    print(response.statusCode);
  }

  Future<void> _delete_questions_like_details(
      String user_id, String question_id) async {
    final http.Response response = await http.delete(
      Uri.parse(Constant.BASE_URL + 'delete_questions_like_details'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        "Access-Control_Allow_Origin": "*"
      },
      body: jsonEncode(<String, dynamic>{
        "user_id": _currentUserId,
        "question_id": question_id
      }),
    );
    print(response.statusCode);
  }

  void _showExamlikelihoodAndToughnessDialog(
      Questions questionsModel, int index) {
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
                                if ((questionsModel.examlikelyhood_type ==
                                    "low")) {
                                  _add_questions_examlikelyhood_details(
                                      questionsModel.user_id,
                                      questionsModel.question_id,
                                      "high");
                                  updateExamLikelyType("high", questionsModel);

                                  ////////////////////////////notification//////////////////////////////////////
                                  notifyCRUD.createNotification(
                                      questionsModel.question_id,
                                      "question",
                                      "no",
                                      "false",
                                      questionsModel.user_id,
                                      countData!.value["usertoken"]
                                          [questionsModel.user_id]["tokenid"],
                                      "${userDataDB!.get('first_name')} ${userDataDB!.get('last_name')} marked your question as highly examlikelihood.",
                                      "You got a examlikelihood",
                                      "question",
                                      "reaction",
                                      "+");
                                  /////////////////////////////////////////////////////////////////////////////
                                } else if ((questionsModel
                                        .examlikelyhood_type ==
                                    "moderate")) {
                                  _add_questions_examlikelyhood_details(
                                      questionsModel.user_id,
                                      questionsModel.question_id,
                                      "high");
                                  updateExamLikelyType("high", questionsModel);
                                  ////////////////////////////notification//////////////////////////////////////
                                  notifyCRUD.createNotification(
                                      questionsModel.question_id,
                                      "question",
                                      "no",
                                      "false",
                                      questionsModel.user_id,
                                      countData!.value["usertoken"]
                                          [questionsModel.user_id]["tokenid"],
                                      "${userDataDB!.get('first_name')} ${userDataDB!.get('last_name')} marked your question as highly examlikelihood.",
                                      "You got a examlikelihood",
                                      "question",
                                      "reaction",
                                      "+");
                                  /////////////////////////////////////////////////////////////////////////////
                                } else if ((questionsModel
                                        .examlikelyhood_type ==
                                    "high")) {
                                  updateCount(
                                      questionsModel.user_id,
                                      questionsModel.question_id,
                                      'examlikelyhood',
                                      "-",
                                      questionsModel);
                                  _delete_questions_examlikelyhood_details(
                                      questionsModel.user_id,
                                      questionsModel.question_id);
                                  updateExamLikelyType("", questionsModel);
                                  ////////////////////////////notification//////////////////////////////////////
                                  notifyCRUD.createNotification(
                                      questionsModel.question_id,
                                      "question",
                                      "no",
                                      "false",
                                      questionsModel.user_id,
                                      countData!.value["usertoken"]
                                          [questionsModel.user_id]["tokenid"],
                                      "${userDataDB!.get('first_name')} ${userDataDB!.get('last_name')} marked your question as highly examlikelihood.",
                                      "You got a examlikelihood",
                                      "question",
                                      "reaction",
                                      "-");
                                  /////////////////////////////////////////////////////////////////////////////
                                } else {
                                  updateCount(
                                      questionsModel.user_id,
                                      questionsModel.question_id,
                                      'examlikelyhood',
                                      "+",
                                      questionsModel);
                                  _add_questions_examlikelyhood_details(
                                      questionsModel.user_id,
                                      questionsModel.question_id,
                                      "high");
                                  updateExamLikelyType("high", questionsModel);
                                  ////////////////////////////notification//////////////////////////////////////
                                  notifyCRUD.createNotification(
                                      questionsModel.question_id,
                                      "question",
                                      "yes",
                                      "false",
                                      questionsModel.user_id,
                                      countData!.value["usertoken"]
                                          [questionsModel.user_id]["tokenid"],
                                      "${userDataDB!.get('first_name')} ${userDataDB!.get('last_name')} marked your question as highly examlikelihood.",
                                      "You got a examlikelihood",
                                      "question",
                                      "reaction",
                                      "+");
                                  /////////////////////////////////////////////////////////////////////////////
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
                                        color: (questionsModel
                                                    .examlikelyhood_type ==
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
                                if ((questionsModel.examlikelyhood_type ==
                                    "low")) {
                                  _add_questions_examlikelyhood_details(
                                      questionsModel.user_id,
                                      questionsModel.question_id,
                                      "moderate");
                                  updateExamLikelyType(
                                      "moderate", questionsModel);
                                  ////////////////////////////notification//////////////////////////////////////
                                  notifyCRUD.createNotification(
                                      questionsModel.question_id,
                                      "question",
                                      "no",
                                      "false",
                                      questionsModel.user_id,
                                      countData!.value["usertoken"]
                                          [questionsModel.user_id]["tokenid"],
                                      "${userDataDB!.get('first_name')} ${userDataDB!.get('last_name')} marked your question as moderate examlikelihood.",
                                      "You got a examlikelihood",
                                      "question",
                                      "reaction",
                                      "+");
                                  /////////////////////////////////////////////////////////////////////////////
                                } else if ((questionsModel
                                        .examlikelyhood_type ==
                                    "high")) {
                                  _add_questions_examlikelyhood_details(
                                      questionsModel.user_id,
                                      questionsModel.question_id,
                                      "moderate");
                                  updateExamLikelyType(
                                      "moderate", questionsModel);
                                  ////////////////////////////notification//////////////////////////////////////
                                  notifyCRUD.createNotification(
                                      questionsModel.question_id,
                                      "question",
                                      "no",
                                      "false",
                                      questionsModel.user_id,
                                      countData!.value["usertoken"]
                                          [questionsModel.user_id]["tokenid"],
                                      "${userDataDB!.get('first_name')} ${userDataDB!.get('last_name')} marked your question as moderate examlikelihood.",
                                      "You got a examlikelihood",
                                      "question",
                                      "reaction",
                                      "+");
                                  /////////////////////////////////////////////////////////////////////////////
                                } else if ((questionsModel
                                        .examlikelyhood_type ==
                                    "moderate")) {
                                  updateCount(
                                      questionsModel.user_id,
                                      questionsModel.question_id,
                                      'examlikelyhood',
                                      "-",
                                      questionsModel);
                                  _delete_questions_examlikelyhood_details(
                                      questionsModel.user_id,
                                      questionsModel.question_id);
                                  updateExamLikelyType("", questionsModel);
                                  ////////////////////////////notification//////////////////////////////////////
                                  notifyCRUD.createNotification(
                                      questionsModel.question_id,
                                      "question",
                                      "no",
                                      "false",
                                      questionsModel.user_id,
                                      countData!.value["usertoken"]
                                          [questionsModel.user_id]["tokenid"],
                                      "${userDataDB!.get('first_name')} ${userDataDB!.get('last_name')} marked your question as moderate examlikelihood.",
                                      "You got a examlikelihood",
                                      "question",
                                      "reaction",
                                      "-");
                                  /////////////////////////////////////////////////////////////////////////////
                                } else {
                                  updateCount(
                                      questionsModel.user_id,
                                      questionsModel.question_id,
                                      'examlikelyhood',
                                      "+",
                                      questionsModel);
                                  _add_questions_examlikelyhood_details(
                                      questionsModel.user_id,
                                      questionsModel.question_id,
                                      "moderate");
                                  updateExamLikelyType(
                                      "moderate", questionsModel);
                                  ////////////////////////////notification//////////////////////////////////////
                                  notifyCRUD.createNotification(
                                      questionsModel.question_id,
                                      "question",
                                      "yes",
                                      "false",
                                      questionsModel.user_id,
                                      countData!.value["usertoken"]
                                          [questionsModel.user_id]["tokenid"],
                                      "${userDataDB!.get('first_name')} ${userDataDB!.get('last_name')} marked your question as moderate examlikelihood.",
                                      "You got a examlikelihood",
                                      "question",
                                      "reaction",
                                      "+");
                                  /////////////////////////////////////////////////////////////////////////////
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
                                        color: (questionsModel
                                                    .examlikelyhood_type ==
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
                                if ((questionsModel.examlikelyhood_type ==
                                    "high")) {
                                  _add_questions_examlikelyhood_details(
                                      questionsModel.user_id,
                                      questionsModel.question_id,
                                      "low");
                                  updateExamLikelyType("low", questionsModel);
                                  ////////////////////////////notification//////////////////////////////////////
                                  notifyCRUD.createNotification(
                                      questionsModel.question_id,
                                      "question",
                                      "no",
                                      "false",
                                      questionsModel.user_id,
                                      countData!.value["usertoken"]
                                          [questionsModel.user_id]["tokenid"],
                                      "${userDataDB!.get('first_name')} ${userDataDB!.get('last_name')} marked your question as low examlikelihood.",
                                      "You got a examlikelihood",
                                      "question",
                                      "reaction",
                                      "+");
                                  /////////////////////////////////////////////////////////////////////////////
                                } else if ((questionsModel
                                        .examlikelyhood_type ==
                                    "moderate")) {
                                  _add_questions_examlikelyhood_details(
                                      questionsModel.user_id,
                                      questionsModel.question_id,
                                      "low");
                                  updateExamLikelyType("low", questionsModel);
                                  ////////////////////////////notification//////////////////////////////////////
                                  notifyCRUD.createNotification(
                                      questionsModel.question_id,
                                      "question",
                                      "no",
                                      "false",
                                      questionsModel.user_id,
                                      countData!.value["usertoken"]
                                          [questionsModel.user_id]["tokenid"],
                                      "${userDataDB!.get('first_name')} ${userDataDB!.get('last_name')} marked your question as low examlikelihood.",
                                      "You got a examlikelihood",
                                      "question",
                                      "reaction",
                                      "+");
                                  /////////////////////////////////////////////////////////////////////////////
                                } else if ((questionsModel
                                        .examlikelyhood_type ==
                                    "low")) {
                                  updateCount(
                                      questionsModel.user_id,
                                      questionsModel.question_id,
                                      'examlikelyhood',
                                      "-",
                                      questionsModel);
                                  updateExamLikelyType("", questionsModel);
                                  _delete_questions_examlikelyhood_details(
                                      questionsModel.user_id,
                                      questionsModel.question_id);
                                  ////////////////////////////notification//////////////////////////////////////
                                  notifyCRUD.createNotification(
                                      questionsModel.question_id,
                                      "question",
                                      "no",
                                      "false",
                                      questionsModel.user_id,
                                      countData!.value["usertoken"]
                                          [questionsModel.user_id]["tokenid"],
                                      "${userDataDB!.get('first_name')} ${userDataDB!.get('last_name')} marked your question as low examlikelihood.",
                                      "You got a examlikelihood",
                                      "question",
                                      "reaction",
                                      "-");
                                  /////////////////////////////////////////////////////////////////////////////
                                } else {
                                  updateCount(
                                      questionsModel.user_id,
                                      questionsModel.question_id,
                                      'examlikelyhood',
                                      "+",
                                      questionsModel);
                                  _add_questions_examlikelyhood_details(
                                      questionsModel.user_id,
                                      questionsModel.question_id,
                                      "low");
                                  updateExamLikelyType("low", questionsModel);
                                  ////////////////////////////notification//////////////////////////////////////
                                  notifyCRUD.createNotification(
                                      questionsModel.question_id,
                                      "question",
                                      "yes",
                                      "false",
                                      questionsModel.user_id,
                                      countData!.value["usertoken"]
                                          [questionsModel.user_id]["tokenid"],
                                      "${userDataDB!.get('first_name')} ${userDataDB!.get('last_name')} marked your question as low examlikelihood.",
                                      "You got a examlikelihood",
                                      "question",
                                      "reaction",
                                      "+");
                                  /////////////////////////////////////////////////////////////////////////////
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
                                        color: (questionsModel
                                                    .examlikelyhood_type ==
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
                                if ((questionsModel.toughness_type == "low")) {
                                  _add_questions_toughness_details(
                                      questionsModel.user_id,
                                      questionsModel.question_id,
                                      "high");
                                  updateToughNessType("high", questionsModel);
                                  ////////////////////////////notification//////////////////////////////////////
                                  notifyCRUD.createNotification(
                                      questionsModel.question_id,
                                      "question",
                                      "no",
                                      "false",
                                      questionsModel.user_id,
                                      countData!.value["usertoken"]
                                          [questionsModel.user_id]["tokenid"],
                                      "${userDataDB!.get('first_name')} ${userDataDB!.get('last_name')} marked your question as highly tough.",
                                      "You got a toughness",
                                      "question",
                                      "reaction",
                                      "+");
                                  /////////////////////////////////////////////////////////////////////////////
                                } else if ((questionsModel.toughness_type ==
                                    "medium")) {
                                  _add_questions_toughness_details(
                                      questionsModel.user_id,
                                      questionsModel.question_id,
                                      "high");
                                  updateToughNessType("high", questionsModel);
                                  ////////////////////////////notification//////////////////////////////////////
                                  notifyCRUD.createNotification(
                                      questionsModel.question_id,
                                      "question",
                                      "no",
                                      "false",
                                      questionsModel.user_id,
                                      countData!.value["usertoken"]
                                          [questionsModel.user_id]["tokenid"],
                                      "${userDataDB!.get('first_name')} ${userDataDB!.get('last_name')} marked your question as highly tough.",
                                      "You got a toughness",
                                      "question",
                                      "reaction",
                                      "+");
                                  /////////////////////////////////////////////////////////////////////////////
                                } else if ((questionsModel.toughness_type ==
                                    "high")) {
                                  _delete_questions_toughness_details(
                                      questionsModel.user_id,
                                      questionsModel.question_id);
                                  updateCount(
                                      questionsModel.user_id,
                                      questionsModel.question_id,
                                      'toughness',
                                      "-",
                                      questionsModel);
                                  updateToughNessType("", questionsModel);
                                  ////////////////////////////notification//////////////////////////////////////
                                  notifyCRUD.createNotification(
                                      questionsModel.question_id,
                                      "question",
                                      "no",
                                      "false",
                                      questionsModel.user_id,
                                      countData!.value["usertoken"]
                                          [questionsModel.user_id]["tokenid"],
                                      "${userDataDB!.get('first_name')} ${userDataDB!.get('last_name')} marked your question as highly tough.",
                                      "You got a toughness",
                                      "question",
                                      "reaction",
                                      "-");
                                  /////////////////////////////////////////////////////////////////////////////
                                } else {
                                  updateCount(
                                      questionsModel.user_id,
                                      questionsModel.question_id,
                                      'toughness',
                                      "+",
                                      questionsModel);
                                  _add_questions_toughness_details(
                                      questionsModel.user_id,
                                      questionsModel.question_id,
                                      "high");
                                  updateToughNessType("high", questionsModel);
                                  ////////////////////////////notification//////////////////////////////////////
                                  notifyCRUD.createNotification(
                                      questionsModel.question_id,
                                      "question",
                                      "yes",
                                      "false",
                                      questionsModel.user_id,
                                      countData!.value["usertoken"]
                                          [questionsModel.user_id]["tokenid"],
                                      "${userDataDB!.get('first_name')} ${userDataDB!.get('last_name')} marked your question as highly tough.",
                                      "You got a toughness",
                                      "question",
                                      "reaction",
                                      "+");
                                  /////////////////////////////////////////////////////////////////////////////
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
                                        color: (questionsModel.toughness_type ==
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
                                if ((questionsModel.toughness_type == "low")) {
                                  _delete_questions_toughness_details(
                                      questionsModel.user_id,
                                      questionsModel.question_id);
                                  _add_questions_toughness_details(
                                      questionsModel.user_id,
                                      questionsModel.question_id,
                                      "medium");
                                  updateToughNessType("medium", questionsModel);
                                  ////////////////////////////notification//////////////////////////////////////
                                  notifyCRUD.createNotification(
                                      questionsModel.question_id,
                                      "question",
                                      "no",
                                      "false",
                                      questionsModel.user_id,
                                      countData!.value["usertoken"]
                                          [questionsModel.user_id]["tokenid"],
                                      "${userDataDB!.get('first_name')} ${userDataDB!.get('last_name')} marked your question as medium tough.",
                                      "You got a toughness",
                                      "question",
                                      "reaction",
                                      "+");
                                  /////////////////////////////////////////////////////////////////////////////
                                } else if ((questionsModel.toughness_type ==
                                    "high")) {
                                  _add_questions_toughness_details(
                                      questionsModel.user_id,
                                      questionsModel.question_id,
                                      "medium");
                                  updateToughNessType("medium", questionsModel);
                                  ////////////////////////////notification//////////////////////////////////////
                                  notifyCRUD.createNotification(
                                      questionsModel.question_id,
                                      "question",
                                      "no",
                                      "false",
                                      questionsModel.user_id,
                                      countData!.value["usertoken"]
                                          [questionsModel.user_id]["tokenid"],
                                      "${userDataDB!.get('first_name')} ${userDataDB!.get('last_name')} marked your question as medium tough.",
                                      "You got a toughness",
                                      "question",
                                      "reaction",
                                      "+");
                                  /////////////////////////////////////////////////////////////////////////////
                                } else if ((questionsModel.toughness_type ==
                                    "medium")) {
                                  _delete_questions_toughness_details(
                                      questionsModel.user_id,
                                      questionsModel.question_id);
                                  updateCount(
                                      questionsModel.user_id,
                                      questionsModel.question_id,
                                      'toughness',
                                      "-",
                                      questionsModel);
                                  updateToughNessType("", questionsModel);
                                  ////////////////////////////notification//////////////////////////////////////
                                  notifyCRUD.createNotification(
                                      questionsModel.question_id,
                                      "question",
                                      "no",
                                      "false",
                                      questionsModel.user_id,
                                      countData!.value["usertoken"]
                                          [questionsModel.user_id]["tokenid"],
                                      "${userDataDB!.get('first_name')} ${userDataDB!.get('last_name')} marked your question as medium tough.",
                                      "You got a toughness",
                                      "question",
                                      "reaction",
                                      "-");
                                  /////////////////////////////////////////////////////////////////////////////
                                } else {
                                  updateCount(
                                      questionsModel.user_id,
                                      questionsModel.question_id,
                                      'toughness',
                                      "+",
                                      questionsModel);
                                  _add_questions_toughness_details(
                                      questionsModel.user_id,
                                      questionsModel.question_id,
                                      "medium");
                                  updateToughNessType("medium", questionsModel);
                                  ////////////////////////////notification//////////////////////////////////////
                                  notifyCRUD.createNotification(
                                      questionsModel.question_id,
                                      "question",
                                      "yes",
                                      "false",
                                      questionsModel.user_id,
                                      countData!.value["usertoken"]
                                          [questionsModel.user_id]["tokenid"],
                                      "${userDataDB!.get('first_name')} ${userDataDB!.get('last_name')} marked your question as medium tough.",
                                      "You got a toughness",
                                      "question",
                                      "reaction",
                                      "+");
                                  /////////////////////////////////////////////////////////////////////////////
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
                                        color: (questionsModel.toughness_type ==
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
                                if ((questionsModel.toughness_type == "high")) {
                                  _add_questions_toughness_details(
                                      questionsModel.user_id,
                                      questionsModel.question_id,
                                      "low");
                                  updateToughNessType("low", questionsModel);
                                  ////////////////////////////notification//////////////////////////////////////
                                  notifyCRUD.createNotification(
                                      questionsModel.question_id,
                                      "question",
                                      "no",
                                      "false",
                                      questionsModel.user_id,
                                      countData!.value["usertoken"]
                                          [questionsModel.user_id]["tokenid"],
                                      "${userDataDB!.get('first_name')} ${userDataDB!.get('last_name')} marked your question as low tough.",
                                      "You got a toughness",
                                      "question",
                                      "reaction",
                                      "+");
                                  /////////////////////////////////////////////////////////////////////////////
                                } else if ((questionsModel.toughness_type ==
                                    "medium")) {
                                  _add_questions_toughness_details(
                                      questionsModel.user_id,
                                      questionsModel.question_id,
                                      "low");
                                  updateToughNessType("low", questionsModel);
                                  ////////////////////////////notification//////////////////////////////////////
                                  notifyCRUD.createNotification(
                                      questionsModel.question_id,
                                      "question",
                                      "no",
                                      "false",
                                      questionsModel.user_id,
                                      countData!.value["usertoken"]
                                          [questionsModel.user_id]["tokenid"],
                                      "${userDataDB!.get('first_name')} ${userDataDB!.get('last_name')} marked your question as low tough.",
                                      "You got a toughness",
                                      "question",
                                      "reaction",
                                      "+");
                                  /////////////////////////////////////////////////////////////////////////////
                                } else if ((questionsModel.toughness_type ==
                                    "low")) {
                                  _delete_questions_toughness_details(
                                      questionsModel.user_id,
                                      questionsModel.question_id);
                                  updateCount(
                                      questionsModel.user_id,
                                      questionsModel.question_id,
                                      'toughness',
                                      "-",
                                      questionsModel);
                                  updateToughNessType("", questionsModel);
                                  ////////////////////////////notification//////////////////////////////////////
                                  notifyCRUD.createNotification(
                                      questionsModel.question_id,
                                      "question",
                                      "no",
                                      "false",
                                      questionsModel.user_id,
                                      countData!.value["usertoken"]
                                          [questionsModel.user_id]["tokenid"],
                                      "${userDataDB!.get('first_name')} ${userDataDB!.get('last_name')} marked your question as low tough.",
                                      "You got a toughness",
                                      "question",
                                      "reaction",
                                      "-");
                                  /////////////////////////////////////////////////////////////////////////////
                                } else {
                                  updateCount(
                                      questionsModel.user_id,
                                      questionsModel.question_id,
                                      'toughness',
                                      "+",
                                      questionsModel);
                                  _add_questions_toughness_details(
                                      questionsModel.user_id,
                                      questionsModel.question_id,
                                      "low");
                                  updateToughNessType("low", questionsModel);
                                  ////////////////////////////notification//////////////////////////////////////
                                  notifyCRUD.createNotification(
                                      questionsModel.question_id,
                                      "question",
                                      "yes",
                                      "false",
                                      questionsModel.user_id,
                                      countData!.value["usertoken"]
                                          [questionsModel.user_id]["tokenid"],
                                      "${userDataDB!.get('first_name')} ${userDataDB!.get('last_name')} marked your question as low tough.",
                                      "You got a toughness",
                                      "question",
                                      "reaction",
                                      "+");
                                  /////////////////////////////////////////////////////////////////////////////
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
                                        color: (questionsModel.toughness_type ==
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

  generateNotifications() {}

  Future<void> _add_questions_examlikelyhood_details(
      String user_id, String question_id, String examlikelyhood_level) async {
    final http.Response response = await http.post(
      Uri.parse(Constant.BASE_URL + 'add_questions_examlikelyhood_details'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        "Access-Control_Allow_Origin": "*"
      },
      body: jsonEncode(<String, dynamic>{
        "user_id": _currentUserId,
        "question_id": question_id,
        "examlikelyhood_level": examlikelyhood_level
      }),
    );

    print(response.statusCode);
  }

  Future<void> _delete_questions_examlikelyhood_details(
      String user_id, String question_id) async {
    final http.Response response = await http.delete(
      Uri.parse(Constant.BASE_URL + 'delete_questions_examlikelyhood_details'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        "Access-Control_Allow_Origin": "*"
      },
      body: jsonEncode(<String, dynamic>{
        "user_id": _currentUserId,
        "question_id": question_id
      }),
    );
    print(response.statusCode);
  }

  Future<void> _add_questions_toughness_details(
      String user_id, String question_id, String toughness_level) async {
    final http.Response response = await http.post(
      Uri.parse(Constant.BASE_URL + 'add_questions_toughness_details'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        "Access-Control_Allow_Origin": "*"
      },
      body: jsonEncode(<String, dynamic>{
        "user_id": _currentUserId,
        "question_id": question_id,
        "toughness_level": toughness_level
      }),
    );
    print(response.statusCode);
  }

  Future<void> _delete_questions_toughness_details(
      String user_id, String question_id) async {
    final http.Response response = await http.delete(
      Uri.parse(Constant.BASE_URL + 'delete_questions_toughness_details'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        "Access-Control_Allow_Origin": "*"
      },
      body: jsonEncode(<String, dynamic>{
        "user_id": _currentUserId,
        "question_id": question_id
      }),
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
                                      QuestionProviders questionProvider =
                                          Provider.of<QuestionProviders>(
                                              context,
                                              listen: false);
                                      questionProvider.questionList.data!.add(
                                          Questions(
                                              first_name:
                                                  userDataDB!.get("first_name"),
                                              last_name:
                                                  userDataDB!.get("last_name"),
                                              profilepic:
                                                  userDataDB!.get("profilepic"),
                                              school_name: userDataDB!
                                                  .get("school_name"),
                                              question_id: data[0],
                                              user_id: data[1],
                                              answer_count: data[2],
                                              answer_preference: data[3],
                                              audio_reference: data[4],
                                              call_date: data[5],
                                              call_end_time: data[6],
                                              call_now: data[7],
                                              call_preferred_lang: data[8],
                                              call_start_time: data[9],
                                              answer_credit: data[10],
                                              question_credit: data[11],
                                              view_count: data[12],
                                              examlikelyhood_count: data[13],
                                              grade: data[14],
                                              like_count: data[15],
                                              note_reference: data[16],
                                              ocr_image: data[17],
                                              compare_date: data[18],
                                              question: data[19],
                                              question_type: data[20],
                                              is_identity_visible: data[21],
                                              subject: data[22],
                                              topic: data[23],
                                              tag_list: [],
                                              city: userDataDB!.get("city"),
                                              text_reference: data[24],
                                              toughness_count: data[25],
                                              video_reference: data[26],
                                              impression_count: data[27],
                                              isExamlikelyhoodButtonExpanded:
                                                  "false",
                                              isLikeButtonExpanded: "false",
                                              isToughnessButtonExpanded:
                                                  "false",
                                              like_type: "",
                                              examlikelyhood_type: "",
                                              toughness_type: "",
                                              is_save: "",
                                              is_bookmark: "",
                                              high_toughness_count: 0,
                                              medium_toughness_count: 0,
                                              low_toughness_count: 0,
                                              high_examlike_count: 0,
                                              medium_examlike_count: 0,
                                              low_examlike_count: 0,
                                              shared_question_details: <
                                                  SharedQuestion>[]));
                                      questionProvider
                                          .fetchQuestionList(_currentUserId);
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
                                              rootNavigator: false)
                                          .pop();
                                      Navigator.of(context).pop();
                                      ElegantNotification.success(
                                        title: Text("Congrats,"),
                                        description: Text(
                                            "Your question posted successfully, it will take few minute to review and publish."),
                                      );
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
  void _shareQuestionPostDialog(Questions questionsModel, int index) {
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
                                      questionsModel.question_id,
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
                                    QuestionProviders questionProvider =
                                        Provider.of<QuestionProviders>(context,
                                            listen: false);
                                    questionProvider.questionList.data!.add(Questions(
                                        first_name: questionsModel.first_name,
                                        last_name: questionsModel.last_name,
                                        profilepic: questionsModel.profilepic,
                                        school_name: questionsModel.school_name,
                                        question_id: questionsModel.question_id,
                                        user_id: questionsModel.user_id,
                                        answer_count:
                                            questionsModel.answer_count,
                                        answer_preference:
                                            questionsModel.answer_preference,
                                        audio_reference:
                                            questionsModel.audio_reference,
                                        call_date: questionsModel.call_date,
                                        call_end_time:
                                            questionsModel.call_end_time,
                                        call_now: questionsModel.call_now,
                                        call_preferred_lang:
                                            questionsModel.call_preferred_lang,
                                        call_start_time:
                                            questionsModel.call_start_time,
                                        answer_credit:
                                            questionsModel.answer_credit,
                                        question_credit:
                                            questionsModel.question_credit,
                                        view_count: questionsModel.view_count,
                                        examlikelyhood_count:
                                            questionsModel.examlikelyhood_count,
                                        grade: questionsModel.grade,
                                        like_count: questionsModel.like_count,
                                        note_reference:
                                            questionsModel.note_reference,
                                        ocr_image: questionsModel.ocr_image,
                                        compare_date:
                                            questionsModel.compare_date,
                                        question: questionsModel.question,
                                        question_type:
                                            questionsModel.question_type,
                                        is_identity_visible:
                                            questionsModel.is_identity_visible,
                                        subject: questionsModel.subject,
                                        topic: questionsModel.topic,
                                        tag_list: questionsModel.tag_list,
                                        city: questionsModel.city,
                                        text_reference:
                                            questionsModel.text_reference,
                                        toughness_count:
                                            questionsModel.toughness_count,
                                        video_reference:
                                            questionsModel.video_reference,
                                        impression_count:
                                            questionsModel.impression_count,
                                        isExamlikelyhoodButtonExpanded:
                                            questionsModel
                                                .isExamlikelyhoodButtonExpanded,
                                        isLikeButtonExpanded:
                                            questionsModel.isLikeButtonExpanded,
                                        isToughnessButtonExpanded:
                                            questionsModel
                                                .isToughnessButtonExpanded,
                                        like_type: questionsModel.like_type,
                                        examlikelyhood_type:
                                            questionsModel.examlikelyhood_type,
                                        toughness_type:
                                            questionsModel.toughness_type,
                                        is_save: questionsModel.is_save,
                                        is_bookmark: questionsModel.is_bookmark,
                                        high_toughness_count:
                                            questionsModel.high_toughness_count,
                                        medium_toughness_count: questionsModel
                                            .medium_toughness_count,
                                        low_toughness_count:
                                            questionsModel.low_toughness_count,
                                        high_examlike_count:
                                            questionsModel.high_examlike_count,
                                        medium_examlike_count: questionsModel
                                            .medium_examlike_count,
                                        low_examlike_count:
                                            questionsModel.low_examlike_count,
                                        shared_question_details: <
                                            SharedQuestion>[
                                          SharedQuestion(
                                              first_name:
                                                  userDataDB!.get("first_name"),
                                              last_name:
                                                  userDataDB!.get("last_name"),
                                              profilepic:
                                                  userDataDB!.get("profilepic"),
                                              school_name: userDataDB!
                                                  .get("school_name"),
                                              question_id: data[0],
                                              user_id: data[1],
                                              answer_count: data[2],
                                              answer_preference: data[3],
                                              audio_reference: data[4],
                                              call_date: data[5],
                                              call_end_time: data[6],
                                              call_now: data[7],
                                              call_preferred_lang: data[8],
                                              call_start_time: data[9],
                                              answer_credit: data[10],
                                              question_credit: data[11],
                                              view_count: data[12],
                                              examlikelyhood_count: data[13],
                                              grade: data[14],
                                              like_count: data[15],
                                              note_reference: data[16],
                                              ocr_image: data[17],
                                              compare_date: data[18],
                                              question: data[19],
                                              question_type: data[20],
                                              is_identity_visible: data[21],
                                              subject: data[22],
                                              topic: data[23],
                                              tag_list: [],
                                              city: userDataDB!.get("city"),
                                              text_reference: data[24],
                                              toughness_count: data[25],
                                              video_reference: data[26],
                                              impression_count: data[27],
                                              isExamlikelyhoodButtonExpanded:
                                                  "false",
                                              isLikeButtonExpanded: "false",
                                              isToughnessButtonExpanded:
                                                  "false",
                                              like_type: "",
                                              examlikelyhood_type: "",
                                              toughness_type: "",
                                              is_save: "",
                                              is_bookmark: "",
                                              high_toughness_count: 0,
                                              medium_toughness_count: 0,
                                              low_toughness_count: 0,
                                              high_examlike_count: 0,
                                              medium_examlike_count: 0,
                                              low_examlike_count: 0)
                                        ]));
                                    questionProvider
                                        .fetchQuestionList(_currentUserId);
                                    ElegantNotification.success(
                                      title: Text("Congrats,"),
                                      description: Text(
                                          "Your shared question posted successfully."),
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
                                      title: Text("Error..."),
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
                      questionsModel.question_type == "text"
                          ? InkWell(
                              onTap: () {},
                              child: Container(
                                padding: EdgeInsets.all(10),
                                color: Color.fromRGBO(242, 246, 248, 1),
                                width: _width! > 530 ? 450 : _width! - 30,
                                margin: EdgeInsets.fromLTRB(10, 10, 0, 2),
                                child: ReadMoreText(
                                  questionsModel.question,
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
                                  TeXViewDocument(questionsModel.question,
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
                Navigator.of(_keyLoader.currentContext!, rootNavigator: false)
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
            Navigator.of(_keyLoader.currentContext!, rootNavigator: false)
                .pop(); //close the dialoge
            setState(() {
              referenceNotesAtttachedURL = downloadURL;
              print(downloadURL);
              notesAttached = true;
              progress = 0.0;
            });
            Navigator.of(context).pop();
            ElegantNotification.success(
              title: Text("Congrats,"),
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
            Navigator.of(_keyLoader.currentContext!, rootNavigator: false)
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
              Navigator.of(_keyLoader.currentContext!, rootNavigator: false)
                  .pop(); //close the dialoge
              referenceVideoAtttachedURL = downloadURL;
              print(downloadURL);
              audioAttached = true;
              progress = 0.0;
            });

            Navigator.of(context).pop();
            ElegantNotification.success(
              title: Text("Congrats,"),
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

  void _addAnswerPostDialog(Questions questionData, int qIndex) {
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
                                child: questionData.question_type == "text"
                                    ? InkWell(
                                        child: Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width -
                                              30,
                                          margin:
                                              EdgeInsets.fromLTRB(10, 10, 0, 2),
                                          child: ReadMoreText(
                                            questionData.question,
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
                                                questionData.question,
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
                                              _anspickImage(context,
                                                  questionData, qIndex);
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
                                              _pickImageAnswer(context,
                                                  questionData, qIndex);
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
                                    _ansreference(
                                        context, questionData, qIndex),
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
                                        ansID = questionData.question_id +
                                            comparedate;
                                        data = [
                                          ansID,
                                          questionData.question_id,
                                          _currentUserId,
                                          0,
                                          ansreferenceAudioAtttachedURL,
                                          0,
                                          0,
                                          0,
                                          ansreferenceNotesAtttachedURL,
                                          latex != ""
                                              ? ocrImageURL
                                              : ansImageURL != ""
                                                  ? ansImageURL
                                                  : "",
                                          comparedate,
                                          answer != ""
                                              ? answer
                                              : latex != ""
                                                  ? latex
                                                  : "",
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
                                        notificationDB.createNotification(
                                            questionData.question_id,
                                            "question",
                                            "yes",
                                            "false",
                                            questionData.user_id,
                                            countData!.value["usertoken"]
                                                    [questionData.user_id]
                                                ["tokenid"],
                                            "${userDataDB!.get('first_name')} ${userDataDB!.get('last_name')} answered on your question.",
                                            "You got a toughness",
                                            "question",
                                            "answer",
                                            "+");
                                        /////////////////////////////////////////////////////////////////////////////

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
                                        setState(() {
                                          questionData.answer_count++;
                                        });
                                        Navigator.of(_keyLoader.currentContext!,
                                                rootNavigator: false)
                                            .pop();
                                        Navigator.of(context).pop();
                                        ElegantNotification.success(
                                          title: Text("Congrats..."),
                                          description: Text(
                                              "Your answer is posted successfully."),
                                        );
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

  _ansreference(BuildContext context, Questions questionData, int qIndex) {
    return Container(
        height: 80,
        child: ListView(
          scrollDirection: Axis.horizontal,
          physics: BouncingScrollPhysics(),
          children: [
            InkWell(
              onTap: () async {
                _anspickNotes(context, questionData, qIndex);
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
                _anspickVideo(context, questionData, qIndex);
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
                _anspickAudio(context, questionData, qIndex);
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

  void _anspickImage(
      BuildContext context, Questions questionData, int qIndex) async {
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
                _addAnswerPostDialog(questionData, qIndex);
              }
            }
          });
        }
      }
    }
  }

  void _pickImageAnswer(
      BuildContext context, Questions questionData, int qIndex) async {
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
            _addAnswerPostDialog(questionData, qIndex);
          }
        }
      });
    }
  }

  void _anspickNotes(
      BuildContext context, Questions questionData, int qIndex) async {
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
            _addAnswerPostDialog(questionData, qIndex);
            ElegantNotification.success(
              title: Text("Congrats,"),
              description: Text("You attatched note successfully."),
            );
          }
        }
      });
    }
  }

  void _anspickVideo(
      BuildContext context, Questions questionData, int qIndex) async {
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
            _addAnswerPostDialog(questionData, qIndex);
            ElegantNotification.success(
              title: Text("Congrats,"),
              description: Text("You attatched video file successfully."),
            );
          }
        }
      });
    }
  }

  void _anspickAudio(
      BuildContext context, Questions questionData, int qIndex) async {
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
            _addAnswerPostDialog(questionData, qIndex);
            ElegantNotification.success(
              title: Text("Congrats,"),
              description: Text("You attatched audio file successfully."),
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

// //Comment Post

//   bool cmntPostVisibility = false;
//   String commentType = 'text';
//   String comment = "";
//   String cmntImageURL = "";
//   String cmntreferenceNotesAtttachedURL = "";
//   String cmntreferenceVideoAtttachedURL = "";
//   String cmntreferenceAudioAtttachedURL = "";
//   String cmntreferenceTextAtttached = "";

//   bool cmntnotesAttached = false;
//   bool cmntvideoAttached = false;
//   bool cmntaudioAttached = false;
//   bool cmnttextAttached = false;

//   void _addCommentPostDialog(int qIndex, int ansSelectID, int ansIndex) {
//     showDialog(
//         context: context,
//         barrierColor: Colors.grey.withOpacity(0.2),
//         barrierDismissible: false,
//         builder: (_) => StatefulBuilder(builder: (context, setState) {
//               return AlertDialog(
//                 contentPadding: EdgeInsets.all(20),
//                 shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10.0)),
//                 title: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         SizedBox(width: 30),
//                         Text(
//                           "Post your comment",
//                           style: TextStyle(
//                             fontSize: 20,
//                             color: Color(0xCB000000),
//                             fontWeight: FontWeight.w900,
//                           ),
//                         ),
//                         IconButton(
//                           onPressed: () {
//                             cmntPostVisibility = false;
//                             commentType = 'text';
//                             comment = "";
//                             cmntreferenceNotesAtttachedURL = "";
//                             cmntreferenceVideoAtttachedURL = "";
//                             cmntreferenceAudioAtttachedURL = "";
//                             cmntreferenceTextAtttached = "";
//                             cmntImageURL = "";
//                             cmntnotesAttached = false;
//                             cmntvideoAttached = false;
//                             cmntaudioAttached = false;
//                             cmnttextAttached = false;
//                             Navigator.pop(context);
//                           },
//                           icon: Tab(
//                               child: Icon(Icons.cancel_rounded,
//                                   color: Colors.black45, size: 25)),
//                         )
//                       ],
//                     ),
//                     SizedBox(height: 20),
//                     Container(height: 1, width: 500, color: Colors.grey[200]),
//                   ],
//                 ),
//                 content: Container(
//                   height: 470,
//                   width: 500,
//                   child: SingleChildScrollView(
//                     child: Column(
//                       children: [
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Text(
//                                 cmntPostVisibility == false
//                                     ? "Choose comment type"
//                                     : "Post comment",
//                                 style: TextStyle(
//                                     fontSize: 16, color: Colors.black54)),
//                             cmntPostVisibility == true
//                                 ? IconButton(
//                                     onPressed: () {
//                                       if (cmntPostVisibility == true) {
//                                         setState(() {
//                                           cmntPostVisibility = false;
//                                         });
//                                       }
//                                     },
//                                     icon: Icon(Icons.arrow_back_ios,
//                                         color: Colors.black54, size: 22))
//                                 : SizedBox(width: 20)
//                           ],
//                         ),
//                         SizedBox(height: 10),
//                         cmntPostVisibility == true
//                             ? Container(
//                                 margin: EdgeInsets.fromLTRB(20, 0, 20, 0),
//                                 padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
//                                 decoration: BoxDecoration(
//                                     color: Color.fromRGBO(242, 246, 248, 1),
//                                     borderRadius: BorderRadius.circular(10)),
//                                 child: allAnswersQIDwise[ansSelectID][ansIndex]
//                                             ["answer_type"] ==
//                                         "text"
//                                     ? InkWell(
//                                         child: Container(
//                                           width: MediaQuery.of(context)
//                                                   .size
//                                                   .width -
//                                               30,
//                                           margin:
//                                               EdgeInsets.fromLTRB(10, 10, 0, 2),
//                                           child: ReadMoreText(
//                                             allAnswersQIDwise[ansSelectID]
//                                                 [ansIndex]["answer"],
//                                             textAlign: TextAlign.left,
//                                             trimLines: 4,
//                                             colorClickableText:
//                                                 Color(0xff0962ff),
//                                             trimMode: TrimMode.Line,
//                                             trimCollapsedText: 'read more',
//                                             trimExpandedText: 'Show less',
//                                             style: TextStyle(
//                                               fontFamily: 'Nunito Sans',
//                                               fontSize: 16,
//                                               color:
//                                                   Color.fromRGBO(0, 0, 0, 0.8),
//                                               fontWeight: FontWeight.w400,
//                                             ),
//                                             lessStyle: TextStyle(
//                                               fontFamily: 'Nunito Sans',
//                                               fontSize: 12,
//                                               color: Color(0xff0962ff),
//                                               fontWeight: FontWeight.w700,
//                                             ),
//                                             moreStyle: TextStyle(
//                                               fontFamily: 'Nunito Sans',
//                                               fontSize: 12,
//                                               color: Color(0xff0962ff),
//                                               fontWeight: FontWeight.w700,
//                                             ),
//                                           ),
//                                         ),
//                                       )
//                                     : allAnswersQIDwise[ansSelectID][ansIndex]
//                                                 ["answer_type"] ==
//                                             "ocr"
//                                         ? Container(
//                                             margin: EdgeInsets.fromLTRB(
//                                                 1, 10, 1, 10),
//                                             child: TeXView(
//                                               child: TeXViewColumn(children: [
//                                                 TeXViewDocument(
//                                                     allAnswersQIDwise[
//                                                             ansSelectID]
//                                                         [ansIndex]["answer"],
//                                                     style: TeXViewStyle(
//                                                       fontStyle:
//                                                           TeXViewFontStyle(
//                                                               fontSize: 12,
//                                                               sizeUnit:
//                                                                   TeXViewSizeUnit
//                                                                       .pt),
//                                                       padding:
//                                                           TeXViewPadding.all(
//                                                               10),
//                                                     )),
//                                               ]),
//                                               style: TeXViewStyle(
//                                                 elevation: 10,
//                                                 backgroundColor: Color.fromRGBO(
//                                                     242, 246, 248, 1),
//                                               ),
//                                             ),
//                                           )
//                                         : SizedBox(),
//                               )
//                             : SizedBox(),
//                         SizedBox(height: 10),
//                         cmntPostVisibility == false
//                             ? Container(
//                                 height: 350,
//                                 margin: EdgeInsets.fromLTRB(20, 0, 20, 0),
//                                 child: Column(
//                                   children: [
//                                     SizedBox(
//                                       height: 10,
//                                     ),
//                                     SizedBox(
//                                       height: 30,
//                                     ),
//                                     Row(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.spaceEvenly,
//                                       children: [
//                                         InkWell(
//                                           onTap: () {
//                                             setState(() {
//                                               commentType = "text";
//                                               cmntPostVisibility = true;
//                                             });
//                                           },
//                                           child: Column(
//                                             children: [
//                                               Image.network(
//                                                   "https://firebasestorage.googleapis.com/v0/b/hys-pro-41c66.appspot.com/o/assets%2Ftyping.gif?alt=media&token=1a4b65b2-c497-438b-8c3a-a69dcfc7f67d",
//                                                   height: 100,
//                                                   width: 100),
//                                               SizedBox(
//                                                 height: 7,
//                                               ),
//                                               Text(
//                                                 "Keyboard",
//                                                 style: TextStyle(
//                                                   fontFamily: 'Nunito Sans',
//                                                   fontSize: 15,
//                                                   color: Color(0xff0C2551),
//                                                   fontWeight: FontWeight.w700,
//                                                 ),
//                                                 textAlign: TextAlign.center,
//                                               )
//                                             ],
//                                           ),
//                                         ),
//                                         InkWell(
//                                           onTap: () {
//                                             setState(() {
//                                               commentType = "image";
//                                               _pickImageComment(context, qIndex,
//                                                   ansSelectID, ansIndex);
//                                             });
//                                           },
//                                           child: Column(
//                                             children: [
//                                               Image.network(
//                                                   "https://firebasestorage.googleapis.com/v0/b/hys-pro-41c66.appspot.com/o/assets%2Fgallery.png?alt=media&token=09a32fa6-5e7c-4139-94e5-d4d74e5f5d6a",
//                                                   height: 100,
//                                                   width: 100),
//                                               SizedBox(
//                                                 height: 7,
//                                               ),
//                                               Text(
//                                                 "Image",
//                                                 style: TextStyle(
//                                                   fontFamily: 'Nunito Sans',
//                                                   fontSize: 15,
//                                                   color: Color(0xff0C2551),
//                                                   fontWeight: FontWeight.w700,
//                                                 ),
//                                                 textAlign: TextAlign.center,
//                                               )
//                                             ],
//                                           ),
//                                         )
//                                       ],
//                                     ),
//                                   ],
//                                 ),
//                               )
//                             : Container(
//                                 height: 350,
//                                 margin: EdgeInsets.fromLTRB(20, 0, 20, 0),
//                                 child: ListView(
//                                   physics: BouncingScrollPhysics(),
//                                   children: [
//                                     SizedBox(
//                                       height: 20,
//                                     ),
//                                     commentType == "text"
//                                         ? Container(
//                                             child: TextFormField(
//                                               maxLines: 10,
//                                               initialValue: comment,
//                                               keyboardType: TextInputType.text,
//                                               cursorColor: Color.fromRGBO(
//                                                   88, 165, 196, 1),
//                                               style: TextStyle(
//                                                   fontSize: 16,
//                                                   color: Color.fromRGBO(
//                                                       88, 165, 196, 1),
//                                                   fontWeight: FontWeight.w500),
//                                               validator: (val) => ((val!
//                                                       .isEmpty))
//                                                   ? 'Leave your comment here, you can\'t kept it blank'
//                                                   : null,
//                                               onChanged: (val) {
//                                                 setState(() => comment = val);
//                                               },
//                                               decoration: InputDecoration(
//                                                 fillColor: Color.fromRGBO(
//                                                     245, 245, 245, 1),
//                                                 filled: true,
//                                                 counterText: '',
//                                                 hintText: 'Your comment...',
//                                                 hintStyle: TextStyle(
//                                                     fontSize: 18,
//                                                     color: Colors.grey[300],
//                                                     fontWeight:
//                                                         FontWeight.w600),
//                                                 alignLabelWithHint: false,
//                                                 contentPadding:
//                                                     new EdgeInsets.symmetric(
//                                                         vertical: 10.0,
//                                                         horizontal: 10),
//                                                 errorStyle: TextStyle(
//                                                     color: Color.fromRGBO(
//                                                         240, 20, 41, 1)),
//                                                 focusColor: Color.fromRGBO(
//                                                     88, 165, 196, 1),
//                                                 focusedBorder:
//                                                     OutlineInputBorder(
//                                                   borderRadius:
//                                                       BorderRadius.circular(10),
//                                                   borderSide: BorderSide(
//                                                       color: Color.fromRGBO(
//                                                           245, 245, 245, 1)),
//                                                 ),
//                                                 enabledBorder:
//                                                     OutlineInputBorder(
//                                                   borderRadius:
//                                                       BorderRadius.circular(10),
//                                                   borderSide: BorderSide(
//                                                     color: Color.fromRGBO(
//                                                         245, 245, 245, 1),
//                                                   ),
//                                                 ),
//                                               ),
//                                             ),
//                                           )
//                                         : Container(
//                                             height: 100,
//                                             child: CachedNetworkImage(
//                                               imageUrl: cmntImageURL,
//                                               fit: BoxFit.contain,
//                                               placeholder: (context, url) =>
//                                                   Container(
//                                                 height: 30,
//                                                 width: 30,
//                                                 child: Image.network(
//                                                   "https://firebasestorage.googleapis.com/v0/b/hys-pro-41c66.appspot.com/o/assets%2Floadingimg.gif?alt=media&token=4ca910f2-c584-4b3a-bbcb-2f1c01d93f67",
//                                                 ),
//                                               ),
//                                               errorWidget:
//                                                   (context, url, error) =>
//                                                       Icon(Icons.error),
//                                             ),
//                                           ),
//                                     SizedBox(
//                                       height: 20,
//                                     ),
//                                     Container(
//                                       height: 50,
//                                       width: 400,
//                                       child: FlutterMentions(
//                                         key: key,
//                                         keyboardType: TextInputType.text,
//                                         cursorColor:
//                                             Color.fromRGBO(88, 165, 196, 1),
//                                         decoration: InputDecoration(
//                                           fillColor:
//                                               Color.fromRGBO(245, 245, 245, 1),
//                                           filled: true,
//                                           counterText: '',
//                                           hintText: '@Tag someone here',
//                                           hintStyle: TextStyle(
//                                               fontSize: 13,
//                                               color: Colors.grey[350],
//                                               fontWeight: FontWeight.w600),
//                                           alignLabelWithHint: false,
//                                           contentPadding:
//                                               new EdgeInsets.symmetric(
//                                                   vertical: 10.0,
//                                                   horizontal: 10),
//                                           errorStyle: TextStyle(
//                                               color: Color.fromRGBO(
//                                                   240, 20, 41, 1)),
//                                           focusColor:
//                                               Color.fromRGBO(88, 165, 196, 1),
//                                           focusedBorder: OutlineInputBorder(
//                                             borderRadius:
//                                                 BorderRadius.circular(10),
//                                             borderSide: BorderSide(
//                                                 color: Color.fromRGBO(
//                                                     245, 245, 245, 1)),
//                                           ),
//                                           enabledBorder: OutlineInputBorder(
//                                             borderRadius:
//                                                 BorderRadius.circular(10),
//                                             borderSide: BorderSide(
//                                               color: Color.fromRGBO(
//                                                   245, 245, 245, 1),
//                                             ),
//                                           ),
//                                         ),
//                                         style: TextStyle(
//                                             fontSize: 12,
//                                             color:
//                                                 Color.fromRGBO(88, 165, 196, 1),
//                                             fontWeight: FontWeight.w500),
//                                         suggestionPosition:
//                                             SuggestionPosition.Bottom,
//                                         onMarkupChanged: (val) {
//                                           setState(() {
//                                             markupptext = val;
//                                           });
//                                         },
//                                         onEditingComplete: () {
//                                           setState(() {
//                                             tagids.clear();
//                                             for (int l = 0;
//                                                 l < markupptext.length;
//                                                 l++) {
//                                               int k = l;
//                                               if (markupptext.substring(
//                                                       k, k + 1) ==
//                                                   "@") {
//                                                 String test1 =
//                                                     markupptext.substring(k);
//                                                 tagids.add(test1.substring(
//                                                     4, test1.indexOf("__]")));
//                                               }
//                                             }
//                                             print(tagids);
//                                           });
//                                         },
//                                         onSuggestionVisibleChanged: (val) {
//                                           setState(() {
//                                             _showList = val;
//                                           });
//                                         },
//                                         onChanged: (val) {
//                                           setState(() {
//                                             tagedString = val;
//                                           });
//                                         },
//                                         onSearchChanged: (
//                                           trigger,
//                                           value,
//                                         ) {
//                                           print('again | $trigger | $value ');
//                                         },
//                                         hideSuggestionList: false,
//                                         minLines: 1,
//                                         maxLines: 5,
//                                         mentions: [
//                                           Mention(
//                                               trigger: r'@',
//                                               style: TextStyle(
//                                                 color: Color.fromRGBO(
//                                                     88, 165, 196, 1),
//                                               ),
//                                               matchAll: false,
//                                               data: _users,
//                                               suggestionBuilder: (data) {
//                                                 return Container(
//                                                   padding: EdgeInsets.all(10),
//                                                   decoration: BoxDecoration(
//                                                       color: Colors.white,
//                                                       border: Border(
//                                                           top: BorderSide(
//                                                               color: Color(
//                                                                   0xFFE0E1E4)))),
//                                                   child: Row(
//                                                     mainAxisAlignment:
//                                                         MainAxisAlignment.start,
//                                                     children: <Widget>[
//                                                       CircleAvatar(
//                                                         backgroundImage:
//                                                             NetworkImage(
//                                                           data['photo'],
//                                                         ),
//                                                       ),
//                                                       SizedBox(
//                                                         width: 20.0,
//                                                       ),
//                                                       Column(
//                                                         mainAxisAlignment:
//                                                             MainAxisAlignment
//                                                                 .start,
//                                                         crossAxisAlignment:
//                                                             CrossAxisAlignment
//                                                                 .start,
//                                                         children: <Widget>[
//                                                           Row(
//                                                             mainAxisAlignment:
//                                                                 MainAxisAlignment
//                                                                     .start,
//                                                             children: [
//                                                               Text(data[
//                                                                   'display']),
//                                                             ],
//                                                           ),
//                                                           SizedBox(
//                                                             height: 3,
//                                                           ),
//                                                           Row(
//                                                             mainAxisAlignment:
//                                                                 MainAxisAlignment
//                                                                     .start,
//                                                             children: [
//                                                               Text(
//                                                                 '${data['full_name']}',
//                                                                 style:
//                                                                     TextStyle(
//                                                                   color: Color(
//                                                                       0xFFAAABAD),
//                                                                   fontSize: 11,
//                                                                 ),
//                                                               ),
//                                                             ],
//                                                           ),
//                                                         ],
//                                                       )
//                                                     ],
//                                                   ),
//                                                 );
//                                               }),
//                                         ],
//                                       ),
//                                     ),
//                                     SizedBox(
//                                       height: 10,
//                                     ),
//                                     ((cmntnotesAttached == true) ||
//                                             (cmntvideoAttached == true) ||
//                                             (cmntaudioAttached == true) ||
//                                             (cmnttextAttached == true))
//                                         ? Row(
//                                             mainAxisAlignment:
//                                                 MainAxisAlignment.start,
//                                             children: [
//                                               (cmntnotesAttached == true)
//                                                   ? SizedBox(
//                                                       width: 30,
//                                                     )
//                                                   : SizedBox(),
//                                               (cmntnotesAttached == true)
//                                                   ? GestureDetector(
//                                                       onTap: () async {
//                                                         _launchInBrowser(
//                                                             cmntreferenceNotesAtttachedURL);
//                                                       },
//                                                       onLongPress: () {
//                                                         setState(() {
//                                                           cmntnotesAttached =
//                                                               false;
//                                                           cmntreferenceAudioAtttachedURL =
//                                                               "";
//                                                         });
//                                                       },
//                                                       child: Container(
//                                                         width: 40,
//                                                         height: 40,
//                                                         decoration:
//                                                             BoxDecoration(
//                                                           color:
//                                                               Color(0xffffffff),
//                                                           borderRadius:
//                                                               BorderRadius
//                                                                   .circular(5),
//                                                           boxShadow: [
//                                                             BoxShadow(
//                                                               offset: Offset(
//                                                                   12, 11),
//                                                               blurRadius: 15,
//                                                               color: Color(
//                                                                       0xffaaaaaa)
//                                                                   .withOpacity(
//                                                                       0.1),
//                                                             )
//                                                           ],
//                                                         ),
//                                                         //
//                                                         child: Center(
//                                                           child: Icon(
//                                                               Icons
//                                                                   .file_copy_outlined,
//                                                               color: Color(
//                                                                   0xFFD60808),
//                                                               size: 25),
//                                                         ),
//                                                       ),
//                                                     )
//                                                   : SizedBox(),
//                                               (cmntvideoAttached == true)
//                                                   ? SizedBox(
//                                                       width: 30,
//                                                     )
//                                                   : SizedBox(),
//                                               (cmntvideoAttached == true)
//                                                   ? GestureDetector(
//                                                       onTap: () async {
//                                                         _launchInBrowser(
//                                                             cmntreferenceVideoAtttachedURL);
//                                                       },
//                                                       onLongPress: () {
//                                                         setState(() {
//                                                           cmntvideoAttached =
//                                                               false;
//                                                           cmntreferenceVideoAtttachedURL =
//                                                               "";
//                                                         });
//                                                       },
//                                                       child: Container(
//                                                         width: 40,
//                                                         height: 40,
//                                                         decoration:
//                                                             BoxDecoration(
//                                                           color:
//                                                               Color(0xffffffff),
//                                                           borderRadius:
//                                                               BorderRadius
//                                                                   .circular(5),
//                                                           boxShadow: [
//                                                             BoxShadow(
//                                                               offset: Offset(
//                                                                   12, 11),
//                                                               blurRadius: 15,
//                                                               color: Color(
//                                                                       0xffaaaaaa)
//                                                                   .withOpacity(
//                                                                       0.1),
//                                                             )
//                                                           ],
//                                                         ),
//                                                         //
//                                                         child: Center(
//                                                           child: Icon(
//                                                               Icons
//                                                                   .video_call_outlined,
//                                                               color: Color(
//                                                                   0xFFD60808),
//                                                               size: 25),
//                                                         ),
//                                                       ),
//                                                     )
//                                                   : SizedBox(),
//                                               (cmntaudioAttached == true)
//                                                   ? SizedBox(
//                                                       width: 30,
//                                                     )
//                                                   : SizedBox(),
//                                               (cmntaudioAttached == true)
//                                                   ? GestureDetector(
//                                                       onTap: () async {
//                                                         _launchInBrowser(
//                                                             cmntreferenceAudioAtttachedURL);
//                                                       },
//                                                       onLongPress: () {
//                                                         setState(() {
//                                                           cmntaudioAttached =
//                                                               false;
//                                                           cmntreferenceAudioAtttachedURL =
//                                                               "";
//                                                         });
//                                                       },
//                                                       child: Container(
//                                                         width: 40,
//                                                         height: 40,
//                                                         decoration:
//                                                             BoxDecoration(
//                                                           color:
//                                                               Color(0xffffffff),
//                                                           borderRadius:
//                                                               BorderRadius
//                                                                   .circular(5),
//                                                           boxShadow: [
//                                                             BoxShadow(
//                                                               offset: Offset(
//                                                                   12, 11),
//                                                               blurRadius: 15,
//                                                               color: Color(
//                                                                       0xffaaaaaa)
//                                                                   .withOpacity(
//                                                                       0.1),
//                                                             )
//                                                           ],
//                                                         ),
//                                                         //
//                                                         child: Center(
//                                                           child: Icon(
//                                                               Icons
//                                                                   .audiotrack_outlined,
//                                                               color: Color(
//                                                                   0xFFD60808),
//                                                               size: 25),
//                                                         ),
//                                                       ),
//                                                     )
//                                                   : SizedBox(),
//                                               (cmnttextAttached == true)
//                                                   ? SizedBox(
//                                                       width: 30,
//                                                     )
//                                                   : SizedBox(),
//                                               (cmnttextAttached == true)
//                                                   ? GestureDetector(
//                                                       onTap: () {
//                                                         pickTextReferenceDialog(
//                                                             cmntreferenceTextAtttached);
//                                                       },
//                                                       onLongPress: () {
//                                                         setState(() {
//                                                           cmnttextAttached =
//                                                               false;
//                                                         });
//                                                       },
//                                                       child: Container(
//                                                         width: 40,
//                                                         height: 40,
//                                                         decoration:
//                                                             BoxDecoration(
//                                                           color:
//                                                               Color(0xffffffff),
//                                                           borderRadius:
//                                                               BorderRadius
//                                                                   .circular(5),
//                                                           boxShadow: [
//                                                             BoxShadow(
//                                                               offset: Offset(
//                                                                   12, 11),
//                                                               blurRadius: 15,
//                                                               color: Color(
//                                                                       0xffaaaaaa)
//                                                                   .withOpacity(
//                                                                       0.1),
//                                                             )
//                                                           ],
//                                                         ),
//                                                         //
//                                                         child: Center(
//                                                           child: Icon(
//                                                               Icons
//                                                                   .text_fields_outlined,
//                                                               color: Color(
//                                                                   0xFFD60808),
//                                                               size: 25),
//                                                         ),
//                                                       ),
//                                                     )
//                                                   : SizedBox(),
//                                             ],
//                                           )
//                                         : SizedBox(),
//                                     SizedBox(
//                                       height: 20,
//                                     ),
//                                     Row(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.start,
//                                       children: [
//                                         Text(
//                                           'Add Reference   ',
//                                           style: TextStyle(
//                                             fontFamily: 'Nunito Sans',
//                                             fontSize: 15,
//                                             color:
//                                                 Color.fromRGBO(88, 165, 196, 1),
//                                             fontWeight: FontWeight.w600,
//                                           ),
//                                         ),
//                                         Text(
//                                           '(Optional)',
//                                           style: TextStyle(
//                                             fontFamily: 'Nunito Sans',
//                                             fontSize: 12,
//                                             color: Colors.black45,
//                                             fontWeight: FontWeight.w600,
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                     SizedBox(height: 10),
//                                     _cmntreference(
//                                         context, qIndex, ansSelectID, ansIndex),
//                                   ],
//                                 ),
//                               ),
//                         SizedBox(height: 20),
//                         cmntPostVisibility == true
//                             ? Container(
//                                 decoration: BoxDecoration(
//                                   color: Colors.white,
//                                   borderRadius: BorderRadius.circular(5),
//                                   boxShadow: [
//                                     BoxShadow(
//                                       color: Colors.deepPurple.withOpacity(0.1),
//                                       spreadRadius: 5,
//                                       blurRadius: 10,
//                                     ),
//                                   ],
//                                 ),
//                                 child: ElevatedButton(
//                                   child: Container(
//                                       width: double.infinity,
//                                       height: 40,
//                                       child: Center(
//                                           child: Text("Post",
//                                               style: TextStyle(
//                                                   fontSize: 15,
//                                                   fontWeight: FontWeight.bold,
//                                                   color: ((comment != "") ||
//                                                           (cmntImageURL != ""))
//                                                       ? Colors.white
//                                                       : Colors.grey[400])))),
//                                   onPressed: () async {
//                                     if ((comment != "") ||
//                                         (cmntImageURL != "")) {
//                                       Dialogs.showLoadingDialog(
//                                           context, _keyLoader);
//                                       String cmtID = "";
//                                       setState(() {
//                                         tagids.clear();
//                                         tagedUsersName.clear();
//                                         print(markupptext);
//                                         for (int l = 0;
//                                             l < markupptext.length - 4;
//                                             l++) {
//                                           int k = l;
//                                           if (markupptext.substring(k, k + 1) ==
//                                               "@") {
//                                             String test1 =
//                                                 markupptext.substring(k);
//                                             print(
//                                                 "tagid ${test1.substring(4, test1.indexOf("__]"))}");
//                                             tagids.add(test1.substring(
//                                                 4, test1.indexOf("__]")));
//                                           }

//                                           if (markupptext.substring(k, k + 3) ==
//                                               "(__") {
//                                             String test2 =
//                                                 markupptext.substring(k);
//                                             print(test2);
//                                             tagedUsersName.add(test2.substring(
//                                                 3, test2.indexOf("__)")));
//                                             print(
//                                                 "tagusername ${test2.substring(3, test2.indexOf("__)"))}");
//                                           }
//                                         }
//                                         print(tagedUsersName);
//                                         print(tagids);
//                                         cmtID = "cmnt" +
//                                             _currentUserId +
//                                             comparedate;
//                                         data = [
//                                           cmtID,
//                                           allAnswersQIDwise[ansSelectID]
//                                               [ansIndex]["answer_id"],
//                                           allQuestionsData[qIndex]
//                                               ["question_id"],
//                                           _currentUserId,
//                                           0,
//                                           0,
//                                           comment != ""
//                                               ? comment
//                                               : cmntImageURL != ""
//                                                   ? cmntImageURL
//                                                   : "na",
//                                           commentType,
//                                           cmntreferenceNotesAtttachedURL,
//                                           cmntreferenceAudioAtttachedURL,
//                                           cmntreferenceTextAtttached,
//                                           cmntreferenceVideoAtttachedURL,
//                                           comparedate
//                                         ];
//                                       });
//                                       // if (tagids.isNotEmpty) {
//                                       //   for (int i = 0;
//                                       //       i < tagids.length;
//                                       //       i++) {
//                                       //     await dataLoad
//                                       //         .postUsertaggedInAnswerData(
//                                       //             [ansID, tagids[i]]);
//                                       //   }
//                                       // }
//                                       bool x = await dataLoad
//                                           .postUserAnswerCommentData(data);
//                                       if (x == true) {
//                                         setState(() {
//                                           commentCountAns[ansSelectID]
//                                                   [ansIndex] =
//                                               commentCountAns[ansSelectID]
//                                                       [ansIndex] +
//                                                   1;
//                                         });
//                                         dataLoad.updateAnswerCountData([
//                                           allAnswersQIDwise[ansSelectID]
//                                               [ansIndex]["answer_id"],
//                                           _currentUserId,
//                                           commentCountAns[ansSelectID]
//                                                   [ansIndex] +
//                                               1,
//                                           likeCountAns[ansSelectID][ansIndex],
//                                           upvoteCountAns[ansSelectID]
//                                                   [ansIndex] +
//                                               1,
//                                           downVoteCountAns[ansSelectID]
//                                                   [ansIndex] -
//                                               1
//                                         ]);
//                                         ////////////////////////////notification//////////////////////////////////////
//                                         String notify_id =
//                                             "ntf${allAnswersQIDwise[ansSelectID][ansIndex]["answer_id"]}$comparedate";
//                                         notifyCRUD.sendNotification([
//                                           notify_id,
//                                           "commentpost",
//                                           "reply",
//                                           _currentUserId,
//                                           allAnswersQIDwise[ansSelectID]
//                                               [ansIndex]["user_id"],
//                                           countData!.value["usertoken"][
//                                                   allAnswersQIDwise[ansSelectID]
//                                                       [ansIndex]["user_id"]]
//                                               ["tokenid"],
//                                           "You got one comment!",
//                                           "${userDataDB!.get("first_name")} ${userDataDB!.get("last_name")} commented on your answer.",
//                                           allQuestionsData[qIndex]
//                                               ["question_id"],
//                                           "question",
//                                           "false",
//                                           comparedate,
//                                           "add"
//                                         ]);
//                                         //////////////////////////////////////////////////////////////////////////
//                                         ElegantNotification.success(
//                                           title: Text("Congrats,"),
//                                           description: Text(
//                                               "Your comment posted successfully."),
//                                         );

//                                         // _update_count(
//                                         //     _currentUserId,
//                                         //     allQuestionsData[qIndex]
//                                         //         ["question_id"],
//                                         //     "answer",
//                                         //     "+",
//                                         //     qIndex);
//                                         cmntPostVisibility = false;
//                                         comment = "";
//                                         cmntreferenceNotesAtttachedURL = "";
//                                         cmntreferenceVideoAtttachedURL = "";
//                                         cmntreferenceAudioAtttachedURL = "";
//                                         cmntreferenceTextAtttached = "";
//                                         cmntnotesAttached = false;
//                                         cmntvideoAttached = false;
//                                         cmntaudioAttached = false;
//                                         cmnttextAttached = false;
//                                         base64Image = "";
//                                         tagcount = 0;
//                                         tagids = [];
//                                         tagedUsersName = [];
//                                         markupptext = '';
//                                         tagedString = "";
//                                         _get_all_questions_posted();
//                                         _get_all_answers_posted();
//                                         _get_all_answers_comment_posted();
//                                         Navigator.of(_keyLoader.currentContext!,
//                                                 rootNavigator: true)
//                                             .pop();
//                                         Navigator.of(context).pop();
//                                       } else {
//                                         ElegantNotification.error(
//                                           title: Text("Error..."),
//                                           description: Text("Something wrong."),
//                                         );
//                                       }
//                                     }
//                                   },
//                                   style: ElevatedButton.styleFrom(
//                                     primary: ((comment != "") ||
//                                             (cmntImageURL != ""))
//                                         ? active
//                                         : Colors.white54,
//                                     onPrimary: Colors.white,
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(5),
//                                     ),
//                                   ),
//                                 ),
//                               )
//                             : SizedBox(),
//                       ],
//                     ),
//                   ),
//                 ),
//               );
//             }));
//   }

//   _cmntreference(
//       BuildContext context, int qIndex, int ansSelectID, int ansIndex) {
//     return Container(
//         height: 80,
//         child: ListView(
//           scrollDirection: Axis.horizontal,
//           physics: BouncingScrollPhysics(),
//           children: [
//             InkWell(
//               onTap: () async {
//                 _cmntpickNotes(context, qIndex, ansSelectID, ansIndex);
//               },
//               child: Container(
//                 width: 70,
//                 height: 70,
//                 margin: EdgeInsets.only(right: 20, left: 20),
//                 padding: EdgeInsets.all(8),
//                 decoration: BoxDecoration(
//                   color: cmntnotesAttached == true
//                       ? Color.fromRGBO(88, 165, 196, 1)
//                       : Colors.white,
//                   borderRadius: BorderRadius.circular(4),
//                 ),
//                 child: Center(
//                     child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(Icons.note_add_outlined,
//                         color: cmntnotesAttached == false
//                             ? Color.fromRGBO(88, 165, 196, 1)
//                             : Colors.white,
//                         size: 25),
//                     SizedBox(height: 10),
//                     Text(
//                       "Notes",
//                       style: TextStyle(
//                         fontFamily: 'Nunito Sans',
//                         fontSize: 12,
//                         color: cmntnotesAttached == false
//                             ? Color.fromRGBO(88, 165, 196, 1)
//                             : Colors.white,
//                       ),
//                     )
//                   ],
//                 )),
//               ),
//             ),
//             InkWell(
//               onTap: () async {
//                 _cmntpickVideo(context, qIndex, ansSelectID, ansIndex);
//               },
//               child: Container(
//                 width: 70,
//                 height: 70,
//                 margin: EdgeInsets.only(right: 20, left: 20),
//                 padding: EdgeInsets.all(8),
//                 decoration: BoxDecoration(
//                   color: cmntvideoAttached == true
//                       ? Color.fromRGBO(88, 165, 196, 1)
//                       : Colors.white,
//                   borderRadius: BorderRadius.circular(4),
//                 ),
//                 child: Center(
//                     child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(Icons.video_label_outlined,
//                         color: cmntvideoAttached == false
//                             ? Color.fromRGBO(88, 165, 196, 1)
//                             : Colors.white,
//                         size: 25),
//                     SizedBox(height: 10),
//                     Text(
//                       "Video\nExplainer",
//                       style: TextStyle(
//                         fontFamily: 'Nunito Sans',
//                         fontSize: 12,
//                         color: cmntvideoAttached == false
//                             ? Color.fromRGBO(88, 165, 196, 1)
//                             : Colors.white,
//                       ),
//                       textAlign: TextAlign.center,
//                     )
//                   ],
//                 )),
//               ),
//             ),
//             InkWell(
//               onTap: () {
//                 _cmntpickAudio(context, qIndex, ansSelectID, ansIndex);
//               },
//               child: Container(
//                 width: 70,
//                 height: 70,
//                 margin: EdgeInsets.only(right: 20, left: 20),
//                 padding: EdgeInsets.all(8),
//                 decoration: BoxDecoration(
//                   color: cmntaudioAttached == true
//                       ? Color.fromRGBO(88, 165, 196, 1)
//                       : Colors.white,
//                   borderRadius: BorderRadius.circular(4),
//                 ),
//                 child: Center(
//                     child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(Icons.music_note_outlined,
//                         color: cmntaudioAttached == false
//                             ? Color.fromRGBO(88, 165, 196, 1)
//                             : Colors.white,
//                         size: 25),
//                     SizedBox(height: 10),
//                     Text(
//                       "Audio\nExplainer",
//                       style: TextStyle(
//                         fontFamily: 'Nunito Sans',
//                         fontSize: 12,
//                         color: cmntaudioAttached == false
//                             ? Color.fromRGBO(88, 165, 196, 1)
//                             : Colors.white,
//                       ),
//                       textAlign: TextAlign.center,
//                     )
//                   ],
//                 )),
//               ),
//             ),
//             InkWell(
//               onTap: () {
//                 cmntpickTextReferenceDialog("");
//               },
//               child: Container(
//                 width: 70,
//                 height: 70,
//                 margin: EdgeInsets.only(right: 20, left: 20),
//                 padding: EdgeInsets.all(8),
//                 decoration: BoxDecoration(
//                   color: cmnttextAttached == true
//                       ? Color.fromRGBO(88, 165, 196, 1)
//                       : Colors.white,
//                   borderRadius: BorderRadius.circular(4),
//                 ),
//                 child: Center(
//                     child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(Icons.bookmark_border_outlined,
//                         color: cmnttextAttached == false
//                             ? Color.fromRGBO(88, 165, 196, 1)
//                             : Colors.white,
//                         size: 25),
//                     SizedBox(height: 10),
//                     Text(
//                       "Reference",
//                       style: TextStyle(
//                         fontFamily: 'Nunito Sans',
//                         fontSize: 12,
//                         color: cmnttextAttached == false
//                             ? Color.fromRGBO(88, 165, 196, 1)
//                             : Colors.white,
//                       ),
//                     )
//                   ],
//                 )),
//               ),
//             ),
//           ],
//         ));
//   }

//   void _pickImageComment(
//       BuildContext context, int qIndex, int ansSelectID, int ansIndex) async {
//     FilePickerResult? result = await FilePicker.platform.pickFiles();
//     if (result != null) {
//       Dialogs.showLoadingDialog(context, _keyLoader);

//       Uint8List? file = result.files.first.bytes;
//       String fileName = result.files.first.name;
//       UploadTask task = FirebaseStorage.instance
//           .ref()
//           .child("userAnswer/$_currentUserId/$fileName")
//           .putData(file!);

//       task.snapshotEvents.listen((event) async {
//         setState(() {
//           progress = ((event.bytesTransferred.toDouble() /
//                       event.totalBytes.toDouble()) *
//                   100)
//               .roundToDouble();
//         });
//         if (progress == 100) {
//           print(progress);

//           String downloadURL = await FirebaseStorage.instance
//               .ref("userAnswer/$_currentUserId/$fileName")
//               .getDownloadURL();
//           if (downloadURL != null) {
//             Navigator.of(_keyLoader.currentContext!, rootNavigator: true)
//                 .pop(); //close the dialoge
//             setState(() {
//               cmntImageURL = downloadURL;
//               print(downloadURL);
//               progress = 0.0;
//               cmntPostVisibility = true;
//             });

//             Navigator.of(context).pop();

//             _addCommentPostDialog(qIndex, ansSelectID, ansIndex);
//           }
//         }
//       });
//     }
//   }

//   void _cmntpickNotes(
//       BuildContext context, int qIndex, int ansSelectID, int ansIndex) async {
//     FilePickerResult? result = await FilePicker.platform.pickFiles();
//     if (result != null) {
//       Dialogs.showLoadingDialog(context, _keyLoader);

//       Uint8List? file = result.files.first.bytes;
//       String fileName = result.files.first.name;
//       UploadTask task = FirebaseStorage.instance
//           .ref()
//           .child("userNotesReference/$_currentUserId/$fileName")
//           .putData(file!);

//       task.snapshotEvents.listen((event) async {
//         setState(() {
//           progress = ((event.bytesTransferred.toDouble() /
//                       event.totalBytes.toDouble()) *
//                   100)
//               .roundToDouble();
//         });
//         if (progress == 100) {
//           print(progress);

//           String downloadURL = await FirebaseStorage.instance
//               .ref("userNotesReference/$_currentUserId/$fileName")
//               .getDownloadURL();
//           if (downloadURL != null) {
//             Navigator.of(_keyLoader.currentContext!, rootNavigator: true)
//                 .pop(); //close the dialoge
//             setState(() {
//               cmntreferenceNotesAtttachedURL = downloadURL;
//               print(downloadURL);
//               cmntnotesAttached = true;
//               progress = 0.0;
//             });

//             Navigator.of(context).pop();
//             _addCommentPostDialog(qIndex, ansSelectID, ansIndex);
//             ElegantNotification.success(
//               title: Text("Congrats,"),
//               description: Text("You attatched note successfully."),
//             );
//           }
//         }
//       });
//     }
//   }

//   void _cmntpickVideo(
//       BuildContext context, int qIndex, int ansSelectID, int ansIndex) async {
//     FilePickerResult? result = await FilePicker.platform.pickFiles();
//     if (result != null) {
//       Uint8List? file = result.files.first.bytes;
//       String fileName = result.files.first.name;
//       Dialogs.showLoadingDialog(context, _keyLoader);
//       UploadTask task = FirebaseStorage.instance
//           .ref()
//           .child("userVideoReference/$_currentUserId/$fileName")
//           .putData(file!);

//       task.snapshotEvents.listen((event) async {
//         setState(() {
//           progress = ((event.bytesTransferred.toDouble() /
//                       event.totalBytes.toDouble()) *
//                   100)
//               .roundToDouble();
//         });
//         if (progress == 100) {
//           print(progress);

//           String downloadURL = await FirebaseStorage.instance
//               .ref("userVideoReference/$_currentUserId/$fileName")
//               .getDownloadURL();
//           if (downloadURL != null) {
//             Navigator.of(_keyLoader.currentContext!, rootNavigator: true)
//                 .pop(); //close the dialoge
//             setState(() {
//               cmntreferenceVideoAtttachedURL = downloadURL;
//               print(downloadURL);
//               cmntvideoAttached = true;
//               progress = 0.0;
//             });

//             Navigator.of(context).pop();
//             _addCommentPostDialog(qIndex, ansSelectID, ansIndex);
//           }
//         }
//       });
//     }
//   }

//   void _cmntpickAudio(
//       BuildContext context, int qIndex, int ansSelectID, int ansIndex) async {
//     FilePickerResult? result = await FilePicker.platform.pickFiles();
//     if (result != null) {
//       Uint8List? file = result.files.first.bytes;
//       String fileName = result.files.first.name;
//       Dialogs.showLoadingDialog(context, _keyLoader);
//       UploadTask task = FirebaseStorage.instance
//           .ref()
//           .child("userAudioReference/$_currentUserId/$fileName")
//           .putData(file!);

//       task.snapshotEvents.listen((event) async {
//         setState(() {
//           progress = ((event.bytesTransferred.toDouble() /
//                       event.totalBytes.toDouble()) *
//                   100)
//               .roundToDouble();
//         });
//         if (progress == 100) {
//           print(progress);

//           String downloadURL = await FirebaseStorage.instance
//               .ref("userAudioReference/$_currentUserId/$fileName")
//               .getDownloadURL();
//           if (downloadURL != null) {
//             Navigator.of(_keyLoader.currentContext!, rootNavigator: true)
//                 .pop(); //close the dialoge
//             setState(() {
//               cmntreferenceVideoAtttachedURL = downloadURL;
//               print(downloadURL);
//               cmntaudioAttached = true;
//               progress = 0.0;
//             });

//             Navigator.of(context).pop();
//             ElegantNotification.success(
//               title: Text("Congrats,"),
//               description: Text("You attatched audio file successfully."),
//             );
//             _addCommentPostDialog(qIndex, ansSelectID, ansIndex);
//           }
//         }
//       });
//     }
//   }

//   void cmntpickTextReferenceDialog(String x) {
//     showDialog(
//         context: context,
//         barrierColor: Colors.grey.withOpacity(0.2),
//         builder: (_) => StatefulBuilder(builder: (context, setState) {
//               return AlertDialog(
//                   shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(20.0)),
//                   content: Container(
//                     height: 200,
//                     child: Column(
//                       children: [
//                         SizedBox(height: 30),
//                         Container(
//                           padding:
//                               EdgeInsets.only(left: 15, right: 15, bottom: 5),
//                           child: TextFormField(
//                             maxLines: 4,
//                             keyboardType: TextInputType.text,
//                             cursorColor: Color.fromRGBO(88, 165, 196, 1),
//                             style: TextStyle(
//                                 fontSize: 12,
//                                 color: Color.fromRGBO(88, 165, 196, 1),
//                                 fontWeight: FontWeight.w500),
//                             onChanged: (val) {
//                               setState(() => cmntreferenceTextAtttached = val);
//                             },
//                             decoration: InputDecoration(
//                               fillColor: Color.fromRGBO(245, 245, 245, 1),
//                               filled: true,
//                               counterText: '',
//                               hintText:
//                                   'Add reference like Book Name, Page No.',
//                               hintStyle: TextStyle(
//                                   fontSize: 13,
//                                   color: Colors.grey[350],
//                                   fontWeight: FontWeight.w600),
//                               alignLabelWithHint: false,
//                               contentPadding: new EdgeInsets.symmetric(
//                                   vertical: 10.0, horizontal: 10),
//                               errorStyle: TextStyle(
//                                   color: Color.fromRGBO(240, 20, 41, 1)),
//                               focusColor: Color.fromRGBO(88, 165, 196, 1),
//                               focusedBorder: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(10),
//                                 borderSide: BorderSide(
//                                     color: Color.fromRGBO(245, 245, 245, 1)),
//                               ),
//                               enabledBorder: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(10),
//                                 borderSide: BorderSide(
//                                   color: Color.fromRGBO(245, 245, 245, 1),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                         SizedBox(height: 20),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Container(
//                               padding: EdgeInsets.all(5),
//                               width: 160,
//                               child: RaisedButton(
//                                   shape: RoundedRectangleBorder(
//                                       side: BorderSide(
//                                           color:
//                                               Color.fromRGBO(88, 165, 196, 1)),
//                                       borderRadius:
//                                           BorderRadius.circular(100.0)),
//                                   color: Color.fromRGBO(88, 165, 196, 1),
//                                   splashColor: Color.fromRGBO(88, 165, 196, 1),
//                                   child: Center(
//                                       child: Text(
//                                     'Save',
//                                     style: GoogleFonts.raleway(
//                                         color: Colors.white,
//                                         fontWeight: FontWeight.w800,
//                                         fontSize: 14),
//                                   )),
//                                   onPressed: () {
//                                     if (ansreferenceTextAtttached != "") {
//                                       setState(() {
//                                         anstextAttached = true;
//                                         Navigator.pop(context);
//                                       });
//                                     }
//                                   }),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ));
//             }));
//   }

//   //Reply Post

//   bool replyPostVisibility = false;
//   String replyType = 'text';
//   String reply = "";
//   String replyImageURL = "";

//   void _addreplyPostDialog(int qIndex, int ansSelectID, int ansIndex,
//       int cmntSelectID, int cmntIndex) {
//     showDialog(
//         context: context,
//         barrierColor: Colors.grey.withOpacity(0.2),
//         barrierDismissible: false,
//         builder: (_) => StatefulBuilder(builder: (context, setState) {
//               return AlertDialog(
//                 contentPadding: EdgeInsets.all(20),
//                 shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10.0)),
//                 title: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         SizedBox(width: 30),
//                         Text(
//                           "Post your reply",
//                           style: TextStyle(
//                             fontSize: 20,
//                             color: Color(0xCB000000),
//                             fontWeight: FontWeight.w900,
//                           ),
//                         ),
//                         IconButton(
//                           onPressed: () {
//                             replyPostVisibility = false;
//                             replyType = 'text';
//                             reply = "";
//                             replyImageURL = "";
//                             Navigator.pop(context);
//                           },
//                           icon: Tab(
//                               child: Icon(Icons.cancel_rounded,
//                                   color: Colors.black45, size: 25)),
//                         )
//                       ],
//                     ),
//                     SizedBox(height: 20),
//                     Container(height: 1, width: 500, color: Colors.grey[200]),
//                   ],
//                 ),
//                 content: Container(
//                   height: 470,
//                   width: 500,
//                   child: SingleChildScrollView(
//                     child: Column(
//                       children: [
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Text(
//                                 replyPostVisibility == false
//                                     ? "Choose reply type"
//                                     : "Post reply",
//                                 style: TextStyle(
//                                     fontSize: 16, color: Colors.black54)),
//                             replyPostVisibility == true
//                                 ? IconButton(
//                                     onPressed: () {
//                                       if (replyPostVisibility == true) {
//                                         setState(() {
//                                           replyPostVisibility = false;
//                                         });
//                                       }
//                                     },
//                                     icon: Icon(Icons.arrow_back_ios,
//                                         color: Colors.black54, size: 22))
//                                 : SizedBox(width: 20)
//                           ],
//                         ),
//                         SizedBox(height: 10),
//                         replyPostVisibility == true
//                             ? Container(
//                                 margin: EdgeInsets.fromLTRB(20, 0, 20, 0),
//                                 padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
//                                 decoration: BoxDecoration(
//                                     color: Color.fromRGBO(242, 246, 248, 1),
//                                     borderRadius: BorderRadius.circular(10)),
//                                 child: allAnscmntANSIDwise[cmntSelectID]
//                                             [cmntIndex]["comment_type"] ==
//                                         "text"
//                                     ? InkWell(
//                                         child: Container(
//                                           width: MediaQuery.of(context)
//                                                   .size
//                                                   .width -
//                                               30,
//                                           margin:
//                                               EdgeInsets.fromLTRB(10, 10, 0, 2),
//                                           child: ReadMoreText(
//                                             allAnscmntANSIDwise[cmntSelectID]
//                                                 [cmntIndex]["comment"],
//                                             textAlign: TextAlign.left,
//                                             trimLines: 4,
//                                             colorClickableText:
//                                                 Color(0xff0962ff),
//                                             trimMode: TrimMode.Line,
//                                             trimCollapsedText: 'read more',
//                                             trimExpandedText: 'Show less',
//                                             style: TextStyle(
//                                               fontFamily: 'Nunito Sans',
//                                               fontSize: 16,
//                                               color:
//                                                   Color.fromRGBO(0, 0, 0, 0.8),
//                                               fontWeight: FontWeight.w400,
//                                             ),
//                                             lessStyle: TextStyle(
//                                               fontFamily: 'Nunito Sans',
//                                               fontSize: 12,
//                                               color: Color(0xff0962ff),
//                                               fontWeight: FontWeight.w700,
//                                             ),
//                                             moreStyle: TextStyle(
//                                               fontFamily: 'Nunito Sans',
//                                               fontSize: 12,
//                                               color: Color(0xff0962ff),
//                                               fontWeight: FontWeight.w700,
//                                             ),
//                                           ),
//                                         ),
//                                       )
//                                     : InkWell(
//                                         child: Container(
//                                           margin: EdgeInsets.all(5),
//                                           child: Image.network(
//                                               allAnscmntANSIDwise[cmntSelectID]
//                                                   [cmntIndex]["comment"],
//                                               height: 200,
//                                               fit: BoxFit.fill),
//                                         ),
//                                       ),
//                               )
//                             : SizedBox(),
//                         SizedBox(height: 10),
//                         replyPostVisibility == false
//                             ? Container(
//                                 height: 350,
//                                 margin: EdgeInsets.fromLTRB(20, 0, 20, 0),
//                                 child: Column(
//                                   children: [
//                                     SizedBox(
//                                       height: 10,
//                                     ),
//                                     SizedBox(
//                                       height: 30,
//                                     ),
//                                     Row(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.spaceEvenly,
//                                       children: [
//                                         InkWell(
//                                           onTap: () {
//                                             setState(() {
//                                               replyType = "text";
//                                               replyPostVisibility = true;
//                                             });
//                                           },
//                                           child: Column(
//                                             children: [
//                                               Image.network(
//                                                   "https://firebasestorage.googleapis.com/v0/b/hys-pro-41c66.appspot.com/o/assets%2Ftyping.gif?alt=media&token=1a4b65b2-c497-438b-8c3a-a69dcfc7f67d",
//                                                   height: 100,
//                                                   width: 100),
//                                               SizedBox(
//                                                 height: 7,
//                                               ),
//                                               Text(
//                                                 "Keyboard",
//                                                 style: TextStyle(
//                                                   fontFamily: 'Nunito Sans',
//                                                   fontSize: 15,
//                                                   color: Color(0xff0C2551),
//                                                   fontWeight: FontWeight.w700,
//                                                 ),
//                                                 textAlign: TextAlign.center,
//                                               )
//                                             ],
//                                           ),
//                                         ),
//                                         InkWell(
//                                           onTap: () {
//                                             setState(() {
//                                               replyType = "image";
//                                               _pickImagereply(
//                                                   context,
//                                                   qIndex,
//                                                   ansSelectID,
//                                                   ansIndex,
//                                                   cmntSelectID,
//                                                   cmntIndex);
//                                             });
//                                           },
//                                           child: Column(
//                                             children: [
//                                               Image.network(
//                                                   "https://firebasestorage.googleapis.com/v0/b/hys-pro-41c66.appspot.com/o/assets%2Fgallery.png?alt=media&token=09a32fa6-5e7c-4139-94e5-d4d74e5f5d6a",
//                                                   height: 100,
//                                                   width: 100),
//                                               SizedBox(
//                                                 height: 7,
//                                               ),
//                                               Text(
//                                                 "Image",
//                                                 style: TextStyle(
//                                                   fontFamily: 'Nunito Sans',
//                                                   fontSize: 15,
//                                                   color: Color(0xff0C2551),
//                                                   fontWeight: FontWeight.w700,
//                                                 ),
//                                                 textAlign: TextAlign.center,
//                                               )
//                                             ],
//                                           ),
//                                         )
//                                       ],
//                                     ),
//                                   ],
//                                 ),
//                               )
//                             : Container(
//                                 height: 350,
//                                 margin: EdgeInsets.fromLTRB(20, 0, 20, 0),
//                                 child: ListView(
//                                   physics: BouncingScrollPhysics(),
//                                   children: [
//                                     SizedBox(
//                                       height: 20,
//                                     ),
//                                     replyType == "text"
//                                         ? Container(
//                                             child: TextFormField(
//                                               maxLines: 10,
//                                               initialValue: reply,
//                                               keyboardType: TextInputType.text,
//                                               cursorColor: Color.fromRGBO(
//                                                   88, 165, 196, 1),
//                                               style: TextStyle(
//                                                   fontSize: 16,
//                                                   color: Color.fromRGBO(
//                                                       88, 165, 196, 1),
//                                                   fontWeight: FontWeight.w500),
//                                               validator: (val) => ((val!
//                                                       .isEmpty))
//                                                   ? 'Leave your reply here, you can\'t kept it blank'
//                                                   : null,
//                                               onChanged: (val) {
//                                                 setState(() => reply = val);
//                                               },
//                                               decoration: InputDecoration(
//                                                 fillColor: Color.fromRGBO(
//                                                     245, 245, 245, 1),
//                                                 filled: true,
//                                                 counterText: '',
//                                                 hintText: 'Your reply...',
//                                                 hintStyle: TextStyle(
//                                                     fontSize: 18,
//                                                     color: Colors.grey[300],
//                                                     fontWeight:
//                                                         FontWeight.w600),
//                                                 alignLabelWithHint: false,
//                                                 contentPadding:
//                                                     new EdgeInsets.symmetric(
//                                                         vertical: 10.0,
//                                                         horizontal: 10),
//                                                 errorStyle: TextStyle(
//                                                     color: Color.fromRGBO(
//                                                         240, 20, 41, 1)),
//                                                 focusColor: Color.fromRGBO(
//                                                     88, 165, 196, 1),
//                                                 focusedBorder:
//                                                     OutlineInputBorder(
//                                                   borderRadius:
//                                                       BorderRadius.circular(10),
//                                                   borderSide: BorderSide(
//                                                       color: Color.fromRGBO(
//                                                           245, 245, 245, 1)),
//                                                 ),
//                                                 enabledBorder:
//                                                     OutlineInputBorder(
//                                                   borderRadius:
//                                                       BorderRadius.circular(10),
//                                                   borderSide: BorderSide(
//                                                     color: Color.fromRGBO(
//                                                         245, 245, 245, 1),
//                                                   ),
//                                                 ),
//                                               ),
//                                             ),
//                                           )
//                                         : Container(
//                                             height: 100,
//                                             child: CachedNetworkImage(
//                                               imageUrl: replyImageURL,
//                                               fit: BoxFit.contain,
//                                               placeholder: (context, url) =>
//                                                   Container(
//                                                 height: 30,
//                                                 width: 30,
//                                                 child: Image.network(
//                                                   "https://firebasestorage.googleapis.com/v0/b/hys-pro-41c66.appspot.com/o/assets%2Floadingimg.gif?alt=media&token=4ca910f2-c584-4b3a-bbcb-2f1c01d93f67",
//                                                 ),
//                                               ),
//                                               errorWidget:
//                                                   (context, url, error) =>
//                                                       Icon(Icons.error),
//                                             ),
//                                           ),
//                                     SizedBox(
//                                       height: 20,
//                                     ),
//                                     Container(
//                                       height: 50,
//                                       width: 400,
//                                       child: FlutterMentions(
//                                         key: key,
//                                         keyboardType: TextInputType.text,
//                                         cursorColor:
//                                             Color.fromRGBO(88, 165, 196, 1),
//                                         decoration: InputDecoration(
//                                           fillColor:
//                                               Color.fromRGBO(245, 245, 245, 1),
//                                           filled: true,
//                                           counterText: '',
//                                           hintText: '@Tag someone here',
//                                           hintStyle: TextStyle(
//                                               fontSize: 13,
//                                               color: Colors.grey[350],
//                                               fontWeight: FontWeight.w600),
//                                           alignLabelWithHint: false,
//                                           contentPadding:
//                                               new EdgeInsets.symmetric(
//                                                   vertical: 10.0,
//                                                   horizontal: 10),
//                                           errorStyle: TextStyle(
//                                               color: Color.fromRGBO(
//                                                   240, 20, 41, 1)),
//                                           focusColor:
//                                               Color.fromRGBO(88, 165, 196, 1),
//                                           focusedBorder: OutlineInputBorder(
//                                             borderRadius:
//                                                 BorderRadius.circular(10),
//                                             borderSide: BorderSide(
//                                                 color: Color.fromRGBO(
//                                                     245, 245, 245, 1)),
//                                           ),
//                                           enabledBorder: OutlineInputBorder(
//                                             borderRadius:
//                                                 BorderRadius.circular(10),
//                                             borderSide: BorderSide(
//                                               color: Color.fromRGBO(
//                                                   245, 245, 245, 1),
//                                             ),
//                                           ),
//                                         ),
//                                         style: TextStyle(
//                                             fontSize: 12,
//                                             color:
//                                                 Color.fromRGBO(88, 165, 196, 1),
//                                             fontWeight: FontWeight.w500),
//                                         suggestionPosition:
//                                             SuggestionPosition.Bottom,
//                                         onMarkupChanged: (val) {
//                                           setState(() {
//                                             markupptext = val;
//                                           });
//                                         },
//                                         onEditingComplete: () {
//                                           setState(() {
//                                             tagids.clear();
//                                             for (int l = 0;
//                                                 l < markupptext.length;
//                                                 l++) {
//                                               int k = l;
//                                               if (markupptext.substring(
//                                                       k, k + 1) ==
//                                                   "@") {
//                                                 String test1 =
//                                                     markupptext.substring(k);
//                                                 tagids.add(test1.substring(
//                                                     4, test1.indexOf("__]")));
//                                               }
//                                             }
//                                             print(tagids);
//                                           });
//                                         },
//                                         onSuggestionVisibleChanged: (val) {
//                                           setState(() {
//                                             _showList = val;
//                                           });
//                                         },
//                                         onChanged: (val) {
//                                           setState(() {
//                                             tagedString = val;
//                                           });
//                                         },
//                                         onSearchChanged: (
//                                           trigger,
//                                           value,
//                                         ) {
//                                           print('again | $trigger | $value ');
//                                         },
//                                         hideSuggestionList: false,
//                                         minLines: 1,
//                                         maxLines: 5,
//                                         mentions: [
//                                           Mention(
//                                               trigger: r'@',
//                                               style: TextStyle(
//                                                 color: Color.fromRGBO(
//                                                     88, 165, 196, 1),
//                                               ),
//                                               matchAll: false,
//                                               data: _users,
//                                               suggestionBuilder: (data) {
//                                                 return Container(
//                                                   padding: EdgeInsets.all(10),
//                                                   decoration: BoxDecoration(
//                                                       color: Colors.white,
//                                                       border: Border(
//                                                           top: BorderSide(
//                                                               color: Color(
//                                                                   0xFFE0E1E4)))),
//                                                   child: Row(
//                                                     mainAxisAlignment:
//                                                         MainAxisAlignment.start,
//                                                     children: <Widget>[
//                                                       CircleAvatar(
//                                                         backgroundImage:
//                                                             NetworkImage(
//                                                           data['photo'],
//                                                         ),
//                                                       ),
//                                                       SizedBox(
//                                                         width: 20.0,
//                                                       ),
//                                                       Column(
//                                                         mainAxisAlignment:
//                                                             MainAxisAlignment
//                                                                 .start,
//                                                         crossAxisAlignment:
//                                                             CrossAxisAlignment
//                                                                 .start,
//                                                         children: <Widget>[
//                                                           Row(
//                                                             mainAxisAlignment:
//                                                                 MainAxisAlignment
//                                                                     .start,
//                                                             children: [
//                                                               Text(data[
//                                                                   'display']),
//                                                             ],
//                                                           ),
//                                                           SizedBox(
//                                                             height: 3,
//                                                           ),
//                                                           Row(
//                                                             mainAxisAlignment:
//                                                                 MainAxisAlignment
//                                                                     .start,
//                                                             children: [
//                                                               Text(
//                                                                 '${data['full_name']}',
//                                                                 style:
//                                                                     TextStyle(
//                                                                   color: Color(
//                                                                       0xFFAAABAD),
//                                                                   fontSize: 11,
//                                                                 ),
//                                                               ),
//                                                             ],
//                                                           ),
//                                                         ],
//                                                       )
//                                                     ],
//                                                   ),
//                                                 );
//                                               }),
//                                         ],
//                                       ),
//                                     ),
//                                     SizedBox(
//                                       height: 20,
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                         replyPostVisibility == true
//                             ? Container(
//                                 decoration: BoxDecoration(
//                                   color: Colors.white,
//                                   borderRadius: BorderRadius.circular(5),
//                                   boxShadow: [
//                                     BoxShadow(
//                                       color: Colors.deepPurple.withOpacity(0.1),
//                                       spreadRadius: 5,
//                                       blurRadius: 10,
//                                     ),
//                                   ],
//                                 ),
//                                 child: ElevatedButton(
//                                   child: Container(
//                                       width: double.infinity,
//                                       height: 40,
//                                       child: Center(
//                                           child: Text("Post",
//                                               style: TextStyle(
//                                                   fontSize: 15,
//                                                   fontWeight: FontWeight.bold,
//                                                   color: ((reply != "") ||
//                                                           (replyImageURL != ""))
//                                                       ? Colors.white
//                                                       : Colors.grey[400])))),
//                                   onPressed: () async {
//                                     if ((reply != "") ||
//                                         (replyImageURL != "")) {
//                                       Dialogs.showLoadingDialog(
//                                           context, _keyLoader);
//                                       String replyID = "";
//                                       setState(() {
//                                         tagids.clear();
//                                         tagedUsersName.clear();
//                                         print(markupptext);
//                                         for (int l = 0;
//                                             l < markupptext.length - 4;
//                                             l++) {
//                                           int k = l;
//                                           if (markupptext.substring(k, k + 1) ==
//                                               "@") {
//                                             String test1 =
//                                                 markupptext.substring(k);
//                                             print(
//                                                 "tagid ${test1.substring(4, test1.indexOf("__]"))}");
//                                             tagids.add(test1.substring(
//                                                 4, test1.indexOf("__]")));
//                                           }

//                                           if (markupptext.substring(k, k + 3) ==
//                                               "(__") {
//                                             String test2 =
//                                                 markupptext.substring(k);
//                                             print(test2);
//                                             tagedUsersName.add(test2.substring(
//                                                 3, test2.indexOf("__)")));
//                                             print(
//                                                 "tagusername ${test2.substring(3, test2.indexOf("__)"))}");
//                                           }
//                                         }
//                                         print(tagedUsersName);
//                                         print(tagids);
//                                         replyID = "reply" +
//                                             _currentUserId +
//                                             comparedate;
//                                         data = [
//                                           replyID,
//                                           allAnscmntANSIDwise[cmntSelectID]
//                                               [cmntIndex]["comment_id"],
//                                           allAnswersQIDwise[ansSelectID]
//                                               [ansIndex]["answer_id"],
//                                           allQuestionsData[qIndex]
//                                               ["question_id"],
//                                           _currentUserId,
//                                           reply != ""
//                                               ? reply
//                                               : replyImageURL != ""
//                                                   ? replyImageURL
//                                                   : "na",
//                                           replyType,
//                                           0,
//                                           comparedate
//                                         ];
//                                       });
//                                       // if (tagids.isNotEmpty) {
//                                       //   for (int i = 0;
//                                       //       i < tagids.length;
//                                       //       i++) {
//                                       //     await dataLoad
//                                       //         .postUsertaggedInAnswerData(
//                                       //             [ansID, tagids[i]]);
//                                       //   }
//                                       // }
//                                       bool x = await dataLoad
//                                           .postUserAnswerReplyData(data);
//                                       if (x == true) {
//                                         setState(() {
//                                           replyCountAnscmnt[cmntSelectID]
//                                                   [cmntIndex] =
//                                               replyCountAnscmnt[cmntSelectID]
//                                                       [cmntIndex] +
//                                                   1;
//                                         });
//                                         dataLoad.updateAnswerCommentCountData([
//                                           allAnscmntANSIDwise[cmntSelectID]
//                                               [cmntIndex]["comment_id"],
//                                           _currentUserId,
//                                           allAnscmntANSIDwise[cmntSelectID]
//                                               [cmntIndex]["like_count"],
//                                           allAnscmntANSIDwise[cmntSelectID]
//                                                   [cmntIndex]["reply_count"] +
//                                               1
//                                         ]);
//                                         ////////////////////////////notification//////////////////////////////////////
//                                         String notify_id =
//                                             "ntf${allQuestionsData[qIndex]["user_id"]}$comparedate";
//                                         notifyCRUD.sendNotification([
//                                           notify_id,
//                                           "replypost",
//                                           "comment",
//                                           _currentUserId,
//                                           allAnscmntANSIDwise[cmntSelectID]
//                                               [cmntIndex]["user_id"],
//                                           countData!.value["usertoken"][
//                                               allAnscmntANSIDwise[cmntSelectID]
//                                                       [cmntIndex]
//                                                   ["user_id"]]["tokenid"],
//                                           "You got one reply!",
//                                           "${userDataDB!.get("first_name")} ${userDataDB!.get("last_name")} replied on your comment.",
//                                           allQuestionsData[qIndex]
//                                               ["question_id"],
//                                           "question",
//                                           "false",
//                                           comparedate,
//                                           "add"
//                                         ]);
//                                         //////////////////////////////////////////////////////////////////////////
//                                         ElegantNotification.success(
//                                           title: Text("Congrats,"),
//                                           description: Text(
//                                               "Your reply posted successfully."),
//                                         );

//                                         // _update_count(
//                                         //     _currentUserId,
//                                         //     allQuestionsData[qIndex]
//                                         //         ["question_id"],
//                                         //     "answer",
//                                         //     "+",
//                                         //     qIndex);
//                                         replyPostVisibility = false;
//                                         reply = "";

//                                         tagcount = 0;
//                                         tagids = [];
//                                         tagedUsersName = [];

//                                         tagedString = "";
//                                         _get_all_questions_posted();
//                                         _get_all_answers_posted();
//                                         _get_all_answers_comment_posted();
//                                         _get_all_answers_reply_posted();
//                                         Navigator.of(_keyLoader.currentContext!,
//                                                 rootNavigator: true)
//                                             .pop();
//                                         Navigator.of(context).pop();
//                                       } else {
//                                         ElegantNotification.error(
//                                           title: Text("Error..."),
//                                           description: Text("Something wrong."),
//                                         );
//                                       }
//                                     }
//                                   },
//                                   style: ElevatedButton.styleFrom(
//                                     primary:
//                                         ((reply != "") || (replyImageURL != ""))
//                                             ? active
//                                             : Colors.white54,
//                                     onPrimary: Colors.white,
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(5),
//                                     ),
//                                   ),
//                                 ),
//                               )
//                             : SizedBox(),
//                       ],
//                     ),
//                   ),
//                 ),
//               );
//             }));
//   }

//   void _pickImagereply(BuildContext context, int qIndex, int ansSelectID,
//       int ansIndex, int cmntSelectID, int cmntIndex) async {
//     FilePickerResult? result = await FilePicker.platform.pickFiles();
//     if (result != null) {
//       Dialogs.showLoadingDialog(context, _keyLoader);

//       Uint8List? file = result.files.first.bytes;
//       String fileName = result.files.first.name;
//       UploadTask task = FirebaseStorage.instance
//           .ref()
//           .child("userAnswerReply/$_currentUserId/$fileName")
//           .putData(file!);

//       task.snapshotEvents.listen((event) async {
//         setState(() {
//           progress = ((event.bytesTransferred.toDouble() /
//                       event.totalBytes.toDouble()) *
//                   100)
//               .roundToDouble();
//         });
//         if (progress == 100) {
//           print(progress);
//           String downloadURL = await FirebaseStorage.instance
//               .ref("userAnswerReply/$_currentUserId/$fileName")
//               .getDownloadURL();
//           if (downloadURL != null) {
//             Navigator.of(_keyLoader.currentContext!, rootNavigator: true)
//                 .pop(); //close the dialoge
//             setState(() {
//               replyImageURL = downloadURL;
//               print(downloadURL);
//               progress = 0.0;
//               replyPostVisibility = true;
//             });

//             Navigator.of(context).pop();

//             _addreplyPostDialog(
//                 qIndex, ansSelectID, ansIndex, cmntSelectID, cmntIndex);
//           }
//         }
//       });
//     }
//   }
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
