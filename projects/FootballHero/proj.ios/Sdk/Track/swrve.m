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

#if !__has_feature(objc_arc)
    #error Please enable ARC for this project (Project Settings > Build Settings), or add the -fobjc-arc compiler flag to each of the files in the Swrve SDK (Project Settings > Build Phases > Compile Sources)
#endif

#include "swrve.h"
#include <sys/time.h>
#include <sys/stat.h>
#include <sys/socket.h>
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>
#include <CoreFoundation/CFArray.h>
#include <CoreFoundation/CFString.h>
#include <CoreFoundation/CFURL.h>
#include <CoreFoundation/CFStream.h>
#include <CFNetwork/CFNetwork.h>
#include <CommonCrypto/CommonDigest.h>
#include <CommonCrypto/CommonHMAC.h>
#include <UIKit/UIScreen.h>
#include <UIKit/UIKit.h>
#include <objc/runtime.h>
#import <StoreKit/StoreKit.h>
#import "SwrveTransactionListener.h"
#import "SwrveCampaign.h"

#if SWRVE_TEST_BUILD
#define SWRVE_STATIC_UNLESS_TEST_BUILD
#else
#define SWRVE_STATIC_UNLESS_TEST_BUILD static
#endif

#define NullableNSString(x) ((x == nil)? [NSNull null] : x)
#define KB(x) (1024*(x))
#define MB(x) (1024*KB((x)))

enum
{
    // The API version of this file.
    // This is send to the server on each call, and should not be modified.
    SWRVE_VERSION = 2,

    // Initial size of the in-memory queue
    // Tweak this to avoid fragmenting memory when the queue is growing.
    SWRVE_MEMORY_QUEUE_INITIAL_SIZE = 16,

    // This is the largest number of bytes that the in-memory queue will use
    // If more than this numer of bytes are used, the entire queue will be written
    // to disk, and the queue will be emptied.
    SWRVE_MEMORY_QUEUE_MAX_BYTES = KB(100),

    // This is the largest size that the disk-cache persist between runs of the
    // application. The file may grow larger than this size over a very long run
    // of the app, but then next time the app is run, the file will be truncated.
    // To avoid losing data, you should allow enough disk space here for your apps
    // messages.
    SWRVE_DISK_MAX_BYTES = MB(4),

    // This is the max timeout on a HTTP send before Swrve will kill the connection
    // This is used for sending data to Swrve. For data where the client is reading
    // from Swrve, the timeout is mush smaller, and is specified in swrve_config
    // This value of 4000 seconds is the maximum latency seen to api.swrve.com
    // over a 7 day period in July 2013
    SWRVE_SEND_TIMEOUT_SECONDS = 4000,

    // Flush frequency for automatic campaign/user resources updates
    SWRVE_DEFAULT_CAMPAIGN_RESOURCES_FLUSH_FREQUENCY = 60000,

    // Delay between flushing events and refreshing campaign/user resources
    SWRVE_DEFAULT_CAMPAIGN_RESOURCES_FLUSH_REFRESH_DELAY = 5000
};

const static char* swrve_trailing_comma = ",\n";
static NSString* swrve_link_token_key = @"swrve_link_token";
static NSString* swrve_user_id_key = @"swrve_user_id";
static NSString* swrve_device_token_key = @"swrve_device_token";

typedef void (^ConnectionCompletionHandler)(NSURLResponse* response, NSData* data, NSError* error);

typedef void (*didRegisterForRemoteNotificationsWithDeviceTokenImplSignature)(__strong id,SEL,UIApplication *, NSData*);
typedef void (*didFailToRegisterForRemoteNotificationsWithErrorImplSignature)(__strong id,SEL,UIApplication *, NSError*);

@interface SwrveSendContext : NSObject
@property (weak) Swrve* swrveReference;
@property long swrveInstanceID;
@property NSArray* buffer;
@property int bufferLength;
@end

@implementation SwrveSendContext
@end

@interface SwrveSendLogfileContext : NSObject
@property (weak) Swrve* swrveReference;
@property long swrveInstanceID;
@end

@implementation SwrveSendLogfileContext
@end

enum
{
    SWRVE_TRUNCATE_FILE,
    SWRVE_APPEND_TO_FILE,
    SWRVE_TRUNCATE_IF_TOO_LARGE,
};

@interface SwrveConnectionDelegate : NSObject <NSURLConnectionDataDelegate>

@property (weak) Swrve* swrve;
@property NSDate* startTime;
@property NSMutableDictionary* metrics;
@property NSMutableData* data;
@property NSURLResponse* response;
@property (strong) ConnectionCompletionHandler handler;

- (id)init:(Swrve*)swrve completionHandler:(ConnectionCompletionHandler)handler;

@end

@interface SwrveInstanceIDRecorder : NSObject
{
    NSMutableSet * swrveInstanceIDs;
    long nextInstanceID;
}

+(SwrveInstanceIDRecorder*) sharedInstance;

-(BOOL)hasSwrveInstanceID:(long)instanceID;
-(long)addSwrveInstanceID;
-(void)removeSwrveInstanceID:(long)instanceID;

@end

@interface SwrveResourceManager()

- (void)setResourcesFromArray:(NSArray*)json;
- (NSDictionary*) getResources;

@end

@interface SwrveMessageController()

-(void) updateCampaigns:(NSDictionary*)campaignJson;
-(NSString*) getCampaignQueryString;
-(void) autoShowMessages;
-(void) writeToCampaignCache:(NSData*)campaignData;
@end

@interface Swrve()
{
    UInt64 install_time;
    NSURL* batch_url;
    NSURL* linking_app_launch;
    NSURL* linking_click_thru;
    NSURL* campaignsAndResourcesURL;

    SwrveSignatureProtectedFile* resourcesFile;
    
    SwrveSignatureProtectedFile* resourcesDiffFile;
    NSData* resourcesDiffContent; // in-memory content
    
    // An in-memory buffer of messages that are ready to be sent to the Swrve
    // server the next time sendQueuedEvents is called.
    NSMutableArray* eventBuffer;
    
    bool eventFileHasData;
    NSOutputStream* eventStream;
    NSURL* eventFilename;

    // Count the number of UTF-16 code points stored in buffer
    int eventBufferBytes;

    // keep track of whether any events were sent so we know whether to check for resources / campaign updates
    bool eventsWereSent;
    
    SwrveEventQueuedCallback event_queued_callback;
    
    // Used to retain user-blocks that are passed to C functions
    NSMutableDictionary *   blockStore;
    int                     blockStoreId;
    
    // The unique id associated with this instance of Swrve
    long    instanceID;
    
    didRegisterForRemoteNotificationsWithDeviceTokenImplSignature didRegisterForRemoteNotificationsWithDeviceTokenImpl;
    didFailToRegisterForRemoteNotificationsWithErrorImplSignature didFailToRegisterForRemoteNotificationsWithErrorImpl;
    
    // The following items are used for testing purposes
    NSMutableArray * _TEST_eventRequests;
    NSMutableArray * _TEST_eventResponses;
    NSMutableArray * _TEST_userResourceRequests;
    NSMutableArray * _TEST_userResourceResponses;
    NSMutableArray * _TEST_clickThruRequests;
    NSMutableArray * _TEST_appLaunchRequests;
    NSMutableArray * _TEST_talkCampaignRequests;
    NSMutableArray * _TEST_talkCampaignResponses;
    NSMutableArray * _TEST_talkQARequests;
    NSMutableArray * _TEST_talkQAResponses;
    NSMutableArray * _TEST_talkQALog;
    NSMutableArray * _TEST_talkAssetsDownloading;
}

-(int) eventInternal:(NSString*)eventName payload:(NSDictionary*)eventPayload triggerCallback:(bool)triggerCallback;
-(void) setupConfig:(SwrveConfig*)config;
+(NSString*) getAppVersion;
-(void) maybeFlushToDisk;
-(void) queueEvent:(NSString*)eventType data:(NSMutableDictionary*)eventData triggerCallback:(bool)triggerCallback;
-(void) removeBlockStoreItem:(int)blockId;
-(void) updateDeviceInfo;
-(void) registerForNotifications;
-(void) appDidBecomeActive:(NSNotification*)notification;
-(void) appWillResignActive:(NSNotification*)notification;
-(void) appWillTerminate:(NSNotification*)notification;
-(void) queueUserUpdates;
-(void) pushNotificationReceived:(NSDictionary*)userInfo;
- (NSString*) createSessionToken;
- (NSString*) createJSON:(NSString*)sessionToken events:(NSString*)rawEvents;
- (NSString*) copyBufferToJson:(NSArray*)buffer;
- (void) sendCrashlyticsMetadata;
- (BOOL) isValidJson:(NSData*) json;
- (void) initResources;
- (void) initLinking:(NSString*)server;
- (UInt64) getInstallTime:(NSString*)fileName;
- (void) sendLogfile;
- (NSOutputStream*) createLogfile:(int)mode;
- (UInt64) getTime;
- (NSString*) createStringWithMD5:(NSString*)source;
- (void) initBuffer;
- (void) addHttpPerformanceMetrics:(NSString*) metrics;
- (void) checkForCampaignAndResourcesUpdates:(NSTimer*)timer;

// Used to store the merged user updates
@property (strong) NSMutableDictionary * userUpdates;

// Set to YES after the first sessionEnd so that multiple session starts are not generated if the app resume event occurs after swrve has been initialized
@property BOOL okToStartSessionOnResume;

// Push notification device token
@property NSString* deviceToken;

// Device id, used for tracking event streams from different devices
@property NSString* deviceUUID;

// HTTP Request metrics that haven't been sent yet
@property NSMutableArray* httpPerformanceMetrics;

// Keep an object to listen to IAPs
@property id<SKPaymentTransactionObserver> transactionObserver;

// Flush values, ETag and timer for campaigns and resources update request
@property NSString* campaignsAndResourcesETAG;
@property double campaignsAndResourcesFlushFrequency;
@property double campaignsAndResourcesFlushRefreshDelay;
@property NSTimer*  campaignsAndResourcesTimer;
@property NSDate* campaignsAndResourcesLastRefreshed;

// Methods used for testing
-(void) TEST_activateTestBuffers;
-(void) TEST_resetTestBuffers;
-(NSMutableArray*) TEST_getEventsBuffer;
-(void) TEST_clearEventCacheFile;
-(NSString*) TEST_createSessionToken;
-(NSArray*) TEST_getEventRequests;
-(NSArray*) TEST_getClickThruRequests;
-(NSArray*) TEST_getAppLaunchRequests;
-(NSArray*) TEST_getTalkCampaignRequests;
-(NSArray *) TEST_getTalkCampaignResponses;
-(NSArray *) TEST_getTalkQARequests;
-(NSArray *) TEST_getTalkQAResponses;
- (NSArray *)TEST_getTalkQALog;
-(NSArray *) TEST_getTalkAssetsDownloading;
- (void)TEST_writeToResourcesFile:(NSData*)data;
- (void)TEST_writeToResourcesDiffFile:(NSData*)data;

