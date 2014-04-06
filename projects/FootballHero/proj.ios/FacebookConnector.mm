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


static FacebookConnector* instance;
FBSession* session;

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
    if (!session.isOpen) {
        // create a fresh session object
        session = [[FBSession alloc] init];
    }
}

void FacebookConnector::login()
{
    if (session.state != FBSessionStateCreated) {
        // Create a new, logged out session.
        session = [[FBSession alloc] init];
    }
    
    // if the session isn't open, let's open it now and present the login UX to the user
    [session openWithCompletionHandler:^(FBSession *session,
                                                     FBSessionState status,
                                                     NSError *error) {
        NSLog(session.accessTokenData.accessToken);
    }];
    Social::FacebookDelegate::sharedDelegate()->loginResult();
}