#include "cocos2d.h"
#include "ShareSDKDelegate.h"
#include "CCLuaEngine.h"
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
#include "ShareSDKConnector.h"
#endif
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
#include "FacebookAndroid.h"
#endif

USING_NS_CC;

namespace Social
{
	static ShareSDKDelegate* s_sharedUtils;

	ShareSDKDelegate::ShareSDKDelegate()
	{
		mAccessTokenUpdateHandler = 0;
		mShareHandler = 0;
	}

	ShareSDKDelegate::~ShareSDKDelegate()
	{

	}

	ShareSDKDelegate* ShareSDKDelegate::sharedDelegate()
	{
		if (s_sharedUtils == NULL)
		{
			s_sharedUtils = new ShareSDKDelegate();
		}
		return s_sharedUtils;
	}

	void ShareSDKDelegate::login(int handler)
	{
		mAccessTokenUpdateHandler = handler;
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
		ShareSDKConnector::getInstance()->login();
#endif
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
		android_facebook_login();
#endif
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
		accessTokenUpdate(NULL);
#endif
	}

	void ShareSDKDelegate::doShare(const char* title, const char* content, int handler)
	{
		mShareHandler = handler;
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
		ShareSDKConnector::getInstance()->share(title, content);
#endif
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
		android_facebook_login();
#endif
	}
   
	void ShareSDKDelegate::accessTokenUpdate(const char* accessToken)
	{
		if (mAccessTokenUpdateHandler == 0)
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
		pStack->pushString(accessToken);
		int ret = pStack->executeFunctionByHandler(mAccessTokenUpdateHandler, 1);
		pStack->clean();

		mAccessTokenUpdateHandler = 0;
	}

	void ShareSDKDelegate::shareResult(int result)
	{
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
		pStack->pushInt(result);
		int ret = pStack->executeFunctionByHandler(mShareHandler, 1);
		pStack->clean();

		mShareHandler = 0;
	}
}