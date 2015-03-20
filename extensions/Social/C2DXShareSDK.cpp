//
//  C2DXShareSDK.cpp
//  C2DXShareSDKSample
//
//  Created by 冯 鸿杰 on 13-12-17.
//
//
#include "CCLuaEngine.h"
#include "C2DXShareSDK.h"

#if CC_TARGET_PLATFORM == CC_PLATFORM_IOS

#include "C2DXiOSShareSDK.h"

#elif CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID

#include "ShareSDKUtils.h"

#endif


USING_NS_CC;
using namespace cn::sharesdk;

static int mAuthorizeHandler;
static int mShareHandler;

void C2DXShareSDK::open(CCString *appKey, bool useAppTrusteeship)
{
#if CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID
    
    //TODO: Andorid
    initShareSDK(appKey->getCString(), useAppTrusteeship);
    
    
#elif CC_TARGET_PLATFORM == CC_PLATFORM_IOS
    
    //TODO: iOS
    C2DXiOSShareSDK::open(appKey, useAppTrusteeship);
    
#endif
}

void C2DXShareSDK::close()
{
#if CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID
    
    //TODO: Andorid
    stopSDK();
    
#elif CC_TARGET_PLATFORM == CC_PLATFORM_IOS
    
    //TODO: iOS
    C2DXiOSShareSDK::close();
    
#endif
}

void C2DXShareSDK::setPlatformConfig(C2DXPlatType platType, CCDictionary *configInfo)
{
#if CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID
    
    //TODO: Andorid
    // This is not a necessary method for Android, you can setup your platform configs more efficiently in "assets/ShareSDK.xml"
    // setPlatformDevInfo((int)platType, configInfo);
    
#elif CC_TARGET_PLATFORM == CC_PLATFORM_IOS
    
    //TODO: iOS
    C2DXiOSShareSDK::setPlatformConfig(platType, configInfo);
    
#endif
}

void C2DXShareSDK::authorizeHandler(C2DXResponseState state, C2DXPlatType platType, CCDictionary *error, const char* accessToken)
{
    bool success = false;
    switch (state) {
        case C2DXResponseStateSuccess:
        {
            success = true;
            break;
        }
        case C2DXResponseStateFail:
        {
            success = false;
            break;
        }
        case C2DXResponseStateBegin:
        {
            return;
        }
        case C2DXResponseStateCancel:
        {
            success = false;
            break;
        }
        default:
            break;
    }
    
    if (mAuthorizeHandler == 0)
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
    pStack->pushInt(platType);
    pStack->pushString(accessToken);
    int ret = pStack->executeFunctionByHandler(mAuthorizeHandler, 3);
    pStack->clean();
    
    mAuthorizeHandler = 0;
}

void C2DXShareSDK::authorize(C2DXPlatType platType, int handler)
{
    mAuthorizeHandler = handler;
    
#if CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID
    
    //TODO: Andorid
    doAuthorize((int)platType, callback);
    
#elif CC_TARGET_PLATFORM == CC_PLATFORM_IOS
    
    //TODO: iOS
    C2DXiOSShareSDK::authorize(platType, authorizeHandler);
    
#endif
}



void C2DXShareSDK::cancelAuthorize(C2DXPlatType platType)
{
#if CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID
    
    //TODO: Andorid
    removeAccount((int)platType);
    
#elif CC_TARGET_PLATFORM == CC_PLATFORM_IOS
    
    //TODO: iOS
    C2DXiOSShareSDK::cancelAuthorize(platType);
    
#endif
}

bool C2DXShareSDK::hasAutorized(C2DXPlatType platType, int handler)
{
    bool result = false;
#if CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID
    
    //TODO: Andorid
    result = isValid((int)platType);
    
#elif CC_TARGET_PLATFORM == CC_PLATFORM_IOS
    
    //TODO: iOS
    result = C2DXiOSShareSDK::hasAutorized(platType);
    
#endif
    
    CCScriptEngineProtocol* pScriptProtocol = CCScriptEngineManager::sharedManager()->getScriptEngine();
    cocos2d::CCLuaEngine* pLuaEngine = dynamic_cast<CCLuaEngine*>(pScriptProtocol);
    if (pLuaEngine == NULL)
    {
        assert(false);
        return false;
    }
    
    CCLuaStack* pStack = pLuaEngine->getLuaStack();
    pStack->pushBoolean(result);
    pStack->pushInt(platType);
    int ret = pStack->executeFunctionByHandler(handler, 2);
    pStack->clean();
    
    return result;
}

