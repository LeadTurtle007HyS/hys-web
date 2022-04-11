import 'package:HyS/pages/chat/ChatScreen.dart';
import 'package:HyS/pages/chat/allChatScreen.dart';
import 'package:HyS/pages/chat/groupChatScreen.dart';
import 'package:HyS/pages/livebook_code/liveBookOpen.dart';
import 'package:HyS/pages/overView/allnotifications.dart';
import 'package:HyS/pages/overView/network/network.dart';
import 'package:HyS/pages/overView/overview.dart';
import 'package:HyS/pages/userprofile.dart';
import 'package:HyS/widgets/right_side_bar.dart';
import 'package:HyS/widgets/side_menu.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class LargeScreen extends StatefulWidget {
  const LargeScreen({Key? key}) : super(key: key);

  @override
  _LargeScreenState createState() => _LargeScreenState();
}

class _LargeScreenState extends State<LargeScreen> {
  final String _currentUserId = FirebaseAuth.instance.currentUser!.uid;
  final databaseReference = FirebaseDatabase.instance.reference();
  DataSnapshot? countData;
  @override
  Widget build(BuildContext context) {
    return _body();
  }

  _body() {
    databaseReference.child("hysweb").once().then((DataSnapshot snapshot) {
      setState(() {
        if (mounted) {
          setState(() {
            countData = snapshot;
          });
        }
      });
    });

    if (countData != null) {
      return Row(
        children: [
          const Expanded(
            child: SideMenu(),
          ),
          Expanded(
              flex: 3,
              child: countData!.value["app_bar_navigation"][_currentUserId]
                          [_currentUserId] ==
                      1
                  ? OverView()
                  : countData!.value["app_bar_navigation"][_currentUserId]
                              [_currentUserId] ==
                          2
                      ? Network()
                      : countData!.value["app_bar_navigation"][_currentUserId]
                                  [_currentUserId] ==
                              3
                          ? LiveBookOpen()
                          : countData!.value["app_bar_navigation"]
                                      [_currentUserId][_currentUserId] ==
                                  4
                              ? (countData!.value["chat"][_currentUserId]
                                              ["index"] ==
                                          0) &&
                                      (countData!.value["app_bar_navigation"]
                                              [_currentUserId][_currentUserId] !=
                                          5)
                                  ? AllChatScreen()
                                  : countData!.value["chat"][_currentUserId]["index"] == 1
                                      ? ChatScreen(countData!.value["chat"][_currentUserId]["userdetails"], countData!.value["chat"][_currentUserId]["chatid"])
                                      : GroupChatScreen(countData!.value["chat"][_currentUserId]["userdetails"], countData!.value["chat"][_currentUserId]["chatid"])
                              : countData!.value["app_bar_navigation"][_currentUserId][_currentUserId] == 6
                                  ? AllNotifications()
                                  : countData!.value["app_bar_navigation"][_currentUserId][_currentUserId] == 7
                                      ? UserProfile(countData!.value["app_bar_navigation"][_currentUserId]["userid"])
                                      : SizedBox()),
          const Expanded(
            child: RightSidebar(),
          ),
        ],
      );
    } else {
      return _loading();
    }
  }

  Widget _loading() {
    return Center(
      child: Container(
          height: 50.0,
          margin: const EdgeInsets.only(left: 10.0, right: 10.0),
          child: const Center(
              child: CircularProgressIndicator(
            valueColor:
                AlwaysStoppedAnimation<Color>(Color.fromRGBO(88, 165, 196, 1)),
          ))),
    );
  }
}
