import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_size_getter/image_size_getter.dart' as getter;

import '../croppainter/croppainter.dart';

class CropImage extends StatefulWidget {
  File file;
  CropImage(this.file);
  @override
  _CropImageState createState() => _CropImageState();
}

class _CropImageState extends State<CropImage> {
  final GlobalKey key = GlobalKey();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  double? width, height;
  Size? imagePixelSize;
  bool isFile = false;
  Offset? tl, tr, bl, br;
  bool isLoading = false;
  MethodChannel channel = MethodChannel('opencv');
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Timer(Duration(milliseconds: 2000), getImageSize);
  }

  getter.ImageSizeGetter ImageSizGetter = getter.ImageSizeGetter();

  void getImageSize() {
    RenderBox imageBox = key.currentContext!.findRenderObject() as RenderBox;
    width = imageBox.size.width;
    height = imageBox.size.height;
    imagePixelSize =
        getter.ImageSizeGetter.getSize(widget.file as getter.ImageInput)
            as Size?;
    tl = Offset(20, 20);
    tr = Offset(width! - 20, 20);
    bl = Offset(20, height! - 20);
    br = Offset(width! - 20, height! - 20);
    setState(() {
      isFile = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: ThemeData.dark().canvasColor,
        key: _scaffoldKey,
        body: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Stack(
                children: <Widget>[
                  GestureDetector(
                    onPanDown: (details) {
                      double x1 = details.localPosition.dx;
                      double y1 = details.localPosition.dy;
                      double x2 = tl!.dx;
                      double y2 = tl!.dy;
                      double x3 = tr!.dx;
                      double y3 = tr!.dy;
                      double x4 = bl!.dx;
                      double y4 = bl!.dy;
                      double x5 = br!.dx;
                      double y5 = br!.dy;
                      if (sqrt((x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1)) <
                              30 &&
                          x1 >= 0 &&
                          y1 >= 0 &&
                          x1 < width! / 2 &&
                          y1 < height! / 2) {
                        print(details.localPosition);
                        setState(() {
                          tl = details.localPosition;
                        });
                      } else if (sqrt((x3 - x1) * (x3 - x1) +
                                  (y3 - y1) * (y3 - y1)) <
                              30 &&
                          x1 >= width! / 2 &&
                          y1 >= 0 &&
                          x1 < width! &&
                          y1 < height! / 2) {
                        setState(() {
                          tr = details.localPosition;
                        });
                      } else if (sqrt((x4 - x1) * (x4 - x1) +
                                  (y4 - y1) * (y4 - y1)) <
                              30 &&
                          x1 >= 0 &&
                          y1 >= height! / 2 &&
                          x1 < width! / 2 &&
                          y1 < height!) {
                        setState(() {
                          bl = details.localPosition;
                        });
                      } else if (sqrt((x5 - x1) * (x5 - x1) +
                                  (y5 - y1) * (y5 - y1)) <
                              30 &&
                          x1 >= width! / 2 &&
                          y1 >= height! / 2 &&
                          x1 < width! &&
                          y1 < height!) {
                        setState(() {
                          br = details.localPosition;
                        });
                      }
                    },
                    onPanUpdate: (details) {
                      double x1 = details.localPosition.dx;
                      double y1 = details.localPosition.dy;
                      double x2 = tl!.dx;
                      double y2 = tl!.dy;
                      double x3 = tr!.dx;
                      double y3 = tr!.dy;
                      double x4 = bl!.dx;
                      double y4 = bl!.dy;
                      double x5 = br!.dx;
                      double y5 = br!.dy;
                      if (sqrt((x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1)) <
                              30 &&
                          x1 >= 0 &&
                          y1 >= 0 &&
                          x1 < width! / 2 &&
                          y1 < height! / 2) {
                        print(details.localPosition);
                        setState(() {
                          tl = details.localPosition;
                        });
                      } else if (sqrt((x3 - x1) * (x3 - x1) +
                                  (y3 - y1) * (y3 - y1)) <
                              30 &&
                          x1 >= width! / 2 &&
                          y1 >= 0 &&
                          x1 < width! &&
                          y1 < height! / 2) {
                        setState(() {
                          tr = details.localPosition;
                        });
                      } else if (sqrt((x4 - x1) * (x4 - x1) +
                                  (y4 - y1) * (y4 - y1)) <
                              30 &&
                          x1 >= 0 &&
                          y1 >= height! / 2 &&
                          x1 < width! / 2 &&
                          y1 < height!) {
                        setState(() {
                          bl = details.localPosition;
                        });
                      } else if (sqrt((x5 - x1) * (x5 - x1) +
                                  (y5 - y1) * (y5 - y1)) <
                              30 &&
                          x1 >= width! / 2 &&
                          y1 >= height! / 2 &&
                          x1 < width! &&
                          y1 < height!) {
                        setState(() {
                          br = details.localPosition;
                        });
                      }
                    },
                    child: SafeArea(
                      child: Container(
                        color: ThemeData.dark().canvasColor,
                        constraints: BoxConstraints(maxHeight: 450),
                        child: Image.file(
                          widget.file,
                          key: key,
                        ),
                      ),
                    ),
                  ),
                  isFile
                      ? SafeArea(
                          child: CustomPaint(
                            painter: CropPainter(tl!, tr!, bl!, br!),
                          ),
                        )
                      : SizedBox()
                ],
              ),
              bottomSheet()
            ],
          ),
        ));
  }

  Widget bottomSheet() {
    return Container(
      color: ThemeData.dark().canvasColor,
      width: MediaQuery.of(context).size.width,
      height: 120,
      child: Center(
        child: Column(
          children: <Widget>[
            Text(
              "Drag the handles to adjust the borders. You can",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  "also do this later using the ",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                Icon(
                  Icons.crop,
                  color: Colors.white,
                ),
                Text(
                  " tool.",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                MaterialButton(
                  onPressed: () {},
                  child: Text(
                    "Retake",
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.4), fontSize: 18),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    width: 100,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: Colors.blue,
                    ),
                    child: isLoading
                        ? Container(
                            width: 60.0,
                            height: 20.0,
                            child: Center(
                              child: Container(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor:
                                      AlwaysStoppedAnimation(Colors.white),
                                ),
                              ),
                            ),
                          )
                        : isFile
                            ? ElevatedButton(
                                child: Text(
                                  "Continue",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 18),
                                ),
                                onPressed: () async {
                                  setState(() {
                                    isLoading = true;
                                  });
                                  double tlX =
                                      (imagePixelSize!.width / width!) * tl!.dx;
                                  double trX =
                                      (imagePixelSize!.width / width!) * tr!.dx;
                                  double blX =
                                      (imagePixelSize!.width / width!) * bl!.dx;
                                  double brX =
                                      (imagePixelSize!.width / width!) * br!.dx;

                                  double tlY =
                                      (imagePixelSize!.height / height!) *
                                          tl!.dy;
                                  double trY =
                                      (imagePixelSize!.height / height!) *
                                          tr!.dy;
                                  double blY =
                                      (imagePixelSize!.height / height!) *
                                          bl!.dy;
                                  double brY =
                                      (imagePixelSize!.height / height!) *
                                          br!.dy;
                                  Timer(Duration(seconds: 1), () async {
                                    var bytesArray = await channel
                                        .invokeMethod('convertToGray', {
                                      'filePath': widget.file.path,
                                      'tl_x': tlX,
                                      'tl_y': tlY,
                                      'tr_x': trX,
                                      'tr_y': trY,
                                      'bl_x': blX,
                                      'bl_y': blY,
                                      'br_x': brX,
                                      'br_y': brY,
                                    });
                                    Navigator.of(context).pop([
                                      bytesArray,
                                      tlX,
                                      tlY,
                                      trX,
                                      trY,
                                      blX,
                                      blY,
                                      brX,
                                      brY
                                    ]);
                                  });
                                },
                              )
                            : Container(
                                width: 60,
                                height: 20.0,
                                child: Center(
                                    child: Container(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation(
                                              Colors.white),
                                        ))),
                              ),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
