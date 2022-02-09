# Flutter Flurry SDK (flutter\_flurry\_sdk)

A Flutter plugin for Flurry SDK

- **Flurry Push** for messaging and **Flurry Config** for remote configuration are supported by our plugin!

## Table of contents

- [Installation](#installation)
  - [Android](#android)
  - [iOS](#ios)
  - [tvOS](#tvos)
- [Example](#example)
- [API Reference](#api-reference)
- [Support](#support)
- [License](#license)

## Installation

1. Install Flutter Flurry SDK plugin by running this command in the terminal from the directory containing `pubspec.yaml` file. And run an implicit `flutter pub get`.

   ```bash
   $ flutter pub add flutter_flurry_sdk
   ```

2. Flutter Flurry SDK has been added as a dependency. Now, import the `flurry.dart` class in the files calling Flurry SDK APIs.

   ```dart
   import 'package:flutter_flurry_sdk/flurry.dart';
   ```

### Android

- By default, Flurry adds `INTERNET` and `ACCESS_NETWORK_STATE` permissions to optimize analytics data. Please see [Manual Flurry Android SDK Integration](https://developer.yahoo.com/flurry/docs/integrateflurry/android-manual/) for the other recommended options.
- To improve analytics identities, please see [Manual Flurry Android SDK Integration](https://developer.yahoo.com/flurry/docs/integrateflurry/android-manual/) for adding Google Play Services library in your app by including the following in your `build.gradle` file:

  ```groovy
  dependencies {
      // Recommended to add Google Play Services
      implementation 'com.google.android.gms:play-services-ads-identifier:17.1.0'
  }
  ```

- **Flurry Push**</br>
  In order to use [Flurry Push](https://developer.yahoo.com/flurry/docs/push/) for [Android](https://developer.yahoo.com/flurry/docs/push/integration/android/), please follow the additional steps below:
  1. Android Flurry Push requires your projects to initialize Flurry from the native Application class. Please implement a custom application class if it does not exist by extending FlutterApplication, and apply the Flurry setup in the `onCreate()` method. Remember to register the class in the AndroidManifest by adding `android:name=".MyFlutterApplication"` to `<application>` attributes. With the same APIs as the JavaScript version.

     ```xml
     // AndroidManifest.xml
     <application
         android:name=".MyFlutterApplication"
     ```
     
     ```java
     import com.flurry.android.flutter.FlurryFlutterPlugin;
     
     public class MyFlutterApplication extends FlutterApplication {
     
         @Override
         public void onCreate() {
             super.onCreate();
             
             new FlurryFlutterPlugin.Builder()
                 .withCrashReporting(true)
                 .withLogEnabled(true)
                 .withLogLevel(Log.VERBOSE)
                 .withMessaging(true, options_or_listener) // optional user's native `FlurryMarketingOptions` or `FlurryMessagingListener`.
                 .build(this, FLURRY_ANDROID_API_KEY);
     ```

  2. Follow [Add Firebase to your Flutter app](https://firebase.google.com/docs/flutter/setup?platform=android). Complete "Add a Firebase configuration file" step for adding Firebase to your Android project. There should be a file `google-services.json` in your project's `android/app` folder now. You do not need to "Add FlutterFire plugins". Your `build.gradle` will look like:

     ```groovy
        // android/build.gradle (project-level)
        buildscript {
            dependencies {
                classpath 'com.google.gms:google-services:4.3.10'
            }
        }
     ```

     ```groovy
        // android/app/build.gradle (app-level)
        apply plugin: 'com.google.gms.google-services'

        dependencies {
            implementation 'com.google.firebase:firebase-messaging:21.1.0'
        }
     ```

  3. Set up "Android Authorization" in Flurry [Push Authorization](https://developer.yahoo.com/flurry/docs/push/authorization/).

### iOS

- **Flurry Push**</br>
  To set up Flurry Push, please take the following steps.

  1. Open your `.xcworkspace` file which is under the `ios` folder. Go to "Capabilities" tab and enable Push Notifications.
     ![push_ios_1](https://github.com/flurry/flutter-flurry-sdk/raw/main/images/push_ios_1.png)
  2. Enable Background Modes (Background Fetch and Remote Notifications turned on).
     ![push_ios_2](https://github.com/flurry/flutter-flurry-sdk/raw/main/images/push_ios_2.png)
     Now your `Info.plist` should contain the following items. For more information, please see [Push Setup](https://developer.yahoo.com/flurry/docs/push/integration/ios/).
     ![push_ios_3](https://github.com/flurry/flutter-flurry-sdk/raw/main/images/push_ios_3.png)
  3. Set up "iOS Authorization" in Flurry [Push Authorization](https://developer.yahoo.com/flurry/docs/push/authorization/).

### tvOS

- Please note that Flurry Messaging and Flurry Config are currently not available on tvOS. For the detailed list of unavailable APIs, please see API reference below.

## Example

- `lib/main.dart`

   ```dart
   import 'package:flutter/material.dart';
   import 'dart:async';
   
   import 'package:flutter_flurry_sdk/flurry.dart';
   
   // Init Flurry once as early as possible recommended in main.dart.
   // For each platform (Android, iOS) where the app runs you need to acquire a unique Flurry API Key.
   // i.e., you need two API keys if you are going to release the app on both Android and iOS platforms.
   // If you are building for TV platforms, you will need two API keys for Android TV and tvOS.
   Flurry.builder
       .withCrashReporting(true)
       .withLogEnabled(true)
       .withLogLevel(LogLevel.debug)
       .build(
           androidAPIKey: FLURRY_ANDROID_API_KEY,
               iosAPIKey: FLURRY_IOS_API_KEY);
   ```

- `lib/example.dart`

   ```dart
   import 'package:flutter_flurry_sdk/flurry.dart';
   
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
   Flurry.userProperties.setValue(UserProperties.propertyRegisteredUser, 'True');
   
   // Log Flurry events.
   Flurry.logEvent('Flutter Event');
   var map = <String, String>{};
   for (int i = 0; i < 6; i++) {
       map.putIfAbsent('$i', () => '$i');
   }
   Flurry.logTimedEventWithParameters('Flutter Timed Event', map, true);
   ...
   Flurry.endTimedEvent('Flutter Timed Event');
   
   // Log Flurry standard events.
   var paramBuilder = Param()
       .putDoubleParam(EventParam.totalAmount, 34.99)
       .putBooleanParam(EventParam.success, true)
       .putStringParam(EventParam.itemName, 'book 1')
       .putString('note', 'This is an awesome book to purchase !!!');
   Flurry.logStandardEvent(FlurryEvent.purchased, paramBuilder);
   ...
   ```

- `lib/config.dart`

   ```dart
   Flurry.config.registerListener(MyConfigListener());
   Flurry.config.fetchConfig();
   
   class MyConfigListener with ConfigListener {
       @override
       void onFetchSuccess() {
           // Data fetched, activate it.
           Flurry.config.activateConfig();
       }
   
       @override
       void onFetchNoChange() {
           // Fetch finished, but data unchanged.
           Flurry.config.getConfigString('welcome_message', 'Welcome').then((welcomeMessage) {
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
           Flurry.config.getConfigString('welcome_message', 'Welcome').then((welcomeMessage) {
               print((isCache ? 'Received cached data: $welcomeMessage' : 'Received newly activated data: $welcomeMessage'));
           });
       }
   }
   ```

- `lib/messaging.dart`

   ```dart
   // To enable Flurry Push for Android, please duplicate Builder setup in your
   Flurry.builder
       .withMessaging(true)
   ...
   
   // Optionally add a listener to receive messaging events, and handle the notification.
   Flurry.builder
       .withMessaging(true, MyMessagingListener())
   ...
   
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
               '\n    Title: $message.title'
               '\n    Body: $message.body'
               '\n    ClickAction: $message.clickAction'
               '\n    Data: $message.appData');
       }
   }
   ```

- `lib/publisher.dart`

   ```dart
   Flurry.publisherSegmentation.registerListener(MyPublisherSegmentationListener());
   Flurry.publisherSegmentation.fetch();
   
   class MyPublisherSegmentationListener with PublisherSegmentationListener {
       @override
       void onFetched(Map<String, String> data) {
          print('Publisher Segmentation data fetched: $data');
       }
   }
   ```

## API Reference

See [Android](https://flurry.github.io/flurry-android-sdk/analytics/index.html)-[(FlurryAgent)](https://flurry.github.io/flurry-android-sdk/analytics/com/flurry/android/FlurryAgent.html) /
[iOS](https://flurry.github.io/flurry-ios-sdk/Flurry%20Analytics%20API%20Documentation/index.html)-[(Flurry)](https://flurry.github.io/flurry-ios-sdk/Flurry%20Analytics%20API%20Documentation/interface_flurry.html) for the Flurry references.

- **Methods in Flurry.builder to initialize Flurry Agent**

  ```dart
  Builder withAppVersion(String versionName);  // iOS only. For Android, please use Flurry.setVersionName() instead.
  Builder withContinueSessionMillis(int sessionMillis);
  Builder withCrashReporting(bool crashReporting);
  Builder withDataSaleOptOut(bool isOptOut);
  Builder withIncludeBackgroundSessionsInMetrics(bool includeBackgroundSessionsInMetrics);
  Builder withLogEnabled(bool enableLog);
  Builder withLogLevel(LogLevel logLevel); // LogLevel = { verbose, debug, info, warn, error, assertion }
  Builder withMessaging(bool enableMessaging, MessagingListener listener);
  Builder withPerformanceMetrics(int performanceMetrics); // Performance = { none, coldStart, screenTime, all }
  Builder withSslPinningEnabled(bool sslPinningEnabled); // Android only

  void build(String androidAPIKey, String iosAPIKey);
  ```

- **Methods to set Flurry preferences**

  ```dart
  void Flurry.setContinueSessionMillis(int sessionMillis);
  void Flurry.setCrashReporting(bool crashReporting);
  void Flurry.setIncludeBackgroundSessionsInMetrics(bool includeBackgroundSessionsInMetrics);
  void Flurry.setLogEnabled(bool enableLog);
  void Flurry.setLogLevel(LogLevel logLevel); // LogLevel = { verbose, debug, info, warn, error, assertion }
  void Flurry.setSslPinningEnabled(bool sslPinningEnabled); // Android only
  ```

- **Methods to set user preferences**

  ```dart
  void Flurry.setAge(int age);
  void Flurry.setGender(Gender gender);
  void Flurry.setReportLocation(bool reportLocation);
  void Flurry.setSessionOrigin(String originName, String deepLink);
  void Flurry.setUserId(String userId);
  void Flurry.setVersionName(String versionName);

  void Flurry.addOrigin(String originName, String originVersion);
  void Flurry.addOriginWithParameters(String originName, String originVersion, Map<String, String> parameters);
  void Flurry.addSessionProperty(String propertyName, String propertyValue);
  ```

- **Methods to set privacy preferences**

  ```dart
  void Flurry.setDataSaleOptOut(bool isOptOut);
  void Flurry.deleteData();
  void Flurry.openPrivacyDashboard();
  ```

- **Methods in Flurry.userProperties to set user properties**

  ```dart
  // Standard User Properties: UserProperties = {
  //     propertyCurrencyPreference, propertyPurchaser, propertyRegisteredUser, propertySubscriber }
  void setValue    (String propertyName, String       propertyValue);
  void setValues   (String propertyName, List<String> propertyValues);
  void addValue    (String propertyName, String       propertyValue);
  void addValues   (String propertyName, List<String> propertyValues);
  void remove      (String propertyName);
  void removeValue (String propertyName, String       propertyValue);
  void removeValues(String propertyName, List<String> propertyValues);
  void flag        (String propertyName);
  ```

- **Methods to get Flurry versions and publisher segmentation**

  ```dart
  int Flurry.getAgentVersion();
  String Flurry.getReleaseVersion();
  String Flurry.getSessionId();
  String Flurry.getPlatformVersion();

  mixin PublisherSegmentationListener {
      void onFetched(Map<String, String> data);
  }

  // in Flurry.publisherSegmentation
  void registerListener  (PublisherSegmentationListener listener);
  void unregisterListener(PublisherSegmentationListener listener);
  bool isFetchFinished();
  void fetch();
  Map<String, String> getPublisherData();
  ```

- **Methods to log Flurry events**

  ```dart
  enum EventRecordStatus {
      eventFailed,
      eventRecorded,
      eventUniqueCountExceeded,
      eventParamsCountExceeded,
      eventLoggingDelayed,
      eventAnalyticsDisabled,
      eventParametersMismatched
  }

  EventRecordStatus Flurry.logEvent(String eventId);
  EventRecordStatus Flurry.logEventWithParameters(String eventId, Map<String, String> parameters);
  EventRecordStatus Flurry.logTimedEvent(String eventId, bool timed);
  EventRecordStatus Flurry.logTimedEventWithParamters(String eventId, Map<String, String> parameters, bool timed);

  void Flurry.endTimedEvent(String eventId);
  void Flurry.endTimedEventWithParameters(String eventId, Map<String, String> parameters);

  EventRecordStatus Flurry.logStandardEvent(StandardEventId id, Param param);

  void Flurry.onError(String errorId, String message, String errorClass);
  void Flurry.onErrorWithParameters(String errorId, String message, String errorClass, Map<String, String> parameters);

  void Flurry.logBreadcrumb(String crashBreadcrumb);
  
  EventRecordStatus Flurry.logPayment(String productName, String productId, int quantity, double price,
                                      String currency, String transactionId, Map<String, String> parameters);
  ```

- **Methods to enable IAP reporting(iOS)**

  ```dart
  void Flurry.setIAPReportingEnabled(bool enableIAP);
  ```

- **Methods to set the iOS conversion value sent to Apple through SKAdNetwork (iOS)**

  ```dart
  void Flurry.updateConversionValue(int conversionValue);
  void Flurry.updateConversionValueWithEvent(SKAdNetworkEvent flurryEvent);
  ```

- **Methods in Flurry.performance to log Flurry Performance Metrics**

  ```dart
  void startResourceLogger();
  void logResourceLogger();
  void reportFullyDrawn();
  ```

- **Methods in Flurry.config for Flurry Config**

  ```dart
  mixin ConfigListener{
      void onFetchSuccess();
      void onFetchNoChange();
      void onFetchError(bool isRetrying);
      void onActivateComplete(bool isCache);
  }

  void registerListener  (ConfigListener listener);
  void unregisterListener(ConfigListener listener);
  void fetchConfig();
  void activateConfig();
  String getConfigString(String key, String defaultValue);
  ```

- **Methods for Messaging Listener**

  ```dart
  mixin MessagingListener{
      bool onNotificationReceived(Message message);  
      bool onNotificationClicked(Message message);
      void onNotificationCancelled(Message message);
      void onTokenRefresh(String token);
  }

  class Message {
      String title;
      String body;
      String clickAction;
      Map<String, String> appData;
  }
  ```

- **Methods for Standard Event - Param (builder setters and getters)**

  ```dart
  Map<dynamic, String> getParameters();
  Param clear();
  Param removeParam(ParamBase param);
  Param remove(String key);
  Param putAll(Param param);
  Param putStringParam(StringParam key, String value);
  Param putString(String key, String value);
  Param putIntegerParam(IntegerParam key, int value);
  Param putInteger(String key, int value);
  Param putDoubleParam(DoubleParam key, double value);
  Param putDouble(String key, double value);
  Param putBooleanParam(BooleanParam key, bool value);
  Param putBoolen(String key, bool value);
  ```

- **FlurryEvent enum for Standard Event Id (Event Name)**

  ```dart
  enum FlurryEvent{
      /// Log this event when a user clicks on an Ad.
      /// Suggested event params: adType
      /// Mandatory event params: none
      adClick,

      /// Log this event when a user views an Ad impression.
      /// Suggested event params: adType
      /// Mandatory event params: none
      adImpression,
      
      /// Log this event when a user is granted a reward for viewing a rewarded Ad.
      /// Suggested event params: adType
      /// Mandatory event params: none
      adRewarded,

      /// Log this event when a user skips an Ad
      /// Suggested event params: adType
      /// Mandatory event params: none
      adSkipped,

      /// Log this event when a user spends credit in the app
      /// Suggested event params: levelNumber, totalAmount, isCurrencySoft, creditType, creditId, creditName, currencyType
      /// Mandatory event params: totalAmount
      creditsSpent,

      /// Log this event when a user purchases credit in the app
      /// Suggested event params: levelNumber, totalAmount, isCurrencySoft, creditType, creditId, creditName, currencyType
      /// Mandatory event params: totalAmount
      creditsPurchased,

      /// Log this event when a user earns credit in the app
      /// Suggested event params: levelNumber, totalAmount, isCurrencySoft, creditType, creditId, creditName, currencyType
      /// Mandatory event params: totalAmount
      creditsEarned,

      /// Log this event when a user unlocks an achievement in the app
      /// Suggested event params: achievementId
      /// Mandatory event params: none
      achievementUnlocked,

      /// Log this event when an App user completes a level
      /// Suggested event params: levelNumber, levelName
      /// Mandatory event params: levelNumber
      levelCompleted,

      /// Log this event when an App user fails a level
      /// Suggested event params: levelNumber, levelName
      /// Mandatory event params: levelNumber
      levelFailed,

      /// Log this event when an App user levels up
      /// Suggested event params: levelNumber, levelName
      /// Mandatory event params: levelNumber
      levelUp,

      /// Log this event when an App user starts a level
      /// Suggested event params: levelNumber, levelName
      /// Mandatory event params: levelNumber
      levelStarted,

      /// Log this event when an App user skips a level
      /// Suggested event params: levelNumber, levelName
      /// Mandatory event params: levelNumber
      levelSkip,

      /// Log this event when an App user posts his score
      /// Suggested event params: score, levelNumber
      /// Mandatory event params: score
      scorePosted,

      /// Log this event when a user rates a content in the App
      /// Suggested event params: contentId, contentType, contentName, rating
      /// Mandatory event params: contentId, rating
      contentRated,

      /// Log this event when a specific content is viewed by a user
      /// Suggested event params: contentId, contentType, contentName
      /// Mandatory event params: contentId
      contentViewed,

      /// Log this event when a user saves the content in the App
      /// Suggested event params: contentId, contentType, contentName
      /// Mandatory event params: contentId
      contentSaved,

      /// Log this event when a user customizes the App/product
      /// Suggested event params: none
      /// Mandatory event params: none
      productCustomized,

      /// Log this event when the App is activated
      /// Suggested event params: none
      /// Mandatory event params: none
      appActivated,

      /// Log this event when a user submits an application through the App
      /// Suggested event params: none
      /// Mandatory event params: none
      applicationSubmitted,

      /// Log this event when an item is added to the cart
      /// Suggested event params: itemCount, price, itemId, itemName, itemType
      /// Mandatory event params: itemCount, price
      addItemToCart,

      /// Log this event when an item is added to the wish list
      /// Suggested event params: itemCount, price, itemId, itemName, itemType
      /// Mandatory event params: itemCount, price
      addItemToWishList,

      /// Log this event when checkout is completed or transaction is successfully completed
      /// Suggested event params: itemCount, totalAmount, currencyType, transactionId
      /// Mandatory event params: itemCount, totalAmount
      completedCheckout,

      /// Log this event when payment information is added during a checkout process
      /// Suggested event params: success, paymentType
      /// Mandatory event params: none
      paymentInfoAdded,

      /// Log this event when an item is viewed
      /// Suggested event params: itemId, itemName, itemType, price
      /// Mandatory event params: itemId
      itemViewed,

      /// Log this event when a list of items is viewed
      /// Suggested event params: itemListType
      /// Mandatory event params: none
      itemListViewed,

      /// Log this event when a user does a purchase in the App
      /// Suggested event params: itemCount, totalAmount, itemId, success, itemName, itemType, currencyType, transactionId
      /// Mandatory event params: totalAmount
      purchased,

      /// Log this event when a purchase is refunded
      /// Suggested event params: price, currencyType
      /// Mandatory event params: price
      purchaseRefunded,

      /// Log this event when a user removes an item from the cart
      /// Suggested event params: itemId, price, itemName, itemType
      /// Mandatory event params: itemId
      removeItemFromCart,

      /// Log this event when a user starts checkout
      /// Suggested event params: itemCount, totalAmount
      /// Mandatory event params: itemCount, totalAmount
      checkoutInitiated,

      /// Log this event when a user donates fund to your App or through the App
      /// Suggested event params: price, currencyType
      /// Mandatory event params: price
      fundsDonated,

      /// Log this event when user schedules an appointment using the App
      /// Suggested event params: none
      /// Mandatory event params: none
      userScheduled,

      /// Log this event when an offer is presented to the user
      /// Suggested event params: itemId, itemName, itemCategory, price
      /// Mandatory event params: itemId, price
      offerPresented,

      /// Log this event at the start of a paid subscription for a service or product
      /// Suggested event params: price, isAnnualSubscription, trialDays, predictedLTV, currencyType, subscriptionCountry
      /// Mandatory event params: price, isAnnualSubscription
      subscriptionStarted,

      /// Log this event when a user unsubscribes from a paid subscription
      /// for a service or product
      /// Suggested event params: isAnnualSubscription, currencyType, subscriptionCountry
      /// Mandatory event params: isAnnualSubscription
      subscriptionEnded,

      /// Log this event when user joins a group.
      /// Suggested event params: groupName
      /// Mandatory event params: none
      groupJoined,

      /// Log this event when user leaves a group
      /// Suggested event params: groupName
      /// Mandatory event params: none
      groupLeft,

      /// Log this event when a user starts a tutorial
      /// Suggested event params: tutorialName
      /// Mandatory event params: none
      tutorialStarted,

      /// Log this event when a user completes a tutorial
      /// Suggested event params: tutorialName
      /// Mandatory event params: none
      tutorialCompleted,

      /// Log this event when a specific tutorial step is completed
      /// Suggested event params: stepNumber, tutorialName
      /// Mandatory event params: stepNumber
      tutorialStepCompleted,

      /// Log this event when user skips the tutorial
      /// Suggested event params: stepNumber, tutorialName
      /// Mandatory event params: stepNumber
      tutorialSkipped,

      /// Log this event when a user login on the App
      /// Suggested event params: userId, method
      /// Mandatory event params: none
      login,

      /// Log this event when a user logout of the App
      /// Suggested event params: userId, method
      /// Mandatory event params: none
      logout,

      /// Log the event when a user registers (signup). Helps capture the method
      /// used to sign-up (sign up with google / apple or email address)
      /// Suggested event params: userId, method
      /// Mandatory event params: none
      userRegistered,

      /// Log this event when user views search results
      /// Suggested event params: query, searchType (e.g. voice, text)
      /// Mandatory event params: none
      searchResultViewed,

      /// Log this event when a user searches for a keyword using Search
      /// Suggested event params: query, searchType (e.g. voice, text)
      /// Mandatory event params: none
      keywordSearched,

      /// Log this event when a user searches for a location using Search
      /// Suggested event params: query
      /// Mandatory event params: none
      locationSearched,

      /// Log this event when a user invites another user
      /// Suggested event params: userId, method
      /// Mandatory event params: none
      invite,

      /// Log this event when a user shares content with another user in the App
      /// Suggested event params: socialContentId, socialContentName, method
      /// Mandatory event params: socialContentId
      share,

      /// Log this event when a user likes a social content. e.g. likeType captures
      /// what kind of like is logged ("celebrate", "insightful", etc)
      /// Suggested event params: socialContentId, socialContentName, likeType
      /// Mandatory event params: socialContentId
      like,

      /// Log this event when a user comments or replies on a social post
      /// Suggested event params: socialContentId, socialContentName
      /// Mandatory event params: socialContentId
      comment,

      /// Log this event when an image, audio or a video is captured
      /// Suggested event params: mediaId, mediaName, mediaType
      /// Mandatory event params: none
      mediaCaptured,

      /// Log this event when an audio or video starts
      /// Suggested event params: mediaId, mediaName, mediaType
      /// Mandatory event params: none
      mediaStarted,

      /// Log this event when an audio or video is stopped
      /// Suggested event params: mediaId, duration (in seconds), mediaName, mediaType
      /// Mandatory event params: duration (in seconds)
      mediaStopped,

      /// Log this event when an audio or video is paused
      /// Suggested event params: mediaId, duration (in seconds), mediaName, mediaType
      /// Mandatory event params: duration (in seconds)
      mediaPaused,

      /// Log this event when a privacy prompt is displayed
      /// Suggested event params: none
      /// Mandatory event params: none
      privacyPromptDisplayed,

      /// Log this event when a user opts in (on the privacy prompt)
      /// Suggested event params: none
      /// Mandatory event params: none
      privacyOptIn,

      /// Log this event when a user opts out (on the privacy prompt)
      /// Suggested event params: none
      /// Mandatory event params: none
      privacyOptOut
  }
  ```

- **EventParam types for Standard Event parameter (Param Type)**

  ```dart
  StringParam  adType;
  StringParam  levelName;
  IntegerParam levelNumber;
  StringParam  contentName;
  StringParam  contentType;
  StringParam  contentId;
  StringParam  creditName;
  StringParam  creditType;
  StringParam  creditId;
  StringParam  currencyType;
  BooleanParam isCurrencySoft;
  StringParam  itemName;
  StringParam  itemType;
  StringParam  itemId;
  IntegerParam itemCount;
  StringParam  itemCategory;
  StringParam  itemListType;
  DoubleParam  price;
  DoubleParam  totalAmount;
  StringParam  achievementId;
  IntegerParam score;
  StringParam  rating;
  StringParam  transactionId;
  BooleanParam success;
  StringParam  paymentType;
  BooleanParam isAnnualSubscription;
  StringParam  subscriptionCountry;
  IntegerParam trialDays;
  StringParam  predictedLTV;
  StringParam  groupName;
  IntegerParam stepNumber;
  StringParam  tutorialName;
  StringParam  userId;
  StringParam  method;
  StringParam  query;
  StringParam  searchType;
  StringParam  socialContentName;
  StringParam  socialContentId;
  StringParam  likeType;
  StringParam  mediaName;
  StringParam  mediaType;
  StringParam  mediaId;
  IntegerParam duration;
  ```

## Support
- [Flurry Developer Support Site](https://developer.yahoo.com/flurry/docs/)

## License

Copyright 2022 Yahoo Inc.

This project is licensed under the terms of the [Apache 2.0](https://www.apache.org/licenses/LICENSE-2.0) open source license. Please refer to [LICENSE](https://raw.githubusercontent.com/flurry/flutter-flurry-sdk/main/LICENSE) for the full terms.
