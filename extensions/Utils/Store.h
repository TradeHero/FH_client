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
        
        void requestProducts(int handler);
        void requestProductResult(bool success);
        void buy(int level, int handler);
        void buyResult(bool success);
        
    protected:
        Store();
    private:
        int mRequestProductHandler;
        int mPaymentHandler;
    };
};

#endif /* defined(__FootballHero__Store__) */
