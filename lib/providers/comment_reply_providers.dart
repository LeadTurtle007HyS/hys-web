


// import 'dart:async';

// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:hys/models/social_feed_comment_model.dart';
// import '../database/social_repository.dart';
// import '../models/comment_reply_model.dart';
// import '../models/network_request_genric.dart';

// class CommentReplyProviders extends ChangeNotifier {

//   SocialRepository _socialRepository;
//   ApiResponse<List<CommentReplyModel>> _commentReplyList;
//   ApiResponse<List<CommentReplyModel>> get commentReplyList => _commentReplyList;
//   bool get hasNextPage => _hasNextPage;
//   bool get isFirstLoadRunning => _isFirstLoadRunning;
//   bool get isLoadMoreRunning => _isLoadMoreRunning;

//   SocialFeedCommentModel socialFeedCommentModel;

//   StreamController<bool> controller = StreamController<bool>.broadcast();


//   String commentImageURL="";
//   String comment = "";
//   String commentVideoURL="";
//   String markupText="";
//   bool _showImgContainer =false;
//   bool _showVideoContainer=false;
//   bool _commentImg=false;



//   int pageNumber;
//   String _currentUserId;

//   bool _hasNextPage = true;
//   bool _isFirstLoadRunning = false;
//   bool _isLoadMoreRunning = false;



//   bool get isShowImgContainer => _showImgContainer;
//   bool get isShowVideoContainer => _showVideoContainer;
//   bool get isCommentImg => _commentImg;


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



//   SocialFeedCommentModel get socialCommentModel{
//     return socialFeedCommentModel;
//   }

//   void setSocialCommentModel(SocialFeedCommentModel socialFeedCommentModel){
//     this.socialFeedCommentModel=socialFeedCommentModel;
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



//   CommentReplyProviders() {
//     _currentUserId = FirebaseAuth.instance.currentUser.uid;
//      pageNumber=0;
//     _commentReplyList = ApiResponse.loading("Loading");
//     _socialRepository = SocialRepository();

//   }


//   fetchCommentReplyList(String commentId) async {
//     pageNumber=0;
//     _isFirstLoadRunning = true;
//     _commentReplyList = ApiResponse.loading('Loading');
//     await Future.delayed(Duration(milliseconds: 1));
//     notifyListeners();
//     try {
//       List<CommentReplyModel> feedList = await _socialRepository.fetchAllSocialFeedCommentsReply(_currentUserId,(pageNumber*10).toString(),commentId);
//       _commentReplyList = ApiResponse.completed(feedList.length>0?feedList:<CommentReplyModel>[]);
//       notifyListeners();
//     } catch (e) {
//       _isFirstLoadRunning = false;
//       _commentReplyList = ApiResponse.error(e.toString());
//       notifyListeners();
//     }
//   }

//   fetchMoreList(String commentId) async {
//     _isLoadMoreRunning=true;
//     controller.add(true);
//     pageNumber++;

//     notifyListeners();
//     try {
//       List<CommentReplyModel> commentReplyList = await _socialRepository.fetchAllSocialFeedCommentsReply(_currentUserId,(pageNumber*10).toString(),commentId);
//       if(commentReplyList.length<10)
//         _hasNextPage=false;
//       var duplicateList=_commentReplyList.data;
//       duplicateList.addAll(commentReplyList);
//       _commentReplyList = ApiResponse.completed(duplicateList);
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
//     if(process=="+"){
//       _commentReplyList.data[index].like_count=_commentReplyList.data[index].like_count+1;
//       _commentReplyList.data[index].like_type= likeType;
//     }else{
//       _commentReplyList.data[index].like_count=_commentReplyList.data[index].like_count-1;
//       _commentReplyList.data[index].like_type= likeType;
//     }
//     notifyListeners();

//   }

//   updateCommentLikeDislikeCount(String process , String likeType){
//     if(process=="+"){
//       socialCommentModel.like_count=socialCommentModel.like_count+1;
//       socialCommentModel.like_type= likeType;
//     }else{
//       socialCommentModel.like_count=socialCommentModel.like_count-1;
//       socialCommentModel.like_type= likeType;
//     }
//     notifyListeners();
//   }





//   addCommentReply(CommentReplyModel commentReplyModel){
//     _commentReplyList.data.add(commentReplyModel);
//     socialCommentModel.reply_count=socialCommentModel.reply_count+1;
//     notifyListeners();

//   }



// }