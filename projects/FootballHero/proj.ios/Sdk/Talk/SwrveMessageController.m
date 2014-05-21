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

#import <objc/runtime.h>
#include <CommonCrypto/CommonDigest.h>
#include <CommonCrypto/CommonHMAC.h>
#import "SwrveMessageController.h"
#import "SwrveMessage.h"
#import "SwrveButton.h"
#import "SwrveCampaign.h"
#import "SwrveImage.h"
#import "SwrveTalkQA.h"
#include "swrve.h"

static NSString* swrve_folder         = @"com.ngt.msgs";
static NSString* swrve_campaign_cache = @"cmcc.json";
static NSString* swrve_campaign_cache_signature = @"cmccsgt.txt";
static NSString* swrve_device_token_key = @"swrve_device_token";
static dispatch_once_t autoShowMessagePred;

const static int CAMPAIGN_VERSION            = 4;
const static int CAMPAIGN_RESPONSE_VERSION   = 1;
const static int DEFAULT_DELAY_FIRST_MESSAGE = 150;
const static int DEFAULT_MAX_SHOWS           = 99999;
const static int DEFAULT_MIN_DELAY           = 55;

const static NSString* orientation_name [] = {
    [SWRVE_ORIENTATION_LANDSCAPE] = @"landscape",
    [SWRVE_ORIENTATION_PORTRAIT]  = @"portrait",
    [SWRVE_ORIENTATION_BOTH]      = @"both"
};

@interface Swrve(PrivateMethodsForMessageController)
-(void) setPushNotificationsDeviceToken:(NSData*)deviceToken;
-(void) pushNotificationReceived:(NSDictionary*)userInfo;
- (void) invalidateETag;
@end

@interface Swrve (SwrveHelperMethods)
- (CGRect) getDeviceScreenBounds;
- (NSString*) getSignatureKey;
- (void) sendHttpGETRequest:(NSURL*)url completionHandler:(void (^)(NSURLResponse*, NSData*, NSError*))handler;
@end

@interface Swrve (SwrveMessageControllerTests)
- (NSArray *)TEST_getTalkCampaignRequests;
- (NSArray *)TEST_getTalkCampaignResponses;
- (NSArray *) TEST_getTalkAssetsDownloading;
@property BOOL TEST_campaignsDownloading;
@end

@interface SwrveMessageController()

@property (nonatomic, retain) NSString*             user;
@property (nonatomic, retain) NSString*             token;
@property (nonatomic, retain) NSString*             cdnRoot;
@property (nonatomic, retain) NSString*             apiKey;
@property (nonatomic, retain) NSString*         	server;
@property (nonatomic, retain) NSOperationQueue*     queue;
@property (nonatomic, retain) NSMutableSet*         assetsOnDisk;
@property (nonatomic, retain) NSString*             cacheFolder;
@property (nonatomic, retain) NSString*             campaignCache;
@property (nonatomic, retain) NSString*             campaignCacheSignature;
@property (nonatomic, retain) SwrveSignatureProtectedFile* campaignFile;
@property (nonatomic, retain) NSString*             language; // ISO language code
@property (nonatomic, retain) NSFileManager*        manager;
@property (nonatomic, retain) NSMutableDictionary*  appStoreURLs;
@property (nonatomic, retain) NSMutableArray*       notifications;
@property (nonatomic, retain) NSString*             settingsPath;
@property (nonatomic, retain) NSDate*               initialisedTime; // SDK init time
@property (nonatomic, retain) NSDate*               showMessagesAfterLaunch; // Only show messages after this time.
@property (nonatomic, retain) NSDate*               showMessagesAfterDelay; // Only show messages after this time.
@property (nonatomic)         bool                  pushEnabled; // Decide if push notification is enabled
@property (nonatomic, retain) NSSet*                pushNotificationEvents; // Events that trigger the push notification dialog


// Current Device Properties
@property (nonatomic) int device_width;
@property (nonatomic) int device_height;
@property (nonatomic) SwrveInterfaceOrientation orientation;


// Only ever show this many messages. This number is decremented each time a
// message is shown.
@property long messagesLeftToShow;
@property NSTimeInterval minDelayBetweenMessage;

@property (nonatomic) Swrve* analyticsSDK;

// QA
@property (nonatomic) SwrveTalkQA* qaUser;

// Private functions
- (void) initCampaignsFromCacheFile;
@end

@implementation SwrveMessageController

