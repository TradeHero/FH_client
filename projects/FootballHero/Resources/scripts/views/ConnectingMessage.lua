module(..., package.seeall)

local Constants = require("scripts.Constants")
local SceneManager = require("scripts.SceneManager")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList

local mWidget

function loadFrame()

	local widget = GUIReader:shareReader():widgetFromJsonFile("scenes/ConnectingMessage.json")

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