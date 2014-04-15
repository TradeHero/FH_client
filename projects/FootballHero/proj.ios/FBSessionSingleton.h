//
//  abdf.h
//  FootballHero
//
//  Created by trdehero on 14-4-15.
//
//

#import <Foundation/Foundation.h>
#import <FacebookSDK/FacebookSDK.h>

@interface FBSessionSingleton : NSObject

+ (instancetype)sharedInstance;

@property (strong, nonatomic) FBSession * session;

@end
