import 'package:HyS/constants/style.dart';
import 'package:HyS/pages/authentication/authentication.dart';
import 'package:HyS/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VerticalMenuItem extends StatefulWidget {
  const VerticalMenuItem({Key? key}) : super(key: key);

  @override
  _VerticalMenuItemState createState() => _VerticalMenuItemState();
}

class _VerticalMenuItemState extends State<VerticalMenuItem> {
  var profileHover = false.obs;
  var friendsHover = false.obs;
  var groupHover = false.obs;
  var studyHover = false.obs;
  var libraryHover = false.obs;
  var logOutHover = false.obs;
  var searchHover = false.obs;
  final AuthService _auth = AuthService();
  @override
  Widget build(BuildContext context) {
    double _width = MediaQuery.of(context).size.width;
    return Container(
      width: 60,
      color: background,
      child: Column(
        children: [
          SizedBox(height: 10),
          Tooltip(
            message: "Search",
            preferBelow: false,
            child: InkWell(
              onTap: () {},
              onHover: (value) {
                searchHover.value = value;
              },
              child: Obx(() => Container(
                    color: searchHover.value == true
                        ? lightGrey.withOpacity(0.1)
                        : Colors.transparent,
                    margin: EdgeInsets.only(top: 10, bottom: 10),
                    child: Row(
                      children: [
                        Visibility(
                            visible: searchHover.value,
                            child: Container(width: 6, height: 40, color: dark),
                            maintainSize: true,
                            maintainState: true,
                            maintainAnimation: true),
                        SizedBox(width: 10),
                        Icon(Icons.search, size: 30, color: dark),
                      ],
                    ),
                  )),
            ),
          ),
          Tooltip(
            message: "Friends",
            preferBelow: false,
            child: InkWell(
              onTap: () {},
              onHover: (value) {
                friendsHover.value = value;
              },
              child: Obx(() => Container(
                    color: friendsHover.value == true
                        ? lightGrey.withOpacity(0.1)
                        : Colors.transparent,
                    margin: EdgeInsets.only(top: 10, bottom: 10),
                    child: Row(
                      children: [
                        Visibility(
                            visible: friendsHover.value,
                            child: Container(width: 6, height: 40, color: dark),
                            maintainSize: true,
                            maintainState: true,
                            maintainAnimation: true),
                        SizedBox(width: 10),
                        Icon(Icons.people, size: 30, color: dark),
                      ],
                    ),
                  )),
            ),
          ),
          Tooltip(
            message: "Groups",
            preferBelow: false,
            child: InkWell(
              onTap: () {},
              onHover: (value) {
                groupHover.value = value;
              },
              child: Obx(() => Container(
                    color: groupHover.value == true
                        ? lightGrey.withOpacity(0.1)
                        : Colors.transparent,
                    margin: EdgeInsets.only(top: 10, bottom: 10),
                    child: Row(
                      children: [
                        Visibility(
                            visible: groupHover.value,
                            child: Container(width: 6, height: 40, color: dark),
                            maintainSize: true,
                            maintainState: true,
                            maintainAnimation: true),
                        SizedBox(width: 10),
                        Icon(Icons.group_work, size: 30, color: dark),
                      ],
                    ),
                  )),
            ),
          ),
          Tooltip(
            message: "Study planner",
            preferBelow: false,
            child: InkWell(
              onTap: () {},
              onHover: (value) {
                studyHover.value = value;
              },
              child: Obx(() => Container(
                    color: studyHover.value == true
                        ? lightGrey.withOpacity(0.1)
                        : Colors.transparent,
                    margin: EdgeInsets.only(top: 10, bottom: 10),
                    child: Row(
                      children: [
                        Visibility(
                            visible: studyHover.value,
                            child: Container(width: 6, height: 40, color: dark),
                            maintainSize: true,
                            maintainState: true,
                            maintainAnimation: true),
                        SizedBox(width: 10),
                        Icon(Icons.calendar_today, size: 30, color: dark),
                      ],
                    ),
                  )),
            ),
          ),
          Tooltip(
            message: "Library",
            preferBelow: false,
            child: InkWell(
              onTap: () {},
              onHover: (value) {
                libraryHover.value = value;
              },
              child: Obx(() => Container(
                    color: libraryHover.value == true
                        ? lightGrey.withOpacity(0.1)
                        : Colors.transparent,
                    margin: EdgeInsets.only(top: 10, bottom: 10),
                    child: Row(
                      children: [
                        Visibility(
                            visible: libraryHover.value,
                            child: Container(width: 6, height: 40, color: dark),
                            maintainSize: true,
                            maintainState: true,
                            maintainAnimation: true),
                        SizedBox(width: 10),
                        Icon(Icons.library_books, size: 30, color: dark),
                      ],
                    ),
                  )),
            ),
          ),
          Expanded(child: Container()),
          Tooltip(
            message: "Logout",
            preferBelow: false,
            child: InkWell(
              onTap: () async {
                print("Logout");
                await _auth.signOut();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AuthPage()),
                );
              },
              onHover: (value) {
                logOutHover.value = value;
              },
              child: Obx(() => Container(
                    color: logOutHover.value == true
                        ? lightGrey.withOpacity(0.1)
                        : Colors.transparent,
                    margin: EdgeInsets.only(top: 10, bottom: 10),
                    child: Row(
                      children: [
                        Visibility(
                            visible: logOutHover.value,
                            child: Container(width: 6, height: 40, color: dark),
                            maintainSize: true,
                            maintainState: true,
                            maintainAnimation: true),
                        SizedBox(width: 10),
                        Icon(Icons.logout, size: 30, color: dark),
                      ],
                    ),
                  )),
            ),
          ),
        ],
      ),
    );
  }
}
