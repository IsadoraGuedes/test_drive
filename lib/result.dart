import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:test_drive/api/api.dart';
import 'package:http/http.dart' as http;

class ResultPage extends StatefulWidget {
  final XFile? clothImage;
  final XFile? personImage;

  const ResultPage(
      {super.key, required this.clothImage, required this.personImage});

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  late Future<String> hello;
  late XFile? clothImage;
  late XFile? personImage;
  String? message = "";

  @override
  void initState() {
    super.initState();
    print('before call');
    hello = fetchCall();
    print(hello);

    clothImage = widget.clothImage;
    personImage = widget.personImage;

    uploadImage();
  }

  uploadImage() async {
    final request = http.MultipartRequest(
        "POST", Uri.parse("http://192.168.15.8:3000/upload"));

    final headers = {"Content-type": "multipart/form-data"};

    final File convert = File(clothImage!.path);

    request.files.add(http.MultipartFile(
        'image', clothImage!.readAsBytes().asStream(), convert.lengthSync(),
        filename: convert.path.split("/").last));

    request.headers.addAll(headers);

    final response = await request.send();

    http.Response res = await http.Response.fromStream(response);
    final resJson = jsonDecode(res.body);
    message = resJson['message'];
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Peça de roupa'),
        ),
        body: const Center(
          child: Text('teste loading'),
        ));
  }
}
