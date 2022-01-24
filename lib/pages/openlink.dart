import 'package:flutter/material.dart';
import 'dart:html' as html;

class OpenLink extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: SelectableText("Open External Link"),
          backgroundColor: Colors.redAccent,
        ),
        body: Container(
            child: Center(
          child: ElevatedButton(
            onPressed: () {
              html.window.open(
                  'https://61deec8d9131835a3415acbd--infallible-curie-918c03.netlify.app/',
                  "_self");
            },
            child: SelectableText("Open Flutter Campus"),
          ),
        )));
  }
}
