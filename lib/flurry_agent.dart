import 'dart:core';
import 'dart:io';
import 'package:flutter/services.dart';

import 'flurry.dart';

class FlurryAgent {

  static const MethodChannel _agentChannel = const MethodChannel('flurry_flutter_plugin');

  void setContinueSessionMillis(int sessionMillis) {
    if (Platform.isIOS) {
      int seconds = sessionMillis ~/ 1000;
      String secondsStr = seconds.toString();
      _agentChannel.invokeMethod('setContinueSessionMillis', <String, dynamic>{
        'secondsStr': secondsStr
      });
    } else if (Platform.isAndroid) {
      String sessionMillisStr = sessionMillis.toString();
      _agentChannel.invokeMethod('setContinueSessionMillis', <String, dynamic>{
        'sessionMillisStr': sessionMillisStr
      });
    }
  }

  void setCrashReporting(bool crashReporting) {
    _agentChannel.invokeMethod('setCrashReporting', <String, dynamic>{
      'crashReporting': crashReporting
    });
  }

  void setIncludeBackgroundSessionsInMetrics(bool includeBackgroundSessionsInMetrics) {
    _agentChannel.invokeMethod('setIncludeBackgroundSessionsInMetrics', <String, dynamic> {
      'includeBackgroundSessionsInMetrics': includeBackgroundSessionsInMetrics
    });
  }

  void setLogEnabled(bool enableLog) {
    _agentChannel.invokeMethod('setLogEnabled', <String, dynamic> {
      'enableLog': enableLog
    });
  }

  void setLogLevel(LogLevel logLevel) {
    int logLevelInt = Flurry().getLogLevel(logLevel);
    String logLevelStr = logLevelInt.toString();
    _agentChannel.invokeMethod('setLogLevel', <String, dynamic> {
      'logLevelStr': logLevelStr
    });
  }

  void setSslPinningEnabled(bool sslPinningEnabled) {
    if (Platform.isIOS) {
      print("Flurry iOS SDK does not implement setSslPinningEnabled method");
    } else {
      _agentChannel.invokeMethod('setSslPinningEnabled', <String, dynamic>{
        'sslPinningEnabled': sslPinningEnabled
      });
    }
  }

  void addOrigin(String originName, String originVersion) {
    _agentChannel.invokeMethod('addOrigin', <String, dynamic> {
      'originName': originName,
      'originVersion': originVersion
    });
  }

  void addOriginWithParameters(String originName, String originVersion, Map<String, String> originParameters) {
    String keysStr = keysToString(originParameters);
    String valuesStr = valuesToString(originParameters);
    _agentChannel.invokeMethod('addOriginWithParameters', <String, dynamic> {
      'originName': originName,
      'originVersion': originVersion,
      'keysStr': keysStr,
      'valuesStr': valuesStr
    });
  }

  void addSessionProperty(String name, String value) {
    _agentChannel.invokeMethod('addSessionProperty', <String, dynamic> {
      'name': name,
      'value': value
    });
  }

  void deleteData() {
    _agentChannel.invokeMethod('deleteData');
  }

  void endTimedEvent(String eventId) {
    _agentChannel.invokeMethod('endTimedEvent', <String, dynamic>{
      'eventId': eventId
    });
  }

  void endTimedEventWithParameters(String eventId, Map<String, String> parameters) {
    String keysStr = keysToString(parameters);
    String valuesStr = valuesToString(parameters);
    _agentChannel.invokeMethod('endTimedEventWithParameters', <String, dynamic> {
      'eventId': eventId,
      'keysStr': keysStr,
      'valuesStr': valuesStr
    });
  }

  Future<int> getAgentVersion() async {
    return await _agentChannel.invokeMethod('getAgentVersion');
  }

  Future<String> getReleaseVersion() async {
    return await _agentChannel.invokeMethod('getReleaseVersion');
  }

  Future<String> getSessionId() async {
    return await _agentChannel.invokeMethod('getSessionId');
  }

  void logBreadcrumb(String crashBreadcrumb) {
    _agentChannel.invokeMethod('logBreadcrumb', <String, dynamic>{
      'crashBreadcrumb': crashBreadcrumb
    });
  }

  Future<int> logEvent(String eventId) async {
    return await _agentChannel.invokeMethod('logEvent', <String, dynamic>{
      'eventId': eventId
    });
  }

