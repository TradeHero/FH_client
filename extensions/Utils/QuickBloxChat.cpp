#include "cocos2d.h"
#include "QuickBloxChat.h"
#include "CCLuaEngine.h"
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
#include "QuickBloxChatHandler.h"
#endif
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
#include "AnalyticsAndroid.h"
#endif

USING_NS_CC;

namespace Utils
{
	static QuickBloxChat* s_sharedUtils;

	QuickBloxChat::QuickBloxChat()
	{

	}

	QuickBloxChat::~QuickBloxChat()
	{

	}

	QuickBloxChat* QuickBloxChat::sharedDelegate()
	{
		if (s_sharedUtils == NULL)
		{
			s_sharedUtils = new QuickBloxChat();
		}
		return s_sharedUtils;
	}

	void QuickBloxChat::login(const char *username, const char* profileImg, int userId, int handler)
	{
        mLoginHandler = handler;
        
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
        QuickBloxChatHandler::getInstance()->login(username, profileImg, userId);
#endif
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
		
#endif
	}
    
    void QuickBloxChat::loginResult(const char *token)
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
        int ret = pStack->executeFunctionByHandler(mLoginHandler, 1);
        pStack->clean();
    }
    
    void QuickBloxChat::logout()
    {
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
        QuickBloxChatHandler::getInstance()->logout();
#endif
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
        
#endif
    }
    
    void QuickBloxChat::joinChatRoom(const char* jid, int handler)
    {
        mJoinRoomHandler = handler;
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
        QuickBloxChatHandler::getInstance()->joinChatRoom(jid);
#endif
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
        
#endif
    }
    
    void QuickBloxChat::joinChatRoomResult(bool success)
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
        int ret = pStack->executeFunctionByHandler(mJoinRoomHandler, 1);
        pStack->clean();
    }
    
    void QuickBloxChat::sendMessage(const char* message)
    {
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
        QuickBloxChatHandler::getInstance()->sendMessage(message);
#endif
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
        
#endif
    }
    
    void QuickBloxChat::setNewMessageHandler(int handler)
    {
        mNewMessageHandler = handler;
    }
    
    void QuickBloxChat::newMessageHandler(const char* sender, const char* message, int timestamp)
    {
        CCScriptEngineProtocol* pScriptProtocol = CCScriptEngineManager::sharedManager()->getScriptEngine();
        cocos2d::CCLuaEngine* pLuaEngine = dynamic_cast<CCLuaEngine*>(pScriptProtocol);
        if (pLuaEngine == NULL)
        {
            assert(false);
            return;
        }
        
        CCLuaStack* pStack = pLuaEngine->getLuaStack();
        pStack->pushString(sender);
        pStack->pushString(message);
        pStack->pushInt(timestamp);
        int ret = pStack->executeFunctionByHandler(mNewMessageHandler, 3);
        pStack->clean();
    }
}