// Copyright (c) 2020 KineApps. All rights reserved.
//
// This source code is licensed under the BSD-style license found in the
// LICENSE file in the root directory of this source tree.

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_image_utilities/flutter_image_utilities.dart';
import 'package:image_picker/image_picker.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  File? _sourceFile;
  File? _destinationFile;

  final _destinationSize = const Size(200, 400);

  bool _canScaleUp = true;

  ImageProperties? _imageProperties;
  ImageProperties? _actualImageProperties;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final sourceFileSize =
        _sourceFile?.existsSync() == true ? _sourceFile?.lengthSync() ?? 0 : 0;

    final destinationFileSize = _destinationFile?.existsSync() == true
        ? _destinationFile?.lengthSync() ?? 0
        : 0;

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('flutter_image_utilities example app'),
        ),
        body: ListView(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                      "Destination width=${_destinationSize.width}, height=${_destinationSize.height}"),
                  ElevatedButton(
                    onPressed: () async {
                      await _pickImage();
                      await _compressImage();
                    },
                    child: const Text("Pick image"),
                  ),
                  Text(_sourceFile?.path ?? "No image"),
                  Text(
                      "$sourceFileSize bytes = ${(sourceFileSize / 1024.0).toStringAsFixed(1)} kB"),
                  Text(
                      "width=${_imageProperties?.width}, height=${_imageProperties?.height}, orientation=${_imageProperties?.orientation}"),
                  CheckboxListTile(
                      title: const Text('Can scale up'),
                      value: _canScaleUp,
                      onChanged: (value) {
                        setState(() => _canScaleUp = value ?? false);
                        _compressImage();
                      }),
                  Center(
                    child: Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.hardEdge,
                      children: <Widget>[
                        if (_destinationFile != null)
                          SizedBox(
                            width: _actualImageProperties?.width?.toDouble(),
                            height: _actualImageProperties?.height?.toDouble(),
                            child: Image.file(
                              _destinationFile!,
                              width: _actualImageProperties?.width?.toDouble(),
                              height:
                                  _actualImageProperties?.height?.toDouble(),
                            ),
                          ),
                        Container(
                          width: _destinationSize.width,
                          height: _destinationSize.height,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.red, width: 3),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(_destinationFile?.path ?? "N/A"),
                  Text(
                      "$destinationFileSize bytes = ${(destinationFileSize / 1024.0).toStringAsFixed(1)} kB"),
                  Text(
                      "Width: ${_actualImageProperties?.width ?? '-'}, height= ${_actualImageProperties?.height ?? '-'}"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final imageFile = File(pickedFile.path);

      _imageProperties =
          await FlutterImageUtilities.getImageProperties(imageFile);

      setState(() {
        _sourceFile = imageFile;
      });
    }
  }

  Future _compressImage() async {
    if (_sourceFile == null) {
      return;
    }
    if (_destinationFile?.existsSync() == true) {
      _destinationFile!.deleteSync();
    }

    final tempDir = Directory.systemTemp;
    final tempFilePath =
        "${tempDir.path}/image${DateTime.now().millisecondsSinceEpoch}.jpg";

    final image = await FlutterImageUtilities.saveAsJpeg(
        sourceFile: _sourceFile!,
        destinationFilePath: tempFilePath,
        quality: 60,
        maxWidth: _destinationSize.width.round(),
        maxHeight: _destinationSize.height.round(),
        canScaleUp: _canScaleUp);

    _actualImageProperties =
        await FlutterImageUtilities.getImageProperties(image);

    imageCache.clear();
    setState(() {
      _destinationFile = null;
    });
    setState(() {
      _destinationFile = image;
    });
  }
}
