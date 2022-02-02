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

import 'dart:io';
import 'package:flutter/services.dart';

import 'src/flurry_agent.dart';

enum LogLevel { verbose, debug, info, warn, error, assertion }

/// Constants for logging post install events using Flurry's FlurrySKAdNetwork class.
enum SKAdNetworkEvent {
  noEvent,
  registration,
  login,
  subscription,
  inAppPurchase
}

/// Status for analytics event recording.
enum EventRecordStatus {
  eventFailed,
  eventRecorded,
  eventUniqueCountExceeded,
  eventParamsCountExceeded,
  eventLoggingDelayed,
  eventAnalyticsDisabled,
  eventParametersMismatched
}

/// Constants for setting user gender in analytics SDK.
enum Gender { male, female }

/// A Flutter plugin for Flurry SDK.
///
/// The Flurry Agent allows you to track the usage and behavior of your application
/// on user's devices for viewing in the Flurry Analytics system.
///
/// Set of methods that allow developers to capture detailed, aggregate information
/// regarding the use of their app by end users.
class Flurry {
  static const MethodChannel _channel =
      const MethodChannel('flurry_flutter_plugin');

  static final FlurryAgent flurryAgent =
      (Platform.isAndroid || Platform.isIOS) ? new FlurryAgent() : null;
  static final Builder builder = Builder();
  static final UserProperties userProperties = UserProperties();
  static final Performance performance = Performance();
  static final Config config = Config();
  static final PublisherSegmentation publisherSegmentation =
      PublisherSegmentation();