  Future<int> logEventWithParameters(String eventId, Map<String, String> parameters) async {
    String keysStr = keysToString(parameters);
    String valuesStr = valuesToString(parameters);
    return await _agentChannel.invokeMethod('logEventWithParameters', <String, dynamic> {
      'eventId': eventId,
      'keysStr': keysStr,
      'valuesStr': valuesStr
    });
  }

  Future<int> logPayment(String productName, String productId, int quantity,
      double price, String currency, String transactionId,
      Map<String, String> parameters) async {
    String keysStr = keysToString(parameters);
    String valuesStr = valuesToString(parameters);
    return await _agentChannel.invokeMethod('logPayment', <String, dynamic> {
      'productName': productName,
      'productId': productId,
      'quantity': quantity,
      'price': price,
      'currency': currency,
      'transactionId': transactionId,
      'keysStr': keysStr,
      'valuesStr': valuesStr
    });
  }

  Future<int> logTimedEvent(String eventId, bool timed) async {
    return await _agentChannel.invokeMethod('logTimedEvent', <String, dynamic> {
      'eventId': eventId,
      'timed': timed
    });
  }

  Future<int> logTimedEventWithParameters(String eventId,
      Map<String, String> parameters, bool timed) async {
    String keysStr = keysToString(parameters);
    String valuesStr = valuesToString(parameters);
    return await _agentChannel.invokeMethod('logTimedEventWithParameters',
        <String, dynamic> {
      'eventId': eventId,
      'keysStr': keysStr,
      'valuesStr': valuesStr,
      'timed': timed
    });
  }

  Future<int> logStandardEvent(FlurryEvent id, Param param) async {
    Map<int, String> flurryParamMap = new Map<int, String>();
    Map<String, String> userParamMap = new Map<String, String>();

    for (MapEntry<dynamic, String> e in param.builderAgent._map.entries) {
      // if user defined key
      if (e.key is String) {
        userParamMap.putIfAbsent(e.key, () => e.value);
      } else {
        ParamBase p = e.key as ParamBase;
        flurryParamMap.putIfAbsent(p.id.index, () => e.value);
      }
    }
    return await _agentChannel.invokeMethod('logStandardEvent', <String, dynamic>{
      'id' : id.index,
      'flurryParam': flurryParamMap,
      'userParam': userParamMap
    });
  }

  void onError(String errorId, String message, String errorClass) {
    _agentChannel.invokeMethod('onError', <String, dynamic> {
      'errorId': errorId,
      'message': message,
      'errorClass': errorClass
    });
  }

  void onErrorWithParameters(String errorId, String message, String errorClass,
      Map<String, String> parameters) {
    String keysStr = keysToString(parameters);
    String valuesStr = valuesToString(parameters);
    _agentChannel.invokeMethod('onErrorWithParameters', <String, dynamic> {
      'errorId': errorId,
      'message': message,
      'errorClass': errorClass,
      'keysStr': keysStr,
      'valuesStr': valuesStr
    });
  }

  void openPrivacyDashboard() {
    _agentChannel.invokeMethod('openPrivacyDashboard');
  }

  void setAge(int age) {
    String ageStr = age.toString();
    _agentChannel.invokeMethod('setAge', <String, dynamic> {
      'ageStr': ageStr,
    });
  }

  void setGender(Gender gender) {
    if (gender == Gender.male) {
      _agentChannel.invokeMethod('setGender', <String, dynamic> {
        'gender': "m"
      });
    } else if (gender == Gender.female) {
      _agentChannel.invokeMethod('setGender', <String, dynamic> {
        'gender': "f"
      });
    }
  }

  void setDataSaleOptOut(bool isOptOut) {
    _agentChannel.invokeMethod('setDataSaleOptOut', <String, dynamic> {
      'isOptOut': isOptOut
    });
  }

  void setIAPReportingEnabled(bool enableIAP) {
    _agentChannel.invokeMethod('setIAPReportingEnabled', <String, dynamic> {
      'enableIAP': enableIAP
    });
  }

  void setReportLocation(bool reportLocation) {
    if (Platform.isIOS) {
      print("This method is applied based on the user permissions of the app.");
    } else {
      _agentChannel.invokeMethod('setReportLocation', <String, dynamic> {
        'reportLocation': reportLocation
      });
    }
  }

