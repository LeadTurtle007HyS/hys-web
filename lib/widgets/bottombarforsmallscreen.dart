import 'package:HyS/constants/style.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class BottomBarMobileScreen extends StatefulWidget {
  const BottomBarMobileScreen({Key? key}) : super(key: key);

  @override
  _BottomBarMobileScreenState createState() => _BottomBarMobileScreenState();
}

class _BottomBarMobileScreenState extends State<BottomBarMobileScreen> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  DataSnapshot? countData;
  final String _currentUserId = FirebaseAuth.instance.currentUser!.uid;
  final databaseReference = FirebaseDatabase.instance.reference();
  int appbar_nav_index = 1;

  @override
  Widget build(BuildContext context) {
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
      appbar_nav_index = countData!.value["app_bar_navigation"][_currentUserId]
          [_currentUserId];
      return Container(
          height: 60,
          color: active,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              InkWell(
                onTap: () {
                  databaseReference
                      .child("hysweb")
                      .child("app_bar_navigation")
                      .child(_currentUserId)
                      .update({"$_currentUserId": 1});
                  setState(() {
                    appbar_nav_index = 1;
                  });
                },
                child: Container(
                  child: Text("HOME",
                      style: TextStyle(
                          color: background,
                          fontSize: appbar_nav_index == 1 ? 22 : 16,
                          fontWeight: appbar_nav_index == 1
                              ? FontWeight.w900
                              : FontWeight.normal)),
                ),
              ),
              InkWell(
                onTap: () {
                  databaseReference
                      .child("hysweb")
                      .child("app_bar_navigation")
                      .child(_currentUserId)
                      .update({"$_currentUserId": 2});
                  setState(() {
                    appbar_nav_index = 2;
                  });
                },
                child: Container(
                  child: Text("NETWORK",
                      style: TextStyle(
                          color: background,
                          fontSize: appbar_nav_index == 2 ? 22 : 16,
                          fontWeight: appbar_nav_index == 2
                              ? FontWeight.w900
                              : FontWeight.normal)),
                ),
              ),
              InkWell(
                onTap: () {
                  databaseReference
                      .child("hysweb")
                      .child("app_bar_navigation")
                      .child(_currentUserId)
                      .update({"$_currentUserId": 3});
                  setState(() {
                    appbar_nav_index = 3;
                  });
                },
                child: Container(
                  child: Text("LIVE BOOKS",
                      style: TextStyle(
                          color: background,
                          fontSize: appbar_nav_index == 3 ? 22 : 16,
                          fontWeight: appbar_nav_index == 3
                              ? FontWeight.w900
                              : FontWeight.normal)),
                ),
              ),
            ],
          ));
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
