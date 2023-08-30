#import "FlurryFlutterPlugin.h"

#import <Flurry_iOS_SDK/Flurry_iOS_SDK.h>

#if __has_include(<Flurry_Messaging/Flurry_Messaging.h>)
#import <Flurry_Messaging/Flurry_Messaging.h>
#endif

#if __has_include(<Flurry_Config/Flurry_Config.h>)
#import <Flurry_Config/Flurry_Config.h>
#endif

NSString *originName = @"flutter-flurry-sdk";
NSString *originVersion = @"3.3.0";

static FlurryFlutterPlugin* sharedInstance;

NSString *kNotificationReceivedMessage = @"NotificationReceived";
NSString *kActionReceivedMessage = @"NotificationClicked";
NSString *kConfigFetchCompleteMessage = @"FetchSuccess";
NSString *kConfigFetchNoChangeMessage = @"FetchNoChange";
NSString *kConfigFetchFailMessage = @"FetchError";
NSString *kConfigActivatedMessage = @"ActivateComplete";
NSString *kPSFetchCompleteMessage = @"kPSOnFetchedNotification";


FlurrySessionBuilder* builder;
bool FlurryLogEnabled = true;
bool hasSetUpDummyListener_messaging = false;

#if __has_include(<Flurry_Config/Flurry_Config.h>) && __has_include(<Flurry_Messaging/Flurry_Messaging.h>)
@interface FlurryFlutterPlugin()<FlurryMessagingDelegate, FConfigObserver, FlurryFetchObserver>
#elif __has_include(<Flurry_Messaging/Flurry_Messaging.h>)
@interface FlurryFlutterPlugin()<FlurryMessagingDelegate>
#elif __has_include(<Flurry_Config/Flurry_Config.h>)
@interface FlurryFlutterPlugin()<FConfigObserver>
#else
@interface FlurryFlutterPlugin()
#endif
@end


@implementation FlurryFlutterPlugin{
    NSMutableDictionary<NSString *, FlutterEventSink> *_listeners;
    FlutterEventSink _emitter;
    NSDictionary<NSNumber *, NSString *> *_paramStringMap;
}

+ (FlurryFlutterPlugin*) shared {
    static dispatch_once_t once;
    static id _sharedInstance;
    dispatch_once(&once, ^{
        _sharedInstance = [[FlurryFlutterPlugin alloc] init];
    });
    return _sharedInstance;
}

-(instancetype)init {
    self = [super init];
    if(self){
        _listeners = [NSMutableDictionary new];
    }
    return self;
}

#pragma mark - FlurryMessaging

- (void) flurrySetAutoIntegrationForMessaging {
    #if __has_include(<Flurry_Messaging/Flurry_Messaging.h>)
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if(!hasSetUpDummyListener_messaging){
            [FlurryMessaging setMessagingDelegate:[FlurryFlutterPlugin shared]];
            hasSetUpDummyListener_messaging = !hasSetUpDummyListener_messaging;
        }
        [FlurryMessaging setAutoIntegrationForMessaging];
        NSLog(@"did set Messaging auto-integration");
    });
    #endif
}

- (void) flurrySetMessagingDelegate{
#if __has_include(<Flurry_Messaging/Flurry_Messaging.h>)
    if(!hasSetUpDummyListener_messaging){
        [FlurryMessaging setMessagingDelegate:[FlurryFlutterPlugin shared]];
        hasSetUpDummyListener_messaging = !hasSetUpDummyListener_messaging;
    }
    NSLog(@"did set MessagingDelegate");
#endif
}

#pragma mark - FlurryMessageDelegate
#if __has_include(<Flurry_Messaging/Flurry_Messaging.h>)
- (void) didReceiveMessage:(nonnull FlurryMessage*)message {
    NSLog(@"didReceiveMessage = %@", [message description]);

    NSDictionary *msg = @{@"type" : kNotificationReceivedMessage,
                          @"title" : message.title,
                          @"clickAction" : message.sound,
                          @"body" : message.body,
                          @"appData" : message.appData};
    self->_emitter(msg);

}

// delegate method when a notification action is performed
-(void) didReceiveActionWithIdentifier:(nullable NSString*)identifier message:(nonnull FlurryMessage*)message {
    NSLog(@"didReceiveAction %@ , Message = %@",identifier, [message description]);

    NSDictionary *msg = @{@"type" : kActionReceivedMessage,
                          @"title" : message.title,
                          @"clickAction" : message.sound,
                          @"body" : message.body,
                          @"appData" : message.appData,
                          @"id" : identifier};
    self->_emitter(msg);
}

