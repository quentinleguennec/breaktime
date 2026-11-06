#include "AppDelegate.h"
#include "GeneratedPluginRegistrant.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import <uni_links/UniLinksPlugin.h>

@implementation WTUserInfoHandler

FlutterEventSink sink;
NSDictionary *info;

- (void) updateUserInfo:(nonnull NSDictionary<NSString *, id> *)userInfo{
    if(info != userInfo){
        info = userInfo;
        if(sink!=nil){
            sink(@[userInfo]);
        }
    }
}

- (FlutterError*)onListenWithArguments:(id)arguments eventSink:(FlutterEventSink)eventSink {
    //NSLog(@"Adding Flutter Listener");
    sink = eventSink;
    return nil;
}

- (FlutterError*)onCancelWithArguments:(id)arguments {
    //NSLog(@"Removing Flutter Listener");
    if(sink!=nil){
        sink = nil;
    }
    return nil;
}

@end

@implementation AppDelegate

// RECEIVES INFO FROM THE WATCH -----------------
- (void)session:(nonnull WCSession *)session didReceiveUserInfo:(nonnull NSDictionary<NSString *, id> *)userInfo
{
    if(userInfoStreamHandler != nil){
        [userInfoStreamHandler updateUserInfo:userInfo];
    }
}
// RECEIVES INFO FROM THE WATCH WHEN BOTH APPS ARE ACTIVE-----------------
- (void)session:(WCSession *)session didReceiveMessage:(NSDictionary<NSString *,id> *)message{
    if(userInfoStreamHandler != nil){
        [userInfoStreamHandler updateUserInfo:message];
    }
}

// SENDS INFO TO THE WATCH -----------------
- (void)session:(nonnull WCSession *)session activationDidCompleteWithState:(WCSessionActivationState)activationState error:(nullable NSError *)error {
    
    
}


- (void)sessionDidBecomeInactive:(nonnull WCSession *)session {
    
}


- (void)sessionDidDeactivate:(nonnull WCSession *)session {
    
}

// Method used to enable the Watch session
- (void)activateSession
{
    
    [self activateChannel];
    [self watchSession];
}

// create our eventChannel
-(FlutterEventChannel *) activateChannel {
    userInfoStreamHandler = [[WTUserInfoHandler alloc] init];
    FlutterViewController* controller = (FlutterViewController*)self.window.rootViewController;
    FlutterEventChannel *eventChannel = [FlutterEventChannel eventChannelWithName:@"com.aebeze.ios/info/data" binaryMessenger:controller];
    [eventChannel setStreamHandler:(NSObject<FlutterStreamHandler> * _Nullable) userInfoStreamHandler ];
    return eventChannel;
}


// activate session
- (WCSession *)watchSession
{
    if (watchSession == nil) {
        if ([WCSession isSupported]) {
            watchSession = [WCSession defaultSession];
            [watchSession setDelegate:self];
            [watchSession activateSession];
        } else {
            NSLog(@"Error -  Watch Connectivity NOT supported");
        }
    }
    return watchSession;
}

- (void)dealloc
{
    if (watchSession != nil) {
        [watchSession setDelegate:nil];
    }
}

- (BOOL)application:(UIApplication *)application
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    FlutterViewController* controller = (FlutterViewController*)self.window.rootViewController;
    FlutterMethodChannel *tipinfoChannel = [FlutterMethodChannel
                                            methodChannelWithName:@"com.aebeze.ios/info"
                                            binaryMessenger:controller];
    
    
    [tipinfoChannel setMethodCallHandler:^(FlutterMethodCall* call, FlutterResult result) {
        
        // activate Session
        if([@"activateSession" isEqualToString:call.method]){
            [self activateSession];
            result(@"Moodrise Watch Activated");
        } else if ([@"receiveMoodsFromMobileApp" isEqualToString:call.method]){
            NSDictionary *colourAndMoodDict = call.arguments[@"colourAndMoodDict"];
            if(self.watchSession.isReachable){
                [self.watchSession sendMessage:colourAndMoodDict replyHandler:nil errorHandler:^(NSError * _Nonnull error) {
                    NSLog(@"Error while sending message to watch");
                }];
            }
            else{
                [self.watchSession transferUserInfo:colourAndMoodDict];
            }
            
        } else {
            result(FlutterMethodNotImplemented);;
        }
    }];
    
    [GeneratedPluginRegistrant registerWithRegistry:self];
    
    // Override point for customization after application launch.
    return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

@end
