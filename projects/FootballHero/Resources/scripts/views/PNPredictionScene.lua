module(..., package.seeall)

local Json = require("json")
local Constants = require("scripts.Constants")
local SceneManager = require("scripts.SceneManager")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList


local mWidget
local mSelectYesCallback
local mSelectNoCallback

function loadFrame( selectYesCallback, selectNoCallback )
    mSelectYesCallback = selectYesCallback
    mSelectNoCallback = selectNoCallback

	local widget = GUIReader:shareReader():widgetFromJsonFile("scenes/PushNotificationMessage.json")

    local okBt = tolua.cast( widget:getChildByName("Button_Enable"), "Button" )
    okBt:addTouchEventListener( okEventHandler )
    local closeBt = widget:getChildByName("Button_Close")
    closeBt:addTouchEventListener( closeEventHandler )

    --Labels
    okBt:setTitleText( Constants.String.button.enable )
    local lbQuestion = tolua.cast( widget:getChildByName("Label_Question"), "Label" )
    local lbBody1 = tolua.cast( widget:getChildByName("Label_Body1"), "Label" )
    local lbBody2 = tolua.cast( widget:getChildByName("Label_Body2"), "Label" )
    local lbBody3 = tolua.cast( widget:getChildByName("Label_Body3"), "Label" )

    lbQuestion:setText( Constants.String.push_notification.question_prediction )
    lbBody1:setText( Constants.String.push_notification.receive )
    lbBody2:setText( Constants.String.push_notification.match_result )
    lbBody3:setText( Constants.String.push_notification.points_won )

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
        if mSelectYesCallback ~= nil then
            mSelectYesCallback()
        end
        SceneManager.removeWidget( mWidget )
    end
end

function closeEventHandler( sender, eventType )
    if eventType == TOUCH_EVENT_ENDED then
        if mSelectNoCallback ~= nil then
            mSelectNoCallback()
        end
        SceneManager.removeWidget( mWidget )
    end
end

function onFrameTouch( sender, eventType )
    -- Do nothing, just block touch event.
end