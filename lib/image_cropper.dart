import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'crop_image_service.dart';

class ImageCropper extends StatefulWidget {
  const ImageCropper({super.key});

  @override
  _ImageCropperState createState() => _ImageCropperState();
}

class _ImageCropperState extends State<ImageCropper> {
  late ui.Image _image;
  bool _imageLoaded = false;
  final GlobalKey _key = GlobalKey();
  final TransformationController _controller = TransformationController();
  EdgeInsets _boundaryMargin = EdgeInsets.zero;

  // Fixed crop area dimensions
  final double _cropSize = 200;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  void _getBoundaryMargin() {
    final RenderBox? renderBox =
        _key.currentContext?.findRenderObject() as RenderBox?;

    if (renderBox != null) {
      final ui.Size size = renderBox.size;

      final double vertical =
          ((size.height - _cropSize) / 2) / _controller.value.row0[0];
      final double horizontal =
          ((size.width - _cropSize) / 2) / _controller.value.row0[0];

      setState(() {
        _boundaryMargin =
            EdgeInsets.symmetric(vertical: vertical, horizontal: horizontal);
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
    final Completer<ui.Image> completer = Completer<ui.Image>();
    ui.decodeImageFromList(list, (ui.Image img) {
      return completer.complete(img);
    });
    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          child: Center(
            child: _imageLoaded
                ? Stack(
                    children: <Widget>[
                      Center(
                        child: InteractiveViewer(
                          minScale: 0.5,
                          maxScale: 3.0,
                          transformationController: _controller,
                          clipBehavior: Clip.none,
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
                : const CircularProgressIndicator(),
          ),
        ),
        ElevatedButton(
          onPressed: _imageLoaded ? () => _cropImage(context) : null,
          child: const Text('Crop Image'),
        ),
      ],
    );
  }

  Future<void> _cropImage(BuildContext context) async {
    await CropImageService.cropImage(
      transformation: _controller.value,
      renderBox: _key.currentContext!.findRenderObject()! as RenderBox,
      cropSize: _cropSize,
      imageWidth: _image.width,
      imageHeight: _image.height,
      imageByteData: await _image.toByteData(),
    ).then((Image? image) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(content: image),
      );
    });
  }
}
