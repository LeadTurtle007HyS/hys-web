// import 'dart:async';

// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';

// import '../database/social_repository.dart';
// import '../models/network_request_genric.dart';
// import '../models/notifications_model.dart';

// class NotificationProvider extends ChangeNotifier {
//   SocialRepository? _socialRepository;
//   ApiResponse<List<NotificationModel>>? _notificationsList;
//   List<NotificationModel> _qnaNotificationsList = [];
//   List<NotificationModel> _socialNotificationsList = [];
//   List<NotificationModel> _friendNotificationsList = [];
//   ApiResponse<List<NotificationModel>> get notificationsList =>
//       _notificationsList!;
//   List<NotificationModel> get qnaNotificationsList => _qnaNotificationsList;
//   List<NotificationModel> get socialNotificationsList =>
//       _socialNotificationsList;
//   List<NotificationModel> get friendNotificationList =>
//       _friendNotificationsList;

//   String? _currentUserId;

//   // ignore: close_sinks
//   StreamController<bool> controller = StreamController<bool>.broadcast();

//   // ignore: non_constant_identifier_names
//   NotificationProvider() {
//     _notificationsList = ApiResponse.loading("Loading");
//     _socialRepository = SocialRepository();
//     _currentUserId = FirebaseAuth.instance.currentUser!.uid;
//     fetchNotificationsList(_currentUserId!);
//   }

//   fetchNotificationsList(String userID) async {
//     _notificationsList = ApiResponse.loading('Loading');
//     await Future.delayed(Duration(milliseconds: 1));
//     notifyListeners();
//     try {
//       List<NotificationModel> movies =
//           await _socialRepository!.fetchAllNotifications(userID);

//       for (var notificationModel in movies) {
//         var section = notificationModel.section;
//         if (section.isNotEmpty &&
//             (section == "question" ||
//                 section == "answer" ||
//                 section == "comment")) {
//           _qnaNotificationsList.add(notificationModel);
//         } else if (section.isNotEmpty &&
//             (section == "social" || section == "socialpost")) {
//           _socialNotificationsList.add(notificationModel);
//         } else if (section.isNotEmpty &&
//             (section == "request" ||
//                 section == "requestaccept " ||
//                 section == "follow")) {
//           _friendNotificationsList.add(notificationModel);
//         }
//       }

//       _notificationsList = ApiResponse.completed(movies);
//       notifyListeners();
//     } catch (e) {
//       _notificationsList = ApiResponse.error(e.toString());
//       notifyListeners();
//     }
//   }

//   isClicked(String value, int index) {
//     if (value == "false") {
//       _notificationsList!.data![index].isClicked = 'true';
//     }
//     notifyListeners();
//   }

//   void deleteFriendReqNotification(int index) {
//     var notifyID = _notificationsList!.data![index].notifyId;
//     int position = -1;
//     for (int i = 0; i < _friendNotificationsList.length; i++) {
//       if (notifyID == _friendNotificationsList[i].notifyId) {
//         position = i;
//         break;
//       }
//     }
//     if (position != -1) friendNotificationList.removeAt(position);
//     _notificationsList!.data!.removeAt(index);
//     _deleteNotificationFromDB(notifyID);
//     notifyListeners();
//   }

//   void deleteParticularFriendReqNotification(int index) {
//     var notifyID = _friendNotificationsList[index].notifyId;
//     int position = -1;
//     for (int i = 0; i < _notificationsList!.data!.length; i++) {
//       if (notifyID == _notificationsList!.data![i].notifyId) {
//         position = i;
//         break;
//       }
//     }
//     if (position != -1) _notificationsList!.data!.removeAt(position);
//     _friendNotificationsList.removeAt(index);
//     _deleteNotificationFromDB(notifyID);
//     notifyListeners();
//   }

//   _deleteNotificationFromDB(String notificationID) {
//     _socialRepository!.deleteNotification(notificationID);
//   }
// }
