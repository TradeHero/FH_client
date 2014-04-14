module(..., package.seeall)

local Constants = require("scripts.Constants")
local SceneManager = require("scripts.SceneManager")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList

local mWidget

function loadFrame()

	local widget = GUIReader:shareReader():widgetFromJsonFile("scenes/ErrorMessage/ErrorMessage.json")
    SceneManager.addWidget( widget )

    local okBt = widget:getChildByName("ok")
    okBt:addTouchEventListener( okEventHandler )

    widget:addTouchEventListener( onFrameTouch )
    mWidget = widget
end

function setErrorMessage( message )
    local errorMessage = tolua.cast( mWidget:getChildByName("errorMessage"), "Label" )
    errorMessage:setText( message )
end

function okEventHandler( sender, eventType )
    if eventType == TOUCH_EVENT_ENDED then
        SceneManager.removeWidget( mWidget )
    end
end

function onFrameTouch( sender, eventType )
    -- Do nothing, just block touch event.
end