@synthesize server;
@synthesize cdnRoot;
@synthesize apiKey;
@synthesize queue;
@synthesize cacheFolder;
@synthesize campaignCache;
@synthesize campaignCacheSignature;
@synthesize campaignFile;
@synthesize manager;
@synthesize settingsPath;
@synthesize initialisedTime;
@synthesize showMessagesAfterLaunch;
@synthesize showMessagesAfterDelay;
@synthesize messagesLeftToShow;
@synthesize backgroundColor;


- (id)initWithSwrve:(Swrve*)sdk
{
    self = [super init];
    CGRect screen_bounds = [sdk getDeviceScreenBounds];
    const int side_a = screen_bounds.size.width;
    const int side_b = screen_bounds.size.height;
    self.device_height = MAX(side_a, side_b);
    self.device_width  = MIN(side_a, side_b);
    self.orientation   = sdk.config.orientation;

    self.language           = sdk.config.language;
    self.user               = sdk.userID;
    self.token              = sdk.config.linkToken;
    self.apiKey             = sdk.apiKey;
    self.server             = sdk.config.contentServer;
    self.analyticsSDK       = sdk;
    self.pushEnabled        = sdk.config.pushEnabled;
    self.pushNotificationEvents = sdk.config.pushNotificationEvents;
    self.settingsPath       = @"com.swrve.messages.settings.plist";
    self.cdnRoot            = nil;
    self.appStoreURLs       = [[NSMutableDictionary alloc] init];
    self.assetsOnDisk       = [[NSMutableSet alloc] init];
    self.backgroundColor    = [UIColor blackColor];
    
    NSString* cacheRoot     = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    self.cacheFolder        = [cacheRoot stringByAppendingPathComponent:swrve_folder];
    self.campaignCache      = [self.cacheFolder stringByAppendingPathComponent:swrve_campaign_cache];
    self.campaignCacheSignature = [self.cacheFolder stringByAppendingPathComponent:swrve_campaign_cache_signature];
    self.manager            = [NSFileManager defaultManager];
    self.queue              = [[NSOperationQueue alloc] init];
    self.notifications      = [[NSMutableArray alloc] init];

    // Initialize campaign cache file
    [self initCampaignsFromCacheFile];
    
    // Queue information
    [self.queue setMaxConcurrentOperationCount:sdk.config.maxConcurrentDownloads];
    [self.queue setName:@"Swrve Message Queue"];
    
    // Game rule defaults
    self.initialisedTime = [NSDate date];
    self.showMessagesAfterLaunch  = [NSDate date];
    self.messagesLeftToShow = LONG_MAX;
    
    NSLog(@"Swrve Messaging System initialised: Server: %@ Game: %@",
          self.server,
          self.apiKey);

    SwrveMessageController * __weak weakSelf = self;
    [sdk setEventQueuedCallback:^(NSDictionary *eventPayload, NSString *eventsPayloadAsJSON) {
        [weakSelf eventRaised:eventPayload];
    }];
    
    
    NSAssert1([self.language length] > 0, @"Invalid language specified %@", self.language);
    NSAssert1([self.user     length] > 0, @"Invalid username specified %@", self.user);
    NSAssert(self.analyticsSDK != NULL,   @"Swrve Analytics SDK is null");

    NSData* device_token = [[NSUserDefaults standardUserDefaults] objectForKey:swrve_device_token_key];
    if (self.pushEnabled && device_token) {
            // Once we have a device token, ask for it every time
            [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound];
            [self setDeviceToken:device_token];
    }
    
    return self;
}

- (NSDictionary*)getCampaignSettings
{
    NSMutableDictionary* settings = [[NSMutableDictionary alloc] init];
    
    NSString* root = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString* path = [root stringByAppendingPathComponent:self.settingsPath];
    
    NSData* data = [NSData dataWithContentsOfFile:path];

    if(!data)
    {
        NSLog(@"Error: No settings loaded. [Reading from %@]", path);
        return [NSDictionary dictionaryWithDictionary:settings];
    }
    
    NSError* error = NULL;
    NSArray* loadedSettings = [NSPropertyListSerialization propertyListWithData:data
                                                                        options:NSPropertyListImmutable
                                                                         format:NULL
                                                                          error:&error];
    for (NSDictionary* setting in loadedSettings)
    {
        NSString* campaignId = [setting objectForKey:@"ID"];
        if(campaignId)
        {
            [settings setValue:setting forKey:campaignId];
        }
    }
    
    return [NSDictionary dictionaryWithDictionary:settings];
}

