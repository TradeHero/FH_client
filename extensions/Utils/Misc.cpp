#include "cocos2d.h"
#include "Misc.h"
#include "CCLuaEngine.h"
#include <string.h>
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
#include "MiscHandler.h"
#endif
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
#include "platform/android/jni/JniHelper.h"
#include "MiscAndroid.h"
#endif

USING_NS_CC;

namespace Utils
{
	static Misc* s_sharedUtils;

	Misc::Misc()
	{

	}

	Misc::~Misc()
	{

	}

	Misc* Misc::sharedDelegate()
	{
		if (s_sharedUtils == NULL)
		{
			s_sharedUtils = new Misc();
		}
		return s_sharedUtils;
	}

	void Misc::copyToPasteboard(const char* content)
	{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
		MiscHandler::getInstance()->copyToPasteboard(content);
#endif
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
		misc_copy_to_paste_board(content);
#endif
	}

	void Misc::selectImage(char* path, int width, int height, int handler)
	{
		mSelectImageHandler = handler;
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
		MiscHandler::getInstance()->selectImage(path, width, height);
#endif
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
		misc_select_image(path, width, height);
#endif
	}

	void Misc::selectImageResult(bool success)
	{
		CCScriptEngineProtocol* pScriptProtocol = CCScriptEngineManager::sharedManager()->getScriptEngine();
		cocos2d::CCLuaEngine* pLuaEngine = dynamic_cast<CCLuaEngine*>(pScriptProtocol);
		if (pLuaEngine == NULL)
		{
			assert(false);
			return;
		}

		CCLuaStack* pStack = pLuaEngine->getLuaStack();
		pStack->pushBoolean(success);
		int ret = pStack->executeFunctionByHandler(mSelectImageHandler, 1);
		pStack->clean();
	}
    
	void Misc::sendMail(char* receiver, char* subject, char* body, int handler)
    {
		mSendMailHandler = handler;
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
		MiscHandler::getInstance()->sendMail(receiver, subject, body);
#endif
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
        misc_send_mail(receiver, subject, body);
#endif
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
		sendMailResult(-1);
#endif
    }

	void Misc::sendMailResult(int resultCode)
	{
		CCScriptEngineProtocol* pScriptProtocol = CCScriptEngineManager::sharedManager()->getScriptEngine();
		cocos2d::CCLuaEngine* pLuaEngine = dynamic_cast<CCLuaEngine*>(pScriptProtocol);
		if (pLuaEngine == NULL)
		{
			assert(false);
			return;
		}

		CCLuaStack* pStack = pLuaEngine->getLuaStack();
		pStack->pushInt(resultCode);
		int ret = pStack->executeFunctionByHandler(mSendMailHandler, 1);
		pStack->clean();
	}

	void Misc::sendSMS(char* body, int handler)
	{
		mSendSMSHandler = handler;
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
		MiscHandler::getInstance()->sendSMS(body);
#endif
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
		misc_send_sms(body);
#endif
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
		sendSMSResult(-1);
#endif
	}

	void Misc::sendSMSResult(int resultCode)
	{
		CCScriptEngineProtocol* pScriptProtocol = CCScriptEngineManager::sharedManager()->getScriptEngine();
		cocos2d::CCLuaEngine* pLuaEngine = dynamic_cast<CCLuaEngine*>(pScriptProtocol);
		if (pLuaEngine == NULL)
		{
			assert(false);
			return;
		}

		CCLuaStack* pStack = pLuaEngine->getLuaStack();
		pStack->pushInt(resultCode);
		int ret = pStack->executeFunctionByHandler(mSendSMSHandler, 1);
		pStack->clean();
	}

	void Misc::getDeepLink(int handler)
	{
		const char* result = NULL;
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
		result = MiscHandler::getInstance()->getDeepLink();
#endif
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
		
#endif
		CCScriptEngineProtocol* pScriptProtocol = CCScriptEngineManager::sharedManager()->getScriptEngine();
		cocos2d::CCLuaEngine* pLuaEngine = dynamic_cast<CCLuaEngine*>(pScriptProtocol);
		if (pLuaEngine == NULL)
		{
			assert(false);
			return;
		}

		CCLuaStack* pStack = pLuaEngine->getLuaStack();
		pStack->pushString(result);
		int ret = pStack->executeFunctionByHandler(handler, 1);
		pStack->clean();

	}