  static Future<String> getPlatformVersion() async {
    String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  /// Get constants for setting log level in analytics SDK.
  int getLogLevel(LogLevel logLevel) {
    switch (logLevel) {
      case LogLevel.verbose:
      case LogLevel.debug:
      case LogLevel.info:
      case LogLevel.warn:
      case LogLevel.error:
      case LogLevel.assertion:
        return logLevel.index + 2;
    }
    return 7;
  }

  /// Sets the timeout for expiring a Flurry session.
  ///
  /// Sets the time the app may be in the background before starting a new session
  /// upon resume. Default is set to 10 seconds in background.
  static void setContinueSessionMillis([int sessionMillis = 10000]) {
    if (flurryAgent != null) {
      flurryAgent.setContinueSessionMillis(sessionMillis);
    }
  }

  /// Enable automatics collection of crash reports.
  ///
  /// Catches uncaught exceptions and reports them to Flurry if [crashReporting]
  /// enabled. Default value is set to true.
  static void setCrashReporting([bool crashReporting = true]) {
    if (flurryAgent != null) {
      flurryAgent.setCrashReporting(crashReporting);
    }
  }

  /// Enables opting out of background sessions being counted towards total
  /// sessions.
  ///
  /// Set [includeBackgroundSessionsInMetrics] true if this session should be
  /// added to total sessions/DAUs when application state is inactive or background.
  /// This API needs to be called before starting session.
  static void setIncludeBackgroundSessionsInMetrics(
      [bool includeBackgroundSessionsInMetrics = true]) {
    if (flurryAgent != null) {
      flurryAgent.setIncludeBackgroundSessionsInMetrics(
          includeBackgroundSessionsInMetrics);
    }
  }

  /// Generates debug logs to console.
  static void setLogEnabled([bool enableLog = true]) {
    if (flurryAgent != null) {
      flurryAgent.setLogEnabled(enableLog);
    }
  }

  /// Sets the log level of the debug logs of console.
  static void setLogLevel([LogLevel logLevel = LogLevel.warn]) {
    if (flurryAgent != null) {
      flurryAgent.setLogLevel(logLevel);
    }
  }

  /// True to enable or false to disable SSL Pinning for Flurry Analytics connection. Defaults to false.
  static void setSslPinningEnabled([bool sslPinningEnabled = false]) {
    if (flurryAgent != null) {
      flurryAgent.setSslPinningEnabled(sslPinningEnabled);
    }
  }

  /// Sends ccpa compliance data to Flurry.
  ///
  /// Opts out or opt in to data sale to third parties based boolean value of
  /// [isOptOut].
  /// The user's preference must be used to initialize the [Builder.withDataSaleOptOut]
  /// setting in the [Builder] in all future sessions.
  static void setDataSaleOptOut(bool isOptOut) {
    if (flurryAgent != null) {
      flurryAgent.setDataSaleOptOut(isOptOut);
    }
  }

  /// Allows the user to request Flurry to delete their collected data from this
  /// app.
  static void deleteData() {
    if (flurryAgent != null) {
      flurryAgent.deleteData();
    }
  }

  /// Sets user's [age] in years at the time of this session.
  static void setAge(int age) {
    if (flurryAgent != null) {
      flurryAgent.setAge(age);
    }
  }

  /// Sets user's [gender].
  ///
  /// [gender] can be specified by either Gender.Male or Gender.Female
  static void setGender(Gender gender) {
    if (flurryAgent != null) {
      flurryAgent.setGender(gender);
    }
  }

  /// Sets user's preference to allow Flurry to record location via GPS.
  ///
  /// Location reporting depends on [reportLocation] value for Android whereas
  /// iOS decides based on user permissions of the app.
  static void setReportLocation(bool reportLocation) {
    if (flurryAgent != null) {
      flurryAgent.setReportLocation(reportLocation);
    }
  }

  /// Sets session attributions.
  ///
  /// Specifies session origin named [originName] and [deepLink] for each
  /// session
  static void setSessionOrigin(String originName, String deepLink) {
    if (flurryAgent != null) {
      flurryAgent.setSessionOrigin(originName, deepLink);
    }
  }

  /// Sets a unique Flurry [userId] for this session.
  static void setUserId(String userId) {
    if (flurryAgent != null) {
      flurryAgent.setUserId(userId);
    }
  }

  /// Sets the [versionName] of the app.
  ///
  /// Use this method to set [versionName] and for iOS, set version name with
  /// [Builder.withAppVersion].
  static void setVersionName(String versionName) {
    if (flurryAgent != null) {
      flurryAgent.setVersionName(versionName);
    }
  }

  /// Adds origin attribution.
  ///
  /// Capture the [originName] and version string of the origin wrapper named
  /// [originVersion].
  static void addOrigin(String originName, String originVersion) {
    if (flurryAgent != null) {
      flurryAgent.addOrigin(originName, originVersion);
    }
  }

  /// Adds origin attribution with parameters.
  ///
  /// Capture the [originName] and version string of the origin wrapper named
  /// [originVersion]. Use maximum of 10 [originParameters] to store
  /// characteristics of an origin.
  static void addOriginWithParameters(String originName, String originVersion,
      Map<String, String> originParameters) {
    if (flurryAgent != null) {
      flurryAgent.addOriginWithParameters(
          originName, originVersion, originParameters);
    }
  }

  /// Allows you to associate parameters with a session.
  ///
  /// Adds property name called [name] and property value called [value].
  static void addSessionProperty(String name, String value) {
    if (flurryAgent != null) {
      flurryAgent.addSessionProperty(name, value);
    }
  }

  /// Returns the version of the Flurry SDK.
  static Future<int> getAgentVersion() async {
    if (flurryAgent != null) {
      int agentVersion = await flurryAgent.getAgentVersion();
      return agentVersion;
    }
    return 0;
  }

  /// Returns the release version of the Flurry SDK.
  static Future<String> getReleaseVersion() async {
    if (flurryAgent != null) {
      String version = await flurryAgent.getReleaseVersion();
      return version;
    }

    return null;
  }

  /// Returns the session id of the current session.
  static Future<String> getSessionId() async {
    if (flurryAgent != null) {
      String sessionId = await flurryAgent.getSessionId();
      return sessionId;
    }
    return null;
  }

  /// Records a custom event specified by [eventId].
  ///
  /// Returns the event recording status of the logged event.
  static Future<EventRecordStatus> logEvent(String eventId) async {
    if (flurryAgent != null) {
      int eventRecordStatus = await flurryAgent.logEvent(eventId);
      return EventRecordStatus.values[eventRecordStatus];
    }

    return EventRecordStatus.eventRecorded;
  }

  /// Records a custom timed event named [eventId]
  ///
  /// Logs [eventId] as a non timed event or a timed event based on boolean
  /// [timed]. Returns the event recording status of the logged event.
  static Future<EventRecordStatus> logTimedEvent(
      String eventId, bool timed) async {
    if (flurryAgent != null) {
      int eventRecordStatus = await flurryAgent.logTimedEvent(eventId, timed);
      return EventRecordStatus.values[eventRecordStatus];
    }

    return EventRecordStatus.eventRecorded;
  }

  /// Records an event named [eventId] with parameters.
  ///
  /// Logs [eventId] with maximum of 10 [parameters] which helps in specifying
  /// the characteristics of the event. Returns the event recording status
  /// of the logged event.
  static Future<EventRecordStatus> logEventWithParameters(
      String eventId, Map<String, String> parameters) async {
    if (flurryAgent != null) {
      int eventRecordStatus =
          await flurryAgent.logEventWithParameters(eventId, parameters);
      return EventRecordStatus.values[eventRecordStatus];
    }

    return EventRecordStatus.eventRecorded;
  }

  /// Records a timed event named [eventId] with parameters.
  ///
  /// Logs [eventId] as a non timed event or a timed event based on boolean
  /// [timed]. Use maximum of 10 [parameters] to specify the characters of the
  /// event. Returns the event recording status of the logged event.
  static Future<EventRecordStatus> logTimedEventWithParameters(
      String eventId, Map<String, String> parameters, bool timed) async {
    if (flurryAgent != null) {
      int eventRecordStatus = await flurryAgent.logTimedEventWithParameters(
          eventId, parameters, timed);
      return EventRecordStatus.values[eventRecordStatus];
    }

    return EventRecordStatus.eventRecorded;
  }

  /// Ends an existing timed event named [eventId].
  ///
  /// Ignores the action if event named [eventId] is already terminated.
  static void endTimedEvent(String eventId) {
    if (flurryAgent != null) {
      flurryAgent.endTimedEvent(eventId);
    }
  }

  /// Ends a timed event and updated parameters.
  ///
  /// Ends the timed event if the event was not terminated already. Updates the
  /// existing parameters to the new [parameters] Maximum of 10 unique
  /// parameters total can be passed for an event, including those passed when
  /// the event was initiated.
  static void endTimedEventWithParameters(
      String eventId, Map<String, String> parameters) {
    if (flurryAgent != null) {
      flurryAgent.endTimedEventWithParameters(eventId, parameters);
    }
  }

  /// Records an app exception.
  ///
  /// Commonly used to catch unhandled exceptions. Specifies error name using
  /// [errorId], and error message in [message]. Specifies exception attributes
  /// like exception name and exception reason in [errorClass].
  static void onError(String errorId, String message, String errorClass) {
    if (flurryAgent != null) {
      flurryAgent.onError(errorId, message, errorClass);
    }
  }

  /// Records an app exception with parameters.
  ///
  /// Commonly used to catch unhandled exceptions. Specifies error name using
  /// [errorId], and error message in [message]. Specifies exception attributes
  /// like exception name and exception reason in [errorClass]. Specify custom
  /// parameters associated with the exception.
  static void onErrorWithParameters(String errorId, String message,
      String errorClass, Map<String, String> parameters) {
    if (flurryAgent != null) {
      flurryAgent.onErrorWithParameters(
          errorId, message, errorClass, parameters);
    }
  }

  /// Logs the breadcrumb.
  ///
  /// Captures [crashBreadcrumb] of 250 characters. The last 207 recorded
  /// breadcrumbs are included in crash and error logs. Breadcrumbs are reset
  /// at every application launch.
  static void logBreadcrumb(String crashBreadcrumb) {
    if (flurryAgent != null) {
      flurryAgent.logBreadcrumb(crashBreadcrumb);
    }
  }

  /// Logs a payment.
  ///
  /// Logs a transaction event with maximum of 10 [parameters] to specify the
  /// characteristics of the payment. Returns the event recording status of the
  /// logged event.
  static Future<EventRecordStatus> logPayment(
      String productName,
      String productId,
      int quantity,
      double price,
      String currency,
      String transactionId,
      Map<String, String> parameters) async {
    if (flurryAgent != null) {
      int eventRecordStatus = await flurryAgent.logPayment(productName,
          productId, quantity, price, currency, transactionId, parameters);
      return EventRecordStatus.values[eventRecordStatus];
    }

    return EventRecordStatus.eventRecorded;
  }

  /// Records a Flurry standard event.
  ///
  /// Records a standard parameterized event specified by event type named [id]
  /// and maximum of 10 parameters passed as [param]. Returns the event recording
  /// status of the logged standard event.
  static Future<EventRecordStatus> logStandardEvent(
      FlurryEvent id, Param param) async {
    if (flurryAgent != null) {
      int eventRecordStatus = await flurryAgent.logStandardEvent(id, param);
      return EventRecordStatus.values[eventRecordStatus];
    }
    return EventRecordStatus.eventFailed;
  }

  /// Enables implicit recording of In-App transactions.
  ///
  /// This method needs to be called before any transaction is finalized.
  static void setIAPReportingEnabled(bool enableIAP) {
    if (flurryAgent != null) {
      flurryAgent.setIAPReportingEnabled(enableIAP);
    }
  }

  /// Sets the iOS conversion value sent to Apple through SKAdNetwork.
  ///
  /// [conversionValue] is an integer value between 0-63. The conversion values
  /// meaning is determined by the developer.
  static void updateConversionValue(int conversionValue) {
    if (flurryAgent != null) {
      flurryAgent.updateConversionValue(conversionValue);
    }
  }

  /// Allows Flurry to set the SKAdNetwork conversion value for you.
  ///
  /// The final conversion value is a decimal number between 0-63.
  /// The conversion value is calculated from a 6 bit binary number.
  /// The first two bits represent days of user retention from 0-3 days
  /// The last four bits represent a true false state indicating if the user has
  /// completed the post install [flurryEvent].
  /// Valid [flurryEvent] is NoEvent, Registration, LogIn, Subscription, or InAppPurchase.
  static void updateConversionValueWithEvent(SKAdNetworkEvent flurryEvent) {
    if (flurryAgent != null) {
      flurryAgent.updateConversionValueWithEvent(flurryEvent);
    }
  }

  /// opens privacy dashboard in Safari/Chrome CustomTab.
  ///
  /// Opens Safari/Chrome CustomTab if its dependency's
  /// been included in the gradle and device support it as well. otherwise will
  /// open it in the external browser.
  static void openPrivacyDashboard() {
    if (flurryAgent != null) {
      flurryAgent.openPrivacyDashboard();
    }
  }
}

class Builder {
  BuilderAgent builderAgent;
  MessagingAgent messagingAgent;

