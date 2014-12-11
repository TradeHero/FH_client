module(..., package.seeall)

local Json = require("json")
local Constants = require("scripts.Constants")
local SceneManager = require("scripts.SceneManager")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList


local mWidget
local mLeagueId

function loadFrame( leagueId )
    mLeagueId = leagueId
	local widget = GUIReader:shareReader():widgetFromJsonFile("scenes/MarketingMessage.json")

    local okBt = tolua.cast( widget:getChildByName("Button_Go"), "Button" )
    okBt:addTouchEventListener( okEventHandler )
    okBt:setTitleText( Constants.String.button.go )

    local closeBt = widget:getChildByName("Button_Close")
    closeBt:addTouchEventListener( closeEventHandler )

    local lbCTA1 = tolua.cast( widget:getChildByName("Label_CTA1"), "Label" )
    local lbCTA2 = tolua.cast( widget:getChildByName("Label_CTA2"), "Label" )
    local lbCTA3 = tolua.cast( widget:getChildByName("Label_CTA3"), "Label" )
    lbCTA1:setText( Constants.String.marketing_message_1 )
    lbCTA2:setText( Constants.String.marketing_message_2 )
    lbCTA3:setText( Constants.String.marketing_message_3 )
    
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

        local params = { Content = "competition creation", 
                        Action = "accept", 
                        Location = "after prediction" }
        CCLuaLog("Send ANALYTICS_EVENT_POPUP: "..Json.encode( params ) )
        Analytics:sharedDelegate():postEvent( Constants.ANALYTICS_EVENT_POPUP, Json.encode( params ) )

        EventManager:postEvent( Event.Enter_Create_Competition, { true, mLeagueId } )
    end
end

function closeEventHandler( sender, eventType )
    if eventType == TOUCH_EVENT_ENDED then
        
        local params = { Content = "competition creation", 
                        Action = "cancel/close", 
                        Location = "after prediction" }
        CCLuaLog("Send ANALYTICS_EVENT_POPUP: "..Json.encode( params ) )
        Analytics:sharedDelegate():postEvent( Constants.ANALYTICS_EVENT_POPUP, Json.encode( params ) )

        SceneManager.removeWidget( mWidget )
    end
end

function onFrameTouch( sender, eventType )
    -- Do nothing, just block touch event.
end