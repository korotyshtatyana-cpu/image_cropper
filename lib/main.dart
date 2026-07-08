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
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: const Text(
            'Image Cropper with InteractiveViewer',
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: const ImageCropper(),
      ),
    );
  }
}
