module(..., package.seeall)

local Constants = require("scripts.Constants")
local SceneManager = require("scripts.SceneManager")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local ConnectingMessage = require("scripts.views.ConnectingMessage")
local Logic = require("scripts.Logic").getInstance()


local mWidget
local mShareTitle
local mShareBody

function loadFrame( title, body, shareByFacebook )
	mShareTitle = title
	mShareBody = body

    local widget = GUIReader:shareReader():widgetFromJsonFile("scenes/ShareTypeSelection.json")

	mWidget = widget
    mWidget:addTouchEventListener( onFrameTouch )
    mWidget:registerScriptHandler( EnterOrExit )
    SceneManager.addWidget( mWidget )

    local byFacebook = mWidget:getChildByName("facebook")
    local byEmail = mWidget:getChildByName("email")
    local bySMS = mWidget:getChildByName("sms")
    local close = mWidget:getChildByName("close")

    byFacebook:addTouchEventListener( shareByFacebook )
    byEmail:addTouchEventListener( shareByEmail )
    bySMS:addTouchEventListener( shareBySMS )
    close:addTouchEventListener( closeShareTypeSelectionHandler )
end

function EnterOrExit( eventType )
    if eventType == "enter" then
    elseif eventType == "exit" then
        mWidget = nil
    end
end

function onFrameTouch( sender, eventType )
    -- Do nothing, just block touch event.
end

function shareByEmail( sender, eventType )
    if eventType == TOUCH_EVENT_ENDED then
        EventManager:postEvent( Event.Do_Share_By_Email, { mShareBody, mShareTitle } )
    end
end

function shareBySMS( sender, eventType )
    if eventType == TOUCH_EVENT_ENDED then
        EventManager:postEvent( Event.Do_Share_By_SMS, { mShareBody } )
    end
end

function closeShareTypeSelectionHandler( sender, eventType )
    if eventType == TOUCH_EVENT_ENDED then
        SceneManager.removeWidget( mWidget )
    end
end