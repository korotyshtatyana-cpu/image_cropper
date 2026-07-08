# Image Cropper with InteractiveViewer

A Flutter application that demonstrates how to implement a custom image cropping tool using the `InteractiveViewer` widget. This implementation is inspired by the smooth and intuitive photo cropping experience in **Telegram**, allowing users to zoom and pan the image behind a fixed circular mask.

## Features

- **Interactive Zoom & Pan**: Users can easily adjust the image position and scale within the crop area using standard gestures.
- **Circular Crop Overlay**: Provides a clear visual guide for the cropping area using a custom-painted overlay.
- **Background Processing**: Image cropping is performed in a separate isolate using the `compute` function, ensuring the UI remains responsive during heavy processing.
- **Precise Cropping**: Uses transformation matrices to accurately map the visual crop area back to the original image coordinates.
- **Cross-Platform Support**: Works seamlessly across Web, Desktop (Windows, macOS, Linux), and Mobile (iOS, Android).

## How It Works

The project uses `InteractiveViewer`'s `TransformationController` to track how the user has transformed the image (scaling and translation). 

1. **Mapping Coordinates**: When the "Crop Image" button is pressed, the inverse of the transformation matrix is applied to the crop area's screen coordinates.
2. **Scaling**: The coordinates are then scaled to match the original image's dimensions.
3. **Isolate Processing**: The calculated crop rectangle and image data are sent to a background isolate.
4. **Image Manipulation**: The `image` package is used to crop and encode the result as a JPG.

## Project Structure

- `lib/main.dart`: Entry point of the application.
- `lib/image_cropper.dart`: The main UI widget containing the `InteractiveViewer` and crop overlay.
- `lib/crop_image_service.dart`: Service responsible for coordinate calculations and isolate-based cropping.
- `lib/circle_cutout_painter.dart`: Custom painter for the circular crop overlay.

## Getting Started

1. **Clone the repository.**
2. **Ensure you have Flutter installed.**
3. **Run `flutter pub get`** to install dependencies.
4. **Run the app** on your preferred device.

## Dependencies

- [image](https://pub.dev/packages/image): For server-side (or isolate-side) image processing.
- [vector_math](https://pub.dev/packages/vector_math): For matrix transformations.
