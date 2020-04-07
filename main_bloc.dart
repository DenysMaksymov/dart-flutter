import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'package:flutter/foundation.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_bloc/flutter_bloc.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: BlocProvider(
        child: MyHomePage(),
        create: (String) => GetImgBloc(),
      )
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
          BlocBuilder<GetImgBloc, String>(
            builder: (_, imgSours){
              return Center(
                child: Image.network('$imgSours'),
              );
            },
          ),
          Wrap( children: <Widget>[
            ButtonTheme(minWidth: 40.0,
              child: RaisedButton(onPressed: () =>
                  context.bloc<GetImgBloc>().add(SearchEvent.search),
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
enum SearchEvent { search }

class GetImgBloc extends Bloc<SearchEvent, String> {
  @override
  String get initialState => '';

  @override
  Stream<String> mapEventToState(SearchEvent event) async* {
    String qrResult = await BarcodeScanner.scan();
    var response = await http.get('https://api.listex.info/v3/product?apikey=lq6y6ib2jvxjfzku&gtin='+qrResult);
    var rest = utf8.decode(response.bodyBytes);
    var imgSours = jsonDecode(rest)['result'][0]['good_img'];
    print(state);
    switch (event) {
      case SearchEvent.search:
        yield imgSours;
        break;
    }
    }
  }



