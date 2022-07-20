import 'dart:convert';
import 'dart:io';
import 'dart:html' as webFile;
import 'dart:typed_data';
import 'package:collection/collection.dart' show IterableExtension;
import 'package:epubx/epubx.dart' hide Image;
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_menu/flutter_menu.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' show parse;
import 'package:rxdart/rxdart.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'epub_cfi/generator.dart';
import 'epub_cfi/interpreter.dart';
import 'epub_cfi/parser.dart';
export 'package:epubx/epubx.dart' hide Image;
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:url_launcher/url_launcher.dart';

import 'epub_crud.dart';
part 'epub_data.dart';
part 'epub_parser.dart';
part 'epub_controller.dart';
part 'epub_cfi_reader.dart';

const MIN_TRAILING_EDGE = 0.55;
const MIN_LEADING_EDGE = -0.05;

const _defaultTextStyle = TextStyle(
  height: 1.25,
  fontSize: 16,
);

int baseOffset = 0;
int extentOffset = 0;
int selected_index = -1;
String text_selected = "";

typedef ChaptersBuilder = Widget Function(
  BuildContext context,
  List<EpubChapter> chapters,
  List<Paragraph> paragraphs,
  int index,
);

typedef ExternalLinkPressed = void Function(String href);

class EpubView extends StatefulWidget {
  const EpubView({
    required this.controller,
    this.itemBuilder,
    required this.tittle,
    this.onExternalLinkPressed,
    this.loaderSwitchDuration,
    this.loader,
    this.errorBuilder,
    this.dividerBuilder,
    this.onChange,
    this.onDocumentLoaded,
    this.onDocumentError,
    this.chapterPadding = const EdgeInsets.all(8),
    this.paragraphPadding = const EdgeInsets.symmetric(horizontal: 16),
    this.textStyle = _defaultTextStyle,
    Key? key,
  }) : super(key: key);

  final EpubController controller;
  final ExternalLinkPressed? onExternalLinkPressed;

  /// Show document loading error message inside [EpubView]
  final Widget Function(Exception? error)? errorBuilder;
  final Widget Function(EpubChapter value)? dividerBuilder;
  final void Function(EpubChapterViewValue? value)? onChange;

  /// Called when a document is loaded
  final void Function(EpubBook? document)? onDocumentLoaded;

  /// Called when a document loading error
  final void Function(Exception? error)? onDocumentError;
  final Duration? loaderSwitchDuration;
  final Widget? loader;
  final EdgeInsetsGeometry chapterPadding;
  final EdgeInsetsGeometry paragraphPadding;
  final ChaptersBuilder? itemBuilder;
  final TextStyle textStyle;
  final Widget tittle;

  @override
  _EpubViewState createState() => _EpubViewState();
}

class _EpubViewState extends State<EpubView> {
  _EpubViewLoadingState _loadingState = _EpubViewLoadingState.loading;
  Exception? _loadingError;
  ItemScrollController? _itemScrollController;
  ItemPositionsListener? _itemPositionListener;
  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();
  List<EpubChapter> _chapters = [];
  List<Paragraph> _paragraphs = [];
  EpubCfiReader? _epubCfiReader;
  EpubChapterViewValue? _currentValue;
  bool _initialized = false;
  EpubCRUD epubCRUD = EpubCRUD();
  List allTaggedUsersData = [];
  List allSavedItem = [];
  List allSuggestionItem = [];
  List allSavedIndex = [];
  List highlightSavedItem = [];
  List examlikehoodSavedItem = [];
  List difficultySavedItem = [];
  List examlikehoodSavedItemHigh = [];
  List examlikehoodSavedItemModerate = [];
  List examlikehoodSavedItemLow = [];
  List difficultySavedItemHigh = [];
  List difficultySavedItemModerate = [];
  List difficultySavedItemLow = [];

  var dio = Dio();

  final GlobalKey<State> _keyLoader = new GlobalKey<State>();

  final List<int> _chapterIndexes = [];
  final BehaviorSubject<EpubChapterViewValue?> _actualChapter =
      BehaviorSubject();
  final BehaviorSubject<bool> _bookLoaded = BehaviorSubject();

  Future<void> _get_all_tagged_users() async {
    final http.Response response = await http.get(
      Uri.parse('https://hys-api.herokuapp.com/get_all_sm_usertagged'),
    );

    print("get_all_sm_usertagged: ${response.statusCode}");
    if ((response.statusCode == 200) || (response.statusCode == 201)) {
      setState(() {
        allTaggedUsersData = json.decode(response.body);
      });
    }
  }

  Future<void> _get_all_saved_text() async {
    final http.Response response = await http.get(
      Uri.parse(
          'https://hys-api.herokuapp.com/get_user_epub_selected_text/123'),
    );

    print("get_user_epub_selected_text: ${response.statusCode}");
    if ((response.statusCode == 200) || (response.statusCode == 201)) {
      setState(() {
        allSavedItem = [];
        allSavedIndex = [];
        highlightSavedItem = [];
        examlikehoodSavedItem = [];
        difficultySavedItem = [];
        examlikehoodSavedItemHigh = [];
        examlikehoodSavedItemModerate = [];
        examlikehoodSavedItemLow = [];
        difficultySavedItemHigh = [];
        difficultySavedItemModerate = [];
        difficultySavedItemLow = [];
        allSavedItem = json.decode(response.body);
        for (int i = 0; i < allSavedItem.length; i++) {
          allSavedIndex.add(allSavedItem[i]["tag_index"]);
          if (allSavedItem[i]["selection_type"] == "heighlight") {
            highlightSavedItem.add(allSavedItem[i]);
          } else if (allSavedItem[i]["selection_type"] == "examlikehood") {
            examlikehoodSavedItem.add(allSavedItem[i]);
            if (allSavedItem[i]["level_"] == "high") {
              examlikehoodSavedItemHigh.add(allSavedItem[i]);
            } else if (allSavedItem[i]["level_"] == "moderate") {
              examlikehoodSavedItemModerate.add(allSavedItem[i]);
            } else if (allSavedItem[i]["level_"] == "low") {
              examlikehoodSavedItemLow.add(allSavedItem[i]);
            }
          } else if (allSavedItem[i]["selection_type"] == "difficultylevel") {
            difficultySavedItem.add(allSavedItem[i]);
            if (allSavedItem[i]["level_"] == "high") {
              difficultySavedItemHigh.add(allSavedItem[i]);
            } else if (allSavedItem[i]["level_"] == "moderate") {
              difficultySavedItemModerate.add(allSavedItem[i]);
            } else if (allSavedItem[i]["level_"] == "low") {
              difficultySavedItemLow.add(allSavedItem[i]);
            }
          }
        }
      });
    }
  }

