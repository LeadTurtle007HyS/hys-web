import 'package:flutter/material.dart';

class Decoration {
  //main heading
  TextStyle h1style() {
    return TextStyle(
      fontFamily: 'Nunito Sans',
      fontSize: 35,
      color: Color(0xff0C2551),
      fontWeight: FontWeight.w900,
    );
  }

  //subheading
  TextStyle h2style() {
    return TextStyle(
      fontFamily: 'Nunito Sans',
      fontSize: 15,
      color: Colors.grey,
      fontWeight: FontWeight.w700,
    );
  }

  //paragraph
  TextStyle h3style() {
    return TextStyle(
      fontFamily: 'Product Sans',
      fontSize: 15,
      color: Color(0xff8f9db5),
    );
  }

  //error heading
  TextStyle errorH1style() {
    return TextStyle(
      fontFamily: 'Nunito Sans',
      fontSize: 35,
      color: Color(0xff0C2551),
      fontWeight: FontWeight.w900,
    );
  }

  //error paragraph
  TextStyle errorH2style() {
    return TextStyle(
      color: Colors.red,
      fontWeight: FontWeight.w700,
      fontFamily: 'Nunito Sans',
    );
  }

  //button text style
  TextStyle buttonText() {
    return TextStyle(
        color: Colors.white,
        fontFamily: 'Nunito Sans',
        fontWeight: FontWeight.w500,
        fontSize: 17);
  }

  //button icon
  Icon bIcon() {
    return Icon(
      Icons.arrow_forward_ios_outlined,
      color: Colors.white,
      size: 30.0,
    );
  }

  //button size
  final bSize = 48;
  //button height
  final bHeight = 50;
  //button width
  final bWidth = 190;
}