  void setSessionOrigin(String originName, String deepLink) {
    _agentChannel.invokeMethod('setSessionOrigin', <String, dynamic> {
      'originName': originName,
      'deepLink': deepLink
    });
  }

  void setUserId(String userId) {
    _agentChannel.invokeMethod('setUserId', <String, dynamic>{
      'userId': userId
    });
  }

  void setVersionName(String versionName) {
    _agentChannel.invokeMethod('setVersionName', <String, dynamic>{
      'versionName': versionName
    });
  }

  void updateConversionValue(int conversionValue) {
    if (Platform.isIOS) {
      String conversionValueStr = conversionValue.toString();
      _agentChannel.invokeMethod(
          'updateConversionValue', <String, dynamic>{
        'conversionValueStr': conversionValueStr
      });
    }
  }

  void updateConversionValueWithEvent(SKAdNetworkEvent flurryEvent) {
    if (Platform.isIOS) {
      String flurryEventStr = flurryEvent.toString();
      _agentChannel.invokeMethod(
          'updateConversionValueWithEvent', <String, dynamic>{
        'flurryEventStr': flurryEventStr
      });
    }
  }

  //out or reference paramters are not possible in dart
  String keysToString(Map<String, String> map) {
    var keyStr = new StringBuffer();

    for(String key in map.keys) {
      keyStr.write(key);
      keyStr.write("\n");
    }
    if(keyStr.length > 0){
      var str = keyStr.toString();
      return str.substring(0, str.length - 1);
    }
    return keyStr.toString();
  }

  //out or reference parameters are not possible in dart.
  String valuesToString(Map<String, String> map) {
    var valueStr = new StringBuffer();

    for(String value in map.values) {
      valueStr.write(value);
      valueStr.write("\n");
    }
    if(valueStr.length > 0){
      var str = valueStr.toString();
      return str.substring(0, str.length - 1);
    }
    return valueStr.toString();
  }
}

class BuilderAgent {
  static const MethodChannel _agentBuilderChannel = const MethodChannel('flurry_flutter_plugin');

  //cannot have async call to objective c method from constructor
  BuilderAgent() {
    _agentBuilderChannel.invokeMethod('initializeFlurryBuilder');
  }

  void build(Map<String, dynamic> apiKeys) {
    String apiKey = "";
    if (Platform.isIOS) {
      apiKey = apiKeys["iosAPIKey"];
    } else if (Platform.isAndroid) {
      apiKey = apiKeys["androidAPIKey"];
    }
    _agentBuilderChannel.invokeMethod('buildFlurryBuilder', <String, dynamic> {
      'apiKey': apiKey,
    });
  }

  void withAppVersion(String appVersion) {
    _agentBuilderChannel.invokeMethod('withAppVersion', <String, dynamic> {
      'appVersion': appVersion
    });
  }

  void withContinueSessionMillis(int sessionMillis) {
    if (Platform.isIOS) {
      int seconds = sessionMillis ~/ 1000;
      String secondsStr = seconds.toString();
      _agentBuilderChannel.invokeMethod(
          'withContinueSessionMillis', <String, dynamic>{
        'secondsStr': secondsStr
      });
    } else if (Platform.isAndroid) {
      String sessionMillisStr = sessionMillis.toString();
      _agentBuilderChannel.invokeMethod(
          'withContinueSessionMillis', <String, dynamic>{
        'sessionMillisStr': sessionMillisStr
      });
    }
  }

  void withCrashReporting(bool crashReporting) {
    _agentBuilderChannel.invokeMethod('withCrashReporting', <String, dynamic>{
      'crashReporting': crashReporting
    });
  }

  void withDataSaleOptOut(bool isOptOut) {
    _agentBuilderChannel.invokeMethod('withDataSaleOptOut', <String, dynamic> {
      'isOptOut': isOptOut
    });
  }

  void withIncludeBackgroundSessionsInMetrics(bool includeBackgroundSessionsInMetrics) {
    _agentBuilderChannel.invokeMethod('withIncludeBackgroundSessionsInMetrics', <String, dynamic> {
      'includeBackgroundSessionsInMetrics': includeBackgroundSessionsInMetrics
    });
  }

  void withLogEnabled(bool enableLog) {
    _agentBuilderChannel.invokeMethod('withLogEnabled', <String, dynamic> {
      'enableLog': enableLog
    });
  }

