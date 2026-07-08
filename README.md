# image_cropper

[![pub version](https://img.shields.io/pub/v/telegram_image_cropper)](https://pub.dev/packages/telegram_image_cropper)
[![license](https://img.shields.io/github/license/korotyshtatyana-cpu/image_cropper)](https://github.com/korotyshtatyana-cpu/image_cropper/blob/main/LICENSE)
[![Platform](https://img.shields.io/badge/platform-Android%20%7C%20iOS%20%7C%20Web%20%7C%20macOS%20%7C%20Windows%20%7C%20Linux-blue?logo=flutter)](https://flutter.dev)

A flexible, high-performance image cropping widget for Flutter, built with `InteractiveViewer`. Inspired by the intuitive cropping experience in apps like **Telegram**, it allows users to smoothly zoom and pan an image behind a fixed circular mask.

<table>
  <tr>
    <td><img src="https://raw.githubusercontent.com/korotyshtatyana-cpu/image_cropper/main/example/images/screenshots/desctop.png" width="250"/><br/><sub>Desktop</sub></td>
    <td><img src="https://raw.githubusercontent.com/korotyshtatyana-cpu/image_cropper/main/example/images/screenshots/mobile.png" width="250"/><br/><sub>Mobile</sub></td>
    <td><img src="https://raw.githubusercontent.com/korotyshtatyana-cpu/image_cropper/main/example/images/screenshots/web.png" width="250"/><br/><sub>Web</sub></td>
  </tr>
</table>

## Features

- **Telegram-style Interaction**: Move and scale the image naturally within a fixed crop area.
- **Cross-Platform**: Fully compatible with **Web**, **iOS**, **Android**, and **Desktop** (macOS, Windows, Linux).
- **High Performance**:
  - **Native**: Uses background Isolates for image processing to prevent UI stuttering.
  - **Web**: Utilizes optimized `Canvas` and `ImageData` for fast client-side cropping.
- **Customizable**: Control crop size, button styles, labels, and the result display.
- **Precise**: Uses transformation matrices for pixel-perfect cropping regardless of zoom level.

## Getting Started

Add `image_cropper` to your `pubspec.yaml`:

```yaml
dependencies:
  image_cropper: ^1.0.0
```

## Usage

Import the package:

```dart
import 'package:image_cropper/telegram_image_cropper.dart';
```

### Basic Example

```dart
TelegramImageCropper(
  imagePath: 'assets/images/profile.jpg',
  cropSize: 250,
  cropButtonText: Text('Save Profile Picture'),
)
```

### Custom Styling & Result Widget

```dart
TelegramImageCropper(
  imagePath: 'assets/images/photo.jpg',
  cropSize: 200,
  cropButtonStyle: ElevatedButton.styleFrom(
    backgroundColor: Colors.blue,
    foregroundColor: Colors.white,
  ),
  cropButtonText: Text('Apply Crop'),
  croppedImageResultWidget: CustomResultDialog(), // Show your custom widget after cropping
)
```

## Properties

| Property | Type | Description | Default |
|----------|------|-------------|---------|
| `imagePath` | `String` | Path to the asset image. | *Required* |
| `cropSize` | `int` | Diameter of the circular crop area. | `200` |
| `cropButtonStyle` | `ButtonStyle?` | Style for the "Crop" button. | `null` |
| `cropButtonText` | `Text?` | Custom label for the "Crop" button. | `Text('Crop Image')` |
| `croppedImageResultWidget` | `Widget?` | Custom widget shown in a dialog after cropping. | `null` |

## How It Works

1. **InteractiveViewer**: Handles all gestures (pan, pinch-to-zoom).
2. **Matrix Transformation**: The widget captures the exact transformation state from the `TransformationController`.
3. **Inverse Mapping**: It applies the inverse of the transformation matrix to the screen crop area to find the exact region on the source image.
4. **Platform Workers**:
   - On **Native** platforms, it processes bytes in a background isolate via the `image` library.
   - On **Web**, it uses the `package:web` API to render to an offscreen Canvas for efficiency.

## License

This project is licensed under the MIT License.
