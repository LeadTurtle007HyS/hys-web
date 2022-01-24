import 'dart:typed_data';

import 'package:HyS/constants/style.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/shims/dart_ui_real.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:file_picker/file_picker.dart';
import 'package:oktoast/oktoast.dart';

class HtmlEditorExample extends StatefulWidget {
  @override
  _HtmlEditorExampleState createState() => _HtmlEditorExampleState();
}

class _HtmlEditorExampleState extends State<HtmlEditorExample> {
  String result = '';
  final GlobalKey<State> _keyLoader = new GlobalKey<State>();
  String _currentUserId = FirebaseAuth.instance.currentUser!.uid;
  final HtmlEditorController controller = HtmlEditorController();
  double progress = 0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (!kIsWeb) {
          controller.clearFocus();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: light,
          title: Text("HyS Blog Editor",
              style: TextStyle(
                  color: Colors.black87, fontWeight: FontWeight.bold)),
          elevation: 0,
          actions: [
            // IconButton(
            //     icon: Icon(Icons.refresh),
            //     onPressed: () {
            //       if (kIsWeb) {
            //         controller.reloadWeb();
            //       } else {
            //         controller.editorController!.reload();
            //       }
            //     })
          ],
        ),
        // floatingActionButton: FloatingActionButton(
        //   onPressed: () {
        //     controller.toggleCodeView();
        //   },
        //   child: Text(r'<\>',
        //       style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        // ),
        body: SingleChildScrollView(
          child: Padding(
            padding:
                const EdgeInsets.only(left: 30.0, right: 30.0, bottom: 30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(height: 30),
                HtmlEditor(
                  controller: controller,
                  htmlEditorOptions: HtmlEditorOptions(
                    hint: 'Your text here...',
                    shouldEnsureVisible: true,
                    //initialText: "<p>text content initial, if any</p>",
                  ),
                  htmlToolbarOptions: HtmlToolbarOptions(
                    toolbarPosition: ToolbarPosition.aboveEditor, //by default
                    toolbarType: ToolbarType.nativeScrollable, //by default
                    onButtonPressed: (ButtonType type, bool? status,
                        Function()? updateStatus) {
                      print(
                          "button '${describeEnum(type)}' pressed, the current selected status is $status");
                      return true;
                    },
                    onDropdownChanged: (DropdownType type, dynamic changed,
                        Function(dynamic)? updateSelectedItem) {
                      print(
                          "dropdown '${describeEnum(type)}' changed to $changed");
                      return true;
                    },
                    mediaLinkInsertInterceptor:
                        (String url, InsertFileType type) {
                      print(url);
                      return true;
                    },
                    mediaUploadInterceptor:
                        (PlatformFile file, InsertFileType type) async {
                      print(file.name); //filename
                      print(file.size); //size in bytes
                      print(file.extension); //file extension (eg jpeg or mp4)
                      return true;
                    },
                  ),
                  otherOptions: OtherOptions(height: 550),
                  callbacks: Callbacks(onBeforeCommand: (String? currentHtml) {
                    print('html before change is $currentHtml');
                  }, onChangeContent: (String? changed) {
                    print('content changed to $changed');
                  }, onChangeCodeview: (String? changed) {
                    print('code changed to $changed');
                  }, onChangeSelection: (EditorSettings settings) {
                    print('parent element is ${settings.parentElement}');
                    print('font name is ${settings.fontName}');
                  }, onDialogShown: () {
                    print('dialog shown');
                  }, onEnter: () {
                    print('enter/return pressed');
                  }, onFocus: () {
                    print('editor focused');
                  }, onBlur: () {
                    print('editor unfocused');
                  }, onBlurCodeview: () {
                    print('codeview either focused or unfocused');
                  }, onInit: () {
                    print('init');
                  },
                      //this is commented because it overrides the default Summernote handlers
                      /*onImageLinkInsert: (String? url) {
                      print(url ?? "unknown url");
                    },
                    onImageUpload: (FileUpload file) async {
                      print(file.name);
                      print(file.size);
                      print(file.type);
                      print(file.base64);
                    },*/
                      onImageUploadError: (FileUpload? file, String? base64Str,
                          UploadError error) {
                    print(describeEnum(error));
                    print(base64Str ?? '');
                    if (file != null) {
                      print(file.name);
                      print(file.size);
                      print(file.type);
                    }
                  }, onKeyDown: (int? keyCode) {
                    print('$keyCode key downed');
                    print(
                        'current character count: ${controller.characterCount}');
                  }, onKeyUp: (int? keyCode) {
                    print('$keyCode key released');
                  }, onMouseDown: () {
                    print('mouse downed');
                  }, onMouseUp: () {
                    print('mouse released');
                  }, onNavigationRequestMobile: (String url) {
                    print(url);
                    return NavigationActionPolicy.ALLOW;
                  }, onPaste: () {
                    print('pasted into editor');
                  }, onScroll: () {
                    print('editor scrolled');
                  }),
                  plugins: [
                    SummernoteAtMention(
                        getSuggestionsMobile: (String value) {
                          var mentions = <String>['test1', 'test2', 'test3'];
                          return mentions
                              .where((element) => element.contains(value))
                              .toList();
                        },
                        mentionsWeb: ['test1', 'test2', 'test3'],
                        onSelect: (String value) {
                          print(value);
                        }),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      TextButton(
                        style: TextButton.styleFrom(
                            backgroundColor: Theme.of(context).accentColor),
                        onPressed: () {
                          _insertImage(context);
                        },
                        child: Text(
                          'Insert Image',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      SizedBox(
                        width: 16,
                      ),
                      TextButton(
                        style: TextButton.styleFrom(
                            backgroundColor: Theme.of(context).accentColor),
                        onPressed: () async {
                          var txt = await controller.getText();
                          if (txt.contains('src=\"data:')) {
                            txt =
                                '<text removed due to base-64 data, displaying the text could cause the app to crash>';
                          }
                          setState(() {
                            result = txt;
                            print("result: $result");
                          });
                          Navigator.pop(context, result);
                        },
                        child: Text(
                          'Submit',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String url = "";
  void _insertImage(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      Uint8List? file = result.files.first.bytes;
      String fileName = result.files.first.name;
      Dialogs.showLoadingDialog(context, _keyLoader);
      UploadTask task = FirebaseStorage.instance
          .ref()
          .child("userVideoReference/$_currentUserId/$fileName")
          .putData(file!);

      task.snapshotEvents.listen((event) async {
        setState(() {
          progress = ((event.bytesTransferred.toDouble() /
                      event.totalBytes.toDouble()) *
                  100)
              .roundToDouble();
        });
        if (progress == 100) {
          print(progress);
          String downloadURL = await FirebaseStorage.instance
              .ref("userVideoReference/$_currentUserId/$fileName")
              .getDownloadURL();
          if (downloadURL != null) {
            setState(() {
              url = downloadURL;
              progress = 0.0;
            });
            controller.insertNetworkImage(url, filename: fileName);
            Navigator.of(_keyLoader.currentContext!, rootNavigator: true)
                .pop(); //close the dialoge
            showToast(
              "You attached video file successfully.",
              duration: Duration(seconds: 4),
              position: ToastPosition.top,
              backgroundColor: active.withOpacity(0.7),
              radius: 13.0,
              textPadding: EdgeInsets.all(5),
              textStyle: TextStyle(fontSize: 18.0),
            );
          }
        }
      });
    }
  }
}

class Dialogs {
  static Future<void> showLoadingDialog(
      BuildContext context, GlobalKey key) async {
    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new WillPopScope(
              onWillPop: () async => false,
              child: SimpleDialog(
                  key: key,
                  backgroundColor: Colors.black54,
                  children: <Widget>[
                    Center(
                      child: Column(children: [
                        CircularProgressIndicator(),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          "Please Wait....",
                          style: TextStyle(color: Colors.blueAccent),
                        )
                      ]),
                    )
                  ]));
        });
  }
}