  void withLogLevel(LogLevel logLevel) {
    int logLevelInt = Flurry().getLogLevel(logLevel);
    String logLevelStr = logLevelInt.toString();
    _agentBuilderChannel.invokeMethod('withLogLevel', <String, dynamic> {
      'logLevelStr': logLevelStr
    });
  }

  void withPerformanceMetrics(int performanceMetrics) {
    if (Platform.isIOS) {
      print("Flurry iOS SDK does not implement withPerformanceMetrics method");
    } else {
      _agentBuilderChannel.invokeMethod('withPerformanceMetrics', <String, dynamic>{
        'performanceMetrics': performanceMetrics
      });
    }
  }

  void withSslPinningEnabled(bool sslPinningEnabled) {
    if (Platform.isIOS) {
      print("Flurry iOS SDK does not implement withSslPinningEnabled method");
    } else {
      _agentBuilderChannel.invokeMethod('withSslPinningEnabled', <String, dynamic>{
        'sslPinningEnabled': sslPinningEnabled
      });
    }
  }
}

class UserPropertiesAgent {
  static const MethodChannel _agentUserPropertiesIOSChannel = const MethodChannel('flurry_flutter_plugin');

  void addUserPropertyValue(String propertyName, String propertyValue) {
    _agentUserPropertiesIOSChannel.invokeMethod('addUserPropertyValue', <String, dynamic> {
      'propertyName': propertyName,
      'propertyValue': propertyValue
    });
  }

  void addUserPropertyValues(String propertyName, List<String> propertyValues) {
    String propertyValuesStr = propertyValues.join('\n');
    _agentUserPropertiesIOSChannel.invokeMethod('addUserPropertyValues', <String, dynamic> {
      'propertyName': propertyName,
      'propertyValuesStr': propertyValuesStr
    });
  }

  void flagUserProperty(String propertyName) {
    _agentUserPropertiesIOSChannel.invokeMethod('flagUserProperty', <String, dynamic> {
      'propertyName': propertyName
    });
  }

  void removeUserProperty(String propertyName) {
    _agentUserPropertiesIOSChannel.invokeMethod('removeUserProperty', <String, dynamic> {
      'propertyName': propertyName
    });
  }

  void removeUserPropertyValue(String propertyName, String propertyValue) {
    _agentUserPropertiesIOSChannel.invokeMethod('removeUserPropertyValue', <String, dynamic> {
      'propertyName': propertyName,
      'propertyValue': propertyValue
    });
  }

  void removeUserPropertyValues(String propertyName, List<String> propertyValues) {
    String propertyValuesStr = propertyValues.join('\n');
    _agentUserPropertiesIOSChannel.invokeMethod('removeUserPropertyValues', <String, dynamic> {
      'propertyName': propertyName,
      'propertyValuesStr': propertyValuesStr
    });
  }

  void setUserPropertyValue(String propertyName, String propertyValue) {
    _agentUserPropertiesIOSChannel.invokeMethod('setUserPropertyValue', <String, dynamic> {
      'propertyName': propertyName,
      'propertyValue': propertyValue
    });
  }

  void setUserPropertyValues(String propertyName, List<String> propertyValues) {
    String propertyValuesStr = propertyValues.join('\n');
    _agentUserPropertiesIOSChannel.invokeMethod('setUserPropertyValues', <String, dynamic> {
      'propertyName': propertyName,
      'propertyValuesStr': propertyValuesStr
    });
  }
}

class PerformanceAgent {
  static const MethodChannel _agentPerformanceChannel = const MethodChannel('flurry_flutter_plugin');

  void reportFullyDrawn() {
    if (Platform.isIOS) {
      print("Flurry iOS SDK does not implemented ReportFullyDrawn method.");
    } else if (Platform.isAndroid) {
      _agentPerformanceChannel.invokeMethod('reportFullyDrawn');
    }
  }

  void startResourceLogger() {
    if (Platform.isIOS) {
      print("Flurry iOS SDK does not implement StartResourceLogger method.");
    } else if (Platform.isAndroid) {
      _agentPerformanceChannel.invokeMethod('startResourceLogger');
    }
  }

  void logResourceLogger(String id) {
    if (Platform.isIOS) {
      print("Flurry iOS SDK does not implement LogResourseLogger method.");
    } else if (Platform.isAndroid) {
      _agentPerformanceChannel.invokeMethod('logResourceLogger', <String, dynamic> {
        'id': id
      });
    }
  }

}

