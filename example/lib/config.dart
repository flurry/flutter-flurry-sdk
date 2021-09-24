import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter_flurry_sdk/flurry.dart';


class ConfigPage extends StatefulWidget {
  ConfigPage({Key key, this.title}) : super(key: key);

  static const String routeName = "/ConfigPage";

  final String title;

  @override
  _ConfigPageState createState() => new _ConfigPageState();
}

class _ConfigPageState extends State<ConfigPage> with ConfigListener {

  Color _color;
  bool _listenerRegistered = false;

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    super.dispose();
  }

  @override
  void initState(){
    getActivcatedColor().then((data) => setState((){
      _color = data;
    }));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
      ),
      body: Center(
        child: Container(
          color: Colors.white,
          margin: EdgeInsets.all(10),
          width: 340,
          child: Column(
            children: <Widget>[
              MaterialButton(
                height: 40.0,
                minWidth: 300,
                color: _color,
                textColor: Colors.blue,
                child: Text(
                  "Register Config Listener",
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.left,
                ),
                onPressed: () {
                  if(!_listenerRegistered){
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      duration: const Duration(seconds: 1),
                      content: Text("Listener was successfully registered"),
                    ));
                    _listenerRegistered = !_listenerRegistered;
                    Flurry.config.registerListener(this);
                  }else{
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      duration: const Duration(seconds: 1),
                      content: Text("Listener has already been registered"),
                    ));
                  }
                },
                splashColor: Colors.blueAccent,
              ),
              MaterialButton(
                height: 40.0,
                minWidth: 300,
                color: _color,
                textColor: Colors.blue,
                child: Text(
                  "Fetch Config",
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.left,
                ),
                onPressed: () {
                  Flurry.config.fetchConfig();
                },
                splashColor: Colors.blueAccent,
              ),
              MaterialButton(
                height: 40.0,
                minWidth: 300,
                color: Colors.white,
                textColor: Colors.blue,
                child: Text(
                  "Reset",
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.left,
                ),
                onPressed: () {
                  setState(() {
                    _color = Colors.white;
                  });
                },
                splashColor: Colors.blueAccent,
              ),
            ],
          ),

        ),
      ),
    );
  }

  @override
  void onActivateComplete(bool isCache) {
    // TODO: implement activated
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      duration: const Duration(seconds: 1),
      content: Text("Fetch activated"),
    ));
    getActivcatedColor().then((data) => setState((){
      _color = data;
    }));
  }

  @override
  void onFetchSuccess() {
    // TODO: implement fetchComplete
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      duration: const Duration(seconds: 1),
      content: Text("Fetch completed"),
    ));
    Flurry.config.activateConfig();
  }

  @override
  void onFetchNoChange() {
    // TODO: implement fetchCompleteNoChnage
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      duration: const Duration(seconds: 1),
      content: Text("Fetch completed with no change"),
    ));
    getActivcatedColor().then((data) => setState((){
      _color = data;
    }));
  }

  @override
  void onFetchError(bool isRetrying){
    // TODO: implement fetchFail
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      duration: const Duration(seconds: 1),
      content: Text("Fetch failed"),
    ));
  }

  Future<Color> getActivcatedColor() async{
    String value = await Flurry.config.getConfigString('bgColor', '#ffffff');
    Color color = _getColorFromHex(value);
    return color;
  }

  Color _getColorFromHex(String hexColor) {
    hexColor = hexColor.replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    if (hexColor.length == 8) {
      return Color(int.parse("0x$hexColor"));
    }
  }
}