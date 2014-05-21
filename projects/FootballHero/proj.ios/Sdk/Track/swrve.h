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

#import <CoreFoundation/CFString.h>
#import <StoreKit/SKPaymentTransaction.h>
#import <StoreKit/SKPayment.h>
#import <StoreKit/SKProduct.h>
#import "SwrveTransactionCompleteListener.h"
#import "SwrveMessageController.h"
#import "SwrveInterfaceOrientation.h"
#import "SwrveReceiptProvider.h"
#import "SwrveResourceManager.h"
#import "SwrveSignatureProtectedFile.h"

/// The release version of this SDK.
#define SWRVE_SDK_VERSION "3.0"

/**
 * Result codes for swrve methods.
 */
enum
{
    /// Method executed successfully.
    SWRVE_SUCCESS = 0,
    
    /// Method did not execute successfully.
    SWRVE_FAILURE = -1
};

/**
 * Defines the block signature for receiving resouces after calling
 * Swrve getUserResources.
 *
 * @param resources         A dictionary containing the resources.
 * @param resourcesAsJSON   A string containing the resources as returned by the Swrve REST API.
 */
typedef void (^SwrveUserResourcesCallback) (NSDictionary* resources,
                                            NSString * resourcesAsJSON);

/**
 * Defines the block signature for receiving resouces after calling
 * Swrve getUserResourcesDiff.
 *
 * @param oldResourcesValues    A dictionary containing the old values of changed resources.
 * @param oldResourcesValues    A dictionary containing the new values of changed resources.
 * @param resourcesAsJSON       A string containing the resources diff as returned by the Swrve REST API.
 */
typedef void (^SwrveUserResourcesDiffCallback) (NSDictionary * oldResourcesValues,
                                                NSDictionary * newResourcesValues,
                                                NSString * resourcesAsJSON);

/**
 * Defines the block signature for notifications when an event is raised.
 * Typically, this is used by Swrve Talk internally.
 *
 * @param eventPayload          A dictionary containing the event payload.
 * @param eventsPayloadAsJSON   A string containing the event payload encoded as JSON.
 */
typedef void (^SwrveEventQueuedCallback) (NSDictionary * eventPayload,
                                          NSString * eventsPayloadAsJSON);

/**
 * SwrveIAPRewards contains additional IAP rewards that you want to send to Swrve.
 *
 * If the IAP represents a bundle containing a few reward items and/or
 * in-app currencies you can create create a SwrveIAPRewards object and call
 * addCurrency: and addItem: for each element contained in the bundle.
 * By including this when recording an iap event with Swrve we will be able to track
 * individual bundle items as well as the bundle purchase itself.
 */
@interface SwrveIAPRewards : NSObject

/**
 * Add a purchased item
 *
 * @param resourceName The name of the resource item with which the user was rewarded.
 * @param quantity The quantity purchased
 */
- (void) addItem:(NSString*) resourceName withQuantity:(long) quantity;

/**
 * Add an in-app currency purchase
 *
 * @param currencyName The name of the in-app currency with which the user was rewarded.
 * @param amount The amount of in-app currency with which the user was rewarded.
 */
- (void) addCurrency:(NSString*) currencyName withAmount:(long) amount;

- (NSDictionary*) rewards;

@end

/**
 */
typedef void (^SwrveTransactionCompleteCallback) (SKPaymentTransaction* transaction, SKProduct* product, SwrveIAPRewards* iapRewards);
typedef void (^SwrveResourcesUpdatedListener) ();

/**
 * Stores the configuration for a Swrve instance.
 */
@interface SwrveConfig : NSObject

/// The supported orientations of the app.
@property (nonatomic) SwrveInterfaceOrientation orientation;

/**
 * Specify the number of seconds to wait before considering a request as 'timed out'.
 * Typically a value between 5 and 20 seconds should suffice.
 */
@property (nonatomic) int httpTimeoutSeconds;

/**
 * Set to override the default location of the server to which Swrve will send analytics events.
 * If your company has a special API end-point enabled, then you should specify that here.
 * You should only need to change this value if you are working with Swrve support on a specific support issue.
 */
