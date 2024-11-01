// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:test_drive/main.dart';
import 'package:test_drive/pose_picker.dart';

class MyClothPage extends StatefulWidget {
  const MyClothPage({super.key});

  @override
  State<MyClothPage> createState() => _MyClothPageState();
}

class _MyClothPageState extends State<MyClothPage> {
  List<XFile>? _mediaFileList;

  void _setImageFileListFromFile(XFile? value) {
    _mediaFileList = value == null ? null : <XFile>[value];
  }

  dynamic _pickImageError;
  bool isVideo = false;

  String? _retrieveDataError;

  final ImagePicker _picker = ImagePicker();

  Future<void> _onImageButtonPressed(
    ImageSource source, {
    required BuildContext context,
  }) async {
    if (context.mounted) {
      await _displayPickImageDialog(context, false, (double? maxWidth,
          double? maxHeight, int? quality, int? limit) async {
        try {
          final XFile? pickedFile = await _picker.pickImage(
            source: source,
            maxWidth: maxWidth,
            maxHeight: maxHeight,
            imageQuality: quality,
          );
          setState(() {
            _setImageFileListFromFile(pickedFile);
          });
        } catch (e) {
          setState(() {
            _pickImageError = e;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    print(' dispose ');
    super.dispose();
  }

  Widget _previewImages() {
    final Text? retrieveError = _getRetrieveErrorWidget();
    if (retrieveError != null) {
      return retrieveError;
    }
    if (_mediaFileList != null) {
      return displayPickImageConfirmDialog();
    } else if (_pickImageError != null) {
      return Text(
        'Pick image error: $_pickImageError',
        textAlign: TextAlign.center,
      );
    } else {
      return getPageButtons();
    }
  }

  Widget getPreview() {
    return Semantics(
      label: 'image_picker_example_picked_image',
      child: _mediaFileList != null && _mediaFileList!.isNotEmpty
          ? Image.file(
              File(_mediaFileList![0].path), // Exibe apenas a primeira imagem
              errorBuilder:
                  (BuildContext context, Object error, StackTrace? stackTrace) {
                return const Center(
                  child: Text('This image type is not supported'),
                );
              },
            )
          : const Center(
              child: Text(
                  'No image selected'), // Mensagem caso a lista esteja vazia
            ),
    );
  }

  // Widget getConfirmPreview(index) {
  //   print('getImagePreviewConfirm');
  //   return
  // }

  Widget _handlePreview() {
    return _previewImages();
  }

  Future<void> retrieveLostData() async {
    final LostDataResponse response = await _picker.retrieveLostData();
    if (response.isEmpty) {
      return;
    }
    if (response.file != null) {
      isVideo = false;
      setState(() {
        if (response.files == null) {
          _setImageFileListFromFile(response.file);
        } else {
          _mediaFileList = response.files;
        }
      });
    } else {
      _retrieveDataError = response.exception!.code;
    }
  }

  Widget getPageButtons() {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      const Text(
        'Selecione a peça de roupa desejada',
        style: TextStyle(fontSize: 18, color: Colors.black54),
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 40),
      CustomButton(
        text: 'Carregar\nda galeria',
        color: const Color(0xFF6B4C7A),
        onPressed: () {
          print(' press button 2');
          _onImageButtonPressed(ImageSource.gallery, context: context);
          // Handle "Carregar da galeria" button press
        },
      ),
      const SizedBox(height: 20),
      CustomButton(
        text: 'Carregar\nda camera',
        color: const Color(0xFF4C3F58),
        onPressed: () {
          _onImageButtonPressed(ImageSource.camera, context: context);
        },
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Peça de roupa'),
        ),
        body: Center(
          child: defaultTargetPlatform == TargetPlatform.android
              ? FutureBuilder<void>(
                  future: retrieveLostData(),
                  builder:
                      (BuildContext context, AsyncSnapshot<void> snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.none:
                      case ConnectionState.waiting:
                        print('wating');
                        return getPageButtons();
                      case ConnectionState.done:
                        return _handlePreview();
                      case ConnectionState.active:
                        print('acTIVE');
                        if (snapshot.hasError) {
                          return Text(
                            'Pick image/video error: ${snapshot.error}}',
                            textAlign: TextAlign.center,
                          );
                        } else {
                          return getPageButtons();
                        }
                    }
                  },
                )
              : _handlePreview(),
        ));
  }

  Text? _getRetrieveErrorWidget() {
    if (_retrieveDataError != null) {
      final Text result = Text(_retrieveDataError!);
      _retrieveDataError = null;
      return result;
    }
    return null;
  }

  Future<void> _displayPickImageDialog(
      BuildContext context, bool isMulti, OnPickImageCallback onPick) async {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Add optional parameters'),
            content: const Text(' confirmar? '),
            actions: <Widget>[
              TextButton(
                child: const Text('CANCEL'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                  child: const Text('PICK'),
                  onPressed: () {
                    onPick(null, null, null, 1);
                    Navigator.of(context).pop();
                  }),
            ],
          );
        });
  }

  Widget displayPickImageConfirmDialog() {
    return AlertDialog(
      title: const Text('Confirma seleção da imagem abaixo?'),
      content: getPreview(),
      actions: <Widget>[
        TextButton(
          child: const Text('CANCEL'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
            child: const Text('CONFIRM'),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const PosePage()));
            }),
      ],
    );
  }
}

typedef OnPickImageCallback = void Function(
    double? maxWidth, double? maxHeight, int? quality, int? limit);