#endif

#pragma mark - Flutter stream handler delegate methods
- (FlutterError* _Nullable)onListenWithArguments:(id _Nullable)arguments
                                       eventSink:(FlutterEventSink)events {
    self->_emitter = events;
    return nil;
}

- (FlutterError* _Nullable)onCancelWithArguments:(id _Nullable)arguments {
    return nil;
}

#pragma mark - FluryConfig

- (void)flurryRegisterConfigListener{
#if __has_include(<Flurry_Config/Flurry_Config.h>)
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [[FConfig sharedInstance] registerObserver:[FlurryFlutterPlugin shared] withExecutionQueue:dispatch_get_main_queue()];
    });
#endif
}

- (void)flurryFetchConfig{
#if __has_include(<Flurry_Config/Flurry_Config.h>)
    [[FConfig sharedInstance] fetchConfig];
#endif
}

- (void)flurryActivateConfig{
#if __has_include(<Flurry_Config/Flurry_Config.h>)
    [[FConfig sharedInstance] activateConfig];
#endif
}

- (NSString *)flurryGetConfigString:(NSDictionary *)dict{
    NSString *key = (NSString *)dict[@"key"];
    NSString *defaultValue = (NSString *)dict[@"defaultValue"];

    NSString *value = [[FConfig sharedInstance] getStringForKey:key withDefault:defaultValue];
    return value;
}

#if __has_include(<Flurry_Config/Flurry_Config.h>)

- (void) fetchComplete{
    NSDictionary *msg = @{@"type" : kConfigFetchCompleteMessage};
    self->_emitter(msg);
}

- (void) fetchCompleteNoChange{
    NSDictionary *msg = @{@"type" : kConfigFetchNoChangeMessage};
    self->_emitter(msg);
}

- (void) fetchFail{
    NSDictionary *msg = @{@"type" : kConfigFetchFailMessage};
    self->_emitter(msg);
}

- (void) activationComplete{
    NSDictionary *msg = @{@"type" : kConfigActivatedMessage};
    self->_emitter(msg);
}

#endif