@property BOOL TEST_campaignsDownloading;
@property BOOL TEST_eventsSending;

@end

BOOL SwrveSystemVersionGreaterThan(NSString* desired) {
    NSString* currentVersion = [[UIDevice currentDevice] systemVersion];
    return [currentVersion compare:desired options:NSNumericSearch] != NSOrderedAscending;
}

// Manages unique ids for each instance of Swrve
// This allows low-level c callbacks to know if it is safe to execute their callback functions.
// It is not safe to execute a callback function after a Swrve instance has been deallocated or shutdown.
@implementation SwrveInstanceIDRecorder

+(SwrveInstanceIDRecorder*) sharedInstance
{
    static dispatch_once_t pred;
    static SwrveInstanceIDRecorder *shared = nil;
    dispatch_once(&pred, ^{
        shared = [SwrveInstanceIDRecorder alloc];
    });
    return shared;
}

-(id)init
{
    if (self = [super init]) {
        nextInstanceID = 1;
    }
    return self;
}

-(BOOL)hasSwrveInstanceID:(long)instanceID
{
    @synchronized(self) {
        if (!swrveInstanceIDs) {
            return NO;
        }
        return [swrveInstanceIDs containsObject:[NSNumber numberWithLong:instanceID]];
    }
}

-(long)addSwrveInstanceID
{
    @synchronized(self) {
        if (!swrveInstanceIDs) {
            swrveInstanceIDs = [[NSMutableSet alloc]init];
        }
        long result = nextInstanceID++;
        [swrveInstanceIDs addObject:[NSNumber numberWithLong:result]];
        return result;
    }
}

-(void)removeSwrveInstanceID:(long)instanceID
{
    @synchronized(self) {
        if (swrveInstanceIDs) {
            [swrveInstanceIDs removeObject:[NSNumber numberWithLong:instanceID]];
        }
    }
}

@end


@implementation SwrveConfig


-(id) init
{
    if ( self = [super init] ) {
        _httpTimeoutSeconds = 15;
        _autoDownloadCampaignsAndResources = YES;
        _maxConcurrentDownloads = 2;
        _orientation = SWRVE_ORIENTATION_BOTH;
        _appVersion = [Swrve getAppVersion];
        _language = [[NSLocale preferredLanguages] objectAtIndex:0];
        
        NSString* caches = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        _eventCacheFile = [caches stringByAppendingPathComponent: @"swrve_events.txt"];
        
        _userResourcesCacheFile = [caches stringByAppendingPathComponent: @"srcngt.txt"];
        _userResourcesCacheSignatureFile = [caches stringByAppendingPathComponent: @"srcngtsgt.txt"];

        _userResourcesDiffCacheFile = [caches stringByAppendingPathComponent: @"rsdfngt.txt"];
        _userResourcesDiffCacheSignatureFile = [caches stringByAppendingPathComponent:@"rsdfngtsgt.txt"];

        self.installTimeCacheFile = [caches stringByAppendingPathComponent: @"swrve_install.txt"];
        self.autoSendEventsOnResume = YES;
        self.autoSaveEventsOnResign = YES;
        self.talkEnabled = YES;
        self.autoShowMessageAfterDownloadEventNames = [NSSet setWithObject:@"Swrve.Messages.campaigns_downloaded"];
        self.linkToken = [self createLinkToken];
        self.pushEnabled = NO;
        self.pushNotificationEvents = [NSSet setWithObject:@"Swrve.session.start"];
        self.autoCollectDeviceToken = YES;
        self.reportInAppPurchases = YES;
        self.testBuffersActivated = NO;
        self.receiptProvider = [[SwrveReceiptProvider alloc] init];
        self.resourcesUpdatedCallback = ^() {
            // Do nothing by default.
        };
        self.transactionCompleteCallback = ^(SKPaymentTransaction* transaction, SKProduct* product, SwrveIAPRewards* rewards) {
            // Do nothing by default.
        };
    }
    return self;
}

NSString* getIDFV() {
    if ([[UIDevice currentDevice] respondsToSelector:@selector(identifierForVendor)]) {
        return [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    }
    
    return nil;
}

-(NSString*)createLinkToken
{
    NSString* result = getIDFV();
    if (result) {
        return result;
    }

    result = [[NSUserDefaults standardUserDefaults] stringForKey:swrve_link_token_key];
    if (result) {
        return result;
    }

    return [[[NSUUID alloc] init] UUIDString];
}

@end


@interface SwrveIAPRewards()
@property (nonatomic, retain) NSMutableDictionary* rewards;
@end

@implementation SwrveIAPRewards


- (id) init
{
    self = [super init];
    self.rewards = [[NSMutableDictionary alloc] init];
    return self;
}

- (void) addItem:(NSString*) resourceName withQuantity:(long) quantity
{
    [self addObject:resourceName withQuantity: quantity ofType: @"item"];
}

- (void) addCurrency:(NSString*) currencyName withAmount:(long) amount
{
    [self addObject:currencyName withQuantity:amount ofType:@"currency"];
}

- (void) addObject:(NSString*) name withQuantity:(long) quantity ofType:(NSString*) type
{
    if (![self checkArguments:name andQuantity:quantity andType:type]) {
        NSLog(@"ERROR: SwrveIAPRewards has not been added because it received an illegal argument");
        return;
    }
    
    NSDictionary* item = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithLong:quantity], @"amount", type, @"type", nil];
    [[self rewards] setValue:item forKey:name];
}

- (bool) checkArguments:(NSString*) name andQuantity:(long) quantity andType:(NSString*) type
{
    if (name == nil || [name length] <= 0) {
        NSLog(@"SwrveIAPRewards illegal argument: reward name cannot be empty");
        return false;
    }
    if (quantity <= 0) {
        NSLog(@"SwrveIAPRewards illegal argument: reward amount must be greater than zero");
        return false;
    }
    if (type == nil || [type length] <= 0) {
        NSLog(@"SwrveIAPRewards illegal argument: type cannot be empty");
        return false;
    }
    
    return true;
}

- (NSDictionary*) rewards {
    return _rewards;
}

@end


@implementation Swrve

static Swrve * _swrveSharedInstance = nil;
static dispatch_once_t sharedInstanceToken = 0;
static bool didSwizzle = false;

// Replaces the selector on oldObject with the same selector on newObject.
// Returns the implementation of the selector that was replaced, or NULL if
// no replacement was done.
IMP _swizzelMethod(NSObject* oldObject, SEL selector, NSObject* newObject)
{
    Method originalMethod = class_getInstanceMethod([oldObject class], selector);
    Method newMethod = class_getInstanceMethod([newObject class], selector);
    
    if(class_addMethod([oldObject class], selector, method_getImplementation(newMethod), method_getTypeEncoding(newMethod))) {
        return NULL;
    } else {
        IMP oldImplementation = method_getImplementation(originalMethod);
        IMP newImplementation = [newObject methodForSelector:selector];
        method_setImplementation(originalMethod, newImplementation);
        return oldImplementation;
    }
}

+(Swrve*) sharedInstance
{
    if (!_swrveSharedInstance) {
        NSLog(@"Warning: [Swrve sharedInstance] called before sharedInstanceWithAppID:... method.");
    }
    return _swrveSharedInstance;
}

+(Swrve*) sharedInstanceWithAppID:(int)swrveAppID apiKey:(NSString*)swrveAPIKey
{
    dispatch_once(&sharedInstanceToken, ^{
        _swrveSharedInstance = [Swrve alloc];
        _swrveSharedInstance = [_swrveSharedInstance initWithAppID:swrveAppID apiKey:swrveAPIKey];
    });
    return _swrveSharedInstance;
}

+(Swrve*) sharedInstanceWithAppID:(int)swrveAppID apiKey:(NSString*)swrveAPIKey userID:(NSString*)swrveUserID
{
    dispatch_once(&sharedInstanceToken, ^{
        _swrveSharedInstance = [Swrve alloc];
        _swrveSharedInstance = [_swrveSharedInstance initWithAppID:swrveAppID apiKey:swrveAPIKey userID:swrveUserID];
    });
    return _swrveSharedInstance;
}

+(Swrve*) sharedInstanceWithAppID:(int)swrveAppID apiKey:(NSString*)swrveAPIKey userID:(NSString*)swrveUserID config:(SwrveConfig*)swrveConfig
{
    dispatch_once(&sharedInstanceToken, ^{
        _swrveSharedInstance = [Swrve alloc];
        _swrveSharedInstance = [_swrveSharedInstance initWithAppID:swrveAppID apiKey:swrveAPIKey userID:swrveUserID config:swrveConfig];
    });
    return _swrveSharedInstance;
}

-(id) initWithAppID:(int)swrveAppID apiKey:(NSString*)swrveAPIKey
{
    return [self initWithAppID:swrveAppID apiKey:swrveAPIKey userID:nil];
}
-(id) initWithAppID:(int)swrveAppID apiKey:(NSString*)swrveAPIKey userID:(NSString*)swrveUserID
{
    // Create a custom config object
    SwrveConfig * newConfig = [[SwrveConfig alloc]init];
    return [self initWithAppID:swrveAppID apiKey:swrveAPIKey userID:swrveUserID config:newConfig];
}

