#include "cocos2d.h"
#include "FacebookDelegate.h"
#include "CCLuaEngine.h"
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
#include "FacebookConnector.h"
#endif
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
#include "platform/android/jni/JniHelper.h"
#include <jni.h>
#endif

USING_NS_CC;

#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
extern "C"
{
	void Java_com_myhero_fh_FootballHero_loginResult(JNIEnv *env, jobject thiz, jstring accessToken)
	{
		const char *token = env->GetStringUTFChars(accessToken, NULL);
		Social::FacebookDelegate::sharedDelegate()->loginResult(token);
	}
}
#endif

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
		JniMethodInfo jmi;
		if (JniHelper::getStaticMethodInfo(jmi, "com/myhero/fh/FootballHero", "login", "()V"))
		{
			jmi.env->CallStaticVoidMethod(jmi.classID, jmi.methodID);
			jmi.env->DeleteLocalRef(jmi.classID);
		}
#endif
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
		loginResult(NULL);
#endif
	}
    
    void FacebookDelegate::loginResult(const char* accessToken)
	{
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