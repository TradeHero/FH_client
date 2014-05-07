module(..., package.seeall)

local Constants = require("scripts.Constants")
local SceneManager = require("scripts.SceneManager")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList

local mWidget

function loadFrame( message )
    if mWidget == nil then
        local widget = GUIReader:shareReader():widgetFromJsonFile("scenes/ConnectingMessage.json")

        widget:addTouchEventListener( onFrameTouch )
        mWidget = widget
        mWidget:registerScriptHandler( EnterOrExit )
        SceneManager.addWidget( widget )
    end
    setMessage( message )
end

function EnterOrExit( eventType )
    if eventType == "enter" then
    elseif eventType == "exit" then
        mWidget = nil
    end
end

function setMessage( message )
    message = message or "Connecting..."
    print( "Load connecting message scene:"..message )
    local messageLabel = tolua.cast( mWidget:getChildByName("connectMessage"), "Label" )
    messageLabel:setText( message )
end

function selfRemove()
    SceneManager.removeWidget( mWidget )
end

function onFrameTouch( sender, eventType )
    -- Do nothing, just block touch event.
end