  Builder() {
    if (Platform.isIOS || Platform.isAndroid) {
      // calls initializeBuilder
      builderAgent = new BuilderAgent();
      messagingAgent = new MessagingAgent();
    }
  }

  void build({String androidAPIKey = "", String iosAPIKey = ""}) {
    if (builderAgent != null) {
      Map<String, dynamic> arguments = <String, dynamic>{};
      arguments.putIfAbsent("androidAPIKey", () => androidAPIKey);
      arguments.putIfAbsent("iosAPIKey", () => iosAPIKey);
      builderAgent.build(arguments);
    }
  }

  /// Sets the app version.
  ///
  /// Explicitly specifies the [appVersion] that Flurry will use to group
  /// Analytics data. Default is set to "1.0". Maximum of 605 versions allowed
  /// per app.
  Builder withAppVersion([String appVersion = "1.0"]) {
    if (builderAgent != null) {
      builderAgent.withAppVersion(appVersion);
    }
    return this;
  }

  /// Sets the timeout for expiring a Flurry session.
  ///
  /// Sets the time the app may be in the background before starting a new session
  /// upon resume. Default is set to 10 seconds in background.
  Builder withContinueSessionMillis([int sessionMillis = 10000]) {
    if (builderAgent != null) {
      builderAgent.withContinueSessionMillis(sessionMillis);
    }
    return this;
  }

  /// Enable automatics collection of crash reports.
  ///
  /// Catches uncaught exceptions and reports them to Flurry if [crashReporting]
  /// enabled. Default value is set to true.
  Builder withCrashReporting([bool crashReporting = true]) {
    if (builderAgent != null) {
      builderAgent.withCrashReporting(crashReporting);
    }
    return this;
  }

  /// Sends CCPA compliance data to Flurry.
  ///
  /// Sends CCPA compliance data to Flurry on the user's choice to opt out or
  /// opt in to data sale to third parties. By default, [isOptOut] is set to false.
  Builder withDataSaleOptOut([bool isOptOut = false]) {
    if (builderAgent != null) {
      builderAgent.withDataSaleOptOut(isOptOut);
    }
    return this;
  }

  /// Enables opting out of background sessions being counted towards total
  /// sessions.
  ///
  /// Set [includeBackgroundSessionsInMetrics] true if this session should be
  /// added to total sessions/DAUs when application state is inactive or background.
  /// This API needs to be called before starting session.
  Builder withIncludeBackgroundSessionsInMetrics(
      [bool includeBackgroundSessionsInMetrics = true]) {
    if (builderAgent != null) {
      builderAgent.withIncludeBackgroundSessionsInMetrics(
          includeBackgroundSessionsInMetrics);
    }
    return this;
  }

  /// Generates debug logs to console.
  Builder withLogEnabled([bool enableLog = true]) {
    if (builderAgent != null) {
      builderAgent.withLogEnabled(enableLog);
    }
    return this;
  }

  /// Sets the log level of the debug logs of console.
  Builder withLogLevel([LogLevel logLevel = LogLevel.warn]) {
    if (builderAgent != null) {
      builderAgent.withLogLevel(logLevel);
    }
    return this;
  }

  /// Sets flag for performance metrics reporting.
  Builder withPerformanceMetrics([int performanceMetrics = Performance.all]) {
    if (builderAgent != null) {
      builderAgent.withPerformanceMetrics(performanceMetrics);
    }
    return this;
  }

  /// True to enable or false to disable SSL Pinning for Flurry Analytics connection. Defaults to false.
  Builder withSslPinningEnabled([bool sslPinningEnabled = false]) {
    if (builderAgent != null) {
      builderAgent.withSslPinningEnabled(sslPinningEnabled);
    }
    return this;
  }

  /// Sets automatic integration for push notification for iOS.
  /// Register Messaging listener for optional callback on Push events for both iOS and Android.
  ///
  /// This API takes care of all the setup for iOS push Notifications.
  /// 1) Registers for Notifications.
  /// 2) Handles device token.
  /// 3) Listens for callbacks from UIApplication and UNUserNotificationCenter.
  Builder withMessaging(
      [bool enableMessaging = true, MessagingListener listener]) {
    if (!enableMessaging) {
      return this;
    }

    if (messagingAgent != null) {
      messagingAgent.setListener(listener);

      if (Platform.isIOS) {
        messagingAgent.withMessaging();
      } else {
        print(
            "To enable Flurry Push for Android, please duplicate Builder setup in your FlutterApplication class.");
      }
    }
    return this;
  }
}

/// User Properties class for Flurry
class UserProperties {
  /// Standard User Property: Currency Preference.
  ///
  /// Follow ISO 4217: https://en.wikipedia.org/wiki/ISO_4217
  /// [](https://en.wikipedia.org/wiki/ISO_4217)
  /// E.g., "USD", "EUR", "JPY", "CNY", ...
  static const String propertyCurrencyPreference = "Flurry.CurrencyPreference";

  /// Standard User Property: Purchaser.
  ///
  /// E.g., "true" or "false"
  static const String propertyPurchaser = "Flurry.Purchaser";

  /// Standard User Property: Registered user.
  ///
  /// E.g., "true" or "false"
  static const String propertyRegisteredUser = "Flurry.RegisteredUser";

