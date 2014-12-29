module(..., package.seeall)

local Constants = require("scripts.Constants")
local SceneManager = require("scripts.SceneManager")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local RateManager = require("scripts.RateManager")


local mWidget

function loadFrame()
    local widget = GUIReader:shareReader():widgetFromJsonFile("scenes/AskForComment.json")
    local bg = widget:getChildByName("bg")

    local yesBt = tolua.cast( bg:getChildByName("yes"), "Button" )
    local noBt = tolua.cast( bg:getChildByName("no"), "Button" )
    local msgBt = tolua.cast( bg:getChildByName("message"), "Label" )

    yesBt:setTitleText( Constants.String.button.yes )
    noBt:setTitleText( Constants.String.button.no )
    msgBt:setText( Constants.String.info.leave_comment )

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
        local bg = mWidget:getChildByName("bg")

        bg:setPosition( ccp( bg:getPositionX(), bg:getPositionY() - 960 ) )
        bg:runAction( CCMoveBy:create( 0.5, ccp( 0, 960 ) ) )
    elseif eventType == "exit" then
        mWidget = nil
    end
end

function yesEventHandler( sender, eventType )
    if eventType == TOUCH_EVENT_ENDED then
        SceneManager.removeWidget( mWidget )
        SceneManager.setKeyPadBackEnabled( true )

        EventManager:postEvent( Event.Do_Send_Feedback )
    end
end

function noEventHandler( sender, eventType )
    if eventType == TOUCH_EVENT_ENDED then
        SceneManager.removeWidget( mWidget )
        SceneManager.setKeyPadBackEnabled( true )
    end
end


function onFrameTouch( sender, eventType )
    -- Do nothing, just block touch event.
end