+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel methodChannelWithName:@"flurry_flutter_plugin"
                                   binaryMessenger:[registrar messenger]];
    [registrar addMethodCallDelegate:[FlurryFlutterPlugin shared] channel:channel];

    // 1. messaging event channel
    FlutterEventChannel *eventChannel_messaging = [FlutterEventChannel eventChannelWithName:@"flurry_flutter_plugin_event_messaging"
                                   binaryMessenger:[registrar messenger]];
    [eventChannel_messaging setStreamHandler:[FlurryFlutterPlugin shared]];

    // 2. config event channel
    FlutterEventChannel *eventChannel_config = [FlutterEventChannel eventChannelWithName:@"flurry_flutter_plugin_event_config"
                                       binaryMessenger:[registrar messenger]];
    [eventChannel_config setStreamHandler:[FlurryFlutterPlugin shared]];
    
    // 3. PS listener
    FlutterEventChannel *eventChannel_PS = [FlutterEventChannel eventChannelWithName:@"flurry_flutter_plugin_event_ps"
                                       binaryMessenger:[registrar messenger]];
    [eventChannel_PS setStreamHandler:[FlurryFlutterPlugin shared]];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"getPlatformVersion" isEqualToString:call.method]) {
      result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
  } else if([@"initializeFlurryBuilder" isEqualToString:call.method]) {
      [self initializeFlurrySessionBuilder];
  } else if([@"withCrashReporting" isEqualToString:call.method]) {
      [self flurryWithCrashReporting:call.arguments];
  } else if ([@"buildFlurryBuilder" isEqualToString:call.method]) {
      [self flurryStartSessionWithSessionBuilder:call.arguments];
  } else if ([@"withAppVersion" isEqualToString: call.method]) {
      [self flurryWithAppVersion:call.arguments];
  } else if ([@"withContinueSessionMillis" isEqualToString:call.method]) {
      [self flurryWithSessionContinueSeconds:call.arguments];
  } else if([@"withGppConsent" isEqualToString:call.method]) {
      [self flurryWithGppConsent:call.arguments];
  } else if([@"withDataSaleOptOut" isEqualToString:call.method]) {
      [self flurryWithDataSaleOptOut:call.arguments];
  } else if([@"withIncludeBackgroundSessionsInMetrics" isEqualToString:call.method]) {
      [self flurryWithIncludeBackgroundSessionsInMetrics:call.arguments];
  } else if([@"withLogEnabled" isEqualToString:call.method]) {
      [self flurryWithLogEnabled:call.arguments];
  } else if([@"withLogLevel" isEqualToString:call.method]) {
      [self flurryWithLogLevel:call.arguments];
  } else if([@"setVersionName" isEqualToString:call.method]) {
    [self flurrySetVersionName:call.arguments];
  } else if([@"setContinueSessionMillis" isEqualToString:call.method]) {
      [self flurrySetContinueSessionMillis:call.arguments];
  } else if([@"setIncludeBackgroundSessionsInMetrics" isEqualToString:call.method]) {
      [self flurrySetIncludeBackgroundSessionsInMetrics:call.arguments];
  } else if([@"addUserPropertyValue" isEqualToString:call.method]) {
      [self flurryAddUserPropertyValue:call.arguments];
  } else if([@"addUserPropertyValues" isEqualToString:call.method]) {
      [self flurryAddUserPropertyValues:call.arguments];
  } else if([@"flagUserProperty" isEqualToString:call.method]) {
      [self flurryFlagUserProperty:call.arguments];
  } else if([@"removeUserProperty" isEqualToString:call.method]) {
      [self flurryRemoveUserProperty:call.arguments];
  } else if([@"removeUserPropertyValue" isEqualToString:call.method]) {
      [self flurryRemoveUserPropertyValue:call.arguments];
  } else if([@"removeUserPropertyValues" isEqualToString:call.method]) {
      [self flurryRemoveUserPropertyValues:call.arguments];
  } else if([@"setUserPropertyValue" isEqualToString:call.method]) {
      [self flurrySetUserPropertyValue:call.arguments];
  } else if([@"setUserPropertyValues" isEqualToString:call.method]) {
      [self flurrySetUserPropertyValues:call.arguments];
  } else if([@"addOrigin" isEqualToString:call.method]) {
      [self flurryAddOrigin:call.arguments];
  } else if([@"addOriginWithParameters" isEqualToString:call.method]) {
      [self flurryAddOriginWithParameters:call.arguments];
  } else if([@"addSessionProperty" isEqualToString:call.method]) {
      [self flurryAddSessionProperty:call.arguments];
  } else if([@"deleteData" isEqualToString:call.method]) {
      [self flurrySetDelete];
  } else if([@"getAgentVersion" isEqualToString:call.method]) {
      NSNumber* agentVersion = [NSNumber numberWithLong:[self flurryGetAgentVersion]];
      result(agentVersion);
  } else if([@"getReleaseVersion" isEqualToString:call.method]) {
    NSString* releaseVersion = [self flurryGetReleaseVersion];
    result(releaseVersion);
  } else if([@"getSessionId" isEqualToString:call.method]) {
      NSString* sessionId = [self flurryGetSessionId];
      result(sessionId);
  } else if([@"logBreadcrumb" isEqualToString:call.method]) {
      [self flurryLogBreadcrumb:call.arguments];
  } else if([@"logEvent" isEqualToString:call.method]) {
      NSNumber* logEvent = [NSNumber numberWithLong:[self flurryLogEvent:call.arguments]];
      result(logEvent);
  } else if([@"logEventWithParameters" isEqualToString:call.method]) {
      NSNumber* logEvent = [NSNumber numberWithLong:[self flurryLogEventWithParameters:call.arguments]];
      result(logEvent);
  } else if([@"logTimedEvent" isEqualToString:call.method]) {
      NSNumber* logEvent = [NSNumber numberWithLong:[self flurryLogTimedEvent:call.arguments]];
      result(logEvent);
  } else if([@"logTimedEventWithParameters" isEqualToString:call.method]) {
      NSNumber* logEvent = [NSNumber numberWithLong:[self flurryLogTimedEventWithParameters:call.arguments]];
      result(logEvent);
  } else if([@"logTimedEventId" isEqualToString:call.method]) {
      NSNumber* logEvent = [NSNumber numberWithLong:[self flurryLogTimedEventId:call.arguments]];
      result(logEvent);
  } else if([@"logTimedEventIdWithParameters" isEqualToString:call.method]) {
      NSNumber* logEvent = [NSNumber numberWithLong:[self flurryLogTimedEventIdWithParameters:call.arguments]];
      result(logEvent);
  } else if([@"endTimedEvent" isEqualToString:call.method]) {
      [self flurryEndTimedEvent:call.arguments];
  } else if([@"endTimedEventWithParameters" isEqualToString:call.method]) {
      [self flurryEndTimedEventWithParameters:call.arguments];
  } else if([@"endTimedEventId" isEqualToString:call.method]) {
      [self flurryEndTimedEventId:call.arguments];
  } else if([@"endTimedEventIdWithParameters" isEqualToString:call.method]) {
      [self flurryEndTimedEventIdWithParameters:call.arguments];
  } else if([@"logPayment" isEqualToString:call.method]) {
      NSNumber* num = [NSNumber numberWithLong:[self flurryLogPayment:call.arguments]];
      result(num);
  } else if([@"onError" isEqualToString:call.method]) {
      [self flurryLogError:call.arguments];
  } else if([@"onErrorWithParameters" isEqualToString:call.method]) {
      [self flurryLogErrorWithParameters:call.arguments];
  } else if([@"openPrivacyDashboard" isEqualToString:call.method]) {
      [self flurryOpenPrivacyDashboard];
  } else if([@"setAge" isEqualToString:call.method]) {
      [self flurrySetAge:call.arguments];
  } else if([@"setGender" isEqualToString:call.method]) {
      [self flurrySetGender:call.arguments];
  } else if([@"setGppConsent" isEqualToString:call.method]) {
      [self flurrySetGppConsent:call.arguments];
  } else if([@"setDataSaleOptOut" isEqualToString:call.method]) {
      [self flurrySetDataSaleOptOut:call.arguments];
  } else if([@"setIAPReportingEnabled" isEqualToString:call.method]) {
      [self flurrySetIAPReportingEnabled:call.arguments];
  } else if([@"setSessionOrigin" isEqualToString:call.method]) {
      [self flurrySetSessionOrigin:call.arguments];
  } else if([@"setUserId" isEqualToString:call.method]) {
      [self flurrySetUserId:call.arguments];
  } else if([@"updateConversionValue" isEqualToString:call.method]) {
#if __has_include(<StoreKit/SKAdNetwork.h>)
      [self flurryUpdateConversionValue:call.arguments];
#endif
  } else if([@"updateConversionValueWithEvent" isEqualToString:call.method]) {
#if __has_include(<StoreKit/SKAdNetwork.h>)
      [self flurryUpdateConversionValueWithEvent:call.arguments];
#endif
  }else if([@"withMessaging" isEqualToString:call.method]){
      [self flurrySetAutoIntegrationForMessaging];
  }else if([@"setMessagingListener" isEqualToString:call.method]){
      [self flurrySetMessagingDelegate];
  }else if([@"fetchConfig" isEqualToString:call.method]){
      [self flurryFetchConfig];
  }else if([@"activateConfig" isEqualToString:call.method]){
      [self flurryActivateConfig];
  }else if([@"registerConfigListener" isEqualToString:call.method]){
      [self flurryRegisterConfigListener];
  }else if([@"getConfigString" isEqualToString:call.method]){
      NSString *value = [self flurryGetConfigString:call.arguments];
      result(value);
  }else if([@"logStandardEvent" isEqualToString:call.method]){
      NSNumber* logStandardEvent = [NSNumber numberWithLong:[self flurryEventLogStandardEvent:call.arguments]];
      result(logStandardEvent);
  }else if([@"registerPublisherDataListener" isEqualToString:call.method]){
      [self registerPublisherDataListener];
  }else if([@"getPublisherData" isEqualToString:call.method]){
      NSDictionary<NSString *, NSString *> *dict = [self getPublisherData];
      result(dict);
  }else if([@"fetchPublisherData" isEqualToString:call.method]){
      [self fetchPublisherData];
  }else if([@"isPublisherDataFetched" isEqualToString:call.method]){
      NSNumber *value = [NSNumber numberWithBool:[self isPublisherDataFetched]];
      result(value);
  }else{
      result(FlutterMethodNotImplemented);
  }
}

