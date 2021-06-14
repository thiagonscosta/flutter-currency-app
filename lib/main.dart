import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

var url = Uri.parse('https://api.hgbrasil.com/finance');

void main() async {
  runApp(MaterialApp(
    home: Home(),
    theme: ThemeData(
      hintColor: Colors.white,
      primaryColor: Colors.white,
      inputDecorationTheme: InputDecorationTheme(
        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
        hintStyle: TextStyle(color: Colors.white),
      )
    )
  ));
}

Future<Map> getData() async {
  http.Response response = await http.get(url);
  return json.decode(response.body);
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();

  void _clear() {
    realController.text = "";
    dolarController.text = "";
    euroController.text = "";
  }
  
  void _realChanged(String value) {
    if (value.isEmpty) {
      this._clear();
      return;
    }
    double real = double.parse(value);
    dolarController.text = (real/_dolar).toStringAsFixed(2);
    euroController.text = (real/_euro).toStringAsFixed(2);
  }

  void _dolarChanged(String value) {
    if (value.isEmpty) {
      this._clear();
      return;
    }
    double dolar = double.parse(value);
    realController.text = (dolar * this._dolar).toStringAsFixed(2);
    euroController.text = ((dolar * this._dolar) / this._euro).toStringAsFixed(2);
  }

  void _euroChanged(String value) {
    if (value.isEmpty) {
      this._clear();
    }
    double euro = double.parse(value);
    realController.text = (euro * this._euro).toStringAsFixed(2);
    dolarController.text = ((euro/this._euro) / this._dolar).toStringAsFixed(2);
  }
  
  double _dolar;
  double _euro;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('\$ Conversor \$', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        centerTitle: true,
      ),
      body: FutureBuilder<Map>(
          future: getData(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
                return Center(
                    child: Text(
                  "Waiting...",
                  style: TextStyle(color: Colors.white, fontSize: 25.0),
                  textAlign: TextAlign.center,
                ));
              default:
                if (snapshot.hasError) {
                  return Center(
                      child: Text("Ops! An error has occurred",
                          style: TextStyle(color: Colors.white, fontSize: 25.0),
                          textAlign: TextAlign.center));
                } else {
                    _dolar = snapshot.data["results"]["currencies"]["USD"]["buy"];
                    _euro = snapshot.data["results"]["currencies"]["EUR"]["buy"];

                    return SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Icon(Icons.monetization_on, size: 150.0, color: Colors.white),
                          _buildTextField("Reais", "R\$", realController, _realChanged),
                          Divider(),
                          _buildTextField("Dolars", "US\$", dolarController, _dolarChanged),
                          Divider(),
                          _buildTextField("Euros", "€", euroController, _euroChanged),
                        ],
                      ),
                    );
                }
            }
          }),
    );
  }
}

Widget _buildTextField(String l, String p, TextEditingController c, Function f) {
  return TextField(
      decoration: InputDecoration(
        labelText: l,
        labelStyle: TextStyle(color: Colors.white),
        border: OutlineInputBorder(),
        prefixText: p,
      ),
      style: TextStyle(color: Colors.white, fontSize: 25.0),
    controller: c,
    onChanged: f,
    keyboardType: TextInputType.number,
  );
}
