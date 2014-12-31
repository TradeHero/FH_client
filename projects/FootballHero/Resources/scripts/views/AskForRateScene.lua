module(..., package.seeall)

local Constants = require("scripts.Constants")
local SceneManager = require("scripts.SceneManager")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local RateManager = require("scripts.RateManager")


local mWidget

function loadFrame()
	local widget = GUIReader:shareReader():widgetFromJsonFile("scenes/AskForRate.json")
    local bg = widget:getChildByName("bg")

    local yesBt = tolua.cast( bg:getChildByName("yes"), "Button" )
    local noBt = tolua.cast( bg:getChildByName("no"), "Button" )
    local msg1 = tolua.cast( bg:getChildByName("message"), "Label" )
    local msg2 = tolua.cast( bg:getChildByName("message1"), "Label" )

    yesBt:setTitleText( Constants.String.button.rate_now )
    noBt:setTitleText( Constants.String.button.no )
    msg1:setText( Constants.String.info.like_fh1 )
    msg2:setText( Constants.String.info.like_fh2 )

    yesBt:addTouchEventListener( yesEventHandler )
    noBt:addTouchEventListener( noEventHandler )

    widget:addTouchEventListener( onFrameTouch )
    mWidget = widget
    mWidget:registerScriptHandler( EnterOrExit )
    SceneManager.addWidget( mWidget )
    SceneManager.setKeyPadBackEnabled( false )
end

function EnterOrExit( eventType )
    if eventType == "enter" then
    elseif eventType == "exit" then
        mWidget = nil
    end
end

function yesEventHandler( sender, eventType )
    if eventType == TOUCH_EVENT_ENDED then
        SceneManager.removeWidget( mWidget )
        SceneManager.setKeyPadBackEnabled( true )

        Misc:sharedDelegate():openRate()
        RateManager.setRated( true )
    end
end

function noEventHandler( sender, eventType )
    if eventType == TOUCH_EVENT_ENDED then
        SceneManager.removeWidget( mWidget )
        SceneManager.setKeyPadBackEnabled( true )

        EventManager:postEvent( Event.Do_Ask_For_Comment )
    end
end


function onFrameTouch( sender, eventType )
    -- Do nothing, just block touch event.
end