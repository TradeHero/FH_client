module(..., package.seeall)

local SceneManager = require("scripts.SceneManager")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList

local mWidget

function loadFrame()
	local widget = GUIReader:shareReader():widgetFromJsonFile("scenes/LoginNReg.json")
    mWidget = widget
    mWidget:registerScriptHandler( EnterOrExit )
    SceneManager.clearNAddWidget(widget)

    local signinBt = widget:getChildByName("signin")
    local registerBt = widget:getChildByName("register")
    local facebookBt = widget:getChildByName("facebookConnect")
    local dev = tolua.cast( widget:getChildByName("dev"), "Button" )

    signinBt:addTouchEventListener( signinEventHandler )
    registerBt:addTouchEventListener( registerEventHandler )
    facebookBt:addTouchEventListener( facebookEventHandler )
    dev:addTouchEventListener( devEventHandler )
    dev:setEnabled( false )
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

function facebookEventHandler( sender,eventType )
    if eventType == TOUCH_EVENT_ENDED then
        EventManager:postEvent( Event.Do_FB_Connect ) 
    end
end

function devEventHandler( sender,eventType )
    if eventType == TOUCH_EVENT_ENDED then
         local RequestUtils = require("scripts.RequestUtils")
         RequestUtils.setServerIP("http://fhapi-dev1.cloudapp.net")
    end
end