@property (nonatomic) NSString * eventsServer;

/**
 * Set to override the default location of the server from which Swrve will receive personalized content.
 * If your company has a special API end-point enabled, then you should specify that here.
 * You should only need to change this value if you are working with Swrve support on a specific support issue.
 */
@property (nonatomic) NSString * contentServer;

/**
 * Set to override the default location of the server that Swrve uses to link users across multiple apps by the same publisher.
 * If your company has a special API end-point enabled, then you should specify
 * that here. You should only need to change this value if you are working with Swrve
 * support on a specific support issue.
 */
@property (nonatomic) NSString * linkServer;

/**
 * Swrve will read the language from the current device using the [NSLocale preferredLanguages] API.
 * If your app has a custom mechanism to allow users to change their language, then you should set this property.
 * The language value here should be a valid IETF language tag.
 * See http://en.wikipedia.org/wiki/IETF_language_tag .
 *
 * Typical values are codes such as en_US, en_GB or fr_FR. If you are planning
 * on using this feature, or you are participating in the Swrve Talk beta
 * program then you should contact the Swrve team (support@swrve.com) and let
 * them know about your plans.
 */
@property (nonatomic) NSString * language;

/**
 * The events cache stores analytics data that has not yet been sent to Swrve.
 * The default value will be correct in most cases. If you plan
 * to change this please contant the team at Swrve who will be happy to help you out.
 * This path should be located in app/Libraries/Caches/, as this is where Apple
 * recommend that persistent data should be stored. http://bit.ly/nCe9Zy
 */
@property (nonatomic) NSString * eventCacheFile;

/**
 * Store signature to verify content of eventCacheFile
 */
@property (nonatomic) NSString * eventCacheSignatureFile;

/**
 * The user resources cache stores the result of calls to Swrve getUserResources
 * so that the results can be used when the device is offline.
 * The default value will be correct in most cases. If you plan
 * to change this please contant the team at Swrve who will be happy to help you out.
 * This path should be located in app/Libraries/Caches/, as this is where Apple
 * recommend that persistent data should be stored. http://bit.ly/nCe9Zy
 */
@property (nonatomic) NSString * userResourcesCacheFile;

/**
 * Store signature to verify content of userResourcesCacheFile
 */
@property (nonatomic) NSString * userResourcesCacheSignatureFile;

/**
 * The user resources diff cache stores the result of calls to Swrve getUserResourcesDiff
 * so that the results can be used when the device is offline.
 * The default value will be correct in most cases. If you plan
 * to change this please contant the team at Swrve who will be happy to help you out.
 * This path should be located in app/Libraries/Caches/, as this is where Apple
 * recommend that persistent data should be stored. http://bit.ly/nCe9Zy
 */
@property (nonatomic) NSString * userResourcesDiffCacheFile;

/**
 * Store signature to verify content of userResourcesDiffCacheFile
 */
@property (nonatomic) NSString * userResourcesDiffCacheSignatureFile;

/**
 * The install-time cache caches the time that the user first installed the
 * app.
 * The default value will be correct in most cases. If you plan
 * to change this please contant the team at Swrve who will be happy to help you out.
 * This path should be located in app/Libraries/Caches/, as this is where Apple
 * recommend that persistent data should be stored. http://bit.ly/nCe9Zy
 */
@property (nonatomic) NSString * installTimeCacheFile;


/**
 * By default Swrve will read the application version from the current
 * application bundle. This is used to allow you to test and target users with a
 * particular application version.
 * If you use a different application versioning system than you can specify
 * this here. If you are doing this please contact the Swrve team.
 */
@property (nonatomic) NSString * appVersion;

/**
 * Internal Only.
 * The receipt provider is to get a base64 encoded string of the receipt associated
 * with a StoreKit SKPaymentTransaction.
 * This is exposed to the config object to allow dependancy injection for testing
 * in isolation and for mocking.
 */
@property (nonatomic, retain) SwrveReceiptProvider* receiptProvider;