-(id) initWithAppID:(int)swrveAppID apiKey:(NSString*)swrveAPIKey userID:(NSString*)swrveUserID config:(SwrveConfig*)swrveConfig
{
    NSCAssert(self.config == nil, @"Do not initialize Swrve instance more than once!");
    if (self.config) {
        NSLog(@"Swrve may not be initialized more than once.");
        return self;
    }
    
    if ( self = [super init] ) {
        // Auto generate user id if necessary
        if (!swrveUserID) {
            swrveUserID = [[NSUserDefaults standardUserDefaults] stringForKey:swrve_user_id_key];
            if(!swrveUserID) {
                swrveUserID = getIDFV();
            }
            if(!swrveUserID) {
                swrveUserID = [[NSUUID UUID] UUIDString];
            }
        }
        
        instanceID = [[SwrveInstanceIDRecorder sharedInstance]addSwrveInstanceID];
        [self sendCrashlyticsMetadata];
        
        NSCAssert(swrveConfig, @"Null config object given to Swrve");

        _appID = swrveAppID;
        _apiKey = swrveAPIKey;
        _userID = swrveUserID;
        
        NSCAssert(_appID > 0, @"Invalid app ID given (%ld)", _appID);
        NSCAssert(_apiKey.length > 1, @"API Key is invalid (too short): %@", _apiKey);
        NSCAssert(_userID != nil, @"@UserID must not be nil.");

        BOOL didSetUserId = [[NSUserDefaults standardUserDefaults] stringForKey:swrve_user_id_key] == nil;
        [[NSUserDefaults standardUserDefaults] setValue:_userID forKey:swrve_user_id_key];
        
        [self setupConfig:swrveConfig];
        
        [self setHttpPerformanceMetrics:[[NSMutableArray alloc] init]];
        
        if (swrveConfig.testBuffersActivated) {
            [self TEST_activateTestBuffers];
        }
        self.TEST_campaignsDownloading = NO;
        self.TEST_eventsSending = NO;
        
        event_queued_callback = nil;

        blockStore = [[NSMutableDictionary alloc] init];
        blockStoreId = 0;
        
        _config = swrveConfig;
        [self initBuffer];
        _deviceInfo = [NSMutableDictionary dictionary];
        
        install_time = [self getInstallTime:swrveConfig.installTimeCacheFile];
        
        NSURL* base_events_url = [NSURL URLWithString:swrveConfig.eventsServer];
        batch_url = [NSURL URLWithString:@"1/batch" relativeToURL:base_events_url];
        
        NSURL* base_content_url = [NSURL URLWithString:self.config.contentServer];
        campaignsAndResourcesURL = [NSURL URLWithString:@"api/1/user_resources_and_campaigns" relativeToURL:base_content_url];
        
        // Initialize resource cache file and resource manager
        [self initResources];
        
        [self initResourcesDiff];
        
        eventFilename = [NSURL fileURLWithPath:swrveConfig.eventCacheFile];
        eventStream = [self createLogfile:SWRVE_TRUNCATE_IF_TOO_LARGE];
        
        // All set up, so start to do any work work now.
        self.deviceUUID = [[NSUserDefaults standardUserDefaults] stringForKey:@"swrve_device_id"];
        if (self.deviceUUID == nil) {
            // This is the first time we see this device, assign a UUID to it
            self.deviceUUID = [[NSUUID UUID] UUIDString];
            [[NSUserDefaults standardUserDefaults] setObject:self.deviceUUID forKey:@"swrve_device_id"];
        }

        [self initLinking:swrveConfig.linkServer];

        if (self.config.reportInAppPurchases) {
            self.transactionObserver = [[SwrveTransactionListener alloc] initWithPaymentQueue:[SKPaymentQueue defaultQueue] andTransactionCompleteListener:self];
        }
        
        // Setup empty user attributes store
        self.userUpdates = [[NSMutableDictionary alloc]init];
        [self.userUpdates setValue:@"user" forKey:@"type"];
        [self.userUpdates setValue:[[NSMutableDictionary alloc]init] forKey:@"attributes"];

        [self queueSessionStart];
        [self userIdentified];
        [self sendIdentifiers];

        if(swrveConfig.autoCollectDeviceToken && [Swrve sharedInstance] == self && !didSwizzle){
            id appDelegate = [UIApplication sharedApplication].delegate;
            
            SEL didRegister = @selector(application:didRegisterForRemoteNotificationsWithDeviceToken:);
            SEL didFail = @selector(application:didFailToRegisterForRemoteNotificationsWithError:);
            
            // Cast to actual method signature, otherwise it may crash
            didRegisterForRemoteNotificationsWithDeviceTokenImpl = (didRegisterForRemoteNotificationsWithDeviceTokenImplSignature)_swizzelMethod(appDelegate, didRegister, self);
            didFailToRegisterForRemoteNotificationsWithErrorImpl = (didFailToRegisterForRemoteNotificationsWithErrorImplSignature)_swizzelMethod(appDelegate, didFail, self);
            didSwizzle = true;
        } else {
            didRegisterForRemoteNotificationsWithDeviceTokenImpl = NULL;
            didFailToRegisterForRemoteNotificationsWithErrorImpl = NULL;
        }
        
        if (swrveConfig.talkEnabled) {
            _talk = [[SwrveMessageController alloc]initWithSwrve:self];
        }

        self.okToStartSessionOnResume = NO;
        [self registerForNotifications];
        
        // If this is the first time this user has been seen send install analytics
        if(didSetUserId) {
            [self event:@"Swrve.first_session"];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyyMMdd"];
            [self userUpdate:@{ @"swrve.install_date" : [dateFormatter stringFromDate:[NSDate date]] } ];
        }

        self.campaignsAndResourcesFlushFrequency = [[NSUserDefaults standardUserDefaults] doubleForKey:@"swrve_cr_flush_frequency"];
        if (self.campaignsAndResourcesFlushFrequency == 0) {
            self.campaignsAndResourcesFlushFrequency = SWRVE_DEFAULT_CAMPAIGN_RESOURCES_FLUSH_FREQUENCY / 1000;
        }

        self.campaignsAndResourcesFlushRefreshDelay = [[NSUserDefaults standardUserDefaults] doubleForKey:@"swrve_cr_flush_delay"];
        if (self.campaignsAndResourcesFlushRefreshDelay == 0) {
            self.campaignsAndResourcesFlushRefreshDelay = SWRVE_DEFAULT_CAMPAIGN_RESOURCES_FLUSH_REFRESH_DELAY / 1000;
        }

        if (self.config.autoDownloadCampaignsAndResources) {
            [self refreshCampaignsAndResources];

            // Ensure timer isn't already set
            if([self.campaignsAndResourcesTimer respondsToSelector:@selector(invalidate)]) {
                [self.campaignsAndResourcesTimer invalidate];
            }
            self.campaignsAndResourcesTimer = [NSTimer scheduledTimerWithTimeInterval:self.campaignsAndResourcesFlushFrequency target:self selector:@selector(checkForCampaignAndResourcesUpdates:) userInfo:nil repeats:YES];
        }
    }
    
    [self sendQueuedEvents];
    
    return self;
}


- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    Swrve* swrveInstance = [Swrve sharedInstance];
    if( swrveInstance == NULL) {
        NSLog(@"Error: Auto device token collection only works if you are using the Swrve instance singleton.");
    } else {
        if (swrveInstance.talk != nil) {
            [swrveInstance.talk setDeviceToken:deviceToken];
            NSLog(@"Auto collected device token.");
        }
        
        if( swrveInstance->didRegisterForRemoteNotificationsWithDeviceTokenImpl != NULL ) {
            id target = [UIApplication sharedApplication].delegate;
            swrveInstance->didRegisterForRemoteNotificationsWithDeviceTokenImpl(target, @selector(application:didRegisterForRemoteNotificationsWithDeviceToken:), [UIApplication sharedApplication], deviceToken);
        }
    }
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    Swrve* swrveInstance = [Swrve sharedInstance];
    if( swrveInstance == NULL) {
        NSLog(@"Error: Auto device token collection only works if you are using the Swrve instance singleton.");
    } else {
        NSLog(@"Could not auto collected device token.");
        
        if( swrveInstance->didFailToRegisterForRemoteNotificationsWithErrorImpl != NULL ) {
            id target = [UIApplication sharedApplication].delegate;
            swrveInstance->didFailToRegisterForRemoteNotificationsWithErrorImpl(target, @selector(application:didFailToRegisterForRemoteNotificationsWithError:), [UIApplication sharedApplication], error);
        }
    }
}

-(void) queueSessionStart
{
    [self maybeFlushToDisk];
    NSMutableDictionary* json = [[NSMutableDictionary alloc] init];
    [self queueEvent:@"session_start" data:json triggerCallback:true];
}

-(int) sessionStart
{
    [self queueSessionStart];
    [self sendQueuedEvents];
    return SWRVE_SUCCESS;
}

-(int) sessionEnd
{
    [self maybeFlushToDisk];
    NSMutableDictionary* json = [[NSMutableDictionary alloc] init];
    [self queueEvent:@"session_end" data:json triggerCallback:true];
    self.okToStartSessionOnResume = YES;
    return SWRVE_SUCCESS;
}

-(int) purchaseItem:(NSString*)itemName currency:(NSString*)itemCurrency cost:(int)itemCost quantity:(int)itemQuantity
{
    [self maybeFlushToDisk];
    NSMutableDictionary* json = [[NSMutableDictionary alloc] init];
    [json setValue:NullableNSString(itemName) forKey:@"item"];
    [json setValue:NullableNSString(itemCurrency) forKey:@"currency"];
    [json setValue:[NSNumber numberWithInt:itemCost] forKey:@"cost"];
    [json setValue:[NSNumber numberWithInt:itemQuantity] forKey:@"quantity"];
    [self queueEvent:@"purchase" data:json triggerCallback:true];
    return SWRVE_SUCCESS;
}

-(int) event:(NSString*)eventName
{
    return [self eventInternal:eventName payload:nil triggerCallback:true];
}

-(int) event:(NSString*)eventName payload:(NSDictionary*)eventPayload
{
    return [self eventInternal:eventName payload:eventPayload triggerCallback:true];
}

-(int) currencyGiven:(NSString*)givenCurrency givenAmount:(double)givenAmount
{
    [self maybeFlushToDisk];
    NSMutableDictionary* json = [[NSMutableDictionary alloc] init];
    [json setValue:NullableNSString(givenCurrency) forKey:@"given_currency"];
    [json setValue:[NSNumber numberWithDouble:givenAmount] forKey:@"given_amount"];
    [self queueEvent:@"currency_given" data:json triggerCallback:true];
    return SWRVE_SUCCESS;
}

-(int) userUpdate:(NSDictionary*)attributes
{
    [self maybeFlushToDisk];
    
    // Merge attributes with current set of attributes
    if (attributes) {
        NSMutableDictionary * currentAttributes = (NSMutableDictionary*)[self.userUpdates objectForKey:@"attributes"];
        [self.userUpdates setValue:[NSNumber numberWithUnsignedLongLong:[self getTime]] forKey:@"time"];
        for (id attributeKey in attributes) {
            id attribute = [attributes objectForKey:attributeKey];
            [currentAttributes setObject:attribute forKey:attributeKey];
        }
    }
    
    return SWRVE_SUCCESS;
}

-(SwrveResourceManager*) getSwrveResourceManager
{
    return [self resourceManager];
}

-(void) refreshCampaignsAndResources:(NSTimer*)timer
{
    [self refreshCampaignsAndResources];
}

