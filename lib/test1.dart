import 'dart:html';

import 'package:flutter/material.dart';
import 'package:code_editor/code_editor.dart';

class MyEditor extends StatefulWidget {
  @override
  _MyEditorState createState() => _MyEditorState();
}

class _MyEditorState extends State<MyEditor> {
  void goFullScreen() {
    document.documentElement!.requestFullscreen();
  }

  @override
  void initState() {
    goFullScreen();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<String> contentOfPage1 = [
      "<!DOCTYPE html>",
      "<html lang='fr'>",
      "\t<body>",
      "\t\t<a href='page2.html'>go to page 2</a>",
      "\t</body>",
      "</html>",
    ];

    List<FileEditor> files = [
      new FileEditor(
        name: "page1.html",
        language: "html",
        code: contentOfPage1.join("\n"),
      ),
      new FileEditor(
        name: "page2.html",
        language: "html",
        code: "<a href='page1.html'>go back</a>",
      ),
      new FileEditor(
        name: "mahesh.sql",
        language: "sql",
        code: "select * from mahesh;",
      ),
    ];

    EditorModel model = new EditorModel(
      files: files,
      styleOptions: new EditorModelStyleOptions(
        fontSize: 13,
      ),
    );

    // since 1.3.1
    model.styleOptions?.defineEditButtonPosition(top: 10.0, right: 10.0);

    return Scaffold(
      appBar: AppBar(
        title: InkWell(
            onTap: () {
              goFullScreen();
            },
            child: Text("editor")),
      ),
      body: SingleChildScrollView(
        child: CodeEditor(
          model: model,
          onSubmit: (String? language, String? value) {
            print("language = $language");
            print("value = '$value'");
          },
        ),
      ),
    );
  }
}
