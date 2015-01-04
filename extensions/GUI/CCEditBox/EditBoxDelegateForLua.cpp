#include "EditBoxDelegateForLua.h"
#include "CCLuaEngine.h"

USING_NS_CC;
USING_NS_CC_EXT;

EditBoxDelegateForLua::EditBoxDelegateForLua()
{
}

EditBoxDelegateForLua::~EditBoxDelegateForLua()
{
	for (std::map<EditBoxEvent, int>::iterator iter = m_scriptDispatchTable.begin(), end = m_scriptDispatchTable.end();
		iter != end; ++iter)
	{
		int nScriptTapHandler = iter->second;
		if (nScriptTapHandler == 0)
		{
			assert(false);
			continue;
		}

		CCScriptEngineManager::sharedManager()->getScriptEngine()->removeScriptHandler(nScriptTapHandler);
	}
}

void EditBoxDelegateForLua::editBoxEditingDidBegin(CCEditBox* editBox)
{
	int nHandler = dispatchScriptHandlerforEvent(EDIT_BOX_EVENT_DID_BEGIN);
	if (nHandler == 0)
	{
		return;
	}

	CCScriptEngineProtocol* pScriptProtocol = CCScriptEngineManager::sharedManager()->getScriptEngine();
	CCLuaEngine* pLuaEngine = dynamic_cast<CCLuaEngine*>(pScriptProtocol);
	if (pLuaEngine == NULL)
	{
		assert(false);
		return;
	}
	
	CCLuaStack* pStack = pLuaEngine->getLuaStack();
	pStack->pushCCObject(editBox, "CCEditBox");
	int ret = pStack->executeFunctionByHandler(nHandler, 1);
	pStack->clean();
}

void EditBoxDelegateForLua::editBoxEditingDidEnd(CCEditBox* editBox)
{
	int nHandler = dispatchScriptHandlerforEvent(EDIT_BOX_EVENT_DID_END);
	if (nHandler == 0)
	{
		return;
	}

	CCScriptEngineProtocol* pScriptProtocol = CCScriptEngineManager::sharedManager()->getScriptEngine();
	CCLuaEngine* pLuaEngine = dynamic_cast<CCLuaEngine*>(pScriptProtocol);
	if (pLuaEngine == NULL)
	{
		assert(false);
		return;
	}

	CCLuaStack* pStack = pLuaEngine->getLuaStack();
	pStack->pushCCObject(editBox, "CCEditBox");
	int ret = pStack->executeFunctionByHandler(nHandler, 1);
	pStack->clean();
}

void EditBoxDelegateForLua::editBoxTextChanged(CCEditBox* editBox, const std::string& text)
{
	int nHandler = dispatchScriptHandlerforEvent(EDIT_BOX_EVENT_TEXT_CHANGED);
	if (nHandler == 0)
	{
		return;
	}

	CCScriptEngineProtocol* pScriptProtocol = CCScriptEngineManager::sharedManager()->getScriptEngine();
	CCLuaEngine* pLuaEngine = dynamic_cast<CCLuaEngine*>(pScriptProtocol);
	if (pLuaEngine == NULL)
	{
		assert(false);
		return;
	}

	CCLuaStack* pStack = pLuaEngine->getLuaStack();
	pStack->pushCCObject(editBox, "CCEditBox");
	pStack->pushString(text.c_str());
	int ret = pStack->executeFunctionByHandler(nHandler, 2);
	pStack->clean();
}

void EditBoxDelegateForLua::editBoxReturn(CCEditBox* editBox)
{
	int nHandler = dispatchScriptHandlerforEvent(EDIT_BOX_EVENT_RETURN);
	if (nHandler == 0)
	{
		return;
	}

	CCScriptEngineProtocol* pScriptProtocol = CCScriptEngineManager::sharedManager()->getScriptEngine();
	CCLuaEngine* pLuaEngine = dynamic_cast<CCLuaEngine*>(pScriptProtocol);
	if (pLuaEngine == NULL)
	{
		assert(false);
		return;
	}

	CCLuaStack* pStack = pLuaEngine->getLuaStack();
	pStack->pushCCObject(editBox, "CCEditBox");
	int ret = pStack->executeFunctionByHandler(nHandler, 1);
	pStack->clean();
}

void EditBoxDelegateForLua::registerEventScriptHandler(EditBoxEvent eventType, int nHandler)
{
	unregisterEventScriptHandler(eventType);
	m_scriptDispatchTable[eventType] = nHandler;
}

void EditBoxDelegateForLua::unregisterEventScriptHandler(EditBoxEvent eventType)
{
	int nScriptTapHandler = dispatchScriptHandlerforEvent(eventType);
	if (nScriptTapHandler == 0)
	{
		return;
	}

	m_scriptDispatchTable.erase(eventType);

	CCScriptEngineManager::sharedManager()->getScriptEngine()->removeScriptHandler(nScriptTapHandler);
	LUALOG("[LUA] Remove EditBoxDelegateForLua script handler: %d", nScriptTapHandler);
}

int EditBoxDelegateForLua::dispatchScriptHandlerforEvent(EditBoxEvent eventType)
{
	std::map<EditBoxEvent, int>::iterator eventIter = m_scriptDispatchTable.find(eventType);
	if (eventIter == m_scriptDispatchTable.end())
	{
		return 0;
	}

	return eventIter->second;
}