  /// Standard User Property: Subscriber.
  ///
  /// E.g., "true" or "false"
  static const String propertySubscriber = "Flurry.Subscriber";

  // init static Flurry agent UserProperties object.
  static UserPropertiesAgent userPropertiesAgent;

  UserProperties() {
    if (Platform.isIOS || Platform.isAndroid) {
      userPropertiesAgent = new UserPropertiesAgent();
    }
  }

  /// Exactly sets, or replace if any previously exists, any state for the property.
  ///
  /// Null [propertyValue] clears the property state. [propertyValue] allows
  /// in a single string value.
  void setValue(String propertyName, String propertyValue) {
    if (userPropertiesAgent != null) {
      userPropertiesAgent.setUserPropertyValue(propertyName, propertyValue);
    }
  }

  /// Exactly set, or replace if any previously exists, any state for the property.
  ///
  /// Empty list or null [propertyValues] clears the property state.
  void setValues(String propertyName, List<String> propertyValues) {
    if (userPropertiesAgent != null) {
      userPropertiesAgent.setUserPropertyValues(propertyName, propertyValues);
    }
  }

  /// Extends or creates property named [propertyName].
  ///
  /// Extends property if [propertyName] already exists or adds [propertyName]
  /// if does not already exists. Adding [propertyValue] already included in the
  /// state has no effect and does not error.
  void addValue(String propertyName, String propertyValue) {
    if (userPropertiesAgent != null) {
      userPropertiesAgent.addUserPropertyValue(propertyName, propertyValue);
    }
  }

  /// Extends or creates property named [propertyName].
  ///
  /// Extends property if [propertyName] already exists or adds [propertyName]
  /// if does not already exists. Adding [propertyValues] already included in
  /// the state has no effect and does not error.
  void addValues(String propertyName, List<String> propertyValues) {
    if (userPropertiesAgent != null) {
      userPropertiesAgent.addUserPropertyValues(propertyName, propertyValues);
    }
  }

  /// Reduces property named [propertyName].
  ///
  /// Removing [propertyValue] not already included in the state has no effect
  /// and does not error
  void removeValue(String propertyName, String propertyValue) {
    if (userPropertiesAgent != null) {
      userPropertiesAgent.removeUserPropertyValue(propertyName, propertyValue);
    }
  }

  /// Reduce property named [propertyName].
  ///
  /// Removing [propertyValues] not already included in the state has no effect
  /// and does not error
  void removeValues(String propertyName, List<String> propertyValues) {
    if (userPropertiesAgent != null) {
      userPropertiesAgent.removeUserPropertyValues(
          propertyName, propertyValues);
    }
  }

  /// Removes all property values for the property named [propertyName].
  ///
  /// Exactly set, or replace if any previously exists, any state for the
  /// [propertyName] to be empty.
  void remove(String propertyName) {
    if (userPropertiesAgent != null) {
      userPropertiesAgent.removeUserProperty(propertyName);
    }
  }

  /// Exactly set, or replace if any previously exists, any state for the
  /// [propertyName] to a single true state.
  ///
  /// Implies that value is boolean and should only be flagged and cleared.
  void flag(String propertyName) {
    if (userPropertiesAgent != null) {
      userPropertiesAgent.flagUserProperty(propertyName);
    }
  }
}

class Performance {
  static const int none = 0;
  static const int coldStart = 1;
  static const int screenTime = 2;
  static const int all = 1 | 2;

  // init static Flurry agent PerformanceMetrics object.
  static PerformanceAgent performanceAgent;

  Performance() {
    if (Platform.isAndroid || Platform.isIOS) {
      performanceAgent = new PerformanceAgent();
    }
  }

  /// Reports to the Flurry Cold Start metrics that your app is now fully drawn.
  ///
  /// **Android Only.**
  /// This is only used to help measuring application launch times, so that the
  /// app can report when it is fully in a usable state similar to
  /// android.app.Activity#reportFullyDrawn
  /// [](https://android.app.Activity#reportFullyDrawn)
  void reportFullyDrawn() {
    if (performanceAgent != null) {
      performanceAgent.reportFullyDrawn();
    }
  }

  /// Provides a Resource logger.
  ///
  /// Users can start resource logger before profiled codes start,
  /// then log event after finished. Flurry will compute the time.
  /// **Android Only.**
  ///
  /// e.g.
  /// ```dart
  ///   Flurry.Performance.StartResourceLogger();
  ///   {
  ///       // profiled codes ...
  ///   }
  ///   Flurry.Performance.LogResourceLogger("My ID");
  /// ```
  void startResourceLogger() {
    if (performanceAgent != null) {
      performanceAgent.startResourceLogger();
    }
  }

  /// Logs Flurry Resources Consuming events with group event id, [id].
  void logResourceLogger(String id) {
    if (performanceAgent != null) {
      performanceAgent.logResourceLogger(id);
    }
  }
}

/// Message is a convenience class to access all the properties set
/// on the Flurry message.
class Message {
  String title;
  String body;
  String clickAction;
  Map<String, String> appData;
}

/// Provides all available delegates for receiving callbacks related to
///
/// Flurry Notifications. Set of methods that allow developers to manage and
/// take actions within the App, which is useful when used with the Flurry
/// Messaging
mixin MessagingListener {
  /// Informs the app when Flurry Notification received.
  ///
  /// Returns true if you've handled the notification; false if you haven't and
  /// want Flurry to handle it.
  /// **For Android only, you might want to return false for iOS.**
  bool onNotificationReceived(Message message);

  /// Informs the app when Flurry Notification receives an action.
  ///
  /// Return true if you've handled the notification; false if you haven't and
  /// want Flurry to handle it.
  /// **For Android only, you might want to return false for iOS**
  bool onNotificationClicked(Message message);

  ///Informs the app when Flurry Notification has been cancelled/dismissed by
  ///by users. **Android only.**
  void onNotificationCancelled(Message message);

  /// Informs the app when Flurry Notification token has been changed.
  /// **Android only.**
  void onTokenRefresh(String token);
}

/// Provides a protocol for subscribed observers of the Config class to listen to.
///
/// A set of actions that allow an observing class to take action based on
/// certain events, such as fetch operations or activations.
mixin ConfigListener {
  /// Informs the app when a fetch is initiated and completed with a change.
  void onFetchSuccess();

  /// Informs the app when a fetch is completed but no changed are made.
  void onFetchNoChange();

  /// Informs the app when a fetch is initiated but fails for some reason.
  ///
  /// [isRetrying] is set to true if SDK is retrying to fetch. For iOS,
  /// [isRetrying] is always false.
  void onFetchError(bool isRetrying);

  /// Informs the app when an activation is done.
  ///
  /// This notification is important in the "greedy" case of activation. An
  /// object may greedily call for activation and other objects may need to
  /// know to modify their state (or ignore this activation) in order to
  /// maintain a consistent user experience. [isCache] is true if activated
  /// from the cached data. For iOS, [isCache] is always false.
  void onActivateComplete(bool isCache);
}

/// Config is a config service that seeks to allow app developers to have
/// configuration services over their app.
///
/// For example, a developer could bake in a green theme for the day of the
/// Saint Patrick's Holiday. Further, a developer could roll out, into
/// production, the ability for the developers to test real-world changes while
/// only exposing those changes to the developers.
///
/// * The Config service is designed to provide the least disruptive experience to
/// users possible. In light of this goal, fetched configs will only be applied
/// when the app leaves memory and relaunches. This will guarantee a continuity
/// of the user experience that is not jarring if a new config gets rolled out
/// mid-session.
///
/// * In this basic usage all that is necessary is to call fetch on the shared
/// instance. The code may then check feature flags with the assurance that the
/// UI experience will be consistent.
///
/// * However, it is often the case that a developer would like to be more
/// aggressive with the application of a config. To satisfy that need the
/// FConfig service supplies an observer that an object may subscribe to.
///
/// * As events happen, such as successful fetching or the activation of a config,
/// the object that is observing may take action. This allows the developer to
/// have more control over the configuration service if it is necessary.

class Config {
  static ConfigAgent configAgent;