-(void) initializeFlurrySessionBuilder {
    builder = [FlurrySessionBuilder new];
    FlurryFlutterPlugin* sharedInstance = [FlurryFlutterPlugin shared];
    [Flurry setDelegate:(id <FlurryDelegate>) sharedInstance];
}

-(void) flurryWithCrashReporting:(NSDictionary *)crashReporting {
    BOOL isCrashReporting = crashReporting[@"crashReporting"];
    [builder withCrashReporting:isCrashReporting];
}

-(void) flurryStartSessionWithSessionBuilder:(NSDictionary* )session {
    NSString* apiKey = session[@"apiKey"];
    if(![Flurry activeSessionExists]) {
        [Flurry addOrigin:originName withVersion:originVersion];
        [Flurry startSession:apiKey withSessionBuilder:builder];
    }
}

-(void) flurryWithAppVersion:(nullable NSDictionary*)appVersion {
    NSString* appVersionStr = appVersion[@"appVersion"];
    [builder withAppVersion:appVersionStr];
}

-(void) flurryWithSessionContinueSeconds:(nullable NSDictionary*)seconds {
    NSString* secondsStr = seconds[@"secondsStr"];
    NSInteger secondsInt = [secondsStr integerValue];
    [builder withSessionContinueSeconds:secondsInt];
}

