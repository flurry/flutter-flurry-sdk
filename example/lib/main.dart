import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_flurry_sdk/flurry.dart';

import 'analytics.dart';
import 'user_properties.dart';
import 'config.dart';
import 'public_apis.dart';


void main() => runApp(new MyApp());

class MyApp extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    var routes = <String, WidgetBuilder>{
      UserPropertiesPage.routeName: (BuildContext context) => new UserPropertiesPage(title: "User Properties"),
      PublicAPIPage.routeName: (BuildContext context) => new PublicAPIPage(title: "Public APIs"),
      AnalyticsPage.routeName: (BuildContext context) => new AnalyticsPage(title: "Analytics"),
      ConfigPage.routeName: (BuildContext context) => new ConfigPage(title: "Config"),
    };
    return new MaterialApp(
      title: 'Flutter Test',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(title: 'Flutter Test Home'),
      routes: routes,
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with MessagingListener, PublisherSegmentationListener{
  String _platformVersion = 'Unknown';

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      Flurry.builder.withLogEnabled(true)
          .withLogLevel(LogLevel.verbose)
          .withCrashReporting(true)
          .withAppVersion("1.0.0")
          .withIncludeBackgroundSessionsInMetrics(true)
          .withMessaging(true, this)
          .build(androidAPIKey: 'C9R699NJWSMJVPQWJ273',
                 iosAPIKey: 'RPBHT5CJFFJ9WCS3C5R6');

      // ios test config use - RPBHT5CJFFJ9WCS3C5R6
      // ios use default - VSWDMD4N49ZZ8ZNWWVCB
      // android use default - C9R699NJWSMJVPQWJ273

      // Flurry.openPrivacyDashboard();
      Param paramBuilder = new Param();
      paramBuilder.putStringParam(EventParam.userId, '12345');
      paramBuilder.putStringParam(EventParam.contentName, 'flutter test app');
      paramBuilder.putDouble('double', 1.2345);
      paramBuilder.removeParam(EventParam.userId);
      Flurry.logStandardEvent(FlurryEvent.login, paramBuilder);

      Flurry.publisherSegmentation.registerListener(this);
      Flurry.publisherSegmentation.fetch();

    } on PlatformException {
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) {
      return null;
    }

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
      ),
      body: Center(
        child: Container(
          margin: EdgeInsets.all(20),
          child: Column(
            children: <Widget>[
              Card(
                elevation: 10,
                child: MaterialButton(
                  height: 50.0,
                  minWidth: 300.0,
                  color: Colors.white,
                  textColor: Colors.blue,
                  child: Text(
                    "Analytics",
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.left,
                  ),
                  onPressed: () => {
                    _onAnalyticsButtonPressed()
                  },
                  splashColor: Colors.blueAccent,
                ),
              ),
              Card(
                elevation: 10,
                child: MaterialButton(
                  height: 50.0,
                  minWidth: 300.0,
                  color: Colors.white,
                  textColor: Colors.blue,
                  child: Text(
                    "Config",
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.left,
                  ),
                  onPressed: () => {
                    _onConfigButtonPressed()
                  },
                  splashColor: Colors.blueAccent,
                ),
              ),
              Card(
                elevation: 10,
                child: MaterialButton(
                  height: 50.0,
                  minWidth: 300.0,
                  color: Colors.white,
                  textColor: Colors.blue,
                  child: Text(
                    "User Property",
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.left,
                  ),
                  onPressed: () => {
                    _onUserPropertiesButtonPressed()
                  },
                  splashColor: Colors.blueAccent,
                ),
              ),
              Card(
                elevation: 10,
                child: MaterialButton(
                  height: 50.0,
                  minWidth: 300.0,
                  color: Colors.white,
                  textColor: Colors.blue,
                  child: Text(
                    "Public APIs",
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.left,
                  ),
                  onPressed: () => {
                    _onPublicButtonPressed()
                  },
                  splashColor: Colors.blueAccent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onAnalyticsButtonPressed() {
    Navigator.pushNamed(context, AnalyticsPage.routeName);
  }

  void _onConfigButtonPressed() {
    Navigator.pushNamed(context, ConfigPage.routeName);
  }

  void _onUserPropertiesButtonPressed() {
    Navigator.pushNamed(context, UserPropertiesPage.routeName);
  }

  void _onPublicButtonPressed() {
    Navigator.pushNamed(context, PublicAPIPage.routeName);
  }

  @override
  bool onNotificationClicked(Message message){
    // TODO: implement didReceiveAction
    print("push action callback!");
    return false;
  }

  @override
  bool onNotificationReceived(Message message){
    // TODO: implement didReceiveMessage
    print("push receive callback!");
    return false;
  }

  @override
  void onNotificationCancelled(Message message) {
    // TODO: implement onNotificationCancelled
  }

  @override
  void onTokenRefresh(String token){
    // TODO: implement onTokenRefresh
  }

  @override
  void onFetched(Map<String, String> data){
    print("PS onFetched");
  }
}
