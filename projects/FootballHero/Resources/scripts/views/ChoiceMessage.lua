module(..., package.seeall)

local Constants = require("scripts.Constants")
local SceneManager = require("scripts.SceneManager")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList

local mWidget
local mYesCallback
local mNoCallback

function loadFrame()

	local widget = GUIReader:shareReader():widgetFromJsonFile("scenes/ChoiceMessage.json")

    local yesBt = widget:getChildByName("yes")
    yesBt:addTouchEventListener( yesEventHandler )
    local noBt = widget:getChildByName("no")
    noBt:addTouchEventListener( noEventHandler )

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

function setMessage( text )
    local message = tolua.cast( mWidget:getChildByName("errorMessage"), "Label" )
    message:setText( text )
end

function setCallbacks( yesCallback, noCallback )
    mYesCallback = yesCallback
    mNoCallback = noCallback
end

function setButtonText( yesText, noText )
    local yesBt = tolua.cast( mWidget:getChildByName("yes"), "Button" )
    yesBt:setTitleText( yesText )
    local noBt = tolua.cast( mWidget:getChildByName("no"), "Button" )
    noBt:setTitleText( noText )
end

function yesEventHandler( sender, eventType )
    if eventType == TOUCH_EVENT_ENDED then
        SceneManager.removeWidget( mWidget )
        SceneManager.setKeyPadBackEnabled( true )
        if mYesCallback ~= nil then
            mYesCallback()
            mYesCallback = nil
        end
    end
end

function noEventHandler( sender, eventType )
    if eventType == TOUCH_EVENT_ENDED then
        SceneManager.removeWidget( mWidget )
        SceneManager.setKeyPadBackEnabled( true )
        if mNoCallback ~= nil then
            mNoCallback()
            mNoCallback = nil
        end
    end
end

function onFrameTouch( sender, eventType )
    -- Do nothing, just block touch event.
end