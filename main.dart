import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'package:flutter/foundation.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
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
  final StreamController<String> _nameController = StreamController<String>();
  final StreamController<String> _imgController = StreamController<String>();

  @override
  void dispose() {
    _nameController.close();
    _imgController.close();
    super.dispose();
  }

  @override
  var surceImg = "";
  var surceName = 'Найменування товару';
  Future<String> _getAllSurse() async {
    String qrResult = await BarcodeScanner.scan();
    final response = await http.get('https://api.listex.info/v3/product?apikey=lq6y6ib2jvxjfzku&gtin='+qrResult);
    var rest = utf8.decode(response.bodyBytes);
    _imgController.sink.add(jsonDecode(rest)['result'][0]['good_img']);
    _nameController.sink.add(jsonDecode(rest)['result'][0]['good_name']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("QR scaner"),
        backgroundColor: Colors.black45,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,

        children: <Widget>[
          StreamBuilder<String>(
            initialData: "Відскануй код товару",
            stream: _nameController.stream,
              builder: (BuildContext context, AsyncSnapshot<String> snapshot){
                return Text(snapshot.data, style: new TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                );
              }),
          StreamBuilder<String>(
            initialData: '',
            stream: _imgController.stream,
            builder: (BuildContext context, AsyncSnapshot<String> snapshot){
              return new Image.network(snapshot.data, width: 300.0, height: 300.0,);
            },
          ),
          Wrap( children: <Widget>[
            ButtonTheme(minWidth: 40.0,
              child: RaisedButton(onPressed: _getAllSurse,
                color: Colors.black45,
                child: Icon(Icons.search),
              ),
            )
          ],

          ),

        ],
      ),
    );
  }
}
