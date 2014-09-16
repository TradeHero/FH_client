module(..., package.seeall)

local Constants = require("scripts.Constants")
local SceneManager = require("scripts.SceneManager")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList

local mWidget
local mRetryCall

function loadFrame()

	local widget = GUIReader:shareReader():widgetFromJsonFile("scenes/ErrorMessage.json")

    local okBt = widget:getChildByName("ok")
    okBt:addTouchEventListener( okEventHandler )

    widget:addTouchEventListener( onFrameTouch )
    mWidget = widget
    mWidget:registerScriptHandler( EnterOrExit )
    SceneManager.addWidget( widget )
    SceneManager.setKeyPadBackEnabled( false )
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

function setErrorMessage( message, retryCall )
    local errorMessage = tolua.cast( mWidget:getChildByName("errorMessage"), "Label" )
    errorMessage:setText( message )
    mRetryCall = retryCall
end

function setButtonText( text )
    local okBt = tolua.cast( mWidget:getChildByName("ok"), "Button" )
    okBt:setTitleText( text )
end

function okEventHandler( sender, eventType )
    if eventType == TOUCH_EVENT_ENDED then
        SceneManager.removeWidget( mWidget )
        SceneManager.setKeyPadBackEnabled( true )
        if mRetryCall ~= nil then
            mRetryCall()
            mRetryCall = nil
        end
    end
end

function onFrameTouch( sender, eventType )
    -- Do nothing, just block touch event.
end