- (void)saveSettings
{
    NSMutableArray* newSettings = [[NSMutableArray alloc] initWithCapacity:self.campaigns.count];
    
    for (SwrveCampaign* campaign in self.campaigns)
    {
        [newSettings addObject:[campaign saveSettings]];
    }
    
    NSError*  error = NULL;
    NSString* root = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString* path = [root stringByAppendingPathComponent:self.settingsPath];
    NSData*   data = [NSPropertyListSerialization dataWithPropertyList:newSettings
                                                                   format:NSPropertyListXMLFormat_v1_0
                                                                  options:0
                                                                    error:&error];
    if(data)
    {
        BOOL success = [data writeToFile:path atomically:YES];
        if (!success)
        {
            NSLog(@"Error writing to : %@", path);
        }
    }
    else
    {
        NSLog(@"Error: %@ writing to %@", error, path);
    }
}

- (void) initCampaignsFromCacheFile
{
    // Create campaign cache folder
    NSError* error;
    if (![manager createDirectoryAtPath:self.cacheFolder
            withIntermediateDirectories:YES
                             attributes:nil
                                  error:&error])
    {
        NSLog(@"Error creating %@: %@", self.cacheFolder, error);
    }

    // Create signature protected cache file
    NSURL* fileURL = [NSURL fileURLWithPath:self.campaignCache];
    NSURL* signatureURL = [NSURL fileURLWithPath:self.campaignCacheSignature];
    campaignFile = [[SwrveSignatureProtectedFile alloc] initFile:fileURL signatureFilename:signatureURL usingKey:[self.analyticsSDK getSignatureKey]];

    // read content of campaigns file and update campaigns
    NSData* content = [campaignFile readFromFile];

    if (content != nil) {
        NSError* error;
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:content options:0 error:&error];
        if (!error) {
            [self updateCampaigns:jsonDict];
        }
    } else {
        [[self analyticsSDK] invalidateETag];
    }
}

static NSNumber* numberFromJsonWithDefault(NSDictionary* json, NSString* key, int defaultValue)
{
    NSNumber* result = [json objectForKey:key];
    if (!result){
        result = [NSNumber numberWithInt:defaultValue];
    }
    return result;
}

-(void) writeToCampaignCache:(NSData*)campaignData
{
    [[self campaignFile] writeToFile:campaignData];
}

