import 'package:HyS/constants/style.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OverViewCardsVerySmallScreen extends StatefulWidget {
  const OverViewCardsVerySmallScreen({Key? key}) : super(key: key);

  @override
  _OverViewCardsVerySmallScreenState createState() =>
      _OverViewCardsVerySmallScreenState();
}

var ridesProgess = false.obs;
var packageDelivered = false.obs;
var canelledDelivery = false.obs;
var scheduledDeliveries = false.obs;

class _OverViewCardsVerySmallScreenState
    extends State<OverViewCardsVerySmallScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          GestureDetector(
              onTap: () {
                ridesProgess.value = true;
                packageDelivered.value = false;
                canelledDelivery.value = false;
                scheduledDeliveries.value = false;
              },
              child: Obx(() => smallCard("Rides in progress", "7",
                  ridesProgess.value, Colors.orange))),
          GestureDetector(
              onTap: () {
                ridesProgess.value = false;
                packageDelivered.value = true;
                canelledDelivery.value = false;
                scheduledDeliveries.value = false;
              },
              child: Obx(() => smallCard("Packages delivered", "17",
                  packageDelivered.value, Colors.green))),
          GestureDetector(
              onTap: () {
                ridesProgess.value = false;
                packageDelivered.value = false;
                canelledDelivery.value = true;
                scheduledDeliveries.value = false;
              },
              child: Obx(() => smallCard("Cancelled delivery", "3",
                  canelledDelivery.value, Colors.redAccent))),
          GestureDetector(
              onTap: () {
                ridesProgess.value = false;
                packageDelivered.value = false;
                canelledDelivery.value = false;
                scheduledDeliveries.value = true;
              },
              child: Obx(() => smallCard("Scheduled deliveries", "32",
                  scheduledDeliveries.value, Colors.purple)))
        ],
      ),
    );
  }
}

Widget smallCard(String title, String value, bool isClicked, Color color) {
  return Container(
    decoration: BoxDecoration(
        border: Border.all(
          color: isClicked == true ? color : lightGrey,
        ),
        borderRadius: BorderRadius.circular(10),
        color: Colors.white),
    padding: EdgeInsets.only(left: 15, right: 15, top: 20, bottom: 20),
    margin: EdgeInsets.all(10),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("$title",
            style: TextStyle(
                color: isClicked == true ? color : lightGrey,
                fontSize: isClicked == true ? 25 : 20,
                fontWeight: FontWeight.normal)),
        Text("$value",
            style: TextStyle(
                color: isClicked == true ? color : dark,
                fontSize: isClicked == true ? 30 : 25,
                fontWeight:
                    isClicked == true ? FontWeight.bold : FontWeight.normal)),
      ],
    ),
  );
}
