// import 'dart:async';

// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:hys/models/social_feed_model.dart';
// import '../database/social_repository.dart';
// import '../models/network_request_genric.dart';


// class SpecificSocialFeedProvider extends ChangeNotifier{

//   SocialRepository _socialRepository;
//   ApiResponse<List<SocialFeedModel>> _socialFeedList;
//   ApiResponse<List<SocialFeedModel>> get socialFeedList => _socialFeedList;
//   bool get hasNextPage => _hasNextPage;
//   bool get isFirstLoadRunning => _isFirstLoadRunning;
//   bool get isLoadMoreRunning => _isLoadMoreRunning;
//   StreamController<bool> controller = StreamController<bool>.broadcast();
//   int pageNumber;
//   String _currentUserId;
//   bool _hasNextPage = true;
//   bool _isFirstLoadRunning = false;
//   bool _isLoadMoreRunning = false;

//   SpecificSocialFeedProvider() {
//     pageNumber=0;
//     _socialFeedList = ApiResponse();
//     _socialRepository = SocialRepository();
//     _currentUserId = FirebaseAuth.instance.currentUser.uid;

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

//   refreshFeedList(String type) async{

//   }


//   fetchFeedList(String type) async {
//     pageNumber=0;
//     _isFirstLoadRunning = true;
//     _socialFeedList = ApiResponse.loading('Loading');
//     await Future.delayed(Duration(milliseconds: 1));
//     notifyListeners();
//     try {
//       List<SocialFeedModel> movies = await _socialRepository.fetchSpecificSocialFeed((pageNumber*10).toString(),_currentUserId,type);
//       _socialFeedList = ApiResponse.completed(movies);
//       notifyListeners();
//     } catch (e) {
//       _socialFeedList = ApiResponse.error(e.toString());
//       notifyListeners();
//     }
//   }

//   fetchMoreList(String type) async {
//     _isLoadMoreRunning=true;
//     controller.add(true);
//     pageNumber++;
//     notifyListeners();
//     try {
//       List<SocialFeedModel> movies = await _socialRepository.fetchSpecificSocialFeed((pageNumber*10).toString(),_currentUserId,type);
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
//     if(process=="+" &&  _socialFeedList.data[index].like_type.isNotEmpty){
//       _socialFeedList.data[index].like_type= likeType;
//     }else if(process=="+" &&  _socialFeedList.data[index].like_type.isEmpty){
//       _socialFeedList.data[index].like_count=_socialFeedList.data[index].like_count+1;
//       _socialFeedList.data[index].like_type= likeType;
//   }else {
//       _socialFeedList.data[index].like_count=_socialFeedList.data[index].like_count-1;
//       _socialFeedList.data[index].like_type= likeType;
//     }
//     notifyListeners();

//   }

// }