/**
 * The linkToken is used by Swrve to identify users between a publisher's set of
 * apps on a device. This value must be unique for users, but should be consistent
 * across apps on a given device. The value must be a canonical UUID, for example :
 * 5B093A97-43D1-4478-B14B-2EA2369806E6.
 * On iOS6+, the default value is Apple's IDFV.
 * If your app must support linking on iOS5, then Swrve recommends using SecureUDID.
 */
@property (nonatomic) NSString * linkToken;

/**
 * The maximum number of simultaneous asset downloads for Swrve Talk messages.
 * The default value is 2.
 */
@property (nonatomic) int maxConcurrentDownloads;


/**
 * Controls if Swrve Talk campaigns are automatically downloaded.
 * The default value is YES.
 */
@property (nonatomic) BOOL autoDownloadCampaignsAndResources;

/**
 * Controls if Swrve Talk is enabled.
 * The default value is NO.
 */
@property (nonatomic) BOOL talkEnabled;

/**
 * A callback that allows the game to specify any extra rewards the user was
 * given for an IAP.
 *
 * If the user purchased a bundle of virtual items in an IAP, then this callback
 * allows the developer to add that information to the IAP data that will be sent
 * to Swrve.
 *
 * config.transactionCompleteCallback = ^(SKPaymentTransaction* transaction, SKProduct* product, SwrveIAPRewards* iapRewards) {
 *   if ([[product productIdentifier] isEqualToString:@"com.swrve.bundle4"]) {
 *     [rewards addItem:@"hammer" withQuantity:7];
 *     [rewards addItem:@"shield" withQuantity:13];
 *     [rewards addCurrency:@"gold" withAmount:100];
 *   }
 * }
 *
 */
@property (nonatomic, copy) SwrveTransactionCompleteCallback transactionCompleteCallback;

/**
 * A callback to get notified when user resources have been updated.
 *
 * If config.autoDownloadCampaignsAndResources is YES (default) user resources will be kept up to date automatically
 * and this listener will be called whenever there has been a change.
 * Instead of using the listener, you could use the SwrveResourceManager ([swrve getResourceManager]) to get
 * the latest value for each attribute at the time you need it. Resources and attributes in the resourceManager
 * are kept up to date.
 *
 * When config.autoDownloadCampaignsAndResources is NO resources will not be kept up to date, and you will have
 * to manually call refreshCampaignsAndResources - which will call this listener on completion.
 *
 * This listener does not have any argument, use the resourceManager to get the updated resources
 */

@property (nonatomic, copy) SwrveResourcesUpdatedListener resourcesUpdatedCallback;

/**
 * A set of event names used to automatically show messages.  If a message
 * has one of these events as a trigger the message is automatically shown
 * immediately after it is downloaded.
 * The default value is [@"Swrve.Messages.campaigns_downloaded"].
 */
@property (nonatomic, retain) NSSet* autoShowMessageAfterDownloadEventNames;

/**
 * Controls if Swrve sendEvents: is automatically called when the app resumes
 * in the foreground.
 * The default value is YES.
 */
@property (nonatomic) BOOL autoSendEventsOnResume;

/**
 * Controls if Swrve saveEvents: is automatically called when the app resigns to the background.
 * The default value is YES.
 */
@property (nonatomic) BOOL autoSaveEventsOnResign;

/**
 * Controls if push notifications are enabled.
 * The default value is NO.
 */
@property (nonatomic) BOOL pushEnabled;

/**
 * The set of Swrve events that will trigger push notifications.
 * The default value is [@s"Swrve.session.start"].
 */
@property (nonatomic, retain) NSSet* pushNotificationEvents;

/**
 * Controls if the SDK automatically collects the push device token.  To
 * manually set the device token yourself set to NO.
 * The default value is YES.
 */
@property (nonatomic) BOOL autoCollectDeviceToken;

/**
 * If set, the SDK will register an observer for StoreKit IAPs and automatically
 * report on revenue generated.
 * Default true.
 */
@property (nonatomic) BOOL reportInAppPurchases;

/**
 * Used for testing. Please do not use this property. The default is NO.
 */
@property (nonatomic) BOOL testBuffersActivated;

@end

