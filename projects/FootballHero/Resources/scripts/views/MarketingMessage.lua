module(..., package.seeall)

local Constants = require("scripts.Constants")
local SceneManager = require("scripts.SceneManager")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList


local mWidget
local mLeagueId

function loadFrame( leagueId )
    mLeagueId = leagueId
	local widget = GUIReader:shareReader():widgetFromJsonFile("scenes/MarketingMessage.json")

    local okBt = widget:getChildByName("OK")
    okBt:addTouchEventListener( okEventHandler )
    local closeBt = widget:getChildByName("close")
    closeBt:addTouchEventListener( closeEventHandler )

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
        EventManager:postEvent( Event.Enter_Create_Competition, { true, mLeagueId } )
    end
end

function closeEventHandler( sender, eventType )
    if eventType == TOUCH_EVENT_ENDED then
        SceneManager.removeWidget( mWidget )
    end
end

function onFrameTouch( sender, eventType )
    -- Do nothing, just block touch event.
end