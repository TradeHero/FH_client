//
//  FacebookConnector.h
//  FootballHero
//
//  Created by trdehero on 14-4-3.
//
//

#include <iostream>
#import <FacebookSDK/FacebookSDK.h>

class FacebookConnector
{
public:
    static FacebookConnector* getInstance();
    
    void login();
};