/**
 *
 * Holds all state necessary to communicate with Swrve.
 *
 * The Swrve iOS API mirrors the Swrve REST API. Before using the iOS API you
 * should read the documentation for the REST API. This is located at
 * http://dashboard.swrve.com/help
 *
 */
@interface Swrve : NSObject<SwrveTransactionCompleteListener,SwrveSignatureErrorListener>

#pragma mark -
#pragma mark Singleton

/**
 * Accesses a single shared instance of a Swrve object.
 *
 * @return A singleton instance of a Swrve object.
 *         This will be nil until one of the sharedInstanceWith... methods is called.
 */
+(Swrve*) sharedInstance;

/**
 * Creates and initializes the shared Swrve singleton.
 *
 * On iOS6+ the user ID is set to Apple's IdentifierForVendor, on iOS5 or less
 * the user ID is set to a UUID.  In both cases the userID is cached in the
 * default settings of the app and recalled the next time you initialize the
 * app. This means the ID for the user will stay consistent for as long as the
 * user has your app installed on the device.
 *
 * @param swrveAppID The App ID for your app supplied by Swrve.
 * @param swrveAPIKey The secret token for your app supplied by Swrve.
 * @return An initialized Swrve object.
 */
+(Swrve*) sharedInstanceWithAppID:(int)swrveAppID apiKey:(NSString*)swrveAPIKey;

/**
 * Creates and initializes the shared Swrve singleton.
 * The userID is used by Swrve to identify unique users. It must be unique for all users
 * of your app. On iOS6+, Swrve recommends using Apple's IdentifierForVendor.
 * On iOS5, Swrve recommends using SecureUDID.
 *
 * @param swrveAppID The App ID for your app supplied by Swrve.
 * @param swrveAPIKey The secret token for your app supplied by Swrve.
 * @param swrveUserID The unique user id for your application.
 * @return An initialized Swrve object.
 */
+(Swrve*) sharedInstanceWithAppID:(int)swrveAppID apiKey:(NSString*)swrveAPIKey userID:(NSString*)swrveUserID;


/**
 * Creates and initializes the shared Swrve singleton.
 *
 * Takes a SwrveConfig object that can be used to change default settings.
 * The userID is used by Swrve to identify unique users. It must be unique for all users
 * of your app. On iOS6+, Swrve recommends using Apple's IdentifierForVendor.
 * On iOS5, Swrve recommends using SecureUDID.
 *
 * @param swrveAppID The App ID for your app supplied by Swrve.
 * @param swrveAPIKey The secret token for your app supplied by Swrve.
 * @param swrveConfig The swrve configuration object used to override default settings.
 * @param swrveUserID The unique user id for your application.
 * @return An initialized Swrve object.
 */
+(Swrve*) sharedInstanceWithAppID:(int)swrveAppID apiKey:(NSString*)swrveAPIKey userID:(NSString*)swrveUserID config:(SwrveConfig*)swrveConfig;


#pragma mark -
#pragma mark Initialization

/**
 * Initializes a Swrve object that has already been allocated using [Swrve alloc].
 *
 * On iOS6+ the user ID is set to Apple's IdentifierForVendor, on iOS5 or less 
 * the user ID is set to a UUID.  In both cases the userID is cached in the 
 * default settings of the app and recalled the next time you initialize the
 * app. This means the ID for the user will stay consistent for as long as the
 * user has your app installed on the device.
 *
 * @param swrveAppID The App ID for your app supplied by Swrve.
 * @param swrveAPIKey The secret token for your app supplied by Swrve.
 * @return An initialized Swrve object.
 */
-(id) initWithAppID:(int)swrveAppID apiKey:(NSString*)swrveAPIKey;

/**
 * Initializes a Swrve object that has already been allocated using [Swrve alloc].
 *
 * The userID is used by Swrve to identify unique users. It must be unique for all users
 * of your app. On iOS6+, Swrve recommends using Apple's IdentifierForVendor.
 * On iOS5, Swrve recommends using SecureUDID.
 *
 * @param swrveAppID The App ID for your app supplied by Swrve.
 * @param swrveAPIKey The secret token for your app supplied by Swrve.
 * @param swrveUserID The unique user id for your application.
 * @return An initialized Swrve object.
 */
