//
//  FacebookConnector.h
//  FootballHero
//
//  Created by trdehero on 14-4-3.
//
//

class FacebookConnector
{
public:
    static FacebookConnector* getInstance();
    
    void initSession();
    void login();
};
