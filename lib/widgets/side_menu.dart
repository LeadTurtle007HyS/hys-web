import 'package:HyS/helpers/responsiveness.dart';
import 'package:HyS/widgets/horizontal_menu_item.dart';
import 'package:HyS/widgets/vertical_menu_item.dart';
import 'package:flutter/material.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (ResponsiveWidget.isMediumScreen(context)) {
      return VerticalMenuItem();
    } else {
      return HorizontalMenuItem();
    }
  }
}
