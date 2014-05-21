/*
 * SWRVE CONFIDENTIAL
 *
 * (c) Copyright 2010-2014 Swrve New Media, Inc. and its licensors.
 * All Rights Reserved.
 *
 * NOTICE: All information contained herein is and remains the property of Swrve
 * New Media, Inc or its licensors.  The intellectual property and technical
 * concepts contained herein are proprietary to Swrve New Media, Inc. or its
 * licensors and are protected by trade secret and/or copyright law.
 * Dissemination of this information or reproduction of this material is
 * strictly forbidden unless prior written permission is obtained from Swrve.
 */

#import "SwrveCampaign.h"
#import "SwrveMessage.h"
#import "SwrveMessageController.h"

const static int  DEFAULT_MAX_IMPRESSIONS        = 99999;
const static int  DEFAULT_DELAY_FIRST_MSG        = 180;
const static int  DEFAULT_MIN_DELAY_BETWEEN_MSGS = 60;

@interface SwrveCampaign()
@property BOOL randomOrder;
@property (retain, nonatomic) NSDate*       dateStart;
@property (retain, nonatomic) NSDate*       dateEnd;
@property (retain, nonatomic) NSMutableSet* triggers;
@property (retain, nonatomic) NSDate* initialisedTime;

@end

@implementation SwrveCampaign

-(id)initWithController:(SwrveMessageController*)controller atTime:(NSDate*)time
{
    self = [super init];
    // Defaul both dates to now
    self.dateStart = self.dateEnd = [NSDate date];
    
    self.maxImpressions = DEFAULT_MAX_IMPRESSIONS;
    self.minDelayBetweenMsgs = DEFAULT_MIN_DELAY_BETWEEN_MSGS;
    self.initialisedTime = time;
    self.showMsgsAfterLaunch  = [time dateByAddingTimeInterval:DEFAULT_DELAY_FIRST_MSG];
    
    self.triggers  = [[NSMutableSet alloc] init];
    return self;
}

+(BOOL)runningOnRetinaDevice;
{
    // checks for iPhone 4. will return a false positive on iPads, so use the
    // above function in conjunction with this to determine if it's a 3GS or
    // below, or an iPhone 4.
    return  [[UIScreen mainScreen] respondsToSelector:@selector(scale)] &&
            [[UIScreen mainScreen] scale] == 2;
}

-(void)messageWasShownToUser:(SwrveMessage*)message
{
    [self incrementImpressions];
    
    // The message was shown. Take the current time so that we can throttle messages
    // from being shown too quickly.
    self.showMsgsAfterDelay = [[NSDate date] dateByAddingTimeInterval:self.minDelayBetweenMsgs];
    
    if (!self.randomOrder)
    {
        NSInteger count = [self.messages count];
        NSInteger nextMessage = (self.next + 1) % count;
        NSLog(@"Round Robin message in campaign %ld is %ld (next will be %ld)", (long)self.ID, (long)self.next, (long)nextMessage);
        self.next = nextMessage;
    }
}

-(void)incrementImpressions;
{
    self.impressions += 1;
}

static NSDate* read_date(id d, NSDate* default_date)
{
    double millis = [d doubleValue];

    if (millis > 0){
        double seconds = millis / 1000.0;
        return [NSDate dateWithTimeIntervalSince1970:seconds];
    } else {
        return default_date;
    }
}

-(void)loadDatesFrom:(NSDictionary*)json {
    self.dateStart = read_date([json objectForKey:@"start_date"], self.dateStart);
    self.dateEnd   = read_date([json objectForKey:@"end_date"],   self.dateEnd);
}

-(void)loadRulesFrom:(NSDictionary*)json {

    NSDictionary* rules = [json objectForKey:@"rules"];
    NSLog(@"Rules: %@", rules);
    self.randomOrder = [[rules objectForKey:@"display_order"] isEqualToString: @"random"];
    
    NSNumber* maxImpressions = [rules objectForKey:@"dismiss_after_views"];
    if (maxImpressions)
    {
        self.maxImpressions = [maxImpressions integerValue];
    }
    
    NSNumber* delayFirstMsg = [rules objectForKey:@"delay_first_message"];
    if (delayFirstMsg)
    {
        self.showMsgsAfterLaunch = [self.initialisedTime dateByAddingTimeInterval:delayFirstMsg.integerValue];
    }
    
    NSNumber* minDelayBetweenMsgs = [rules objectForKey:@"min_delay_between_messages"];
    if (minDelayBetweenMsgs)
    {
        self.minDelayBetweenMsgs = [minDelayBetweenMsgs doubleValue];
    }
}

-(void)loadTriggersFrom:(NSDictionary*)json{

    NSArray* jsonTriggers = [json objectForKey:@"triggers"];
    if (!jsonTriggers) {
        NSLog(@"Error loading triggers");
        return;
    }
    
    for (NSString* trigger in jsonTriggers){
        if (trigger) {
            [self.triggers addObject:[trigger lowercaseString]];
        }
    }

    NSLog(@"Campaign Triggers:");
    for (NSString* trigger in self.triggers){
        NSLog(@"- %@", trigger);
    }
}

