import 'dart:convert';

import 'package:HyS/constants/style.dart';
import 'package:HyS/helpers/responsiveness.dart';
import 'package:HyS/pages/authentication/authentication.dart';
import 'package:HyS/services/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

class HorizontalMenuItem extends StatefulWidget {
  const HorizontalMenuItem({Key? key}) : super(key: key);

  @override
  _HorizontalMenuItemState createState() => _HorizontalMenuItemState();
}

class _HorizontalMenuItemState extends State<HorizontalMenuItem> {
  var profileHover = false.obs;
  var friendsHover = false.obs;
  var groupHover = false.obs;
  var studyHover = false.obs;
  var libraryHover = false.obs;
  var logOutHover = false.obs;
  Box<dynamic>? userDataDB;
  final AuthService _auth = AuthService();
  final String _currentUserId = FirebaseAuth.instance.currentUser!.uid;
  final databaseReference = FirebaseDatabase.instance.reference();
  @override
  void initState() {
    userDataDB = Hive.box<dynamic>('userdata');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: background,
      child: Column(
        children: [
          InkWell(
              onTap: () {
                databaseReference
                    .child("hysweb")
                    .child("app_bar_navigation")
                    .child(_currentUserId)
                    .update({"$_currentUserId": 7, "userid": _currentUserId});
              },
              onHover: (value) {
                profileHover.value = value;
              },
              child: Obx(
                () => Container(
                  color: profileHover.value == true
                      ? lightGrey.withOpacity(0.1)
                      : Colors.transparent,
                  margin: EdgeInsets.all(10),
                  child: Row(
                    children: [
                      Visibility(
                          visible: profileHover.value,
                          child: Container(width: 6, height: 60, color: dark),
                          maintainSize: true,
                          maintainState: true,
                          maintainAnimation: true),
                      SizedBox(width: 10),
                      Container(
                          decoration: BoxDecoration(
                              color: light,
                              borderRadius: BorderRadius.circular(30)),
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            margin: const EdgeInsets.all(2),
                            child: CircleAvatar(
                              backgroundImage:
                                  NetworkImage(userDataDB!.get("profilepic")),
                              radius: profileHover.value == true ? 28 : 25,
                            ),
                          )),
                      SizedBox(width: 18),
                      Text(
                          "${userDataDB!.get("first_name")}\n${userDataDB!.get("last_name")}",
                          style: TextStyle(
                              color: dark,
                              fontSize: 16,
                              fontWeight: FontWeight.bold))
                    ],
                  ),
                ),
              )),
          Divider(color: lightGrey.withOpacity(0.1)),
          SizedBox(height: 10),
          InkWell(
              onTap: () {
                if (ResponsiveWidget.isSmallScreen(context)) {
                  Get.back();
                }
              },
              onHover: (value) {
                print(value);

                friendsHover.value = value;
              },
              child: Obx(
                () => Container(
                  color: friendsHover.value == true
                      ? lightGrey.withOpacity(0.1)
                      : Colors.transparent,
                  margin: EdgeInsets.all(10),
                  child: Row(
                    children: [
                      Visibility(
                          visible: friendsHover.value,
                          child: Container(width: 6, height: 40, color: dark),
                          maintainSize: true,
                          maintainState: true,
                          maintainAnimation: true),
                      SizedBox(width: 10),
                      Icon(Icons.people, size: 20, color: dark),
                      SizedBox(width: 22),
                      Text("Friends",
                          style: TextStyle(
                              color:
                                  friendsHover.value == true ? dark : lightGrey,
                              fontSize: 16,
                              fontWeight: friendsHover.value == true
                                  ? FontWeight.bold
                                  : FontWeight.normal))
                    ],
                  ),
                ),
              )),
          InkWell(
              onTap: () {
                if (ResponsiveWidget.isSmallScreen(context)) {
                  Get.back();
                }
              },
              onHover: (value) {
                groupHover.value = value;
              },
              child: Obx(
                () => Container(
                  color: groupHover.value == true
                      ? lightGrey.withOpacity(0.1)
                      : Colors.transparent,
                  margin: EdgeInsets.all(10),
                  child: Row(
                    children: [
                      Visibility(
                          visible: groupHover.value,
                          child: Container(width: 6, height: 40, color: dark),
                          maintainSize: true,
                          maintainState: true,
                          maintainAnimation: true),
                      SizedBox(width: 10),
                      Icon(Icons.group_work, size: 20, color: dark),
                      SizedBox(width: 22),
                      Text("Groups",
                          style: TextStyle(
                              color:
                                  groupHover.value == true ? dark : lightGrey,
                              fontSize: 16,
                              fontWeight: groupHover.value == true
                                  ? FontWeight.bold
                                  : FontWeight.normal))
                    ],
                  ),
                ),
              )),
          InkWell(
              onTap: () {
                if (ResponsiveWidget.isSmallScreen(context)) {
                  Get.back();
                }
              },
              onHover: (value) {
                studyHover.value = value;
              },
              child: Obx(
                () => Container(
                  color: studyHover.value == true
                      ? lightGrey.withOpacity(0.1)
                      : Colors.transparent,
                  margin: EdgeInsets.all(10),
                  child: Row(
                    children: [
                      Visibility(
                          visible: studyHover.value,
                          child: Container(width: 6, height: 40, color: dark),
                          maintainSize: true,
                          maintainState: true,
                          maintainAnimation: true),
                      SizedBox(width: 10),
                      Icon(Icons.calendar_today, size: 20, color: dark),
                      SizedBox(width: 22),
                      Text("Study planner",
                          style: TextStyle(
                              color:
                                  studyHover.value == true ? dark : lightGrey,
                              fontSize: 16,
                              fontWeight: studyHover.value == true
                                  ? FontWeight.bold
                                  : FontWeight.normal))
                    ],
                  ),
                ),
              )),
          InkWell(
              onTap: () {
                if (ResponsiveWidget.isSmallScreen(context)) {
                  Get.back();
                }
              },
              onHover: (value) {
                libraryHover.value = value;
              },
              child: Obx(
                () => Container(
                  color: libraryHover.value == true
                      ? lightGrey.withOpacity(0.1)
                      : Colors.transparent,
                  margin: EdgeInsets.all(10),
                  child: Row(
                    children: [
                      Visibility(
                          visible: libraryHover.value,
                          child: Container(width: 6, height: 40, color: dark),
                          maintainSize: true,
                          maintainState: true,
                          maintainAnimation: true),
                      SizedBox(width: 10),
                      Icon(Icons.library_books, size: 20, color: dark),
                      SizedBox(width: 22),
                      Text("Library",
                          style: TextStyle(
                              color:
                                  libraryHover.value == true ? dark : lightGrey,
                              fontSize: 16,
                              fontWeight: libraryHover.value == true
                                  ? FontWeight.bold
                                  : FontWeight.normal))
                    ],
                  ),
                ),
              )),
          Expanded(child: Container()),
          Divider(color: lightGrey.withOpacity(0.1)),
          InkWell(
              onTap: () async {
                if (ResponsiveWidget.isSmallScreen(context)) {
                  Get.back();
                }
                print("Logout");
                await _auth.signOut();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AuthPage()),
                );
              },
              onHover: (value) {
                print(value);

                logOutHover.value = value;
              },
              child: Obx(
                () => Container(
                  color: logOutHover.value == true
                      ? lightGrey.withOpacity(0.1)
                      : Colors.transparent,
                  margin: EdgeInsets.all(10),
                  child: Row(
                    children: [
                      Visibility(
                          visible: logOutHover.value,
                          child: Container(width: 6, height: 40, color: dark),
                          maintainSize: true,
                          maintainState: true,
                          maintainAnimation: true),
                      SizedBox(width: 10),
                      Icon(Icons.logout, size: 20, color: dark),
                      SizedBox(width: 22),
                      Text("Logout",
                          style: TextStyle(
                              color:
                                  logOutHover.value == true ? dark : lightGrey,
                              fontSize: 16,
                              fontWeight: logOutHover.value == true
                                  ? FontWeight.bold
                                  : FontWeight.normal))
                    ],
                  ),
                ),
              )),
          SizedBox(height: 10)
        ],
      ),
    );
  }
}
