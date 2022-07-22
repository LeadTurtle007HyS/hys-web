import 'package:flutter/material.dart';

class NavBarIndex extends ChangeNotifier {
  var tabIndex = 0;
  int get getCounter {
    return tabIndex;
  }


void setTabCount(int index){
  tabIndex = index;
    notifyListeners();
}

}