module(..., package.seeall)

local SceneManager = require("scripts.SceneManager")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList

local mWidget

function loadFrame()
	local widget = GUIReader:shareReader():widgetFromJsonFile("scenes/LoginNRegEmail.json")
    mWidget = widget
    mWidget:registerScriptHandler( EnterOrExit )
    SceneManager.clearNAddWidget(widget)

    local existingUserBt = widget:getChildByName("ExistingUser")
    local newUserBt = widget:getChildByName("NewUser")
    local backBt = widget:getChildByName("back")

    backBt:addTouchEventListener( backEventHandler )
    existingUserBt:addTouchEventListener( signinEventHandler )
    newUserBt:addTouchEventListener( registerEventHandler )
end

function EnterOrExit( eventType )
    if eventType == "enter" then
    elseif eventType == "exit" then
        mWidget = nil
    end
end

function signinEventHandler( sender,eventType )
	if eventType == TOUCH_EVENT_ENDED then
        EventManager:postEvent( Event.Enter_Login )
    end
end

function registerEventHandler( sender,eventType )
	if eventType == TOUCH_EVENT_ENDED then
        EventManager:postEvent( Event.Enter_Register )
    end
end

function backEventHandler( sender,eventType )
    if eventType == TOUCH_EVENT_ENDED then
        EventManager:popHistory()
    end
end