-(void) flurryWithGppConsent:(NSDictionary *)gppConsent {
    NSString* gppString = gppConsent[@"gppString"];
    NSArray* gppSectionIds = gppConsent[@"gppSectionIds"];
    [builder withGppConsent:gppString gppSectionIds:gppSectionIds];
}

-(void) flurryWithDataSaleOptOut:(NSDictionary*)optOut {
    BOOL isOptOut = optOut[@"isOptOut"];
    [builder withDataSaleOptOut:isOptOut];
}

-(void) flurryWithIncludeBackgroundSessionsInMetrics:(NSDictionary*)includeBackgroundSessionsInMetricsDict {
    BOOL includeBackgroundSessionsInMetrics = includeBackgroundSessionsInMetricsDict[@"includeBackgroundSessionsInMetrics"];
    [builder withIncludeBackgroundSessionsInMetrics:includeBackgroundSessionsInMetrics];
}

-(void) flurryWithLogEnabled:(NSDictionary*)logEnabledDict {
    BOOL logEnabled = logEnabledDict[@"enableLog"];
    if(logEnabled == false) {
        [builder withLogLevel:FlurryLogLevelNone];
        FlurryLogEnabled = false;
    } else {
        FlurryLogEnabled = true;
    }
}

-(void) flurryWithLogLevel:(nullable NSDictionary*)logLevel {
    NSString* logLevelStr = logLevel[@"logLevelStr"];
    NSInteger logLevelInt = [logLevelStr integerValue];
    if(FlurryLogEnabled) {
        if(logLevelInt == 2) {
            [builder withLogLevel:FlurryLogLevelAll];
        } else if (logLevelInt == 3 || logLevelInt == 4 || logLevelInt == 5) {
            [builder withLogLevel: FlurryLogLevelDebug];
        } else {
            [builder withLogLevel: FlurryLogLevelCriticalOnly]; //default
        }
    }
}

-(void) flurrySetVersionName:(NSDictionary *)appVersionDict {
    NSString* appVersion = appVersionDict[@"versionName"];
    [Flurry setAppVersion:appVersion];
}

-(void) flurrySetContinueSessionMillis:(NSDictionary *)seconds {
    NSString* secondsStr = seconds[@"secondsStr"];
    int secondsInt = [secondsStr intValue];
    [Flurry setSessionContinueSeconds:secondsInt];
}

-(void) flurrySetIncludeBackgroundSessionsInMetrics:(NSDictionary*)includeBackgroundSessionsInMetrics {
    BOOL isIncludeBackgroundSessionsInMetrics = includeBackgroundSessionsInMetrics[@"includeBackgroundSessionsInMetrics"];
    [Flurry setCountBackgroundSessions:isIncludeBackgroundSessionsInMetrics];
}

-(void) flurryAddUserPropertyValue:(NSDictionary *)userProperties {
    NSString* propertyName = userProperties[@"propertyName"];
    NSString* propertyValue = userProperties[@"propertyValue"];
    [FlurryUserProperties add:propertyName value:propertyValue];
}

-(void) flurryAddUserPropertyValues:(NSDictionary *)userProperties {
    NSString* propertyName = userProperties[@"propertyName"];
    NSArray* propertyValues = userProperties[@"propertyValues"];
    [FlurryUserProperties add:propertyName values:propertyValues];
}

-(void) flurryFlagUserProperty:(NSDictionary *)userProperties {
    NSString* propertyName = userProperties[@"propertyName"];
    [FlurryUserProperties flag:propertyName];
}

-(void) flurryRemoveUserProperty:(NSDictionary *)userProperties {
    NSString* propertyName = userProperties[@"propertyName"];
    [FlurryUserProperties remove:propertyName];
}

