/****************************************************************************
 Copyright (c) 2010 cocos2d-x.org

 http://www.cocos2d-x.org

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 ****************************************************************************/
#import <UIKit/UIKit.h>
#import "AppController.h"
#import "cocos2d.h"
#import "EAGLView.h"
#import "AppDelegate.h"
#import "WebviewController.h"
#import "LocalyticsSession.h"

#import "UAConfig.h"
#import "UAirship.h"
#import "UAPush.h"
#import "UAInbox.h"
#import "UAInboxUI.h"
#import "AppsFlyerTracker.h"

#import "RootViewController.h"
#import "FBSessionSingleton.h"
#import <FacebookSDK/FacebookSDK.h>
#import <MobileAppTracker/MobileAppTracker.h>
#import <AdSupport/AdSupport.h>
#include "MiscHandler.h"

@implementation AppController

#pragma mark -
#pragma mark Application lifecycle

// cocos2d application instance
static AppDelegate s_sharedApplication;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    // Override point for customization after application launch.

    // Add the view controller's view to the window and display.
    window = [[UIWindow alloc] initWithFrame: [[UIScreen mainScreen] bounds]];
    EAGLView *__glView = [EAGLView viewWithFrame: [window bounds]
                                     pixelFormat: kEAGLColorFormatRGBA8
                                     depthFormat: GL_DEPTH24_STENCIL8_OES
                              preserveBackbuffer: NO
                                      sharegroup: nil
                                   multiSampling: NO
                                 numberOfSamples: 0 ];

    [__glView setMultipleTouchEnabled:YES];
    // Use RootViewController manage EAGLView
    viewController = [[RootViewController alloc] initWithNibName:nil bundle:nil];
    viewController.wantsFullScreenLayout = YES;
    viewController.view = __glView;

    // Set RootViewController to window
    if ( [[UIDevice currentDevice].systemVersion floatValue] < 6.0)
    {
        // warning: addSubView doesn't work on iOS6
        [window addSubview: viewController.view];
    }
    else
    {
        // use this method on ios6
        [window setRootViewController:viewController];
    }
    
    [window makeKeyAndVisible];

    [[UIApplication sharedApplication] setStatusBarHidden: YES];

    cocos2d::CCApplication::sharedApplication()->run();
    
    NSDate *startTime = [NSDate date];
    NSLog(@"Start date:%@",startTime);
    
    // Localytics
    [[LocalyticsSession shared] LocalyticsSession:@"d16d149eabf971a5b376a43-aa0e6fc0-1c50-11e4-49cb-00a426b17dd8"];
    [[LocalyticsSession shared] setLoggingEnabled:YES];
    
    // MAT
    [MobileAppTracker initializeWithMATAdvertiserId:@"19686"
                                   MATConversionKey:@"c65b99d5b751944e3637593edd04ce01"];
    [MobileAppTracker setAppleAdvertisingIdentifier:[[ASIdentifierManager sharedManager] advertisingIdentifier]
                         advertisingTrackingEnabled:[[ASIdentifierManager sharedManager] isAdvertisingTrackingEnabled]];
    
    //UrbanAirship
    [UAirship setLogLevel:UALogLevelTrace];
    [UAirship takeOff:[UAConfig defaultConfig]];
    [UAPush setDefaultPushEnabledValue:NO];
    [[UAPush shared] resetBadge];
    [UAPush shared].notificationTypes = (UIRemoteNotificationTypeBadge |
                                         UIRemoteNotificationTypeSound |
                                         UIRemoteNotificationTypeAlert);
    [UAInbox useCustomUI:[UAInboxUI class]];
    [UAInbox shared].pushHandler.delegate = [UAInboxUI shared];
    [UAInboxUI shared].inboxParentController = viewController;
    NSLog(@"UA device token is %@", [UAPush shared].deviceToken);

    // AppsFlyer
    [AppsFlyerTracker sharedTracker].appsFlyerDevKey = @"pEuxjZE2GpyRXXwFjHHRRU";
    [AppsFlyerTracker sharedTracker].appleAppID = @"859894802";

    NSTimeInterval timeInterval = [startTime timeIntervalSinceNow];
    NSLog(@"Interval:%f",timeInterval);
    
    return YES;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    
    // Normally your app would handle url navigation here and go to the correct
    // app location.  In this example we just print the url in an alert.
    
   return NO;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
    cocos2d::CCDirector::sharedDirector()->pause();
    
    [[LocalyticsSession shared] close];
    [[LocalyticsSession shared] upload];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    cocos2d::CCDirector::sharedDirector()->resume();
    
    // Handle the user leaving the app while the Facebook login dialog is being shown
    // For example: when the user presses the iOS "home" button while the login dialog is active
    [FBAppCall handleDidBecomeActive];
    
    [[LocalyticsSession shared] resume];
    [[LocalyticsSession shared] upload];
    
    [MobileAppTracker measureSession];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
    cocos2d::CCApplication::sharedApplication()->applicationDidEnterBackground();
    
    [[LocalyticsSession shared] close];
    [[LocalyticsSession shared] upload];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
    cocos2d::CCApplication::sharedApplication()->applicationWillEnterForeground();
    
    [[LocalyticsSession shared] resume];
    [[LocalyticsSession shared] upload];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
    
    [[LocalyticsSession shared] close];
    [[LocalyticsSession shared] upload];
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
     cocos2d::CCDirector::sharedDirector()->purgeCachedData();
}


- (void)dealloc {
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    
    [MobileAppTracker applicationDidOpenURL:[url absoluteString] sourceApplication:sourceApplication];
    
    if([[LocalyticsSession shared] handleURL:url])
    {
        return YES;
    }
    
    if([[url host] isEqualToString:@"openPage"])
    {
        deepLink = [url path];
        NSLog(@"Deep link path:%@", deepLink);
        
        MiscHandler::getInstance()->notifyDeepLink([deepLink UTF8String]);
        return YES;
    }
    
    return [FBAppCall handleOpenURL:url
                  sourceApplication:sourceApplication];
}

- (RootViewController *)getViewController
{
    return viewController;
}

- (NSString *)getDeepLink
{
    return deepLink;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    UA_LINFO(@"APNS device token: %@", deviceToken);
    
    // Updates the device token and registers the token with UA. This won't occur until
    // push is enabled if the outlined process is followed. This call is required.
    [[UAPush shared] registerDeviceToken:deviceToken];
    
    NSString* token = [UAPush shared].deviceToken;
    MiscHandler::getInstance()->responseUADeviceToken([token UTF8String]);
}


@end

