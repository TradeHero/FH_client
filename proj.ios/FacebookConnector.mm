//
//  FacebookConnector.cpp
//  FootballHero
//
//  Created by trdehero on 14-4-3.
//
//

#include "FacebookConnector.h"

static FacebookConnector* instance;

FacebookConnector* getInstance()
{
    if (instance == NULL)
    {
        instance = new FacebookConnector();
    }
    return instance;
}

void login()
{
    
}