  Config() {
    if (Platform.isAndroid || Platform.isIOS) {
      configAgent = new ConfigAgent();
    }
  }

  /// Fetches the most recent config from the server for this client.
  ///
  /// Upon completion of the fetch, the [ConfigListener] will be called to make
  /// note of the result.
  ///
  /// There is a built in throttle on the number of times this call can be made.
  /// That throttle is based on a response from the server.
  ///
  /// **It is important to know that fetching does not activate a new config.**
  void fetchConfig() {
    if (configAgent != null) {
      configAgent.fetchConfig();
    }
  }

  /// Aggressively activates the latest config if it has not been activated.
  ///
  /// Puts the latest config directly into use, unlike the typical operation
  /// where a fetched config is only activated after the next session.
  ///
  /// When an activation occurs, anyone listening to the [ConfigListener]
  /// will be notified of the activation.
  void activateConfig() {
    if (configAgent != null) {
      configAgent.activateConfig();
    }
  }

  /// Registers an observer.
  ///
  /// An object may register as an observer in order to be notified of events
  /// within the config service.
  void registerListener(ConfigListener listener) {
    if (configAgent != null) {
      configAgent.registerListener(listener);
    }
  }

  /// Unregisters an observer.
  void unregisterListener(ConfigListener listener) {
    if (configAgent != null) {
      configAgent.unregisterListener(listener);
    }
  }

  /// Gets the string value for the given [key].
  ///
  /// The config service will do its best to handle the string appropriately,
  /// but all attempts should be made to validate that the returned value is,
  /// indeed, a fully formed string.  If no value is provided in the config the
  /// [defaultValue] will be chosen.
  Future<String> getConfigString(String key, String defaultValue) async {
    if (configAgent != null) {
      String value = await configAgent.getConfigString(key, defaultValue);
      return value;
    }
    return null;
  }
}

enum FlurryEvent {
  /// Log this event when a user clicks on an Ad.
  ///
  /// Suggested event params: adType
  ///
  /// Mandatory event params : none
  adClick,

  /// Log this event when a user views an Ad impression.
  ///
  /// Suggested event params : adType
  ///
  /// Mandatory event params : none
  adImpression,

  /// Log this event when a user is granted a reward for viewing a rewarded Ad.
  ///
  /// Suggested event params : adType
  ///
  /// Mandatory event params : none
  adRewarded,

  /// Log this event when a user skips an Ad
  ///
  /// Suggested event params : adType
  ///
  /// Mandatory event params : none
  adSkipped,

  /// Log this event when a user spends credit in the app.
  ///
  /// Suggested event params : levelNumber, totalAmount, isCurrencySoft,
  /// creditType, creditId, creditName, currencyType
  ///
  /// Mandatory event params : totalAmount
  creditsSpent,

  /// Log this event when a user purchases credit in the app.
  ///
  /// Suggested event params : levelNumber, totalAmount, isCurrencySoft,
  /// creditType, creditId, creditName, currencyType
  ///
  /// Mandatory event params : totalAmount
  creditsPurchased,

  /// Log this event when a user earns credit in the app.
  ///
  /// Suggested event params : levelNumber, totalAmount, isCurrencySoft,
  /// creditType, creditId, creditName, currencyType
  ///
  /// Mandatory event params : totalAmount
  creditsEarned,

  /// Log this event when a user unlocks an achievement in the app.
  ///
  /// Suggested event params : achievementId
  ///
  /// Mandatory event params : none
  achievementUnlocked,

  /// Log this event when an App user completes a level.
  ///
  /// Suggested event params : levelNumber, levelName
  ///
  /// Mandatory event params : levelNumber
  levelCompleted,

  /// Log this event when an App user fails a level.
  ///
  /// Suggested event params : levelNumber, levelName
  ///
  /// Mandatory event params : levelNumber
  levelFailed,

  /// Log this event when an App user levels up.
  ///
  /// Suggested event params : levelNumber, levelName
  ///
  /// Mandatory event params : levelNumber
  levelUp,

  /// Log this event when an App user starts a level.
  ///
  /// Suggested event params : levelNumber, levelName
  ///
  /// Mandatory event params : levelNumber
  levelStarted,

  /// Log this event when an App user skips a level.
  ///
  /// Suggested event params : levelNumber, levelName
  ///
  /// Mandatory event params : levelNumber
  levelSkip,

  /// Log this event when an App user posts his score.
  ///
  /// Suggested event params : score, levelNumber
  ///
  /// Mandatory event params : score
  scorePosted,

  /// Log this event when a user rates a content in the App.
  ///
  /// Suggested event params : contentId, contentType, contentName, rating
  ///
  /// Mandatory event params : contentId, rating
  contentRated,

  /// Log this event when a specific content is viewed by a user.
  ///
  /// Suggested event params : contentId, contentType, contentName
  ///
  /// Mandatory event params : contentId
  contentViewed,

  /// Log this event when a user saves the content in the App.
  ///
  /// Suggested event params : contentId, contentType, contentName
  ///
  /// Mandatory event params : contentId
  contentSaved,

  /// Log this event when a user customizes the App/product.
  ///
  /// Suggested event params : none
  ///
  /// Mandatory event params : none
  productCustomized,

  /// Log this event when the App is activated.
  ///
  /// Suggested event params : none
  ///
  /// Mandatory event params : none
  appActivated,

