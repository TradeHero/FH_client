

#include "AnalyticsHandler.h"
#import "LocalyticsSession.h"


static AnalyticsHandler* instance;

AnalyticsHandler* AnalyticsHandler::getInstance()
{
    if (instance == NULL)
    {
        instance = new AnalyticsHandler();
    }
    return instance;
}

void AnalyticsHandler::postEvent(const char* eventName, const char* key, const char* value)
{
    if (key != NULL && value != NULL)
    {
        NSDictionary * payload = [NSDictionary dictionaryWithObject:[NSString stringWithUTF8String:value] forKey:[NSString stringWithUTF8String:key]];
        [[LocalyticsSession shared] tagEvent:[NSString stringWithUTF8String:eventName] attributes:payload];
    }
    else
    {
        [[LocalyticsSession shared] tagEvent:[NSString stringWithUTF8String:eventName]];
    }
}