//
//  Store.h
//  FootballHero
//
//  Created by SpiritRain on 15/11/3.
//
//

#ifndef __FootballHero__Store__
#define __FootballHero__Store__
#include "cocos2d.h"

namespace Utils
{
    class Store
    {
    public:
        ~Store();
        static Store* sharedDelegate();
        
        void requestProducts(const char* ids, int handler);
        void requestProductResult(const char* result,bool success);
        void buy(const char* id, int handler);
        void buyResult(bool success);
        
    protected:
        Store();
    private:
        int mRequestProductHandler;
        int mPaymentHandler;
    };
};

#endif /* defined(__FootballHero__Store__) */