  /// Log this event when a user submits an application through the App.
  ///
  /// Suggested event params : none
  ///
  /// Mandatory event params : none
  applicationSubmitted,

  /// Log this event when an item is added to the cart.
  ///
  /// Suggested event params : itemCount, price, itemId, itemName, itemType
  ///
  /// Mandatory event params : itemCount, price
  addItemToCart,

  /// Log this event when an item is added to the wish list.
  ///
  /// Suggested event params : itemCount, price, itemId, itemName, itemType
  ///
  /// Mandatory event params : itemCount, price
  addItemToWishList,

  /// Log this event when checkout is completed or transaction is successfully
  /// completed.
  ///
  /// Suggested event params : itemCount, totalAmount, currencyType, transactionId
  ///
  /// Mandatory event params : itemCount, totalAmount
  completedCheckout,

  /// Log this event when payment information is added during a checkout process.
  ///
  /// Suggested event params : success, paymentType
  ///
  /// Mandatory event params : none
  paymentInfoAdded,

  /// Log this event when an item is viewed.
  ///
  /// Suggested event params : itemId, itemName, itemType, price
  ///
  /// Mandatory event params : itemId
  itemViewed,

  /// Log this event when a list of items is viewed.
  ///
  /// Suggested event params : itemListType
  ///
  /// Mandatory event params : none
  itemListViewed,

  /// Log this event when a user does a purchase in the App.
  ///
  /// Suggested event params : itemCount, totalAmount, itemId, success,
  /// itemName, itemType, currencyType, transactionId
  ///
  /// Mandatory event params : totalAmount
  purchased,

  /// Log this event when a purchase is refunded.
  ///
  /// Suggested event params : price, currencyType
  ///
  /// Mandatory event params : price
  purchaseRefunded,

  /// Log this event when a user removes an item from the cart.
  ///
  /// Suggested event params : itemId, price, itemName, itemType
  ///
  /// Mandatory event params : itemId
  removeItemFromCart,

  /// Log this event when a user starts checkout.
  ///
  /// Suggested event params : itemCount, totalAmount
  ///
  /// Mandatory event params : itemCount, totalAmount
  checkoutInitiated,

  /// Log this event when a user donates fund to your App or through the App.
  ///
  /// Suggested event params : price, currencyType
  ///
  /// Mandatory event params : price
  fundsDonated,

  /// Log this event when user schedules an appointment using the App.
  ///
  /// Suggested event params : none
  ///
  /// Mandatory event params : none
  userScheduled,

  /// Log this event when an offer is presented to the user.
  ///
  /// Suggested event params : itemId, itemName, itemCategory, price.
  ///
  /// Mandatory event params : itemId, price
  offerPresented,

  /// Log this event at the start of a paid subscription for a service or product.
  ///
  /// Suggested event params : price, isAnnualSubscription, trialDays,
  /// predictedLTV, currencyType, subscriptionCountry
  ///
  /// Mandatory event params : price, isAnnualSubscription
  subscriptionStarted,

  /// Log this event when a user unsubscribes from a paid subscription
  /// for a service or product.
  ///
  /// Suggested event params : isAnnualSubscription, currencyType,
  /// subscriptionCountry
  ///
  /// Mandatory event params : isAnnualSubscription
  subscriptionEnded,

  /// Log this event when user joins a group.
  ///
  /// Suggested event params : groupName
  ///
  /// Mandatory event params : none
  groupJoined,

  /// Log this event when user leaves a group.
  ///
  /// Suggested event params : groupName
  ///
  /// Mandatory event params : none
  groupLeft,

  /// Log this event when a user starts a tutorial.
  ///
  /// Suggested event params : tutorialName
  ///
  /// Mandatory event params : none
  tutorialStarted,

  /// Log this event when a user completes a tutorial.
  ///
  /// Suggested event params : tutorialName
  ///
  /// Mandatory event params : none
  tutorialCompleted,

  /// Log this event when a specific tutorial step is completed.
  ///
  /// Suggested event params : stepNumber, tutorialName
  ///
  /// Mandatory event params : stepNumber
  tutorialStepCompleted,

  /// Log this event when user skips the tutorial.
  ///
  /// Suggested event params : stepNumber, tutorialName
  ///
  /// Mandatory event params : stepNumber
  tutorialSkipped,

  /// Log this event when a user login on the App.
  ///
  /// Suggested event params : userId, method
  ///
  /// Mandatory event params : none
  login,

  /// Log this event when a user logout of the App.
  ///
  /// Suggested event params : userId, method
  ///
  /// Mandatory event params : none
  logout,

  /// Log the event when a user registers (signup). Helps capture the method
  /// used to sign-up (sign up with google / apple or email address).
  ///
  /// Suggested event params : userId, method
  ///
  /// Mandatory event params : none
  userRegistered,

  /// Log this event when user views search results.
  ///
  /// Suggested event params : query, searchType (e.g. voice, text)
  ///
  /// Mandatory event params : none
  searchResultViewed,

  /// Log this event when a user searches for a keyword using Search.
  ///
  /// Suggested event params : query, searchType (e.g. voice, text)
  ///
  /// Mandatory event params : none
  keywordSearched,

  /// Log this event when a user searches for a location using Search.
  ///
  /// Suggested event params : query
  ///
  /// Mandatory event params : none
  locationSearched,

  /// Log this event when a user invites another user.
  ///
  /// Suggested event params : userId, method
  ///
  /// Mandatory event params : none
  invite,

  /// Log this event when a user shares content with another user in the App.
  ///
  /// Suggested event params : socialContentId, socialContentName, method
  ///
  /// Mandatory event params : socialContentId
  share,

  /// Log this event when a user likes a social content. e.g. likeType captures
  /// what kind of like is logged ("celebrate", "insightful", etc).
  ///
  /// Suggested event params : socialContentId, socialContentName, likeType
  ///
  /// Mandatory event params : socialContentId
  like,

  /// Log this event when a user comments or replies on a social post.
  ///
  /// Suggested event params : socialContentId, socialContentName
  ///
  /// Mandatory event params : socialContentId
  comment,

  /// Log this event when an image, audio or a video is captured.
  ///
  /// Suggested event params : mediaId, mediaName, mediaType
  ///
  /// Mandatory event params : none
  mediaCaptured,

  /// Log this event when an audio or video starts.
  ///
  /// Suggested event params : mediaId, mediaName, mediaType
  ///
  /// Mandatory event params : none
  mediaStarted,

  /// Log this event when an audio or video is stopped.
  ///
  /// Suggested event params : mediaId, duration (in seconds), mediaName, mediaType
  ///
  /// Mandatory event params : duration (in seconds)
  mediaStopped,

