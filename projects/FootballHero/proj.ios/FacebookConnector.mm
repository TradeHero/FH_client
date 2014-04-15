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
#import "FBSessionSingleton.h"

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
    
    [FBSession openActiveSessionWithReadPermissions: @[@"basic_info", @"email", @"user_birthday"] allowLoginUI:YES completionHandler:^(FBSession *aSession, FBSessionState status, NSError *error) {
        
        [FBSessionSingleton sharedInstance].session = aSession;
        const char* accessToken =[aSession.accessTokenData.accessToken UTF8String];
        Social::FacebookDelegate::sharedDelegate()->loginResult(accessToken);
        
    }];
}