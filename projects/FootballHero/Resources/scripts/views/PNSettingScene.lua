module(..., package.seeall)

local SceneManager = require("scripts.SceneManager")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local PushNotificationManager = require("scripts.PushNotificationManager")
local Constants = require("scripts.Constants")

local mWidget

function loadFrame()
    local widget = GUIReader:shareReader():widgetFromJsonFile("scenes/PushNotification.json")
    mWidget = widget
    mWidget:registerScriptHandler( EnterOrExit )
    SceneManager.clearNAddWidget( widget )
    SceneManager.setKeypadBackListener( keypadBackEventHandler )

    local backBt = widget:getChildByName("back")
    backBt:addTouchEventListener( backEventHandler )

    local generalCheck = tolua.cast( mWidget:getChildByName("generalCheck"), "CheckBox" )
    generalCheck:addTouchEventListener( generalCheckHandler )
    if PushNotificationManager.getGeneralSwitch() then
        generalCheck:setSelectedState( true )
    end

    local predictionCheck = tolua.cast( mWidget:getChildByName("predictionCheck"), "CheckBox" )
    predictionCheck:addTouchEventListener( predictionCheckHandler )
    if PushNotificationManager.getPredictionSwitch() then
        predictionCheck:setSelectedState( true )
    end
end

function EnterOrExit( eventType )
    if eventType == "enter" then
    elseif eventType == "exit" then
        mWidget = nil
    end
end

function isFrameShown()
    return mWidget ~= nil
end

function backEventHandler( sender,eventType )
    if eventType == TOUCH_EVENT_ENDED then
        keypadBackEventHandler()
    end
end

function keypadBackEventHandler()
    WebviewDelegate:sharedDelegate():closeWebpage()
    EventManager:popHistory()
end

function generalCheckHandler( sender,eventType )
    if eventType == TOUCH_EVENT_ENDED then
        if CCUserDefault:sharedUserDefault():getBoolForKey( Constants.NOTIFICATION_KEY_SFX ) == true then
            AudioEngine.playEffect( AudioEngine.SETTINGS_ON_OFF )
        end

        local check = tolua.cast( sender, "CheckBox" )
        PushNotificationManager.setGeneralSwitch( not check:getSelectedState() )
    end
end

function predictionCheckHandler( sender,eventType )
    if eventType == TOUCH_EVENT_ENDED then
        if CCUserDefault:sharedUserDefault():getBoolForKey( Constants.NOTIFICATION_KEY_SFX ) == true then
            AudioEngine.playEffect( AudioEngine.SETTINGS_ON_OFF )
        end

        local check = tolua.cast( sender, "CheckBox" )
        PushNotificationManager.setPredictionSwitch( not check:getSelectedState() )
    end
end