-(void) flurryRemoveUserPropertyValue:(NSDictionary *)userProperties {
    NSString* propertyName = userProperties[@"propertyName"];
    NSString* propertyValue = userProperties[@"propertyValue"];
    [FlurryUserProperties remove:propertyName value:propertyValue];
}

-(void) flurryRemoveUserPropertyValues:(NSDictionary *)userProperties {
    NSString* propertyName = userProperties[@"propertyName"];
    NSArray* propertyValues = userProperties[@"propertyValues"];
    [FlurryUserProperties remove:propertyName values:propertyValues];
}

-(void) flurrySetUserPropertyValue:(NSDictionary *)userProperties {
    NSString* propertyName = userProperties[@"propertyName"];
    NSString* propertyValue = userProperties[@"propertyValue"];
    [FlurryUserProperties set:propertyName value:propertyValue];
}

-(void) flurrySetUserPropertyValues:(NSDictionary *)userProperties {
    NSString* propertyName = userProperties[@"propertyName"];
    NSArray* propertyValues = userProperties[@"propertyValues"];
    [FlurryUserProperties set:propertyName values:propertyValues];
}

-(void) flurryAddOrigin:(NSDictionary *)origin {
    NSString* originName = origin[@"originName"];
    NSString* originVersion = origin[@"originVersion"];
    [Flurry addOrigin:originName withVersion:originVersion];
}

-(void) flurryAddOriginWithParameters:(NSDictionary *)origin {
    NSString* originName = origin[@"originName"];
    NSString* originVersion = origin[@"originVersion"];
    NSDictionary* params = origin[@"originParameters"];

    [Flurry addOrigin:originName withVersion:originVersion withParameters:params];
}

-(void) flurryAddSessionProperty:(NSDictionary *)session {
    NSString* sessionName = session[@"name"];
    NSString* sessionValue = session[@"value"];
    NSDictionary* sessionDict = @{sessionName : sessionValue};

    [Flurry sessionProperties: sessionDict];
}

-(void) flurrySetDelete {
    [FlurryCCPA setDelete];
}

-(NSInteger) flurryGetAgentVersion {
    NSString* str = [Flurry getFlurryAgentVersion];
    NSArray *arrayOfComponents = [str componentsSeparatedByString:@"_"];
    NSInteger agentVersion = [arrayOfComponents[2] intValue];
    return agentVersion;
}

-(NSString*) flurryGetSessionId {
    return [Flurry getSessionID];
}

-(NSString*) flurryGetReleaseVersion {
    NSLog(@"Flurry iOS SDK does not implement getReleaseVersion method");
    return @"1.0";
}


-(void) flurryLogBreadcrumb:(NSDictionary*)breadcrumb {
    NSString* crashBreadcrumb = breadcrumb[@"crashBreadcrumb"];
    [Flurry leaveBreadcrumb:crashBreadcrumb];
}

-(NSInteger) flurryLogEvent:(NSDictionary*)event {
    NSString* eventId = event[@"eventId"];
    NSInteger eventInt = [Flurry logEvent:eventId];
    return eventInt;
}

-(NSInteger) flurryLogEventWithParameters:(NSDictionary*)event {
    NSString* eventId = event[@"eventId"];
    NSDictionary *params = event[@"parameters"];
    return [Flurry logEvent:eventId withParameters:params];
}

-(NSInteger) flurryLogTimedEvent:(NSDictionary*)event {
    NSString* eventId = event[@"eventId"];
    BOOL timed = event[@"timed"];
    return [Flurry logEvent:eventId withParameters:nil timed:timed];
}

-(NSInteger) flurryLogTimedEventWithParameters:(NSDictionary*)event {
    NSString* eventId = event[@"eventId"];
    BOOL timed = event[@"timed"];
    NSDictionary* params = event[@"parameters"];
    return [Flurry logEvent:eventId withParameters:params timed:timed];
}

-(NSInteger) flurryLogTimedEventId:(NSDictionary*)event {
    NSString* eventId = event[@"eventId"];
    NSString* timedId = event[@"timedId"];
    return [Flurry logEvent:eventId withEventId:timedId];
}

-(NSInteger) flurryLogTimedEventIdWithParameters:(NSDictionary*)event {
    NSString* eventId = event[@"eventId"];
    NSString* timedId = event[@"timedId"];
    NSDictionary* params = event[@"parameters"];
    return [Flurry logEvent:eventId withEventId:timedId withParameters:params];
}

