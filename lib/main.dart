import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  int _total = 0, _received = 0;
  http.StreamedResponse _response;
  List<int> _bytes = [];
  Uint8List _image;

  Future<void> _downloadImage() async {
    _response = await http.Client().send(http.Request('GET',
        Uri.parse("https://upload.wikimedia.org/wikipedia/commons/f/ff/Pizigani_1367_Chart_10MB.jpg")));
    _total = _response.contentLength;

    print("listenting to stream");
    _response.stream.listen((value) {
      setState(() {
        print("received: ${value.length}");
        _bytes.addAll(value);
        _received += value.length;
      });
    }).onDone(() async {
      setState(() {
        _image = Uint8List.fromList(_bytes);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        label: Text("${_received ~/ 1024}/${_total ~/ 1024} KB"),
        icon: Icon(Icons.file_download),
        onPressed: _downloadImage,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: SizedBox.fromSize(
            size: Size(400, 300),
            child: _image == null ? Placeholder() : Image.memory(_image, fit: BoxFit.fill),
          ),
        ),
      ),
    );
  }
}

