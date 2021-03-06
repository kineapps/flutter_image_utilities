# flutter_image_utilities

Image file related utilities for saving an image as JPEG with the specified quality and size and for getting image properties.

## Features

- Supports Android and iOS.
- Modern plugin implementation based on Kotlin (Android) and Swift (iOS).
- Uses background processing to keep UI responsive.
- Save an image file as JPEG using the specified JPEG quality.
- Resize saved image to a given size.
- Get image width and height.
- Get image orientation (Android).

## Examples

### Save image as JPEG

```dart
final jpegFile = await FlutterImageUtilities.saveAsJpeg(
  sourceFile: File("source_image_file"),
  destinationFilePath: "path/to/dest/file.jpg",
  quality: 60,
  maxWidth: 1920,
  maxHeight: 1080,
  canScaleUp: false);
```

### Get image properties

```dart
final imageProperties =
  await FlutterImageUtilities.getImageProperties(File("source_image_file"));
```