-(void) flurryEndTimedEvent:(NSDictionary*) event {
    NSString* eventId = event[@"eventId"];
    [Flurry endTimedEvent:eventId withParameters:nil];
}

-(void) flurryEndTimedEventWithParameters:(NSDictionary*)event {
    NSString* eventId = event[@"eventId"];
    NSMutableDictionary* params = event[@"parameters"];
    [Flurry endTimedEvent:eventId withParameters: params];
}

-(void) flurryEndTimedEventId:(NSDictionary*) event {
    NSString* eventId = event[@"eventId"];
    NSString* timedId = event[@"timedId"];
    [Flurry endTimedEvent:eventId withEventId:timedId withParameters:nil];
}

-(void) flurryEndTimedEventIdWithParameters:(NSDictionary*)event {
    NSString* eventId = event[@"eventId"];
    NSString* timedId = event[@"timedId"];
    NSMutableDictionary* params = event[@"parameters"];
    [Flurry endTimedEvent:eventId withEventId:timedId withParameters: params];
}

-(NSInteger) flurryLogPayment:(NSDictionary*)payment {
    NSString* productName = payment[@"productName"];
    NSString* productId = payment[@"productId"];
    NSUInteger quantity = [payment[@"quantity"] unsignedIntegerValue];
    double price = [payment[@"price"] doubleValue];
    NSString* currency = payment[@"currency"];
    NSString* transactionId = payment[@"transactionId"];
    NSDictionary* params = payment[@"parameters"];
    __block NSInteger transactionStatus = 0;
    [Flurry logPaymentTransactionWithTransactionId:transactionId productId:productId
    quantity:quantity price:price currency:currency productName:productName
    transactionState:FlurryPaymentTransactionStatePurchasing userDefinedParams:params statusCallback:^(FlurryTransactionRecordStatus status) {
        transactionStatus = (NSInteger)status;
    }];

    return transactionStatus;
}

-(void) flurryLogError:(NSDictionary*)errorDict {
    NSString* errorId = errorDict[@"errorId"];
    NSString* message = errorDict[@"message"];
    NSString* errorClass = errorDict[@"errorClass"];
    
    NSError *error = nil;
    if (errorClass != nil) {
        error = [NSError errorWithDomain:errorClass code:0 userInfo:nil];
    }
    [Flurry logError:errorId message:message error:error withParameters:nil];
}

-(void) flurryLogErrorWithParameters:(NSDictionary*)errorDict {
    NSString* errorId = errorDict[@"errorId"];
    NSString* message = errorDict[@"message"];
    NSString* errorClass = errorDict[@"errorClass"];
    NSDictionary* params = errorDict[@"parameters"];
    
    NSError *error = nil;
    if (errorClass != nil) {
        error = [NSError errorWithDomain:errorClass code:0 userInfo:nil];
    }
    
    [Flurry logError:errorId message:message error:error withParameters:params];
}

-(void) flurryOpenPrivacyDashboard {
    [Flurry openPrivacyDashboard:^(BOOL success) {
        NSLog(@"Flurry privacy dashbpard opened successfully");
    }];
}

-(void) flurrySetAge:(NSDictionary*)ageDict {
    NSString* ageStr = ageDict[@"ageStr"];
    NSInteger age = [ageStr integerValue];
    [Flurry setAge:(int)age];
}

-(void) flurrySetGender:(NSDictionary*)genderDict {
    NSString* gender = genderDict[@"gender"];
    [Flurry setGender:gender];
}

-(void) flurrySetGppConsent:(NSDictionary *)gppConsent {
    NSString* gppString = gppConsent[@"gppString"];
    NSArray* gppSectionIds = gppConsent[@"gppSectionIds"];
    [Flurry setGppConsent:gppString gppSectionIds:gppSectionIds];
}

-(void) flurrySetDataSaleOptOut:(NSDictionary*)optOut {
    BOOL isOptOut = optOut[@"isOptOut"];
    [FlurryCCPA setDataSaleOptOut:isOptOut];
}

-(void) flurrySetIAPReportingEnabled:(NSDictionary*)IAP {
    BOOL enableIAP = IAP[@"enableIAP"];
    [Flurry setIAPReportingEnabled:enableIAP];
}

-(void) flurrySetSessionOrigin:(NSDictionary*)sessionOrigin {
    NSString* originName = sessionOrigin[@"originName"];
    NSString* deepLink = sessionOrigin[@"deepLink"];
    [Flurry addSessionOrigin:originName withDeepLink:deepLink];
}