  Future<void> _get_all_suggestion_text() async {
    final http.Response response = await http.post(
      Uri.parse('https://hys.today/predict'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        "Access-Control-Allow-Origin": "https://hys.today",
        "Access-Control-Allow-Methods":
            "GET, POST, PUT, PATCH, DELETE, OPTIONS, HEAD",
        "Access-Control-Allow-Headers": "Origin, Content-Type"
      },
      body: jsonEncode(<String, dynamic>{
        "grade": "12",
        "subject": "physics",
        "publication": "ncert",
        "publication_edition": "01",
        "chapter": "chapter_5",
        "part": "01",
        "query":
            "Drugs usually interact with biomolecules such as carbohydrates, lipids, proteins and nucleic acids. These are called target molecules or drug targets. Drugs possessing some common structural features may have the same mechanism of action on targets. The classification based on molecular targets is the most useful classification for medicinal chemists."
      }),
    );

    print("get_user_epub_selected_text: ${response.statusCode}");
    if ((response.statusCode == 200) || (response.statusCode == 201)) {
      setState(() {
        allSuggestionItem = [];
        allSuggestionItem = json.decode(response.body);
        print(allSuggestionItem);
      });
    }
  }

  @override
  void initState() {
    _get_all_saved_text();
    _get_all_tagged_users();
    _get_all_suggestion_text();
    _itemScrollController = ItemScrollController();
    _itemPositionListener = ItemPositionsListener.create();
    // document.onContextMenu.listen((event) => event.preventDefault());
    widget.controller._attach(this);
    super.initState();
  }

  @override
  void dispose() {
    _itemPositionListener!.itemPositions.removeListener(_changeListener);
    _actualChapter.close();
    _bookLoaded.close();
    widget.controller._detach();
    super.dispose();
  }

  Future<bool> _init() async {
    if (_initialized) {
      return true;
    }
    _chapters = parseChapters(widget.controller._document!);
    final parseParagraphsResult =
        parseParagraphs(_chapters, widget.controller._document!.Content);
    _paragraphs = parseParagraphsResult.flatParagraphs;
    _chapterIndexes.addAll(parseParagraphsResult.chapterIndexes);

    _epubCfiReader = EpubCfiReader.parser(
      cfiInput: widget.controller.epubCfi,
      chapters: _chapters,
      paragraphs: _paragraphs,
    );
    _itemPositionListener!.itemPositions.addListener(_changeListener);
    _initialized = true;
    _bookLoaded.sink.add(true);

    return true;
  }

  void _changeListener() {
    if (_paragraphs.isEmpty ||
        _itemPositionListener!.itemPositions.value.isEmpty) {
      return;
    }
    final position = _itemPositionListener!.itemPositions.value.first;
    final chapterIndex = _getChapterIndexBy(
      positionIndex: position.index,
      trailingEdge: position.itemTrailingEdge,
      leadingEdge: position.itemLeadingEdge,
    );
    final paragraphIndex = _getParagraphIndexBy(
      positionIndex: position.index,
      trailingEdge: position.itemTrailingEdge,
      leadingEdge: position.itemLeadingEdge,
    );
    _currentValue = EpubChapterViewValue(
      chapter: chapterIndex >= 0 ? _chapters[chapterIndex] : null,
      chapterNumber: chapterIndex + 1,
      paragraphNumber: paragraphIndex + 1,
      position: position,
    );
    _actualChapter.sink.add(_currentValue);
    widget.onChange?.call(_currentValue);
  }

  void _gotoEpubCfi(
    String? epubCfi, {
    double alignment = 0,
    Duration duration = const Duration(milliseconds: 250),
    Curve curve = Curves.linear,
  }) {
    _epubCfiReader?.epubCfi = epubCfi;
    final index = _epubCfiReader?.paragraphIndexByCfiFragment;

    if (index == null) {
      return null;
    }

    _itemScrollController?.scrollTo(
      index: index,
      duration: duration,
      alignment: alignment,
      curve: curve,
    );
  }

