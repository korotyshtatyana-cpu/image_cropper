import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:vector_math/vector_math_64.dart' show Vector3;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Image Cropper with InteractiveViewer')),
        body: ImageCropper(),
      ),
    );
  }
}

class ImageCropper extends StatefulWidget {
  @override
  _ImageCropperState createState() => _ImageCropperState();
}

class _ImageCropperState extends State<ImageCropper> {
  late ui.Image _image;
  bool _imageLoaded = false;
  GlobalKey _key = GlobalKey();
  TransformationController _controller = TransformationController();
  EdgeInsets _boundaryMargin = EdgeInsets.zero;

  // Fixed crop area dimensions
  final double _cropSize = 200;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  double _getScaleFactor() {
    RenderBox renderBox = _key.currentContext!.findRenderObject() as RenderBox;
    final size = renderBox.size;

    return (_image.width / size.width);
  }

  void _getBoundaryMargin() {
    RenderBox? renderBox = _key.currentContext?.findRenderObject() as RenderBox?;

    if (renderBox != null) {
      final size = renderBox.size;

      final vertical = ((size.height - (_cropSize)) / 2) / _controller.value.row0[0];
      final horizontal = ((size.width - (_cropSize)) / 2) / _controller.value.row0[0];

      setState(() {
        _boundaryMargin = EdgeInsets.symmetric(vertical: vertical, horizontal: horizontal);
      });
    }
  }

  Future<void> _loadImage() async {
    // Load an image from assets
    final ByteData data = await rootBundle.load('images/lorenzomessinaph.jpg');
    final Uint8List list = Uint8List.view(data.buffer);
    final ui.Image image = await _loadImageFromBytes(list);

    setState(() {
      _image = image;
      _imageLoaded = true;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getBoundaryMargin();
    });
  }

  Future<ui.Image> _loadImageFromBytes(Uint8List list) async {
    final Completer<ui.Image> completer = Completer();
    ui.decodeImageFromList(list, (ui.Image img) {
      return completer.complete(img);
    });
    return completer.future;
  }

  Future<void> _cropImage() async {
    // Get the current scale and translation from the InteractiveViewer
    final transformation = _controller.value;

    // Get the inverse of the transformation matrix
    final matrix4 = transformation.clone()..invert();

    // Define the fixed crop area (centered)
    RenderBox renderBox = _key.currentContext!.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final scaleFactor = _getScaleFactor();

    final cropRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: _cropSize,
      height: _cropSize,
    );

    // Apply the inverse matrix to the crop rect to get the portion of the image that is visible
    final topLeft = matrix4.transform3(Vector3(cropRect.topLeft.dx, cropRect.topLeft.dy, 0));
    final bottomRight = matrix4.transform3(Vector3(cropRect.bottomRight.dx, cropRect.bottomRight.dy, 0));

    // Crop the image using the transformed rectangle
    final Rect transformedRect = Rect.fromPoints(
      Offset(topLeft.x * scaleFactor, topLeft.y * scaleFactor), // Convert Vector3 to Offset
      Offset(bottomRight.x * scaleFactor, bottomRight.y * scaleFactor),
    );

    // Ensure the crop coordinates are within image bounds
    int cropLeft = transformedRect.left.clamp(0, _image.width).toInt();
    int cropTop = transformedRect.top.clamp(0, _image.height).toInt();
    int cropWidth = transformedRect.width.clamp(0, _image.width - cropLeft).toInt();
    int cropHeight = transformedRect.height.clamp(0, _image.height - cropTop).toInt();

    final ByteData? data = await _image.toByteData(format: ui.ImageByteFormat.rawRgba);
    if (data != null) {
      img.Image original = img.Image.fromBytes(_image.width, _image.height, data.buffer.asUint8List());
      img.Image croppedImage = img.copyCrop(
        original,
        cropLeft,
        cropTop,
        cropWidth,
        cropHeight,
      );

      // Convert cropped image to displayable format
      final cropped = await _convertToUiImage(croppedImage);

      // Display the cropped image
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          content: Image.memory(Uint8List.view(cropped.buffer.asByteData().buffer)),
        ),
      );
    }
  }

  Future<Uint8List> _convertToUiImage(img.Image image) async {
    final Uint8List bytes = Uint8List.fromList(img.encodePng(image));
    return bytes;
  }

  @override
  Widget build(BuildContext context) {
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //       _getBoundaryMargin();
    //     });

    return Column(
      children: [
        Expanded(
          child: Center(
            child: _imageLoaded
                ? Stack(
                    children: [
                      Center(
                        child: InteractiveViewer(
                          // transformationController: _controller,
                          // boundaryMargin: EdgeInsets.all(100.0),
                          minScale: 0.5,
                          maxScale: 3.0,
                          transformationController: _controller,
                          clipBehavior: Clip.none,
                          // minScale: 1,
                          boundaryMargin: _boundaryMargin,
                          onInteractionEnd: (ScaleEndDetails details) {
                            _getBoundaryMargin();
                          },
                          child: RawImage(
                            key: _key,
                            image: _image,
                          ),
                        ),
                      ),
                      // Static crop area in the center
                      IgnorePointer(
                        child: Center(
                          child: Container(
                            width: _cropSize,
                            height: _cropSize,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.red, width: 2),
                              color: Colors.transparent,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : CircularProgressIndicator(),
          ),
        ),
        ElevatedButton(
          onPressed: _imageLoaded ? _cropImage : null,
          child: Text('Crop Image'),
        ),
      ],
    );
  }
}