-(void) refreshCampaignsAndResources
{
    // When campaigns need to be downloaded manually, enforce max. flush frequency
    if (!self.config.autoDownloadCampaignsAndResources) {
        NSDate* now = [NSDate date];
 
        if (self.campaignsAndResourcesLastRefreshed != nil) {
            NSDate* nextAllowedTime = [NSDate dateWithTimeInterval:self.campaignsAndResourcesFlushFrequency sinceDate:self.campaignsAndResourcesLastRefreshed];
            if ([now compare:nextAllowedTime] == NSOrderedAscending) {
                // Too soon to call refresh again
                NSLog(@"Request to retrieve campaign and user resource data was rate-limited.");
                return;
            }
        }
 
        self.campaignsAndResourcesLastRefreshed = [NSDate date];
    }
 
    NSMutableString* queryString = [NSMutableString stringWithFormat:@"?user=%@&api_key=%@&app_version=%@&joined=%llu",
                             self.userID, self.apiKey, self.config.appVersion, self->install_time];
    if (self.talk && [self.config talkEnabled]) {
        NSString* campaignQueryString = [self.talk getCampaignQueryString];
        [queryString appendFormat:@"&%@", campaignQueryString];
    }
 
    NSString* etagValue = [[NSUserDefaults standardUserDefaults] stringForKey:@"campaigns_and_resources_etag"];
    if (etagValue != nil) {
        [queryString appendFormat:@"&etag=%@", etagValue];
    }
 
    NSURL* url = [NSURL URLWithString:queryString relativeToURL:self->campaignsAndResourcesURL];
    [self sendHttpGETRequest:url completionHandler:^(NSURLResponse* response, NSData* data, NSError* error) {
        if (!error) {
            NSInteger statusCode = 200;
            enum HttpStatus status = HTTP_SUCCESS;
            
            NSDictionary* headers = [[NSDictionary alloc] init];
            if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
                statusCode = [httpResponse statusCode];
                status = [self getHttpStatus:httpResponse];
                headers = [httpResponse allHeaderFields];
            }
            
            if (status == SWRVE_SUCCESS) {
                if ([self isValidJson:data]) {
                    NSString* etagHeader = [headers objectForKey:@"ETag"];
                    if (etagHeader != nil) {
                        [[NSUserDefaults standardUserDefaults] setValue:etagHeader forKey:@"campaigns_and_resources_etag"];
                    }

                    NSDictionary* responseDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];

                    NSNumber* flushFrequency = [responseDict objectForKey:@"flush_frequency"];
                    if (flushFrequency != nil) {
                        self.campaignsAndResourcesFlushFrequency = [flushFrequency integerValue] / 1000;
                        [[NSUserDefaults standardUserDefaults] setInteger:self.campaignsAndResourcesFlushFrequency forKey:@"swrve_cr_flush_frequency"];
                    }

                    NSNumber* flushDelay = [responseDict objectForKey:@"flush_refresh_delay"];
                    if (flushDelay != nil) {
                        self.campaignsAndResourcesFlushRefreshDelay = [flushDelay integerValue] / 1000;
                        [[NSUserDefaults standardUserDefaults] setInteger:self.campaignsAndResourcesFlushRefreshDelay forKey:@"swrve_cr_flush_delay"];
                    }

                    if (self.talk && [self.config talkEnabled]) {
                        NSDictionary* campaignJson = [responseDict objectForKey:@"campaigns"];
                        if (campaignJson != nil) {
                            [self.talk updateCampaigns:campaignJson];

                            NSData* campaignData = [NSJSONSerialization dataWithJSONObject:campaignJson options:0 error:nil];
                            [[self talk] writeToCampaignCache:campaignData];
                            
                            // Notify campaigns have been downloaded
                            NSMutableArray* campaignIds = [[NSMutableArray alloc] init];
                            for( SwrveCampaign* campaign in self.talk.campaigns ){
                                [campaignIds addObject:[NSNumber numberWithInteger:campaign.ID]];
                            }
                            
                            NSDictionary* payload = @{ @"ids" : [campaignIds componentsJoinedByString:@","],
                                                       @"count" : [NSString stringWithFormat:@"%lu", (unsigned long)[self.talk.campaigns count]] };
                            
                            [self event:@"Swrve.Messages.campaigns_downloaded" payload:payload];
                        }
                        // See if there are any messages to autoShow, either based on cached value if we didn't get a result or based on new values just retrieved
                        [[self talk] autoShowMessages];
                    }

                    NSArray* resourceJson = [responseDict objectForKey:@"user_resources"];
                    if (resourceJson != nil) {
                        [[self resourceManager] setResourcesFromArray:resourceJson];
                       
                        NSData* resourceData = [NSJSONSerialization dataWithJSONObject:resourceJson options:0 error:nil];
                        [self->resourcesFile writeToFile:resourceData];

                        if ([self.config resourcesUpdatedCallback] != nil) {
                            [self.config resourcesUpdatedCallback]();
                        }
                    }
                } else {
                    NSLog(@"Invalid JSON received for user resources and campaigns");
                }
            } else if (statusCode == 429) {
                NSLog(@"Request to retrieve campaign and user resource data was rate-limited.");
            } else {
                NSLog(@"Request to retrieve campaign and user resource data failed");
            }
        }
    }];
}

- (void) checkForCampaignAndResourcesUpdates:(NSTimer*)timer
{
    // If this wasn't called from the timer then reset the timer
    if (timer == nil) {
        NSDate* nextInterval = [NSDate dateWithTimeIntervalSinceNow:self.campaignsAndResourcesFlushFrequency];
        [self.campaignsAndResourcesTimer setFireDate:nextInterval];
    }
    
    // Check if there are events in the buffer or in the cache
    if (self->eventFileHasData || [self->eventBuffer count] > 0 || self->eventsWereSent) {
        [self sendQueuedEvents];
        self->eventsWereSent = NO;
        
        [NSTimer scheduledTimerWithTimeInterval:self.campaignsAndResourcesFlushRefreshDelay target:self selector:@selector(refreshCampaignsAndResources:) userInfo:nil repeats:NO];
    } else {
        [self refreshCampaignsAndResources];
    }
}

-(void) clickThruForTargetGame:(long)targetApp source:(NSString*)source
{
    NSString * authString = [NSString stringWithFormat:@"?user=%@&api_key=%@&app_version=%@&link_token=%@&destination=%ld&source=%@",
                             self.userID,
                             self.apiKey,
                             self.config.appVersion,
                             self.config.linkToken,
                             targetApp,
                             source];
    NSLog(@"Swrve click through logged from %ld to %ld as '%@'", self.appID, targetApp, source);

    if (_TEST_clickThruRequests) {
        NSString * testEntry = [NSString stringWithFormat:@"%@%@", [self->linking_click_thru absoluteString], authString];
        [_TEST_clickThruRequests addObject:testEntry];
    }
    
    [self sendHttpGETRequest:self->linking_click_thru queryString:authString];
}

-(void) setPushNotificationsDeviceToken:(NSData*)deviceToken
{
    NSCAssert(deviceToken, @"The device token cannot be null");
    NSString* tokenString = [[[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]] stringByReplacingOccurrencesOfString:@" " withString:@""];
    self.deviceToken = tokenString;
    [[NSUserDefaults standardUserDefaults] setValue:tokenString forKey:swrve_device_token_key];
    [self sendDeviceProperties];
}

-(void) sendQueuedEvents
{
    if (!self.userID)
    {
        NSLog(@"Swrve user_id is null. Not sending data.");
        return;
    }
    
    NSLog(@"Sending queued events");
    if (self->eventFileHasData)
    {
        [self sendLogfile];
    }
    
    [self queueUserUpdates];
    
    // Early out if length is zero.
    if ([self->eventBuffer count] == 0) return;
    
    // Swap buffers
    NSArray* buffer = self->eventBuffer;
    int bytes = self->eventBufferBytes;
    [self initBuffer];
    
    NSString* session_token = [self createSessionToken];
    NSString* array_body = [self copyBufferToJson:buffer];
    NSString* json_string = [self createJSON:session_token events:array_body];
    
    NSData* json_data = [json_string dataUsingEncoding:NSUTF8StringEncoding];
    
    if (_TEST_eventRequests) {
        NSString * testEntry = [NSString stringWithFormat:@"%@ %@", [self->batch_url absoluteString], json_string];
        [_TEST_eventRequests addObject:testEntry];
    }
    
    self.TEST_eventsSending = YES;
    self->eventsWereSent = YES;
    
    [self sendHttpPOSTRequest:self->batch_url
                     jsonData:json_data
            completionHandler:^(NSURLResponse* response, NSData* data, NSError* error) {
        
                if (error){
                    NSLog(@"Error opening HTTP stream: %@ %@", [error localizedDescription], [error localizedFailureReason]);
                    self->eventBufferBytes += [json_string length];
                    [self->eventBuffer addObject:json_string];
                    self.TEST_eventsSending = NO;
                    return;
                }
            
                // Schedule the stream on the current run loop, then open the stream (which
                // automatically sends the request).  Wait for at least one byte of data to
                // be returned by the server.  As soon as at least one byte is available,
                // the full HTTP response header is available.  If no data is returned
                // within the timeout period, give up.
                SwrveSendContext* sendContext = [[SwrveSendContext alloc] init];
                [sendContext setSwrveReference:self];
                [sendContext setSwrveInstanceID:self->instanceID];
                [sendContext setBuffer:buffer];
                [sendContext setBufferLength:bytes];

                enum HttpStatus status = HTTP_SUCCESS;
                if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
                    status = [self getHttpStatus:httpResponse];
                }
                [self eventsSentCallback:status withData:data andContext:sendContext];
    }];
}

-(void) saveEventsToDisk
{
    NSLog(@"Writing unsent event data to file");
    
    [self queueUserUpdates];
    
    if (self->eventStream && [self->eventBuffer count] > 0)
    {
        NSString* json = [self copyBufferToJson:self->eventBuffer];
        NSData* buffer = [json dataUsingEncoding:NSUTF8StringEncoding];
        NSInteger bytes_written = [self->eventStream write:(const uint8_t *)[buffer bytes] maxLength:[buffer length]];
        NSLog(@"Wrote %ld bytes to disk\n", (long)bytes_written);
        [self->eventStream write:(const uint8_t *)swrve_trailing_comma maxLength:strlen(swrve_trailing_comma)];
        self->eventFileHasData = true;
    }
    
    // Always empty the buffer
    [self initBuffer];
}

-(void) setEventQueuedCallback:(SwrveEventQueuedCallback)callbackBlock
{
    event_queued_callback = callbackBlock;
}

-(void) shutdown
{
    if ([[SwrveInstanceIDRecorder sharedInstance]hasSwrveInstanceID:instanceID] == NO)
    {
        NSLog(@"Swrve shutdown: called on invalid instance.");
        return;
    }
    
    _talk = nil;
    _resourceManager = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [[SwrveInstanceIDRecorder sharedInstance]removeSwrveInstanceID:instanceID];
    
    if (self->eventStream) {
        [self->eventStream close];
        self->eventStream = nil;
    }
    
    self->eventBuffer = nil;
}

-(int) eventWithNoCallback:(NSString*)eventName payload:(NSDictionary*)eventPayload
{
    return [self eventInternal:eventName payload:eventPayload triggerCallback:false];
}


#pragma mark - 
#pragma mark Private methods

-(int) eventInternal:(NSString*)eventName payload:(NSDictionary*)eventPayload triggerCallback:(bool)triggerCallback
{
    if (!eventPayload) {
        eventPayload = [[NSDictionary alloc]init];
    }
    
    [self maybeFlushToDisk];
    NSMutableDictionary* json = [[NSMutableDictionary alloc] init];
    [json setValue:NullableNSString(eventName) forKey:@"name"];
    [json setValue:eventPayload forKey:@"payload"];
    [self queueEvent:@"event" data:json triggerCallback:triggerCallback];
    return SWRVE_SUCCESS;
}

-(void) dealloc
{
    if ([[SwrveInstanceIDRecorder sharedInstance]hasSwrveInstanceID:instanceID] == YES)
    {
        [self shutdown];
    }
}


-(void) removeBlockStoreItem:(int)blockId
{
    [blockStore removeObjectForKey:[NSNumber numberWithInt:blockId ]];
}

