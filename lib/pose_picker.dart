// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:test_drive/main.dart';
import 'package:test_drive/result.dart';

class PosePage extends StatefulWidget {
  const PosePage({super.key});

  @override
  State<PosePage> createState() => _PosePageState();
}

class _PosePageState extends State<PosePage> {
  XFile? _image;

  void _setImageFileListFromFile(XFile? value) {
    _image = value;
  }

  dynamic _pickImageError;

  String? _retrieveDataError;

  final ImagePicker _picker = ImagePicker();

  Future<void> _onImageButtonPressed(
    ImageSource source, {
    required BuildContext context,
  }) async {
    if (context.mounted) {
      try {
        final XFile? pickedFile = await _picker.pickImage(
          source: source,
          // maxWidth: maxWidth,
          // maxHeight: maxHeight,
          // imageQuality: quality,
        );
        setState(() {
          _setImageFileListFromFile(pickedFile);
        });
      } catch (e) {
        setState(() {
          _pickImageError = e;
        });
      }
    }
  }

  @override
  void dispose() {
    print(' dispose ');
    super.dispose();
  }

  Widget _handlePreview() {
    final Text? retrieveError = _getRetrieveErrorWidget();
    if (retrieveError != null) {
      return retrieveError;
    }
    if (_image != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          builder: (BuildContext context) => displayPickImageConfirmDialog(),
        );
      });
      return Container();
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
      child: _image != null
          ? Image.file(
              File(_image!.path),
              errorBuilder:
                  (BuildContext context, Object error, StackTrace? stackTrace) {
                return const Center(
                  child: Text('This image type is not supported'),
                );
              },
            )
          : const Center(
              child: Text('No image selected'),
            ),
    );
  }

  Future<void> retrieveLostData() async {
    final LostDataResponse response = await _picker.retrieveLostData();
    if (response.isEmpty) {
      return;
    }
    if (response.file != null) {
      setState(() {
        if (response.files == null) {
          _setImageFileListFromFile(response.file);
        } else {
          //o que isso faz?
          _image = response.file;
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

  Widget displayPickImageConfirmDialog() {
    return AlertDialog(
      title: const Text('Confirmar seleção?'),
      elevation: 1,
      content: getPreview(),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancelar'),
          onPressed: () {
            setState(() {
              _image = null;
            });
            Navigator.of(context, rootNavigator: true).pop();
          },
        ),
        TextButton(
            child: const Text('Confirmar'),
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop();
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const ResultPage()));
            }),
      ],
    );
  }
}
