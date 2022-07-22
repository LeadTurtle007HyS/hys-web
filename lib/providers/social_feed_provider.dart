// import 'dart:async';

// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:hive/hive.dart';
// import 'package:hys/SearchDelegate.dart';
// import 'package:hys/models/social_feed_model.dart';
// import '../database/social_repository.dart';
// import '../models/network_request_genric.dart';

// class SocialFeedProvider extends ChangeNotifier{

//   SocialRepository _socialRepository;
//   ApiResponse<List<SocialFeedModel>> _socialFeedList;
//   ApiResponse<List<SocialFeedModel>> get socialFeedList => _socialFeedList;
//   List<PersonQuestion> _ques_pers_List = [];

//   List<PersonQuestion> get ques_pers_List => _ques_pers_List;
//   bool get hasNextPage => _hasNextPage;
//   bool get isFirstLoadRunning => _isFirstLoadRunning;
//   bool get isLoadMoreRunning => _isLoadMoreRunning;

//   Box<List<dynamic>> allSocialPostLocalDB;
//   StreamController<bool> controller = StreamController<bool>.broadcast();
//   int pageNumber;
//   String _currentUserId;
//   bool _hasNextPage = true;
//   bool _isFirstLoadRunning = false;
//   bool _isLoadMoreRunning = false;

//   SocialFeedProvider() {
//     pageNumber=0;
//     _socialFeedList = ApiResponse();
//     _socialRepository = SocialRepository();
//     _currentUserId = FirebaseAuth.instance.currentUser.uid;
//     //fetchFeedList(_currentUserId);

//   }

//   setLoadMoreRuning(bool value){
//     _isLoadMoreRunning=value;
//   }
//   setFirstLoadRunning(bool value){
//     _isFirstLoadRunning=value;
//   }
//   setHasNextPage(bool value){
//     _hasNextPage=value;
//   }

//   refreshList(String userId) async{

//     pageNumber=0;
//     _isFirstLoadRunning = true;
//     try {
//       List<SocialFeedModel> movies = await _socialRepository.fetchAllSocialFeed((pageNumber*10).toString(),userId);
//       if(movies.length<10)
//         _hasNextPage=false;
//       // allSocialPostLocalDB.put("LocalSocialFeed", movies as List<dynamic>);
//       _socialFeedList = ApiResponse.completed(movies);

//       notifyListeners();
//     } catch (e) {
//       _socialFeedList = ApiResponse.error(e.toString());
//       notifyListeners();
//     }

//   }


//   fetchFeedList(String userID) async {
//     pageNumber=0;
//     _isFirstLoadRunning = true;
//     _socialFeedList = ApiResponse.loading('Loading');
//     await Future.delayed(Duration(milliseconds: 1));
//     notifyListeners();
//     try {
//       List<SocialFeedModel> movies = await _socialRepository.fetchAllSocialFeed((pageNumber*10).toString(),userID);
//       if(movies.length<10)
//         _hasNextPage=false;
//       // allSocialPostLocalDB.put("LocalSocialFeed", movies as List<dynamic>);
//       _socialFeedList = ApiResponse.completed(movies);
//       notifyListeners();
//     } catch (e) {
//       _socialFeedList = ApiResponse.error(e.toString());
//       notifyListeners();
//     }
//   }



//   fetchFeedListALL(String userID) async {
//     pageNumber=0;
//     _isFirstLoadRunning = true;
//     _socialFeedList = ApiResponse.loading('Loading');
//     //_ques_pers_List=[];
//     //notifyListeners();
//     try {
//       List<SocialFeedModel> movies = await _socialRepository.fetchAllSocialFeed_inONE(userID);
//       //List<SocialFeedModel> movies = await _socialRepository.fetchAllSocialFeed((pageNumber*10).toString(),userID);
//       if(movies.length<10)
//         _hasNextPage=false;
//       // allSocialPostLocalDB.put("LocalSocialFeed", movies as List<dynamic>);
//       _socialFeedList = ApiResponse.completed(movies);
//       for(int i=0;i<_socialFeedList.data.length;i++)
//       {
//         _ques_pers_List.add(PersonQuestion(
//             _socialFeedList.data[i],null,
//             null,
//             null,
//             null,
//             _socialFeedList.data[i].user_id,
//             _socialFeedList.data[i].post_id,
//             '',
//             (_socialFeedList.data[i].post_type=="blog")?_socialFeedList.data[i].blog_intro:_socialFeedList.data[i].message,
//             '',
//             '',
//             _socialFeedList.data[i].profilepic,
//             (_socialFeedList.data[i].post_type=="podcast")?"podcast":(_socialFeedList.data[i].post_type=="blog")?"blog":(_socialFeedList.data[i].post_type=="Mood")?"Mood":(_socialFeedList.data[i].post_type=="cause|teachunprevilagedKids")?"cause|teachunprevilagedKids":"",
//             _socialFeedList.data[i].user_mood,
//             _socialFeedList.data[i].blog_title,
//             _socialFeedList.data[i].eventname,
//             _socialFeedList.data[i].school_name,
//             _socialFeedList.data[i].grade.toString(),
//             '',
//             '',
//             ["English","Hindi"],
//             "",
//             "",
//             "",
//             ""));
//       }
//       notifyListeners();
//     } catch (e) {
//       _socialFeedList = ApiResponse.error(e.toString());
//       notifyListeners();
//     }
//   }



//   fetchMoreList() async {
//     _isLoadMoreRunning=true;
//     controller.add(true);
//     pageNumber++;
//     notifyListeners();
//     try {
//       List<SocialFeedModel> movies = await _socialRepository.fetchAllSocialFeed((pageNumber*10).toString(),FirebaseAuth.instance.currentUser.uid);
//       if(movies.length<10)
//         _hasNextPage=false;
//       var duplicateList=_socialFeedList.data;
//       duplicateList.addAll(movies);
//       _socialFeedList = ApiResponse.completed(duplicateList);
//       _isLoadMoreRunning=false;
//       controller.add(false);
//       notifyListeners();
//     } catch (e) {
//       _isLoadMoreRunning=false;
//       controller.add(false);
//       notifyListeners();
//     }
//   }

//   updateLikeDislikeCount(int index,String process,String likeType){
//     if(process=="+" && socialFeedList.data[index].like_type==""){
//       _socialFeedList.data[index].like_count=_socialFeedList.data[index].like_count+1;
//       _socialFeedList.data[index].like_type= likeType;
//     }else if(process=="+" && socialFeedList.data[index].like_type!=""){
//       _socialFeedList.data[index].like_type= likeType;
//     } else{
//       _socialFeedList.data[index].like_count=_socialFeedList.data[index].like_count-1;
//       _socialFeedList.data[index].like_type= likeType;
//     }
//     notifyListeners();

//   }

// }