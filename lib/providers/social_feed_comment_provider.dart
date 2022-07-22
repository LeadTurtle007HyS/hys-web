


// import 'dart:async';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:hys/models/social_feed_comment_model.dart';
// import '../database/social_repository.dart';
// import '../models/network_request_genric.dart';
// import '../models/social_feed_model.dart';

// class SocialFeedCommentProvider extends ChangeNotifier {

//   SocialRepository _socialRepository;
//   ApiResponse<List<SocialFeedCommentModel>> _commentList;
//   ApiResponse<List<SocialFeedCommentModel>> get commentList => _commentList;


//   String commentImageURL="";
//   String comment = "";
//   String commentVideoURL="";
//   String markupText="";
//   bool _showImgContainer =false;
//   bool _showVideoContainer=false;
//   bool _commentImg=false;
//   bool _commentVdo=false;

//   int pageNumber;
//   String _currentUserId;
//   bool _hasNextPage = true;
//   bool _isFirstLoadRunning = false;
//   bool _isLoadMoreRunning = false;

//   String postId;

//   SocialFeedModel feedPost;

//   bool get hasNextPage => _hasNextPage;
//   bool get isFirstLoadRunning => _isFirstLoadRunning;
//   bool get isLoadMoreRunning => _isLoadMoreRunning;

//   bool get isShowImgContainer => _showImgContainer;
//   bool get isShowVideoContainer => _showVideoContainer;
//   bool get isCommentImg => _commentImg;
//   bool get isCommentVdo=>_commentVdo;

//   StreamController<bool> controller = StreamController<bool>.broadcast();




//   SocialFeedCommentProvider() {
//     _currentUserId = FirebaseAuth.instance.currentUser.uid;
//     pageNumber=0;
//     _commentList = ApiResponse.loading("Loading");
//     _socialRepository = SocialRepository();

//   }

//   SocialFeedModel get socialFeedModel{
//     return feedPost;
//   }

//   void setSocialModelModel(SocialFeedModel socialFeedModel){
//     this.feedPost=socialFeedModel;
//   }


//   String get getPostId {
//     return postId;
//   }

//   String get getComment {
//     return comment;
//   }

//   String get getMarkupText {
//     return markupText;
//   }
//   void setComment(String comment){
//     this.comment = comment;
//     notifyListeners();
//   }

//   void setMarkupText(String markupText){
//     this.markupText = markupText;
//     notifyListeners();
//   }

//   String get getCommentImageURL {
//     return commentImageURL;
//   }
//   void setCommentImageURL(String commentImageURL){
//     this.commentImageURL = commentImageURL;

//   }
//   String get getCommentVideoURL {
//     return commentVideoURL;
//   }
//   void setCommentVideoURL(String commentVideoURl){
//     this.commentVideoURL = commentVideoURl;

//   }
// setIsCommentVideo(bool isCommentVdo)
// {
//   this._commentVdo=isCommentVdo;
// }

//   void setPostId(String postId){
//     this.postId = postId;
//   }

//   setIsCommentImage(bool isCommentImg){
//     this._commentImg=isCommentImg;
//     notifyListeners();
//   }


//   setShowVideoImageConVis(bool image,bool video){
//     _showVideoContainer=video;
//     _showImgContainer=image;
//     notifyListeners();
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


//   fetchCommentList(String postId) async {
//     pageNumber=0;
//     _isFirstLoadRunning = true;
//     _commentList = ApiResponse.loading('Loading');
//      await Future.delayed(Duration(milliseconds: 1));
//      notifyListeners();
//     try {
//       List<SocialFeedCommentModel> feedList = await _socialRepository.fetchAllSocialFeedComments(_currentUserId,(pageNumber*10).toString(),postId);
//       _commentList = ApiResponse.completed(feedList.length>0?feedList:<SocialFeedCommentModel>[]);
//       notifyListeners();
//     } catch (e) {
//       _isFirstLoadRunning = false;
//       _commentList = ApiResponse.error(e.toString());
//       notifyListeners();
//     }
//   }

//   fetchMoreList(String postId) async {
//     _isLoadMoreRunning=true;
//     controller.add(true);
//     pageNumber++;

//     notifyListeners();
//     try {
//       List<SocialFeedCommentModel> movies = await _socialRepository.fetchAllSocialFeedComments(_currentUserId,(pageNumber*10).toString(),postId);
//       if(movies.length<10)
//         _hasNextPage=false;
//       var duplicateList=_commentList.data;
//       duplicateList.addAll(movies);
//       _commentList = ApiResponse.completed(duplicateList);
//       _isLoadMoreRunning=false;
//       controller.add(false);
//       notifyListeners();
//     } catch (e) {
//       _isLoadMoreRunning=false;
//       controller.add(false);
//       notifyListeners();
//     }
//   }


//   updateSocialFeedLikeDislikeCount(String process,String likeType){
//     if(process=="+" && socialFeedModel.like_type==""){
//       socialFeedModel.like_count=socialFeedModel.like_count+1;
//       socialFeedModel.like_type= likeType;
//     }else if(process=="+" && socialFeedModel.like_type!=""){
//       socialFeedModel.like_type= likeType;
//     } else{
//       socialFeedModel.like_count=socialFeedModel.like_count-1;
//       socialFeedModel.like_type= likeType;
//     }
//     notifyListeners();

//   }

//   updateLikeDislikeCount(int index,String process,String likeType){
//     if(process=="+"){
//       _commentList.data[index].like_count=_commentList.data[index].like_count+1;
//       _commentList.data[index].like_type= likeType;
//     }else{
//       _commentList.data[index].like_count=_commentList.data[index].like_count-1;
//       _commentList.data[index].like_type= likeType;
//     }
//     notifyListeners();

//   }

//   updateCommentReplyLikeDislikeCount(int commentIndex,int replyIndex,String process,String likeType){
//     if(process=="+"){
//       _commentList.data[commentIndex].reply_list[replyIndex].like_count=_commentList.data[commentIndex].reply_list[replyIndex].like_count+1;
//       _commentList.data[commentIndex].reply_list[replyIndex].like_type= likeType;
//     }else{
//       _commentList.data[commentIndex].reply_list[replyIndex].like_count=_commentList.data[commentIndex].reply_list[replyIndex].like_count+1;
//      _commentList.data[commentIndex].reply_list[replyIndex].like_type= likeType;
//     }
//     notifyListeners();

//   }




//   addComment(SocialFeedCommentModel socialFeedCommentModel){
//     _commentList.data.add(socialFeedCommentModel);
//     socialFeedModel.comment_count=socialFeedModel.comment_count+1;
//     notifyListeners();

//   }



// }