-(id) initWithAppID:(int)swrveAppID apiKey:(NSString*)swrveAPIKey userID:(NSString*)swrveUserID;


/**
 * Initializes a Swrve object that has already been allocated using [Swrve alloc].
 *
 * Takes a SwrveConfig object that can be used to change default settings.
 * The userID is used by Swrve to identify unique users. It must be unique for all users
 * of your app. On iOS6+, Swrve recommends using Apple's IdentifierForVendor.
 * On iOS5, Swrve recommends using SecureUDID.
 *
 * @param swrveAppID The App ID for your app supplied by Swrve.
 * @param swrveAPIKey The secret token for your app supplied by Swrve.
 * @param swrveUserID The unique user id for your application.
 * @param swrveConfig The swrve configuration object used to override default settings.
 * @return An initialized Swrve object.
 */
-(id) initWithAppID:(int)swrveAppID apiKey:(NSString*)swrveAPIKey userID:(NSString*)swrveUserID config:(SwrveConfig*)swrveConfig;


#pragma mark -
#pragma mark Events


/**
 * Call this when an in-app item is purchased.
 * The currency specified must be one of the currencies known to Swrve that are
 * specified on the Swrve dashboard.
 * See the REST API docs for the purchase event for a detailed description of the
 * semantics of this call.
 *
 * @param itemName The UID of the item being purchased.
 * @param itemCurrency The name of the currency used to purchase the item.
 * @param itemCost The per-item cost of the item being purchased.
 * @param itemQuantity The quantity of the item being purchased.
 * @return SWRVE_SUCCESS if the call was successful, otherwise SWRVE_ERROR.
 *
 */
-(int) purchaseItem:(NSString*)itemName currency:(NSString*)itemCurrency cost:(int)itemCost quantity:(int)itemQuantity;

/**
 * Call this to send a named custom event with no payload.
 *
 * @param eventName The quantity of the item being purchased.
 * @return SWRVE_SUCCESS if the call was successful, otherwise SWRVE_ERROR.
 */
-(int) event:(NSString*)eventName;

/**
 * Call this to send a named custom event with no payload.
 *
 * @param eventName The quantity of the item being purchased.
 * @param eventPayload The payload to be sent with this event.
 * @return SWRVE_SUCCESS if the call was successful, otherwise SWRVE_ERROR.
 */
-(int) event:(NSString*)eventName payload:(NSDictionary*)eventPayload;


/**
 * Call this when the user has been gifted in-app currency by the app itself.
 * See the REST API docs for the currency_given event for a detailed
 * description of the semantics of this call.
 *
 * @param givenCurrency The name of the in-app currency that the player was
 * rewarded with.
 * @param givenAmount The amount of virtual currency that the player was
 * rewarded with.
 * @return SWRVE_SUCCESS if the call was successful, otherwise SWRVE_ERROR.
 */
-(int) currencyGiven:(NSString*)givenCurrency givenAmount:(double)givenAmount;

/**
 * Sends the user state to Swrve.
 * See the REST API docs for the user event for a detailed description of the
 * semantics of this call.
 *
 * @param attributes The attributes to be set for the user.
 * @return SWRVE_SUCCESS if the call was successful, otherwise SWRVE_ERROR.
 */
-(int) userUpdate:(NSDictionary*)attributes;

#pragma mark -
#pragma mark User Resources

/*
 * If SwrveConfig.autoDownloadCampaignsAndResources is true (default value) this function is called
 * automatically to keep the user resources and campaign data up to date.
 *
 * Use the resourceManager to get the latest up-to-date values for the resources.
 *
 * If SwrveConfig.autoDownloadCampaignsAndResources is set to false, please call this function to update
 * values. This function issues an asynchronous HTTP request to the Swrve ABTest server
 * specified in SwrveConfig. This function will return immediately, and the
 * callback will be fired after the Swrve server has sent its response. At this point
 * the resourceManager can be used to retrieve the updated resource values.
 *
 * @param callback A callback block that will be called asynchronously when user
 * resources and campaigns have been updated.
 */