	void Misc::addEventListenerDeepLink(int handler)
	{
		mDeepLinkEventHandler = handler;
	}

	void Misc::notifyDeepLink(const char * result)
	{
		if (mDeepLinkEventHandler == NULL)
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
		int ret = pStack->executeFunctionByHandler(mDeepLinkEventHandler, 1);
		pStack->clean();
	}

	char* Misc::createFormWithFile(const char* begin, const char* end, const char* filePath, const char* pszMode, unsigned long *pSize)
	{
		*pSize = 0;
		unsigned char* fileContent = CCFileUtils::sharedFileUtils()->getFileData(filePath, pszMode, pSize);

		char* buffer = new char[strlen(begin) + strlen(end) + *pSize];

		memcpy(buffer, begin, strlen(begin));
		memcpy(buffer + strlen(begin), fileContent, *pSize);
		memcpy(buffer + strlen(begin) + *pSize, end, strlen(end));

		*pSize += strlen(begin) + strlen(end);
		return buffer;
	}

	void Misc::setFileToRequestData(HttpRequestForLua* request, const char* begin, const char* end, const char* filePath, const char* pszMode)
	{
		unsigned long pSize;
		unsigned char* fileContent = CCFileUtils::sharedFileUtils()->getFileData(filePath, pszMode, &pSize);

		char* buffer = new char[strlen(begin) + strlen(end) + pSize];

		memcpy(buffer, begin, strlen(begin));
		memcpy(buffer + strlen(begin), fileContent, pSize);
		memcpy(buffer + strlen(begin) + pSize, end, strlen(end));

		pSize += (strlen(begin) + strlen(end));
		request->getRequest()->setRequestData(buffer, pSize);
	}

	void Misc::getUADeviceToken(int handler)
	{
		mUADeviceTokenHandler = handler;
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
		MiscHandler::getInstance()->getUADeviceToken();
#endif
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
		misc_get_UA_DeviceToken();
#endif
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
		responseUADeviceToken("-1");
#endif
	}

	void Misc::setUADeviceTokenHandler(int handler)
	{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
		mUADeviceTokenHandler = handler;
#endif
	}

	void Misc::responseUADeviceToken(const char* token)
	{
		CCScriptEngineProtocol* pScriptProtocol = CCScriptEngineManager::sharedManager()->getScriptEngine();
		cocos2d::CCLuaEngine* pLuaEngine = dynamic_cast<CCLuaEngine*>(pScriptProtocol);
		if (pLuaEngine == NULL)
		{
			assert(false);
			return;
		}

		CCLuaStack* pStack = pLuaEngine->getLuaStack();
		pStack->pushString(token);
		int ret = pStack->executeFunctionByHandler(mUADeviceTokenHandler, 1);
		pStack->clean();
	}
    
    void Misc::addUATags(const char *tagsString)
    {
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
        MiscHandler::getInstance()->addUATags(tagsString);
#endif
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
        
#endif
    }
    
    void Misc::removeUATags(const char *tagsString)
    {
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
        MiscHandler::getInstance()->removeUATags(tagsString);
#endif
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
        
#endif
    }

	void Misc::requestPushNotification()
	{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
		MiscHandler::getInstance()->requestPushNotification();
#endif
	}

	void Misc::openUrl(char* url)
	{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
		MiscHandler::getInstance()->openUrl(url);
#endif
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
		misc_open_url(url);
#endif
	}

	void Misc::openRate()
	{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
		MiscHandler::getInstance()->openRate();
#endif
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
		misc_open_rate();
#endif
	}

	void Misc::terminate()
	{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
		JniMethodInfo jmi;
		if (JniHelper::getStaticMethodInfo(jmi, "org/cocos2dx/lib/Cocos2dxHelper", "terminateProcess", "()V"))
		{
			jmi.env->CallStaticVoidMethod(jmi.classID, jmi.methodID);
			jmi.env->DeleteLocalRef(jmi.classID);
		}
#endif
	}
}