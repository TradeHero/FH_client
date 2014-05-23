

#import <Foundation/Foundation.h>
#import <FacebookSDK/FacebookSDK.h>

@interface FBSessionSingleton : NSObject

+ (instancetype)sharedInstance;

@property (strong, nonatomic) FBSession * session;

@end