-(void) refreshCampaignsAndResources;

/**
 * Use the resource manager to retrieve the most up-to-date attribute
 * values at any time.
 */
-(SwrveResourceManager*) getSwrveResourceManager;

/**
 * Gets a list of resources for a user including modifications from active
 * A/B tests.  Please refer to our online documentation for more details:
 *
 * http://dashboard.swrve.com/help/docs/abtest_api#GetUserResources
 *
 * This function issues an asynchronous HTTP request to the Swrve AB-Test server
 * specified in SwrveConfig. This function will return immediately, and the
 * callback will be fired at some unspecified time in the future. The callback
 * will be fired after the Swrve server has sent some AB-Test modifications to
 * the SDK, or if the HTTP request fails (when the iOS device is offline or has
 * limited connectivity.
 *
 * The result of this call is cached in the userResourcesCacheFile specified in
 * SwrveConfig. This file is initially seeded with "[]", the empty JSON array.
 *
 * @param callbackBlock A callback block that will be called asynchronously when
 * a/b test data is available.
 */
-(void) getUserResources:(SwrveUserResourcesCallback)callbackBlock;

/**
 * Gets a list of resource differences that should be applied to items for the .
 * given user based on the A/B test the user is involved in.  Please refer to
 * our online documentation for more details:
 *
 * http://dashboard.swrve.com/help/docs/abtest_api#GetUserResourcesDiff
 *
 * This function issues an asynchronous HTTP request to the Serve AB-Test server
 * specified in #swrve_init. This function will return immediately, and the
 * callback will be fired at some unspecified time in the future. The callback
 * will be fired after the Swrve server has sent some AB-Test modifications to
 * the SDK, or if the HTTP request fails (when the iOS device is offline or has
 * limited connectivity.
 *
 * The resulting AB-Test data is cached in the userResourcesDiffCacheFile specified in
 * SwrveConfig. This file is initially seeded with "[]", the empty JSON array.
 *
 * @param callbackBlock A callback block that will be called asynchronously when
 * a/b test data is available.
 */
-(void) getUserResourcesDiff:(SwrveUserResourcesDiffCallback)callbackBlock;

#pragma mark -
#pragma mark Other

/**
 This method is used by Swrve Talk to track cross promotional installs.
 */
-(void) clickThruForTargetGame:(long)targetApp source:(NSString*)source;


/**
 * Sends all events that are queued to the Swrve servers.
 * If any events cannot be send they will be re-queued and sent again later.
 */
-(void) sendQueuedEvents;

/**
 * Saves events stored in the in-memory queue to disk.
 * After calling this function, the in-memory queue will be empty.
 */
-(void) saveEventsToDisk;

/**
 * Sets the event queue callback.  If set, the callback block will be called each
 * an event is queued with the SDK.
 */
-(void) setEventQueuedCallback:(SwrveEventQueuedCallback)callbackBlock;

/**
 * Similar to #event:payload: except the callback block will not be called when the event is queued.
 */
-(int) eventWithNoCallback:(NSString*)eventName payload:(NSDictionary*)eventPayload;

/**
 * Releases all resources used by the Swrve object.
 * Typically, this should only be called if you are managing multiple Swrve instances.
 * Once called, it is not safe to call any methods on the Swrve object.
 */
-(void) shutdown;

#pragma mark -
#pragma mark Properties

/// The configuration settings for this Swrve object.
@property (readonly,strong) SwrveConfig * config;

/// The App ID used to initialize this Swrve object.
@property (readonly) long appID;

/// The secret token used to initialize this Swrve object.
@property (readonly) NSString * apiKey;

// The User ID used to initialize this Swrve object.
@property (readonly) NSString * userID;

/// Information about the current device.
@property (readonly) NSDictionary * deviceInfo;

/// The Swrve Talk component
@property (readonly) SwrveMessageController * talk;

// The resourceManager can be queried for up-to-date resource attribute values
@property (readonly) SwrveResourceManager * resourceManager;

@end


/**
 * Return the device bounds in pixels, taking into account the scale.
 */
CGRect get_device_screen_bounds();


