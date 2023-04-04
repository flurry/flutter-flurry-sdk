/*
 * Copyright 2021, Yahoo Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package com.flurry.android.flutter;

import android.content.Context;
import android.os.Handler;
import android.os.HandlerThread;
import android.os.Looper;
import android.util.Log;

import androidx.annotation.NonNull;

import com.flurry.android.FlurryAgent;
import com.flurry.android.FlurryConfig;
import com.flurry.android.FlurryConfigListener;
import com.flurry.android.FlurryEvent;
import com.flurry.android.FlurryEventRecordStatus;
import com.flurry.android.FlurryPerformance;
import com.flurry.android.FlurryPrivacySession;
import com.flurry.android.FlurryPublisherSegmentation;
import com.flurry.android.marketing.FlurryMarketingModule;
import com.flurry.android.marketing.FlurryMarketingOptions;
import com.flurry.android.marketing.messaging.FlurryMessagingListener;
import com.flurry.android.marketing.messaging.notification.FlurryMessage;

import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

public class FlurryFlutterPlugin implements FlutterPlugin, MethodCallHandler, ActivityAware {
    private static final String TAG = "FlurryFlutterPlugin";

    private static final String ORIGIN_NAME = "flutter-flurry-sdk";
    private static final String ORIGIN_VERSION = "3.2.0";

    private Context context;

    private static FlurryAgent.Builder builder;
    private static FlurryPerformance.ResourceLogger flurryResourceLogger;
    private static FlutterFlurryConfigListener sFlutterFlurryConfigListener;
    private static FlutterFlurryPublisherListener sFlutterFlurryPublisherListener;
    private static boolean messagingInitialized = false;

    /**
     * The MethodChannel/EventChannel that will the communication between Flutter and native Android
     *
     * This local reference serves to register the plugin with the Flutter Engine and unregister it
     * when the Flutter Engine is detached from the Activity
     */
    private MethodChannel channel;
    private EventChannel configEventChannel;
    private EventChannel messagingEventChannel;
    private EventChannel publisherEventChannel;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        context = flutterPluginBinding.getApplicationContext();

        channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "flurry_flutter_plugin");
        channel.setMethodCallHandler(this);

        // Set up Flurry Config event channel
        configEventChannel = new EventChannel(flutterPluginBinding.getBinaryMessenger(),"flurry_flutter_plugin_event_config");
        configEventChannel.setStreamHandler(new EventChannel.StreamHandler() {
            @Override
            public void onListen(Object listener, EventChannel.EventSink eventSink) {
                if (sFlutterFlurryConfigListener == null) {
                    sFlutterFlurryConfigListener = new FlutterFlurryConfigListener(eventSink);
                    FlurryConfig.getInstance().registerListener(sFlutterFlurryConfigListener);
                }
            }

            @Override
            public void onCancel(Object listener) {
            }
        });

        // Set up Flurry Push (Messaging) event channel
        messagingEventChannel = new EventChannel(flutterPluginBinding.getBinaryMessenger(),"flurry_flutter_plugin_event_messaging");
        messagingEventChannel.setStreamHandler(new EventChannel.StreamHandler() {
            @Override
            public void onListen(Object listener, EventChannel.EventSink eventSink) {
                FlutterFlurryMessagingListener.setEventSink(eventSink);
            }

            @Override
            public void onCancel(Object listener) {
            }
        });

        // Set up Flurry Publisher Segmentation event channel
        publisherEventChannel = new EventChannel(flutterPluginBinding.getBinaryMessenger(),"flurry_flutter_plugin_event_ps");
        publisherEventChannel.setStreamHandler(new EventChannel.StreamHandler() {
            @Override
            public void onListen(Object listener, EventChannel.EventSink eventSink) {
                if (sFlutterFlurryPublisherListener == null) {
                    sFlutterFlurryPublisherListener = new FlutterFlurryPublisherListener(eventSink);
                    FlurryPublisherSegmentation.registerFetchListener(sFlutterFlurryPublisherListener);
                }
            }

            @Override
            public void onCancel(Object listener) {
            }
        });
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
        configEventChannel.setStreamHandler(null);
        messagingEventChannel.setStreamHandler(null);
        publisherEventChannel.setStreamHandler(null);
    }

    @Override
    public void onDetachedFromActivity() {
    }

    @Override
    public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
    }

    @Override
    public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        switch(call.method) {
            case "initializeFlurryBuilder":
                initializeFlurryBuilder();
                break;
            case "buildFlurryBuilder":
                String apiKey = call.argument("apiKey");
                buildFlurryBuilder(apiKey);
                break;
            case "withAppVersion":
                String appVersion = call.argument("appVersion");
                withAppVersion(appVersion);
                break;
            case "withContinueSessionMillis":
                String sessionMillisStr = call.argument("sessionMillisStr");
                withContinueSessionMillis(sessionMillisStr);
                break;
            case "withCrashReporting":
                boolean crashReporting = call.<Boolean>argument("crashReporting");
                withCrashReporting(crashReporting);
                break;
            case "withGppConsent":
                String gppString = call.argument("gppString");
                List<Integer> gppSectionIds = call.argument("gppSectionIds");
                builder.withGppConsent(gppString, new HashSet<>(gppSectionIds));
                break;
            case "withDataSaleOptOut":
                boolean isOptOut = call.<Boolean>argument("isOptOut");
                withDataSaleOptOut(isOptOut);
                break;
            case "withIncludeBackgroundSessionsInMetrics":
                boolean includeBackgroundSessionsInMetrics = call.<Boolean>argument("includeBackgroundSessionsInMetrics");
                withIncludeBackgroundSessionsInMetrics(includeBackgroundSessionsInMetrics);
                break;
            case "withLogEnabled":
                boolean enableLog = call.<Boolean>argument("enableLog");
                withLogEnabled(enableLog);
                break;
            case "withLogLevel":
                String logLevelStr = call.argument("logLevelStr");
                withLogLevel(logLevelStr);
                break;
            case "withReportLocation":
                boolean reportLocation = call.<Boolean>argument("reportLocation");
                builder.withReportLocation(reportLocation);
                break;
            case "withPerformanceMetrics":
                int performanceMetrics = call.<Integer>argument("performanceMetrics");
                withPerformanceMetrics(performanceMetrics);
                break;
            case "withSslPinningEnabled":
                boolean sslPinningEnabled = call.<Boolean>argument("sslPinningEnabled");
                builder.withSslPinningEnabled(sslPinningEnabled);
                break;
            case "withMessaging":
                withMessaging();
                break;
            case "setContinueSessionMillis":
                sessionMillisStr = call.argument("sessionMillisStr");
                long millis = Long.parseLong(sessionMillisStr);
                FlurryAgent.setContinueSessionMillis(millis);
                break;
            case "setCrashReporting":
                crashReporting = call.<Boolean>argument("crashReporting");
                FlurryAgent.setCaptureUncaughtExceptions(crashReporting);
                break;
            case "setIncludeBackgroundSessionsInMetrics":
                includeBackgroundSessionsInMetrics = call.<Boolean>argument("includeBackgroundSessionsInMetrics");
                FlurryAgent.setIncludeBackgroundSessionsInMetrics(includeBackgroundSessionsInMetrics);
                break;
            case "setLogEnabled":
                enableLog = call.<Boolean>argument("enableLog");
                FlurryAgent.setLogEnabled(enableLog);
                break;
            case "setLogLevel":
                logLevelStr = call.argument("logLevelStr");
                int logLevel = Integer.parseInt(logLevelStr);
                FlurryAgent.setLogLevel(logLevel);
                break;
            case "setSslPinningEnabled":
                sslPinningEnabled = call.<Boolean>argument("sslPinningEnabled");
                FlurryAgent.setSslPinningEnabled(sslPinningEnabled);
                break;
            case "addUserPropertyValue":
                String propertyName = call.argument("propertyName");
                String propertyValue = call.argument("propertyValue");
                addUserPropertyValue(propertyName, propertyValue);
                break;
            case "addUserPropertyValues":
                propertyName = call.argument("propertyName");
                List<String> propertyValues = call.argument("propertyValues");
                addUserPropertyValues(propertyName, propertyValues);
                break;
            case "flagUserProperty":
                propertyName = call.argument("propertyName");
                flagUserProperty(propertyName);
                break;
            case "removeUserProperty":
                propertyName = call.argument("propertyName");
                removeUserProperty(propertyName);
                break;
            case "removeUserPropertyValue":
                propertyName = call.argument("propertyName");
                propertyValue = call.argument("propertyValue");
                removeUserPropertyValue(propertyName, propertyValue);
                break;
            case "removeUserPropertyValues":
                propertyName = call.argument("propertyName");
                propertyValues = call.argument("propertyValues");
                removeUserPropertyValues(propertyName, propertyValues);
                break;
            case "setUserPropertyValue":
                propertyName = call.argument("propertyName");
                propertyValue = call.argument("propertyValue");
                setUserPropertyValue(propertyName, propertyValue);
                break;
            case "setUserPropertyValues":
                propertyName = call.argument("propertyName");
                propertyValues = call.argument("propertyValues");
                setUserPropertyValues(propertyName, propertyValues);
                break;
            case "reportFullyDrawn":
                reportFullyDrawn();
                break;
            case "startResourceLogger":
                startResourceLogger();
                break;
            case "logResourceLogger":
                String id = call.argument("id");
                logResourceLogger(id);
                break;
            case "setAge":
                String ageStr = call.argument("ageStr");
                setAge(ageStr);
                break;
            case "setGender":
                String gender = call.argument("gender");
                if (gender != null) {
                    setGender(gender);
                }
                break;
            case "setReportLocation":
                reportLocation = call.<Boolean>argument("reportLocation");
                setReportLocation(reportLocation);
                break;
            case "setSessionOrigin":
                String originName = call.argument("originName");
                String deepLink = call.argument("deepLink");
                setSessionOrigin(originName, deepLink);
                break;
            case "setUserId":
                String userId = call.argument("userId");
                setUserId(userId);
                break;
            case "setVersionName":
                String versionName = call.argument("versionName");
                setVersionName(versionName);
                break;
            case "addOrigin":
                originName = call.argument("originName");
                String originVersion = call.argument("originVersion");
                addOrigin(originName, originVersion);
                break;
            case "addOriginWithParameters":
                originName = call.argument("originName");
                originVersion = call.argument("originVersion");
                Map<String, String> parameters = call.argument("originParameters");
                addOriginWithParameters(originName, originVersion, parameters);
                break;
            case "addSessionProperty":
                String sessionName = call.argument("name");
                String sessionValue = call.argument("value");
                addSessionProperty(sessionName, sessionValue);
                break;
            case "setIAPReportingEnabled":
                setIAPReportingEnabled();
                break;
            case "setGppConsent":
                gppString = call.argument("gppString");
                gppSectionIds = call.argument("gppSectionIds");
                FlurryAgent.setGppConsent(gppString, new HashSet<>(gppSectionIds));
                break;
            case "setDataSaleOptOut":
                isOptOut = call.<Boolean>argument("isOptOut");
                setDataSaleOptOut(isOptOut);
                break;
            case "deleteData":
                deleteData();
                break;
            case "openPrivacyDashboard":
                openPrivacyDashboard();
                break;
            case "getPlatformVersion":
                result.success("Android " + android.os.Build.VERSION.RELEASE);
                break;
            case "getAgentVersion":
                int agentVersion = getAgentVersion();
                result.success(agentVersion);
                break;
            case "getReleaseVersion":
                String releaseVersion = getReleaseVersion();
                result.success(releaseVersion);
                break;
            case "getSessionId":
                String sessionId = getSessionId();
                result.success(sessionId);
                break;
            case "logEvent":
                String eventId = call.argument("eventId");
                int status = logEvent(eventId);
                result.success(status);
                break;
            case "logEventWithParameters":
                eventId = call.argument("eventId");
                parameters = call.argument("parameters");
                status = logEventWithParameters(eventId, parameters);
                result.success(status);
                break;
            case "logTimedEvent":
                eventId = call.argument("eventId");
                boolean timed = call.<Boolean>argument("timed");
                status = logTimedEvent(eventId, timed);
                result.success(status);
                break;
            case "logTimedEventWithParameters":
                eventId = call.argument("eventId");
                parameters = call.argument("parameters");
                timed = call.<Boolean>argument("timed");
                status = logTimedEventWithParameters(eventId, parameters, timed);
                result.success(status);
                break;
            case "endTimedEvent":
                eventId = call.argument("eventId");
                endTimedEvent(eventId);
                break;
            case "endTimedEventWithParameters":
                eventId = call.argument("eventId");
                parameters = call.argument("parameters");
                endTimedEventWithParameters(eventId, parameters);
                break;
            case "logStandardEvent":
                int standardId = call.<Integer>argument("id");
                Map<Integer, String> flurryParam = call.<Map<Integer, String>>argument("flurryParam");
                Map<String, String> userParam = call.<Map<String, String>>argument("userParam");
                status = logStandardEvent(standardId, flurryParam, userParam);
                result.success(status);
                break;
            case "onError":
                String errorId = call.argument("errorId");
                String message = call.argument("message");
                String errorClass = call.argument("errorClass");
                onError(errorId, message, errorClass);
                break;
            case "onErrorWithParameters":
                errorId = call.argument("errorId");
                message = call.argument("message");
                errorClass = call.argument("errorClass");
                parameters = call.argument("parameters");
                onErrorWithParameters(errorId, message, errorClass, parameters);
                break;
            case "logBreadcrumb":
                String crashBreadcrumb = call.argument("crashBreadcrumb");
                logBreadcrumb(crashBreadcrumb);
                break;
            case "logPayment":
                String productName = call.argument("productName");
                String productId = call.argument("productId");
                int quantity = call.<Integer>argument("quantity");
                double price = call.<Double>argument("price");
                String currency = call.argument("currency");
                String transactionId = call.argument("transactionId");
                parameters = call.argument("parameters");
                status = logPayment(productName, productId, quantity, price, currency, transactionId, parameters);
                result.success(status);
                break;
            case "registerConfigListener":
                // no-op
                break;
            case "fetchConfig":
                FlurryConfig.getInstance().fetchConfig();
                break;
            case "activateConfig":
                FlurryConfig.getInstance().activateConfig();
                break;
            case "getConfigString":
                String key = call.argument("key");
                String defaultValue = call.argument("defaultValue");
                String configValue = FlurryConfig.getInstance().getString(key, defaultValue);
                result.success(configValue);
                break;
            case "setMessagingListener":
                // no-op
                break;
            case "willHandleMessage":
                boolean willHandle = call.<Boolean>argument("willHandle");
                FlutterFlurryMessagingListener.notifyCallbackReturn(willHandle);
                break;
            case "isPublisherDataFetched":
                boolean fetched = FlurryPublisherSegmentation.isFetchFinished();
                result.success(fetched);
                break;
            case "getPublisherData":
                Map<String, String> data = FlurryPublisherSegmentation.getPublisherData();
                result.success(data);
                break;
            case "fetchPublisherData":
                FlurryPublisherSegmentation.fetch();
                break;
            case "registerPublisherDataListener":
                // no-op
                break;
            default:
                result.notImplemented();
        }
    }

    public void initializeFlurryBuilder() {
        builder = new FlurryAgent.Builder();
        builder.withSessionForceStart(true)
               .withReportLocation(true);
    }

    public void buildFlurryBuilder(String apiKey) {
        FlurryAgent.addOrigin(ORIGIN_NAME, ORIGIN_VERSION);
        builder.build(context, apiKey);
    }

    public void withAppVersion(String appVersion) {
        Log.w(TAG, "iOS only. For Android, please also call Flurry.setVersionName().");
    }

    public void withContinueSessionMillis(String sessionMillisStr) {
        long millis = Long.parseLong(sessionMillisStr);
        builder.withContinueSessionMillis(millis);
    }

    public void withCrashReporting(boolean crashReporting) {
        builder.withCaptureUncaughtExceptions(crashReporting);
    }

    public void withDataSaleOptOut(boolean isOptOut) {
        builder.withDataSaleOptOut(isOptOut);
    }

    public void withIncludeBackgroundSessionsInMetrics(boolean includeBackgroundSessionsInMetrics) {
        builder.withIncludeBackgroundSessionsInMetrics(includeBackgroundSessionsInMetrics);
    }

    public void withLogEnabled(boolean enableLog) {
        builder.withLogEnabled(enableLog);
    }

    public void withLogLevel(String logLevelStr) {
        int logLevel = Integer.parseInt(logLevelStr);
        builder.withLogLevel(logLevel);
    }

    public void withPerformanceMetrics(int performanceMetrics ) {
        builder.withPerformanceMetrics(performanceMetrics);
    }

    public void withMessaging() {
        Log.i(TAG, "To customize Flurry Push for Android, please duplicate Builder setup in your FlutterApplication class.");

        if (messagingInitialized) {
            return;
        }

        FlutterFlurryMessagingListener messagingListener = new FlutterFlurryMessagingListener();
        FlurryMarketingOptions messagingOptions = new FlurryMarketingOptions.Builder()
                .setupMessagingWithAutoIntegration()
                .withFlurryMessagingListener(messagingListener, getHandler())
                // Define yours if needed
                // .withDefaultNotificationChannelId(NOTIFICATION_CHANNEL_ID)
                // .withDefaultNotificationIconResourceId(R.mipmap.ic_launcher_round)
                // .withDefaultNotificationIconAccentColor(getResources().getColor(R.color.colorPrimary))
                .build();

        FlurryMarketingModule marketingModule = new FlurryMarketingModule(messagingOptions);
        builder.withModule(marketingModule);
    }

    public void addUserPropertyValue(String propertyName, String propertyValue) {
        FlurryAgent.UserProperties.add(propertyName, propertyValue);
    }

    public void addUserPropertyValues(String propertyName, List<String> propertyValues) {
        FlurryAgent.UserProperties.add(propertyName, propertyValues);
    }

    public void flagUserProperty(String propertyName) {
        FlurryAgent.UserProperties.flag(propertyName);
    }

    public void removeUserProperty(String propertyName) {
        FlurryAgent.UserProperties.remove(propertyName);
    }

    public void removeUserPropertyValue(String propertyName, String propertyValue) {
        FlurryAgent.UserProperties.remove(propertyName, propertyValue);
    }

    public void removeUserPropertyValues(String propertyName, List<String> propertyValues) {
        FlurryAgent.UserProperties.remove(propertyName, propertyValues);
    }

    public void setUserPropertyValue(String propertyName, String propertyValue) {
        FlurryAgent.UserProperties.set(propertyName, propertyValue);
    }

    public void setUserPropertyValues(String propertyName, List<String> propertyValues) {
        FlurryAgent.UserProperties.set(propertyName, propertyValues);
    }

    public void reportFullyDrawn() {
        FlurryPerformance.reportFullyDrawn();
    }

    public void startResourceLogger() {
        flurryResourceLogger = new FlurryPerformance.ResourceLogger();
    }

    public void logResourceLogger(String id) {
        if (flurryResourceLogger != null) {
            flurryResourceLogger.logEvent(id);
        }
    }

    public void setAge(String ageStr) {
        int age = Integer.parseInt(ageStr);
        FlurryAgent.setAge(age);
    }

    public void setGender(String gender) {
        if (gender.equals("f")) {
            byte female = 0;
            FlurryAgent.setGender(female);
        } else {
            byte male = 1;
            FlurryAgent.setGender(male);
        }
    }

    public void setReportLocation(boolean reportLocation) {
        FlurryAgent.setReportLocation(reportLocation);
    }

    public void setSessionOrigin(String originName, String deepLink) {
        FlurryAgent.setSessionOrigin(originName, deepLink);
    }

    public void setUserId(String userId) {
        FlurryAgent.setUserId(userId);
    }

    public void setVersionName(String versionName) {
        FlurryAgent.setVersionName(versionName);
    }

    public void addOrigin(String originName, String originVersion) {
        FlurryAgent.addOrigin(originName, originVersion);
    }

    public void addOriginWithParameters(String originName, String originVersion,
                                        Map<String, String> parameters) {
        FlurryAgent.addOrigin(originName, originVersion, parameters);
    }

    public void addSessionProperty(String sessionName, String sessionValue) {
        FlurryAgent.addSessionProperty(sessionName, sessionValue);
    }

    public void setIAPReportingEnabled() {
        Log.w(TAG, "setIAPReportingEnabled is not supported on Android. Please use LogPayment instead.");
    }

    public void setDataSaleOptOut(boolean isOptOut) {
        FlurryAgent.setDataSaleOptOut(isOptOut);
    }

    public void deleteData() {
        FlurryAgent.deleteData();
    }

    public void openPrivacyDashboard() {
        if (context == null) {
            Log.w(TAG, "Application Context is not available to open Privacy Dashboard.");
            return;
        }

        FlurryPrivacySession.Callback callback = new FlurryPrivacySession.Callback() {
            @Override
            public void success() {
                Log.d(TAG, "Privacy Dashboard opened successfully.");
            }

            @Override
            public void failure() {
                Log.d(TAG, "Opening Privacy Dashboard failed.");
            }
        };

        FlurryPrivacySession.Request request = new FlurryPrivacySession.Request(context, callback);
        FlurryAgent.openPrivacyDashboard(request);
    }

    public int getAgentVersion() {
        return FlurryAgent.getAgentVersion();
    }

    public String getReleaseVersion() {
        return FlurryAgent.getReleaseVersion();
    }

    public String getSessionId() {
        return FlurryAgent.getSessionId();
    }

    public int logEvent(String eventId) {
        FlurryEventRecordStatus status = FlurryAgent.logEvent(eventId);
        return (status != null) ? status.ordinal() : 0;
    }

    public int logEventWithParameters(String eventId, Map<String, String> parameters) {
        FlurryEventRecordStatus status = FlurryAgent.logEvent(eventId, parameters);
        return (status != null) ? status.ordinal() : 0;
    }

    public int logTimedEvent(String eventId, boolean timed) {
        FlurryEventRecordStatus status = FlurryAgent.logEvent(eventId, timed);
        return (status != null) ? status.ordinal() : 0;
    }

    public int logTimedEventWithParameters(String eventId, Map<String, String> parameters, boolean timed) {
        FlurryEventRecordStatus status = FlurryAgent.logEvent(eventId, parameters, timed);
        return (status != null) ? status.ordinal() : 0;
    }

    public void endTimedEvent(String eventId) {
        FlurryAgent.endTimedEvent(eventId);
    }

    public void endTimedEventWithParameters(String eventId, Map<String, String> parameters) {
        FlurryAgent.endTimedEvent(eventId, parameters);
    }

    public int logStandardEvent(int standardId, Map<Integer, String> flurryParam, Map<String, String> userParam) {
        // Find the standard event ID.
        if ((standardId < 0) || (standardId >= FlurryFlutterEvent.EVENTS.length)) {
            Log.e(TAG, "Standard event ID is out of range: " + standardId);
            return FlurryEventRecordStatus.kFlurryEventFailed.ordinal();
        }
        FlurryEvent event = FlurryFlutterEvent.EVENTS[standardId];

        // Construct the standard event parameters.
        FlurryEvent.Params params = new FlurryEvent.Params();
        Map<Object, String> paramMap = params.getParams();
        for (Map.Entry<Integer, String> entry : flurryParam.entrySet()) {
            int paramIndex = entry.getKey();
            if ((paramIndex < 0) || (paramIndex >= FlurryFlutterEvent.PARAMS.length)) {
                Log.e(TAG, "Standard event parameter ID is out of range: " + paramIndex);
            } else {
                paramMap.put(FlurryFlutterEvent.PARAMS[paramIndex], entry.getValue());
            }
        }
        for (Map.Entry<String, String> entry : userParam.entrySet()) {
            paramMap.put(entry.getKey(), entry.getValue());
        }

        FlurryEventRecordStatus status = FlurryAgent.logEvent(event, params);
        return (status != null) ? status.ordinal() : 0;
    }

    public void onError(String errorId, String message, String errorClass) {
        FlurryAgent.onError(errorId, message, errorClass);
    }

    public void onErrorWithParameters(String errorId, String message, String errorClass, Map<String, String> parameters) {
        FlurryAgent.onError(errorId, message, errorClass, parameters);
    }

    public void logBreadcrumb(String crashBreadcrumb) {
        FlurryAgent.logBreadcrumb(crashBreadcrumb);
    }

    public int logPayment(String productName, String productId, int quantity, double price,
                                String currency, String transactionId, Map<String, String> parameters) {
        FlurryEventRecordStatus status = FlurryAgent.logPayment(productName, productId, quantity, price, currency,
                transactionId, parameters);
        return (status != null) ? status.ordinal() : 0;
    }

    /**
     * Builder Pattern class for Flurry. Used by FlutterApplication to initialize Flurry Push for messaging.
     */
    public static class Builder {
        private final FlurryAgent.Builder mFlurryAgentBuilder;

        public Builder() {
            mFlurryAgentBuilder = new FlurryAgent.Builder();
        }

        /**
         * True to enable or  false to disable the ability to catch all uncaught exceptions
         * and have them reported back to Flurry.
         *
         * @param captureExceptions true to enable, false to disable.
         * @return The Builder instance.
         */
        public Builder withCrashReporting(final boolean captureExceptions) {
            mFlurryAgentBuilder.withCaptureUncaughtExceptions(captureExceptions);
            return this;
        }

        /**
         * Set the timeout for expiring a Flurry session.
         *
         * @param sessionMillis The time in milliseconds to set the session timeout to. Minimum value of 5000.
         * @return The Builder instance.
         */
        public Builder withContinueSessionMillis(final long sessionMillis) {
            mFlurryAgentBuilder.withContinueSessionMillis(sessionMillis);
            return this;
        }

        /**
         * True if this session should be added to total sessions/DAUs when applicationstate is inactive or background.
         * Default is set to true.
         *
         * @param includeBackgroundSessionsInMetrics if background and inactive session should be counted toward dau
         */
        public Builder withIncludeBackgroundSessionsInMetrics(final boolean includeBackgroundSessionsInMetrics) {
            mFlurryAgentBuilder.withIncludeBackgroundSessionsInMetrics(includeBackgroundSessionsInMetrics);
            return this;
        }

        /**
         * True to enable or false to disable the internal logging for the Flurry SDK.
         *
         * @param enableLog true to enable logging, false to disable it.
         * @return The Builder instance.
         */
        public Builder withLogEnabled(final boolean enableLog) {
            mFlurryAgentBuilder.withLogEnabled(enableLog);
            return this;
        }

        /**
         * Set the log level of the internal Flurry SDK logging.
         *
         * @param logLevel The level to set it to.
         * @return The Builder instance.
         */
        public Builder withLogLevel(final int logLevel) {
            mFlurryAgentBuilder.withLogLevel(logLevel);
            return this;
        }

        /**
         * Set flags for performance metrics.
         *
         * @param performanceMetrics Flags for performance metrics.
         * @return The Builder instance.
         */
        public Builder withPerformanceMetrics(final int performanceMetrics) {
            mFlurryAgentBuilder.withPerformanceMetrics(performanceMetrics);
            return this;
        }

        /**
         * Enable Flurry add-on Messaging.
         *
         * @param enableMessaging true to enable messaging,
         *                        currently support only auto integration.
         * @return The Builder instance.
         */
        public Builder withMessaging(final boolean enableMessaging) {
            return withMessaging(enableMessaging, (FlurryMessagingListener) null);
        }

        /**
         * Enable Flurry add-on Messaging with listener.
         *
         * @param enableMessaging   true to enable messaging,
         *                          currently support only auto integration.
         * @param messagingListener user's messaging listener.
         * @return The Builder instance.
         */
        public Builder withMessaging(final boolean enableMessaging, FlurryMessagingListener messagingListener) {
            if (!enableMessaging) {
                return this;
            }

            if (messagingListener == null) {
                messagingListener = new FlutterFlurryMessagingListener();
            }

            FlurryMarketingOptions messagingOptions = new FlurryMarketingOptions.Builder()
                    .setupMessagingWithAutoIntegration()
                    .withFlurryMessagingListener(messagingListener, getHandler())
                    // Define yours if needed
                    // .withDefaultNotificationChannelId(NOTIFICATION_CHANNEL_ID)
                    // .withDefaultNotificationIconResourceId(R.mipmap.ic_launcher_round)
                    // .withDefaultNotificationIconAccentColor(getResources().getColor(R.color.colorPrimary))
                    .build();

            FlurryMarketingModule marketingModule = new FlurryMarketingModule(messagingOptions);
            mFlurryAgentBuilder.withModule(marketingModule);

            messagingInitialized = true;
            return this;
        }

        /**
         * Enable Flurry add-on Messaging with options.
         *
         * @param enableMessaging  true to enable messaging.
         * @param messagingOptions user's messaging options.
         * @return The Builder instance.
         */
        public Builder withMessaging(final boolean enableMessaging, FlurryMarketingOptions messagingOptions) {
            if (!enableMessaging) {
                return this;
            }

            // If user does not specify the messaging listener, use the Flutter default listener.
            if (messagingOptions.getFlurryMessagingListener() == null) {
                FlurryMarketingOptions.Builder builder = new FlurryMarketingOptions.Builder();
                if (messagingOptions.isAutoIntegration()) {
                    builder.setupMessagingWithAutoIntegration();
                } else {
                    builder.setupMessagingWithManualIntegration(messagingOptions.getToken());
                }

                messagingOptions = builder
                        .withFlurryMessagingListener(new FlutterFlurryMessagingListener(), getHandler())
                        .withDefaultNotificationChannelId(messagingOptions.getNotificationChannelId())
                        .withDefaultNotificationIconResourceId(messagingOptions.getDefaultNotificationIconResourceId())
                        .withDefaultNotificationIconAccentColor(messagingOptions.getDefaultNotificationIconAccentColor())
                        .build();
            }

            FlurryMarketingModule marketingModule = new FlurryMarketingModule(messagingOptions);
            mFlurryAgentBuilder.withModule(marketingModule);

            messagingInitialized = true;
            return this;
        }

        public void build(final Context context, final String apiKey) {
            mFlurryAgentBuilder
                    .withSessionForceStart(true)
                    .build(context, apiKey);
        }
    }

    private static Handler getHandler() {
        // Use non-UI thread to notify the messaging listeners.
        HandlerThread handlerThread = new HandlerThread("FlurryHandlerThread");
        handlerThread.start();

        return new Handler(handlerThread.getLooper());
    }

    /**
     * Wrapper Flurry Config listener.
     */
    static class FlutterFlurryConfigListener implements FlurryConfigListener {

        enum EventType {
            FetchSuccess("FetchSuccess"),
            FetchNoChange("FetchNoChange"),
            FetchError("FetchError"),
            ActivateComplete("ActivateComplete");

            private final String name;

            EventType(String name) {
                this.name = name;
            }

            public String getName() {
                return name;
            }
        }

        private static EventChannel.EventSink eventSink;

        FlutterFlurryConfigListener(EventChannel.EventSink eventSink) {
            FlutterFlurryConfigListener.eventSink = eventSink;
        }

        @Override
        public void onFetchSuccess() {
            sendEvent(EventType.FetchSuccess);
        }

        @Override
        public void onFetchNoChange() {
            sendEvent(EventType.FetchNoChange);
        }

        @Override
        public void onFetchError(boolean value) {
            sendEvent(EventType.FetchError, "isRetrying", value);
        }

        @Override
        public void onActivateComplete(boolean value) {
            sendEvent(EventType.ActivateComplete, "isCache", value);
        }

        private void sendEvent(EventType type) {
            sendEvent(type, null, false);
        }

        private void sendEvent(EventType type, String key, boolean value) {
            final Map<String, String> params = new HashMap<>();
            params.put("type", type.getName());
            if (key != null) {
                params.put(key, Boolean.toString(value));
            }

            // Run Flutter event channel on the UI main thread.
            new Handler(Looper.getMainLooper()).post(new Runnable() {
                @Override
                public void run() {
                    eventSink.success(params);
                }
            });
        }

    }

    /**
     * Get the default Flutter Messaging listener.
     * Used by MainApplication to initialize Flurry Push for messaging,
     * when constructing the optional FlurryMarketingOptions.
     *
     * @return the default Flutter Messaging listener
     */
    public static FlurryMessagingListener getFlurryMessagingListener() {
        return new FlutterFlurryMessagingListener();
    }

    /**
     * Wrapper Flurry Messaging listener.
     */
    static class FlutterFlurryMessagingListener implements FlurryMessagingListener {
        private static EventChannel.EventSink eventSink;
        private static boolean sCallbackReturnValue = false;
        private static boolean sIsCallbackReturn = false;
        private static String sToken = null;

        enum EventType {
            NotificationReceived("NotificationReceived"),
            NotificationClicked("NotificationClicked"),
            NotificationCancelled("NotificationCancelled"),
            TokenRefresh("TokenRefresh");

            private final String name;

            EventType(String name) {
                this.name = name;
            }

            public String getName() {
                return name;
            }
        }

        public static void setEventSink(EventChannel.EventSink eventSink) {
            FlutterFlurryMessagingListener.eventSink = eventSink;
            if (sToken != null) {
                sendEvent(EventType.TokenRefresh, sToken);
            }
        }

        @Override
        public boolean onNotificationReceived(FlurryMessage flurryMessage) {
            if (eventSink != null) {
                return sendEvent(EventType.NotificationReceived, flurryMessage, true);
            }
            return false;
        }

        @Override
        public boolean onNotificationClicked(FlurryMessage flurryMessage) {
            if (eventSink != null) {
                return sendEvent(EventType.NotificationClicked, flurryMessage, true);
            }
            return false;
        }

        @Override
        public void onNotificationCancelled(FlurryMessage flurryMessage) {
            if (eventSink != null) {
                sendEvent(EventType.NotificationCancelled, flurryMessage, false);
            }
        }

        @Override
        public void onTokenRefresh(String token) {
            sToken = token;
            if (eventSink != null) {
                sendEvent(EventType.TokenRefresh, token);
            }
        }

        @Override
        public void onNonFlurryNotificationReceived(Object message) {
            // no-op
        }

        private static boolean sendEvent(EventType type, FlurryMessage flurryMessage, boolean waitReturn) {
            final Map<String, Object> params = new HashMap<>();
            params.put("type", type.getName());
            params.put("title", flurryMessage.getTitle());
            params.put("body", flurryMessage.getBody());
            params.put("clickAction", flurryMessage.getClickAction());
            params.put("appData", flurryMessage.getAppData());

            sCallbackReturnValue = false;
            sIsCallbackReturn = !waitReturn;

            // Run Flutter event channel on the UI main thread.
            new Handler(Looper.getMainLooper()).post(new Runnable() {
                @Override
                public void run() {
                    eventSink.success(params);
                }
            });

            waitCallbackReturn();
            return sCallbackReturnValue;
        }

        private static void sendEvent(EventType type, String token) {
            final Map<String, Object> params = new HashMap<>();
            params.put("type", type.getName());
            params.put("token", token);

            // Run Flutter event channel on the UI main thread.
            new Handler(Looper.getMainLooper()).post(new Runnable() {
                @Override
                public void run() {
                    eventSink.success(params);
                }
            });
        }

        private static void waitCallbackReturn() {
            synchronized (eventSink) {
                if (!sIsCallbackReturn) {
                    try {
                        eventSink.wait(300);
                    } catch (InterruptedException e) {
                        Log.e(TAG, "Interrupted Exception!", e);
                    }
                }
            }
        }

        public static void notifyCallbackReturn(boolean returnValue) {
            synchronized (eventSink) {
                sCallbackReturnValue = returnValue;
                sIsCallbackReturn = true;
                eventSink.notifyAll();
            }
        }

    }

    /**
     * Wrapper Flurry Publisher Segmentation listener.
     */
    static class FlutterFlurryPublisherListener implements FlurryPublisherSegmentation.FetchListener {

        private static EventChannel.EventSink eventSink;

        FlutterFlurryPublisherListener(EventChannel.EventSink eventSink) {
            FlutterFlurryPublisherListener.eventSink = eventSink;
        }

        @Override
        public void onFetched(final Map<String, String> map) {
            // Run Flutter event channel on the UI main thread.
            new Handler(Looper.getMainLooper()).post(new Runnable() {
                @Override
                public void run() {
                    eventSink.success(map);
                }
            });
        }

    }

}
