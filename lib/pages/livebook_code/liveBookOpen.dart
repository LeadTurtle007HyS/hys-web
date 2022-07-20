import 'dart:typed_data';
import 'package:HyS/live_books/epub_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:html' as webFile;

class LiveBookOpen extends StatefulWidget {
  const LiveBookOpen({Key? key}) : super(key: key);

  @override
  State<LiveBookOpen> createState() => _LiveBookOpenState();
}

class _LiveBookOpenState extends State<LiveBookOpen> {
  EpubController? _epubReaderController;
  bool _fileLoaded = true;
  Uint8List? fileBytes;
  Box<dynamic>? epubDataDB;

  @override
  void initState() {
    epubDataDB = Hive.box<dynamic>('epub');
    if (epubDataDB!.get("isRendered") == "true") {
      final loadedBook = _loadFromNetwork(epubDataDB!.get("epubLink"));
      _epubReaderController = EpubController(
        document: EpubReader.readBook(loadedBook),
      );
    } else {}
    final loadedBook = _loadFromNetwork(
        'https://firebasestorage.googleapis.com/v0/b/hys-pro-41c66.appspot.com/o/jesc101.epub?alt=media&token=c1a56d06-1406-4fa6-86c8-49ec21419d12');
    _epubReaderController = EpubController(
      document: EpubReader.readBook(loadedBook),
    );
    super.initState();
  }

  @override
  void dispose() {
    _epubReaderController!.dispose();
    super.dispose();
  }

  Future<Uint8List> _loadFromAssets(String assetName) async {
    final bytes = await rootBundle.load(assetName);
    var blob = webFile.Blob(bytes.buffer.asUint8List(), 'text/plain', 'native');

    var anchorElement = webFile.AnchorElement(
      href: webFile.Url.createObjectUrlFromBlob(blob).toString(),
    )
      ..setAttribute("download", "databyteb.txt")
      ..click();
    return bytes.buffer.asUint8List();
  }

  Future<Uint8List> _loadFromNetwork(String url) async {
    final http.Response response = await http.get(Uri.parse(url),
        headers: <String, String>{
          "Access-Control-Allow-Origin": "*",
          "Access-Control-Allow-Methods": "GET"
        });
    if (response.statusCode == 200 || response.statusCode == 201) {
      setState(() {
        _fileLoaded = true;
      });
      fileBytes = response.bodyBytes;
      // var blob = webFile.Blob(response.bodyBytes, 'text/plain', 'native');

      // var anchorElement = webFile.AnchorElement(
      //   href: webFile.Url.createObjectUrlFromBlob(blob).toString(),
      // )
      //   ..setAttribute("download", "databyte.txt")
      //   ..click();
    }
    return fileBytes!;
  }

  @override
  Widget build(BuildContext context) => _fileLoaded
      ? EpubView(
          tittle: Padding(
            padding: const EdgeInsets.all(3.0),
            child: EpubActualChapter(
              controller: _epubReaderController!,
              builder: (chapterValue) => Text(
                (chapterValue?.chapter?.Title?.trim() ?? '')
                    .replaceAll('\n', ''),
                style: TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.start,
              ),
            ),
          ),
          controller: _epubReaderController!,
          onDocumentLoaded: (document) {
            print('isLoaded: $document');
          },
          dividerBuilder: (_) => Divider(),
        )
      : Center(
          child: Container(
              height: 50.0,
              margin: const EdgeInsets.only(left: 10.0, right: 10.0),
              child: const Center(
                  child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                    Color.fromRGBO(88, 165, 196, 1)),
              ))),
        );

  void _showCurrentEpubCfi(context) {
    final cfi = _epubReaderController!.generateEpubCfi();

    if (cfi != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(cfi),
          action: SnackBarAction(
            label: 'GO',
            onPressed: () {
              _epubReaderController!.gotoEpubCfi(cfi);
            },
          ),
        ),
      );
    }
  }
}