  void _onLinkPressed(String href, void Function(String href)? openExternal) {
    if (href.contains('://')) {
      openExternal?.call(href);
      return;
    }

    // Chapter01.xhtml#ph1_1 -> [ph1_1, Chapter01.xhtml] || [ph1_1]
    String? hrefIdRef;
    String? hrefFileName;

    if (href.contains('#')) {
      final dividedHref = href.split('#');
      if (dividedHref.length == 1) {
        hrefIdRef = href;
      } else {
        hrefFileName = dividedHref[0];
        hrefIdRef = dividedHref[1];
      }
    } else {
      hrefFileName = href;
    }

    if (hrefIdRef == null) {
      final chapter = _chapterByFileName(hrefFileName);
      if (chapter != null) {
        final cfi = _epubCfiReader?.generateCfiChapter(
          book: widget.controller._document,
          chapter: chapter,
          additional: ['/4/2'],
        );

        _gotoEpubCfi(cfi);
      }
      return;
    } else {
      final paragraph = _paragraphByIdRef(hrefIdRef);
      final chapter =
          paragraph != null ? _chapters[paragraph.chapterIndex] : null;
      if (chapter != null && paragraph != null) {
        final paragraphIndex =
            _epubCfiReader?._getParagraphIndexByElement(paragraph.element);
        final cfi = _epubCfiReader?.generateCfi(
          book: widget.controller._document,
          chapter: chapter,
          paragraphIndex: paragraphIndex,
        );

        _gotoEpubCfi(cfi);
      }

      return;
    }
  }

  Paragraph? _paragraphByIdRef(String idRef) =>
      _paragraphs.firstWhereOrNull((paragraph) {
        if (paragraph.element.id == idRef) {
          return true;
        }

        return paragraph.element.children.isNotEmpty &&
            paragraph.element.children[0].id == idRef;
      });

  EpubChapter? _chapterByFileName(String? fileName) =>
      _chapters.firstWhereOrNull((chapter) {
        if (fileName != null) {
          if (chapter.ContentFileName!.contains(fileName)) {
            return true;
          } else {
            return false;
          }
        }
        return false;
      });

  int _getChapterIndexBy({
    required int positionIndex,
    double? trailingEdge,
    double? leadingEdge,
  }) {
    final posIndex = _getAbsParagraphIndexBy(
      positionIndex: positionIndex,
      trailingEdge: trailingEdge,
      leadingEdge: leadingEdge,
    );
    final index = posIndex >= _chapterIndexes.last
        ? _chapterIndexes.length
        : _chapterIndexes.indexWhere((chapterIndex) {
            if (posIndex < chapterIndex) {
              return true;
            }
            return false;
          });

    return index - 1;
  }

  int _getParagraphIndexBy({
    required int positionIndex,
    double? trailingEdge,
    double? leadingEdge,
  }) {
    final posIndex = _getAbsParagraphIndexBy(
      positionIndex: positionIndex,
      trailingEdge: trailingEdge,
      leadingEdge: leadingEdge,
    );

    final index = _getChapterIndexBy(positionIndex: posIndex);

    if (index == -1) {
      return posIndex;
    }

    return posIndex - _chapterIndexes[index];
  }

  int _getAbsParagraphIndexBy({
    required int positionIndex,
    double? trailingEdge,
    double? leadingEdge,
  }) {
    int posIndex = positionIndex;
    if (trailingEdge != null &&
        leadingEdge != null &&
        trailingEdge < MIN_TRAILING_EDGE &&
        leadingEdge < MIN_LEADING_EDGE) {
      posIndex += 1;
    }

    return posIndex;
  }

  void _changeLoadingState(_EpubViewLoadingState state) {
    if (state == _EpubViewLoadingState.success) {
      widget.onDocumentLoaded?.call(widget.controller._document);
    } else if (state == _EpubViewLoadingState.error) {
      widget.onDocumentError?.call(_loadingError);
    }
    setState(() {
      _loadingState = state;
    });
  }

  Widget _buildDivider(EpubChapter chapter) =>
      widget.dividerBuilder?.call(chapter) ??
      Container(
        height: 56,
        width: double.infinity,
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Color(0x24000000),
        ),
        alignment: Alignment.centerLeft,
        child: Text(
          chapter.Title ?? '',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
      );

