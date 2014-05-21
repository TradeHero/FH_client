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

#import <Foundation/Foundation.h>

@class SwrveMessage;
@class SwrveButton;
@class SwrveMessageController;

@interface SwrveCampaign : NSObject

@property (retain) NSArray*  messages;
@property NSInteger next;
@property NSInteger ID;
@property NSInteger maxImpressions;
@property NSTimeInterval minDelayBetweenMsgs;
@property NSInteger impressions;
@property (nonatomic, retain) NSDate* showMsgsAfterLaunch; // Only show messages after this time.
@property (nonatomic, retain) NSDate* showMsgsAfterDelay; // Only show messages after this time.
@property (retain, nonatomic) NSString* name;

-(id)initWithController:(SwrveMessageController*)controller
                 atTime:(NSDate*)time;

-(BOOL)hasMessageForEvent:(NSString*)event;

-(SwrveMessage*)getMessageForEvent:(NSString*)event
                        withAssets:(NSSet*)assets
                            atTime:(NSDate*)time;
-(SwrveMessage*)getMessageForEvent:(NSString*)event
                        withAssets:(NSSet*)assets
                            atTime:(NSDate*)time
                       withReasons:(NSMutableDictionary*)campaignReasons;

+(BOOL)runningOnRetinaDevice;
-(void)incrementImpressions;
-(void)messageWasShownToUser:(SwrveMessage*)message;
-(id)saveSettings;
-(void)loadTriggersFrom:(NSDictionary*)json;
-(void)loadRulesFrom:(NSDictionary*)json;
-(void)loadDatesFrom:(NSDictionary*)json;

@end
