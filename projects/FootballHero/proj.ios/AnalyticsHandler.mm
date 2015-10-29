

#include "AnalyticsHandler.h"
#import "LocalyticsSession.h"
#import "Flurry.h"


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

