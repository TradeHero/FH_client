#include "cocos2d.h"
#include "FacebookDelegate.h"
#include "../Utils/Analytics.h"
#include "CCLuaEngine.h"
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
#include "FacebookConnector.h"
#endif
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
#include "FacebookAndroid.h"
#endif

USING_NS_CC;

namespace Social
{
	static FacebookDelegate* s_sharedUtils;

	FacebookDelegate::FacebookDelegate()
	{

	}

	FacebookDelegate::~FacebookDelegate()
	{

	}

	FacebookDelegate* FacebookDelegate::sharedDelegate()
	{
		if (s_sharedUtils == NULL)
		{
			s_sharedUtils = new FacebookDelegate();
		}
		return s_sharedUtils;
	}

	void FacebookDelegate::login(int successHandler, int errorHandler)
	{
		mSuccessHandler = successHandler;
		mErrorHandler = errorHandler;
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
        FacebookConnector::getInstance()->login();
#endif
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
		android_facebook_login();
#endif
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
		loginResult(NULL);
#endif
	}
    
    void FacebookDelegate::loginResult(const char* accessToken)
	{
		if (accessToken != NULL) {
			Utils::Analytics::sharedDelegate()->postEvent("FacebookLoginSuccess", "", "");
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
		int ret = pStack->executeFunctionByHandler(mSuccessHandler, 1);
		pStack->clean();
	}
    
}