import 'dart:io';
import 'dart:html' as html;
import 'dart:typed_data';
import 'dart:async';
import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:HyS/constants/keys.dart';
import 'package:HyS/constants/style.dart';
import 'package:HyS/database/crud.dart';
import 'package:HyS/services/place_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_custom_dialog/flutter_custom_dialog.dart';
import 'package:flutter_fadein/flutter_fadein.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:liquid_progress_indicator/liquid_progress_indicator.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../../constants/constants.dart';
import '../../layout.dart';

GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: kGoogleApiKey);

class RegistrationProcess extends StatefulWidget {
  @override
  _RegistrationProcessState createState() => _RegistrationProcessState();
}

class _RegistrationProcessState extends State<RegistrationProcess> {
  int _current_active_tab = 0;
  bool _current_hover_tab0 = false;
  bool _current_hover_tab1 = false;
  bool _current_hover_tab2 = false;
  bool _current_hover_tab3 = false;

  final _formKeyPersonalDetails = GlobalKey<FormState>();
  final _formKeySchoolDetails = GlobalKey<FormState>();
  final _formKeyStrengthDetails = GlobalKey<FormState>();
  final _formKeyWeaknessDetails = GlobalKey<FormState>();

  String f_name = "";
  String l_name = "";
  String email = "";
  String mobile = "";
  String gender = "";
  String dob = "";
  String address = "";
  String street = "";
  String city = "";
  String state = "";
  String grade = "";
  String board = "";
  String school_name = "";
  String school_street = "";
  String school_city = "";

  final GlobalKey<State> _keyLoader = new GlobalKey<State>();
  String school_state = "";

  List avataar = [
    'https://firebasestorage.googleapis.com/v0/b/hys-pro-41c66.appspot.com/o/assets%2Fauthentication%2Frobot1.png?alt=media&token=01ee884d-34af-4f70-a8a6-e4935269bc51',
    'https://firebasestorage.googleapis.com/v0/b/hys-pro-41c66.appspot.com/o/assets%2Fauthentication%2Ftony1.png?alt=media&token=b82d4041-f4de-400f-8695-3ca81f2342c8',
    'https://firebasestorage.googleapis.com/v0/b/hys-pro-41c66.appspot.com/o/assets%2Fauthentication%2Fgirl2.jpg?alt=media&token=add4e299-41b1-49ed-ba61-f35c39cbd070',
    'https://firebasestorage.googleapis.com/v0/b/hys-pro-41c66.appspot.com/o/assets%2Fauthentication%2Fgirl5.jpg?alt=media&token=af04a9f4-d1b6-4482-94b6-f2df1c140276',
    'https://firebasestorage.googleapis.com/v0/b/hys-pro-41c66.appspot.com/o/assets%2Fauthentication%2Fgirl6.jpg?alt=media&token=18c6d52f-d65e-4c2c-b85d-e71e8d3679a6',
    'https://firebasestorage.googleapis.com/v0/b/hys-pro-41c66.appspot.com/o/assets%2Fauthentication%2Fgirl7.jpg?alt=media&token=58388cd3-b48b-435e-8a92-0fd4eb3403a3',
    'https://firebasestorage.googleapis.com/v0/b/hys-pro-41c66.appspot.com/o/assets%2Fauthentication%2Fgirl8.jpg?alt=media&token=75b20327-538a-4e7f-bc50-c981dc2655eb',
    'https://firebasestorage.googleapis.com/v0/b/hys-pro-41c66.appspot.com/o/assets%2Fauthentication%2Fnewgirl.png?alt=media&token=0226b0cf-9381-4f1b-a496-360eebe35401',
    'https://firebasestorage.googleapis.com/v0/b/hys-pro-41c66.appspot.com/o/assets%2Fauthentication%2Fnewgirl1.png?alt=media&token=87857a56-68a8-439b-8bc5-96ffbadbf8e7',
    'https://firebasestorage.googleapis.com/v0/b/hys-pro-41c66.appspot.com/o/assets%2Fauthentication%2Fnewgirl2.png?alt=media&token=67fee229-5c19-47fe-b754-618cf79c46d5',
    'https://firebasestorage.googleapis.com/v0/b/hys-pro-41c66.appspot.com/o/assets%2Fauthentication%2Fbean1.png?alt=media&token=4f3b51ff-55f0-46ad-8611-fdd9b321ab73',
    'https://firebasestorage.googleapis.com/v0/b/hys-pro-41c66.appspot.com/o/assets%2Fauthentication%2FavataarSwag.png?alt=media&token=08b6a3f7-aa3a-401b-8256-dfa9baa3ea6c',
    'https://firebasestorage.googleapis.com/v0/b/hys-pro-41c66.appspot.com/o/assets%2Fauthentication%2FavataarSwag1.png?alt=media&token=fed2544c-dec9-4ab7-bf23-ccf31c3263ee',
    'https://firebasestorage.googleapis.com/v0/b/hys-pro-41c66.appspot.com/o/assets%2Fauthentication%2Fboy1.jpg?alt=media&token=241e4b63-bcd6-4233-9748-0c9de0273048',
    'https://firebasestorage.googleapis.com/v0/b/hys-pro-41c66.appspot.com/o/assets%2Fauthentication%2Fboy2.jpg?alt=media&token=3f6b1082-735e-4a1a-8939-cbbf55b15978',
    'https://firebasestorage.googleapis.com/v0/b/hys-pro-41c66.appspot.com/o/assets%2Fauthentication%2Fboy3.jpg?alt=media&token=25867996-54e8-4f8d-bf15-36b3ccb8bc9a'
  ];

  String choosedImg = '';
  Image? _image;
  Image? image;
  dynamic imgUrl;
  final picker = ImagePicker();
  String current_date = DateFormat.yMMMMd('en_US').format(DateTime.now());
  String current_time = DateTime.now().toString().substring(11, 15);
  String starttime = DateTime.now().toString();
  String current_onlyDate = (DateFormat('yyyyMMddkkmm').format(DateTime.now()))
      .toString()
      .substring(0, 8);
  String comparedate = DateFormat('yyyyMMddkkmm').format(DateTime.now());

  TextEditingController fnamecontroller = TextEditingController();
  TextEditingController lnamecontroller = TextEditingController();
  TextEditingController emailidcontroller = TextEditingController();
  TextEditingController mobilenocontroller = TextEditingController();
  TextEditingController personaddresscontroller = TextEditingController();
  TextEditingController personstreetcontroller = TextEditingController();
  TextEditingController personcitycontroller = TextEditingController();
  TextEditingController personstatecontroller = TextEditingController();
  TextEditingController personDOBcontroller = TextEditingController();

  TextEditingController schoolnamecontroller = TextEditingController();
  TextEditingController schoolstreetcontroller = TextEditingController();
  TextEditingController schooladdresscontroller = TextEditingController();
  TextEditingController schoolcitycontroller = TextEditingController();
  TextEditingController schoolstatecontroller = TextEditingController();
  final databaseReference = FirebaseDatabase.instance.reference();
  late DateTime _dTime;
  String _selectedDate = '';
  bool dt = false;

  late File cropped;
  String croppedImgPath = "";
  String dropdownValueStream = 'PCM';
  String dropdownValueGender = 'MALE';
  String dropdownValueBoard = "Select board";

  String fname = "";
  String lname = "";
  String stream = "";

  String dropdownValueGrade = 'Grade';
  String sname = "";
  String sArea = "";
  String sCity = "";
  String sState = "";
  List<String> preferredLanguage = ["English"];
  List<String> optionspreferredLanguage = [
    "English",
    "Hindi",
    "Marathi",
    "Gujrati",
    "Bengali",
    "Tamil",
    "Kannada",
    "Urdu",
    "Telugu",
    "Assami",
    "Sindhi",
    "Punjabi",
    "Bangla",
    "Oriya",
    "Tripuri",
    "Nepali"
  ];

  List<bool> boolOptionspreferredLanguage = [
    true,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false
  ];

  bool enable = true;
  var url;
  bool enable1 = true;
  String _streetnum = '';
  String _street = '';
  String _city = '';
  String _state = '';

  //------------------------------------------------Strength---------------------------------------------//

  QuerySnapshot? subjects;
  QuerySnapshot? topics;
  PanelController _pc = new PanelController();
  List<String> finalSelectedStrengthSubjects = [];
  List<List<String>> finalSelectedStrengthTopics = [];
  List<String> finalSelectedWeaknessSubjects = [];
  List<List<String>> finalSelectedWeaknessTopics = [];
  Map? totaldata;
  CrudMethods crudobj = CrudMethods();
  List<String> subjectList = [];
  List<bool> boolSubjectList = [];
  List<List<String>> topicList = [];
  List<List<bool>> boolTopicsList = [];
  List<int> selectedtopicsbysubject = [];

  List<String> subjectListWkns = [];
  List<bool> boolSubjectListWkns = [];
  List<List<String>> topicListWkns = [];
  List<List<bool>> boolTopicsListWkns = [];
  List<int> selectedtopicsbysubjectWkns = [];
  int panelSubjectIndex = 0;
  int totalselectedTopiccount = 0;
  int panelSubjectIndexWkns = 0;
  int totalselectedTopiccountWkns = 0;
  String _currentUserId = FirebaseAuth.instance.currentUser!.uid;
  bool isImageselected = false;
  String imageSelectedFromGalleryURL = "";

  ScrollController? _scrollController;
  bool? flag;

  @override
  void initState() {
    _scrollController = ScrollController();
    super.initState();
  }

  String selectedGradeValue = '';
  String selectedBoardValue = '';

  _loadStrengthWeaknessData(String value) {
    if ((dropdownValueGrade != 'Grade') &&
        (dropdownValueBoard != "Select board")) {
      if ((selectedGradeValue != dropdownValueGrade) ||
          (dropdownValueBoard != selectedBoardValue)) {
        if (dropdownValueBoard == "CBSE") {
          dropdownValueBoard = "Central Board of Secondary Education (CBSE)";
        }
        subjectListWkns = [];
        subjectList = [];
        boolSubjectList = [];
        boolSubjectListWkns = [];
        selectedtopicsbysubject = [];
        selectedtopicsbysubjectWkns = [];
        topicList = [];
        boolTopicsList = [];
        topicListWkns = [];
        boolTopicsListWkns = [];
        selectedGradeValue = dropdownValueGrade;
        selectedBoardValue = dropdownValueBoard;
        crudobj.getGradeSubjectList(dropdownValueBoard).then((value) {
          setState(() {
            subjects = value;
            if ((subjects != null)) {
              for (int i = 0; i < subjects!.docs.length; i++) {
                if ((subjects!.docs[i].get("grade") == dropdownValueGrade)) {
                  subjectListWkns.add(subjects!.docs[i].get("subject"));
                  subjectList.add(subjects!.docs[i].get("subject"));
                  boolSubjectList.add(false);
                  boolSubjectListWkns.add(false);
                  selectedtopicsbysubject.add(0);
                  selectedtopicsbysubjectWkns.add(0);
                }
              }
              crudobj.getTopicSubjectList(dropdownValueBoard).then((value) {
                setState(() {
                  topics = value;
                  if (topics != null) {
                    for (int i = 0; i < subjectList.length; i++) {
                      List<String> subjectTopics = [];
                      List<bool> boolsubjectTopics = [];
                      for (int j = 0; j < topics!.docs.length; j++) {
                        if ((topics!.docs[j].get("grade") ==
                                dropdownValueGrade) &&
                            (topics!.docs[j].get("subject") ==
                                subjectList[i])) {
                          subjectTopics.add(topics!.docs[j].get("topic"));
                          boolsubjectTopics.add(false);
                        }
                      }
                      topicList.add(subjectTopics);
                      boolTopicsList.add(boolsubjectTopics);
                    }

                    for (int i = 0; i < subjectListWkns.length; i++) {
                      List<String> subjectTopicsWkns = [];
                      List<bool> boolsubjectTopicsWkns = [];
                      for (int j = 0; j < topics!.docs.length; j++) {
                        if ((topics!.docs[j].get("grade") ==
                                dropdownValueGrade) &&
                            (topics!.docs[j].get("subject") ==
                                subjectListWkns[i])) {
                          subjectTopicsWkns.add(topics!.docs[j].get("topic"));
                          boolsubjectTopicsWkns.add(false);
                        }
                      }
                      topicListWkns.add(subjectTopicsWkns);
                      boolTopicsListWkns.add(boolsubjectTopicsWkns);
                    }
                    print("topicList: $topicList");
                    print("topicListWkns: $topicListWkns");
                  }
                });
              });
            }
          });
        });
      }
      if (value == 'strength') {
        _current_active_tab = 2;
      } else if (value == 'weakness') {
        _current_active_tab = 3;
      }
    }
  }

  //map is created to show the image with its respective sebject
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

//UI of show subject on screen
  _showImage(String sub) {
    if (imageMap.containsKey(sub) == true) {
      flag = true;
    } else
      flag = false;
    String? img_url_load =
        imageMap.containsKey(sub) == true ? imageMap[sub] : imageMap["others"];
    return Image.network(img_url_load!, width: 40, height: 40);
  }

  void dispose() {
    fnamecontroller.dispose();
    lnamecontroller.dispose();
    emailidcontroller.dispose();
    mobilenocontroller.dispose();
    personaddresscontroller.dispose();
    personstreetcontroller.dispose();
    personcitycontroller.dispose();
    personstatecontroller.dispose();
    personDOBcontroller.dispose();
    schoolnamecontroller.dispose();
    schoolstreetcontroller.dispose();
    schooladdresscontroller.dispose();
    schoolcitycontroller.dispose();
    schoolstatecontroller.dispose();
    super.dispose();
  }

  void onError(PlacesAutocompleteResponse response) {
    print(response.errorMessage);
  }

  String sector = '';
  String fullAddress = '';
  String title = '';

  String sStreet = '';

  // google address search function
  Future<void> _handlePressButton() async {
    try {
      Prediction? p = await PlacesAutocomplete.show(
        context: context,
        apiKey: kGoogleApiKey,
        onError: onError,
        mode: Mode.fullscreen,
        language: "en",
      );

      PlacesDetailsResponse place =
          await _places.getDetailsByPlaceId(p!.placeId!);
      final placeDetail = place.result;
      title = placeDetail.name;
      String title1 = '';
      fullAddress = placeDetail.formattedAddress!;
      for (int i = 0; i < title.length; i++) {
        if (title[i] != '-') {
          title1 += title[i];
        } else
          break;
      }
      print(title);
      print(fullAddress);

      for (int i = 0; i < fullAddress.length; i++) {
        String word = fullAddress[i];
        for (int j = i + 1; j < fullAddress.length; j++) {
          if (fullAddress[j] != ' ') {
            word += fullAddress[j];
          } else if (word == 'Sector' ||
              word == 'Phase' ||
              word == 'Block' ||
              word == 'near' ||
              word == 'Near' ||
              word == 'Pocket') {
            word += ' ';
            for (int k = j + 1; k < fullAddress.length; k++) {
              if (fullAddress[k] != ' ') {
                word += fullAddress[k];
              } else {
                sector += word;
                break;
              }
            }
          } else {
            continue;
          }
        }
      }
      print(sector);

      final sessionToken1 = Uuid().v4();

      final placeDetails1 = await PlaceApiProvider(sessionToken1)
          .getPlaceDetailFromId(p.placeId!);
      setState(() {
        schoolnamecontroller.text = title1;
        sArea = placeDetails1.streetNumber;
        schooladdresscontroller.text = placeDetails1.street;

        schoolcitycontroller.text = placeDetails1.city;
        schoolstatecontroller.text = placeDetails1.streetNumber;

        schoolstreetcontroller.text = placeDetails1.zipCode;
      });
    } catch (e) {
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () {
          return Future(() => false);
        },
        child: Scaffold(
            backgroundColor: light,
            body: SlidingUpPanel(
              controller: _pc,
              minHeight: 1,
              maxHeight: MediaQuery.of(context).size.height - 400,
              body: _body(context),
              panel: _panel(context),
            )));
  }