  /// Log this event when an audio or video is paused.
  ///
  /// Suggested event params : mediaId, duration (in seconds), mediaName, mediaType
  ///
  /// Mandatory event params : duration (in seconds)
  mediaPaused,

  /// Log this event when a privacy prompt is displayed.
  ///
  /// Suggested event params : none
  ///
  /// Mandatory event params : none
  privacyPromptDisplayed,

  /// Log this event when a user opts in (on the privacy prompt).
  ///
  /// Suggested event params : none
  ///
  /// Mandatory event params : none
  privacyOptIn,

  /// Log this event when a user opts out (on the privacy prompt).
  ///
  /// Suggested event params : none
  ///
  /// Mandatory event params : none
  privacyOptOut
}

/// [EventParam] contains all Flurry defined parameter keys to log standard event.
class EventParam {
  static final StringParam adType =
      new StringParam(StandardParam.eventParamAdType);
  static final StringParam levelName =
      new StringParam(StandardParam.eventParamLevelName);
  static final IntegerParam levelNumber =
      new IntegerParam(StandardParam.eventParamLevelNumber);
  static final StringParam contentName =
      new StringParam(StandardParam.eventParamContentName);
  static final StringParam contentType =
      new StringParam(StandardParam.eventParamContentType);
  static final StringParam contentId =
      new StringParam(StandardParam.eventParamContentId);
  static final StringParam creditName =
      new StringParam(StandardParam.eventParamCreditName);
  static final StringParam creditType =
      new StringParam(StandardParam.eventParamCreditType);
  static final StringParam creditId =
      new StringParam(StandardParam.eventParamCreditId);
  static final BooleanParam isCurrencySoft =
      new BooleanParam(StandardParam.eventParamIsCurrencySoft);
  static final StringParam currencyType =
      new StringParam(StandardParam.eventParamCurrencyType);
  static final StringParam paymentType =
      new StringParam(StandardParam.eventParamPaymentType);
  static final StringParam itemName =
      new StringParam(StandardParam.eventParamItemName);
  static final StringParam itemType =
      new StringParam(StandardParam.eventParamItemType);
  static final StringParam itemId =
      new StringParam(StandardParam.eventParamItemId);
  static final IntegerParam itemCount =
      new IntegerParam(StandardParam.eventParamItemCount);
  static final StringParam itemCategory =
      new StringParam(StandardParam.eventParamItemCategory);
  static final StringParam itemListType =
      new StringParam(StandardParam.eventParamItemListType);
  static final DoubleParam price =
      new DoubleParam(StandardParam.eventParamPrice);
  static final DoubleParam totalAmount =
      new DoubleParam(StandardParam.eventParamTotalAmount);
  static final StringParam achievementId =
      new StringParam(StandardParam.eventParamAchievementId);
  static final IntegerParam score =
      new IntegerParam(StandardParam.eventParamScore);
  static final StringParam rating =
      new StringParam(StandardParam.eventParamRating);
  static final StringParam transactionId =
      new StringParam(StandardParam.eventParamTransactionId);
  static final BooleanParam success =
      new BooleanParam(StandardParam.eventParamSuccess);
  static final BooleanParam isAnnualSubscription =
      new BooleanParam(StandardParam.eventParamIsAnnualSubscription);
  static final StringParam subscriptionCountry =
      new StringParam(StandardParam.eventParamSubscriptionCountry);
  static final IntegerParam trialDays =
      new IntegerParam(StandardParam.eventParamTrialDays);
  static final StringParam predictedLTV =
      new StringParam(StandardParam.eventParamPredictedLTV);
  static final StringParam groupName =
      new StringParam(StandardParam.eventParamGroupName);
  static final StringParam tutorialName =
      new StringParam(StandardParam.eventParamTutorialName);
  static final IntegerParam stepNumber =
      new IntegerParam(StandardParam.eventParamStepNumber);
  static final StringParam userId =
      new StringParam(StandardParam.eventParamUserId);
  static final StringParam method =
      new StringParam(StandardParam.eventParamMethod);
  static final StringParam query =
      new StringParam(StandardParam.eventParamQuery);
  static final StringParam searchType =
      new StringParam(StandardParam.eventParamSearchType);
  static final StringParam socialContentName =
      new StringParam(StandardParam.eventParamSocialContentName);
  static final StringParam socialContentId =
      new StringParam(StandardParam.eventParamSocialContentId);
  static final StringParam likeType =
      new StringParam(StandardParam.eventParamLikeType);
  static final StringParam mediaName =
      new StringParam(StandardParam.eventParamMediaName);
  static final StringParam mediaType =
      new StringParam(StandardParam.eventParamMediaType);
  static final StringParam mediaId =
      new StringParam(StandardParam.eventParamMediaId);
  static final IntegerParam duration =
      new IntegerParam(StandardParam.eventParamDuration);
}

enum StandardParam {
  eventParamAdType,
  eventParamLevelName,
  eventParamLevelNumber,
  eventParamContentName,
  eventParamContentType,
  eventParamContentId,
  eventParamCreditName,
  eventParamCreditType,
  eventParamCreditId,
  eventParamIsCurrencySoft,
  eventParamCurrencyType,
  eventParamPaymentType,
  eventParamItemName,
  eventParamItemType,
  eventParamItemId,
  eventParamItemCount,
  eventParamItemCategory,
  eventParamItemListType,
  eventParamPrice,
  eventParamTotalAmount,
  eventParamAchievementId,
  eventParamScore,
  eventParamRating,
  eventParamTransactionId,
  eventParamSuccess,
  eventParamIsAnnualSubscription,
  eventParamSubscriptionCountry,
  eventParamTrialDays,
  eventParamPredictedLTV,
  eventParamGroupName,
  eventParamTutorialName,
  eventParamStepNumber,
  eventParamUserId,
  eventParamMethod,
  eventParamQuery,
  eventParamSearchType,
  eventParamSocialContentName,
  eventParamSocialContentId,
  eventParamLikeType,
  eventParamMediaName,
  eventParamMediaType,
  eventParamMediaId,
  eventParamDuration
}

/// [Param] is the interface to use to assemble your parameters for standard event.
///
/// In order for Flurry to log a standard event, you might want to put the
/// standardized parameters as well as your own defined parameters together.
/// There will be recommended standardized parameter keys and mandatory
/// standardized parameter keys defined for each standard event name.
///
/// For instance, to log [FlurryEvent.purchased] event, SDK suggests to include
/// itemCount, totalAmount, itemId, success, itemName, itemType, currencyType
/// and transactionId parameters, in which totalAmount is also a mandatory
/// parameter that is indicated by the SDK. Since each type of standardized
/// param key can only be mapped to its corresponding data value - string,
/// integer, double, boolean, when you assemble your Param object with the
/// standardized parameters, you will need to use the APIs specified in [Param]
/// interface to map them correctly.
class Param {
  ParamBuilderAgent builderAgent;

