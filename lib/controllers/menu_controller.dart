import 'package:HyS/constants/style.dart';
import 'package:HyS/routing/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MenuController extends GetxController {
  static MenuController instance = Get.find();
  var activeItem = OverViewPageRoute.obs;
  var hoverItem = "".obs;
  var profileHover = false.obs;
  var friendsHover = false.obs;
  var groupHover = false.obs;
  var studyHover = false.obs;
  var libraryHover = false.obs;
  changeActiveItemTo(String itemname) {
    activeItem.value = itemname;
  }

  onHover(String itemname) {
    if (!isActive(itemname)) {
      hoverItem.value = itemname;
    }
  }

  isActive(String itemname) => activeItem.value == itemname;
  isHovering(String itemname) => hoverItem.value == itemname;

  Widget returnIconFor(String itemname) {
    switch (itemname) {
      case OverViewPageRoute:
        return _customIcon(Icons.trending_up, itemname);
      case DriversPageRoute:
        return _customIcon(Icons.drive_eta, itemname);
      case ClientsPageRoute:
        return _customIcon(Icons.people_alt_outlined, itemname);
      case AuthenticationPageRoute:
        return _customIcon(Icons.exit_to_app, itemname);

      default:
        return _customIcon(Icons.exit_to_app, itemname);
    }
  }

  Widget _customIcon(IconData icon, String itemName) {
    if (isActive(itemName)) return Icon(icon, size: 22, color: dark);
    return Icon(icon, color: isHovering(itemName) ? dark : lightGrey);
  }
}