-(void) updateDeviceInfo
{
    NSMutableDictionary * mutableInfo = (NSMutableDictionary*)_deviceInfo;
    [mutableInfo removeAllObjects];
    
    [mutableInfo addEntriesFromDictionary:[self getDeviceProperties]];
}

-(void) registerForNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appDidBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appWillResignActive:)
                                                 name:UIApplicationWillResignActiveNotification object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appWillTerminate:)
                                                 name:UIApplicationWillTerminateNotification object:nil];
}

-(void) appDidBecomeActive:(NSNotification*)notification
{
    if (self.okToStartSessionOnResume) {
        if (self.config.autoSendEventsOnResume) {
            [self sendQueuedEvents];
        }
        [self sessionStart];
        [self sendDeviceProperties];
    }
}

-(void) appWillResignActive:(NSNotification*)notification
{
    [self sessionEnd];
    if (self.config.autoSaveEventsOnResign) {
        [self saveEventsToDisk];
    }
}

-(void) appWillTerminate:(NSNotification*)notification
{
    [self sessionEnd];
    if (self.config.autoSaveEventsOnResign) {
        [self saveEventsToDisk];
    }
}

-(void) queueUserUpdates
{
    NSMutableDictionary * currentAttributes =  (NSMutableDictionary*)[self.userUpdates objectForKey:@"attributes"];
    if (currentAttributes.count > 0) {
        [self queueEvent:@"user" data:self.userUpdates triggerCallback:true];
        [currentAttributes removeAllObjects];
    }
}

-(void) pushNotificationReceived:(NSDictionary *)userInfo
{
    // Try to get the identifier _p
    id push_identifier = [userInfo objectForKey:@"_p"];
    if (push_identifier && ![push_identifier isKindOfClass:[NSNull class]]) {
        NSString* push_id = @"-1";
        if ([push_identifier isKindOfClass:[NSString class]]) {
            push_id = (NSString*)push_identifier;
        }
        else if ([push_identifier isKindOfClass:[NSNumber class]]) {
            push_id = [((NSNumber*)push_identifier) stringValue];
        }
        else {
            NSLog(@"Unknown Swrve notification ID class for _p attribute");
            return;
        }

        NSString* eventName = [NSString stringWithFormat:@"Swrve.Messages.Push-%@.engaged", push_id];
        [self event:eventName];
        NSLog(@"Got Swrve notification with ID %@", push_id);
    } else {
        NSLog(@"Got unidentified notification");
    }
}

// Get a string that represents the current App Version
// The implemention intentionally is unspecified, the rest of the SDK is not aware
// of the details of this.
+(NSString*) getAppVersion
{
    NSString * appVersion = nil;
    @try {
        appVersion = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleShortVersionString"];
    }
    @catch (NSException * e) {}
    if (!appVersion)
    {
        return @"error";
    }
    
    return appVersion;
}

-(void) setupConfig:(SwrveConfig *)config
{
    // Setup default server locations
    
    if (nil == config.eventsServer) {
        config.eventsServer = [NSString stringWithFormat:@"https://%ld.api.swrve.com", self.appID];
    }

    if (nil == config.contentServer) {
        config.contentServer = [NSString stringWithFormat:@"https://%ld.content.swrve.com", self.appID];
    }

    if (nil == config.linkServer) {
        config.linkServer = [NSString stringWithFormat:@"https://%ld.link.swrve.com", self.appID];
    }
   
    // Validate other values
    
    NSCAssert(config.httpTimeoutSeconds > 0, @"httpTimeoutSeconds must be greater than zero or requests will fail immediately.");
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
    if (config.linkToken) {
        [defaults setObject:config.linkToken forKey:swrve_link_token_key];
    }
}

-(void) maybeFlushToDisk
{
    //NSLog(@"Considering flush: RAM size: %ld, max: %d\n", swrve->bytes, _SWRVE_MEMORY_QUEUE_MAX_BYTES);
    if (self->eventBufferBytes > SWRVE_MEMORY_QUEUE_MAX_BYTES)
    {
        [self saveEventsToDisk];
    }
}

-(void) queueEvent:(NSString*)eventType data:(NSMutableDictionary*)eventData triggerCallback:(bool)triggerCallback
{
    if (self->eventBuffer) {
        // Add common attributes (if not already present)
        if (![eventData objectForKey:@"type"]) {
            [eventData setValue:eventType forKey:@"type"];
        }
        if (![eventData objectForKey:@"time"]) {
            [eventData setValue:[NSNumber numberWithUnsignedLongLong:[self getTime]] forKey:@"time"];
        }
        if (![eventData objectForKey:@"seqnum"]) {
            [eventData setValue:[NSNumber numberWithInteger:[self nextEventSequenceNumber]] forKey:@"seqnum"];
        }
        
        //NSLog(@"Queuing event: %@ %@", eventType, eventData);
        
        // Convert to string
        NSData* json_data = [NSJSONSerialization dataWithJSONObject:eventData options:0 error:nil];
        if (json_data) {
            NSString* json_string = [[NSString alloc] initWithData:json_data encoding:NSUTF8StringEncoding];
            self->eventBufferBytes += [json_string length];
            
            [self->eventBuffer addObject:json_string];
            
            if (triggerCallback && event_queued_callback != NULL )
            {
                event_queued_callback(eventData, json_string);
            }
        }
    }
}

-(void) sendIdentifiers
{
    NSMutableDictionary* identifiers = [[NSMutableDictionary alloc] init];
    
    NSString* id_forv = getIDFV();
    if (id_forv) {
        [identifiers setValue:id_forv forKey:@"ios_idfv"];
    }
    
    if ([identifiers count] > 0) {
        NSMutableDictionary* json = [[NSMutableDictionary alloc] init];
        [json setValue:identifiers forKey:@"identifiers"];
        [self queueEvent:@"identifiers" data:json triggerCallback:false];
    }
}

- (float) _estimate_dpi
{
    float scale = 1;

    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        scale = [[UIScreen mainScreen] scale];
    }

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return 132.0f * scale;
    }

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        return 163.0f * scale;
    }

    return 160.0f * scale;
}

- (void) sendCrashlyticsMetadata
{
    // Check if Crashlytics is used in this project
    Class crashlyticsClass = NSClassFromString(@"Crashlytics");
    if (crashlyticsClass != nil) {
        if ([crashlyticsClass respondsToSelector:@selector(setObjectValue:forKey:)]) {
            [crashlyticsClass performSelector:@selector(setObjectValue:forKey:) withObject:@SWRVE_SDK_VERSION withObject:@"Swrve_version"];
        }
    }
}

- (CGRect) getDeviceScreenBounds
{
    UIScreen* screen   = [UIScreen mainScreen];
    CGRect bounds = [screen bounds];
    float screen_scale = 1;
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        screen_scale = [[UIScreen mainScreen] scale];
    }
    bounds.size.width  = bounds.size.width  * screen_scale;
    bounds.size.height = bounds.size.height * screen_scale;
    return bounds;
}

- (NSDictionary*) getDeviceProperties
{
    UIDevice* device   = [UIDevice currentDevice];
    NSTimeZone* tz     = [NSTimeZone localTimeZone];
    NSNumber* dpi = [NSNumber numberWithFloat:[self _estimate_dpi]];
    NSNumber* min_os = [NSNumber numberWithInt: __IPHONE_OS_VERSION_MIN_REQUIRED];
    NSString *sdk_language = self.config.language;
    CGRect screen_bounds = [self getDeviceScreenBounds];
    NSNumber* device_width = [NSNumber numberWithFloat: screen_bounds.size.width];
    NSNumber* device_height = [NSNumber numberWithFloat: screen_bounds.size.height];
    NSNumber* secondsFromGMT = [NSNumber numberWithInteger:[tz secondsFromGMT]];
    NSString* timezone_name = [tz name];
    
    NSMutableDictionary* deviceInfo = [[NSMutableDictionary alloc] init];
    [deviceInfo setValue:[device model]         forKey:@"swrve.device_name"];
    [deviceInfo setValue:[device systemName]    forKey:@"swrve.os"];
    [deviceInfo setValue:[device systemVersion] forKey:@"swrve.os_version"];
    [deviceInfo setValue:min_os                 forKey:@"swrve.ios_min_version"];
    [deviceInfo setValue:sdk_language           forKey:@"swrve.language"];
    [deviceInfo setValue:device_height          forKey:@"swrve.device_height"];
    [deviceInfo setValue:device_width           forKey:@"swrve.device_width"];
    [deviceInfo setValue:dpi                    forKey:@"swrve.device_dpi"];
    [deviceInfo setValue:@SWRVE_SDK_VERSION     forKey:@"swrve.sdk_version"];
    [deviceInfo setValue:@"apple"               forKey:@"swrve.app_store"];
    [deviceInfo setValue:secondsFromGMT         forKey:@"swrve.utc_offset_seconds"];
    [deviceInfo setValue:timezone_name          forKey:@"swrve.timezone_name"];
    
    if (self.deviceToken) {
        [deviceInfo setValue:self.deviceToken forKey:@"swrve.ios_token"];
    }
    
    return deviceInfo;
}

- (void) sendDeviceProperties
{
    NSDictionary* deviceInfo = [self getDeviceProperties];
    
    NSMutableString* formattedDeviceData = [[NSMutableString alloc] initWithFormat:
    @"                      User: %@\n"
     "                Link Token: %@\n"
     "                   API Key: %@\n"
     "                    App ID: %ld\n"
     "               App Version: %@\n"
     "                  Language: %@\n"
     "              Event Server: %@\n"
     "            Content Server: %@\n",
          self.userID,
          self.config.linkToken,
          self.apiKey,
          self.appID,
          self.config.appVersion,
          self.config.language,
          self.config.eventsServer,
          self.config.contentServer];

    for (NSString* key in deviceInfo) {
        [formattedDeviceData appendFormat:@"  %24s: %@\n", [key UTF8String], [deviceInfo objectForKey:key]];
    }
    NSLog(@"Swrve config:\n%@", formattedDeviceData);
    
    [self updateDeviceInfo];
    [self userUpdate:deviceInfo];
}

// Get the time that the application was first installed.
// This value is stored in a file. If this file is not available, then we assume
// that the application was installed now, and save the current time to the file.
- (UInt64) getInstallTimeHelper:(NSString*)fileName
{
    unsigned long long seconds = 0;

    NSError* error = NULL;
    NSString* file_contents = [[NSString alloc] initWithContentsOfFile:fileName encoding:NSUTF8StringEncoding error:&error];

    if (!error && file_contents) {
        seconds = [file_contents longLongValue];
    } else {
        NSLog(@"could not read file: %@", fileName);
    }
    
    // If we loaded a value and it was not zero (or less than zero?)
    // then we are done.
    if (seconds > 0)
    {
        UInt64 result = seconds;
        return result * 1000;
    }

    UInt64 time = [self getTime];
    NSString* currentTime = [NSString stringWithFormat:@"%llu", time/(UInt64)1000L];
    [currentTime writeToFile:fileName atomically:YES encoding:NSUTF8StringEncoding error:nil];
    return (time / 1000 * 1000);
}