class MessagingAgent{
  static const MethodChannel _messagingChannel = const MethodChannel('flurry_flutter_plugin');
  static const EventChannel _eventChannel = EventChannel('flurry_flutter_plugin_event_messaging');

  static const String notificationReceived = 'NotificationReceived';
  static const String notificationClicked = 'NotificationClicked';
  static const String notificationCancelled = 'NotificationCancelled';
  static const String tokenRefresh = 'TokenRefresh';

  MessagingListener listener;

  void withMessaging() {
    if (Platform.isIOS) {
      _messagingChannel.invokeMethod('withMessaging');
    }
  }

  void setListener(MessagingListener listener) {
    _messagingChannel.invokeMethod('setMessagingListener');

    // set event channel for native callbacks
    _eventChannel.receiveBroadcastStream().listen(_onEvent, onError: _onError);
    this.listener = listener;
  }

  void _onEvent(Object e) {
    print("Flurry Messaging callback will be triggered");
    if (e is Map) {
      Map<String, dynamic> event = new Map<String, dynamic>.from(e);
      if (event.containsKey('type')) {
        switch(event['type'] as String) {
          case notificationReceived:
            print("Flurry Messaging received callback triggered");
            if (Platform.isIOS) {
              if (listener != null) {
                listener.onNotificationReceived(convertToMessage(event));
              }
            } else if (Platform.isAndroid) {
              if (listener != null) {
                bool willHandle = listener.onNotificationReceived(convertToMessage(event));
                _messagingChannel.invokeMethod('willHandleMessage', <String, dynamic> {
                  'willHandle': willHandle
                });
              }
            }
            break;
          case notificationClicked:
            print("Flurry Messaging clicked callback triggered");
            if (Platform.isIOS) {
              if (listener != null) {
                listener.onNotificationClicked(convertToMessage(event));
              }
            } else if (Platform.isAndroid) {
              if (listener != null) {
                bool willHandle = listener.onNotificationClicked(convertToMessage(event));
                _messagingChannel.invokeMethod('willHandleMessage', <String, dynamic> {
                  'willHandle': willHandle
                });
              }
            }
            break;
          case notificationCancelled:
            print("Flurry Messaging canceled callback triggered");
            if (listener != null) {
              listener.onNotificationCancelled(convertToMessage(event));
            }
            break;
          case tokenRefresh:
            print("Flurry Messaging token refreshed callback triggered");
            if (listener != null) {
              listener.onTokenRefresh(event['token'] as String);
            }
            break;
        }
      }
    }
  }

  Message convertToMessage(Map<String, dynamic> event) {
    Message message = Message();
    message.title = event['title'] as String;
    message.body = event['body'] as String;
    message.clickAction = event['clickAction'] as String;
    message.appData = new Map<String, String>.from(event['appData']);

    return message;
  }

  void _onError(Object error) {
      print("error receiving push callbacks");
  }
}

class ConfigAgent {
  static const MethodChannel _configChannel = const MethodChannel('flurry_flutter_plugin');
  static const EventChannel _eventChannel = EventChannel('flurry_flutter_plugin_event_config');

  static const String fetchSuccess = 'FetchSuccess';
  static const String fetchNoChange = 'FetchNoChange';
  static const String fetchError = 'FetchError';
  static const String activateComplete = 'ActivateComplete';

  List<ConfigListener> _listeners;

  ConfigAgent() {
    _listeners = [];
  }
  void fetchConfig() {
    _configChannel.invokeMethod('fetchConfig');
  }

  void activateConfig() {
    _configChannel.invokeMethod('activateConfig');
  }

  void registerListener(ConfigListener listener) {
    _listeners.add(listener);
    _configChannel.invokeMethod('registerConfigListener');
    _eventChannel.receiveBroadcastStream().listen(_onEvent, onError: _onError);
  }

  void unregisterListener(ConfigListener listener) {
    _listeners.remove(listener);
  }