-(void) updateCampaigns:(NSDictionary*)campaignJson
{
    if (campaignJson == nil) {
        NSLog(@"Error parsing campaign JSON");
        return;
    }

    if ([campaignJson count] == 0) {
        NSLog(@"Campaign JSON empty, no campaigns downloaded");
        self.campaigns = [[NSArray alloc] init];
        return;
    }

    NSMutableSet* assetsQueue = [[NSMutableSet alloc] init];
    NSMutableArray* result    = [[NSMutableArray alloc] init];

    // Version check
    NSNumber* version = [campaignJson objectForKey:@"version"];
    if ([version integerValue] != CAMPAIGN_RESPONSE_VERSION){
        NSLog(@"Campaign JSON has the wrong version. No campaigns loaded.");
        return;
    }

    // CDN
    self.cdnRoot = [campaignJson objectForKey:@"cdn_root" ];
    NSLog(@"CDN URL %@", self.cdnRoot);

    // Game Data
    NSDictionary* gameData = [campaignJson objectForKey:@"game_data"];
    if (gameData){
        for (NSString* game  in gameData) {
            NSString* url = [[gameData objectForKey:game] objectForKey:@"app_store_url"];
            [self.appStoreURLs setValue:url forKey:game];
            NSLog(@"App Store link %@: %@", game, url);
        }
    }
    
    NSDictionary* rules = [campaignJson objectForKey:@"rules"];
    {
        NSNumber* delay    = numberFromJsonWithDefault(rules, @"delay_first_message", DEFAULT_DELAY_FIRST_MESSAGE);
        NSNumber* maxShows = numberFromJsonWithDefault(rules, @"max_messages_per_session", DEFAULT_MAX_SHOWS);
        NSNumber* minDelay = numberFromJsonWithDefault(rules, @"min_delay_between_messages", DEFAULT_MIN_DELAY);
  
        self.showMessagesAfterLaunch  = [self.initialisedTime dateByAddingTimeInterval:delay.doubleValue];
        self.minDelayBetweenMessage = minDelay.doubleValue;
        self.messagesLeftToShow = maxShows.longValue;
    
        NSLog(@"Game rules OK: Delay Seconds: %@ Max shows: %@ ", delay, maxShows);
        NSLog(@"Time is %@ show messages after %@", [NSDate date], self.showMessagesAfterLaunch);
    }
    
    // QA
    NSMutableDictionary* campaignsDownloaded = nil;
    
    NSDictionary* json_qa = [campaignJson objectForKey:@"qa"];
    if(json_qa) {
        NSLog(@"You are a QA user!");
        campaignsDownloaded = [[NSMutableDictionary alloc] init];
        self.qaUser = [[SwrveTalkQA alloc] initWithJSON:json_qa withAnalyticsSDK:self.analyticsSDK];
        
        NSArray* json_qa_campaigns = [json_qa objectForKey:@"campaigns"];
        if(json_qa_campaigns) {
            for (NSDictionary* json_qa_campaign in json_qa_campaigns) {
                NSNumber* campaign_id = [json_qa_campaign objectForKey:@"id"];
                NSString* campaign_reason = [json_qa_campaign objectForKey:@"reason"];
            
                NSLog(@"Campaign %@ not downloaded because: %@", campaign_id, campaign_reason);
                
                // Add campaign for QA purposes
                [campaignsDownloaded setValue:campaign_reason forKey:[campaign_id stringValue]];
            }
        }
        
        // Process any remote notifications
        for (NSDictionary* notification in self.notifications) {
            [self.qaUser pushNotification:notification];
        }
    } else {
        if ([self.analyticsSDK TEST_getTalkCampaignRequests]) {
            NSLog(@"Using Test QA user");
            NSDictionary* qaInit = [[NSDictionary alloc]initWithObjectsAndKeys:
                                    [NSNumber numberWithBool:NO], @"reset_device_state",
                                    [NSNumber numberWithBool:NO], @"logging", nil];
            self.qaUser = [[SwrveTalkQA alloc] initWithJSON:qaInit withAnalyticsSDK:self.analyticsSDK];
        }
    }
    
    // Empty saved push notifications
    [self.notifications removeAllObjects];
    
    NSDictionary* settings = [self getCampaignSettings];

    NSArray* json_campaigns = [campaignJson objectForKey:@"campaigns"];
    for (NSDictionary* dict in json_campaigns)
    {
        SwrveCampaign* campaign = [[SwrveCampaign alloc] initWithController:self atTime:self.initialisedTime];
        
        campaign.ID   = [[dict objectForKey:@"id"] integerValue];
        campaign.name = [dict objectForKey:@"name"];

        NSLog(@"Got campaign with id %ld", (long)campaign.ID);

        [campaign loadTriggersFrom:dict];
        [campaign loadRulesFrom:   dict];
        [campaign loadDatesFrom:   dict];

        NSMutableArray* messages = [[NSMutableArray alloc] init];
        NSArray* campaign_messages = [dict objectForKey:@"messages"];
        for (NSDictionary* messageDict in campaign_messages)
        {
            SwrveMessage* message = [SwrveMessage fromJSON:messageDict forCampaign:campaign forController:self];

            for (SwrveMessageFormat* format in message.formats)
            {
                // Add all images to the download queue
                for (SwrveButton* button in format.buttons)
                {
                    [assetsQueue addObject:button.image];
                }
                
                for (SwrveImage* image in format.images)
                {
                    [assetsQueue addObject:image.file];
                }
            }
            [messages addObject:message];
        }
        
        campaign.messages = [[NSArray alloc] initWithArray:messages];
        
        campaign.next = 0;
        if(!self.qaUser || !self.qaUser.resetDevice) {
            NSNumber* ID = [NSNumber numberWithInteger:campaign.ID];
            NSDictionary* campaignSettings = [settings objectForKey:ID];
            if(campaignSettings) {
                NSNumber* next = [campaignSettings objectForKey:@"next"];
                if (next)
                {
                    campaign.next = [next integerValue];
                }
                NSNumber* impressions = [campaignSettings objectForKey:@"impressions"];
                if (impressions)
                {
                    campaign.impressions = [impressions integerValue];
                }
            }
        }
        
        [result addObject:campaign];
        
        if(self.qaUser) {
            // Add campaign for QA purposes
            [campaignsDownloaded setValue:@"" forKey:[NSString stringWithFormat:@"%ld", (long)campaign.ID]];
        }
    }
    
    
    // QA logging
    if (self.qaUser != nil) {
        [self.qaUser talkSession:campaignsDownloaded];
    }
    
    
    for (NSString* asset in assetsQueue) {
        NSLog(@"Asset Set: %@", asset);
    }

    NSMutableArray* downloadQueue = [self withOutExistingFiles:assetsQueue];
    while([downloadQueue count] > 0)
    {
        [self downloadAsset: [downloadQueue lastObject]];
        [downloadQueue removeLastObject];
    }
    
    self.campaigns = [[NSArray alloc] initWithArray:result];
}

