// Copyright (c) 2020 KineApps. All rights reserved.
//
// This source code is licensed under the BSD-style license found in the
// LICENSE file in the root directory of this source tree.

import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter_image_utilities/flutter_image_utilities.dart';
import 'package:image_picker/image_picker.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  File _sourceFile;
  File _destinationFile;

  var _scaleMode = ScaleMode.fitKeepAspectRatio;

  var _destinationSize = Size(240, 160);

  ImageProperties _imageProperties;

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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                RaisedButton(
                  child: Text("Pick image"),
                  onPressed: () async {
                    await _pickImage();
                    await _compressImage();
                  },
                ),
                Text(_sourceFile?.path ?? "No image"),
                Text(
                    "${sourceFileSize} bytes = ${(sourceFileSize / 1024.0).toStringAsFixed(1)} kB"),
                Text(
                    "width=${_imageProperties?.width}, height=${_imageProperties?.height}, orientation=${_imageProperties?.orientation}"),
                DropdownButton<ScaleMode>(
                  value: _scaleMode,
                  onChanged: (value) {
                    _scaleMode = value;
                    _compressImage();
                  },
                  items: ScaleMode.values
                      .map<DropdownMenuItem<ScaleMode>>((ScaleMode value) {
                    return DropdownMenuItem<ScaleMode>(
                      value: value,
                      child: Text(scaleModeToString(value)),
                    );
                  }).toList(),
                ),
                Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      if (_destinationFile != null)
                        Image.file(
                          _destinationFile,
                        ),
                      Container(
                        width: _destinationSize.width,
                        height: _destinationSize.height,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.red, width: 3),
                        ),
                      ),
                      if (_scaleMode ==
                              ScaleMode.fillAnyDirectionKeepAspectRatio ||
                          _scaleMode ==
                              ScaleMode.fitAnyDirectionKeepAspectRatio)
                        Container(
                          width: _destinationSize.height,
                          height: _destinationSize.width,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.red, width: 3),
                          ),
                        ),
                    ],
                  ),
                ),
                Text(_destinationFile?.path ?? "N/A"),
                Text(
                    "${destinationFileSize} bytes = ${(destinationFileSize / 1024.0).toStringAsFixed(1)} kB"),
                Text(
                    "Width: ${_destinationSize.width}, height= ${_destinationSize.height}"),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future _pickImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);

    _imageProperties = await FlutterImageUtilities.getImageProperties(image);

    setState(() {
      _sourceFile = image;
    });
  }

  Future _compressImage() async {
    if (_sourceFile == null) {
      return;
    }
    if (_destinationFile?.existsSync() == true) {
      _destinationFile.deleteSync();
    }

    final tempDir = Directory.systemTemp;
    final tempFilePath = tempDir.path +
        "/image" +
        DateTime.now().millisecondsSinceEpoch.toString() +
        ".jpg";

    var image = await FlutterImageUtilities.saveAsJpeg(
        sourceFile: _sourceFile,
        destinationFilePath: tempFilePath,
        quality: 60,
        maxWidth: _destinationSize.width.round(),
        maxHeight: _destinationSize.height.round(),
        scaleMode: _scaleMode);

    imageCache.clear();
    setState(() {
      _destinationFile = null;
    });
    setState(() {
      _destinationFile = image;
    });
  }
}
