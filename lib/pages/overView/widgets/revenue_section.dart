import 'package:HyS/constants/style.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import 'bar_chart.dart';

class RevenueSection extends StatefulWidget {
  const RevenueSection({Key? key}) : super(key: key);

  @override
  _RevenueSectionState createState() => _RevenueSectionState();
}

class _RevenueSectionState extends State<RevenueSection> {
  @override
  Widget build(BuildContext context) {
    var _width = (MediaQuery.of(context).size.width).obs;
    return Obx(() => _width <= 1200 ? _isScreenMedium() : _isScreenLarge());
  }

  Widget _isScreenLarge() {
    return Container(
      margin: EdgeInsets.all(20),
      child: Material(
        borderRadius: BorderRadius.circular(10),
        child: Container(
            height: 320,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
                border: Border.all(color: lightGrey.withOpacity(0.1))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  margin: EdgeInsets.only(left: 30),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("Revenue Chart",
                          style: TextStyle(
                              color: lightGrey,
                              fontSize: 22,
                              fontWeight: FontWeight.bold)),
                      SizedBox(
                        height: 20,
                      ),
                      Container(
                          width: 600,
                          height: 200,
                          child: SimpleBarChart.withSampleData())
                    ],
                  ),
                ),
                Container(width: 1, height: 120, color: lightGrey),
                Expanded(
                  child: Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text("Today's revenue",
                                style: TextStyle(
                                    fontSize: 16,
                                    color: lightGrey,
                                    fontWeight: FontWeight.normal)),
                            SizedBox(height: 20),
                            Text("\$ 230",
                                style: TextStyle(
                                    fontSize: 30,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold)),
                            SizedBox(height: 30),
                            Text("Today's revenue",
                                style: TextStyle(
                                    fontSize: 16,
                                    color: lightGrey,
                                    fontWeight: FontWeight.normal)),
                            SizedBox(height: 20),
                            Text("\$ 230",
                                style: TextStyle(
                                    fontSize: 30,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text("Today's revenue",
                                style: TextStyle(
                                    fontSize: 16,
                                    color: lightGrey,
                                    fontWeight: FontWeight.normal)),
                            SizedBox(height: 20),
                            Text("\$ 230",
                                style: TextStyle(
                                    fontSize: 30,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold)),
                            SizedBox(height: 30),
                            Text("Today's revenue",
                                style: TextStyle(
                                    fontSize: 16,
                                    color: lightGrey,
                                    fontWeight: FontWeight.normal)),
                            SizedBox(height: 20),
                            Text("\$ 230",
                                style: TextStyle(
                                    fontSize: 30,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )),
      ),
    );
  }

  Widget _isScreenMedium() {
    return Container(
      margin: EdgeInsets.all(20),
      child: Material(
        borderRadius: BorderRadius.circular(10),
        child: Container(
            padding: EdgeInsets.only(top: 30, bottom: 30),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
                border: Border.all(color: lightGrey.withOpacity(0.1))),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("Revenue Chart",
                          style: TextStyle(
                              color: lightGrey,
                              fontSize: 22,
                              fontWeight: FontWeight.bold)),
                      SizedBox(
                        height: 20,
                      ),
                      Container(
                          width: 500,
                          height: 200,
                          child: SimpleBarChart.withSampleData())
                    ],
                  ),
                ),
                SizedBox(height: 50),
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text("Today's revenue",
                              style: TextStyle(
                                  fontSize: 16,
                                  color: lightGrey,
                                  fontWeight: FontWeight.normal)),
                          SizedBox(height: 20),
                          Text("\$ 230",
                              style: TextStyle(
                                  fontSize: 30,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold)),
                          SizedBox(height: 30),
                          Text("Today's revenue",
                              style: TextStyle(
                                  fontSize: 16,
                                  color: lightGrey,
                                  fontWeight: FontWeight.normal)),
                          SizedBox(height: 20),
                          Text("\$ 230",
                              style: TextStyle(
                                  fontSize: 30,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text("Today's revenue",
                              style: TextStyle(
                                  fontSize: 16,
                                  color: lightGrey,
                                  fontWeight: FontWeight.normal)),
                          SizedBox(height: 20),
                          Text("\$ 230",
                              style: TextStyle(
                                  fontSize: 30,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold)),
                          SizedBox(height: 30),
                          Text("Today's revenue",
                              style: TextStyle(
                                  fontSize: 16,
                                  color: lightGrey,
                                  fontWeight: FontWeight.normal)),
                          SizedBox(height: 20),
                          Text("\$ 230",
                              style: TextStyle(
                                  fontSize: 30,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            )),
      ),
    );
  }
}
