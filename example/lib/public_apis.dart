import 'package:flutter/material.dart';

import 'package:flutter_flurry_sdk/flurry.dart';


class PublicAPIPage extends StatefulWidget {
  PublicAPIPage({Key key, this.title}) : super(key: key);

  static const String routeName = "/PublicAPIPage";

  final String title;

  @override
  _PublicAPIPageState createState() => new _PublicAPIPageState();
}

class _PublicAPIPageState extends State<PublicAPIPage> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
      ),
      body: Center(
        child: Container(
          width: 360,
          margin: EdgeInsets.all(10),
          child: Column(
            children: <Widget>[
              MaterialButton(
                  height: 40.0,
                  minWidth: 350,
                  color: Colors.white,
                  textColor: Colors.blue,
                  child: Text(
                    "Set Gender",
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.left,
                  ),
                  onPressed: () {
                    setGender();
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      duration: const Duration(seconds: 1),
                      content: Text("Set gender to female successfully"),
                    ));
                  },
                  splashColor: Colors.blueAccent,
                ),
              MaterialButton(
                height: 40.0,
                minWidth: 350,
                color: Colors.white,
                textColor: Colors.blue,
                child: Text(
                  "Set Age",
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.left,
                ),
                onPressed: () {
                  setAge();
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    duration: const Duration(seconds: 1),
                    content: Text("Set age to 30 successfully"),
                  ));
                },
                splashColor: Colors.blueAccent,
              ),
              MaterialButton(
                height: 40.0,
                minWidth: 350,
                color: Colors.white,
                textColor: Colors.blue,
                child: Text(
                  "Set Session Origin",
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.left,
                ),
                onPressed: () {
                  setSessionOrigin();
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    duration: const Duration(seconds: 1),
                    content: Text("Set session origin: \"testOrigin\" successfully"),
                  ));
                },
                splashColor: Colors.blueAccent,
              ),
              MaterialButton(
                height: 40.0,
                minWidth: 350,
                color: Colors.white,
                textColor: Colors.blue,
                child: Text(
                  "Set User Id",
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.left,
                ),
                onPressed: () {
                  setUserId();
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    duration: const Duration(seconds: 1),
                    content: Text("Set user id to \"FlutterTest\" successfully"),
                  ));
                },
                splashColor: Colors.blueAccent,
              ),
              MaterialButton(
                height: 40.0,
                minWidth: 350,
                color: Colors.white,
                textColor: Colors.blue,
                child: Text(
                  "Set App Version",
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.left,
                ),
                onPressed: () {
                  setVersionName();
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    duration: const Duration(seconds: 1),
                    content: Text("Set App version to 1.0 successfully"),
                  ));
                },
                splashColor: Colors.blueAccent,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void setGender() {
    Flurry.setGender(Gender.female);
  }

  void setAge() {
    Flurry.setAge(30);
  }

  void setSessionOrigin() {
    Flurry.setSessionOrigin("testOrigin", "https://dev.flurry.com/");
  }

  void setUserId() {
    Flurry.setUserId("FlutterTest");
  }

  void setVersionName() {
    Flurry.setVersionName("1.0");
  }
}