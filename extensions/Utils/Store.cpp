//
//  Store.cpp
//  FootballHero
//
//  Created by SpiritRain on 15/11/3.
//
//

#include "cocos2d.h"
#include "CCLuaEngine.h"

USING_NS_CC;

#include "Store.h"

#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
#include "StoreHandler.h"
#endif
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
#include "StoreAndroid.h"
#endif

namespace Utils
{
    static Store* s_sharedUtils;
    
    Store::Store()
    {
        
    }
    
    Store::~Store()
    {
        
    }
    
    Store* Store::sharedDelegate()
    {
        if (s_sharedUtils == NULL)
        {
            s_sharedUtils = new Store();
        }
        return s_sharedUtils;
    }
    
    
    void Store::requestProducts(const char* ids, int handler){
        mRequestProductHandler = handler;
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
        StoreHandler::getInstance()->requestProductPrice(ids);
#endif
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
        android_requestProducts(ids);
#endif
    }
    
    void Store::requestProductResult(const char* result, bool success)
    {
        if (!success) {
            return;
        }
        
        if (mRequestProductHandler == 0)
        {
            return;
        }
        
        CCScriptEngineProtocol* pScriptProtocol = CCScriptEngineManager::sharedManager()->getScriptEngine();
        cocos2d::CCLuaEngine* pLuaEngine = dynamic_cast<CCLuaEngine*>(pScriptProtocol);
        if (pLuaEngine == NULL)
        {
            assert(false);
            return;
        }
        
        CCLuaStack* pStack = pLuaEngine->getLuaStack();
        pStack->pushString(result);
        pStack->executeFunctionByHandler(mRequestProductHandler, 1);
        pStack->clean();
        
        mRequestProductHandler = 0;
    }
    
    void Store::buy(const char* id, int handler){
        mPaymentHandler = handler;
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
        StoreHandler::getInstance()->buy(id);
#endif
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
        android_buy(id);
#endif
    }
    
    void Store::buyResult(bool success)
    {
        if (mPaymentHandler == 0)
        {
            return;
        }
        
        CCScriptEngineProtocol* pScriptProtocol = CCScriptEngineManager::sharedManager()->getScriptEngine();
        cocos2d::CCLuaEngine* pLuaEngine = dynamic_cast<CCLuaEngine*>(pScriptProtocol);
        if (pLuaEngine == NULL)
        {
            assert(false);
            return;
        }
        
        CCLuaStack* pStack = pLuaEngine->getLuaStack();
        pStack->pushBoolean(success);
        pStack->executeFunctionByHandler(mPaymentHandler, 1);
        pStack->clean();
        
        mPaymentHandler = 0;
    }
}