  void _onEvent(Object e) {
    print("Flurry Config Listener callback will be triggered");
    if (e is Map) {
      Map<String, String> event = new Map<String, String>.from(e);
      if (event.containsKey('type')) {
        String type = event['type'];
        if (type == fetchSuccess) {
          print("onFetchSuccess() triggered");
          _listeners.forEach((element) =>
            element.onFetchSuccess()
          );
        }
        else if (type == fetchNoChange) {
          print("onFetchNoChange() triggered");
          _listeners.forEach((element) =>
              element.onFetchNoChange()
          );
        }

        else if (type == fetchError) {
          print("onFetchError() triggered");
          if (Platform.isIOS) {
            _listeners.forEach((element) =>
                element.onFetchError(false)
            );
          } else if (Platform.isAndroid) {
            bool isRetrying = false;
            if (event.containsKey('isRetrying')) {
              String value = event['isRetrying'];
              isRetrying = value.toLowerCase() == 'true';
            }
            _listeners.forEach((element) =>
                element.onFetchError(isRetrying)
            );
          }
        }
        else if (type == activateComplete) {
          print("onActivateComplete() triggered");
          if (Platform.isIOS) {
            _listeners.forEach((element) =>
                element.onActivateComplete(false)
            );
          } else if (Platform.isAndroid) {
            bool isCache = false;
            if (event.containsKey('isCache')) {
              String value = event['isCache'];
              isCache = value.toLowerCase() == 'true';
            }
            _listeners.forEach((element) =>
                element.onActivateComplete(isCache)
            );
          }
        }
      }
    }
  }

  void _onError(Object error) {
    print("error receiving fetch callbacks");
  }

  Future<String> getConfigString(String key, String defaultValue) async {
    return await _configChannel.invokeMethod('getConfigString', <String, dynamic> {
      'key': key,
      'defaultValue': defaultValue
    });
  }
}

class ParamBuilderAgent {

  Map<dynamic, String> _map;

  ParamBuilderAgent() {
    _map = Map<dynamic, String>();
  }

  void putAll(Param param) {
    for(MapEntry<dynamic, String> e in param.builderAgent._map.entries) {
      _map.putIfAbsent(e.key, () => e.value);
    }
  }

  Map<dynamic, String> getParameters() {
    return _map;
  }

  void putStringParam(StringParam key, String value) {
    _map.putIfAbsent(key, () => value);
  }

  void putString(String key, String value) {
    _map.putIfAbsent(key, () => value);
  }

  void putIntegerParam(IntegerParam key, int value) {
    _map.putIfAbsent(key, () => value.toString());
  }

  void putInteger(String key, int value) {
    _map.putIfAbsent(key, () => value.toString());
  }

  void putDoubleParam(DoubleParam key, double value) {
    _map.putIfAbsent(key, () => value.toString());
  }

  void putDouble(String key, double value) {
    _map.putIfAbsent(key, () => value.toString());
  }

  void putBooleanParam(BooleanParam key, bool value) {
    _map.putIfAbsent(key, () => value.toString());
  }

  void putBoolen(String key, bool value) {
    _map.putIfAbsent(key, () => value.toString());
  }

  void removeParam(ParamBase param) {
    _map.remove(param);
  }

  void remove(String key) {
    _map.remove(key);
  }

  void clear() {
    _map.clear();
  }
}

class PublisherSegmentationAgent {
  static const MethodChannel _publisherChannel = const MethodChannel('flurry_flutter_plugin');
  static const EventChannel _eventChannel = EventChannel('flurry_flutter_plugin_event_ps');

  List<PublisherSegmentationListener> _listeners;

  PublisherSegmentationAgent() {
    _listeners = [];
  }

  Future<bool> isFetchFinished() async {
    return await _publisherChannel.invokeMethod('isPublisherDataFetched');
  }

  void fetch() {
    _publisherChannel.invokeMethod('fetchPublisherData');
  }

  void registerListener(PublisherSegmentationListener listener) {
    _listeners.add(listener);
    _publisherChannel.invokeMethod('registerPublisherDataListener');
    _eventChannel.receiveBroadcastStream().listen(_onEvent, onError: _onError);
  }

  void unregisterListener(PublisherSegmentationListener listener) {
    _listeners.remove(listener);
  }

  void _onEvent(Object e) {
    print("Flurry Publisher Segmentation Listener callback will be triggered");
    if (e is Map) {
      Map<String, String> event = new Map<String, String>.from(e);
      print("Publisher Segmentation onFetched triggered");
      _listeners.forEach((element) =>
          element.onFetched(event)
      );
    }
  }

  void _onError(Object error) {
    print("error receiving fetch callbacks");
  }

  Future<Map<String, String>> getPublisherData() async {
    Map<Object, Object> data = await _publisherChannel.invokeMethod('getPublisherData');
    return new Map<String, String>.from(data);
  }
}

