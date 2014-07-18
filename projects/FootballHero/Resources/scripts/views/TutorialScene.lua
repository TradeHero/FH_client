module(..., package.seeall)

local Constants = require("scripts.Constants")
local SceneManager = require("scripts.SceneManager")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList

local mWidget

function loadFrame( uiKey )

	local widget = GUIReader:shareReader():widgetFromJsonFile( uiKey )

    local okBt = widget:getChildByName("ok")
    okBt:addTouchEventListener( okEventHandler )

    widget:addTouchEventListener( onFrameTouch )
    mWidget = widget
    mWidget:registerScriptHandler( EnterOrExit )
    SceneManager.addWidget( widget )
end

function EnterOrExit( eventType )
    if eventType == "enter" then
    elseif eventType == "exit" then
        mWidget = nil
    end
end

function okEventHandler( sender, eventType )
    if eventType == TOUCH_EVENT_ENDED then
        SceneManager.removeWidget( mWidget )
    end
end

function onFrameTouch( sender, eventType )
    -- Do nothing, just block touch event.
end