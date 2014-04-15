module(..., package.seeall)

local SceneManager = require("scripts.SceneManager")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList

function loadFrame()
	local widget = GUIReader:shareReader():widgetFromJsonFile("scenes/LoginNReg/LoginNReg.json")
    SceneManager.clearNAddWidget(widget)

    local signinBt = widget:getChildByName("signin")
    local registerBt = widget:getChildByName("register")
    local facebookBt = widget:getChildByName("facebookConnect")

    signinBt:addTouchEventListener( signinEventHandler )
    registerBt:addTouchEventListener( registerEventHandler )
    facebookBt:addTouchEventListener( facebookEventHandler )
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

function facebookEventHandler( sender,eventType )
    if eventType == TOUCH_EVENT_ENDED then
        EventManager:postEvent( Event.Do_FB_Connect ) 
    end
end