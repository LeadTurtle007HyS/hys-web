import 'package:HyS/constants/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class OverViewCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final bool isClicked;
  const OverViewCard(
      {Key? key,
      required this.title,
      required this.value,
      required this.color,
      required this.isClicked})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Material(
        elevation: 1,
        borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
        shadowColor: lightGrey.withOpacity(0.1),
        child: Container(
          height: 136,
          decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                  color: isClicked == true ? color : Colors.transparent),
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10))),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Container(color: color, height: 4),
                  )
                ],
              ),
              SizedBox(
                height: 30,
              ),
              Text("$title",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: lightGrey,
                      fontSize: 16,
                      fontWeight: FontWeight.normal)),
              Text("$value",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 40,
                      fontWeight: FontWeight.normal)),
            ],
          ),
        ),
      ),
    );
  }
}
