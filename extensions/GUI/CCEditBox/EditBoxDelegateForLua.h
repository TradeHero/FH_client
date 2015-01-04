#ifndef _EDIT_BOX_FOR_LUA_H_
#define _EDIT_BOX_FOR_LUA_H_

#include "cocos2d.h"
#include "cocos-ext.h"

enum EditBoxEvent
{
	EDIT_BOX_EVENT_DID_BEGIN,
	EDIT_BOX_EVENT_DID_END,
	EDIT_BOX_EVENT_TEXT_CHANGED,
	EDIT_BOX_EVENT_RETURN,
	EDIT_BOX_EVENT_MAX
};

class EditBoxDelegateForLua : public cocos2d::CCLayer, public cocos2d::extension::CCEditBoxDelegate
{
public:
	EditBoxDelegateForLua();
	~EditBoxDelegateForLua();

	CREATE_FUNC(EditBoxDelegateForLua);

	virtual void editBoxEditingDidBegin(cocos2d::extension::CCEditBox* editBox);
	virtual void editBoxEditingDidEnd(cocos2d::extension::CCEditBox* editBox);
	virtual void editBoxTextChanged(cocos2d::extension::CCEditBox* editBox, const std::string& text);
	virtual void editBoxReturn(cocos2d::extension::CCEditBox* editBox);

	void registerEventScriptHandler(EditBoxEvent eventType, int nHandler);
	void unregisterEventScriptHandler(EditBoxEvent eventType);

private:
	int dispatchScriptHandlerforEvent(EditBoxEvent eventType);

private:
	std::map<EditBoxEvent, int>	m_scriptDispatchTable;
};

#endif