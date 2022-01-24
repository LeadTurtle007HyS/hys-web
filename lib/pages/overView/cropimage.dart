import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as Im;
import 'dart:math';

class Cropper extends StatefulWidget {
  final Uint8List image;

  Cropper(this.image);

  @override
  _CropperState createState() => _CropperState(image: image);
}

class _CropperState extends State<Cropper> {
  Uint8List? image;
  Uint8List? resultImg;
  double scale = 1.0;
  double? zeroScale; //Initial scale to fit image in bounding crop box.
  Offset offset = Offset(0.0, 0.0); //Used in translation of image.
  double cropRatio = 10 / 5; //aspect ratio of desired crop.
  Im.Image? decoded; //decoded image to get pixel dimensions
  double imgWidth = 0; //img pixel width
  double imgHeight = 0; //img pixel height
  Size cropArea = Size(1, 1); //Size of crop bonding box
  double? cropPad; //Aesthetic crop box padding.

  double? pXa; //Positive X available in translation
  double? pYa; //Positive Y available in translation
  double? totalX; //Total X of scaled image
  double? totalY; //Total Y of scaled image

  Completer _decoded = Completer<bool>();
  Completer _encoded = Completer<Uint8List>();

  _CropperState({required this.image});

  @override
  initState() {
    _decodeImg();
    super.initState();
  }

  _decodeImg() {
    if (_decoded.isCompleted) return;
    decoded = Im.decodeImage(image!);
    imgWidth = decoded!.width.toDouble();
    imgHeight = decoded!.height.toDouble();
    _decoded.complete(true);
  }

  _encodeImage(Im.Image cropped) async {
    resultImg = Im.encodePng(cropped) as Uint8List?;
    _encoded.complete(resultImg);
  }

  void _cropImage() async {
    double xPercent = pXa != 0.0 ? 1.0 - (offset.dx + pXa!) / (2 * pXa!) : 0.0;
    double yPercent = pYa != 0.0 ? 1.0 - (offset.dy + pYa!) / (2 * pYa!) : 0.0;
    double cropXpx = imgWidth * cropArea.width / totalX!;
    double cropYpx = imgHeight * cropArea.height / totalY!;
    double x0 = (imgWidth - cropXpx) * xPercent;
    double y0 = (imgHeight - cropYpx) * yPercent;
    Im.Image cropped = Im.copyCrop(
        decoded!, x0.toInt(), y0.toInt(), cropXpx.toInt(), cropYpx.toInt());
    _encodeImage(cropped);
    Navigator.pop(context, _encoded.future);
  }

  computeRelativeDim(double newScale) {
    totalX = newScale * cropArea.height * imgWidth / imgHeight;
    totalY = newScale * cropArea.height;
    pXa = 0.5 * (totalX! - cropArea.width);
    pYa = 0.5 * (totalY! - cropArea.height);
  }

  double croppedAreaCustomHeight = 1;
  double croppedAreaCustomWidth = 1;

