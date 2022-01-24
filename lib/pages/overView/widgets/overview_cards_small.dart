import 'package:HyS/pages/overView/widgets/overview_cards.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OverViewCardsSmallScreen extends StatefulWidget {
  const OverViewCardsSmallScreen({Key? key}) : super(key: key);

  @override
  _OverViewCardsSmallScreenState createState() =>
      _OverViewCardsSmallScreenState();
}

class _OverViewCardsSmallScreenState extends State<OverViewCardsSmallScreen> {
  var ridesProgess = false.obs;
  var packageDelivered = false.obs;
  var canelledDelivery = false.obs;
  var scheduledDeliveries = false.obs;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                  child: GestureDetector(
                      onTap: () {
                        ridesProgess.value = true;
                        packageDelivered.value = false;
                        canelledDelivery.value = false;
                        scheduledDeliveries.value = false;
                      },
                      child: Obx(
                        () => OverViewCard(
                            title: "Rides in progress",
                            value: "7",
                            color: Colors.orange,
                            isClicked: ridesProgess.value),
                      ))),
              Expanded(
                  child: GestureDetector(
                      onTap: () {
                        ridesProgess.value = false;
                        packageDelivered.value = true;
                        canelledDelivery.value = false;
                        scheduledDeliveries.value = false;
                      },
                      child: Obx(
                        () => OverViewCard(
                            title: "Packages deliverd",
                            value: "17",
                            color: Colors.green,
                            isClicked: packageDelivered.value),
                      ))),
            ],
          ),
          Row(
            children: [
              Expanded(
                  child: GestureDetector(
                      onTap: () {
                        ridesProgess.value = false;
                        packageDelivered.value = false;
                        canelledDelivery.value = true;
                        scheduledDeliveries.value = false;
                      },
                      child: Obx(
                        () => OverViewCard(
                            title: "Cancelled delivery",
                            value: "3",
                            color: Colors.redAccent,
                            isClicked: canelledDelivery.value),
                      ))),
              Expanded(
                  child: GestureDetector(
                      onTap: () {
                        ridesProgess.value = false;
                        packageDelivered.value = false;
                        canelledDelivery.value = false;
                        scheduledDeliveries.value = true;
                      },
                      child: Obx(
                        () => OverViewCard(
                            title: "Scheduled deliveries",
                            value: "7",
                            color: Colors.purple,
                            isClicked: scheduledDeliveries.value),
                      ))),
            ],
          ),
        ],
      ),
    );
  }
}