-(NSMutableArray*)withOutExistingFiles:(NSSet*)assetSet
{
    NSMutableArray* result = [[NSMutableArray alloc] initWithCapacity:[assetSet count]];
    
    for (NSString* file in assetSet)
    {
        NSString* target = [self.cacheFolder stringByAppendingPathComponent:file];
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:target])
        {
            NSLog(@"Adding %@ to download list" , file);
            [result addObject:file];
        }
        else
        {
            NSLog(@"File already exists on disk %@", file);
            [self.assetsOnDisk addObject:file];
        }
    }
    
    return result;
}

-(void)downloadAsset:(NSString*)asset
{
    NSURL* url = [NSURL URLWithString: asset relativeToURL: [NSURL URLWithString:self.cdnRoot]];

    NSLog(@"Downloading asset: %@", url);
    if ([self.analyticsSDK TEST_getTalkAssetsDownloading]) {
        [(NSMutableArray*)[self.analyticsSDK TEST_getTalkAssetsDownloading] addObject:asset];
    }

    [self.analyticsSDK sendHttpGETRequest:url
                        completionHandler:^(NSURLResponse* response, NSData* data, NSError* error)
     {
         if (error)
         {
             NSLog(@"Asset Error: %@", error);
         }
         else
         {
             if (![SwrveMessageController verifySHA:data against:asset]){
                 NSLog(@"Error downloading %@ – SHA1 does not match.", asset);
             } else {

                 NSURL* dst = [NSURL fileURLWithPathComponents:[NSArray arrayWithObjects:self.cacheFolder, asset, nil]];

                 // TODO: Do this write to disk asynchronously
                 [data writeToURL:dst atomically:YES];
                 // Add the asset to the set of assets that we know are downloaded.
                 [self.assetsOnDisk addObject:asset];
                 NSLog(@"Asset downloaded: %@", asset);
                 if ([self.analyticsSDK TEST_getTalkAssetsDownloading]) {
                     [(NSMutableArray*)[self.analyticsSDK TEST_getTalkAssetsDownloading] removeObject:asset];
                 }
             }
         }
     }];
}

-(void)autoShowMessages
{
    // Ensure this only gets executed once
    dispatch_once(&autoShowMessagePred, ^{
        for (SwrveCampaign* campaign in self.campaigns)
        {
            for(NSString* eventName in self.analyticsSDK.config.autoShowMessageAfterDownloadEventNames) {
                if([campaign hasMessageForEvent:eventName]) {
                
                    int64_t delayInSeconds = (NSInteger)([campaign.showMsgsAfterLaunch timeIntervalSinceDate:[NSDate date]]) + 1;
                    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                        NSDictionary* event = @{ @"type" : @"event", @"name" : eventName};
                        [self eventRaised:event];
                    });
                }
            }
        }
    });
}

-(BOOL)isTooSoonToShowMessageAfterLaunch:(NSDate*)now
{
    return now == [self.showMessagesAfterLaunch earlierDate:now];
}

-(BOOL)isTooSoonToShowMessageAfterDelay:(NSDate*)now
{
    return now == [self.showMessagesAfterDelay earlierDate:now];
}

-(BOOL)hasShowTooManyMessagesAlready
{
    return self.messagesLeftToShow <= 0;
}