-(void) flurrySetUserId:(NSDictionary*)user {
    NSString* userId = user[@"userId"];
    [Flurry setUserID:userId];
}

- (NSInteger)flurryEventLogStandardEvent:(NSDictionary *)dict{

    NSUInteger eventName = [dict[@"id"] unsignedLongValue];
    NSDictionary *userParam = [dict[@"userParam"] copy];
    NSDictionary *flurryParam = [dict[@"flurryParam"] copy];
    
     FlurryParamBuilder *builder = [FlurryParamBuilder new];

     for(NSString *key in [userParam allKeys]){
        [builder setString:userParam[key] forKey:key];
     }

     for(NSNumber *num in [flurryParam allKeys]){
         NSString *key = [self enumToStandardParamString:[num intValue]];
         [builder setString:flurryParam[num] forKey:key];
     }

    return [Flurry logStandardEvent:(FlurryEvent)eventName withParameters:builder];
}

- (NSDictionary<NSNumber *, NSString *> *)paramStringMap{
    if(!_paramStringMap){
        _paramStringMap = @{
          @(0):@"fl.ad.type",
          @(1):@"fl.level.name",
          @(2):@"fl.level.number",
          @(3):@"fl.content.name",
          @(4):@"fl.content.type",
          @(5):@"fl.content.id",
          @(6):@"fl.credit.name",
          @(7):@"fl.credit.type",
          @(8):@"fl.credit.id",
          @(9):@"fl.is.currency.soft",
          @(10):@"fl.currency.type",
          @(11):@"fl.payment.type",
          @(12):@"fl.item.name",
          @(13):@"fl.item.type",
          @(14):@"fl.item.id",
          @(15):@"fl.item.count",
          @(16):@"fl.item.category",
          @(17):@"fl.item.list.type",
          @(18):@"fl.price",
          @(19):@"fl.total.amount",
          @(20):@"fl.achievement.id",
          @(21):@"fl.score",
          @(22):@"fl.rating",
          @(23):@"fl.transaction.id",
          @(24):@"fl.success",
          @(25):@"fl.is.annual.subscription",
          @(26):@"fl.subscription.country",
          @(27):@"fl.trial.days",
          @(28):@"fl.predicted.ltv",
          @(29):@"fl.group.name",
          @(30):@"fl.tutorial.name",
          @(31):@"fl.step.number",
          @(32):@"fl.user.id",
          @(33):@"fl.method",
          @(34):@"fl.query",
          @(35):@"fl.search.type",
          @(36):@"fl.social.content.name",
          @(37):@"fl.social.content.id",
          @(38):@"fl.like.type",
          @(39):@"fl.media.name",
          @(40):@"fl.media.type",
          @(41):@"fl.media.id",
          @(42):@"fl.duration"
       };
    }
    return _paramStringMap;
}

- (void)fetchPublisherData{
    [Flurry fetch];
}

- (void)registerPublisherDataListener{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [Flurry registerFetchObserver:[FlurryFlutterPlugin shared] withExecutionQueue:dispatch_get_main_queue()];
    });
}

- (BOOL)isPublisherDataFetched{
    return [Flurry isFetchFinished];
}

- (NSDictionary<NSString *, NSString *> *)getPublisherData{
    return [Flurry getPublisherData];
}

- (void)onFetched:(NSDictionary<NSString *,NSString *> *)publisherData{
    self->_emitter(publisherData);
}

- (NSString *)enumToStandardParamString:(int)paramEnum{
    return [self paramStringMap][@(paramEnum)];
}

#if __has_include(<StoreKit/SKAdNetwork.h>)
-(void) flurryUpdateConversionValue:(nullable NSDictionary*) conversionValue {
    if (@available(iOS 14.0, *)) {
       NSString* conversionValueStr = conversionValue[@"conversionValueStr"];
       NSInteger* conversionValueInt = [conversionValueStr intValue];
       [FlurrySKAdNetwork flurryUpdateConversionValue:conversionValueInt];
    }
}

-(void) flurryUpdateConversionValueWithEvent:(nullable NSDictionary*) flurryEvent {
    if (@available(iOS 14.0, *)) {
       NSString* flurryEventStr = flurryEvent[@"flurryEventStr"];
       NSInteger* flurryEvent = [flurryEventStr intValue];
       [FlurrySKAdNetwork flurryUpdateConversionValueWithEvent:(FlurryConversionValueEventType) flurryEvent]
    }
}
#endif


@end