- (UInt64) getInstallTime:(NSString*)fileName
{
    UInt64 result = [self getInstallTimeHelper:fileName];

    NSDate* install_date = [NSDate dateWithTimeIntervalSince1970:(result/1000)];
    NSLog(@"Install Time: %@", install_date);

    return result;
}

/*
 * Invalidates the currently stored ETag
 * Should be called when a refresh of campaigns and resources needs to be forced (eg. when cached data cannot be read)
 */
- (void) invalidateETag
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"campaigns_and_resources_etag"];
}

- (void) initResources
{
    // Create signature protected cache file
    NSURL* fileURL = [NSURL fileURLWithPath:self.config.userResourcesCacheFile];
    NSURL* signatureURL = [NSURL fileURLWithPath:self.config.userResourcesCacheSignatureFile];
    resourcesFile = [[SwrveSignatureProtectedFile alloc] initFile:fileURL signatureFilename:signatureURL usingKey:[self getSignatureKey] signatureErrorListener:self];
    
    // Initialize resource manager
    _resourceManager = [[SwrveResourceManager alloc] init];
    
    // read content of resources file and update resource manager if signature valid
    NSData* content = [resourcesFile readFromFile];
    
    if (content != nil) {
        NSError* error = nil;
        NSArray* resourcesArray = [NSJSONSerialization JSONObjectWithData:content options:NSJSONReadingMutableContainers error:&error];
        if (!error) {
            [[self resourceManager] setResourcesFromArray:resourcesArray];
            if ([self.config resourcesUpdatedCallback] != nil) {
                [self.config resourcesUpdatedCallback]();
            }
        }
    } else {
        [self invalidateETag];
    }
}

enum HttpStatus {
    HTTP_SUCCESS,
    HTTP_REDIRECTION,
    HTTP_CLIENT_ERROR,
    HTTP_SERVER_ERROR
};

- (enum HttpStatus) getHttpStatus:(NSHTTPURLResponse*) httpResponse
{
    long code = [httpResponse statusCode];

    if (code < 300) {
        return HTTP_SUCCESS;
    }
    
    if (code < 400) {
        return HTTP_REDIRECTION;
    }

    if (code < 500) {
        return HTTP_CLIENT_ERROR;
    }
    
    // 500+
    return HTTP_SERVER_ERROR;
}

- (void) initLinking:(NSString*) server
{
    NSURL* baseURL = [NSURL URLWithString:server];
    self->linking_app_launch = [NSURL URLWithString:@"1/app_launch" relativeToURL:baseURL];
    self->linking_click_thru = [NSURL URLWithString:@"1/click_thru" relativeToURL:baseURL];
}

- (void) userIdentified
{
    NSString* query = [NSString stringWithFormat:@"?user=%@&api_key=%@&app_version=%@&link_token=%@",
                            self.userID,
                            self.apiKey,
                            self.config.appVersion,
                            self.config.linkToken];
    
    // Send app launch message
    if (self->_TEST_appLaunchRequests) {
        NSString * testEntry = [NSString stringWithFormat:@"%@%@", [self->linking_app_launch absoluteString], query];
        [self->_TEST_appLaunchRequests addObject:testEntry];
    }
    
    [self sendHttpGETRequest:self->linking_app_launch queryString:query];

    // Always send device data
    [self sendDeviceProperties];
}

- (NSOutputStream*) createLogfile:(int)mode
{
    // If the file already exists, close it.
    if (self->eventStream)
    {
        [self->eventStream close];
    }
    
    NSOutputStream* newFile = NULL;
    self->eventFileHasData = false;
    
    switch (mode)
    {    
        case SWRVE_TRUNCATE_FILE:
            newFile = [NSOutputStream outputStreamWithURL:self->eventFilename append:NO];
            break;
            
        case SWRVE_APPEND_TO_FILE:
            newFile = [NSOutputStream outputStreamWithURL:self->eventFilename append:YES];
            break;
            
        case SWRVE_TRUNCATE_IF_TOO_LARGE:
        {
            NSData* cacheContent = [NSData dataWithContentsOfURL:self->eventFilename];
            
            if (cacheContent == nil)
            {
                newFile = [NSOutputStream outputStreamWithURL:self->eventFilename append:NO];
            } else {
                NSUInteger cacheLength = [cacheContent length];
                self->eventFileHasData = cacheLength > 0;
                NSLog(@"%lu - %d", (unsigned long)cacheLength, SWRVE_DISK_MAX_BYTES);
            
                if (cacheLength < SWRVE_DISK_MAX_BYTES) {
                    newFile = [NSOutputStream outputStreamWithURL:self->eventFilename append:YES];
                } else {
                    newFile = [NSOutputStream outputStreamWithURL:self->eventFilename append:NO];
                    NSLog(@"Swrve log file too large (%lu)... truncating", (unsigned long)cacheLength);
                    self->eventFileHasData = false;
                }
            }
            
            break;
        }
    }
    
    [newFile open];
 
    return newFile;
}

- (void) eventsSentCallback:(enum HttpStatus)status withData:(NSData*)data andContext:(SwrveSendContext*)client_info
{
    Swrve* swrve = [client_info swrveReference];
    if ([[SwrveInstanceIDRecorder sharedInstance]hasSwrveInstanceID:[client_info swrveInstanceID]] == YES) {

        if (swrve->_TEST_eventResponses) {
            [swrve addTestResponse:data withStatus:status toArray:swrve->_TEST_eventResponses];
        }

        switch (status) {
            case HTTP_REDIRECTION:
            case HTTP_SUCCESS:
                NSLog(@"Success sending events to Swrve");
                break;
            case HTTP_CLIENT_ERROR:
                NSLog(@"HTTP Error - not adding events back into the queue: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                break;
            case HTTP_SERVER_ERROR:
                NSLog(@"Error sending event data to Swrve (%@) Adding data back onto unsent message buffer", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                [swrve->eventBuffer addObjectsFromArray:[client_info buffer]];
                swrve->eventBufferBytes += [client_info bufferLength];
                break;
        }
        swrve.TEST_eventsSending = NO;
    }
}

// Convert the array of strings into a json array.
// This does not add the square brackets.
- (NSString*) copyBufferToJson:(NSArray*) buffer
{
    return [buffer componentsJoinedByString:@",\n"];
}

- (NSString*) createJSON:(NSString*)sessionToken events:(NSString*)rawEvents
{
    NSString *eventArray = [NSString stringWithFormat:@"[%@]", rawEvents];
    NSData *bodyData = [eventArray dataUsingEncoding:NSUTF8StringEncoding];
    NSArray* body = [NSJSONSerialization
                     JSONObjectWithData:bodyData
                     options:NSJSONReadingMutableContainers
                     error:nil];
    
    // Device ID needs to be unique for this user only, so we create a shorter version to safe on storage in S3
    NSUInteger shortDeviceID = [self.deviceUUID hash];
    if (shortDeviceID > 10000) {
        shortDeviceID = shortDeviceID / 1000;
    }

    NSMutableDictionary* jsonPacket = [[NSMutableDictionary alloc] init];
    [jsonPacket setValue:self.userID forKey:@"user"];
    [jsonPacket setValue:[NSNumber numberWithInteger:shortDeviceID] forKey:@"device_id"];
    [jsonPacket setValue:[NSNumber numberWithInt:SWRVE_VERSION] forKey:@"version"];
    [jsonPacket setValue:NullableNSString(self.config.appVersion) forKey:@"app_version"];
    [jsonPacket setValue:NullableNSString(sessionToken) forKey:@"session_token"];
    [jsonPacket setValue:body forKey:@"data"];
    
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:jsonPacket options:0 error:nil];
    NSString* json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    return json;
}

- (NSInteger) nextEventSequenceNumber {
    
    NSInteger seqno;
    @synchronized(self) {
        // Defaults to 0 if this value is not available
        seqno= [[NSUserDefaults standardUserDefaults] integerForKey:@"swrve_event_seqnum"];
        seqno += 1;
        [[NSUserDefaults standardUserDefaults] setInteger:seqno forKey:@"swrve_event_seqnum"];
    }
    
    return seqno;
}

- (void) logfileSentCallback:(enum HttpStatus)status withData:(NSData*)data andContext:(SwrveSendLogfileContext*)context
{
    Swrve* swrve = [context swrveReference];
    if ([[SwrveInstanceIDRecorder sharedInstance]hasSwrveInstanceID:[context swrveInstanceID]] == YES) {
        int mode = SWRVE_TRUNCATE_FILE;
        
        if (swrve->_TEST_eventResponses) {
            [swrve addTestResponse:data withStatus:status toArray:swrve->_TEST_eventResponses];
        }

        switch (status) {
            case HTTP_SUCCESS:
            case HTTP_CLIENT_ERROR:
            case HTTP_REDIRECTION:
                NSLog(@"Received a valid HTTP POST response. Truncating event log file");
                break;
            case HTTP_SERVER_ERROR:
                NSLog(@"Error sending log file - reopening in append mode: status");
                mode = SWRVE_APPEND_TO_FILE;
                break;
        }

        // close, truncate and re-open the file.
        swrve->eventStream = [swrve createLogfile:mode];
    }
}

- (void) sendLogfile
{
    if (!self->eventStream) return;
    if (!self->eventFileHasData) return;
    
    NSLog(@"Sending log file %@", self->eventFilename);

    // Close the write stream and set it to null
    // No more appending will happen while it is null
    [self->eventStream close];
    self->eventStream = NULL;

    NSMutableData* contents = [[NSMutableData alloc] initWithContentsOfURL:self->eventFilename];
    
    if (contents == nil)
    {
        self->eventStream = [self createLogfile:SWRVE_TRUNCATE_FILE];
        return;
    }
    
    const CFIndex length = [contents length];
        
    if (length <= 2)
    {
        self->eventStream = [self createLogfile:SWRVE_TRUNCATE_FILE];
        return;
    }
    
    // Remove trailing comma
    [contents setLength:[contents length] - 2];
    NSString* file_contents = [[NSString alloc] initWithData:contents encoding:NSUTF8StringEncoding];
    NSString* session_token = [self createSessionToken];
    NSString* json_string = [self createJSON:session_token events:file_contents];
    
    NSData* json_data = [json_string dataUsingEncoding:NSUTF8StringEncoding];
    
    if (self->_TEST_eventRequests) {
        NSString * testEntry = [NSString stringWithFormat:@"%@ %@", [self->batch_url absoluteString], json_string];
        [self->_TEST_eventRequests addObject:testEntry];
    }
    
    [self sendHttpPOSTRequest:self->batch_url
                      jsonData:json_data
             completionHandler:^(NSURLResponse* response, NSData* data, NSError* error) {
        if (error) {
            NSLog(@"Error opening HTTP stream");
            return;
        }
        
        SwrveSendLogfileContext* logfileContext = [[SwrveSendLogfileContext alloc] init];
        [logfileContext setSwrveReference:self];
        [logfileContext setSwrveInstanceID:self->instanceID];
                 
        enum HttpStatus status = HTTP_SUCCESS;
        if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
            status = [self getHttpStatus:(NSHTTPURLResponse*)response];
        }
        [self logfileSentCallback:status withData:data andContext:logfileContext];
    }];
}