void C2DXShareSDK::getUserInfo(C2DXPlatType platType, C2DXGetUserInfoResultEvent callback)
{
#if CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID
    
    //TODO: Andorid
    showUser((int)platType, callback);
#elif CC_TARGET_PLATFORM == CC_PLATFORM_IOS
    
    //TODO: iOS
    C2DXiOSShareSDK::getUserInfo(platType, callback);
    
#endif
}

void C2DXShareSDK::shareContent(C2DXPlatType platType, CCDictionary *content, C2DXShareResultEvent callback)
{
#if CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID
    
    //TODO: Andorid
    doShare((int)platType, content, callback);
    
#elif CC_TARGET_PLATFORM == CC_PLATFORM_IOS
    
    //TODO: iOS
    C2DXiOSShareSDK::shareContent(platType, content, callback);
    
#endif
}

void C2DXShareSDK::oneKeyShareContent(CCArray *platTypes, CCDictionary *content, C2DXShareResultEvent callback)
{
#if CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID
    
    //TODO: Andorid
    multiShare(platTypes, content, callback);
    
#elif CC_TARGET_PLATFORM == CC_PLATFORM_IOS
    
    //TODO: iOS
    C2DXiOSShareSDK::oneKeyShareContent(platTypes, content, callback);
    
#endif
}

void C2DXShareSDK::shareResultHandler(C2DXResponseState state, C2DXPlatType platType, CCDictionary *shareInfo, CCDictionary *error)
{
    bool success = false;
    switch (state) {
        case C2DXResponseStateSuccess:
        {
            success = true;
            break;
        }
        case C2DXResponseStateFail:
        {
            success = false;
            break;
        }
        case C2DXResponseStateBegin:
        {
            return;
        }
        case C2DXResponseStateCancel:
        {
            success = false;
            break;
        }
        default:
            break;
    }
    
    if (mShareHandler == 0)
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
    pStack->pushInt(platType);
    int ret = pStack->executeFunctionByHandler(mShareHandler, 2);
    pStack->clean();
    
    mShareHandler = 0;
}

void C2DXShareSDK::showShareMenu(CCArray *platTypes, CCDictionary *content, int handler)
{
    mShareHandler = handler;
#if CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID
    
    //TODO: Andorid
    onekeyShare(0, content, callback);
    
#elif CC_TARGET_PLATFORM == CC_PLATFORM_IOS
    
    //TODO: iOS
    C2DXiOSShareSDK::showShareMenu(platTypes, content, shareResultHandler);
    
#endif
}

void C2DXShareSDK::showShareMenu(CCArray *platTypes, CCDictionary *content, CCPoint pt, C2DXMenuArrowDirection direction, C2DXShareResultEvent callback)
{
#if CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID
    
    //TODO: Android
    showShareMenu(0, content, callback);
    
#elif CC_TARGET_PLATFORM == CC_PLATFORM_IOS
    
    //TODO: iOS
    C2DXiOSShareSDK::showShareMenu(platTypes, content, pt, direction, callback);
    
#endif
}

void C2DXShareSDK::showShareView(C2DXPlatType platType, CCDictionary *content, C2DXShareResultEvent callback)
{
#if CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID
    
    //TODO: Android
    onekeyShare((int) platType, content, callback);
    
#elif CC_TARGET_PLATFORM == CC_PLATFORM_IOS
    
    //TODO: iOS
    C2DXiOSShareSDK::showShareView(platType, content, callback);
    
#endif
}

void C2DXShareSDK::getCredentialWithType(C2DXPlatType platType, int handler)
{
    const char* result = NULL;
#if CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID
    
    //TODO: Android
    
#elif CC_TARGET_PLATFORM == CC_PLATFORM_IOS
    
    //TODO: iOS
    result = C2DXiOSShareSDK::getCredentialWithType(platType);
    
#endif
    
    CCScriptEngineProtocol* pScriptProtocol = CCScriptEngineManager::sharedManager()->getScriptEngine();
    cocos2d::CCLuaEngine* pLuaEngine = dynamic_cast<CCLuaEngine*>(pScriptProtocol);
    if (pLuaEngine == NULL)
    {
        assert(false);
        return;
    }
    
    CCLuaStack* pStack = pLuaEngine->getLuaStack();
    if (result)
    {
        pStack->pushInt(platType);
    }
    else
    {
        pStack->pushNil();
    }
    int ret = pStack->executeFunctionByHandler(handler, 1);
    pStack->clean();
}
