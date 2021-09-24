import 'package:flutter/material.dart';

import 'package:flutter_flurry_sdk/flurry.dart';


class UserPropertiesPage extends StatefulWidget {
  UserPropertiesPage({Key key, this.title}) : super(key: key);

  static const String routeName = "/UserPropertiesPage";

  final String title;

  @override
  _UserPropertiesPageState createState() => new _UserPropertiesPageState();
}

class _UserPropertiesPageState extends State<UserPropertiesPage> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
      ),
      body: Center(
        child: Container(
          margin: EdgeInsets.all(10),
          width: 360,
          child: Column(children: <Widget>[
            Card(
              elevation: 10,
              child: Column(
                children: <Widget>[
                  MaterialButton(
                    height: 40.0,
                    minWidth: 350,
                    color: Colors.white,
                    textColor: Colors.blue,
                    child: Text(
                      "Add User Property w/ One Value",
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.left,
                    ),
                    onPressed: () {
                      addUserPropertyWithValue();
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        duration: const Duration(seconds: 1),
                        content: Text("Add user propertyName: \"Test1\" and propertyValue: \"Property1\""),
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
                      "Add User Property w/ Values",
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.left,
                    ),
                    onPressed: () {
                      addUserPropertyWithValues();
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        duration: const Duration(seconds: 1),
                        content: Text("Add user propertyName: \"Test2\" and 4 propertyValues"),
                      ));
                    },
                    splashColor: Colors.blueAccent,
                  ),
                ],
              ),
            ),
            Card(
              elevation: 10,
              child: Column(
                children: <Widget>[
                  MaterialButton(
                    height: 40.0,
                    minWidth: 350,
                    color: Colors.white,
                    textColor: Colors.blue,
                    child: Text(
                      "Set User Property w/ One Value",
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.left,
                    ),
                    onPressed: () {
                      setUserProperyWithValue();
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        duration: const Duration(seconds: 1),
                        content: Text("Set user propertyName: \"Test3\" with propertyValue: \"Property2\""),
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
                      "Set User Property w/ Values",
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.left,
                    ),
                    onPressed: () {
                      setUserPropertyWithValues();
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        duration: const Duration(seconds: 1),
                        content: Text("Set user propertyName: \"Test4\" with 3 propertyValues"),
                      ));
                    },
                    splashColor: Colors.blueAccent,
                  ),
                ],
              ),
            ),
            Card(
              elevation: 10,
              child: Column(
                children: <Widget>[
                  MaterialButton(
                    height: 40.0,
                    minWidth: 350,
                    color: Colors.white,
                    textColor: Colors.blue,
                    child: Text(
                      "Remove User Property",
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.left,
                    ),
                    onPressed: () {
                      removeUserProperty();
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        duration: const Duration(seconds: 1),
                        content: Text("Remove user property: \"Test1\""),
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
                      "Remove User Property w/ One Value",
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.left,
                    ),
                    onPressed: () {
                      removeUserPropertyValue();
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        duration: const Duration(seconds: 1),
                        content: Text("Remove user propertyName: \"Test2\" with propertyValue: \"Property2\""),
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
                      "Remove User Property w/ Values",
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.left,
                    ),
                    onPressed: () {
                      removeUserPropertyValues();
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        duration: const Duration(seconds: 1),
                        content: Text("Remove user propertyName: \"Test2\" with propertyValues: \"Property1\", \"Property3\""),
                      ));
                    },
                    splashColor: Colors.blueAccent,
                  ),
                ],
              ),
            ),
            Card(
              elevation: 10,
              child: Column(
                children: <Widget>[
                  MaterialButton(
                    height: 40.0,
                    minWidth: 350,
                    color: Colors.white,
                    textColor: Colors.blue,
                    child: Text(
                      "Flag User Property",
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.left,
                    ),
                    onPressed: () {
                      flagUserProperty();
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        duration: const Duration(seconds: 1),
                        content: Text("Flag user propertyName: \"Test1\""),
                      ));
                    },
                    splashColor: Colors.blueAccent,
                  ),
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }


  void addUserPropertyWithValue() {
    Flurry.userProperties.addValue(UserProperties.propertyCurrencyPreference, "USD");
    Flurry.userProperties.addValue('Test1', 'Property1');
  }

  void addUserPropertyWithValues() {
    List<String> propertyValues = ['Property5', 'Property2', 'Property3', 'Property4'];
    Flurry.userProperties.addValues('Test2', propertyValues);
  }

  void setUserProperyWithValue() {
    Flurry.userProperties.setValue('Test3', 'Property2');
  }

  void setUserPropertyWithValues() {
    List<String> propertyValues = ['Property1', 'Property2', 'Property3'];
    Flurry.userProperties.setValues('Test4', propertyValues);
  }

  void removeUserProperty() {
    Flurry.userProperties.remove("Test1");
  }

  void removeUserPropertyValue() {
    Flurry.userProperties.removeValue('Test2', 'Property2');
  }

  void removeUserPropertyValues() {
    List<String> propertyValues = ['Property1', 'Property3'];
    Flurry.userProperties.removeValues('Test2', propertyValues);
  }

  void flagUserProperty() {
    Flurry.userProperties.flag('Test1');
  }
}