- (void) addTestResponse:(NSData*)data withStatus:(enum HttpStatus)status toArray:(NSMutableArray*)testArray
{
    NSString* testDataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    NSString * statusString = @"Unknown";
    if (status == HTTP_SUCCESS) {
        statusString = @"Success";
    } else if (status == HTTP_SERVER_ERROR) {
        statusString = @"Server Error";
    } else if (status == HTTP_CLIENT_ERROR) {
        statusString = @"Client Error";
    }
    
    NSString * testResponse = [NSString stringWithFormat:@"[%@][%@]", statusString, testDataStr];
    [testArray addObject:testResponse];
}


- (UInt64) getTime
{
    // Get the time since the epoch in seconds
    struct timeval time;
    gettimeofday(&time, NULL);
    return (((UInt64)time.tv_sec) * 1000) + (((UInt64)time.tv_usec) / 1000);
}

- (BOOL) isValidJson:(NSData*) json
{
    NSError *err = nil;
    id obj = [NSJSONSerialization JSONObjectWithData:json options:NSJSONReadingMutableContainers error:&err];
    return obj != nil;
}

- (void) sendHttpGETRequest:(NSURL*)url queryString:(NSString*)query
{
    [self sendHttpGETRequest:url queryString:query completionHandler:nil];
}

- (void) sendHttpGETRequest:(NSURL*)url
{
    [self sendHttpGETRequest:url completionHandler:nil];
}

- (void) sendHttpGETRequest:(NSURL*)baseUrl queryString:(NSString*)query completionHandler:(void (^)(NSURLResponse*, NSData*, NSError*))handler
{
    NSURL* url = [NSURL URLWithString:query relativeToURL:baseUrl];
    [self sendHttpGETRequest:url completionHandler:handler];
}

- (void) sendHttpGETRequest:(NSURL*)url completionHandler:(void (^)(NSURLResponse*, NSData*, NSError*))handler
{
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLCacheStorageAllowed timeoutInterval:self.config.httpTimeoutSeconds];
    if (handler == nil) {
        [request setHTTPMethod:@"HEAD"];
    } else {
        [request setHTTPMethod:@"GET"];
    }
    [self sendHttpRequest:request completionHandler:handler];
}

- (void) sendHttpPOSTRequest:(NSURL*)url jsonData:(NSData*)json
{
    [self sendHttpPOSTRequest:url jsonData:json completionHandler:nil];
}

- (void) sendHttpPOSTRequest:(NSURL*)url jsonData:(NSData*)json completionHandler:(void (^)(NSURLResponse*, NSData*, NSError*))handler
{
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLCacheStorageAllowed timeoutInterval:SWRVE_SEND_TIMEOUT_SECONDS];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:json];
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[json length]] forHTTPHeaderField:@"Content-Length"];
    
    [self sendHttpRequest:request completionHandler:handler];
}

- (void) sendHttpRequest:(NSMutableURLRequest*)request completionHandler:(void (^)(NSURLResponse*, NSData*, NSError*))handler
{
    // Add http request performance metrics for any previous requests into the header of this request (see JIRA SWRVE-5067 for more details)
    NSArray* allMetricsToSend;
    
    @synchronized([self httpPerformanceMetrics]) {
        allMetricsToSend = [[self httpPerformanceMetrics] copy];
        [[self httpPerformanceMetrics] removeAllObjects];
    }
    
    if (allMetricsToSend != nil && [allMetricsToSend count] > 0) {
        NSString* fullHeader = [allMetricsToSend componentsJoinedByString:@";"];
        [request addValue:fullHeader forHTTPHeaderField:@"Swrve-Latency-Metrics"];
    }
    
    SwrveConnectionDelegate* connectionDelegate = [[SwrveConnectionDelegate alloc] init:self completionHandler:handler];
    [NSURLConnection connectionWithRequest:request delegate:connectionDelegate];
}

- (void) addHttpPerformanceMetrics:(NSString*) metrics
{
    @synchronized([self httpPerformanceMetrics]) {
        [[self httpPerformanceMetrics] addObject:metrics];
    }
}

- (void) initBuffer
{
    self->eventBuffer = [[NSMutableArray alloc] initWithCapacity:SWRVE_MEMORY_QUEUE_INITIAL_SIZE];
    self->eventBufferBytes  = 0;
}

- (NSString*) createStringWithMD5:(NSString*)source
{
#define C "%02x"
#define CCCC C C C C
#define DIGEST_FORMAT CCCC CCCC CCCC CCCC
    
    NSString* digestFormat = [NSString stringWithFormat:@"%s", DIGEST_FORMAT];
    
    NSData* buffer = [source dataUsingEncoding:NSUTF8StringEncoding];

    unsigned char digest[CC_MD5_DIGEST_LENGTH] = {};
    unsigned int length = (unsigned int)[buffer length];
    CC_MD5_CTX context;
    CC_MD5_Init(&context);
    CC_MD5_Update(&context, [buffer bytes], length);
    CC_MD5_Final(digest, &context);

    NSString* result = [NSString stringWithFormat:digestFormat,
                            digest[ 0], digest[ 1], digest[ 2], digest[ 3],
                            digest[ 4], digest[ 5], digest[ 6], digest[ 7],
                            digest[ 8], digest[ 9], digest[10], digest[11],
                            digest[12], digest[13], digest[14], digest[15]];

    return result;
}

- (NSString*) createSessionToken
{
    // Get the time since the epoch in seconds
    struct timeval time; gettimeofday(&time, NULL);
    const long session_start = time.tv_sec;

    NSString* source = [NSString stringWithFormat:@"%@%ld%@", self.userID, session_start, self.apiKey];
    
    NSString* digest = [self createStringWithMD5:source];
    
    // $session_token = "$app_id=$user_id=$session_start=$md5_hash";
    NSString* session_token = [NSString stringWithFormat:@"%ld=%@=%ld=%@",
                                                         self.appID,
                                                         self.userID,
                                                         session_start,
                                                         digest];
    return session_token;
}

- (void)transactionComplete:(SKPaymentTransaction*)transaction forProduct:(SKProduct*)product {
    [self maybeFlushToDisk];
    NSString* transactionId  = [transaction transactionIdentifier];
    NSString* encodedReceipt = [self.config.receiptProvider base64EncodedReceiptForTransaction:transaction];

    if (!encodedReceipt) {
        NSLog(@"No transaction receipt could be obtained for %@", transactionId);
        return;
    }
    NSLog(@"Swrve building IAP event for transaction %@ (product %@)", transactionId, product.productIdentifier);

    // Fire a callback to the user allowing them to override the rewards that
    // are given to the user for this IAP.
    SwrveIAPRewards* rewards = [[SwrveIAPRewards alloc] init];
    self.config.transactionCompleteCallback(transaction, product, rewards);

    SKPayment*       payment   = [transaction payment];
    NSNumber*        quantity  = [NSNumber numberWithInteger:payment.quantity];
    NSDecimalNumber* localCost = product.price;
    NSMutableDictionary* json  = [[NSMutableDictionary alloc] init];
    NSString* localCurrency    = [product.priceLocale objectForKey:NSLocaleCurrencyCode];

    [json setValue:@"apple"                    forKey:@"app_store"];
    [json setValue:localCurrency               forKey:@"local_currency"];
    [json setValue:localCost                   forKey:@"cost"];
    [json setValue:[rewards rewards]           forKey:@"rewards"];
    [json setValue:encodedReceipt              forKey:@"receipt"];
    [json setValue:quantity                    forKey:@"quantity"];
    [json setValue:[payment productIdentifier] forKey:@"product_id"];

    BOOL iOS7 = SwrveSystemVersionGreaterThan(@"7.0");
    if (iOS7) {
        [json setValue:transactionId forKey:@"transaction_id"];
    }
    [self queueEvent:@"iap" data:json triggerCallback:true];

    // After IAP event we want to immediately flush the event buffer and update campaigns and resources if necessary
    if ([self.config autoDownloadCampaignsAndResources]) {
        [self checkForCampaignAndResourcesUpdates:nil];
    }
}

- (NSString*) getSignatureKey
{
    return [NSString stringWithFormat:@"%@%llu%@", self.apiKey, self->install_time, getIDFV()];
}

- (void)signatureError:(NSURL*)file
{
    NSLog(@"Signature check failed for file %@", file);
    [self event:@"Swrve.signature_invalid"];
}

- (void) initResourcesDiff
{
    // Create signature protected cache file
    NSURL* fileURL = [NSURL fileURLWithPath:self.config.userResourcesDiffCacheFile];
    NSURL* signatureURL = [NSURL fileURLWithPath:self.config.userResourcesDiffCacheSignatureFile];

    resourcesDiffFile = [[SwrveSignatureProtectedFile alloc] initFile:fileURL signatureFilename:signatureURL usingKey:[self getSignatureKey] signatureErrorListener:self];

    // Initialize in-memory cache
    resourcesDiffContent = [resourcesDiffFile readFromFile];
}

-(void) getUserResources:(SwrveUserResourcesCallback)callbackBlock
{
    NSCAssert(callbackBlock, @"getUserResources: callbackBlock must not be nil.");

    NSDictionary* resourcesDict = [[self resourceManager] getResources];
    NSMutableString* jsonString = [[NSMutableString alloc] initWithString:@"["];
    BOOL first = YES;
    for (NSString* resourceName in resourcesDict) {
        if (!first) {
            [jsonString appendString:@","];
        }
        first = NO;

        NSDictionary* resource = [resourcesDict objectForKey:resourceName];
        NSData* resourceData = [NSJSONSerialization dataWithJSONObject:resource options:0 error:nil];
        [jsonString appendString:[[NSString alloc] initWithData:resourceData encoding:NSUTF8StringEncoding]];
    }
    [jsonString appendString:@"]"];

    @try {
        callbackBlock(resourcesDict, jsonString);
    }
    @catch (NSException * e) {
        NSLog(@"Exception in getUserResources callback. %@", e);
    }
}