  Widget _defaultItemBuilder(int index) {
    bool check = allSavedIndex.contains(index);
    int itemIndex = allSavedItem.indexWhere((element) {
      if (element["tag_index"] == index) {
        print(element["tag_index"]);
        return true;
      } else {
        return false;
      }
    });

    if (_paragraphs.isEmpty) {
      return Container();
    }

    final chapterIndex = _getChapterIndexBy(positionIndex: index);

    final htmlbody = _paragraphs[index].element.outerHtml;

    return Container(
      color: Colors.white,
      child: Column(
        children: <Widget>[
          if (chapterIndex >= 0 &&
              _getParagraphIndexBy(positionIndex: index) == 0)
            _buildDivider(_chapters[chapterIndex]),
          Html(
            data: _paragraphs[index].element.outerHtml,
            onLinkTap: (href, _, __, ___) =>
                _onLinkPressed(href!, widget.onExternalLinkPressed),
            style: {
              'html': Style(
                padding: widget.paragraphPadding as EdgeInsets?,
                backgroundColor: Colors.white,
              ).merge(Style.fromTextStyle(widget.textStyle)),
              'h1': Style(
                  color: Colors.black,
                  fontSize: FontSize.xxLarge,
                  fontWeight: FontWeight.w800),
              'h2': Style(
                  color: Colors.black,
                  fontSize: FontSize.xxLarge,
                  fontWeight: FontWeight.w700),
              'h3': Style(
                  color: Colors.black,
                  fontSize: FontSize.xLarge,
                  fontWeight: FontWeight.w700),
              'p': Style(
                  color: Colors.black,
                  fontSize: FontSize.large,
                  fontWeight: FontWeight.w700),
              'div': Style(
                  color: Colors.black,
                  fontSize: FontSize.large,
                  fontWeight: FontWeight.w700),
            },
            customRenders: {
              tagMatcher('img'): CustomRender.widget(widget: (context, child) {
                final url = context.tree.element!.attributes['src']!
                    .replaceAll('../', '');
                return Image(
                  image: MemoryImage(
                    Uint8List.fromList(widget
                        .controller._document!.Content!.Images![url]!.Content!),
                  ),
                );
              }),
              // ignore: prefer_expression_function_bodies
              tagMatcher('p'): CustomRender.widget(widget: (context, child) {
                return SelectableText(context.tree.element!.text,
                    onSelectionChanged: (selection, cause) {
                  baseOffset = selection.baseOffset;
                  extentOffset = selection.extentOffset;
                  selected_index = index;
                  print("baseOffset: $baseOffset");
                  print("extentOffset: $extentOffset");
                  print("index: $index");
                  text_selected = baseOffset < extentOffset
                      ? (context.tree.element!.text)
                          .substring(baseOffset, extentOffset)
                      : (context.tree.element!.text)
                          .substring(extentOffset, baseOffset);
                }, onTap: () {
                  if (check) {
                    if (itemIndex != -1) {
                      if (allSavedItem[itemIndex]["selection_type"] ==
                          "heighlight") {
                        int indexToScroll =
                            highlightSavedItem.indexWhere((element) {
                          if (element["tag_index"] == index) {
                            print(element["tag_index"]);
                            return true;
                          } else {
                            return false;
                          }
                        });
                        _mySavedDialogBox(0, 0, 0);
                      } else if (allSavedItem[itemIndex]["selection_type"] ==
                          "examlikehood") {
                        int indexToScroll =
                            examlikehoodSavedItem.indexWhere((element) {
                          if (element["tag_index"] == index) {
                            print(element["tag_index"]);
                            return true;
                          } else {
                            return false;
                          }
                        });
                        _mySavedDialogBox(0, 0, 0);
                      } else if (allSavedItem[itemIndex]["selection_type"] ==
                          "difficultylevel") {
                        int indexToScroll =
                            difficultySavedItem.indexWhere((element) {
                          if (element["tag_index"] == index) {
                            print(element["tag_index"]);
                            return true;
                          } else {
                            return false;
                          }
                        });
                        _mySavedDialogBox(0, 0, 0);
                      }
                    }
                  }
                },
                    style: TextStyle(
                        backgroundColor: itemIndex != -1
                            ? allSavedItem[itemIndex]['selection_type'] ==
                                    "heighlight"
                                ? (allSavedItem[itemIndex]['color'] ==
                                        "blueAccent"
                                    ? Colors.blueAccent
                                    : allSavedItem[itemIndex]['color'] ==
                                            "greenAccent"
                                        ? Colors.greenAccent
                                        : Colors.pinkAccent)
                                : allSavedItem[itemIndex]['selection_type'] ==
                                        "examlikehood"
                                    ? allSavedItem[itemIndex]['level_'] == "low"
                                        ? Color.fromRGBO(255, 133, 102, 1)
                                        : allSavedItem[itemIndex]['level_'] ==
                                                "moderate"
                                            ? Color.fromRGBO(255, 77, 77, 1)
                                            : Color.fromRGBO(230, 0, 0, 1)
                                    : allSavedItem[itemIndex]
                                                ['selection_type'] ==
                                            "difficultylevel"
                                        ? allSavedItem[itemIndex]['level_'] ==
                                                "low"
                                            ? Color.fromRGBO(128, 255, 128, 1)
                                            : allSavedItem[itemIndex]
                                                        ['level_'] ==
                                                    "moderate"
                                                ? Color.fromRGBO(0, 255, 85, 1)
                                                : Color.fromRGBO(0, 153, 51, 1)
                                        : Colors.transparent
                            : Colors.transparent,
                        color: Colors.black,
                        fontWeight: FontWeight.normal,
                        fontSize: 15),
                    textAlign: TextAlign.left,
                    toolbarOptions:
                        ToolbarOptions(copy: true, selectAll: false),
                    showCursor: true);
              })
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLoaded() {
    Widget _buildItem(BuildContext context, int index) =>
        widget.itemBuilder?.call(context, _chapters, _paragraphs, index) ??
        _defaultItemBuilder(index);
    return Container(
      width: 800,
      child: ScrollablePositionedList.builder(
        shrinkWrap: true,
        initialScrollIndex: _epubCfiReader!.paragraphIndexByCfiFragment ?? 0,
        itemCount: _paragraphs.length,
        itemScrollController: _itemScrollController,
        itemPositionsListener: _itemPositionListener,
        itemBuilder: _buildItem,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScreen(
      leading: Container(
        child: Row(
          children: [widget.tittle],
        ),
      ),
      masterContextMenu: ContextMenu(
        width: 250,
        height: 260,
        child: ContextMenuSliver(
          title: 'Live books',
          titleStyle: TextStyle(
              color: Colors.black, fontSize: 17, fontWeight: FontWeight.bold),
          titleBackgroundColor: Colors.white,
          widgetBackgroundColor: Colors.white,
          children: [
            masterContextMenuItem(value: 'Exam Like Hood'),
            masterContextMenuItem(value: 'Difficulty Level'),
            masterContextMenuItem(value: 'Suggestion list'),
            masterContextMenuItemForSelection(),
          ],
        ),
      ),
      masterPane: masterPane(),
      detailPaneMinWidth: 0,
      detailPaneFlex: 0,
      menuList: [],
    );
  }

  Builder masterPane() {
    Widget? content;

    switch (_loadingState) {
      case _EpubViewLoadingState.loading:
        content = KeyedSubtree(
          key: Key('$runtimeType.root.loading'),
          child: widget.loader ?? SizedBox(),
        );
        break;
      case _EpubViewLoadingState.error:
        content = KeyedSubtree(
          key: Key('$runtimeType.root.error'),
          child: Padding(
            padding: EdgeInsets.all(32),
            child: widget.errorBuilder?.call(_loadingError) ??
                Center(child: Text(_loadingError.toString())),
          ),
        );
        break;
      case _EpubViewLoadingState.success:
        content = KeyedSubtree(
          key: Key('$runtimeType.root.success'),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildLoaded(),
          ),
        );
        break;
    }

    print('BUILD: masterPane');
    return Builder(
      builder: (BuildContext context) {
        return AnimatedSwitcher(
          duration: widget.loaderSwitchDuration ?? Duration(milliseconds: 500),
          transitionBuilder: (child, animation) =>
              FadeTransition(opacity: animation, child: child),
          child: content,
        );
      },
    );
  }

  Widget masterContextMenuItem({required String value}) {
    print(value);
    return ContextMenuItem(
      child: InkWell(
        onTap: () {
          print(value);
          if (value == "Exam Like Hood") {
            _showExamlikelihoodDialog();
          } else if (value == "Difficulty Level") {
            _dificultyLevelDialog();
          } else if (value == "Suggestion list") {
            _mySavedDialogBox(3, 0, 0);
          }
        },
        child: Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: Colors.white, border: Border.all(color: Colors.black12)),
          child: Center(
              child: Text(value,
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.black54))),
        ),
      ),
    );
  }

  Widget masterContextMenuItemForSelection() {
    return ContextMenuItem(
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(border: Border.all(color: Colors.black12)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            InkWell(
              onTap: () async {
                if (selected_index != -1) {
                  bool check = await epubCRUD.addUserTextSelectionDetails([
                    '',
                    '',
                    '123',
                    baseOffset,
                    extentOffset,
                    selected_index,
                    'greenAccent',
                    "heighlight",
                    '',
                    text_selected
                  ]);
                  if (check) {
                    _get_all_saved_text();
                  }
                }
              },
              child: CircleAvatar(
                backgroundColor: Colors.greenAccent,
                radius: 12,
              ),
            ),
            InkWell(
              onTap: () async {
                if (selected_index != -1) {
                  bool check = await epubCRUD.addUserTextSelectionDetails([
                    '',
                    '',
                    '123',
                    baseOffset,
                    extentOffset,
                    selected_index,
                    'blueAccent',
                    "heighlight",
                    '',
                    text_selected
                  ]);
                  if (check) {
                    _get_all_saved_text();
                  }
                }
              },
              child: CircleAvatar(
                backgroundColor: Colors.blueAccent,
                radius: 12,
              ),
            ),
            InkWell(
              onTap: () async {
                if (selected_index != -1) {
                  bool check = await epubCRUD.addUserTextSelectionDetails([
                    '',
                    '',
                    '123',
                    baseOffset,
                    extentOffset,
                    selected_index,
                    'pinkAccent',
                    "heighlight",
                    '',
                    text_selected
                  ]);
                  if (check) {
                    _get_all_saved_text();
                  }
                }
              },
              child: CircleAvatar(
                backgroundColor: Colors.pinkAccent,
                radius: 12,
              ),
            ),
            InkWell(
              onTap: () async {
                if (selected_index != -1) {
                  bool check = await epubCRUD.addUserTextSelectionDetails([
                    '',
                    '',
                    '123',
                    baseOffset,
                    extentOffset,
                    selected_index,
                    'transperent',
                    "heighlight",
                    '',
                    text_selected
                  ]);
                  if (check) {
                    _get_all_saved_text();
                  }
                }
              },
              child: CircleAvatar(
                backgroundColor: Colors.transparent,
                child: Icon(Icons.cancel_outlined, color: Colors.black45),
                radius: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showExamlikelihoodDialog() {
    showDialog(
        context: context,
        barrierColor: Colors.grey.withOpacity(0.2),
        builder: (_) => StatefulBuilder(builder: (context, setState) {
              return AlertDialog(
                backgroundColor: Color(0xFFFFFFFF),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0)),
                content: Container(
                  height: 100,
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 15,
                      ),
                      Text(
                        "Exam Like Hood",
                        style: TextStyle(
                          fontFamily: 'Nunito Sans',
                          fontSize: 17,
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Container(
                        width: 250,
                        height: 35,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(color: Colors.black12)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            InkWell(
                              onTap: () async {
                                bool check =
                                    await epubCRUD.addUserTextSelectionDetails([
                                  '',
                                  '',
                                  '123',
                                  baseOffset,
                                  extentOffset,
                                  selected_index,
                                  'red',
                                  "examlikehood",
                                  'high',
                                  text_selected
                                ]);
                                if (check) {
                                  _get_all_saved_text();
                                  Navigator.of(context).pop();
                                }
                              },
                              child: Container(
                                padding: EdgeInsets.all(5),
                                child: Center(
                                  child: Text(
                                    "High",
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xff0C2551)),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () async {
                                bool check =
                                    await epubCRUD.addUserTextSelectionDetails([
                                  '',
                                  '',
                                  '123',
                                  baseOffset,
                                  extentOffset,
                                  selected_index,
                                  'redAccent',
                                  "examlikehood",
                                  'moderate',
                                  text_selected
                                ]);
                                if (check) {
                                  _get_all_saved_text();
                                  Navigator.of(context).pop();
                                }
                              },
                              child: Container(
                                padding: EdgeInsets.all(5),
                                child: Center(
                                  child: Text(
                                    "Moderate",
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xff0C2551)),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () async {
                                bool check =
                                    await epubCRUD.addUserTextSelectionDetails([
                                  '',
                                  '',
                                  '123',
                                  baseOffset,
                                  extentOffset,
                                  selected_index,
                                  'redAccent1',
                                  "examlikehood",
                                  'low',
                                  text_selected
                                ]);
                                if (check) {
                                  _get_all_saved_text();
                                  Navigator.of(context).pop();
                                }
                              },
                              child: Container(
                                padding: EdgeInsets.all(5),
                                child: Center(
                                  child: Text(
                                    "Low",
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xff0C2551)),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }));
  }

  void _dificultyLevelDialog() {
    showDialog(
        context: context,
        barrierColor: Colors.grey.withOpacity(0.2),
        builder: (_) => StatefulBuilder(builder: (context, setState) {
              return AlertDialog(
                backgroundColor: Color(0xFFFFFFFF),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0)),
                content: Container(
                  height: 100,
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 15,
                      ),
                      Text(
                        "Difficulty Level",
                        style: TextStyle(
                          fontFamily: 'Nunito Sans',
                          fontSize: 17,
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Container(
                        width: 250,
                        height: 35,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(color: Colors.black12)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            InkWell(
                              onTap: () async {
                                bool check =
                                    await epubCRUD.addUserTextSelectionDetails([
                                  '',
                                  '',
                                  '123',
                                  baseOffset,
                                  extentOffset,
                                  selected_index,
                                  'red',
                                  "difficultylevel",
                                  'high',
                                  text_selected
                                ]);
                                if (check) {
                                  _get_all_saved_text();
                                  Navigator.of(context).pop();
                                }
                              },
                              child: Container(
                                padding: EdgeInsets.all(5),
                                child: Center(
                                  child: Text(
                                    "High",
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xff0C2551)),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () async {
                                bool check =
                                    await epubCRUD.addUserTextSelectionDetails([
                                  '',
                                  '',
                                  '123',
                                  baseOffset,
                                  extentOffset,
                                  selected_index,
                                  'red',
                                  "difficultylevel",
                                  'moderate',
                                  text_selected
                                ]);
                                if (check) {
                                  _get_all_saved_text();
                                  Navigator.of(context).pop();
                                }
                              },
                              child: Container(
                                padding: EdgeInsets.all(5),
                                child: Center(
                                  child: Text(
                                    "Moderate",
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xff0C2551)),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () async {
                                bool check =
                                    await epubCRUD.addUserTextSelectionDetails([
                                  '',
                                  '',
                                  '123',
                                  baseOffset,
                                  extentOffset,
                                  selected_index,
                                  'red',
                                  "difficultylevel",
                                  'low',
                                  text_selected
                                ]);
                                if (check) {
                                  _get_all_saved_text();
                                  Navigator.of(context).pop();
                                }
                              },
                              child: Container(
                                padding: EdgeInsets.all(5),
                                child: Center(
                                  child: Text(
                                    "Low",
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xff0C2551)),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }));
  }

  Future<void> _launchInBrowser(String url) async {
    if (await canLaunch(url)) {
      await launch(
        url,
        forceSafariVC: false,
        forceWebView: false,
      );
    } else {
      throw 'Could not launch $url';
    }
  }

  int mainSlideIndex = 0;
  int innerSlideIndex = 0;
  void _mySavedDialogBox(int mainIndex, int innerIndex, int indexToScroll) {
    List item = [];
    mainSlideIndex = mainIndex;
    innerSlideIndex = innerIndex;
    showDialog(
        context: context,
        barrierColor: Colors.grey.withOpacity(0.2),
        barrierDismissible: false,
        builder: (_) => StatefulBuilder(builder: (context, setState) {
              if (mainSlideIndex == 0) {
                item = highlightSavedItem;
              } else if (mainSlideIndex == 1 && innerSlideIndex == 0) {
                item = examlikehoodSavedItem;
              } else if (mainSlideIndex == 1 && innerSlideIndex == 1) {
                item = examlikehoodSavedItemLow;
              } else if (mainSlideIndex == 1 && innerSlideIndex == 2) {
                item = examlikehoodSavedItemModerate;
              } else if (mainSlideIndex == 1 && innerSlideIndex == 3) {
                item = examlikehoodSavedItemHigh;
              } else if (mainSlideIndex == 2 && innerSlideIndex == 0) {
                item = difficultySavedItem;
              } else if (mainSlideIndex == 2 && innerSlideIndex == 1) {
                item = difficultySavedItemLow;
              } else if (mainSlideIndex == 2 && innerSlideIndex == 2) {
                item = difficultySavedItemModerate;
              } else if (mainSlideIndex == 2 && innerSlideIndex == 3) {
                item = difficultySavedItemHigh;
              }
              return AlertDialog(
                contentPadding: EdgeInsets.all(20),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0)),
                title: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(width: 30),
                        Text(
                          "",
                          style: TextStyle(
                            fontSize: 20,
                            color: Color(0xCB000000),
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          icon: Tab(
                              child: Icon(Icons.cancel_rounded,
                                  color: Colors.black45, size: 25)),
                        )
                      ],
                    ),
                    SizedBox(height: 20),
                    Container(height: 1, width: 500, color: Colors.grey[200]),
                  ],
                ),
                content: Container(
                  height: 470,
                  width: 500,
                  padding: EdgeInsets.all(8),
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      mainSlideIndex != 3
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      mainSlideIndex = 0;
                                      innerSlideIndex = 0;
                                    });
                                  },
                                  child: Container(
                                    color: mainSlideIndex == 0
                                        ? Colors.blueAccent
                                        : Colors.transparent,
                                    padding: EdgeInsets.all(8),
                                    child: Text("Highlight",
                                        style: TextStyle(
                                            fontSize: 17,
                                            letterSpacing: 0.3,
                                            fontWeight: FontWeight.w600,
                                            color: mainSlideIndex == 0
                                                ? Colors.white
                                                : Colors.black)),
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      mainSlideIndex = 1;
                                      innerSlideIndex = 0;
                                    });
                                  },
                                  child: Container(
                                    color: mainSlideIndex == 1
                                        ? Colors.blueAccent
                                        : Colors.transparent,
                                    padding: EdgeInsets.all(8),
                                    child: Text("Exam like hood",
                                        style: TextStyle(
                                            fontSize: 17,
                                            letterSpacing: 0.3,
                                            fontWeight: FontWeight.w600,
                                            color: mainSlideIndex == 1
                                                ? Colors.white
                                                : Colors.black)),
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      mainSlideIndex = 2;
                                      innerSlideIndex = 0;
                                    });
                                  },
                                  child: Container(
                                    color: mainSlideIndex == 2
                                        ? Colors.blueAccent
                                        : Colors.transparent,
                                    padding: EdgeInsets.all(8),
                                    child: Text("Difficulty level",
                                        style: TextStyle(
                                            fontSize: 17,
                                            letterSpacing: 0.3,
                                            fontWeight: FontWeight.w600,
                                            color: mainSlideIndex == 2
                                                ? Colors.white
                                                : Colors.black)),
                                  ),
                                ),
                              ],
                            )
                          : Container(
                              color: Colors.blueAccent,
                              padding: EdgeInsets.all(8),
                              child: Text("Related books",
                                  style: TextStyle(
                                      fontSize: 17,
                                      letterSpacing: 0.3,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white)),
                            ),
                      SizedBox(height: 10),
                      mainSlideIndex != 0 && mainSlideIndex != 3
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      innerSlideIndex = 0;
                                    });
                                  },
                                  child: Container(
                                    color: innerSlideIndex == 0
                                        ? Colors.blueAccent
                                        : Colors.transparent,
                                    padding: EdgeInsets.all(8),
                                    child: Text("All",
                                        style: TextStyle(
                                            fontSize: 15,
                                            letterSpacing: 0.3,
                                            fontWeight: FontWeight.w500,
                                            color: innerSlideIndex == 0
                                                ? Colors.white
                                                : Colors.black54)),
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      innerSlideIndex = 1;
                                    });
                                  },
                                  child: Container(
                                    color: innerSlideIndex == 1
                                        ? Colors.blueAccent
                                        : Colors.transparent,
                                    padding: EdgeInsets.all(8),
                                    child: Text("Low",
                                        style: TextStyle(
                                            fontSize: 15,
                                            letterSpacing: 0.3,
                                            fontWeight: FontWeight.w500,
                                            color: innerSlideIndex == 1
                                                ? Colors.white
                                                : Colors.black54)),
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      innerSlideIndex = 2;
                                    });
                                  },
                                  child: Container(
                                    color: innerSlideIndex == 2
                                        ? Colors.blueAccent
                                        : Colors.transparent,
                                    padding: EdgeInsets.all(8),
                                    child: Text("Moderate",
                                        style: TextStyle(
                                            fontSize: 15,
                                            letterSpacing: 0.3,
                                            fontWeight: FontWeight.w500,
                                            color: innerSlideIndex == 2
                                                ? Colors.white
                                                : Colors.black54)),
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      innerSlideIndex = 3;
                                    });
                                  },
                                  child: Container(
                                    color: innerSlideIndex == 3
                                        ? Colors.blueAccent
                                        : Colors.transparent,
                                    padding: EdgeInsets.all(8),
                                    child: Text("High",
                                        style: TextStyle(
                                            fontSize: 15,
                                            letterSpacing: 0.3,
                                            fontWeight: FontWeight.w500,
                                            color: innerSlideIndex == 3
                                                ? Colors.white
                                                : Colors.black54)),
                                  ),
                                ),
                              ],
                            )
                          : SizedBox(),
                      SizedBox(height: 10),
                      Container(
                        child: ScrollablePositionedList.builder(
                            shrinkWrap: true,
                            initialScrollIndex: indexToScroll,
                            physics: BouncingScrollPhysics(),
                            itemScrollController: itemScrollController,
                            itemPositionsListener: itemPositionsListener,
                            itemCount: mainSlideIndex == 0
                                ? highlightSavedItem.length
                                : mainSlideIndex == 1 && innerSlideIndex == 0
                                    ? examlikehoodSavedItem.length
                                    : mainSlideIndex == 1 &&
                                            innerSlideIndex == 1
                                        ? examlikehoodSavedItemLow.length
                                        : mainSlideIndex == 1 &&
                                                innerSlideIndex == 2
                                            ? examlikehoodSavedItemModerate
                                                .length
                                            : mainSlideIndex == 1 &&
                                                    innerSlideIndex == 3
                                                ? examlikehoodSavedItemHigh
                                                    .length
                                                : mainSlideIndex == 2 &&
                                                        innerSlideIndex == 0
                                                    ? difficultySavedItem.length
                                                    : mainSlideIndex == 2 &&
                                                            innerSlideIndex == 1
                                                        ? difficultySavedItemLow
                                                            .length
                                                        : mainSlideIndex == 2 &&
                                                                innerSlideIndex ==
                                                                    2
                                                            ? difficultySavedItemModerate
                                                                .length
                                                            : mainSlideIndex ==
                                                                        2 &&
                                                                    innerSlideIndex ==
                                                                        3
                                                                ? difficultySavedItemHigh
                                                                    .length
                                                                : allSuggestionItem
                                                                    .length,
                            itemBuilder: (context, i) {
                              return Container(
                                width: 440,
                                margin: EdgeInsets.all(10),
                                child: Row(
                                  children: [
                                    InkWell(
                                      onTap: () async {
                                        if (mainSlideIndex != 3) {
                                          Navigator.of(context).pop();
                                          _itemScrollController?.scrollTo(
                                            index: item[i]['tag_index'],
                                            duration: const Duration(
                                                milliseconds: 250),
                                            alignment: 0,
                                            curve: Curves.linear,
                                          );
                                        } else {
                                          // Directory appDocDir =
                                          //     await getApplicationDocumentsDirectory();
                                          // String appDocPath = appDocDir.path;
                                          // String path =
                                          //     appDocDir.path + '/sway.epub';
                                          // File file = File(path);
                                          // // await file.create();
                                          var response = await dio.get(
                                              'https://firebasestorage.googleapis.com/v0/b/hys-pro-41c66.appspot.com/o/class12%20books%2Faccountancy%2Fpart1%2Fclass%2012%20accountancy%20part1%20chapter%201.epub?alt=media&token=c22016bb-9b6b-4731-9ce3-80b20ba97dc4',
                                              options: Options(
                                                  followRedirects: false,
                                                  receiveTimeout: 0));

                                          // final ref = file.openSync(
                                          //     mode: FileMode.write);
                                          // ref.writeFromSync(response.data);
                                          // await ref.close();
                                          // //return file;
                                          // // print(response);
                                          String _url =
                                              "https://firebasestorage.googleapis.com/v0/b/hys-pro-41c66.appspot.com/o/class12%20books%2Faccountancy%2Fpart1%2Fclass%2012%20accountancy%20part1%20chapter%201.epub?alt=media&token=c22016bb-9b6b-4731-9ce3-80b20ba97dc4";
                                          _launchInBrowser(_url);
                                          // String path = 'Downloads/data.txt';
                                          // bool directoryExists =
                                          //     await Directory(path).exists();
                                          // bool fileExists =
                                          //     await File(path).exists();
                                          // print(
                                          //     "$directoryExists | $fileExists");
                                          // if (response.data != null) {
                                          //   var blob = webFile.Blob(
                                          //       response.data,
                                          //       'text/plain',
                                          //       'native');

                                          //   var anchorElement =
                                          //       webFile.AnchorElement(
                                          //     href: webFile.Url
                                          //             .createObjectUrlFromBlob(
                                          //                 blob)
                                          //         .toString(),
                                          //   )
                                          //         ..setAttribute(
                                          //             "download", "data.txt")
                                          //         ..click();
                                          // }
                                        }
                                      },
                                      child: Container(
                                        width: 420,
                                        child: mainSlideIndex != 3
                                            ? Text(item[i]['text_selected'],
                                                style: TextStyle(
                                                    backgroundColor: item[i][
                                                                'selection_type'] ==
                                                            "heighlight"
                                                        ? (item[i]['color'] ==
                                                                "blueAccent"
                                                            ? Colors.blueAccent
                                                            : item[i]['color'] ==
                                                                    "greenAccent"
                                                                ? Colors
                                                                    .greenAccent
                                                                : Colors
                                                                    .pinkAccent)
                                                        : item[i]['selection_type'] ==
                                                                "examlikehood"
                                                            ? item[i]['level_'] ==
                                                                    "low"
                                                                ? Color.fromRGBO(
                                                                    255, 133, 102, 1)
                                                                : item[i]['level_'] ==
                                                                        "moderate"
                                                                    ? Color.fromRGBO(
                                                                        255,
                                                                        77,
                                                                        77,
                                                                        1)
                                                                    : Color.fromRGBO(
                                                                        230,
                                                                        0,
                                                                        0,
                                                                        1)
                                                            : item[i]['selection_type'] ==
                                                                    "difficultylevel"
                                                                ? item[i]['level_'] ==
                                                                        "low"
                                                                    ? Color.fromRGBO(128, 255, 128, 1)
                                                                    : item[i]['level_'] == "moderate"
                                                                        ? Color.fromRGBO(0, 255, 85, 1)
                                                                        : Color.fromRGBO(0, 153, 51, 1)
                                                                : Color.fromRGBO(230, 0, 0, 1)))
                                            : InkWell(
                                                onTap: () {
                                                  webFile.window.open(
                                                      'http://localhost:58583/epub',
                                                      'ePub');
                                                },
                                                child: Container(
                                                  child: Text(
                                                    allSuggestionItem[i]
                                                        ['Paragraph_related'],
                                                  ),
                                                ),
                                              ),
                                      ),
                                    ),
                                    mainSlideIndex != 3
                                        ? IconButton(
                                            onPressed: () async {
                                              Dialogs.showLoadingDialog(
                                                  context, _keyLoader);
                                              bool check = await epubCRUD
                                                  .deleteUserTextSelectionDetails([
                                                item[i]['book_id'],
                                                item[i]['chapter_id'],
                                                item[i]['user_id'],
                                                item[i]['base_offset'],
                                                item[i]['extent_offset'],
                                                item[i]['tag_index'],
                                                item[i]['selection_type']
                                              ]);
                                              if (check) {
                                                Navigator.of(
                                                        _keyLoader
                                                            .currentContext!,
                                                        rootNavigator: true)
                                                    .pop(); //close the dialoge
                                                _get_all_saved_text();
                                                Navigator.of(context).pop();
                                              }
                                            },
                                            icon: Icon(Icons.delete,
                                                color: Colors.black45,
                                                size: 20))
                                        : SizedBox()
                                  ],
                                ),
                              );
                            }),
                      )
                    ],
                  ),
                ),
              );
            }));
  }
}

enum _EpubViewLoadingState {
  loading,
  error,
  success,
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