-(BOOL)isTooSoonToShowMessageAfterLaunch:(NSDate*)now
{
    return now == [self.showMsgsAfterLaunch earlierDate:now];
}

-(BOOL)isTooSoonToShowMessageAfterDelay:(NSDate*)now
{
    return now == [self.showMsgsAfterDelay earlierDate:now];
}

static SwrveMessage* firstFormatFrom(NSArray* messages, NSSet* assets){

    // Return the first fully downloaded format
    for (SwrveMessage* message in messages) {
        if ([message isDownloaded:assets]){
            return message;
        }
    }
    return nil;
}

-(BOOL)hasMessageForEvent:(NSString*)event
{
    NSString* eventLowercase = [event lowercaseString];
    if (self.triggers != nil && ![self.triggers containsObject:eventLowercase]){
        return NO;
    }
    return YES;
}

-(SwrveMessage*)getMessageForEvent:(NSString*)event
                        withAssets:(NSSet*)assets
                            atTime:(NSDate*)time

{
    return [self getMessageForEvent:event withAssets:assets atTime:time withReasons:nil];
}


-(SwrveMessage*)getMessageForEvent:(NSString*)event
                        withAssets:(NSSet*)assets
                            atTime:(NSDate*)time
                       withReasons:(NSMutableDictionary*)campaignReasons
{
    NSInteger count = [self.messages count];
    NSString* eventLowercase = [event lowercaseString];
    if (self.triggers != nil && ![self.triggers containsObject:eventLowercase]){
        NSLog(@"There is no trigger in %ld that matches %@", (long)self.ID, event);
        return nil;
    }

    if (count == 0)
    {
        [self logAndAddReason:[NSString stringWithFormat:@"No messages in campaign %ld", (long)self.ID] withReasons:campaignReasons];
        return nil;
    }

    if ([self.dateStart compare:time] != NSOrderedAscending)
    {
        [self logAndAddReason:[NSString stringWithFormat:@"Campaign %ld has not started yet", (long)self.ID] withReasons:campaignReasons];
        return nil;
    }

    if ([time compare:self.dateEnd] != NSOrderedAscending)
    {
        [self logAndAddReason:[NSString stringWithFormat:@"Campaign %ld has finished", (long)self.ID] withReasons:campaignReasons];
        return nil;
    }

    if ([self isTooSoonToShowMessageAfterLaunch:time])
    {
        [self logAndAddReason:[NSString stringWithFormat:@"{Campaign throttle limit} Too soon after launch. Wait until %@", [SwrveMessageController getTimeFormatted:self.showMsgsAfterLaunch]] withReasons:campaignReasons];
        return nil;
    }
    
    if ([self isTooSoonToShowMessageAfterDelay:time])
    {
        [self logAndAddReason:[NSString stringWithFormat:@"{Campaign throttle limit} Too soon after last message. Wait until %@", [SwrveMessageController getTimeFormatted:self.showMsgsAfterDelay]] withReasons:campaignReasons];
        return nil;
    }
    
    if (self.impressions >= self.maxImpressions)
    {
        [self logAndAddReason:[NSString stringWithFormat:@"{Campaign throttle limit} Campaign %ld has been shown %ld times already", (long)self.ID, (long)self.maxImpressions] withReasons:campaignReasons];
        return nil;
    }

    SwrveMessage* message = nil;
    if (self.randomOrder)
    {
        NSLog(@"Random Message in %ld", (long)self.ID);
        NSArray* shuffled = [SwrveMessageController shuffled:self.messages];
        message = firstFormatFrom(shuffled, assets);
    }

    if (message == nil)
    {
        message = [self.messages objectAtIndex:self.next];
    }
    
    if ([message isDownloaded:assets]) {
        NSLog(@"%@ matches a trigger in %ld", event, (long)self.ID);
        return message;
    }
    
    [self logAndAddReason:[NSString stringWithFormat:@"Campaign %ld hasn't finished downloading", (long)self.ID] withReasons:campaignReasons];
    return nil;
}

-(void)logAndAddReason:(NSString*)reason withReasons:(NSMutableDictionary*)campaignReasons
{
    if(campaignReasons != nil) {
        [campaignReasons setValue:reason forKey:[[NSNumber numberWithInteger:self.ID] stringValue]];
    }
    NSLog(@"%@",reason);
}

-(id)saveSettings
{
    NSMutableDictionary* settings = [[NSMutableDictionary alloc] init];
    [settings setValue:[NSNumber numberWithInteger:self.ID] forKey:@"ID"];
    [settings setValue:[NSNumber numberWithInteger:self.next] forKey:@"next"];
    [settings setValue:[NSNumber numberWithInteger:self.impressions] forKey:@"impressions"];
    return settings;
}

@end
