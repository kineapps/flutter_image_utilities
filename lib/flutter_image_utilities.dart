// Copyright (c) 2020 KineApps. All rights reserved.
//
// This source code is licensed under the BSD-style license found in the
// LICENSE file in the root directory of this source tree.

import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';

/// Utility methods for working with image files.
class FlutterImageUtilities {
  static const MethodChannel _channel =
      MethodChannel('flutter_image_utilities');

  /// Save [sourceFile] as JPEG to [destinationFilePath] using given
  /// [quality] (1-100, null=100). Resize image to given [maxWidth] and
  /// [maxHeight] using specified [scaleMode]. Original image size is not
  ///  modified if [maxWidth] and [maxHeight] are null.
  ///
  /// If [destinationFilePath] is null, a temporary file is created
  /// automatically.
  ///
  /// Returns saved JPEG image file.
  ///
  /// Throws an exception on error.
  static Future<File> saveAsJpeg(
      {required File sourceFile,
      String? destinationFilePath,
      int? quality,
      int? maxWidth,
      int? maxHeight,
      ScaleMode? scaleMode}) async {
    final params = _SaveAsJpegParameters(
        sourceFile: sourceFile,
        destinationFilePath: destinationFilePath,
        quality: quality,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        scaleMode: scaleMode);

    final String? savedFile =
        await _channel.invokeMethod('saveAsJpeg', params.toJson());
    if (savedFile == null) {
      throw Exception('Unknown error');
    }
    return File(savedFile);
  }

  /// Get properties for the given image file [imageFile].
  /// Throws an exception on error.
  static Future<ImageProperties> getImageProperties(File imageFile) async {
    final params = <String, dynamic>{
      'imageFile': imageFile.path,
    };
    final properties = Map<String, dynamic>.from(
        await _channel.invokeMethod<Map>('getImageProperties', params) ??
            const <String, dynamic>{});
    final orientationId = properties["orientation"] as int?;
    return ImageProperties(
      width: properties['width'] as int?,
      height: properties['height'] as int?,
      orientation: orientationId == null
          ? ImageOrientation.undefined
          : (_imageOrientationById[orientationId] ??
              ImageOrientation.undefined),
    );
  }
}

/// Scale mode used in [saveAsJpeg].
enum ScaleMode {
  /// Image is resized to the specified maximum size keeping
  /// aspect ratio.
  fitKeepAspectRatio,

  /// Image is resized to the minimum size so that image fills specified
  /// size and keeps aspect ratio.
  fillKeepAspectRatio,

  /// Image is resized to the specified maximum size keeping
  /// aspect ratio. Image may be virtually rotated to fit to the specified
  /// maximum size optimally.
  fitAnyDirectionKeepAspectRatio,

  /// Image is resized to the minimum size so that image fills specified
  /// size and keeps aspect ratio. Image may be virtually rotated to fill
  /// the specified maximum size optimally.
  fillAnyDirectionKeepAspectRatio
}

/// Get [scaleMode] as string. Returns null if [scaleMode] is null.
String? scaleModeToString(ScaleMode? scaleMode) {
  if (scaleMode == null) {
    return null;
  }
  switch (scaleMode) {
    case ScaleMode.fitKeepAspectRatio:
      return 'FitKeepAspectRatio';
    case ScaleMode.fillKeepAspectRatio:
      return 'FillKeepAspectRatio';
    case ScaleMode.fitAnyDirectionKeepAspectRatio:
      return 'FitAnyDirectionKeepAspectRatio';
    case ScaleMode.fillAnyDirectionKeepAspectRatio:
      return 'FillAnyDirectionKeepAspectRatio';
    default:
      return null;
  }
}

/// Parameters used in [saveAsJpeg].
class _SaveAsJpegParameters {
  const _SaveAsJpegParameters(
      {required this.sourceFile,
      this.destinationFilePath,
      this.quality,
      this.maxWidth,
      this.maxHeight,
      this.scaleMode});

  final File sourceFile;
  final String? destinationFilePath;
  final int? quality;
  final int? maxWidth;
  final int? maxHeight;
  final ScaleMode? scaleMode;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'sourceFilePath': sourceFile.path,
      'destinationFilePath': destinationFilePath,
      'quality': quality,
      'maxWidth': maxWidth,
      'maxHeight': maxHeight,
      'scaleMode': scaleModeToString(scaleMode)
    };
  }
}

/// Image oriention information returned by [getImageProperties].
enum ImageOrientation {
  normal,
  rotate90,
  rotate180,
  rotate270,
  flipHorizontal,
  flipVertical,
  transpose,
  transverse,
  undefined,
}

/// Map from id to [ImageOrientation]
/// https://developer.android.com/reference/android/media/ExifInterface
Map<int, ImageOrientation> _imageOrientationById = {
  1: ImageOrientation.normal,
  2: ImageOrientation.flipHorizontal,
  3: ImageOrientation.rotate180,
  4: ImageOrientation.flipVertical,
  5: ImageOrientation.transpose,
  6: ImageOrientation.rotate90,
  7: ImageOrientation.transverse,
  8: ImageOrientation.rotate270
};

/// Image properties returned by [getImageProperties].
class ImageProperties {
  const ImageProperties(
      {this.width = 0,
      this.height = 0,
      this.orientation = ImageOrientation.undefined});

  final int? width;
  final int? height;
  final ImageOrientation orientation;
}