  _body(BuildContext context) {
    return SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          children: [
            SizedBox(
              height: 50,
            ),
            _scrollingButton(),
            SizedBox(
              height: 30,
            ),
            _current_active_tab == 0
                ? _personal_details()
                : _current_active_tab == 1
                    ? _school_details()
                    : _current_active_tab == 2
                        ? _strength_details()
                        : _current_active_tab == 3
                            ? _weakness_details()
                            : SizedBox(),
            SizedBox(
              height: 100,
            ),
          ],
        ));
  }

  _scrollingButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        InkWell(
          onTap: () {
            setState(() {
              _current_active_tab = 0;
            });
          },
          onHover: (bool? value) {
            setState(() {
              _current_hover_tab0 = value!;
            });
          },
          child: Container(
            padding: EdgeInsets.all(MediaQuery.of(context).size.width / 76.8),
            margin: EdgeInsets.all(MediaQuery.of(context).size.width / 153.6),
            decoration: BoxDecoration(
                color:
                    (_current_active_tab == 0) || (_current_hover_tab0 == true)
                        ? active
                        : light,
                borderRadius: BorderRadius.circular(
                    MediaQuery.of(context).size.width / 76.8)),
            child: Text(
              "Personal\nDetails",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.width < 1220
                    ? 12
                    : MediaQuery.of(context).size.width / 96,
                fontWeight: FontWeight.w700,
                color:
                    (_current_active_tab == 0) || (_current_hover_tab0 == true)
                        ? Colors.black
                        : Colors.grey[800],
              ),
            ),
          ),
        ),
        Container(
            width: MediaQuery.of(context).size.width / 15.36,
            height: 1,
            color: Colors.grey[400]),
        InkWell(
          onTap: () {
            setState(() {
              _current_active_tab = 1;
            });
          },
          onHover: (bool? value) {
            setState(() {
              _current_hover_tab1 = value!;
            });
          },
          child: Container(
            padding: EdgeInsets.all(MediaQuery.of(context).size.width / 76.8),
            margin: EdgeInsets.all(MediaQuery.of(context).size.width / 153.6),
            decoration: BoxDecoration(
                color:
                    (_current_active_tab == 1) || (_current_hover_tab1 == true)
                        ? active
                        : light,
                borderRadius: BorderRadius.circular(
                    MediaQuery.of(context).size.width / 76.8)),
            child: Text(
              "School\nDetails",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.width < 1220
                    ? 12
                    : MediaQuery.of(context).size.width / 96,
                fontWeight: FontWeight.w700,
                color:
                    (_current_active_tab == 1) || (_current_hover_tab1 == true)
                        ? Colors.black
                        : Colors.grey[800],
              ),
            ),
          ),
        ),
        Container(
            width: MediaQuery.of(context).size.width / 15.36,
            height: 1,
            color: Colors.grey[400]),
        InkWell(
          onTap: () {
            setState(() {
              _loadStrengthWeaknessData("strength");
            });
          },
          onHover: (bool? value) {
            setState(() {
              _current_hover_tab2 = value!;
            });
          },
          child: Container(
            padding: EdgeInsets.all(MediaQuery.of(context).size.width / 76.8),
            margin: EdgeInsets.all(MediaQuery.of(context).size.width / 153.6),
            decoration: BoxDecoration(
                color:
                    (_current_active_tab == 2) || (_current_hover_tab2 == true)
                        ? active
                        : light,
                borderRadius: BorderRadius.circular(
                    MediaQuery.of(context).size.width / 76.8)),
            child: Text(
              "Strength\nDetails",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.width < 1220
                    ? 12
                    : MediaQuery.of(context).size.width / 96,
                fontWeight: FontWeight.w700,
                color:
                    (_current_active_tab == 2) || (_current_hover_tab2 == true)
                        ? Colors.black
                        : Colors.grey[800],
              ),
            ),
          ),
        ),
        Container(
            width: MediaQuery.of(context).size.width / 15.36,
            height: 1,
            color: Colors.grey[400]),
        InkWell(
          onTap: () {
            setState(() {
              _loadStrengthWeaknessData("weakness");
            });
          },
          onHover: (bool? value) {
            setState(() {
              _current_hover_tab3 = value!;
            });
          },
          child: Container(
            padding: EdgeInsets.all(MediaQuery.of(context).size.width / 76.8),
            margin: EdgeInsets.all(MediaQuery.of(context).size.width / 153.6),
            decoration: BoxDecoration(
                color:
                    (_current_active_tab == 3) || (_current_hover_tab3 == true)
                        ? active
                        : light,
                borderRadius: BorderRadius.circular(
                    MediaQuery.of(context).size.width / 76.8)),
            child: Text(
              "Weakness\nDetails",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.width < 1220
                    ? 12
                    : MediaQuery.of(context).size.width / 96,
                fontWeight: FontWeight.w700,
                color:
                    (_current_active_tab == 3) || (_current_hover_tab3 == true)
                        ? Colors.black
                        : Colors.grey[800],
              ),
            ),
          ),
        ),
      ],
    );
  }

  _personal_details() {
    return MediaQuery.of(context).size.width > 900
        ? FadeIn(
            child: Form(
              key: _formKeyPersonalDetails,
              child: Container(
                margin: EdgeInsets.all(30),
                child: Column(
                  children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(children: [
                            CircleAvatar(
                              child: ClipOval(
                                child: Container(
                                  child: CachedNetworkImage(
                                    imageUrl: imageSelectedFromGalleryURL != ""
                                        ? imageSelectedFromGalleryURL
                                        : choosedImg == ""
                                            ? "https://firebasestorage.googleapis.com/v0/b/hys-pro-41c66.appspot.com/o/assets%2Fauthentication%2Frobot1.png?alt=media&token=01ee884d-34af-4f70-a8a6-e4935269bc51"
                                            : choosedImg,
                                    width: 150,
                                    height: 150,
                                    fit: BoxFit.fitHeight,
                                    placeholder: (context, url) => Container(
                                      width: 150,
                                      height: 150,
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
                            SizedBox(height: 6),
                            InkWell(
                                onTap: () {
                                  _showCameraDialog();
                                },
                                child: Text(
                                  "Upload Profile",
                                  style: TextStyle(color: Colors.blue),
                                ))
                          ]),
                          SizedBox(
                            width: MediaQuery.of(context).size.width / 5.12,
                          ),
                          InkWell(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.deepPurple.withOpacity(0.1),
                                    spreadRadius: 10,
                                    blurRadius: 20,
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                child: Container(
                                    width: 100,
                                    height: 40,
                                    child: Center(child: Text("SUBMIT"))),
                                onPressed: () async {
                                  print("button pressed");

                                  if (_formKeyPersonalDetails.currentState!
                                      .validate()) {
                                    print("form validation: correct");
                                    setState(() {
                                      _current_active_tab = 1;
                                    });
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  primary: active,
                                  onPrimary: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        MediaQuery.of(context).size.width /
                                            102.4),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ]),
                    SizedBox(
                      height: 60,
                    ),
                    Container(
                      margin: EdgeInsets.only(bottom: 30),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width / 5.12,
                            child: TextFormField(
                              controller: fnamecontroller,
                              keyboardType: TextInputType.name,
                              textCapitalization: TextCapitalization.sentences,
                              validator: (val) => ((val!.isEmpty))
                                  ? 'Enter your first name'
                                  : null,
                              onChanged: (val) {
                                setState(() {
                                  f_name = val;
                                });
                              },
                              decoration: InputDecoration(
                                hintText: 'First name',
                                filled: true,
                                fillColor: Colors.blueGrey[50],
                                labelStyle: TextStyle(
                                    fontSize:
                                        MediaQuery.of(context).size.width /
                                            128),
                                hintStyle: TextStyle(
                                    fontSize:
                                        MediaQuery.of(context).size.width < 1220
                                            ? 12
                                            : MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                102.4),
                                contentPadding: EdgeInsets.only(
                                    left: MediaQuery.of(context).size.width /
                                        51.2),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.blueGrey.withOpacity(0.05),
                                  ),
                                  borderRadius: BorderRadius.circular(
                                      MediaQuery.of(context).size.width /
                                          102.4),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.blueGrey.withOpacity(0.05),
                                  ),
                                  borderRadius: BorderRadius.circular(
                                      MediaQuery.of(context).size.width /
                                          102.4),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width / 5.12,
                            child: TextFormField(
                              controller: lnamecontroller,
                              keyboardType: TextInputType.name,
                              textCapitalization: TextCapitalization.characters,
                              validator: (val) => ((val!.isEmpty))
                                  ? 'Enter your last name'
                                  : null,
                              onChanged: (val) {
                                setState(() {
                                  l_name = val;
                                });
                              },
                              decoration: InputDecoration(
                                hintText: 'Last name',
                                filled: true,
                                fillColor: Colors.blueGrey[50],
                                labelStyle: TextStyle(
                                    fontSize:
                                        MediaQuery.of(context).size.width /
                                            128),
                                hintStyle: TextStyle(
                                    fontSize:
                                        MediaQuery.of(context).size.width < 1220
                                            ? 12
                                            : MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                102.4),
                                contentPadding: EdgeInsets.only(
                                    left: MediaQuery.of(context).size.width /
                                        51.2),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.blueGrey.withOpacity(0.05),
                                  ),
                                  borderRadius: BorderRadius.circular(
                                      MediaQuery.of(context).size.width /
                                          102.4),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.blueGrey.withOpacity(0.05),
                                  ),
                                  borderRadius: BorderRadius.circular(
                                      MediaQuery.of(context).size.width /
                                          102.4),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width / 5.12,
                            child: TextFormField(
                              controller: emailidcontroller,
                              keyboardType: TextInputType.emailAddress,
                              textCapitalization: TextCapitalization.characters,
                              validator: (val) => ((val!.isEmpty))
                                  ? 'Enter your Email ID'
                                  : null,
                              onChanged: (val) {
                                setState(() {
                                  email = val;
                                });
                              },
                              decoration: InputDecoration(
                                hintText: 'Email ID',
                                filled: true,
                                fillColor: Colors.blueGrey[50],
                                labelStyle: TextStyle(
                                    fontSize:
                                        MediaQuery.of(context).size.width /
                                            128),
                                hintStyle: TextStyle(
                                    fontSize:
                                        MediaQuery.of(context).size.width < 1220
                                            ? 12
                                            : MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                102.4),
                                contentPadding: EdgeInsets.only(
                                    left: MediaQuery.of(context).size.width /
                                        51.2),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.blueGrey.withOpacity(0.05),
                                  ),
                                  borderRadius: BorderRadius.circular(
                                      MediaQuery.of(context).size.width /
                                          102.4),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.blueGrey.withOpacity(0.05),
                                  ),
                                  borderRadius: BorderRadius.circular(
                                      MediaQuery.of(context).size.width /
                                          102.4),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Container(
                      margin: EdgeInsets.only(bottom: 30),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width / 5.12,
                            child: TextFormField(
                              controller: mobilenocontroller,
                              keyboardType: TextInputType.phone,
                              validator: (val) => ((val!.isEmpty))
                                  ? 'Enter your mobile number'
                                  : null,
                              onChanged: (val) {
                                setState(() {
                                  mobile = val;
                                });
                              },
                              decoration: InputDecoration(
                                hintText: '+91 - mobile number',
                                hintStyle: TextStyle(
                                    fontSize:
                                        MediaQuery.of(context).size.width < 1220
                                            ? 12
                                            : MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                102.4),
                                filled: true,
                                fillColor: Colors.blueGrey[50],
                                labelStyle: TextStyle(
                                    fontSize:
                                        MediaQuery.of(context).size.width /
                                            128),
                                contentPadding: EdgeInsets.only(
                                    left: MediaQuery.of(context).size.width /
                                        51.2),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.blueGrey.withOpacity(0.05),
                                  ),
                                  borderRadius: BorderRadius.circular(
                                      MediaQuery.of(context).size.width /
                                          102.4),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.blueGrey.withOpacity(0.05),
                                  ),
                                  borderRadius: BorderRadius.circular(
                                      MediaQuery.of(context).size.width /
                                          102.4),
                                ),
                              ),
                            ),
                          ),
                          Container(
                              width: MediaQuery.of(context).size.width / 5.12,
                              padding: EdgeInsets.only(
                                  left:
                                      MediaQuery.of(context).size.width / 51.2),
                              decoration: BoxDecoration(
                                color: Colors.blueGrey[50],
                                borderRadius: BorderRadius.circular(
                                    MediaQuery.of(context).size.width / 102.4),
                              ),
                              child: DropdownButton<String>(
                                value: dropdownValueGender,
                                icon: Container(),
                                elevation: 7,
                                style: const TextStyle(
                                    color: Colors.black, fontSize: (16)),
                                underline: Container(
                                  height: 0.0,
                                  color: Colors.blueGrey[50],
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    dropdownValueGender = value!;
                                  });
                                },
                                items: <String>[
                                  'MALE',
                                  'FEMAILE',
                                  'OTHERS'
                                ].map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(
                                      value,
                                      style: TextStyle(
                                          fontSize: MediaQuery.of(context)
                                                      .size
                                                      .width <
                                                  1220
                                              ? 12
                                              : MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  102.4),
                                    ),
                                  );
                                }).toList(),
                              )),
                          Container(
                              width: MediaQuery.of(context).size.width / 5.12,
                              child: TextFormField(
                                  validator: (value) => (value!.isEmpty)
                                      ? 'Please choose your date of birth'
                                      : null,
                                  controller: personDOBcontroller,
                                  onChanged: (value) {
                                    setState(() {
                                      dob = value;
                                    });
                                  },
                                  onTap: () {
                                    showDatePicker(
                                            context: context,
                                            initialDate: DateTime.now(),
                                            firstDate: DateTime(1900),
                                            lastDate: DateTime.now())
                                        .then((value) {
                                      setState(() {
                                        dt = false;
                                        _dTime = value!;
                                        _selectedDate = DateFormat("dd/MM/yyyy")
                                            .format(_dTime);
                                        print(
                                          _selectedDate.substring(0, 10),
                                        );
                                        personDOBcontroller.text =
                                            _selectedDate;
                                        dob = _selectedDate;
                                      });
                                    });
                                  },
                                  decoration: InputDecoration(
                                    labelText: 'DD//MM//YY',
                                    filled: true,
                                    fillColor: Colors.blueGrey[50],
                                    labelStyle: TextStyle(
                                        fontSize:
                                            MediaQuery.of(context).size.width <
                                                    1220
                                                ? 12
                                                : MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    102.4),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color:
                                            Colors.blueGrey.withOpacity(0.05),
                                      ),
                                      borderRadius: BorderRadius.circular(
                                          MediaQuery.of(context).size.width /
                                              102.4),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color:
                                            Colors.blueGrey.withOpacity(0.05),
                                      ),
                                      borderRadius: BorderRadius.circular(
                                          MediaQuery.of(context).size.width /
                                              102.4),
                                    ),
                                  ))),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Container(
                      margin: EdgeInsets.only(bottom: 30),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                              width: MediaQuery.of(context).size.width / 5.12,
                              decoration: BoxDecoration(
                                color: Colors.blueGrey[50],
                                borderRadius: BorderRadius.circular(
                                    MediaQuery.of(context).size.width / 102.4),
                              ),
                              child: TextFormField(
                                textCapitalization:
                                    TextCapitalization.characters,
                                validator: (value) => (value!.isEmpty)
                                    ? 'Please type your address'
                                    : null,
                                controller: personaddresscontroller,
                                onChanged: (val) {
                                  setState(() {
                                    _streetnum = val;
                                  });
                                },
                                onTap: () async {
                                  if (_streetnum == '') {
                                    personaddresscontroller =
                                        TextEditingController();
                                    personstreetcontroller =
                                        TextEditingController();
                                    personcitycontroller =
                                        TextEditingController();
                                    personstatecontroller =
                                        TextEditingController();
                                    _street = '';
                                    _city = '';
                                    _state = '';

                                    final sessionToken = Uuid().v4();
                                    final Suggestion? result = await showSearch(
                                      context: context,
                                      delegate: AddressSearch(sessionToken),
                                    );
                                    if (result != null) {
                                      final placeDetails =
                                          await PlaceApiProvider(sessionToken)
                                              .getPlaceDetailFromId1(
                                                  result.placeId);
                                      setState(() {
                                        _showLoadingDialog();
                                        _streetnum = placeDetails.streetNumber;
                                        personaddresscontroller.text =
                                            placeDetails.streetNumber;
                                        personstreetcontroller.text =
                                            placeDetails.street;
                                        _street = placeDetails.street;
                                        personcitycontroller.text =
                                            placeDetails.city;
                                        _city = placeDetails.city;
                                        personstatecontroller.text =
                                            placeDetails.zipCode;
                                        _state = placeDetails.zipCode;
                                        print("ok");
                                        Navigator.pop(context);
                                      });
                                    }
                                  }
                                },
                                decoration: InputDecoration(
                                  hintText: 'Address',
                                  hintStyle: TextStyle(
                                      fontSize: MediaQuery.of(context)
                                                  .size
                                                  .width <
                                              1220
                                          ? 12
                                          : MediaQuery.of(context).size.width /
                                              102.4),
                                  filled: true,
                                  fillColor: Colors.blueGrey[50],
                                  labelStyle: TextStyle(
                                      fontSize:
                                          MediaQuery.of(context).size.width /
                                              128),
                                  contentPadding: EdgeInsets.only(
                                      left: MediaQuery.of(context).size.width /
                                          51.2),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.blueGrey.withOpacity(0.05),
                                    ),
                                    borderRadius: BorderRadius.circular(
                                        MediaQuery.of(context).size.width /
                                            102.4),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.blueGrey.withOpacity(0.05),
                                    ),
                                    borderRadius: BorderRadius.circular(
                                        MediaQuery.of(context).size.width /
                                            102.4),
                                  ),
                                ),
                              )),
                          Container(
                              width: MediaQuery.of(context).size.width / 5.12,
                              decoration: BoxDecoration(
                                color: Colors.blueGrey[50],
                                borderRadius: BorderRadius.circular(
                                    MediaQuery.of(context).size.width / 102.4),
                              ),
                              child: TextFormField(
                                textCapitalization:
                                    TextCapitalization.characters,
                                validator: (value) => (value!.isEmpty)
                                    ? 'Please type your street'
                                    : null,
                                controller: personstreetcontroller,
                                onChanged: (val) {
                                  setState(() {
                                    _streetnum = val;
                                  });
                                },
                                decoration: InputDecoration(
                                  hintText: 'Street',
                                  hintStyle: TextStyle(
                                      fontSize: MediaQuery.of(context)
                                                  .size
                                                  .width <
                                              1220
                                          ? 12
                                          : MediaQuery.of(context).size.width /
                                              102.4),
                                  filled: true,
                                  fillColor: Colors.blueGrey[50],
                                  labelStyle: TextStyle(
                                      fontSize:
                                          MediaQuery.of(context).size.width /
                                              128),
                                  contentPadding: EdgeInsets.only(
                                      left: MediaQuery.of(context).size.width /
                                          51.2),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.blueGrey.withOpacity(0.05),
                                    ),
                                    borderRadius: BorderRadius.circular(
                                        MediaQuery.of(context).size.width /
                                            102.4),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.blueGrey.withOpacity(0.05),
                                    ),
                                    borderRadius: BorderRadius.circular(
                                        MediaQuery.of(context).size.width /
                                            102.4),
                                  ),
                                ),
                              )),
                          Container(
                              width: MediaQuery.of(context).size.width / 5.12,
                              decoration: BoxDecoration(
                                color: Colors.blueGrey[50],
                                borderRadius: BorderRadius.circular(
                                    MediaQuery.of(context).size.width / 102.4),
                              ),
                              child: TextFormField(
                                textCapitalization:
                                    TextCapitalization.characters,
                                validator: (value) => (value!.isEmpty)
                                    ? 'Please type your City'
                                    : null,
                                controller: personcitycontroller,
                                onChanged: (val) {
                                  setState(() {
                                    _streetnum = val;
                                  });
                                },
                                decoration: InputDecoration(
                                  hintText: 'City',
                                  hintStyle: TextStyle(
                                      fontSize: MediaQuery.of(context)
                                                  .size
                                                  .width <
                                              1220
                                          ? 12
                                          : MediaQuery.of(context).size.width /
                                              102.4),
                                  filled: true,
                                  fillColor: Colors.blueGrey[50],
                                  labelStyle: TextStyle(
                                      fontSize:
                                          MediaQuery.of(context).size.width /
                                              128),
                                  contentPadding: EdgeInsets.only(
                                      left: MediaQuery.of(context).size.width /
                                          51.2),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.blueGrey.withOpacity(0.05),
                                    ),
                                    borderRadius: BorderRadius.circular(
                                        MediaQuery.of(context).size.width /
                                            102.4),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.blueGrey.withOpacity(0.05),
                                    ),
                                    borderRadius: BorderRadius.circular(
                                        MediaQuery.of(context).size.width /
                                            102.4),
                                  ),
                                ),
                              )),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Container(
                      margin: EdgeInsets.only(bottom: 30),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                              width: MediaQuery.of(context).size.width / 5.12,
                              decoration: BoxDecoration(
                                color: Colors.blueGrey[50],
                                borderRadius: BorderRadius.circular(
                                    MediaQuery.of(context).size.width / 102.4),
                              ),
                              child: TextFormField(
                                textCapitalization:
                                    TextCapitalization.characters,
                                validator: (value) => (value!.isEmpty)
                                    ? 'Please type your State'
                                    : null,
                                controller: personstatecontroller,
                                onChanged: (val) {
                                  setState(() {
                                    _streetnum = val;
                                  });
                                },
                                decoration: InputDecoration(
                                  hintText: 'State',
                                  hintStyle: TextStyle(
                                      fontSize: MediaQuery.of(context)
                                                  .size
                                                  .width <
                                              1220
                                          ? 12
                                          : MediaQuery.of(context).size.width /
                                              102.4),
                                  filled: true,
                                  fillColor: Colors.blueGrey[50],
                                  labelStyle: TextStyle(
                                      fontSize:
                                          MediaQuery.of(context).size.width /
                                              128),
                                  contentPadding: EdgeInsets.only(
                                      left: MediaQuery.of(context).size.width /
                                          51.2),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.blueGrey.withOpacity(0.05),
                                    ),
                                    borderRadius: BorderRadius.circular(
                                        MediaQuery.of(context).size.width /
                                            102.4),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.blueGrey.withOpacity(0.05),
                                    ),
                                    borderRadius: BorderRadius.circular(
                                        MediaQuery.of(context).size.width /
                                            102.4),
                                  ),
                                ),
                              )),
                          Container(
                              width: MediaQuery.of(context).size.width / 5.12,
                              decoration: BoxDecoration(
                                color: Colors.blueGrey[50],
                                borderRadius: BorderRadius.circular(
                                    MediaQuery.of(context).size.width / 102.4),
                              ),
                              child: TextFormField(
                                initialValue: "INDIA",
                                readOnly: true,
                                textCapitalization:
                                    TextCapitalization.characters,
                                validator: (value) => (value!.isEmpty)
                                    ? 'Please type your country'
                                    : null,
                                decoration: InputDecoration(
                                  hintText: 'Street',
                                  hintStyle: TextStyle(
                                      fontSize: MediaQuery.of(context)
                                                  .size
                                                  .width <
                                              1220
                                          ? 12
                                          : MediaQuery.of(context).size.width /
                                              102.4),
                                  filled: true,
                                  fillColor: Colors.blueGrey[50],
                                  labelStyle: TextStyle(
                                      fontSize:
                                          MediaQuery.of(context).size.width /
                                              128),
                                  contentPadding: EdgeInsets.only(
                                      left: MediaQuery.of(context).size.width /
                                          51.2),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.blueGrey.withOpacity(0.05),
                                    ),
                                    borderRadius: BorderRadius.circular(
                                        MediaQuery.of(context).size.width /
                                            102.4),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.blueGrey.withOpacity(0.05),
                                    ),
                                    borderRadius: BorderRadius.circular(
                                        MediaQuery.of(context).size.width /
                                            102.4),
                                  ),
                                ),
                              )),
                          InkWell(
                            onTap: () {
                              showBarModalBottomSheet(
                                  context: context,
                                  builder: (context) =>
                                      _preferredLanguage(context));
                            },
                            child: Container(
                                width: MediaQuery.of(context).size.width / 5.12,
                                padding: EdgeInsets.only(
                                    left: MediaQuery.of(context).size.width /
                                        51.2,
                                    top: 15,
                                    bottom: 15),
                                decoration: BoxDecoration(
                                  color: Colors.blueGrey[50],
                                  border: Border.all(
                                    color: Colors.blueGrey.withOpacity(0.05),
                                  ),
                                  borderRadius: BorderRadius.circular(
                                      MediaQuery.of(context).size.width /
                                          102.4),
                                ),
                                child: Text(
                                    preferredLanguage.length == 0
                                        ? "Preffer Languages"
                                        : (preferredLanguage
                                            .toString()
                                            .substring(
                                                1,
                                                (preferredLanguage.toString())
                                                        .length -
                                                    1)),
                                    style: TextStyle(
                                        fontSize:
                                            MediaQuery.of(context).size.width <
                                                    1220
                                                ? 12
                                                : MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    96))),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            duration: Duration(seconds: 1),
            curve: Curves.easeIn,
          )
        : FadeIn(
            child: Form(
              key: _formKeyPersonalDetails,
              child: Container(
                margin: EdgeInsets.all(30),
                child: Column(
                  children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(children: [
                            CircleAvatar(
                              child: ClipOval(
                                child: Container(
                                  child: CachedNetworkImage(
                                    imageUrl: imageSelectedFromGalleryURL != ""
                                        ? imageSelectedFromGalleryURL
                                        : choosedImg == ""
                                            ? "https://firebasestorage.googleapis.com/v0/b/hys-pro-41c66.appspot.com/o/assets%2Fauthentication%2Frobot1.png?alt=media&token=01ee884d-34af-4f70-a8a6-e4935269bc51"
                                            : choosedImg,
                                    width: 150,
                                    height: 150,
                                    fit: BoxFit.fitHeight,
                                    placeholder: (context, url) => Container(
                                      width: 150,
                                      height: 150,
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
                            SizedBox(height: 6),
                            InkWell(
                                onTap: () {
                                  _showCameraDialog();
                                },
                                child: Text(
                                  "Upload Profile",
                                  style: TextStyle(color: Colors.blue),
                                ))
                          ]),
                          SizedBox(
                            width: MediaQuery.of(context).size.width / 5.12,
                          ),
                          InkWell(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.deepPurple.withOpacity(0.1),
                                    spreadRadius: 10,
                                    blurRadius: 20,
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                child: Container(
                                    width: 100,
                                    height: 40,
                                    child: Center(child: Text("SUBMIT"))),
                                onPressed: () async {
                                  print("button pressed");

                                  if (_formKeyPersonalDetails.currentState!
                                      .validate()) {
                                    print("form validation: correct");
                                    setState(() {
                                      _current_active_tab = 1;
                                    });
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  primary: active,
                                  onPrimary: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        MediaQuery.of(context).size.width /
                                            102.4),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ]),
                    SizedBox(
                      height: 60,
                    ),
                    Container(
                      margin: EdgeInsets.only(bottom: 30),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width / 3,
                            child: TextFormField(
                              controller: fnamecontroller,
                              keyboardType: TextInputType.name,
                              textCapitalization: TextCapitalization.sentences,
                              validator: (val) => ((val!.isEmpty))
                                  ? 'Enter your first name'
                                  : null,
                              onChanged: (val) {
                                setState(() {
                                  f_name = val;
                                });
                              },
                              decoration: InputDecoration(
                                hintText: 'First name',
                                filled: true,
                                fillColor: Colors.blueGrey[50],
                                labelStyle: TextStyle(
                                    fontSize:
                                        MediaQuery.of(context).size.width /
                                            128),
                                hintStyle: TextStyle(
                                    fontSize:
                                        MediaQuery.of(context).size.width < 1220
                                            ? 12
                                            : MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                102.4),
                                contentPadding: EdgeInsets.only(
                                    left: MediaQuery.of(context).size.width /
                                        51.2),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.blueGrey.withOpacity(0.05),
                                  ),
                                  borderRadius: BorderRadius.circular(
                                      MediaQuery.of(context).size.width /
                                          102.4),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.blueGrey.withOpacity(0.05),
                                  ),
                                  borderRadius: BorderRadius.circular(
                                      MediaQuery.of(context).size.width /
                                          102.4),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width / 3,
                            child: TextFormField(
                              controller: lnamecontroller,
                              keyboardType: TextInputType.name,
                              textCapitalization: TextCapitalization.characters,
                              validator: (val) => ((val!.isEmpty))
                                  ? 'Enter your last name'
                                  : null,
                              onChanged: (val) {
                                setState(() {
                                  l_name = val;
                                });
                              },
                              decoration: InputDecoration(
                                hintText: 'Last name',
                                filled: true,
                                fillColor: Colors.blueGrey[50],
                                labelStyle: TextStyle(
                                    fontSize:
                                        MediaQuery.of(context).size.width /
                                            128),
                                hintStyle: TextStyle(
                                    fontSize:
                                        MediaQuery.of(context).size.width < 1220
                                            ? 12
                                            : MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                102.4),
                                contentPadding: EdgeInsets.only(
                                    left: MediaQuery.of(context).size.width /
                                        51.2),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.blueGrey.withOpacity(0.05),
                                  ),
                                  borderRadius: BorderRadius.circular(
                                      MediaQuery.of(context).size.width /
                                          102.4),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.blueGrey.withOpacity(0.05),
                                  ),
                                  borderRadius: BorderRadius.circular(
                                      MediaQuery.of(context).size.width /
                                          102.4),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Container(
                      margin: EdgeInsets.only(bottom: 30),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width / 3,
                            child: TextFormField(
                              controller: emailidcontroller,
                              keyboardType: TextInputType.emailAddress,
                              textCapitalization: TextCapitalization.characters,
                              validator: (val) => ((val!.isEmpty))
                                  ? 'Enter your Email ID'
                                  : null,
                              onChanged: (val) {
                                setState(() {
                                  email = val;
                                });
                              },
                              decoration: InputDecoration(
                                hintText: 'Email ID',
                                filled: true,
                                fillColor: Colors.blueGrey[50],
                                labelStyle: TextStyle(
                                    fontSize:
                                        MediaQuery.of(context).size.width /
                                            128),
                                hintStyle: TextStyle(
                                    fontSize:
                                        MediaQuery.of(context).size.width < 1220
                                            ? 12
                                            : MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                102.4),
                                contentPadding: EdgeInsets.only(
                                    left: MediaQuery.of(context).size.width /
                                        51.2),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.blueGrey.withOpacity(0.05),
                                  ),
                                  borderRadius: BorderRadius.circular(
                                      MediaQuery.of(context).size.width /
                                          102.4),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.blueGrey.withOpacity(0.05),
                                  ),
                                  borderRadius: BorderRadius.circular(
                                      MediaQuery.of(context).size.width /
                                          102.4),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width / 3,
                            child: TextFormField(
                              controller: mobilenocontroller,
                              keyboardType: TextInputType.phone,
                              validator: (val) => ((val!.isEmpty))
                                  ? 'Enter your mobile number'
                                  : null,
                              onChanged: (val) {
                                setState(() {
                                  mobile = val;
                                });
                              },
                              decoration: InputDecoration(
                                hintText: '+91 - mobile number',
                                hintStyle: TextStyle(
                                    fontSize:
                                        MediaQuery.of(context).size.width < 1220
                                            ? 12
                                            : MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                102.4),
                                filled: true,
                                fillColor: Colors.blueGrey[50],
                                labelStyle: TextStyle(
                                    fontSize:
                                        MediaQuery.of(context).size.width /
                                            128),
                                contentPadding: EdgeInsets.only(
                                    left: MediaQuery.of(context).size.width /
                                        51.2),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.blueGrey.withOpacity(0.05),
                                  ),
                                  borderRadius: BorderRadius.circular(
                                      MediaQuery.of(context).size.width /
                                          102.4),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.blueGrey.withOpacity(0.05),
                                  ),
                                  borderRadius: BorderRadius.circular(
                                      MediaQuery.of(context).size.width /
                                          102.4),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Container(
                      margin: EdgeInsets.only(bottom: 30),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                              width: MediaQuery.of(context).size.width / 3,
                              padding: EdgeInsets.only(
                                  left:
                                      MediaQuery.of(context).size.width / 51.2),
                              decoration: BoxDecoration(
                                color: Colors.blueGrey[50],
                                borderRadius: BorderRadius.circular(
                                    MediaQuery.of(context).size.width / 102.4),
                              ),
                              child: DropdownButton<String>(
                                value: dropdownValueGender,
                                icon: Container(),
                                elevation: 7,
                                style: const TextStyle(
                                    color: Colors.black, fontSize: (16)),
                                underline: Container(
                                  height: 0.0,
                                  color: Colors.blueGrey[50],
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    dropdownValueGender = value!;
                                  });
                                },
                                items: <String>[
                                  'MALE',
                                  'FEMAILE',
                                  'OTHERS'
                                ].map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(
                                      value,
                                      style: TextStyle(
                                          fontSize: MediaQuery.of(context)
                                                      .size
                                                      .width <
                                                  1220
                                              ? 12
                                              : MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  102.4),
                                    ),
                                  );
                                }).toList(),
                              )),
                          Container(
                              width: MediaQuery.of(context).size.width / 3,
                              child: TextFormField(
                                  validator: (value) => (value!.isEmpty)
                                      ? 'Please choose your date of birth'
                                      : null,
                                  controller: personDOBcontroller,
                                  onChanged: (value) {
                                    setState(() {
                                      dob = value;
                                    });
                                  },
                                  onTap: () {
                                    showDatePicker(
                                            context: context,
                                            initialDate: DateTime.now(),
                                            firstDate: DateTime(1900),
                                            lastDate: DateTime.now())
                                        .then((value) {
                                      setState(() {
                                        dt = false;
                                        _dTime = value!;
                                        _selectedDate = DateFormat("dd/MM/yyyy")
                                            .format(_dTime);
                                        print(
                                          _selectedDate.substring(0, 10),
                                        );
                                        personDOBcontroller.text =
                                            _selectedDate;
                                        dob = _selectedDate;
                                      });
                                    });
                                  },
                                  decoration: InputDecoration(
                                    labelText: 'DD//MM//YY',
                                    filled: true,
                                    fillColor: Colors.blueGrey[50],
                                    labelStyle: TextStyle(
                                        fontSize:
                                            MediaQuery.of(context).size.width <
                                                    1220
                                                ? 12
                                                : MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    102.4),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color:
                                            Colors.blueGrey.withOpacity(0.05),
                                      ),
                                      borderRadius: BorderRadius.circular(
                                          MediaQuery.of(context).size.width /
                                              102.4),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color:
                                            Colors.blueGrey.withOpacity(0.05),
                                      ),
                                      borderRadius: BorderRadius.circular(
                                          MediaQuery.of(context).size.width /
                                              102.4),
                                    ),
                                  ))),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Container(
                      margin: EdgeInsets.only(bottom: 30),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                              width: MediaQuery.of(context).size.width / 3,
                              decoration: BoxDecoration(
                                color: Colors.blueGrey[50],
                                borderRadius: BorderRadius.circular(
                                    MediaQuery.of(context).size.width / 102.4),
                              ),
                              child: TextFormField(
                                textCapitalization:
                                    TextCapitalization.characters,
                                validator: (value) => (value!.isEmpty)
                                    ? 'Please type your address'
                                    : null,
                                controller: personaddresscontroller,
                                onChanged: (val) {
                                  setState(() {
                                    _streetnum = val;
                                  });
                                },
                                onTap: () async {
                                  if (_streetnum == '') {
                                    personaddresscontroller =
                                        TextEditingController();
                                    personstreetcontroller =
                                        TextEditingController();
                                    personcitycontroller =
                                        TextEditingController();
                                    personstatecontroller =
                                        TextEditingController();
                                    _street = '';
                                    _city = '';
                                    _state = '';

                                    final sessionToken = Uuid().v4();
                                    final Suggestion? result = await showSearch(
                                      context: context,
                                      delegate: AddressSearch(sessionToken),
                                    );
                                    if (result != null) {
                                      final placeDetails =
                                          await PlaceApiProvider(sessionToken)
                                              .getPlaceDetailFromId1(
                                                  result.placeId);
                                      setState(() {
                                        _showLoadingDialog();
                                        _streetnum = placeDetails.streetNumber;
                                        personaddresscontroller.text =
                                            placeDetails.streetNumber;
                                        personstreetcontroller.text =
                                            placeDetails.street;
                                        _street = placeDetails.street;
                                        personcitycontroller.text =
                                            placeDetails.city;
                                        _city = placeDetails.city;
                                        personstatecontroller.text =
                                            placeDetails.zipCode;
                                        _state = placeDetails.zipCode;
                                        print("ok");
                                        Navigator.pop(context);
                                      });
                                    }
                                  }
                                },
                                decoration: InputDecoration(
                                  hintText: 'Address',
                                  hintStyle: TextStyle(
                                      fontSize: MediaQuery.of(context)
                                                  .size
                                                  .width <
                                              1220
                                          ? 12
                                          : MediaQuery.of(context).size.width /
                                              102.4),
                                  filled: true,
                                  fillColor: Colors.blueGrey[50],
                                  labelStyle: TextStyle(
                                      fontSize:
                                          MediaQuery.of(context).size.width /
                                              128),
                                  contentPadding: EdgeInsets.only(
                                      left: MediaQuery.of(context).size.width /
                                          51.2),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.blueGrey.withOpacity(0.05),
                                    ),
                                    borderRadius: BorderRadius.circular(
                                        MediaQuery.of(context).size.width /
                                            102.4),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.blueGrey.withOpacity(0.05),
                                    ),
                                    borderRadius: BorderRadius.circular(
                                        MediaQuery.of(context).size.width /
                                            102.4),
                                  ),
                                ),
                              )),
                          Container(
                              width: MediaQuery.of(context).size.width / 3,
                              decoration: BoxDecoration(
                                color: Colors.blueGrey[50],
                                borderRadius: BorderRadius.circular(
                                    MediaQuery.of(context).size.width / 102.4),
                              ),
                              child: TextFormField(
                                textCapitalization:
                                    TextCapitalization.characters,
                                validator: (value) => (value!.isEmpty)
                                    ? 'Please type your street'
                                    : null,
                                controller: personstreetcontroller,
                                onChanged: (val) {
                                  setState(() {
                                    _streetnum = val;
                                  });
                                },
                                decoration: InputDecoration(
                                  hintText: 'Street',
                                  hintStyle: TextStyle(
                                      fontSize: MediaQuery.of(context)
                                                  .size
                                                  .width <
                                              1220
                                          ? 12
                                          : MediaQuery.of(context).size.width /
                                              102.4),
                                  filled: true,
                                  fillColor: Colors.blueGrey[50],
                                  labelStyle: TextStyle(
                                      fontSize:
                                          MediaQuery.of(context).size.width /
                                              128),
                                  contentPadding: EdgeInsets.only(
                                      left: MediaQuery.of(context).size.width /
                                          51.2),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.blueGrey.withOpacity(0.05),
                                    ),
                                    borderRadius: BorderRadius.circular(
                                        MediaQuery.of(context).size.width /
                                            102.4),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.blueGrey.withOpacity(0.05),
                                    ),
                                    borderRadius: BorderRadius.circular(
                                        MediaQuery.of(context).size.width /
                                            102.4),
                                  ),
                                ),
                              )),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Container(
                      margin: EdgeInsets.only(bottom: 30),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                              width: MediaQuery.of(context).size.width / 3,
                              decoration: BoxDecoration(
                                color: Colors.blueGrey[50],
                                borderRadius: BorderRadius.circular(
                                    MediaQuery.of(context).size.width / 102.4),
                              ),
                              child: TextFormField(
                                textCapitalization:
                                    TextCapitalization.characters,
                                validator: (value) => (value!.isEmpty)
                                    ? 'Please type your City'
                                    : null,
                                controller: personcitycontroller,
                                onChanged: (val) {
                                  setState(() {
                                    _streetnum = val;
                                  });
                                },
                                decoration: InputDecoration(
                                  hintText: 'City',
                                  hintStyle: TextStyle(
                                      fontSize: MediaQuery.of(context)
                                                  .size
                                                  .width <
                                              1220
                                          ? 12
                                          : MediaQuery.of(context).size.width /
                                              102.4),
                                  filled: true,
                                  fillColor: Colors.blueGrey[50],
                                  labelStyle: TextStyle(
                                      fontSize:
                                          MediaQuery.of(context).size.width /
                                              128),
                                  contentPadding: EdgeInsets.only(
                                      left: MediaQuery.of(context).size.width /
                                          51.2),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.blueGrey.withOpacity(0.05),
                                    ),
                                    borderRadius: BorderRadius.circular(
                                        MediaQuery.of(context).size.width /
                                            102.4),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.blueGrey.withOpacity(0.05),
                                    ),
                                    borderRadius: BorderRadius.circular(
                                        MediaQuery.of(context).size.width /
                                            102.4),
                                  ),
                                ),
                              )),
                          Container(
                              width: MediaQuery.of(context).size.width / 3,
                              decoration: BoxDecoration(
                                color: Colors.blueGrey[50],
                                borderRadius: BorderRadius.circular(
                                    MediaQuery.of(context).size.width / 102.4),
                              ),
                              child: TextFormField(
                                textCapitalization:
                                    TextCapitalization.characters,
                                validator: (value) => (value!.isEmpty)
                                    ? 'Please type your State'
                                    : null,
                                controller: personstatecontroller,
                                onChanged: (val) {
                                  setState(() {
                                    _streetnum = val;
                                  });
                                },
                                decoration: InputDecoration(
                                  hintText: 'State',
                                  hintStyle: TextStyle(
                                      fontSize: MediaQuery.of(context)
                                                  .size
                                                  .width <
                                              1220
                                          ? 12
                                          : MediaQuery.of(context).size.width /
                                              102.4),
                                  filled: true,
                                  fillColor: Colors.blueGrey[50],
                                  labelStyle: TextStyle(
                                      fontSize:
                                          MediaQuery.of(context).size.width /
                                              128),
                                  contentPadding: EdgeInsets.only(
                                      left: MediaQuery.of(context).size.width /
                                          51.2),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.blueGrey.withOpacity(0.05),
                                    ),
                                    borderRadius: BorderRadius.circular(
                                        MediaQuery.of(context).size.width /
                                            102.4),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.blueGrey.withOpacity(0.05),
                                    ),
                                    borderRadius: BorderRadius.circular(
                                        MediaQuery.of(context).size.width /
                                            102.4),
                                  ),
                                ),
                              )),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Container(
                      margin: EdgeInsets.only(bottom: 30),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                              width: MediaQuery.of(context).size.width / 3,
                              decoration: BoxDecoration(
                                color: Colors.blueGrey[50],
                                borderRadius: BorderRadius.circular(
                                    MediaQuery.of(context).size.width / 102.4),
                              ),
                              child: TextFormField(
                                initialValue: "INDIA",
                                readOnly: true,
                                textCapitalization:
                                    TextCapitalization.characters,
                                validator: (value) => (value!.isEmpty)
                                    ? 'Please type your country'
                                    : null,
                                decoration: InputDecoration(
                                  hintText: 'Street',
                                  hintStyle: TextStyle(
                                      fontSize: MediaQuery.of(context)
                                                  .size
                                                  .width <
                                              1220
                                          ? 12
                                          : MediaQuery.of(context).size.width /
                                              102.4),
                                  filled: true,
                                  fillColor: Colors.blueGrey[50],
                                  labelStyle: TextStyle(
                                      fontSize:
                                          MediaQuery.of(context).size.width /
                                              128),
                                  contentPadding: EdgeInsets.only(
                                      left: MediaQuery.of(context).size.width /
                                          51.2),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.blueGrey.withOpacity(0.05),
                                    ),
                                    borderRadius: BorderRadius.circular(
                                        MediaQuery.of(context).size.width /
                                            102.4),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.blueGrey.withOpacity(0.05),
                                    ),
                                    borderRadius: BorderRadius.circular(
                                        MediaQuery.of(context).size.width /
                                            102.4),
                                  ),
                                ),
                              )),
                          InkWell(
                            onTap: () {
                              showBarModalBottomSheet(
                                  context: context,
                                  builder: (context) =>
                                      _preferredLanguage(context));
                            },
                            child: Container(
                                width: MediaQuery.of(context).size.width / 3,
                                padding: EdgeInsets.only(
                                    left: MediaQuery.of(context).size.width /
                                        51.2,
                                    top: 15,
                                    bottom: 15),
                                decoration: BoxDecoration(
                                  color: Colors.blueGrey[50],
                                  border: Border.all(
                                    color: Colors.blueGrey.withOpacity(0.05),
                                  ),
                                  borderRadius: BorderRadius.circular(
                                      MediaQuery.of(context).size.width /
                                          102.4),
                                ),
                                child: Text(
                                    preferredLanguage.length == 0
                                        ? "Preffer Languages"
                                        : (preferredLanguage
                                            .toString()
                                            .substring(
                                                1,
                                                (preferredLanguage.toString())
                                                        .length -
                                                    1)),
                                    style: TextStyle(
                                        fontSize:
                                            MediaQuery.of(context).size.width <
                                                    1220
                                                ? 12
                                                : MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    96))),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            duration: Duration(seconds: 1),
            curve: Curves.easeIn,
          );
  }

  _school_details() {
    return MediaQuery.of(context).size.width > 940
        ? FadeIn(
            child: Form(
              key: _formKeySchoolDetails,
              child: Container(
                margin: EdgeInsets.all(30),
                child: Column(
                  children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          SizedBox(
                            width: 300,
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width / 5.12,
                          ),
                          InkWell(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.deepPurple.withOpacity(0.1),
                                    spreadRadius: 10,
                                    blurRadius: 20,
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                child: Container(
                                    width: 100,
                                    height: 40,
                                    child: Center(child: Text("SUBMIT"))),
                                onPressed: () async {
                                  print("button pressed");
                                  if (_formKeySchoolDetails.currentState!
                                      .validate()) {
                                    print("form validation: correct");
                                    setState(() {
                                      _loadStrengthWeaknessData("strength");
                                    });
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  primary: active,
                                  onPrimary: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        MediaQuery.of(context).size.width /
                                            102.4),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ]),
                    SizedBox(
                      height: 60,
                    ),
                    Container(
                      margin: EdgeInsets.only(bottom: 30),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width / 5.12,
                            child: TextFormField(
                              controller: schoolnamecontroller,
                              keyboardType: TextInputType.name,
                              textCapitalization: TextCapitalization.sentences,
                              validator: (val) => ((val!.isEmpty))
                                  ? 'Enter your school name'
                                  : null,
                              onChanged: (val) {
                                setState(() {
                                  sname = val;
                                });
                              },
                              decoration: InputDecoration(
                                hintText: 'School name',
                                hintStyle: TextStyle(
                                    fontSize:
                                        MediaQuery.of(context).size.width < 1220
                                            ? 12
                                            : MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                102.4),
                                filled: true,
                                fillColor: Colors.blueGrey[50],
                                labelStyle: TextStyle(
                                    fontSize:
                                        MediaQuery.of(context).size.width /
                                            128),
                                contentPadding: EdgeInsets.only(
                                    left: MediaQuery.of(context).size.width /
                                        51.2),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.blueGrey.withOpacity(0.05),
                                  ),
                                  borderRadius: BorderRadius.circular(
                                      MediaQuery.of(context).size.width /
                                          102.4),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.blueGrey.withOpacity(0.05),
                                  ),
                                  borderRadius: BorderRadius.circular(
                                      MediaQuery.of(context).size.width /
                                          102.4),
                                ),
                              ),
                            ),
                          ),
                          Container(
                              width: MediaQuery.of(context).size.width / 5.12,
                              padding: EdgeInsets.only(
                                  left:
                                      MediaQuery.of(context).size.width / 51.2),
                              decoration: BoxDecoration(
                                color: Colors.blueGrey[50],
                                borderRadius: BorderRadius.circular(
                                    MediaQuery.of(context).size.width / 102.4),
                              ),
                              child: DropdownButton<String>(
                                value: dropdownValueGrade,
                                icon: Container(),
                                elevation: 7,
                                style: const TextStyle(
                                    color: Colors.black, fontSize: 16),
                                underline: Container(
                                  height: 0.0,
                                  color: Colors.blueGrey[50],
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    dropdownValueGrade = value!;
                                  });
                                },
                                items: <String>[
                                  'Grade',
                                  '7',
                                  '8',
                                  '9',
                                  '10',
                                  '11',
                                  '12',
                                ].map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(
                                      value,
                                      style: TextStyle(
                                          fontSize: MediaQuery.of(context)
                                                      .size
                                                      .width <
                                                  1220
                                              ? 12
                                              : MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  102.4),
                                    ),
                                  );
                                }).toList(),
                              )),
                          Container(
                              width: MediaQuery.of(context).size.width / 5.12,
                              padding: EdgeInsets.only(
                                  left:
                                      MediaQuery.of(context).size.width / 51.2),
                              decoration: BoxDecoration(
                                color: Colors.blueGrey[50],
                                borderRadius: BorderRadius.circular(
                                    MediaQuery.of(context).size.width / 102.4),
                              ),
                              child: DropdownButton<String>(
                                value: dropdownValueBoard,
                                icon: Container(),
                                elevation: 7,
                                style: const TextStyle(
                                    color: Colors.black, fontSize: 16),
                                underline: Container(
                                  height: 0.0,
                                  color: Colors.blueGrey[50],
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    dropdownValueBoard = value!;
                                  });
                                },
                                items: <String>[
                                  "Select board",
                                  "CBSE",
                                  "ICSE",
                                  "NIOS",
                                  "Andhra Pradesh State Board",
                                  "Assam State Board",
                                  "Bihar State Board",
                                  "Chhattisgarh State Board",
                                  "Goa State Board",
                                  "Gujarat State Board",
                                  "Haryana State Board",
                                  "Himachal Pradesh State Board",
                                  "J& K State Board",
                                  "Jharkhand State Board",
                                  "Karnataka State Board",
                                  "Kerala State Board",
                                  "Madhya Pradesh State Board",
                                  "Maharashtra State Board",
                                  "Manipur State Board",
                                  "Meghalaya State Board",
                                  "Mizoram State Board",
                                  "Nagaland State Board",
                                  "Odisha State Board",
                                  "Puducherry State Board",
                                  "Punjab State Board",
                                  "Rajasthan State Board",
                                  "Tamil Nadu State Board",
                                  "Telangana State Board",
                                  "Tripura State Board",
                                  "Uttar Pradesh State Board",
                                  "Uttarakhand State Board",
                                  "West Bengal State Board"
                                ].map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(
                                      value,
                                      style: TextStyle(
                                          fontSize: MediaQuery.of(context)
                                                      .size
                                                      .width <
                                                  1220
                                              ? 12
                                              : MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  102.4),
                                    ),
                                  );
                                }).toList(),
                              )),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Container(
                      margin: EdgeInsets.only(bottom: 30),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                              width: MediaQuery.of(context).size.width / 5.12,
                              decoration: BoxDecoration(
                                color: Colors.blueGrey[50],
                                borderRadius: BorderRadius.circular(
                                    MediaQuery.of(context).size.width / 102.4),
                              ),
                              child: TextFormField(
                                textCapitalization:
                                    TextCapitalization.characters,
                                validator: (value) => (value!.isEmpty)
                                    ? 'Please type your school address'
                                    : null,
                                controller: schooladdresscontroller,
                                onChanged: (val) {
                                  setState(() {
                                    _streetnum = val;
                                  });
                                },
                                onTap: () async {
                                  if (_streetnum == '') {
                                    personaddresscontroller =
                                        TextEditingController();
                                    personstreetcontroller =
                                        TextEditingController();
                                    personcitycontroller =
                                        TextEditingController();
                                    personstatecontroller =
                                        TextEditingController();
                                    _street = '';
                                    _city = '';
                                    _state = '';

                                    final sessionToken = Uuid().v4();
                                    final Suggestion? result = await showSearch(
                                      context: context,
                                      delegate: AddressSearch(sessionToken),
                                    );
                                    if (result != null) {
                                      final placeDetails =
                                          await PlaceApiProvider(sessionToken)
                                              .getPlaceDetailFromId1(
                                                  result.placeId);
                                      setState(() {
                                        _showLoadingDialog();
                                        _streetnum = placeDetails.streetNumber;
                                        personaddresscontroller.text =
                                            placeDetails.streetNumber;
                                        personstreetcontroller.text =
                                            placeDetails.street;
                                        _street = placeDetails.street;
                                        personcitycontroller.text =
                                            placeDetails.city;
                                        _city = placeDetails.city;
                                        personstatecontroller.text =
                                            placeDetails.zipCode;
                                        _state = placeDetails.zipCode;
                                        print("ok");
                                        Navigator.pop(context);
                                      });
                                    }
                                  }
                                },
                                decoration: InputDecoration(
                                  hintText: 'School address',
                                  hintStyle: TextStyle(
                                      fontSize: MediaQuery.of(context)
                                                  .size
                                                  .width <
                                              1220
                                          ? 12
                                          : MediaQuery.of(context).size.width /
                                              102.4),
                                  filled: true,
                                  fillColor: Colors.blueGrey[50],
                                  labelStyle: TextStyle(
                                      fontSize:
                                          MediaQuery.of(context).size.width /
                                              128),
                                  contentPadding: EdgeInsets.only(
                                      left: MediaQuery.of(context).size.width /
                                          51.2),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.blueGrey.withOpacity(0.05),
                                    ),
                                    borderRadius: BorderRadius.circular(
                                        MediaQuery.of(context).size.width /
                                            102.4),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.blueGrey.withOpacity(0.05),
                                    ),
                                    borderRadius: BorderRadius.circular(
                                        MediaQuery.of(context).size.width /
                                            102.4),
                                  ),
                                ),
                              )),
                          Container(
                              width: MediaQuery.of(context).size.width / 5.12,
                              decoration: BoxDecoration(
                                color: Colors.blueGrey[50],
                                borderRadius: BorderRadius.circular(
                                    MediaQuery.of(context).size.width / 102.4),
                              ),
                              child: TextFormField(
                                textCapitalization:
                                    TextCapitalization.characters,
                                validator: (value) => (value!.isEmpty)
                                    ? 'Please type your school street'
                                    : null,
                                controller: schoolstreetcontroller,
                                onChanged: (val) {
                                  setState(() {
                                    sArea = val;
                                  });
                                },
                                decoration: InputDecoration(
                                  hintText: 'School street',
                                  hintStyle: TextStyle(
                                      fontSize: MediaQuery.of(context)
                                                  .size
                                                  .width <
                                              1220
                                          ? 12
                                          : MediaQuery.of(context).size.width /
                                              102.4),
                                  filled: true,
                                  fillColor: Colors.blueGrey[50],
                                  labelStyle: TextStyle(
                                      fontSize:
                                          MediaQuery.of(context).size.width /
                                              128),
                                  contentPadding: EdgeInsets.only(
                                      left: MediaQuery.of(context).size.width /
                                          51.2),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.blueGrey.withOpacity(0.05),
                                    ),
                                    borderRadius: BorderRadius.circular(
                                        MediaQuery.of(context).size.width /
                                            102.4),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.blueGrey.withOpacity(0.05),
                                    ),
                                    borderRadius: BorderRadius.circular(
                                        MediaQuery.of(context).size.width /
                                            102.4),
                                  ),
                                ),
                              )),
                          Container(
                              width: MediaQuery.of(context).size.width / 5.12,
                              decoration: BoxDecoration(
                                color: Colors.blueGrey[50],
                                borderRadius: BorderRadius.circular(
                                    MediaQuery.of(context).size.width / 102.4),
                              ),
                              child: TextFormField(
                                textCapitalization:
                                    TextCapitalization.characters,
                                validator: (value) => (value!.isEmpty)
                                    ? 'Please type your school city'
                                    : null,
                                controller: schoolcitycontroller,
                                onChanged: (val) {
                                  setState(() {
                                    sCity = val;
                                  });
                                },
                                decoration: InputDecoration(
                                  hintText: 'City',
                                  hintStyle: TextStyle(
                                      fontSize: MediaQuery.of(context)
                                                  .size
                                                  .width <
                                              1220
                                          ? 12
                                          : MediaQuery.of(context).size.width /
                                              102.4),
                                  filled: true,
                                  fillColor: Colors.blueGrey[50],
                                  labelStyle: TextStyle(
                                      fontSize:
                                          MediaQuery.of(context).size.width /
                                              128),
                                  contentPadding: EdgeInsets.only(
                                      left: MediaQuery.of(context).size.width /
                                          51.2),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.blueGrey.withOpacity(0.05),
                                    ),
                                    borderRadius: BorderRadius.circular(
                                        MediaQuery.of(context).size.width /
                                            102.4),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.blueGrey.withOpacity(0.05),
                                    ),
                                    borderRadius: BorderRadius.circular(
                                        MediaQuery.of(context).size.width /
                                            102.4),
                                  ),
                                ),
                              )),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Container(
                      margin: EdgeInsets.only(bottom: 30),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                              width: MediaQuery.of(context).size.width / 5.12,
                              decoration: BoxDecoration(
                                color: Colors.blueGrey[50],
                                borderRadius: BorderRadius.circular(
                                    MediaQuery.of(context).size.width / 102.4),
                              ),
                              child: TextFormField(
                                textCapitalization:
                                    TextCapitalization.characters,
                                validator: (value) => (value!.isEmpty)
                                    ? 'Please type your school state'
                                    : null,
                                controller: schoolstatecontroller,
                                onChanged: (val) {
                                  setState(() {
                                    sState = val;
                                  });
                                },
                                decoration: InputDecoration(
                                  hintText: 'School state',
                                  hintStyle: TextStyle(
                                      fontSize: MediaQuery.of(context)
                                                  .size
                                                  .width <
                                              1220
                                          ? 12
                                          : MediaQuery.of(context).size.width /
                                              102.4),
                                  filled: true,
                                  fillColor: Colors.blueGrey[50],
                                  labelStyle: TextStyle(
                                      fontSize:
                                          MediaQuery.of(context).size.width /
                                              128),
                                  contentPadding: EdgeInsets.only(
                                      left: MediaQuery.of(context).size.width /
                                          51.2),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.blueGrey.withOpacity(0.05),
                                    ),
                                    borderRadius: BorderRadius.circular(
                                        MediaQuery.of(context).size.width /
                                            102.4),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.blueGrey.withOpacity(0.05),
                                    ),
                                    borderRadius: BorderRadius.circular(
                                        MediaQuery.of(context).size.width /
                                            102.4),
                                  ),
                                ),
                              )),
                          Container(
                              width: MediaQuery.of(context).size.width / 5.12,
                              decoration: BoxDecoration(
                                color: Colors.blueGrey[50],
                                borderRadius: BorderRadius.circular(
                                    MediaQuery.of(context).size.width / 102.4),
                              ),
                              child: TextFormField(
                                initialValue: "INDIA",
                                readOnly: true,
                                textCapitalization:
                                    TextCapitalization.characters,
                                validator: (value) => (value!.isEmpty)
                                    ? 'Please type your country'
                                    : null,
                                decoration: InputDecoration(
                                  hintText: 'Country',
                                  hintStyle: TextStyle(
                                      fontSize: MediaQuery.of(context)
                                                  .size
                                                  .width <
                                              1220
                                          ? 12
                                          : MediaQuery.of(context).size.width /
                                              102.4),
                                  filled: true,
                                  fillColor: Colors.blueGrey[50],
                                  labelStyle: TextStyle(
                                      fontSize:
                                          MediaQuery.of(context).size.width /
                                              128),
                                  contentPadding: EdgeInsets.only(
                                      left: MediaQuery.of(context).size.width /
                                          51.2),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.blueGrey.withOpacity(0.05),
                                    ),
                                    borderRadius: BorderRadius.circular(
                                        MediaQuery.of(context).size.width /
                                            102.4),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.blueGrey.withOpacity(0.05),
                                    ),
                                    borderRadius: BorderRadius.circular(
                                        MediaQuery.of(context).size.width /
                                            102.4),
                                  ),
                                ),
                              )),
                          SizedBox(
                            width: 300,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            duration: Duration(seconds: 1),
            curve: Curves.easeIn,
          )
        : FadeIn(
            child: Form(
              key: _formKeySchoolDetails,
              child: Container(
                margin: EdgeInsets.all(30),
                child: Column(
                  children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width / 5.12,
                          ),
                          InkWell(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.deepPurple.withOpacity(0.1),
                                    spreadRadius: 10,
                                    blurRadius: 20,
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                child: Container(
                                    width: 100,
                                    height: 40,
                                    child: Center(child: Text("SUBMIT"))),
                                onPressed: () async {
                                  print("button pressed");
                                  if (_formKeySchoolDetails.currentState!
                                      .validate()) {
                                    print("form validation: correct");
                                    setState(() {
                                      _loadStrengthWeaknessData("strength");
                                    });
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  primary: active,
                                  onPrimary: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        MediaQuery.of(context).size.width /
                                            102.4),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ]),
                    SizedBox(
                      height: 60,
                    ),
                    Container(
                      margin: EdgeInsets.only(bottom: 30),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width / 3,
                            child: TextFormField(
                              controller: schoolnamecontroller,
                              keyboardType: TextInputType.name,
                              textCapitalization: TextCapitalization.sentences,
                              validator: (val) => ((val!.isEmpty))
                                  ? 'Enter your school name'
                                  : null,
                              onChanged: (val) {
                                setState(() {
                                  sname = val;
                                });
                              },
                              decoration: InputDecoration(
                                hintText: 'School name',
                                hintStyle: TextStyle(
                                    fontSize:
                                        MediaQuery.of(context).size.width < 1220
                                            ? 12
                                            : MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                102.4),
                                filled: true,
                                fillColor: Colors.blueGrey[50],
                                labelStyle: TextStyle(
                                    fontSize:
                                        MediaQuery.of(context).size.width /
                                            128),
                                contentPadding: EdgeInsets.only(
                                    left: MediaQuery.of(context).size.width /
                                        51.2),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.blueGrey.withOpacity(0.05),
                                  ),
                                  borderRadius: BorderRadius.circular(
                                      MediaQuery.of(context).size.width /
                                          102.4),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.blueGrey.withOpacity(0.05),
                                  ),
                                  borderRadius: BorderRadius.circular(
                                      MediaQuery.of(context).size.width /
                                          102.4),
                                ),
                              ),
                            ),
                          ),
                          Container(
                              width: MediaQuery.of(context).size.width / 3,
                              padding: EdgeInsets.only(
                                  left:
                                      MediaQuery.of(context).size.width / 51.2),
                              decoration: BoxDecoration(
                                color: Colors.blueGrey[50],
                                borderRadius: BorderRadius.circular(
                                    MediaQuery.of(context).size.width / 102.4),
                              ),
                              child: DropdownButton<String>(
                                value: dropdownValueGrade,
                                icon: Container(),
                                elevation: 7,
                                style: const TextStyle(
                                    color: Colors.black, fontSize: 16),
                                underline: Container(
                                  height: 0.0,
                                  color: Colors.blueGrey[50],
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    dropdownValueGrade = value!;
                                  });
                                },
                                items: <String>[
                                  'Grade',
                                  '7',
                                  '8',
                                  '9',
                                  '10',
                                  '11',
                                  '12',
                                ].map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(
                                      value,
                                      style: TextStyle(
                                          fontSize: MediaQuery.of(context)
                                                      .size
                                                      .width <
                                                  1220
                                              ? 12
                                              : MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  102.4),
                                    ),
                                  );
                                }).toList(),
                              )),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Container(
                      margin: EdgeInsets.only(bottom: 30),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                              width: MediaQuery.of(context).size.width / 3,
                              decoration: BoxDecoration(
                                color: Colors.blueGrey[50],
                                borderRadius: BorderRadius.circular(
                                    MediaQuery.of(context).size.width / 102.4),
                              ),
                              child: TextFormField(
                                textCapitalization:
                                    TextCapitalization.characters,
                                validator: (value) => (value!.isEmpty)
                                    ? 'Please type your school address'
                                    : null,
                                controller: schooladdresscontroller,
                                onChanged: (val) {
                                  setState(() {
                                    _streetnum = val;
                                  });
                                },
                                onTap: () async {
                                  if (_streetnum == '') {
                                    personaddresscontroller =
                                        TextEditingController();
                                    personstreetcontroller =
                                        TextEditingController();
                                    personcitycontroller =
                                        TextEditingController();
                                    personstatecontroller =
                                        TextEditingController();
                                    _street = '';
                                    _city = '';
                                    _state = '';

                                    final sessionToken = Uuid().v4();
                                    final Suggestion? result = await showSearch(
                                      context: context,
                                      delegate: AddressSearch(sessionToken),
                                    );
                                    if (result != null) {
                                      final placeDetails =
                                          await PlaceApiProvider(sessionToken)
                                              .getPlaceDetailFromId1(
                                                  result.placeId);
                                      setState(() {
                                        _showLoadingDialog();
                                        _streetnum = placeDetails.streetNumber;
                                        personaddresscontroller.text =
                                            placeDetails.streetNumber;
                                        personstreetcontroller.text =
                                            placeDetails.street;
                                        _street = placeDetails.street;
                                        personcitycontroller.text =
                                            placeDetails.city;
                                        _city = placeDetails.city;
                                        personstatecontroller.text =
                                            placeDetails.zipCode;
                                        _state = placeDetails.zipCode;
                                        print("ok");
                                        Navigator.pop(context);
                                      });
                                    }
                                  }
                                },
                                decoration: InputDecoration(
                                  hintText: 'School address',
                                  hintStyle: TextStyle(
                                      fontSize: MediaQuery.of(context)
                                                  .size
                                                  .width <
                                              1220
                                          ? 12
                                          : MediaQuery.of(context).size.width /
                                              102.4),
                                  filled: true,
                                  fillColor: Colors.blueGrey[50],
                                  labelStyle: TextStyle(
                                      fontSize:
                                          MediaQuery.of(context).size.width /
                                              128),
                                  contentPadding: EdgeInsets.only(
                                      left: MediaQuery.of(context).size.width /
                                          51.2),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.blueGrey.withOpacity(0.05),
                                    ),
                                    borderRadius: BorderRadius.circular(
                                        MediaQuery.of(context).size.width /
                                            102.4),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.blueGrey.withOpacity(0.05),
                                    ),
                                    borderRadius: BorderRadius.circular(
                                        MediaQuery.of(context).size.width /
                                            102.4),
                                  ),
                                ),
                              )),
                          Container(
                              width: MediaQuery.of(context).size.width / 3,
                              decoration: BoxDecoration(
                                color: Colors.blueGrey[50],
                                borderRadius: BorderRadius.circular(
                                    MediaQuery.of(context).size.width / 102.4),
                              ),
                              child: TextFormField(
                                textCapitalization:
                                    TextCapitalization.characters,
                                validator: (value) => (value!.isEmpty)
                                    ? 'Please type your school street'
                                    : null,
                                controller: schoolstreetcontroller,
                                onChanged: (val) {
                                  setState(() {
                                    sArea = val;
                                  });
                                },
                                decoration: InputDecoration(
                                  hintText: 'School street',
                                  hintStyle: TextStyle(
                                      fontSize: MediaQuery.of(context)
                                                  .size
                                                  .width <
                                              1220
                                          ? 12
                                          : MediaQuery.of(context).size.width /
                                              102.4),
                                  filled: true,
                                  fillColor: Colors.blueGrey[50],
                                  labelStyle: TextStyle(
                                      fontSize:
                                          MediaQuery.of(context).size.width /
                                              128),
                                  contentPadding: EdgeInsets.only(
                                      left: MediaQuery.of(context).size.width /
                                          51.2),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.blueGrey.withOpacity(0.05),
                                    ),
                                    borderRadius: BorderRadius.circular(
                                        MediaQuery.of(context).size.width /
                                            102.4),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.blueGrey.withOpacity(0.05),
                                    ),
                                    borderRadius: BorderRadius.circular(
                                        MediaQuery.of(context).size.width /
                                            102.4),
                                  ),
                                ),
                              )),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Container(
                      margin: EdgeInsets.only(bottom: 30),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                              width: MediaQuery.of(context).size.width / 3,
                              decoration: BoxDecoration(
                                color: Colors.blueGrey[50],
                                borderRadius: BorderRadius.circular(
                                    MediaQuery.of(context).size.width / 102.4),
                              ),
                              child: TextFormField(
                                textCapitalization:
                                    TextCapitalization.characters,
                                validator: (value) => (value!.isEmpty)
                                    ? 'Please type your school city'
                                    : null,
                                controller: schoolcitycontroller,
                                onChanged: (val) {
                                  setState(() {
                                    sCity = val;
                                  });
                                },
                                decoration: InputDecoration(
                                  hintText: 'City',
                                  hintStyle: TextStyle(
                                      fontSize: MediaQuery.of(context)
                                                  .size
                                                  .width <
                                              1220
                                          ? 12
                                          : MediaQuery.of(context).size.width /
                                              102.4),
                                  filled: true,
                                  fillColor: Colors.blueGrey[50],
                                  labelStyle: TextStyle(
                                      fontSize:
                                          MediaQuery.of(context).size.width /
                                              128),
                                  contentPadding: EdgeInsets.only(
                                      left: MediaQuery.of(context).size.width /
                                          51.2),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.blueGrey.withOpacity(0.05),
                                    ),
                                    borderRadius: BorderRadius.circular(
                                        MediaQuery.of(context).size.width /
                                            102.4),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.blueGrey.withOpacity(0.05),
                                    ),
                                    borderRadius: BorderRadius.circular(
                                        MediaQuery.of(context).size.width /
                                            102.4),
                                  ),
                                ),
                              )),
                          Container(
                              width: MediaQuery.of(context).size.width / 3,
                              decoration: BoxDecoration(
                                color: Colors.blueGrey[50],
                                borderRadius: BorderRadius.circular(
                                    MediaQuery.of(context).size.width / 102.4),
                              ),
                              child: TextFormField(
                                textCapitalization:
                                    TextCapitalization.characters,
                                validator: (value) => (value!.isEmpty)
                                    ? 'Please type your school state'
                                    : null,
                                controller: schoolstatecontroller,
                                onChanged: (val) {
                                  setState(() {
                                    sState = val;
                                  });
                                },
                                decoration: InputDecoration(
                                  hintText: 'School state',
                                  hintStyle: TextStyle(
                                      fontSize: MediaQuery.of(context)
                                                  .size
                                                  .width <
                                              1220
                                          ? 12
                                          : MediaQuery.of(context).size.width /
                                              102.4),
                                  filled: true,
                                  fillColor: Colors.blueGrey[50],
                                  labelStyle: TextStyle(
                                      fontSize:
                                          MediaQuery.of(context).size.width /
                                              128),
                                  contentPadding: EdgeInsets.only(
                                      left: MediaQuery.of(context).size.width /
                                          51.2),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.blueGrey.withOpacity(0.05),
                                    ),
                                    borderRadius: BorderRadius.circular(
                                        MediaQuery.of(context).size.width /
                                            102.4),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.blueGrey.withOpacity(0.05),
                                    ),
                                    borderRadius: BorderRadius.circular(
                                        MediaQuery.of(context).size.width /
                                            102.4),
                                  ),
                                ),
                              )),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Container(
                      margin: EdgeInsets.only(bottom: 30),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                              width: 350,
                              padding: EdgeInsets.only(
                                  left:
                                      MediaQuery.of(context).size.width / 51.2),
                              decoration: BoxDecoration(
                                color: Colors.blueGrey[50],
                                borderRadius: BorderRadius.circular(
                                    MediaQuery.of(context).size.width / 102.4),
                              ),
                              child: DropdownButton<String>(
                                value: dropdownValueBoard,
                                icon: Container(),
                                elevation: 7,
                                style: const TextStyle(
                                    color: Colors.black, fontSize: 16),
                                underline: Container(
                                  height: 0.0,
                                  color: Colors.blueGrey[50],
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    dropdownValueBoard = value!;
                                  });
                                },
                                items: <String>[
                                  "Select board",
                                  "CBSE",
                                  "ICSE",
                                  "NIOS",
                                  "Andhra Pradesh State Board",
                                  "Assam State Board",
                                  "Bihar State Board",
                                  "Chhattisgarh State Board",
                                  "Goa State Board",
                                  "Gujarat State Board",
                                  "Haryana State Board",
                                  "Himachal Pradesh State Board",
                                  "J& K State Board",
                                  "Jharkhand State Board",
                                  "Karnataka State Board",
                                  "Kerala State Board",
                                  "Madhya Pradesh State Board",
                                  "Maharashtra State Board",
                                  "Manipur State Board",
                                  "Meghalaya State Board",
                                  "Mizoram State Board",
                                  "Nagaland State Board",
                                  "Odisha State Board",
                                  "Puducherry State Board",
                                  "Punjab State Board",
                                  "Rajasthan State Board",
                                  "Tamil Nadu State Board",
                                  "Telangana State Board",
                                  "Tripura State Board",
                                  "Uttar Pradesh State Board",
                                  "Uttarakhand State Board",
                                  "West Bengal State Board"
                                ].map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(
                                      value,
                                      style: TextStyle(
                                          fontSize: MediaQuery.of(context)
                                                      .size
                                                      .width <
                                                  1220
                                              ? 12
                                              : MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  102.4),
                                    ),
                                  );
                                }).toList(),
                              )),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            duration: Duration(seconds: 1),
            curve: Curves.easeIn,
          );
  }

  _strength_details() {
    if ((subjects != null) && (topics != null)) {
      return MediaQuery.of(context).size.width > 700
          ? FadeIn(
              child: InkWell(
                onTap: () {
                  _pc.close();
                },
                child: Container(
                  height: 900,
                  width: MediaQuery.of(context).size.width,
                  margin: EdgeInsets.all(30),
                  child: Column(
                    children: [
                      SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 15.0),
                            child: Text(
                              'Share Your Knowledge!',
                              style: TextStyle(
                                fontFamily: 'Nunito Sans',
                                fontSize: 35,
                                color: Color(0xCB000000),
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          InkWell(
                            child: Container(
                              margin: const EdgeInsets.only(right: 15.0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.deepPurple.withOpacity(0.1),
                                    spreadRadius: 10,
                                    blurRadius: 20,
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                child: Container(
                                    width: 100,
                                    height: 40,
                                    child: Center(child: Text("SUBMIT"))),
                                onPressed: () async {
                                  print("button pressed");
                                  setState(() {
                                    _current_active_tab = 3;
                                    if (totalselectedTopiccount > 0) {
                                      List<String> finalSelectedSubjects = [];
                                      List<List<String>> finalSelectedTopics =
                                          [];
                                      for (int a = 0;
                                          a < selectedtopicsbysubject.length;
                                          a++) {
                                        List<String> selectedFinaltopics = [];
                                        if (selectedtopicsbysubject[a] > 0) {
                                          finalSelectedSubjects
                                              .add(subjectList[a]);
                                        }
                                        for (int b = 0;
                                            b < topicList[a].length;
                                            b++) {
                                          if (boolTopicsList[a][b] == true) {
                                            selectedFinaltopics
                                                .add(topicList[a][b]);
                                          }
                                        }
                                        if (selectedFinaltopics.length > 0)
                                          finalSelectedTopics
                                              .add(selectedFinaltopics);
                                      }
                                      print(finalSelectedTopics);
                                      print(finalSelectedSubjects);
                                      finalSelectedStrengthSubjects =
                                          finalSelectedSubjects;
                                      finalSelectedStrengthTopics =
                                          finalSelectedTopics;
                                      finalSelectedSubjects = [];
                                      finalSelectedTopics = [];
                                      // for (int c = 0; c < strength!.docs.length; c++) {
                                      //   crudobj.deleteUserStrengthData(
                                      //       strength!.docs[c].id);
                                      // }
                                      // for (int d = 0;
                                      //     d < finalSelectedSubjects.length;
                                      //     d++) {
                                      //   for (int e = 0;
                                      //       e < finalSelectedTopics[d].length;
                                      //       e++) {
                                      //     crudobj.addUserStrengthGradeSubjectTopicData(
                                      //         userschoolData!.docs[0].get("grade"),
                                      //         finalSelectedSubjects[d],
                                      //         finalSelectedTopics[d][e],
                                      //         current_date,
                                      //         comparedate);
                                      //   }
                                      // }
                                      //parallely there is one more table which used to state the registration process
                                      //data to check that user filled all the required details before jumping on home screen
                                      // crudobj.updateUserRegistrationProcessStatusData(
                                      //     service1!.docs[0].id, {"strength": "1"});
                                    }
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  primary: active,
                                  onPrimary: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        MediaQuery.of(context).size.width /
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
                          padding: const EdgeInsets.only(top: 10, left: 15),
                          child: Text(
                            'Select topics based on subject in which you are best.\nIt helps others if they need help on topic in which you are best.',
                            style: TextStyle(
                              fontFamily: 'Product Sans',
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color.fromRGBO(88, 165, 196, 1),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        height: 600,
                        margin: EdgeInsets.all(30),
                        child: GridView.count(
                            controller: _scrollController,
                            childAspectRatio: 1,
                            crossAxisCount:
                                MediaQuery.of(context).size.width > 1200
                                    ? 8
                                    : ((MediaQuery.of(context).size.width <=
                                                1200) &&
                                            (MediaQuery.of(context).size.width >
                                                950))
                                        ? 6
                                        : 4,
                            padding: EdgeInsets.all(10),
                            children:
                                List.generate(subjectList.length, (index) {
                              return InkWell(
                                  onTap: () {
                                    setState(() {
                                      print(topicList[index]);
                                      panelSubjectIndex = index;
                                      _pc.open();
                                    });
                                  },
                                  child: Container(
                                      height: 25,
                                      width: 25,
                                      margin: EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          color:
                                              selectedtopicsbysubject[index] > 0
                                                  ? Color.fromRGBO(
                                                      88, 165, 196, 1)
                                                  : Colors.transparent),
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            _showImage(subjectList[index]),
                                            SizedBox(
                                              height: 5,
                                            ),
                                            Text(
                                              subjectList[index],
                                              textAlign: TextAlign.center,
                                              style: TextStyle(fontSize: 16),
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
            )
          : FadeIn(
              child: InkWell(
                onTap: () {
                  _pc.close();
                },
                child: Container(
                  height: 1000,
                  width: MediaQuery.of(context).size.width,
                  margin: EdgeInsets.all(30),
                  child: Column(
                    children: [
                      SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 0.0),
                            child: Text(
                              'Share Your Knowledge!',
                              style: TextStyle(
                                fontFamily: 'Nunito Sans',
                                fontSize: 25,
                                color: Color(0xCB000000),
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 10, left: 0),
                            child: Text(
                              'Select topics based on subject in which you are best.\nIt helps others if they need help on topic in which you are best.',
                              style: TextStyle(
                                fontFamily: 'Product Sans',
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color.fromRGBO(88, 165, 196, 1),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          InkWell(
                            child: Container(
                              margin: const EdgeInsets.only(right: 15.0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.deepPurple.withOpacity(0.1),
                                    spreadRadius: 10,
                                    blurRadius: 20,
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                child: Container(
                                    width: 100,
                                    height: 40,
                                    child: Center(child: Text("SUBMIT"))),
                                onPressed: () async {
                                  print("button pressed");
                                  setState(() {
                                    _current_active_tab = 3;
                                    if (totalselectedTopiccount > 0) {
                                      List<String> finalSelectedSubjects = [];
                                      List<List<String>> finalSelectedTopics =
                                          [];
                                      for (int a = 0;
                                          a < selectedtopicsbysubject.length;
                                          a++) {
                                        List<String> selectedFinaltopics = [];
                                        if (selectedtopicsbysubject[a] > 0) {
                                          finalSelectedSubjects
                                              .add(subjectList[a]);
                                        }
                                        for (int b = 0;
                                            b < topicList[a].length;
                                            b++) {
                                          if (boolTopicsList[a][b] == true) {
                                            selectedFinaltopics
                                                .add(topicList[a][b]);
                                          }
                                        }
                                        if (selectedFinaltopics.length > 0)
                                          finalSelectedTopics
                                              .add(selectedFinaltopics);
                                      }
                                      print(finalSelectedTopics);
                                      print(finalSelectedSubjects);
                                      finalSelectedStrengthSubjects =
                                          finalSelectedSubjects;
                                      finalSelectedStrengthTopics =
                                          finalSelectedTopics;
                                      finalSelectedSubjects = [];
                                      finalSelectedTopics = [];
                                      // for (int c = 0; c < strength!.docs.length; c++) {
                                      //   crudobj.deleteUserStrengthData(
                                      //       strength!.docs[c].id);
                                      // }
                                      // for (int d = 0;
                                      //     d < finalSelectedSubjects.length;
                                      //     d++) {
                                      //   for (int e = 0;
                                      //       e < finalSelectedTopics[d].length;
                                      //       e++) {
                                      //     crudobj.addUserStrengthGradeSubjectTopicData(
                                      //         userschoolData!.docs[0].get("grade"),
                                      //         finalSelectedSubjects[d],
                                      //         finalSelectedTopics[d][e],
                                      //         current_date,
                                      //         comparedate);
                                      //   }
                                      // }
                                      //parallely there is one more table which used to state the registration process
                                      //data to check that user filled all the required details before jumping on home screen
                                      // crudobj.updateUserRegistrationProcessStatusData(
                                      //     service1!.docs[0].id, {"strength": "1"});
                                    }
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  primary: active,
                                  onPrimary: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        MediaQuery.of(context).size.width /
                                            102.4),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        height: 600,
                        margin: EdgeInsets.all(30),
                        child: GridView.count(
                            controller: _scrollController,
                            childAspectRatio: 1,
                            crossAxisCount: 2,
                            padding: EdgeInsets.all(10),
                            children:
                                List.generate(subjectList.length, (index) {
                              return InkWell(
                                  onTap: () {
                                    setState(() {
                                      print(topicList[index]);
                                      panelSubjectIndex = index;
                                      _pc.open();
                                    });
                                  },
                                  child: Container(
                                      height: 25,
                                      width: 25,
                                      margin: EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          color:
                                              selectedtopicsbysubject[index] > 0
                                                  ? Color.fromRGBO(
                                                      88, 165, 196, 1)
                                                  : Colors.transparent),
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            _showImage(subjectList[index]),
                                            SizedBox(
                                              height: 5,
                                            ),
                                            Text(
                                              subjectList[index],
                                              textAlign: TextAlign.center,
                                              style: TextStyle(fontSize: 12),
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
            );
    } else {
      return _loading();
    }
  }

  _panel(BuildContext context) {
    return _current_active_tab == 2
        ? Container(
            padding: EdgeInsets.fromLTRB(10, 50, 10, 10),
            child: ListView.builder(
              itemCount: topicList.length != 0
                  ? topicList[panelSubjectIndex].length
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
                    child: Text(topicList[panelSubjectIndex][index],
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600)),
                  ),
                );
              }),
            ),
          )
        : Container(
            padding: EdgeInsets.fromLTRB(10, 50, 10, 10),
            child: ListView.builder(
              itemCount: topicListWkns.length != 0
                  ? topicListWkns[panelSubjectIndexWkns].length
                  : 0,
              itemBuilder: ((BuildContext context, int index) {
                return InkWell(
                  onTap: () {
                    setState(() {
                      boolTopicsListWkns[panelSubjectIndexWkns][index] =
                          !boolTopicsListWkns[panelSubjectIndexWkns][index];
                      if (boolTopicsListWkns[panelSubjectIndexWkns][index] ==
                          true) {
                        selectedtopicsbysubjectWkns[panelSubjectIndexWkns]++;
                        totalselectedTopiccountWkns++;
                      } else {
                        selectedtopicsbysubjectWkns[panelSubjectIndexWkns]--;
                        totalselectedTopiccountWkns--;
                      }
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.all(10),
                    margin: EdgeInsets.only(bottom: 10),
                    color:
                        boolTopicsListWkns[panelSubjectIndexWkns][index] == true
                            ? Color.fromRGBO(88, 165, 196, 1)
                            : Colors.white,
                    child: Text(topicListWkns[panelSubjectIndexWkns][index],
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600)),
                  ),
                );
              }),
            ),
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

  _weakness_details() {
    if ((subjects != null) && (topics != null)) {
      return MediaQuery.of(context).size.width > 700
          ? FadeIn(
              child: InkWell(
                onTap: () {
                  _pc.close();
                },
                child: Container(
                  height: 1000,
                  width: MediaQuery.of(context).size.width,
                  margin: EdgeInsets.all(30),
                  child: ListView(
                    children: [
                      SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Padding(
                            padding: const EdgeInsets.only(left: 15.0),
                            child: Text(
                              'Improve Your Weakness!',
                              style: TextStyle(
                                fontFamily: 'Nunito Sans',
                                fontSize: 35,
                                color: Color(0xCB000000),
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          InkWell(
                            child: Container(
                              margin: const EdgeInsets.only(right: 15.0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.deepPurple.withOpacity(0.1),
                                    spreadRadius: 10,
                                    blurRadius: 20,
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                child: Container(
                                    width: 100,
                                    height: 40,
                                    child: Center(child: Text("SUBMIT"))),
                                onPressed: () async {
                                  print("button pressed");
                                  setState(() {
                                    if (totalselectedTopiccountWkns > 0) {
                                      List<String> finalSelectedSubjects = [];
                                      List<List<String>> finalSelectedTopics =
                                          [];
                                      for (int a = 0;
                                          a <
                                              selectedtopicsbysubjectWkns
                                                  .length;
                                          a++) {
                                        List<String> selectedFinaltopics = [];
                                        if (selectedtopicsbysubjectWkns[a] >
                                            0) {
                                          finalSelectedSubjects
                                              .add(subjectListWkns[a]);
                                        }
                                        for (int b = 0;
                                            b < topicListWkns[a].length;
                                            b++) {
                                          if (boolTopicsListWkns[a][b] ==
                                              true) {
                                            selectedFinaltopics
                                                .add(topicListWkns[a][b]);
                                          }
                                        }
                                        if (selectedFinaltopics.length > 0)
                                          finalSelectedTopics
                                              .add(selectedFinaltopics);
                                      }
                                      print(finalSelectedTopics);
                                      print(finalSelectedSubjects);
                                      finalSelectedWeaknessSubjects =
                                          finalSelectedSubjects;
                                      finalSelectedWeaknessTopics =
                                          finalSelectedTopics;
                                      // for (int c = 0; c < strength!.docs.length; c++) {
                                      //   crudobj.deleteUserStrengthData(
                                      //       strength!.docs[c].id);
                                      // }
                                      // for (int d = 0;
                                      //     d < finalSelectedSubjects.length;
                                      //     d++) {
                                      //   for (int e = 0;
                                      //       e < finalSelectedTopics[d].length;
                                      //       e++) {
                                      //     crudobj.addUserStrengthGradeSubjectTopicData(
                                      //         userschoolData!.docs[0].get("grade"),
                                      //         finalSelectedSubjects[d],
                                      //         finalSelectedTopics[d][e],
                                      //         current_date,
                                      //         comparedate);
                                      //   }
                                      // }
                                      //parallely there is one more table which used to state the registration process
                                      //data to check that user filled all the required details before jumping on home screen
                                      // crudobj.updateUserRegistrationProcessStatusData(
                                      //     service1!.docs[0].id, {"strength": "1"});
                                    }
                                    _submitDataDialog();
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  primary: active,
                                  onPrimary: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        MediaQuery.of(context).size.width /
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
                          padding: const EdgeInsets.only(top: 10, left: 15),
                          child: Text(
                            'If you need help, HyS community will help you. Tell us your weakness!',
                            style: TextStyle(
                              fontFamily: 'Product Sans',
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color.fromRGBO(88, 165, 196, 1),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 30),
                      Container(
                        height: 600,
                        child: GridView.count(
                            controller: _scrollController,
                            childAspectRatio: 1,
                            crossAxisCount:
                                MediaQuery.of(context).size.width > 1200
                                    ? 8
                                    : ((MediaQuery.of(context).size.width <=
                                                1200) &&
                                            (MediaQuery.of(context).size.width >
                                                950))
                                        ? 6
                                        : 4,
                            padding: EdgeInsets.all(10),
                            children:
                                List.generate(subjectList.length, (index) {
                              return InkWell(
                                  onTap: () {
                                    setState(() {
                                      print(topicListWkns[index]);
                                      panelSubjectIndexWkns = index;
                                      _pc.open();
                                    });
                                  },
                                  child: Container(
                                      height: 25,
                                      width: 25,
                                      margin: EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          color: selectedtopicsbysubjectWkns[
                                                      index] >
                                                  0
                                              ? Color.fromRGBO(88, 165, 196, 1)
                                              : Colors.transparent),
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            _showImage(subjectListWkns[index]),
                                            SizedBox(
                                              height: 5,
                                            ),
                                            Text(
                                              subjectListWkns[index],
                                              textAlign: TextAlign.center,
                                              style: TextStyle(fontSize: 16),
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
            )
          : FadeIn(
              child: InkWell(
                onTap: () {
                  _pc.close();
                },
                child: Container(
                  height: 1000,
                  width: MediaQuery.of(context).size.width,
                  margin: EdgeInsets.all(30),
                  child: ListView(
                    children: [
                      SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 0.0),
                            child: Text(
                              'Improve Your Weakness!',
                              style: TextStyle(
                                fontFamily: 'Nunito Sans',
                                fontSize: 25,
                                color: Color(0xCB000000),
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 10, left: 0),
                            child: Text(
                              'If you need help, HyS community will help you. Tell us your weakness!',
                              style: TextStyle(
                                fontFamily: 'Product Sans',
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color.fromRGBO(88, 165, 196, 1),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          InkWell(
                            child: Container(
                              margin: const EdgeInsets.only(right: 15.0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.deepPurple.withOpacity(0.1),
                                    spreadRadius: 10,
                                    blurRadius: 20,
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                child: Container(
                                    width: 100,
                                    height: 40,
                                    child: Center(child: Text("SUBMIT"))),
                                onPressed: () async {
                                  print("button pressed");
                                  setState(() {
                                    if (totalselectedTopiccountWkns > 0) {
                                      List<String> finalSelectedSubjects = [];
                                      List<List<String>> finalSelectedTopics =
                                          [];
                                      for (int a = 0;
                                          a <
                                              selectedtopicsbysubjectWkns
                                                  .length;
                                          a++) {
                                        List<String> selectedFinaltopics = [];
                                        if (selectedtopicsbysubjectWkns[a] >
                                            0) {
                                          finalSelectedSubjects
                                              .add(subjectListWkns[a]);
                                        }
                                        for (int b = 0;
                                            b < topicListWkns[a].length;
                                            b++) {
                                          if (boolTopicsListWkns[a][b] ==
                                              true) {
                                            selectedFinaltopics
                                                .add(topicListWkns[a][b]);
                                          }
                                        }
                                        if (selectedFinaltopics.length > 0)
                                          finalSelectedTopics
                                              .add(selectedFinaltopics);
                                      }
                                      print(finalSelectedTopics);
                                      print(finalSelectedSubjects);
                                      finalSelectedWeaknessSubjects =
                                          finalSelectedSubjects;
                                      finalSelectedWeaknessTopics =
                                          finalSelectedTopics;
                                      // for (int c = 0; c < strength!.docs.length; c++) {
                                      //   crudobj.deleteUserStrengthData(
                                      //       strength!.docs[c].id);
                                      // }
                                      // for (int d = 0;
                                      //     d < finalSelectedSubjects.length;
                                      //     d++) {
                                      //   for (int e = 0;
                                      //       e < finalSelectedTopics[d].length;
                                      //       e++) {
                                      //     crudobj.addUserStrengthGradeSubjectTopicData(
                                      //         userschoolData!.docs[0].get("grade"),
                                      //         finalSelectedSubjects[d],
                                      //         finalSelectedTopics[d][e],
                                      //         current_date,
                                      //         comparedate);
                                      //   }
                                      // }
                                      //parallely there is one more table which used to state the registration process
                                      //data to check that user filled all the required details before jumping on home screen
                                      // crudobj.updateUserRegistrationProcessStatusData(
                                      //     service1!.docs[0].id, {"strength": "1"});
                                    }
                                    _submitDataDialog();
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  primary: active,
                                  onPrimary: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        MediaQuery.of(context).size.width /
                                            102.4),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 30),
                      Container(
                        height: 600,
                        child: GridView.count(
                            controller: _scrollController,
                            childAspectRatio: 1,
                            crossAxisCount: 2,
                            padding: EdgeInsets.all(10),
                            children:
                                List.generate(subjectList.length, (index) {
                              return InkWell(
                                  onTap: () {
                                    setState(() {
                                      print(topicListWkns[index]);
                                      panelSubjectIndexWkns = index;
                                      _pc.open();
                                    });
                                  },
                                  child: Container(
                                      height: 25,
                                      width: 25,
                                      margin: EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          color: selectedtopicsbysubjectWkns[
                                                      index] >
                                                  0
                                              ? Color.fromRGBO(88, 165, 196, 1)
                                              : Colors.transparent),
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            _showImage(subjectListWkns[index]),
                                            SizedBox(
                                              height: 5,
                                            ),
                                            Text(
                                              subjectListWkns[index],
                                              textAlign: TextAlign.center,
                                              style: TextStyle(fontSize: 16),
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
            );
    } else {
      return _loading();
    }
  }

  Future _postData() async {
    print("SSubject: $finalSelectedStrengthSubjects");
    print("STopic: $finalSelectedStrengthTopics");
    print("WSubject: $finalSelectedWeaknessSubjects");
    print("WTopic: $finalSelectedWeaknessTopics");
    final List<http.Response> response = await Future.wait([
      http.put(
        Uri.parse(Constant.BASE_URL + 'add_new_user'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          "Access-Control_Allow_Origin": "*"
        },
        body: jsonEncode(<String, String>{"user_id": _currentUserId}),
      ),
      http.post(
        Uri.parse(Constant.BASE_URL + 'add_user_personal_data'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          "Access-Control_Allow_Origin": "*"
        },
        body: jsonEncode(<String, String>{
          "user_id": _currentUserId,
          "first_name": fnamecontroller.text,
          "last_name": lnamecontroller.text,
          "profilepic": imageSelectedFromGalleryURL != ""
              ? imageSelectedFromGalleryURL
              : choosedImg != ""
                  ? choosedImg
                  : "https://firebasestorage.googleapis.com/v0/b/hys-pro-41c66.appspot.com/o/assets%2Fauthentication%2Frobot1.png?alt=media&token=01ee884d-34af-4f70-a8a6-e4935269bc51",
          "email_id": emailidcontroller.text,
          "mobile_no": mobilenocontroller.text,
          "gender": dropdownValueGender,
          "user_dob": personDOBcontroller.text,
          "address": personaddresscontroller.text,
          "street": personstreetcontroller.text,
          "city": personcitycontroller.text,
          "state": personstatecontroller.text
        }),
      ),
      http.post(
        Uri.parse(Constant.BASE_URL + 'add_user_school_data'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          "Access-Control_Allow_Origin": "*"
        },
        body: jsonEncode(<String, dynamic>{
          "user_id": _currentUserId,
          "school_name": schoolnamecontroller.text,
          "grade": int.parse(dropdownValueGrade),
          "stream": dropdownValueStream,
          "board": (dropdownValueBoard == "CBSE")
              ? "Central Board of Secondary Education (CBSE)"
              : dropdownValueBoard,
          "address": schooladdresscontroller.text,
          "street": schoolstreetcontroller.text,
          "city": schoolcitycontroller.text,
          "state": schoolstatecontroller.text
        }),
      ),
      http.post(
        Uri.parse(Constant.BASE_URL + 'add_user_preferred_language_data'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          "Access-Control_Allow_Origin": "*"
        },
        body: jsonEncode(<String, dynamic>{
          "user_id": _currentUserId,
          "preferred_lang_list": preferredLanguage
        }),
      ),
      http.post(
        Uri.parse(Constant.BASE_URL + 'add_user_strength_data'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          "Access-Control_Allow_Origin": "*"
        },
        body: jsonEncode(<String, dynamic>{
          "user_id": _currentUserId,
          "grade": int.parse(dropdownValueGrade),
          "subject_list": finalSelectedStrengthSubjects,
          "topic_list": finalSelectedStrengthTopics
        }),
      ),
      http.post(
        Uri.parse(Constant.BASE_URL + 'add_user_weakness_data'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          "Access-Control_Allow_Origin": "*"
        },
        body: jsonEncode(<String, dynamic>{
          "user_id": _currentUserId,
          "grade": int.parse(dropdownValueGrade),
          "subject_list": finalSelectedWeaknessSubjects,
          "topic_list": finalSelectedWeaknessTopics
        }),
      ),
      http.post(
        Uri.parse(Constant.BASE_URL + 'add_user_privacy'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          "Access-Control_Allow_Origin": "*"
        },
        body: jsonEncode(<String, dynamic>{
          "user_id": _currentUserId,
          "compare_date": comparedate
        }),
      )
    ]);
    setState(() {
      if ((response[0].statusCode == 200) || (response[0].statusCode == 201)) {
        print("userid added: true");
        databaseReference.child("hysweb").update({"$_currentUserId": 1});
      }
      if ((response[1].statusCode == 200) || (response[1].statusCode == 201)) {
        print("user personal details added: true");
        databaseReference.child("hysweb").update({"$_currentUserId": 2});
      }
      if ((response[2].statusCode == 200) || (response[2].statusCode == 201)) {
        print("user school details added: true");
        databaseReference.child("hysweb").update({"$_currentUserId": 3});
      }
      if ((response[3].statusCode == 200) || (response[3].statusCode == 201)) {
        print("user preffered lnguage details added: true");
        databaseReference.child("hysweb").update({"$_currentUserId": 3});
      }
      if ((response[4].statusCode == 200) || (response[4].statusCode == 201)) {
        print("user strength details added: true");
        databaseReference.child("hysweb").update({"$_currentUserId": 4});
      }
      if ((response[5].statusCode == 200) || (response[5].statusCode == 201)) {
        print("user weakness details added: true");
        _firebase_dataload();
        databaseReference.child("hysweb").update({"$_currentUserId": 5});
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
            .child("chat")
            .child(_currentUserId)
            .update({"index": 0, "userdetails": [], "chatid": ""});

        print("almost done");
        databaseReference
            .child("hysweb")
            .child("app_bar_navigation")
            .child(FirebaseAuth.instance.currentUser!.uid)
            .update({"$_currentUserId": 1, "userid": _currentUserId});
        Navigator.of(_keyLoader.currentContext!, rootNavigator: true)
            .pop(); //close the dialoge
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => SiteLayout()));
      }
    });
  }

  Future _firebase_dataload() async {
    databaseReference.child("hysweb").update({"$_currentUserId": 4});
    crudobj.addUserData(
      fnamecontroller.text,
      lnamecontroller.text,
      emailidcontroller.text,
      mobilenocontroller.text,
      dropdownValueGender,
      personDOBcontroller.text,
      personaddresscontroller.text,
      personstreetcontroller.text,
      personcitycontroller.text,
      personstatecontroller.text,
      imageSelectedFromGalleryURL != ""
          ? imageSelectedFromGalleryURL
          : choosedImg != ""
              ? choosedImg
              : "https://firebasestorage.googleapis.com/v0/b/hys-pro-41c66.appspot.com/o/assets%2Fauthentication%2Frobot1.png?alt=media&token=01ee884d-34af-4f70-a8a6-e4935269bc51",
      preferredLanguage,
      null,
      "hobbies",
      "ambition",
      "novels",
      "placesVisited",
      "dreamVacations",
      "createdate",
      comparedate,
    );

    crudobj.addUserSchoolData(
        schoolnamecontroller.text,
        int.parse(dropdownValueGrade),
        dropdownValueStream,
        (dropdownValueBoard == "CBSE")
            ? "Central Board of Secondary Education (CBSE)"
            : dropdownValueBoard,
        schoolstreetcontroller.text,
        schoolcitycontroller.text,
        schoolstatecontroller.text,
        "createdate",
        comparedate);
  }

  void _showCameraDialog() {
    TargetPlatform platform = Theme.of(context).platform;

    showDialog(
        context: context,
        barrierColor: Colors.grey.withOpacity(0.2),
        barrierDismissible: false,
        builder: (_) => StatefulBuilder(builder: (context, setState) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0)),
                content: Container(
                  height: 100,
                  width: 200,
                  child: Column(
                    children: [
                      SizedBox(
                        height: 15,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            children: [
                              IconButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  _pickImage();
                                },
                                icon: Tab(
                                    child: Icon(Icons.image,
                                        color: Color(0xff0962ff), size: 40)),
                              ),
                              SizedBox(
                                height: 15,
                              ),
                              Text(
                                "Gallery",
                                style: TextStyle(
                                  fontFamily: 'Nunito Sans',
                                  fontSize: 16,
                                  color: Color(0xff0C2551),
                                  fontWeight: FontWeight.w700,
                                ),
                                textAlign: TextAlign.center,
                              )
                            ],
                          ),
                          Column(
                            children: [
                              IconButton(
                                onPressed: () {
                                  _showAvtar(context);
                                },
                                icon: CircleAvatar(
                                  child: ClipOval(
                                    child: Container(
                                      width: 100,
                                      height: 100,
                                      child: CachedNetworkImage(
                                        imageUrl:
                                            "https://firebasestorage.googleapis.com/v0/b/hys-pro-41c66.appspot.com/o/assets%2Fauthentication%2Frobot1.png?alt=media&token=01ee884d-34af-4f70-a8a6-e4935269bc51",
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.fill,
                                        placeholder: (context, url) =>
                                            Container(
                                          width: 100,
                                          height: 100,
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
                                height: 15,
                              ),
                              Text(
                                "Avatar",
                                style: TextStyle(
                                  fontFamily: 'Nunito Sans',
                                  fontSize: 16,
                                  color: Color(0xff0C2551),
                                  fontWeight: FontWeight.w700,
                                ),
                                textAlign: TextAlign.center,
                              )
                            ],
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }));
  }

  int checkValues = 0;
  void _submitDataDialog() {
    TargetPlatform platform = Theme.of(context).platform;
    AlertDialog alertDialog = AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      title: Text("Do you want to save your data?",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.redAccent, fontSize: 16)),
      content: Container(
        height: 70,
        width: 200,
        child: Column(
          children: [
            SizedBox(
              height: 15,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                InkWell(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.deepPurple.withOpacity(0.1),
                          spreadRadius: 10,
                          blurRadius: 20,
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      child: Container(
                          width: 60,
                          height: 30,
                          child: Center(child: Text("Yes"))),
                      onPressed: () async {
                        Navigator.of(context).pop();
                        Dialogs.showLoadingDialog(context, _keyLoader);
                        _postData();
                        //  _post_userPrivacy();
                      },
                      style: ElevatedButton.styleFrom(
                        primary: active,
                        onPrimary: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              MediaQuery.of(context).size.width / 102.4),
                        ),
                      ),
                    ),
                  ),
                ),
                InkWell(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.deepPurple.withOpacity(0.1),
                          spreadRadius: 10,
                          blurRadius: 20,
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      child: Container(
                          width: 60,
                          height: 30,
                          child: Center(child: Text("No"))),
                      onPressed: () async {
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors.redAccent,
                        onPrimary: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              MediaQuery.of(context).size.width / 102.4),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => alertDialog);
  }

  // Showing avtar in list
  YYDialog _showAvtar(BuildContext context) {
    return YYDialog().build(context)
      ..gravity = Gravity.bottom
      ..gravityAnimationEnable = true
      ..backgroundColor = Colors.transparent
      ..widget(Container(
          height: 500,
          margin: EdgeInsets.only(left: 2, right: 2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10), topRight: Radius.circular(10)),
            color: Colors.white,
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: GridView.count(
                mainAxisSpacing: 7,
                childAspectRatio: 1.3,
                crossAxisCount: 5,
                children: List.generate(avataar.length, (index) {
                  return InkWell(
                    onTap: () {
                      setState(() {
                        choosedImg = avataar[index];
                      });
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: ClipOval(
                        child: Container(
                            color: Colors.white,
                            width: 100,
                            height: 100,
                            child: CachedNetworkImage(
                              imageUrl: avataar[index],
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                width: 100,
                                height: 100,
                                child: Image.network(
                                  "https://firebasestorage.googleapis.com/v0/b/hys-pro-41c66.appspot.com/o/assets%2Floadingimg.gif?alt=media&token=4ca910f2-c584-4b3a-bbcb-2f1c01d93f67",
                                ),
                              ),
                              errorWidget: (context, url, error) =>
                                  Icon(Icons.error),
                            )),
                      ),
                    ),
                  );
                })),
          )))
      ..show();
  }

  //bottomsheet for languages selection
  _preferredLanguage(BuildContext context) {
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) => Container(
              padding: EdgeInsets.all(20),
              child: Wrap(
                spacing: 5,
                children: [
                  InkWell(
                    onTap: () {
                      setState(() {
                        boolOptionspreferredLanguage[0] =
                            !boolOptionspreferredLanguage[0];
                        if (boolOptionspreferredLanguage[0] == true) {
                          preferredLanguage.add(optionspreferredLanguage[0]);
                        } else {
                          for (int f = 0; f < preferredLanguage.length; f++) {
                            if (preferredLanguage[f] ==
                                optionspreferredLanguage[0]) {
                              preferredLanguage.removeAt(f);
                            }
                          }
                        }
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.all(5),
                      margin: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                          color: boolOptionspreferredLanguage[0] == true
                              ? Color.fromRGBO(88, 165, 196, 1)
                              : Colors.white,
                          border: Border.all(
                              color: Color.fromRGBO(88, 165, 196, 1)),
                          borderRadius: BorderRadius.circular(100)),
                      child: Text(optionspreferredLanguage[0],
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w500)),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        boolOptionspreferredLanguage[1] =
                            !boolOptionspreferredLanguage[1];
                        if (boolOptionspreferredLanguage[1] == true) {
                          setState(() {
                            preferredLanguage.add(optionspreferredLanguage[1]);
                          });
                        } else {
                          for (int f = 0; f < preferredLanguage.length; f++) {
                            if (preferredLanguage[f] ==
                                optionspreferredLanguage[1]) {
                              preferredLanguage.removeAt(f);
                            }
                          }
                        }
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.all(5),
                      margin: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                          color: boolOptionspreferredLanguage[1] == true
                              ? Color.fromRGBO(88, 165, 196, 1)
                              : Colors.white,
                          border: Border.all(
                              color: Color.fromRGBO(88, 165, 196, 1)),
                          borderRadius: BorderRadius.circular(100)),
                      child: Text(optionspreferredLanguage[1],
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w500)),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        boolOptionspreferredLanguage[2] =
                            !boolOptionspreferredLanguage[2];
                        if (boolOptionspreferredLanguage[2] == true) {
                          preferredLanguage.add(optionspreferredLanguage[2]);
                        } else {
                          for (int f = 0; f < preferredLanguage.length; f++) {
                            if (preferredLanguage[f] ==
                                optionspreferredLanguage[2]) {
                              preferredLanguage.removeAt(f);
                            }
                          }
                        }
                      });
                    },
                    child: Container(
                      margin: EdgeInsets.all(4),
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                          color: boolOptionspreferredLanguage[2] == true
                              ? Color.fromRGBO(88, 165, 196, 1)
                              : Colors.white,
                          border: Border.all(
                              color: Color.fromRGBO(88, 165, 196, 1)),
                          borderRadius: BorderRadius.circular(100)),
                      child: Text(optionspreferredLanguage[2],
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w500)),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        boolOptionspreferredLanguage[3] =
                            !boolOptionspreferredLanguage[3];
                        if (boolOptionspreferredLanguage[3] == true) {
                          preferredLanguage.add(optionspreferredLanguage[3]);
                        } else {
                          for (int f = 0; f < preferredLanguage.length; f++) {
                            if (preferredLanguage[f] ==
                                optionspreferredLanguage[3]) {
                              preferredLanguage.removeAt(f);
                            }
                          }
                        }
                      });
                    },
                    child: Container(
                      margin: EdgeInsets.all(4),
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                          color: boolOptionspreferredLanguage[3] == true
                              ? Color.fromRGBO(88, 165, 196, 1)
                              : Colors.white,
                          border: Border.all(
                              color: Color.fromRGBO(88, 165, 196, 1)),
                          borderRadius: BorderRadius.circular(100)),
                      child: Text(optionspreferredLanguage[3],
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w500)),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        boolOptionspreferredLanguage[4] =
                            !boolOptionspreferredLanguage[4];
                        if (boolOptionspreferredLanguage[4] == true) {
                          preferredLanguage.add(optionspreferredLanguage[4]);
                        } else {
                          for (int f = 0; f < preferredLanguage.length; f++) {
                            if (preferredLanguage[f] ==
                                optionspreferredLanguage[4]) {
                              preferredLanguage.removeAt(f);
                            }
                          }
                        }
                      });
                    },
                    child: Container(
                      margin: EdgeInsets.all(4),
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                          color: boolOptionspreferredLanguage[4] == true
                              ? Color.fromRGBO(88, 165, 196, 1)
                              : Colors.white,
                          border: Border.all(
                              color: Color.fromRGBO(88, 165, 196, 1)),
                          borderRadius: BorderRadius.circular(100)),
                      child: Text(optionspreferredLanguage[4],
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w500)),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        boolOptionspreferredLanguage[5] =
                            !boolOptionspreferredLanguage[5];
                        if (boolOptionspreferredLanguage[5] == true) {
                          preferredLanguage.add(optionspreferredLanguage[5]);
                        } else {
                          for (int f = 0; f < preferredLanguage.length; f++) {
                            if (preferredLanguage[f] ==
                                optionspreferredLanguage[5]) {
                              preferredLanguage.removeAt(f);
                            }
                          }
                        }
                      });
                    },
                    child: Container(
                      margin: EdgeInsets.all(4),
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                          color: boolOptionspreferredLanguage[5] == true
                              ? Color.fromRGBO(88, 165, 196, 1)
                              : Colors.white,
                          border: Border.all(
                              color: Color.fromRGBO(88, 165, 196, 1)),
                          borderRadius: BorderRadius.circular(100)),
                      child: Text(optionspreferredLanguage[5],
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w500)),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        boolOptionspreferredLanguage[6] =
                            !boolOptionspreferredLanguage[6];
                        if (boolOptionspreferredLanguage[6] == true) {
                          preferredLanguage.add(optionspreferredLanguage[6]);
                        } else {
                          for (int f = 0; f < preferredLanguage.length; f++) {
                            if (preferredLanguage[f] ==
                                optionspreferredLanguage[6]) {
                              preferredLanguage.removeAt(f);
                            }
                          }
                        }
                      });
                    },
                    child: Container(
                      margin: EdgeInsets.all(4),
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                          color: boolOptionspreferredLanguage[6] == true
                              ? Color.fromRGBO(88, 165, 196, 1)
                              : Colors.white,
                          border: Border.all(
                              color: Color.fromRGBO(88, 165, 196, 1)),
                          borderRadius: BorderRadius.circular(100)),
                      child: Text(optionspreferredLanguage[6],
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w500)),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        boolOptionspreferredLanguage[7] =
                            !boolOptionspreferredLanguage[7];
                        if (boolOptionspreferredLanguage[7] == true) {
                          preferredLanguage.add(optionspreferredLanguage[7]);
                        } else {
                          for (int f = 0; f < preferredLanguage.length; f++) {
                            if (preferredLanguage[f] ==
                                optionspreferredLanguage[7]) {
                              preferredLanguage.removeAt(f);
                            }
                          }
                        }
                      });
                    },
                    child: Container(
                      margin: EdgeInsets.all(4),
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                          color: boolOptionspreferredLanguage[7] == true
                              ? Color.fromRGBO(88, 165, 196, 1)
                              : Colors.white,
                          border: Border.all(
                              color: Color.fromRGBO(88, 165, 196, 1)),
                          borderRadius: BorderRadius.circular(100)),
                      child: Text(optionspreferredLanguage[7],
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w500)),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        boolOptionspreferredLanguage[8] =
                            !boolOptionspreferredLanguage[8];
                        if (boolOptionspreferredLanguage[8] == true) {
                          preferredLanguage.add(optionspreferredLanguage[8]);
                        } else {
                          for (int f = 0; f < preferredLanguage.length; f++) {
                            if (preferredLanguage[f] ==
                                optionspreferredLanguage[8]) {
                              preferredLanguage.removeAt(f);
                            }
                          }
                        }
                      });
                    },
                    child: Container(
                      margin: EdgeInsets.all(4),
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                          color: boolOptionspreferredLanguage[8] == true
                              ? Color.fromRGBO(88, 165, 196, 1)
                              : Colors.white,
                          border: Border.all(
                              color: Color.fromRGBO(88, 165, 196, 1)),
                          borderRadius: BorderRadius.circular(100)),
                      child: Text(optionspreferredLanguage[8],
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w500)),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        boolOptionspreferredLanguage[9] =
                            !boolOptionspreferredLanguage[9];
                        if (boolOptionspreferredLanguage[9] == true) {
                          preferredLanguage.add(optionspreferredLanguage[9]);
                        } else {
                          for (int f = 0; f < preferredLanguage.length; f++) {
                            if (preferredLanguage[f] ==
                                optionspreferredLanguage[9]) {
                              preferredLanguage.removeAt(f);
                            }
                          }
                        }
                      });
                    },
                    child: Container(
                      margin: EdgeInsets.all(4),
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                          color: boolOptionspreferredLanguage[9] == true
                              ? Color.fromRGBO(88, 165, 196, 1)
                              : Colors.white,
                          border: Border.all(
                              color: Color.fromRGBO(88, 165, 196, 1)),
                          borderRadius: BorderRadius.circular(100)),
                      child: Text(optionspreferredLanguage[9],
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w500)),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        boolOptionspreferredLanguage[10] =
                            !boolOptionspreferredLanguage[10];
                        if (boolOptionspreferredLanguage[10] == true) {
                          preferredLanguage.add(optionspreferredLanguage[10]);
                        } else {
                          for (int f = 0; f < preferredLanguage.length; f++) {
                            if (preferredLanguage[f] ==
                                optionspreferredLanguage[10]) {
                              preferredLanguage.removeAt(f);
                            }
                          }
                        }
                      });
                    },
                    child: Container(
                      margin: EdgeInsets.all(4),
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                          color: boolOptionspreferredLanguage[10] == true
                              ? Color.fromRGBO(88, 165, 196, 1)
                              : Colors.white,
                          border: Border.all(
                              color: Color.fromRGBO(88, 165, 196, 1)),
                          borderRadius: BorderRadius.circular(100)),
                      child: Text(optionspreferredLanguage[10],
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w500)),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        boolOptionspreferredLanguage[11] =
                            !boolOptionspreferredLanguage[11];
                        if (boolOptionspreferredLanguage[11] == true) {
                          preferredLanguage.add(optionspreferredLanguage[11]);
                        } else {
                          for (int f = 0; f < preferredLanguage.length; f++) {
                            if (preferredLanguage[f] ==
                                optionspreferredLanguage[11]) {
                              preferredLanguage.removeAt(f);
                            }
                          }
                        }
                      });
                    },
                    child: Container(
                      margin: EdgeInsets.all(4),
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                          color: boolOptionspreferredLanguage[11] == true
                              ? Color.fromRGBO(88, 165, 196, 1)
                              : Colors.white,
                          border: Border.all(
                              color: Color.fromRGBO(88, 165, 196, 1)),
                          borderRadius: BorderRadius.circular(100)),
                      child: Text(optionspreferredLanguage[11],
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w500)),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        boolOptionspreferredLanguage[12] =
                            !boolOptionspreferredLanguage[12];
                        if (boolOptionspreferredLanguage[12] == true) {
                          preferredLanguage.add(optionspreferredLanguage[12]);
                        } else {
                          for (int f = 0; f < preferredLanguage.length; f++) {
                            if (preferredLanguage[f] ==
                                optionspreferredLanguage[12]) {
                              preferredLanguage.removeAt(f);
                            }
                          }
                        }
                      });
                    },
                    child: Container(
                      margin: EdgeInsets.all(4),
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                          color: boolOptionspreferredLanguage[12] == true
                              ? Color.fromRGBO(88, 165, 196, 1)
                              : Colors.white,
                          border: Border.all(
                              color: Color.fromRGBO(88, 165, 196, 1)),
                          borderRadius: BorderRadius.circular(100)),
                      child: Text(optionspreferredLanguage[12],
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w500)),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        boolOptionspreferredLanguage[13] =
                            !boolOptionspreferredLanguage[13];
                        if (boolOptionspreferredLanguage[13] == true) {
                          preferredLanguage.add(optionspreferredLanguage[13]);
                        } else {
                          for (int f = 0; f < preferredLanguage.length; f++) {
                            if (preferredLanguage[f] ==
                                optionspreferredLanguage[13]) {
                              preferredLanguage.removeAt(f);
                            }
                          }
                        }
                      });
                    },
                    child: Container(
                      margin: EdgeInsets.all(4),
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                          color: boolOptionspreferredLanguage[13] == true
                              ? Color.fromRGBO(88, 165, 196, 1)
                              : Colors.white,
                          border: Border.all(
                              color: Color.fromRGBO(88, 165, 196, 1)),
                          borderRadius: BorderRadius.circular(100)),
                      child: Text(optionspreferredLanguage[13],
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w500)),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        boolOptionspreferredLanguage[14] =
                            !boolOptionspreferredLanguage[14];
                        if (boolOptionspreferredLanguage[14] == true) {
                          preferredLanguage.add(optionspreferredLanguage[14]);
                        } else {
                          for (int f = 0; f < preferredLanguage.length; f++) {
                            if (preferredLanguage[f] ==
                                optionspreferredLanguage[14]) {
                              preferredLanguage.removeAt(f);
                            }
                          }
                        }
                      });
                    },
                    child: Container(
                      margin: EdgeInsets.all(4),
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                          color: boolOptionspreferredLanguage[14] == true
                              ? Color.fromRGBO(88, 165, 196, 1)
                              : Colors.white,
                          border: Border.all(
                              color: Color.fromRGBO(88, 165, 196, 1)),
                          borderRadius: BorderRadius.circular(100)),
                      child: Text(optionspreferredLanguage[14],
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w500)),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        boolOptionspreferredLanguage[15] =
                            !boolOptionspreferredLanguage[15];
                        if (boolOptionspreferredLanguage[15] == true) {
                          preferredLanguage.add(optionspreferredLanguage[15]);
                        } else {
                          for (int f = 0; f < preferredLanguage.length; f++) {
                            if (preferredLanguage[f] ==
                                optionspreferredLanguage[15]) {
                              preferredLanguage.removeAt(f);
                            }
                          }
                        }
                      });
                    },
                    child: Container(
                      margin: EdgeInsets.all(4),
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                          color: boolOptionspreferredLanguage[15] == true
                              ? Color.fromRGBO(88, 165, 196, 1)
                              : Colors.white,
                          border: Border.all(
                              color: Color.fromRGBO(88, 165, 196, 1)),
                          borderRadius: BorderRadius.circular(100)),
                      child: Text(optionspreferredLanguage[15],
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w500)),
                    ),
                  ),
                ],
              ),
            ));
  }

  void _showLoadingDialog() {
    AlertDialog alertDialog = AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        content: Center(
          child: Container(
              height: 50.0,
              margin: EdgeInsets.all(20.0),
              child: Center(
                  child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xff0962ff)),
              ))),
        ));
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => alertDialog);
  }

  double progress = 0.0;
  void _pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      Uint8List? file = result.files.first.bytes;
      String fileName = result.files.first.name;
      Dialogs.showLoadingDialog(context, _keyLoader);
      UploadTask task = FirebaseStorage.instance
          .ref()
          .child("userProfile/$_currentUserId/$fileName")
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
              .ref("userProfile/$_currentUserId/$fileName")
              .getDownloadURL();
          if (downloadURL != null) {
            setState(() {
              imageSelectedFromGalleryURL = downloadURL;
              print(downloadURL);
              Navigator.of(_keyLoader.currentContext!, rootNavigator: false)
                  .pop(); //close the dialoge
            });
          }
        }
      });
    }
  }

  void _loadingProgrssbar() {
    showDialog(
        context: context,
        barrierColor: Colors.grey.withOpacity(0.2),
        builder: (_) => StatefulBuilder(builder: (context, setState) {
              return AlertDialog(
                  content: Container(
                height: 70.0,
                width: 70.0,
                child: LiquidCircularProgressIndicator(
                  value: progress / 100,
                  valueColor: AlwaysStoppedAnimation(Colors.pinkAccent),
                  backgroundColor: Colors.white,
                  direction: Axis.vertical,
                  center: Text(
                    "$progress%",
                    style: GoogleFonts.poppins(
                        color: Colors.black87, fontSize: 25.0),
                  ),
                ),
              ));
            }));
  }
}

//address search class
class AddressSearch extends SearchDelegate<Suggestion> {
  final sessionToken;
  late PlaceApiProvider apiClient;

  AddressSearch(this.sessionToken) {
    apiClient = PlaceApiProvider(sessionToken);
  }
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        tooltip: 'Clear',
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      tooltip: 'Back',
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, Suggestion("", ""));
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Container();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return FutureBuilder(
      future: query == ""
          ? null
          : apiClient.fetchSuggestions(
              query, Localizations.localeOf(context).languageCode),
      builder: (context, snapshot) => query == ''
          ? Container(
              padding: EdgeInsets.all(16.0),
              child: Text('Enter your address'),
            )
          : snapshot.hasData
              ? ListView.builder(
                  itemBuilder: (context, index) => ListTile(
                    title: Text((snapshot.data as Suggestion).description),
                    onTap: () {
                      close(context, snapshot.data as Suggestion);
                    },
                  ),
                  itemCount: 4,
                )
              : Container(child: Text('Loading...')),
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
