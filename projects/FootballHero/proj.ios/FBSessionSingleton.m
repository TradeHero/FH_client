//
//  abdf.m
//  FootballHero
//
//  Created by trdehero on 14-4-15.
//
//

#import "FBSessionSingleton.h"

@implementation FBSessionSingleton

+ (instancetype)sharedInstance
{
    static FBSessionSingleton * instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[FBSessionSingleton alloc] init];
    });
    return instance;
}

- (FBSession *)session
{
    if (!_session) {
        _session = [[FBSession alloc] init];
    }
    
    return _session;
}

@end
