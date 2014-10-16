//
//  FacebookConnector.cpp
//  FootballHero
//
//  Created by trdehero on 14-4-3.
//
//

#include "ShareSDKConnector.h"
#include "ShareSDKDelegate.h"


#import <ShareSDK/ShareSDK.h>
#import <ShareSDK/ISSPlatformCredential.h>


static ShareSDKConnector* instance;

ShareSDKConnector* ShareSDKConnector::getInstance()
{
    if (instance == NULL)
    {
        instance = new ShareSDKConnector();
    }
    return instance;
}

void ShareSDKConnector::login()
{
    id<ISSAuthOptions> authOptions = [ShareSDK authOptionsWithAutoAuth:YES
                                                         allowCallback:YES
                                                         authViewStyle:SSAuthViewStyleFullScreenPopup
                                                          viewDelegate:nil
                                               authManagerViewDelegate:nil];
    [authOptions setScopes:[NSDictionary dictionaryWithObjectsAndKeys:
                            @[@"public_profile", @"user_friends", @"email", @"user_birthday", @"publish_actions"],
                            [NSNumber numberWithInt:ShareTypeFacebook],
                            nil]
     ];
    
    
    [ShareSDK authWithType:ShareTypeFacebook
                   options:authOptions
                    result:^(SSAuthState state, id<ICMErrorInfo> error) {
                        if (state == SSAuthStateSuccess)
                        {
                            id<ISSPlatformCredential> credential = [ShareSDK getCredentialWithType:ShareTypeFacebook];
                            const char* accessToken =[[credential token] UTF8String];
                            Social::ShareSDKDelegate::sharedDelegate()->accessTokenUpdate(accessToken);
                        }
                        else if (state == SSAuthStateFail or state == SSAuthStateCancel)
                        {
                            Social::ShareSDKDelegate::sharedDelegate()->accessTokenUpdate(nil);
                        }
                    }];
    
    /*
    [ShareSDK authWithType:ShareTypeWeixiSession
                   options:nil
                    result:^(SSAuthState state, id<ICMErrorInfo> error) {
                        if (state == SSAuthStateSuccess)
                        {
                            id<ISSPlatformCredential> credential = [ShareSDK getCredentialWithType:ShareTypeWeixiSession];
                            NSLog(@"成功 %@ ", [credential token]);
                            const char* accessToken =[[credential token] UTF8String];
                            Social::ShareSDKDelegate::sharedDelegate()->accessTokenUpdate(accessToken);
                            share("Match share", "Content");
                        }
                        else if (state == SSAuthStateFail or state == SSAuthStateCancel)
                        {
                            NSLog(@"失败 %@", error.errorDescription);
                            Social::ShareSDKDelegate::sharedDelegate()->accessTokenUpdate(nil);
                        }
                    }];
     
     
     */
}

void ShareSDKConnector::share(const char* title, const char* content)
{
    //构造分享内容
    id<ISSContent> publishContent = [ShareSDK content:[NSString stringWithUTF8String:title]
                                       defaultContent:[NSString stringWithUTF8String:content]
                                                image:nil
                                                title:@"ShareSDK"
                                                  url:@"http://footballheroapp.com"
                                          description:@"Share"
                                            mediaType:SSPublishContentMediaTypeNews];
    
    [ShareSDK showShareActionSheet:nil
                         shareList:nil
                           content:publishContent
                     statusBarTips:YES
                       authOptions:nil
                      shareOptions: nil
                            result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
                                if (state == SSResponseStateSuccess)
                                {
                                    NSLog(@"分享成功");
                                }
                                else if (state == SSResponseStateFail)
                                {
                                    NSLog(NSLocalizedString(@"TEXT_SHARE_FAI", @"发布失败!error code == %d, error code == %@"), [error errorCode], [error errorDescription]);
                                }
                            }];
}