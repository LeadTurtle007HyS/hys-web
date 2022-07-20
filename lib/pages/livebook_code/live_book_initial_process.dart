import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'dart:html' as webFile;
import '../../constants/style.dart';

class InitialLiveBook extends StatefulWidget {
  const InitialLiveBook({Key? key}) : super(key: key);

  @override
  State<InitialLiveBook> createState() => _InitialLiveBookState();
}

class _InitialLiveBookState extends State<InitialLiveBook> {
  List<String> subjects = [
    'MATHEMATICS',
    'SCIENCE',
    'CHEMISTRY',
    'PHYSICS',
    'BIOLOGY',
    'GEOGRAPHY',
    'HISTORY',
    'ENGLISH',
    'COMPUTER SCIENCE',
    'ACCOUNTANCY',
    'BUSINESS STUDIES'
  ];
  int step = 1;
  @override
  Widget build(BuildContext context) {
    return Container(
        width: 500,
        child: ListView(
          shrinkWrap: true,
          children: [
            const SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                      onPressed: () {
                        setState(() {
                          if (step != 1) {
                            step--;
                          }
                        });
                      },
                      icon: const Icon(Icons.arrow_back_ios)),
                  const Text("Class 11th",
                      style: TextStyle(
                          fontFamily: 'Nunito Sans',
                          fontSize: 25.0,
                          color: Color.fromRGBO(0, 0, 0, 0.8),
                          fontWeight: FontWeight.bold)),
                  const SizedBox(width: 40, height: 40)
                ],
              ),
            ),
            const SizedBox(
              height: 40,
            ),
            step == 1
                ? _subjects()
                : step == 2
                    ? _publications()
                    : selectChapter(
                        "NCERT", "MATHEMATICS", "11", "NCERT MATHEMATICS01")
          ],
        ));
  }

  Widget _subjects() {
    return SizedBox(
      width: 500,
      child: GridView.count(
          shrinkWrap: true,
          childAspectRatio: 1,
          crossAxisCount: 4,
          padding: const EdgeInsets.all(15),
          children: List.generate(subjects.length, (index) {
            return InkWell(
                onTap: () {},
                child: Container(
                  margin: const EdgeInsets.all(10),
                  child: _book(subjects[index], "11"),
                ));
          })),
    );
  }

  Widget _book(String subject, String grade) {
    return Row(
      children: [
        InkWell(
          onTap: () {
            setState(() {
              step = 2;
            });
          },
          child: Stack(
            children: [
              CachedNetworkImage(
                imageUrl:
                    "https://firebasestorage.googleapis.com/v0/b/hys-pro-41c66.appspot.com/o/assets%2FBlue%20and%20Black%20Minimalist%20Big%20Secret%20of%20Education%20Book%20Cover.png?alt=media&token=f2f9a697-c047-4b08-9cc8-abeb2d068d6f",
                width: 150,
                height: 230,
                fit: BoxFit.fill,
                placeholder: (context, url) => Container(
                    width: 40,
                    height: 40,
                    color: Colors.white,
                    child: Image.network(
                      "https://firebasestorage.googleapis.com/v0/b/hys-pro-41c66.appspot.com/o/assets%2Floadingimg.gif?alt=media&token=4ca910f2-c584-4b3a-bbcb-2f1c01d93f67",
                    )),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
              Positioned(
                top: 7,
                child: SizedBox(
                  width: 140,
                  child: Column(
                    children: [
                      Container(
                          width: 140,
                          margin: const EdgeInsets.only(left: 4, bottom: 2),
                          child: Text("Class ${grade}th",
                              style: const TextStyle(
                                  color: Colors.black54,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600))),
                      Container(
                          width: 140,
                          margin: const EdgeInsets.only(left: 4, bottom: 2),
                          child: Text(subject,
                              style: const TextStyle(
                                  color: Color.fromRGBO(0, 0, 0, 0.7),
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold))),
                      Container(
                          width: 140,
                          margin: const EdgeInsets.only(left: 4, bottom: 2),
                          child: const Text("- HyS",
                              style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600))),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _publications() {
    return SizedBox(
      width: 500,
      child: Column(
        children: [
          GridView.count(
              shrinkWrap: true,
              childAspectRatio: 2,
              crossAxisCount: 2,
              padding: const EdgeInsets.all(15),
              children: List.generate(2, (index) {
                return InkWell(
                    onTap: () {
                      setState(() {
                        step = 3;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.all(10),
                      child: _bookPublication("NCERT", "MATHEMATICS", "11",
                          "NCERT MATHEMATICS0$index"),
                    ));
              })),
          SizedBox(
            width: 500,
            child: publicationOptions(),
          ),
          SizedBox(height: 50)
        ],
      ),
    );
  }

  Widget _bookPublication(
      String publication, String subject, String grade, String pub_id) {
    return Row(
      children: [
        Stack(
          children: [
            CachedNetworkImage(
              imageUrl:
                  "https://firebasestorage.googleapis.com/v0/b/hys-pro-41c66.appspot.com/o/assets%2Fbanner1.png?alt=media&token=ccaa6396-ee5c-4ce3-9978-6b708e3d8795",
              width: 300,
              height: 150,
              fit: BoxFit.fill,
              placeholder: (context, url) => Container(
                  width: 40,
                  height: 40,
                  color: Colors.white,
                  child: Image.network(
                    "https://firebasestorage.googleapis.com/v0/b/hys-pro-41c66.appspot.com/o/assets%2Floadingimg.gif?alt=media&token=4ca910f2-c584-4b3a-bbcb-2f1c01d93f67",
                  )),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
            Positioned(
              top: 20,
              left: 120,
              child: SizedBox(
                width: 200,
                child: Column(
                  children: [
                    Container(
                        width: 210,
                        margin: const EdgeInsets.only(left: 4, bottom: 2),
                        child: Text("NCERT Class ${grade}th",
                            style: const TextStyle(
                                color: Colors.black54,
                                fontSize: 12,
                                fontWeight: FontWeight.w600))),
                    Container(
                        width: 210,
                        margin: const EdgeInsets.only(left: 4, bottom: 2),
                        child: Text(subject,
                            style: const TextStyle(
                                color: Color.fromRGBO(0, 0, 0, 0.7),
                                fontSize: 18,
                                fontWeight: FontWeight.bold))),
                    Container(
                        width: 210,
                        margin: const EdgeInsets.only(left: 4, bottom: 2),
                        child: const Text("Book",
                            style: TextStyle(
                                color: Colors.black54,
                                fontSize: 12,
                                fontWeight: FontWeight.w600))),
                    Container(
                        width: 210,
                        margin: const EdgeInsets.only(left: 4, bottom: 2),
                        child: Text(pub_id,
                            style: const TextStyle(
                                color: Color.fromRGBO(0, 0, 0, 0.7),
                                fontSize: 10,
                                fontWeight: FontWeight.bold))),
                  ],
                ),
              ),
            )
          ],
        ),
      ],
    );
  }

  Widget publicationOptions() {
    return Container(
        child: Column(
      children: [
        InkWell(
          onTap: () {},
          child: Container(
              margin: EdgeInsets.all(8),
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                  color: active, borderRadius: BorderRadius.circular(10)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Past year question papers",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Icon(Icons.arrow_circle_right)
                ],
              )),
        ),
        InkWell(
          onTap: () {},
          child: Container(
              margin: EdgeInsets.all(8),
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                  color: active, borderRadius: BorderRadius.circular(10)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Books/chapters referred by your friend's recently",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Icon(Icons.arrow_circle_right)
                ],
              )),
        ),
        InkWell(
          onTap: () {},
          child: Container(
              margin: EdgeInsets.all(8),
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                  color: active, borderRadius: BorderRadius.circular(10)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Most rated books/chapters",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Icon(Icons.arrow_circle_right)
                ],
              )),
        ),
        InkWell(
          onTap: () {},
          child: Container(
              margin: EdgeInsets.all(8),
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                  color: active, borderRadius: BorderRadius.circular(10)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Most rated books",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Icon(Icons.arrow_circle_right)
                ],
              )),
        ),
      ],
    ));
  }

  Widget selectChapter(
      String publication, String subject, String grade, String pub_id) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              children: [
                CachedNetworkImage(
                  imageUrl:
                      "https://firebasestorage.googleapis.com/v0/b/hys-pro-41c66.appspot.com/o/assets%2Fbanner1.png?alt=media&token=ccaa6396-ee5c-4ce3-9978-6b708e3d8795",
                  width: 500,
                  height: 250,
                  fit: BoxFit.fill,
                  placeholder: (context, url) => Container(
                      width: 40,
                      height: 40,
                      color: Colors.white,
                      child: Image.network(
                        "https://firebasestorage.googleapis.com/v0/b/hys-pro-41c66.appspot.com/o/assets%2Floadingimg.gif?alt=media&token=4ca910f2-c584-4b3a-bbcb-2f1c01d93f67",
                      )),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
                Positioned(
                  top: 50,
                  left: 200,
                  child: SizedBox(
                    width: 200,
                    child: Column(
                      children: [
                        Container(
                            width: 210,
                            margin: const EdgeInsets.only(left: 4, bottom: 2),
                            child: Text("NCERT Class ${grade}th",
                                style: const TextStyle(
                                    color: Colors.black54,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600))),
                        Container(
                            width: 210,
                            margin: const EdgeInsets.only(left: 4, bottom: 2),
                            child: Text(subject,
                                style: const TextStyle(
                                    color: Color.fromRGBO(0, 0, 0, 0.7),
                                    fontSize: 25,
                                    fontWeight: FontWeight.bold))),
                        Container(
                            width: 210,
                            margin: const EdgeInsets.only(left: 4, bottom: 2),
                            child: const Text("Book",
                                style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600))),
                        Container(
                            width: 210,
                            margin: const EdgeInsets.only(left: 4, bottom: 2),
                            child: Text(pub_id,
                                style: const TextStyle(
                                    color: Color.fromRGBO(0, 0, 0, 0.7),
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold))),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
        const SizedBox(
          height: 30,
        ),
        SizedBox(
          width: 500,
          child: ListView.builder(
              shrinkWrap: true,
              itemCount: 5,
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () {
                    webFile.window.open('http://localhost:54215/epub', 'ePub');
                  },
                  child: Container(
                      width: 500,
                      margin: const EdgeInsets.all(8),
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                          color: active,
                          borderRadius: BorderRadius.circular(10)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Chapter ${index + 1}",
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          const Icon(Icons.arrow_circle_right)
                        ],
                      )),
                );
              }),
        )
      ],
    );
  }
}
