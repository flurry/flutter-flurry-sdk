// Copyright 2022, Yahoo Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter_flurry_sdk/flurry.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    // Init and run Flurry APIs.
    FlurryExample.init();
    FlurryExample.example();
    FlurryExample.config();
    FlurryExample.publisherSegmentation();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Flutter example for Flurry SDK'),
        ),
        body: Center(
          child: Text('Flutter Plugin for Flurry SDK started.'),
        ),
      ),
    );
  }
}

class FlurryExample {
  static const String FLURRY_ANDROID_API_KEY = 'C9R699NJWSMJVPQWJ273';
  static const String FLURRY_IOS_API_KEY     = 'RPBHT5CJFFJ9WCS3C5R6';

  /// Init Flurry once as early as possible recommended in main.dart.
  /// For each platform (Android, iOS) where the app runs you need to acquire a unique Flurry API Key.
  /// i.e., you need two API keys if you are going to release the app on both Android and iOS platforms.
  /// If you are building for TV platforms, you will need two API keys for Android TV and tvOS.
  static void init() {
    Flurry.builder
        .withCrashReporting(true)
        .withLogEnabled(true)
        .withLogLevel(LogLevel.debug)
        .withMessaging(true, MyMessagingListener())
        .build(
            androidAPIKey: FLURRY_ANDROID_API_KEY,
                iosAPIKey: FLURRY_IOS_API_KEY);
  }

  /// Set, get, log Flurry events in anywhere of your codes.
  static void example() async {
    // Example to get Flurry versions.
    int agentVersion = await Flurry.getAgentVersion();
    print('Agent Version: $agentVersion');

    String? releaseVersion = await Flurry.getReleaseVersion();
    print('Release Version: $releaseVersion');

    String? sessionId = await Flurry.getSessionId();
    print('Session Id: $sessionId');

    // Set Flurry preferences.
    Flurry.setLogEnabled(true);
    Flurry.setLogLevel(LogLevel.verbose);

    // Set user preferences.
    Flurry.setAge(36);
    Flurry.setGender(Gender.female);
    Flurry.setReportLocation(true);

    // Set user properties.
    var list = <String>[];
    for (int i = 0; i < 6; i++) {
      list.add('prop$i');
    }
    Flurry.userProperties
        .setValue(UserProperties.propertyRegisteredUser, 'True');
    Flurry.userProperties.addValues('Flutter Properties', list);

    // Log Flurry events.
    Flurry.logEvent('Flutter Event');
    var map = <String, String>{};
    for (int i = 0; i < 6; i++) {
      map.putIfAbsent('key$i', () => '$i');
    }
    Flurry.logTimedEventWithParameters('Flutter Timed Event', map, true);
    Flurry.endTimedEvent('Flutter Timed Event');

    // Log Flurry standard events.
    var paramBuilder = Param()
        .putDoubleParam(EventParam.totalAmount, 34.99)
        .putBooleanParam(EventParam.success, true)
        .putStringParam(EventParam.itemName, 'book 1')
        .putString('note', 'This is an awesome book to purchase !!!');
    Flurry.logStandardEvent(FlurryEvent.purchased, paramBuilder);
  }

  /// Example to get Flurry Remote Configurations.
  static void config() {
    Flurry.config.registerListener(MyConfigListener());
    Flurry.config.fetchConfig();
  }

  /// Example to get Flurry Publisher Segmentation.
  static void publisherSegmentation() {
    Flurry.publisherSegmentation
        .registerListener(MyPublisherSegmentationListener());
    Flurry.publisherSegmentation.fetch();
  }
}

/// Listener for Flurry Remote Configurations
class MyConfigListener with ConfigListener {
  @override
  void onFetchSuccess() {
    // Data fetched, activate it.
    Flurry.config.activateConfig();
  }

  @override
  void onFetchNoChange() {
    // Fetch finished, but data unchanged.
    Flurry.config
        .getConfigString('welcome_message', 'Welcome')
        .then((welcomeMessage) {
      print('Received unchanged data: $welcomeMessage');
    });
  }

  @override
  void onFetchError(bool isRetrying) {
    // Fetch failed.
    print('Fetch error! Retrying: $isRetrying');
  }

  @override
  void onActivateComplete(bool isCache) {
    // Received cached data, or newly activated data.
    Flurry.config
        .getConfigString('welcome_message', 'Welcome')
        .then((welcomeMessage) {
      print((isCache
          ? 'Received cached data: $welcomeMessage'
          : 'Received newly activated data: $welcomeMessage'));
    });
  }
}

/// To enable Flurry Push for Android, please duplicate Builder setup in your FlutterApplication.java.
/// ```dart
///   Flurry.builder
///       .withMessaging(true)
///       ...
/// ```
/// Optionally add a listener to receive messaging events, and handle the notification.
/// ```dart
///   Flurry.builder
///       .withMessaging(true, MyMessagingListener())
///       ...
/// ```
class MyMessagingListener with MessagingListener {
  @override
  bool onNotificationClicked(Message message) {
    printMessage('onNotificationClicked', message);
    return false;
  }

  @override
  bool onNotificationReceived(Message message) {
    printMessage('onNotificationReceived', message);
    return false;
  }

  @override
  void onNotificationCancelled(Message message) {
    printMessage('onNotificationCancelled', message);
  }

  @override
  void onTokenRefresh(String token) {
    print('Flurry Messaging Type: onTokenRefresh'
        '\n    Token: $token');
  }

  static printMessage(String type, Message message) {
    print('Flurry Messaging Type: $type'
        '\n    Title: ${message.title}'
        '\n    Body: ${message.body}'
        '\n    ClickAction: ${message.clickAction}'
        '\n    Data: ${message.appData}');
  }
}

/// Listener for Flurry Publisher Segmentation
class MyPublisherSegmentationListener with PublisherSegmentationListener {
  @override
  void onFetched(Map<String, String> data) {
    print('Publisher Segmentation data fetched: $data');
  }
}
