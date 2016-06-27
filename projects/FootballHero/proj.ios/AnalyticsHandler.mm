

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
    [TongDao setUserId:[NSString stringWithUTF8String:userId]];
}

void AnalyticsHandler::trackTongdaoAttr(const char* paramString)
{
    NSError *error = nil;
    NSData *data = [[NSString stringWithUTF8String:paramString] dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *params = [NSJSONSerialization JSONObjectWithData:data options:NSJSONWritingPrettyPrinted error:&error];
    
    if (error == nil)
    {
        NSLog(@"Track Tongdao Attr: param: %s", paramString);
        [[TongDaoUiCore sharedManager] identify:params];
    }
    else
    {
        NSLog(@"Post event error with: %@", error);
    }
}

void AnalyticsHandler::trackTongdaoOrder(const char* orderName, const float* price, const char* currency)
{
    NSLog(@"Track Tongdao order: %s param: %s", orderName, currency);
    [[TongDaoUiCore sharedManager] trackPlaceOrder:[NSString stringWithUTF8String:orderName] andPrice:*price andCurrency:[NSString stringWithUTF8String:currency]];
}



