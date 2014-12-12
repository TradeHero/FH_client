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
local mShareByFacebookCallback

function loadFrame( title, body, shareByFacebookCallback )
	mShareTitle = title
	mShareBody = body
    mShareByFacebookCallback = shareByFacebookCallback

    local widget = GUIReader:shareReader():widgetFromJsonFile("scenes/ShareTypeSelection.json")

	mWidget = widget
    mWidget:addTouchEventListener( onFrameTouch )
    mWidget:registerScriptHandler( EnterOrExit )
    SceneManager.addWidget( mWidget )

    local title = tolua.cast( mWidget:getChildByName("Label_Title"), "Label" )
    local byFacebook = tolua.cast( mWidget:getChildByName("facebook"), "Button" )
    local byEmail = tolua.cast( mWidget:getChildByName("email"), "Button" )
    local bySMS = tolua.cast( mWidget:getChildByName("sms"), "Button" )
    local close = mWidget:getChildByName("close")

    title:setText( Constants.String.share_type_title )
    byFacebook:setTitleText( Constants.String.share_type_facebook )
    byEmail:setTitleText( Constants.String.share_type_email )
    bySMS:setTitleText( Constants.String.share_type_SMS )

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

function shareByFacebook(sender, eventType)
    if eventType == TOUCH_EVENT_ENDED then
        mShareByFacebookCallback( sender, eventType )
        SceneManager.removeWidget( mWidget )
    end
end

function shareByEmail( sender, eventType )
    if eventType == TOUCH_EVENT_ENDED then
        EventManager:postEvent( Event.Do_Share_By_Email, { mShareBody, mShareTitle } )
        SceneManager.removeWidget( mWidget )
    end
end

function shareBySMS( sender, eventType )
    if eventType == TOUCH_EVENT_ENDED then
        EventManager:postEvent( Event.Do_Share_By_SMS, { mShareBody } )
        SceneManager.removeWidget( mWidget )
    end
end

function closeShareTypeSelectionHandler( sender, eventType )
    if eventType == TOUCH_EVENT_ENDED then
        SceneManager.removeWidget( mWidget )
    end
end