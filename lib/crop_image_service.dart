import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:vector_math/vector_math_64.dart' show Vector3;

class CropImageService {
  static Future<Image?> cropImage({
    required Matrix4 transformation,
    required RenderBox renderBox,
    required double cropSize,
    required int imageWidth,
    required int imageHeight,
    required ByteData? imageByteData,
  }) async {
    // Get the current scale and translation from the InteractiveViewer
    // final Matrix4 transformation = _controller.value;

    // Get the inverse of the transformation matrix
    final Matrix4 matrix4 = transformation.clone()..invert();

    // Define the fixed crop area (centered)
    final ui.Size size = renderBox.size;
    final double scaleFactor =
        _getScaleFactor(renderBox: renderBox, imageWidth: imageWidth);

    final ui.Rect cropRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: cropSize,
      height: cropSize,
    );

    // Apply the inverse matrix to the crop rect to get the portion of the image that is visible
    final Vector3 topLeft = matrix4
        .transform3(Vector3(cropRect.topLeft.dx, cropRect.topLeft.dy, 0));
    final Vector3 bottomRight = matrix4.transform3(
        Vector3(cropRect.bottomRight.dx, cropRect.bottomRight.dy, 0));

    // Crop the image using the transformed rectangle
    final Rect transformedRect = Rect.fromPoints(
      Offset(topLeft.x * scaleFactor, topLeft.y * scaleFactor),
      // Convert Vector3 to Offset
      Offset(bottomRight.x * scaleFactor, bottomRight.y * scaleFactor),
    );

    // Ensure the crop coordinates are within image bounds
    final int cropLeft = transformedRect.left.clamp(0, imageWidth).toInt();
    final int cropTop = transformedRect.top.clamp(0, imageHeight).toInt();
    final int cropWidth =
        transformedRect.width.clamp(0, imageWidth - cropLeft).toInt();
    final int cropHeight =
        transformedRect.height.clamp(0, imageHeight - cropTop).toInt();

    if (imageByteData != null) {
      final img.Image original = img.Image.fromBytes(
          imageWidth, imageHeight, imageByteData.buffer.asUint8List());
      final img.Image croppedImage = img.copyCrop(
        original,
        cropLeft,
        cropTop,
        cropWidth,
        cropHeight,
      );

      // Convert cropped image to displayable format
      final Uint8List cropped = await _convertToUiImage(croppedImage);

      // Return the cropped image
      return Image.memory(Uint8List.view(cropped.buffer.asByteData().buffer));
    }

    return null;
  }

  static double _getScaleFactor({
    required RenderBox renderBox,
    required int imageWidth,
  }) {
    final ui.Size size = renderBox.size;

    return imageWidth / size.width;
  }

  static Future<Uint8List> _convertToUiImage(img.Image image) async {
    final Uint8List bytes = Uint8List.fromList(img.encodePng(image));
    return bytes;
  }
}
