module(..., package.seeall)

local Constants = require("scripts.Constants")
local SceneManager = require("scripts.SceneManager")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList

local mWidget

function loadFrame()

	local widget = GUIReader:shareReader():widgetFromJsonFile("scenes/ErrorMessage.json")
    mWidget = widget
    mWidget:addTouchEventListener( onFrameTouch )
    mWidget:registerScriptHandler( EnterOrExit )

    local okBt = tolua.cast( widget:getChildByName("ok"), "Button" )
    okBt:addTouchEventListener( okEventHandler )

    setTitle("Are you sure you want to quit?")
    setErrorMessage("Tap back again to quit.")
    okBt:setTitleText("Stay")
    
    SceneManager.addWidget( mWidget )
end

function isShown()
    return mWidget ~= nil
end

function selfRemove()
    SceneManager.removeWidget( mWidget )
end

function EnterOrExit( eventType )
    if eventType == "enter" then
    elseif eventType == "exit" then
        mWidget = nil
    end
end

function setTitle( title )
    local titleMessage = tolua.cast( mWidget:getChildByName("title"), "Label" )
    titleMessage:setText( title )
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