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

    local yesBt = bg:getChildByName("yes")
    local noBt = bg:getChildByName("no")
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