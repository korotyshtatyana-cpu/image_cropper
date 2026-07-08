import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'src/circle_cutout_painter.dart';
import 'src/crop_image_service/crop_image_service.dart';

/// A widget that provides an interactive image cropping experience.
///
/// It allows users to zoom and pan an image behind a fixed circular mask,
/// similar to the photo cropping experience in apps like Telegram.
class TelegramImageCropper extends StatefulWidget {
  /// The path to the image asset that needs to be cropped.
  final String imagePath;

  /// The diameter of the circular crop area in logical pixels.
  ///
  /// Defaults to 200. If the image is smaller than this size, the crop size
  /// will be adjusted to fit the image dimensions.
  final int cropSize;

  /// The style to be applied to the 'Crop Image' button.
  final ButtonStyle? cropButtonStyle;

  /// The text widget to be displayed inside the 'Crop Image' button.
  ///
  /// Defaults to `Text('Crop Image')` if null.
  final Text? cropButtonText;

  /// An optional widget to display as the result of the cropping process.
  ///
  /// If provided, this widget will be shown in a dialog after the user
  /// presses the crop button. If null, a default `AlertDialog` with the
  /// cropped image will be shown.
  final Widget? croppedImageResultWidget;

  const TelegramImageCropper({
    required this.imagePath,
    this.cropSize = 200,
    this.cropButtonStyle,
    this.cropButtonText,
    this.croppedImageResultWidget,
    super.key,
  });

  @override
  _TelegramImageCropperState createState() => _TelegramImageCropperState();
}

class _TelegramImageCropperState extends State<TelegramImageCropper> {
  late ui.Image _image;
  bool _imageLoaded = false;
  final GlobalKey _key = GlobalKey();
  final TransformationController _controller = TransformationController();
  EdgeInsets _boundaryMargin = EdgeInsets.zero;

  // Default crop area dimensions
  int _cropSize = 200;

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
    final ByteData data = await rootBundle.load(widget.imagePath);
    final Uint8List list = Uint8List.view(data.buffer);
    final ui.Image image = await _loadImageFromBytes(list);

    setState(() {
      _image = image;
      _imageLoaded = true;
      _cropSize = _image.width < widget.cropSize
          ? _image.width
          : _image.height < widget.cropSize
              ? _image.height
              : widget.cropSize;
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
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height,
                            child: CustomPaint(
                              painter: CircleCutoutPainter(
                                cropSize: _cropSize,
                                overlayColor:
                                    Colors.black.withValues(alpha: 0.6),
                              ),
                            ),
                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.only(bottom: 36),
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: ElevatedButton(
                            style: widget.cropButtonStyle,
                            onPressed:
                                _imageLoaded ? () => _cropImage(context) : null,
                            child: widget.cropButtonText ??
                                const Text('Crop Image'),
                          ),
                        ),
                      ),
                    ],
                  )
                : const CircularProgressIndicator(),
          ),
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
        builder: (_) =>
            widget.croppedImageResultWidget ??
            AlertDialog(
              content: image,
              contentPadding: EdgeInsets.zero,
            ),
      );
    });
  }
}
