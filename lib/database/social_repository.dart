// import '../constants.dart';
// import '../models/comment_reply_model.dart';
// import '../models/notifications_model.dart';
// import '../models/social_feed_comment_model.dart';
// import '../models/social_feed_model.dart';
// import '../network/api_base_helper.dart';

// class SocialRepository{


//   ApiBaseHelper _helper = ApiBaseHelper();

//  Future<List<SocialFeedModel>> fetchAllSocialFeed(String page,String userID) async {
//    var responseBody=  await _helper.get(Constant.All_SOCIAL_POST_PATH+userID+"/" + page) as List;
//    return responseBody
//        .map((data) => SocialFeedModel.fromJson(data))
//        .toList();

//   }

//   Future<List<SocialFeedModel>> fetchSpecificSocialFeed(String page,String userID,String type) async {
//    var path=Constant.All_SOCIAL_POST_PATH;
//    if(type=="Mood"){
//      path=Constant.All_SOCIAL_MOOD_POST_PATH;
//    }else if(type=="blog"){
//      path=Constant.All_SOCIAL_BLOG_POST_PATH;
//    }else if(type=="projectdiscuss"){
//      path=Constant.All_SOCIAL_PROJECT_POST_PATH;
//    }else if(type=="businessideas"){
//      path=Constant.All_SOCIAL_IDEA_PATH;
//    }else if(type=="cause|teachunprevilagedKids"){
//      path=Constant.All_SOCIAL_CAUSE_POST_PATH;
//    }
//     var responseBody=  await _helper.get(path+userID+"/" + page) as List;
//     return responseBody
//         .map((data) => SocialFeedModel.fromJson(data))
//         .toList();

//   }


//   Future<List<SocialFeedCommentModel>> fetchAllSocialFeedComments(String userId,String page,String postId) async {

//     var responseBody=  await _helper.get("${Constant.SOCIAL_COMMENT_LIST_PATH}$userId/$postId/$page") as List;
//     return responseBody
//         .map((data) => SocialFeedCommentModel.fromJson(data))
//         .toList();

//   }

//   Future<List<CommentReplyModel>> fetchAllSocialFeedCommentsReply(String userId,String page,String commentId) async {

//     var responseBody=  await _helper.get("${Constant.SOCIAL_COMMENT_REPLY_PATH}$userId/$commentId/$page") as List;
//     return responseBody
//         .map((data) => CommentReplyModel.fromJson(data))
//         .toList();

//   }


//   Future<List<NotificationModel>> fetchAllNotifications(String userID) async {
//     var responseBody = await _helper.get(Constant.All_NOTIFICATIONS_PATH + userID) as List;
//     return responseBody
//         .map((data) => NotificationModel.fromJson(data))
//         .toList();
//   }

//   Future<List<SocialFeedModel>> fetchSocialPostDetails(String userID,String postID ,String type) async {

//     var path=Constant.SOCIAL_POST_DETAILS_PATH;
//     if(type=="Mood"){
//       path=Constant.SOCIAL_MOOD_POST_PATH;
//     }else if(type=="blog"){
//       path=Constant.SOCIAL_BLOG_POST_PATH;
//     }else if(type=="projectdiscuss"){
//       path=Constant.SOCIAL_PROJECT_POST_PATH;
//     }else if(type=="businessideas"){
//       path=Constant.SOCIAL_IDEA_PATH;
//     }else if(type=="cause|teachunprevilagedKids"){
//       path=Constant.SOCIAL_CAUSE_POST_PATH;
//     }
//     var responseBody = await _helper.get(path + userID+"/"+postID) as List;
//     return responseBody
//         .map((data) => SocialFeedModel.fromJson(data))
//         .toList();
//   }



//   Future<List<SocialFeedCommentModel>> fetchSocialCommentDetails(String userID,String postID) async {
//     var responseBody = await _helper.get(Constant.SOCIAL_COMMENT_DETAILS_PATH + userID+"/"+postID) as List;
//     return responseBody
//         .map((data) => SocialFeedCommentModel.fromJson(data))
//         .toList();
//   }

//   Future<List<CommentReplyModel>> fetchSocialCommentReplyDetails(String userID,String postID) async {
//     var responseBody = await _helper.get(Constant.SOCIAL_COMMENT_REPLY_DETAILS_PATH + userID+"/"+postID) as List;
//     return responseBody
//         .map((data) => CommentReplyModel.fromJson(data))
//         .toList();
//   }

//   Future<List<SocialFeedModel>> fetchAllSocialFeed_inONE(String userID) async {

//     var responseBody=  await _helper.get(Constant.All_SOCIAL_POST_PATH_IN_ONE+userID) as List;

//     return responseBody

//         .map((data) => SocialFeedModel.fromJson(data))

//         .toList();

//   }

//     deleteNotification(String notifyId){
//      _helper.get(Constant.DELETE_NOTIFICATION_PATH + notifyId);
//   }




// }