-(SwrveMessage*)getMessageForEvent:(NSString *)event
{
    NSDate* now = [NSDate date];
    SwrveMessage* result = nil;
    SwrveCampaign* campaign = nil;
    
    if (self.campaigns != nil) {
        if ([self.campaigns count] == 0)
        {
            [self noMessagesWereShown:event withReason:@"No campaigns available"];
            return nil;
        }
        
        if ([self isTooSoonToShowMessageAfterLaunch:now])
        {
            [self noMessagesWereShown:event withReason:[NSString stringWithFormat:@"{Game throttle limit} Too soon after launch. Wait until %@", [[self class] getTimeFormatted:self.showMessagesAfterLaunch]]];
            return nil;
        }
        
        if ([self isTooSoonToShowMessageAfterDelay:now])
        {
            [self noMessagesWereShown:event withReason:[NSString stringWithFormat:@"{Game throttle limit} Too soon after last message. Wait until %@", [[self class] getTimeFormatted:self.showMessagesAfterDelay]]];
            return nil;
        }
        
        if ([self hasShowTooManyMessagesAlready])
        {
            [self noMessagesWereShown:event withReason:@"{Game throttle limit} Too many messages shown"];
            return nil;
        }
        
        NSMutableDictionary* campaignReasons = nil;
        NSMutableDictionary* campaignMessages = nil;
        if (self.qaUser != nil) {
            campaignReasons = [[NSMutableDictionary alloc] init];
            campaignMessages = [[NSMutableDictionary alloc] init];
        }

        NSMutableArray* availableMessages = [[NSMutableArray alloc] init];
        // Select messages with higher priority that have the current orientation
        NSNumber* minPriority = [NSNumber numberWithInteger:INT_MAX];
        NSMutableArray* candidateMessages = [[NSMutableArray alloc] init];
        // Get current orientation
        UIInterfaceOrientation currentOrientation = [[UIApplication sharedApplication] statusBarOrientation];
        for (SwrveCampaign* campaignIt in self.campaigns)
        {
            SwrveMessage* nextMessage = [campaignIt getMessageForEvent:event withAssets:self.assetsOnDisk atTime:now withReasons:campaignReasons];
            if (nextMessage != nil) {
                if ([nextMessage supportsOrientation:currentOrientation]) {
                    // Add to list of returned messages
                    [availableMessages addObject:nextMessage];
                    // Check if it is a candidate to be shown
                    long nextMessagePriorityLong = [nextMessage.priority longValue];
                    long minPriorityLong = [minPriority longValue];
                    if (nextMessagePriorityLong <= minPriorityLong) {
                        minPriority = nextMessage.priority;
                        if (nextMessagePriorityLong < minPriorityLong) {
                            [candidateMessages removeAllObjects];
                        }
                        [candidateMessages addObject:nextMessage];
                    }
                } else {
                    if (self.qaUser != nil) {
                        NSString* campaignIdString = [[NSNumber numberWithInteger:campaignIt.ID] stringValue];
                        [campaignMessages setValue:nextMessage.messageID forKey:campaignIdString];
                        [campaignReasons setValue:@"Message didn't support the given orientation" forKey:campaignIdString];
                    }
                }
            }
        }
        
        NSArray* shuffledCandidates = [SwrveMessageController shuffled:candidateMessages];
        if ([shuffledCandidates count] > 0) {
            result = [shuffledCandidates objectAtIndex:0];
            campaign = result.campaign;
        }
        
        if (self.qaUser != nil && campaign != nil && result != nil) {
            // A message was chosen, set the reason for the others
            for (SwrveMessage* otherMessage in availableMessages)
            {
                if (result != otherMessage)
                {
                    NSString* campaignIdString = [[NSNumber numberWithInteger:otherMessage.campaign.ID] stringValue];
                    [campaignMessages setValue:otherMessage.messageID forKey:campaignIdString];
                    [campaignReasons setValue:[NSString stringWithFormat:@"Campaign %ld was selected for display ahead of this campaign", (long)campaign.ID] forKey:campaignIdString];
                }
            }
        }
        
        // If QA enabled, send message selection information
        if(self.qaUser != nil) {
            [self.qaUser trigger:event withMessage:result withReason:campaignReasons withMessages:campaignMessages];
        }
    }

    if (result == nil) {
        NSLog(@"Not showing message: no candidate messages for %@", event);
    }
    return result;
}

-(void)noMessagesWereShown:(NSString*)event withReason:(NSString*)reason
{
    NSLog(@"Not showing message for %@: %@", event, reason);
    if (self.qaUser != nil) {
        [self.qaUser triggerFailure:event withReason:reason];
    }
}

+(NSString*)getTimeFormatted:(NSDate*)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *enUSPOSIXLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    [dateFormatter setLocale:enUSPOSIXLocale];
    [dateFormatter setDateFormat:@"HH:mm:ss Z"];
    
    return [dateFormatter stringFromDate:date];
}

-(void)setDownloadingEnabled:(BOOL)enabled
{
    [self.queue setSuspended:!enabled];
    
}


+(NSArray*)shuffled:(NSArray*)source;
{
    unsigned long count = [source count];
    
    // Early out if there is 0 or 1 elements.
    if (count < 2)
    {
        return source;
    }
    
    // Copy
    NSMutableArray* result = [NSMutableArray arrayWithArray:source];
    
    for (int i = 0; i < count; i++)
    {
        unsigned long remain = count - i;
        int n = (arc4random() % remain) + i;
        [result exchangeObjectAtIndex:i withObjectAtIndex:n];
    }
    
    return result;
}



