module(..., package.seeall)

local SceneManager = require("scripts.SceneManager")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList


local mWidget

function loadFrame()
	local widget = GUIReader:shareReader():widgetFromJsonFile("scenes/FAQ.json")
    mWidget = widget
    mWidget:registerScriptHandler( EnterOrExit )
    SceneManager.clearNAddWidget( widget )

    local backBt = widget:getChildByName("back")
    backBt:addTouchEventListener( backEventHandler )
end

function EnterOrExit( eventType )
    if eventType == "enter" then
        WebviewDelegate:sharedDelegate():openWebpage( "http://www.baidu.com", 0, 40, 320, 528 )
    elseif eventType == "exit" then
        mWidget = nil
    end
end

function isFrameShown()
    return mWidget ~= nil
end

function backEventHandler( sender,eventType )
    if eventType == TOUCH_EVENT_ENDED then
        WebviewDelegate:sharedDelegate():closeWebpage()
        EventManager:popHistory()
    end
end