-(void) getUserResourcesDiff:(SwrveUserResourcesDiffCallback)callbackBlock
{
    NSCAssert(callbackBlock, @"getUserResourcesDiff: callbackBlock must not be nil.");

    NSURL* base_content_url = [NSURL URLWithString:self.config.contentServer];
    NSURL* resourcesDiffURL = [NSURL URLWithString:@"api/1/user_resources_diff" relativeToURL:base_content_url];
    NSString* queryString = [NSString stringWithFormat:@"user=%@&api_key=%@&app_version=%@&joined=%llu",
                             self.userID, self.apiKey, self.config.appVersion, self->install_time];
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"?%@", queryString] relativeToURL:resourcesDiffURL];

    [self sendHttpGETRequest:url completionHandler:^(NSURLResponse* response, NSData* data, NSError* error) {
        if (!error) {
            enum HttpStatus status = HTTP_SUCCESS;
            if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                status = [self getHttpStatus:(NSHTTPURLResponse*)response];
            }

            if (status == SWRVE_SUCCESS) {
                if ([self isValidJson:data]) {
                    resourcesDiffContent = data;
                    [resourcesDiffFile writeToFile:data];
                } else {
                    NSLog(@"Invalid JSON received for user resources diff");
                }
            }
        }

        // At this point the cached content has been updated with the http response if a valid response was received
        // So we can call the callbackBlock with the cached content
        @try {
            NSArray* resourcesArray = [NSJSONSerialization JSONObjectWithData:resourcesDiffContent options:NSJSONReadingMutableContainers error:nil];

            NSMutableDictionary* oldResourcesDict = [[NSMutableDictionary alloc] init];
            NSMutableDictionary* newResourcesDict = [[NSMutableDictionary alloc] init];

            for (NSDictionary* resourceObj in resourcesArray) {
                NSString* itemName = [resourceObj objectForKey:@"uid"];
                NSDictionary* itemDiff = [resourceObj objectForKey:@"diff"];

                NSMutableDictionary* oldValues = [[NSMutableDictionary alloc] init];
                NSMutableDictionary* newValues = [[NSMutableDictionary alloc] init];

                for (NSString* propertyKey in itemDiff) {
                    NSDictionary* propertyVals = [itemDiff objectForKey:propertyKey];
                    [oldValues setObject:[propertyVals objectForKey:@"old"] forKey:propertyKey];
                    [newValues setObject:[propertyVals objectForKey:@"new"] forKey:propertyKey];
                }

                [oldResourcesDict setObject:oldValues forKey:itemName];
                [newResourcesDict setObject:newValues forKey:itemName];
            }

            NSString* jsonString = [[NSString alloc] initWithData:resourcesDiffContent encoding:NSUTF8StringEncoding];
            callbackBlock(oldResourcesDict, newResourcesDict, jsonString);
        }
        @catch (NSException* e) {
            NSLog(@"Exception in getUserResourcesDiff callback. %@", e);
        }
    }];
}

- (void)TEST_activateTestBuffers
{
    _TEST_eventRequests = [[NSMutableArray alloc]init];
    _TEST_userResourceRequests = [[NSMutableArray alloc]init];
    _TEST_clickThruRequests = [[NSMutableArray alloc]init];
    _TEST_appLaunchRequests = [[NSMutableArray alloc]init];
    _TEST_eventResponses = [[NSMutableArray alloc]init];
    _TEST_userResourceResponses = [[NSMutableArray alloc]init];
    _TEST_talkCampaignRequests = [[NSMutableArray alloc]init];
    _TEST_talkCampaignResponses = [[NSMutableArray alloc]init];
    _TEST_talkQARequests = [[NSMutableArray alloc]init];
    _TEST_talkQAResponses = [[NSMutableArray alloc]init];
    _TEST_talkQALog = [[NSMutableArray alloc]init];
    _TEST_talkAssetsDownloading = [[NSMutableArray alloc]init];
}

- (void)TEST_resetTestBuffers
{
    [_TEST_eventRequests removeAllObjects];
    [_TEST_userResourceRequests removeAllObjects];
    [_TEST_clickThruRequests removeAllObjects];
    [_TEST_appLaunchRequests removeAllObjects];
    [_TEST_eventResponses removeAllObjects];
    [_TEST_userResourceResponses removeAllObjects];
    [_TEST_talkCampaignRequests removeAllObjects];
    [_TEST_talkCampaignResponses removeAllObjects];
    [_TEST_talkQARequests removeAllObjects];
    [_TEST_talkQAResponses removeAllObjects];
    [_TEST_talkQALog removeAllObjects];
    [_TEST_talkAssetsDownloading removeAllObjects];
}

- (NSArray*)TEST_getEventRequests
{
    return _TEST_eventRequests;
}

- (NSArray*)TEST_getUserResourceRequests
{
    return _TEST_userResourceRequests;
}

-(NSArray*) TEST_getClickThruRequests
{
    return _TEST_clickThruRequests;
}

-(NSArray*) TEST_getAppLaunchRequests
{
    return _TEST_appLaunchRequests;
}

-(NSArray*) TEST_getEventResponses
{
    return _TEST_eventResponses;
}

-(NSArray*) TEST_getUserResourceResponses
{
    return _TEST_userResourceResponses;
}

-(NSArray*) TEST_getTalkCampaignRequests
{
    return _TEST_talkCampaignRequests;
}

-(NSArray*) TEST_getTalkCampaignResponses
{
    return _TEST_talkCampaignResponses;
}

-(NSArray*)TEST_getTalkQARequests
{
    return _TEST_talkQARequests;
}

-(NSArray*)TEST_getTalkQAResponses
{
    return _TEST_talkQAResponses;
}

- (NSArray *)TEST_getTalkQALog
{
    return _TEST_talkQALog;
}

- (NSArray *) TEST_getTalkAssetsDownloading
{
    return _TEST_talkAssetsDownloading;
}

- (NSMutableArray*)TEST_getEventsBuffer
{
    return self->eventBuffer;
}

- (void)TEST_clearEventCacheFile
{
    self->eventStream = [self createLogfile:SWRVE_TRUNCATE_FILE];
}

- (NSString*)TEST_createSessionToken
{
    return [self createSessionToken];
}

- (void)TEST_updateResources:(NSArray*)resourceJson
{
    [[self resourceManager] setResourcesFromArray:resourceJson];

    NSData* resourceData = [NSJSONSerialization dataWithJSONObject:resourceJson options:0 error:nil];
    [resourcesFile writeToFile:resourceData];

    if ([self.config resourcesUpdatedCallback] != nil) {
        [self.config resourcesUpdatedCallback]();
    }
}

- (void)TEST_writeToResourcesFile:(NSData*)data
{
    [self->resourcesFile writeToFile:data];
}

- (void)TEST_writeToResourcesDiffFile:(NSData*)data
{
    self->resourcesDiffContent = data;
    [self->resourcesDiffFile writeToFile:data];
}

+ (void)TEST_destroySharedInstance
{
    if (_swrveSharedInstance) {
        [_swrveSharedInstance shutdown];
        _swrveSharedInstance = nil;
        
        sharedInstanceToken = 0;
    }
}

+ (NSString*)TEST_createBase64EncodingFromData:(NSData*)data
{
    return [data base64Encoding];
}

@end

// This connection delegate tracks performance metrics for each request (see JIRA SWRVE-5067 for more details)
@implementation SwrveConnectionDelegate

- (id)init:(Swrve*)swrve completionHandler:(ConnectionCompletionHandler)handler
{
    self = [super init];
    if (self) {
        [self setSwrve:swrve];
        [self setHandler:handler];
        [self setData:[[NSMutableData alloc] init]];
        [self setMetrics:[[NSMutableDictionary alloc] init]];
        [self setStartTime:[NSDate date]];
        [self setResponse:nil];
    }
    return self;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSDate* finishTime = [NSDate date];
    NSString* interval = [self getTimeIntervalFromStartAsString:finishTime];
    
    NSURL* requestURL = [[connection originalRequest] URL];
    NSString* baseURL = [NSString stringWithFormat:@"%@://%@", [requestURL scheme], [requestURL host]];
    
    NSString* metricsString = [NSString stringWithFormat:@"u=%@", baseURL];
    
    NSString* failedOn = @"c";
    if ([[self metrics] objectForKey:@"sb"]) {
        failedOn = @"rh";
        metricsString = [metricsString stringByAppendingString:[NSString stringWithFormat:@",sb=%@", [[self metrics] valueForKey:@"sb"]]];
    }
    metricsString = [metricsString stringByAppendingString:[NSString stringWithFormat:@",%@=%@,%@_error=1", failedOn, interval, failedOn]];
    
    [[self swrve] addHttpPerformanceMetrics:metricsString];
    
    if (self.handler) {
        self.handler([self response], [self data], error);
    }
}

- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
    NSDate* sendBodyTime = [NSDate date];
    NSString* interval = [self getTimeIntervalFromStartAsString:sendBodyTime];
    
    [[self metrics] setValue:interval forKey:@"c"];
    [[self metrics] setValue:interval forKey:@"sh"];
    [[self metrics] setValue:interval forKey:@"sb"];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSDate* responseTime = [NSDate date];
    NSString* interval = [self getTimeIntervalFromStartAsString:responseTime];
    [self setResponse:response];
    
    if (![[self metrics] objectForKey:@"sb"]) {
        [[self metrics] setValue:interval forKey:@"c"];
        [[self metrics] setValue:interval forKey:@"sh"];
        [[self metrics] setValue:interval forKey:@"sb"];
    }
    [[self metrics] setValue:interval forKey:@"rh"];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    // This might be called multiple times while data is being received
    NSDate* responseDateTime = [NSDate date];
    NSString* interval = [self getTimeIntervalFromStartAsString:responseDateTime];
    [[self data] appendData:data];
    
    if (![[self metrics] objectForKey:@"sb"]) {
        [[self metrics] setValue:interval forKey:@"c"];
        [[self metrics] setValue:interval forKey:@"sh"];
        [[self metrics] setValue:interval forKey:@"sb"];
    }
    if (![[self metrics] objectForKey:@"rh"]) {
        [[self metrics] setValue:interval forKey:@"rh"];
    }
    [[self metrics] setValue:interval forKey:@"rb"];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSDate* finishTime = [NSDate date];
    NSString* interval = [self getTimeIntervalFromStartAsString:finishTime];
    
    if (![[self metrics] objectForKey:@"sb"]) {
        [[self metrics] setValue:interval forKey:@"c"];
        [[self metrics] setValue:interval forKey:@"sh"];
        [[self metrics] setValue:interval forKey:@"sb"];
    }
    if (![[self metrics] objectForKey:@"rh"]) {
        [[self metrics] setValue:interval forKey:@"rh"];
    }
    if (![[self metrics] objectForKey:@"rb"]) {
        [[self metrics] setValue:interval forKey:@"rb"];
    }

    NSURL* requestURL = [[connection originalRequest] URL];
    NSString* baseURL = [NSString stringWithFormat:@"%@://%@", [requestURL scheme], [requestURL host]];
    
    NSString* metricsString = [NSString stringWithFormat:@"u=%@,c=%@,sh=%@,sb=%@,rh=%@,rb=%@",
                               baseURL,
                               [[self metrics] valueForKey:@"c"],
                               [[self metrics] valueForKey:@"sh"],
                               [[self metrics] valueForKey:@"sb"],
                               [[self metrics] valueForKey:@"rh"],
                               [[self metrics] valueForKey:@"rb"]];
    
    [[self swrve] addHttpPerformanceMetrics:metricsString];
    
    if (self.handler) {
        self.handler([self response], [self data], nil);
    }
}

- (NSString*) getTimeIntervalFromStartAsString:(NSDate*)date
{
    NSTimeInterval interval = [date timeIntervalSinceDate:[self startTime]];
    return [NSString stringWithFormat:@"%.0f", round(interval * 1000)];
}

@end