+(bool)verifySHA:(NSData*)data against:(NSString*)expectedDigest
{
    const static char hex[] = {'0', '1', '2', '3',
                               '4', '5', '6', '7',
                               '8', '9', 'a', 'b',
                               'c', 'd', 'e', 'f'};

    unsigned char digest[CC_SHA1_DIGEST_LENGTH];

    // SHA-1 hash has been calculated and stored in 'digest'
    unsigned int length = (unsigned int)[data length];
    if (CC_SHA1([data bytes], length, digest)) {
        for (int i=0; i < [expectedDigest length]; i++) {
            unichar c = [expectedDigest characterAtIndex:i];
            unsigned char e = digest[i>>1];

            if (i&1) {
                e = e & 0xF;
            } else {
                e = e >> 4;
            }

            e = hex[e];

            if (c != e) {
                NSLog(@"SHA[%d] Expected: %d Computed %d", i, e, c);
                return false;
            }
        }
    }

    NSLog(@"SHA Check OK %@", expectedDigest);
    
    return true;
}

-(void)messageWasShownToUser:(SwrveMessage*)message
{
    // The message was shown. Take the current time so that we can throttle messages
    // from being shown too quickly.
    self.showMessagesAfterDelay = [[NSDate date] dateByAddingTimeInterval:self.minDelayBetweenMessage];
    self.messagesLeftToShow = self.messagesLeftToShow - 1;

    [message.campaign messageWasShownToUser:message];
    [self saveSettings];

    NSString* viewEvent = [NSString stringWithFormat:@"Swrve.Messages.Message-%d.impression", [message.messageID intValue]];
    NSLog(@"Sending view event: %@", viewEvent);
    
    [self.analyticsSDK eventWithNoCallback:viewEvent payload:nil];
}

-(void)buttonWasPressedByUser:(SwrveButton*)button
{
    if (button.actionType != kSwrveActionDismiss) {

        NSString* clickEvent = [NSString stringWithFormat:@"Swrve.Messages.Message-%ld.click", button.messageID];
        NSLog(@"Sending click event: %@", clickEvent);
        [self.analyticsSDK eventWithNoCallback:clickEvent payload:nil];
    }

    if (button.actionType == kSwrveActionInstall) {
        NSLog(@"Sending click_thru link event");
        NSString* clickSource = [NSString stringWithFormat:@"Swrve.Message-%ld", button.messageID];
        [self.analyticsSDK clickThruForTargetGame:button.appID source:clickSource];
    }
}

-(NSString*)getAppStoreURLForGame:(long)game
{
    return [self.appStoreURLs objectForKey:[NSString stringWithFormat:@"%ld", game]];
}

-(NSString*) getEventName:(NSDictionary*)eventParameters
{
    NSString* eventName = @"";
    
    NSString* eventType = [eventParameters objectForKey:@"type"];
    if( [eventType isEqualToString:@"session_start"])
    {
        eventName = @"Swrve.session.start";
    }
    else if( [eventType isEqualToString:@"session_end"])
    {
        eventName = @"Swrve.session.end";
    }
    else if( [eventType isEqualToString:@"buy_in"])
    {
        eventName = @"Swrve.buy_in";
    }
    else if( [eventType isEqualToString:@"iap"])
    {
        eventName = @"Swrve.iap";
    }
    else if( [eventType isEqualToString:@"event"])
    {
        eventName = [eventParameters objectForKey:@"name"];
    }
    else if( [eventType isEqualToString:@"purchase"])
    {
        eventName = @"Swrve.user_purchase";
    }
    else if( [eventType isEqualToString:@"currency_given"])
    {
        eventName = @"Swrve.currency_given";
    }
    else if( [eventType isEqualToString:@"user"])
    {
        eventName = @"Swrve.user_properties_changed	";
    }

    return eventName;
}

- (SwrveMessage*)findMessageForEvent:(NSString*) eventName withParameters:(NSDictionary *)parameters;
{
    // By default does a simple by name look up.
    return [self getMessageForEvent:eventName];
}

