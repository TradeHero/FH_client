//
//  FacebookConnector.cpp
//  FootballHero
//
//  Created by trdehero on 14-4-3.
//
//

#include "FacebookConnector.h"
#include "FacebookDelegate.h"
#import <FacebookSDK/FacebookSDK.h>
#import <FacebookSDK/FBSettings.h>
#import "FBSessionSingleton.h"
#import "AppController.h"
#import "RootViewController.h"

static FacebookConnector* instance;

FacebookConnector* FacebookConnector::getInstance()
{
    if (instance == NULL)
    {
        instance = new FacebookConnector();
        instance->initSession();
        
    }
    return instance;
}

void FacebookConnector::initSession()
{
    NSLog(@"\nFacebook Connector init.");
    [FBSessionSingleton sharedInstance].session;
}

void FacebookConnector::login()
{
    FBSession* session = [FBSessionSingleton sharedInstance].session;
    if (session.state != FBSessionStateCreated) {
        // Create a new, logged out session.
        session = [[FBSession alloc] init];
    }
    
    [FBSession openActiveSessionWithReadPermissions: @[@"public_profile", @"user_friends", @"email", @"user_birthday"] allowLoginUI:YES completionHandler:^(FBSession *aSession, FBSessionState status, NSError *error) {

        if( status == FBSessionStateOpen ) {
            [FBSessionSingleton sharedInstance].session = aSession;
            const char* accessToken =[aSession.accessTokenData.accessToken UTF8String];
            Social::FacebookDelegate::sharedDelegate()->accessTokenUpdate(accessToken);
        }
    }];
}

void FacebookConnector::grantPublishPermission(const char* permission)
{
    NSString *publishPermission = [NSString stringWithUTF8String:permission];
    FBSession* session = [FBSessionSingleton sharedInstance].session;
    if ([session hasGranted:publishPermission])
    {
        Social::FacebookDelegate::sharedDelegate()->permissionUpdate(nil, true);
    }
    else
    {
        [session requestNewPublishPermissions:@[publishPermission] defaultAudience:FBSessionDefaultAudienceFriends completionHandler:^(FBSession *aSession, NSError *error)
         {
             [FBSessionSingleton sharedInstance].session = aSession;
             const char* accessToken =[aSession.accessTokenData.accessToken UTF8String];
             Social::FacebookDelegate::sharedDelegate()->permissionUpdate(accessToken, [aSession hasGranted:publishPermission]);
         }];
    }
}

void FacebookConnector::like()
{
    
    [FBSettings enableBetaFeature:FBBetaFeaturesLikeButton];
    [FBSettings enablePlatformCompatibility:NO];
    
    
    FBLikeControl *like = [[FBLikeControl alloc] init];
    like.foregroundColor = [UIColor whiteColor];
    like.objectID = @"http://www.facebook.com/FootballHeroApp";
    
    AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
    UIView *mainView = [app getViewController].view;
    [mainView addSubview:like];
}
