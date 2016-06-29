

#include "AnalyticsHandler.h"
#import "LocalyticsSession.h"
#import "Flurry.h"
#import <TongDaoSDK/TongDao.h>
#import <TongDaoUILibrary/TongDaoUiCore.h>


static AnalyticsHandler* instance;

AnalyticsHandler* AnalyticsHandler::getInstance()
{
    if (instance == NULL)
    {
        instance = new AnalyticsHandler();
    }
    return instance;
}

void AnalyticsHandler::postEvent(const char* eventName, const char* paramString)
{
    if (paramString != NULL)
    {
        NSError *error = nil;
        NSData *data = [[NSString stringWithUTF8String:paramString] dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *params = [NSJSONSerialization JSONObjectWithData:data options:NSJSONWritingPrettyPrinted error:&error];
        
        if (error == nil)
        {
            [[LocalyticsSession shared] tagEvent:[NSString stringWithUTF8String:eventName] attributes:params];
        }
        else
        {
            NSLog(@"Post event error with: %@", error);
        }
    }
    else
    {
        [[LocalyticsSession shared] tagEvent:[NSString stringWithUTF8String:eventName]];
    }
}

void AnalyticsHandler::postFlurryEvent(const char* eventName, const char* paramString)
{
    if (paramString != NULL)
    {
        NSError *error = nil;
        NSData *data = [[NSString stringWithUTF8String:paramString] dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *params = [NSJSONSerialization JSONObjectWithData:data options:NSJSONWritingPrettyPrinted error:&error];
        
        if (error == nil)
        {
            [Flurry logEvent:[NSString stringWithUTF8String:eventName] withParameters:params];
        }
        else
        {
            NSLog(@"Post event error with: %@", error);
        }
    }
    else
    {
        [Flurry logEvent:[NSString stringWithUTF8String:eventName]];
    }
}

void AnalyticsHandler::postTongdaoEvent(const char* eventName, const char* paramString)
{
    if (paramString != NULL)
    {
        NSError *error = nil;
        NSData *data = [[NSString stringWithUTF8String:paramString] dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *params = [NSJSONSerialization JSONObjectWithData:data options:NSJSONWritingPrettyPrinted error:&error];
        
        if (error == nil)
        {
            NSLog(@"Post Tongdao event: %s param: %s", eventName, paramString);
            [[TongDaoUiCore sharedManager] trackWithEventName:[NSString stringWithUTF8String:eventName] andValues:params];
        }
        else
        {
            NSLog(@"Post event error with: %@", error);
        }
    }
    else
    {
        NSLog(@"Post Tongdao event: %s", eventName);
        [[TongDaoUiCore sharedManager] trackWithEventName:[NSString stringWithUTF8String:eventName]];
    }
}

void AnalyticsHandler::loginTongdao(const char* userId)
{
    NSLog(@"Login Tongdao: %s", userId);
    [TongDao setUserId:[NSString stringWithUTF8String:userId]];
}

void AnalyticsHandler::trackTongdaoAttrs(const char* paramString)
{
    NSError *error = nil;
    NSData *data = [[NSString stringWithUTF8String:paramString] dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *params = [NSJSONSerialization JSONObjectWithData:data options:NSJSONWritingPrettyPrinted error:&error];
    
    if (error == nil)
    {
        NSLog(@"Track Tongdao Attr:%s", paramString);
        [[TongDaoUiCore sharedManager] identify:params];
    }
    else
    {
        NSLog(@"Post event error with: %@", error);
    }
}

void AnalyticsHandler::trackTongdaoAttr(const char* attrName, const char* value)
{
    NSLog(@"Track Tongdao Attr: %s value: %s", attrName, value);
    NSString* attr = [NSString stringWithUTF8String:attrName];
    if ([attr isEqualToString:@"UserName"]) {
        [[TongDaoUiCore sharedManager] identifyUserName:[NSString stringWithUTF8String:value]];
    } else if ([attr isEqualToString:@"Email"]){
        [[TongDaoUiCore sharedManager] identifyEmail:[NSString stringWithUTF8String:value]];
    } else if ([attr isEqualToString:@"Phone"]){
        [[TongDaoUiCore sharedManager] identifyPhone:[NSString stringWithUTF8String:value]];
    } else if ([attr isEqualToString:@"Gender"]){
        [[TongDaoUiCore sharedManager] identifyGender:[NSString stringWithUTF8String:value]];
    } else if ([attr isEqualToString:@"Avatar"]){
        [[TongDaoUiCore sharedManager] identifyAvatar:[NSString stringWithUTF8String:value]];
    } else if ([attr isEqualToString:@"FullName"]){
        [[TongDaoUiCore sharedManager] identifyFullName:[NSString stringWithUTF8String:value]];
    } else {
        [[TongDaoUiCore sharedManager] identifyWithKey:attr
                                              andValue:[NSString stringWithUTF8String:value]];
    }
}

void AnalyticsHandler::trackTongdaoOrder(const char* orderName, const float* price, const char* currency)
{
    NSLog(@"Track Tongdao order: %s price: %f currency:%s", orderName, *price, currency);
    [[TongDaoUiCore sharedManager] trackPlaceOrder:[NSString stringWithUTF8String:orderName] andPrice:*price andCurrency:[NSString stringWithUTF8String:currency]];
}
