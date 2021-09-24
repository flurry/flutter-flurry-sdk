import 'package:flutter/material.dart';

import 'package:flutter_flurry_sdk/flurry.dart';


class AnalyticsPage extends StatefulWidget {
  AnalyticsPage({Key key, this.title}) : super(key: key);

  static const String routeName = "/AnalyticsPage";

  final String title;

  @override
  _AnalyticsPageState createState() => new _AnalyticsPageState();
}

/// // 1. After the page has been created, register it with the app routes
/// routes: <String, WidgetBuilder>{
///   MyItemsPage.routeName: (BuildContext context) => new MyItemsPage(title: "MyItemsPage"),
/// },
///
/// // 2. Then this could be used to navigate to the page.
/// Navigator.pushNamed(context, MyItemsPage.routeName);
///

class _AnalyticsPageState extends State<AnalyticsPage> {

  final myController1 = TextEditingController();
  final myController2 = TextEditingController();
  final myController3 = TextEditingController();

  int timedEventId = 0;

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    myController1.dispose();
    myController2.dispose();
    myController3.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
      ),
      body: Center(
        child: Container(
          margin: EdgeInsets.all(10),
          width: 340,
          child: Column(
            children: <Widget>[
              Card(
                elevation: 5,
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      width: 300,
                      child: TextField(
                        controller: myController1,
                        decoration: InputDecoration(
                          border: new UnderlineInputBorder(
                            borderSide: new BorderSide(
                              color: Colors.blue,
                            ),
                          ),
                          hintText: 'Event Name',
                          labelText: "Event Name",
                          contentPadding: const EdgeInsets.symmetric(vertical: 2, horizontal: 10),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 300,
                      child: TextField(
                        controller: myController2,
                        decoration: InputDecoration(
                          border: new UnderlineInputBorder(
                            borderSide: new BorderSide(
                              color: Colors.blue,
                            ),
                          ),
                          hintText: 'Param Count',
                          labelText: 'Number of Parameters',
                          contentPadding: const EdgeInsets.symmetric(vertical: 2, horizontal: 10),
                        ),
                      ),
                    ),
                    MaterialButton(
                      height: 40.0,
                      minWidth: 300,
                      color: Colors.white,
                      textColor: Colors.blue,
                      child: Text(
                        "Log Event",
                        style: TextStyle(fontSize: 16),
                        textAlign: TextAlign.left,
                      ),
                      onPressed: () {
                        if(myController1.text == null ||
                            myController1.text.length == 0 ||
                            (myController2.text != null && myController2.text.length > 0 && !isInt(myController2.text))){
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            duration: const Duration(seconds: 1),
                            content: Text("Enter a valid event name or number of params"),
                          ));
                        }else{
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            duration: const Duration(seconds: 1),
                            content: Text("Event logged"),
                          ));
                          p_logEvent(myController1.text, myController2.text);

                          myController1.clear();
                          myController2.clear();

                        }
                      },
                      splashColor: Colors.blueAccent,
                    ),
                    MaterialButton(
                      height: 40.0,
                      minWidth: 300,
                      color: Colors.white,
                      textColor: Colors.blue,
                      child: Text(
                        "Start Timed Event",
                        style: TextStyle(fontSize: 16),
                        textAlign: TextAlign.left,
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          duration: const Duration(seconds: 1),
                          content: Text("Event logged"),
                        ));
                        logTimedEvent();
                      },
                      splashColor: Colors.blueAccent,
                    ),
                    MaterialButton(
                      height: 40.0,
                      minWidth: 300,
                      color: Colors.white,
                      textColor: Colors.blue,
                      child: Text(
                        "End Timed Event",
                        style: TextStyle(fontSize: 16),
                        textAlign: TextAlign.left,
                      ),
                      onPressed: () {
                        if(timedEventId == 0){
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            duration: const Duration(seconds: 1),
                            content: Text("No timed event to end"),
                          ));
                        }else {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            duration: const Duration(seconds: 1),
                            content: Text("Event logged"),
                          ));
                          endTimedEvent();
                        }
                      },
                      splashColor: Colors.blueAccent,
                    ),
                    MaterialButton(
                      height: 40.0,
                      minWidth: 300,
                      color: Colors.white,
                      textColor: Colors.blue,
                      child: Text(
                        "Log Standard Event",
                        style: TextStyle(fontSize: 16),
                        textAlign: TextAlign.left,
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          duration: const Duration(seconds: 1),
                          content: Text("Standard event logged"),
                        ));
                        logStandardEvent();
                      },
                      splashColor: Colors.blueAccent,
                    ),
                  ],
                ),
              ),
              Card(
                elevation: 5,
                child: Column(
                  children: <Widget>[
                    MaterialButton(
                      height: 40.0,
                      minWidth: 300,
                      color: Colors.white,
                      textColor: Colors.blue,
                      child: Text(
                        "Log Error",
                        style: TextStyle(fontSize: 16),
                        textAlign: TextAlign.left,
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          duration: const Duration(seconds: 1),
                          content: Text("Error logged"),
                        ));
                        logError();
                      },
                      splashColor: Colors.blueAccent,
                    ),
                    MaterialButton(
                      height: 40.0,
                      minWidth: 300,
                      color: Colors.white,
                      textColor: Colors.blue,
                      child: Text(
                        "Log Error with Param",
                        style: TextStyle(fontSize: 16),
                        textAlign: TextAlign.left,
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          duration: const Duration(seconds: 1),
                          content: Text("Error logged"),
                        ));
                        logErrorWithParameters();
                      },
                      splashColor: Colors.blueAccent,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool isInt(String s) {
    if(s == null) {
      return false;
    }
    return double.parse(s, (e) => null) != null;
  }

  void p_logEvent(String name, String count){
    int c = 0;
    if(count != null && count.length > 0){
      double d = double.parse(count);
      c = d.floor();
    }
    if(c == 0){
      Flurry.logEvent(name);
      return;
    }
    Map<String, String> map = Map<String, String>();
    for(int i = 0; i < c; i++){
      map.putIfAbsent('$i', () => '$i');
    }
    Flurry.logEventWithParameters(name, map);
  }

  void logTimedEvent() {
    Flurry.logTimedEvent("Timed Event $timedEventId", true);
    timedEventId += 1;
  }

  void endTimedEvent() {
    Flurry.endTimedEvent("Timed Event $timedEventId");
    timedEventId -= 1;
  }

  void logError() {
    Exception exception = Exception('Something bad happened.');
    Flurry.onError("test exception", "Error just occurred", exception.toString());
  }

  void logErrorWithParameters() {
    Map<String, String> map = {'key1': 'value1', 'key2': 'value2', 'key3': 'value3', 'key4': 'value4'};
    Exception exception = Exception('Something bad happened.');
    Flurry.onErrorWithParameters("Test exception 2", "Something terrific happened", exception.toString(), map);
  }

  void logStandardEvent(){
    Param paramBuilder = new Param();
    paramBuilder.putDoubleParam(EventParam.price, 1.23);
    paramBuilder.putDoubleParam(EventParam.totalAmount, 123);
    paramBuilder.putInteger('quantity', 10);
    Flurry.logStandardEvent(FlurryEvent.purchased, paramBuilder);
  }
}