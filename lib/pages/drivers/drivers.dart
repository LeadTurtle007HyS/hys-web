import 'package:HyS/constants/controllers.dart';
import 'package:HyS/helpers/responsiveness.dart';
import 'package:HyS/widgets/custom_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Drivers extends StatelessWidget {
  const Drivers({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Obx(() => Row(
              children: [
                Container(
                    margin: EdgeInsets.only(
                        top: ResponsiveWidget.isSmallScreen(context) ? 56 : 6),
                    child: CustomText(
                        text: menuController.activeItem.value,
                        size: 24,
                        color: Colors.black,
                        weight: FontWeight.bold))
              ],
            ))
      ],
    );
  }
}