  Param() {
    if (Platform.isAndroid || Platform.isIOS) {
      builderAgent = new ParamBuilderAgent();
    }
  }

  /// Gets the parameters map object for logging the standard events.
  Map<dynamic, String> getParameters() {
    if (builderAgent != null) {
      return builderAgent.getParameters();
    }
    return null;
  }

  /// Sets a standard event Param.
  /// Returns Param object after this procedure after parsing [param].
  Param putAll(Param param) {
    if (builderAgent != null) {
      builderAgent.putAll(param);
    }
    return this;
  }

  /// Sets a string value for a flurry param [key].
  ///
  /// Returns the Param object after setting Flurry defined param [key].
  Param putStringParam(StringParam key, String value) {
    if (builderAgent != null) {
      builderAgent.putStringParam(key, value);
    }
    return this;
  }

  /// Sets a string [value] for a string [key].
  ///
  /// Returns the Param object after setting the given value for the key.
  Param putString(String key, String value) {
    if (builderAgent != null) {
      builderAgent.putString(key, value);
    }
    return this;
  }

  /// Sets an Integer value for a flurry param [key].
  ///
  /// Returns Param object after setting integer [value] for a Flurry Defined
  /// IntegerParam [key].
  Param putIntegerParam(IntegerParam key, int value) {
    if (builderAgent != null) {
      builderAgent.putIntegerParam(key, value);
    }
    return this;
  }

  /// Sets an Integer [value] for a string [key].
  ///
  /// Returns Param object after this procedure.
  Param putInteger(String key, int value) {
    if (builderAgent != null) {
      builderAgent.putInteger(key, value);
    }
    return this;
  }

  /// Sets a Double [value] for a flurry param [key].
  ///
  /// Returns the Param object after setting double [value] for the Flurry
  /// Defined DoubleParam [key]
  Param putDoubleParam(DoubleParam key, double value) {
    if (builderAgent != null) {
      builderAgent.putDoubleParam(key, value);
    }
    return this;
  }

  /// Sets a Double [value] for a String [key].
  ///
  /// Returns Param object after this procedure.
  Param putDouble(String key, double value) {
    if (builderAgent != null) {
      builderAgent.putDouble(key, value);
    }
    return this;
  }

  /// Sets a Boolean [value] for a flurry param [key].
  ///
  /// Returns the Param object after setting boolean [value] for the Flurry
  /// Defined BooleanParam [key].
  Param putBooleanParam(BooleanParam key, bool value) {
    if (builderAgent != null) {
      builderAgent.putBooleanParam(key, value);
    }
    return this;
  }

  /// Sets a Boolean [value] for a String [key].
  ///
  /// Returns Param object after this procedure.
  Param putBoolen(String key, bool value) {
    if (builderAgent != null) {
      builderAgent.putBoolen(key, value);
    }
    return this;
  }

  /// Removes the value for a Flurry defined param [key].
  ///
  /// Returns Param object after this procedure.
  Param removeParam(ParamBase key) {
    if (builderAgent != null) {
      builderAgent.removeParam(key);
    }
    return this;
  }

  /// Removes the value for a String [key].
  ///
  /// Returns Param object after this procedure.
  Param remove(String key) {
    if (builderAgent != null) {
      builderAgent.remove(key);
    }
    return this;
  }

  /// Clears all.
  ///
  /// Returns Param object after this procedure.
  Param clear() {
    if (builderAgent != null) {
      builderAgent.clear();
    }
    return this;
  }
}

/// [ParamBase] serves as a generic class for the following types of
/// param-key classes.
abstract class ParamBase {
  StandardParam id;
}

/// [StringParam] is the class of Flurry-defined param keys which can be only
/// mapped with string value.
///
/// It is a subclass of [ParamBase].
class StringParam extends ParamBase {
  StringParam(StandardParam paramId) {
    id = paramId;
  }
}

/// [IntegerParam] is the class of Flurry-defined param keys which can be only
/// mapped with integer value.
///
/// It is a subclass of [ParamBase].
class IntegerParam with ParamBase {
  IntegerParam(StandardParam paramId) {
    id = paramId;
  }
}

/// [DoubleParam] is the class of Flurry-defined param keys which can be only
/// mapped with double value.
///
/// It is a subclass of [ParamBase].
class DoubleParam extends ParamBase {
  DoubleParam(StandardParam paramId) {
    id = paramId;
  }
}

/// [BooleanParam] is the class of Flurry-defined param keys which can be only
/// mapped with boolean value.
///
/// It is a subclass of [ParamBase].
class BooleanParam extends ParamBase {
  BooleanParam(StandardParam paramId) {
    id = paramId;
  }
}

/// Provides listener method for receiving callbacks related to publisher data
/// is fetched
mixin PublisherSegmentationListener {
  /// Informs the app when publisher data is fetched.
  ///
  /// [data] is a Map of key-value paired configuration for publisher segmentation
  /// data. [data] is nil if publisher data is not fetched or changed.
  void onFetched(Map<String, String> data);
}

class PublisherSegmentation {
  static PublisherSegmentationAgent publisherSegmentationAgent;

  PublisherSegmentation() {
    if (Platform.isIOS || Platform.isAndroid) {
      publisherSegmentationAgent = PublisherSegmentationAgent();
    }
  }

  /// Indicates whether the publisher data is fetched and ready to use.
  Future<bool> isFetchFinished() async {
    if (publisherSegmentationAgent != null) {
      return await publisherSegmentationAgent.isFetchFinished();
    }
    return false;
  }

  /// Triggers an async call to the server.
  ///
  /// Server has a throttle where when the user calls [fetch] Config many times in
  /// a row, it will basically do a no-op.
  void fetch() {
    if (publisherSegmentationAgent != null) {
      publisherSegmentationAgent.fetch();
    }
  }

  /// Registers as an observer
  void registerListener(PublisherSegmentationListener listener) {
    if (publisherSegmentationAgent != null) {
      publisherSegmentationAgent.registerListener(listener);
    }
  }

  /// Unregisters an observer
  void unregisterListener(PublisherSegmentationListener listener) {
    if (publisherSegmentationAgent != null) {
      publisherSegmentationAgent.unregisterListener(listener);
    }
  }

  /// Retrieves the fetched publisher data
  ///
  /// Returns a map of key-value paired configuration for publisher segmentation
  /// data. If not yet fetched, it will return the cached segments data.
  Future<Map<String, String>> getPublisherData() async {
    if (publisherSegmentationAgent != null) {
      return await publisherSegmentationAgent.getPublisherData();
    }
    return null;
  }
}
