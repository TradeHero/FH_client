module(..., package.seeall)

local Constants = require("scripts.Constants")
local SceneManager = require("scripts.SceneManager")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList

local mWidget

function loadFrame()

	local widget = GUIReader:shareReader():widgetFromJsonFile("scenes/ErrorMessage/ConnectingMessage.json")
    SceneManager.addWidget( widget )

    widget:addTouchEventListener( onFrameTouch )
    mWidget = widget
end

function setMessage( message )
    local message = tolua.cast( mWidget:getChildByName("message"), "Label" )
    message:setText( message )
end

function selfRemove()
    SceneManager.removeWidget( mWidget )
end

function onFrameTouch( sender, eventType )
    -- Do nothing, just block touch event.
end