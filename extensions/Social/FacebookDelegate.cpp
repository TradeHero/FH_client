#include "cocos2d.h"
#include "FacebookDelegate.h"
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
		mAccessTokenUpdateHandler = 0;
		mPermissionUpdateHandler = 0;
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

	void FacebookDelegate::login(int handler)
	{
		mAccessTokenUpdateHandler = handler;
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
        FacebookConnector::getInstance()->login();
#endif
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
		android_facebook_login();
#endif
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
		accessTokenUpdate(NULL);
#endif
	}

	void FacebookDelegate::grantPublishPermission(const char* permission, int handler)
	{
		mPermissionUpdateHandler = handler;
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
		FacebookConnector::getInstance()->grantPublishPermission(permission);
#endif
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
		android_facebook_requestPublishPermissions(permission);
#endif
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
		permissionUpdate(NULL, false);
#endif
	}
    
	void FacebookDelegate::accessTokenUpdate(const char* accessToken)
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
    
	void FacebookDelegate::permissionUpdate(const char* accessToken, bool success)
	{
		if (mPermissionUpdateHandler == 0)
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
		pStack->pushBoolean(success);
		int ret = pStack->executeFunctionByHandler(mPermissionUpdateHandler, 2);
		pStack->clean();

		mPermissionUpdateHandler = 0;
	}
    
    void FacebookDelegate::gameRequest(const char* title, const char* message)
    {
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
        FacebookConnector::getInstance()->gameRequest(title, message);
#endif
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
        android_facebook_gameRequest(title, message);
#endif
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)

#endif
    }
}