- (UIViewController *)topViewController{
    return [self topViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
}

- (UIViewController *)topViewController:(UIViewController *)rootViewController
{
    if (rootViewController.presentedViewController == nil) {
        return rootViewController;
    }
    
    if ([rootViewController.presentedViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navigationController = (UINavigationController *)rootViewController.presentedViewController;
        UIViewController *lastViewController = navigationController.visibleViewController;
        if (!lastViewController) {
            lastViewController = [[navigationController viewControllers] lastObject];
        }
        return [self topViewController:lastViewController];
    }
    
    UIViewController *presentedViewController = (UIViewController *)rootViewController.presentedViewController;
    return [self topViewController:presentedViewController];
}

-(void) showMessage:(SwrveMessage *)message
{
    if ( message )
    {
        UIViewController* activeViewController = [self topViewController];
        
        if( activeViewController )
        {
            UIViewController* view = [message createViewControllerThatCalls:^(SwrveActionType type, NSString* action, NSInteger appId)
            {
                if ([activeViewController respondsToSelector:@selector(dismissViewControllerAnimated:completion:)]){
                    [activeViewController dismissViewControllerAnimated:YES completion:nil];
                } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
                    [activeViewController dismissModalViewControllerAnimated:YES];
#pragma clang diagnostic pop
                }
                
                switch(type)
                {
                    case kSwrveActionDismiss:
                        break;
                    case kSwrveActionInstall:
                    {
                        // Call custom button listener
                        BOOL standardEvent = true;
                        if (self.installButtonCallback != nil) {
                            standardEvent = self.installButtonCallback(action);
                        }
                        
                        if (standardEvent) {
                            NSURL* url =  nil;
                            if(action != nil) {
                                url = [NSURL URLWithString: action];
                            }
                            
                            if( url != nil ) {
                                [[UIApplication sharedApplication] openURL:url];
                            } else {
                                NSLog(@"Install action - %@ - could not be handled.", action);
                            }
                        }
                    }
                    break;
                    case kSwrveActionCustom:
                    {
                        if (self.customButtonCallback != nil) {
                            self.customButtonCallback(action);
                        } else {
                            NSURL* url =  nil;
                            if(action != nil) {
                                url = [NSURL URLWithString: action];
                            }

                            if( url != nil ) {
                                NSLog(@"Custom action - %@ - handled.  Sending to applition as URL", action);
                                [[UIApplication sharedApplication] openURL:url];
                            } else {
                                NSLog(@"Custom action - %@ -  not handled.  Override this delegate to customize message actions", action);
                            }
                        }
                    }
                    break;
                }
            }];
        
            if (view)
            {
                view.view.backgroundColor = self.backgroundColor;
                activeViewController.modalPresentationStyle = UIModalPresentationCurrentContext;

                if ([activeViewController respondsToSelector:@selector(presentViewController:animated:completion:)]){
                    [activeViewController presentViewController:view animated:YES completion:nil];
                } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
                    [activeViewController presentModalViewController:view animated:YES];
#pragma clang diagnostic pop
                }

            }
        }
    }
}

-(void) eventRaised:(NSDictionary*)event;
{    
    // Get event name
    NSString* eventName = [self getEventName:event];
    
    if (self.pushEnabled) {
        if ([eventName isEqualToString:@"Swrve.push_notification_permission"] || (self.pushNotificationEvents != nil && [self.pushNotificationEvents containsObject:eventName])) {
                // Ask for push notification permission
                [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound];
        }
    }
    
    // Find a message that should be fired
    SwrveMessage* message = nil;
    if( [self.showMessageDelegate respondsToSelector:@selector(findMessageForEvent: withParameters:)])
    {
        message = [self.showMessageDelegate findMessageForEvent:eventName withParameters:event];
    }
    else
    {
        message = [self findMessageForEvent:eventName withParameters:event];
    }
        
    // Show the message if it exists
    if( message != nil )
    {
        if( [self.showMessageDelegate respondsToSelector:@selector(showMessage:)])
        {
            [self.showMessageDelegate showMessage:message];
        }
        else
        {
            [self showMessage:message];
        }
    }
}

- (void) setDeviceToken:(NSData*)deviceToken
{
   if (self.pushEnabled && deviceToken) {
       [self.analyticsSDK setPushNotificationsDeviceToken:deviceToken];

        if (self.qaUser) {
            // If we are a QA user then send a device info update
            [self.qaUser updateDeviceInfo];
        }
    }
}

- (void) pushNotificationReceived:(NSDictionary*)userInfo
{
    if (self.pushEnabled) {
        [self.analyticsSDK pushNotificationReceived:userInfo];
        if (self.qaUser) {
           [self.qaUser pushNotification:userInfo];
        } else {
            NSLog(@"Queuing push notification for later");
            [self.notifications addObject:userInfo];
        }
    }
}

- (BOOL) isQaUser
{
    return self.qaUser != nil;
}

- (NSString*) getCampaignQueryString
{
    const NSString* orientationName = orientation_name[self.orientation];

    UIDevice* device   = [UIDevice currentDevice];
    NSString* encodedDeviceName = [[device model] stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
    NSString* encodedSystemName = [[device systemName] stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];

    return [NSString stringWithFormat:@"version=%d&link_token=%@&orientation=%@&language=%@&app_store=%@&device_width=%d&device_height=%d&os_version=%@&device_name=%@",
            CAMPAIGN_VERSION, self.token, orientationName, self.language, @"apple", self.device_width, self.device_height, encodedDeviceName, encodedSystemName];
}

@end