  bool init = true;
  double checksliderHeight = 0;
  double checkSliderWidth = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Crop Photo'),
        centerTitle: true,
        leading: IconButton(
          onPressed: _cropImage,
          tooltip: 'Crop',
          icon: Icon(Icons.crop),
        ),
        actions: [
          RaisedButton(
            onPressed: () => Navigator.pop(context, null),
            child: Text('Cancel'),
          )
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: FutureBuilder(
              future: _decoded.future,
              builder: (ctx, snap) {
                if (!snap.hasData)
                  return Center(
                    child: Text('Loading...'),
                  );
                return LayoutBuilder(
                  builder: (ctx, cstr) {
                    if (init) {
                      cropPad = cstr.maxHeight * 0.05;
                      double tmpWidth = cstr.maxWidth - 2 * cropPad!;
                      double tmpHeight = cstr.maxHeight - 2 * cropPad!;
                      cropArea = (tmpWidth / cropRatio > tmpHeight)
                          ? Size(tmpHeight * cropRatio, tmpHeight)
                          : Size(tmpWidth, tmpWidth / cropRatio);
                      zeroScale = cropArea.height / imgHeight;
                      computeRelativeDim(scale);
                      init = false;
                    }
                    return GestureDetector(
                      onPanUpdate: (pan) {
                        double dy;
                        double dx;
                        if (pan.delta.dy > 0)
                          dy = min(pan.delta.dy, pYa! - offset.dy);
                        else
                          dy = max(pan.delta.dy, -pYa! - offset.dy);
                        if (pan.delta.dx > 0)
                          dx = min(pan.delta.dx, pXa! - offset.dx);
                        else
                          dx = max(pan.delta.dx, -pXa! - offset.dx);
                        setState(() => offset += Offset(dx, dy));
                      },
                      child: Stack(
                        children: [
                          Container(
                            color: Colors.black.withOpacity(0.5),
                            height: cstr.maxHeight,
                            width: cstr.maxWidth,
                            child: ClipRect(
                              child: Container(
                                alignment: Alignment.center,
                                height: cropArea.height,
                                width: cropArea.width,
                                child: Transform.translate(
                                  offset: offset,
                                  child: Transform.scale(
                                    scale: scale * zeroScale!,
                                    child: OverflowBox(
                                      maxWidth: imgWidth,
                                      maxHeight: imgHeight,
                                      child: Image.memory(
                                        image!,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          IgnorePointer(
                            child: Center(
                              child: Container(
                                height:
                                    cropArea.height - croppedAreaCustomHeight,
                                width: cropArea.width - croppedAreaCustomWidth,
                                decoration: BoxDecoration(
                                  border:
                                      Border.all(color: Colors.white, width: 2),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Row(
            children: <Widget>[
              Text('Scale:'),
              Expanded(
                child: SliderTheme(
                  data: theme.sliderTheme,
                  child: Slider(
                    value: scale,
                    min: 1,
                    max: 2,
                    onChanged: (n) {
                      double dy;
                      double dx;
                      computeRelativeDim(n);
                      dy = (offset.dy > 0)
                          ? min(offset.dy, pYa!)
                          : max(offset.dy, -pYa!);
                      dx = (offset.dx > 0)
                          ? min(offset.dx, pXa!)
                          : max(offset.dx, -pXa!);
                      setState(() {
                        offset = Offset(dx, dy);
                        scale = n;
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: <Widget>[
              Text('Height:'),
              Expanded(
                child: SliderTheme(
                  data: theme.sliderTheme,
                  child: Slider(
                    value: croppedAreaCustomHeight,
                    min: 1,
                    max: cropArea.height,
                    onChanged: (n) {
                      setState(() {
                        if ((croppedAreaCustomHeight < n) &&
                            (croppedAreaCustomHeight < cropArea.height)) {
                          croppedAreaCustomHeight++;
                          croppedAreaCustomHeight = n;
                        } else if ((croppedAreaCustomHeight >= n) &&
                            (croppedAreaCustomHeight > 0)) {
                          croppedAreaCustomHeight--;
                          croppedAreaCustomHeight = n;
                        }
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: <Widget>[
              Text('Width:'),
              Expanded(
                child: SliderTheme(
                  data: theme.sliderTheme,
                  child: Slider(
                    value: croppedAreaCustomWidth,
                    min: 1,
                    max: cropArea.width,
                    onChanged: (n) {
                      setState(() {
                        if ((croppedAreaCustomWidth < n) &&
                            (croppedAreaCustomWidth < cropArea.width)) {
                          croppedAreaCustomWidth++;
                          croppedAreaCustomWidth = n;
                        } else if ((croppedAreaCustomWidth >= n) &&
                            (croppedAreaCustomWidth > 0)) {
                          croppedAreaCustomWidth--;
                          croppedAreaCustomWidth = n;
                        }
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
