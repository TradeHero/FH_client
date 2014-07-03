#include "cocos2d.h"
#include "Misc.h"
#include "CCLuaEngine.h"
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
#include "MiscHandler.h"
#endif
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
#include "platform/android/jni/JniHelper.h"
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

#endif
	}

	void Misc::selectImage(char* path, int handler)
	{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
		mSelectImageHandler = handler;
		MiscHandler::getInstance()->selectImage(path);
#endif
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)

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
    
    void Misc::sendMail(char* receiver, char* subject, char* body)
    {
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
		MiscHandler::getInstance()->sendMail(receiver, subject, body);
#endif
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
        
#endif
    }
}