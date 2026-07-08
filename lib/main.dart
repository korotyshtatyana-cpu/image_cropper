import 'package:flutter/material.dart';

import 'image_cropper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Image Cropper with InteractiveViewer'),
        ),
        body: const ImageCropper(),
      ),
    );
  }
}
