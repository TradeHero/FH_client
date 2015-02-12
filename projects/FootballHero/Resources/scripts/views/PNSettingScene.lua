module(..., package.seeall)

local SceneManager = require("scripts.SceneManager")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local PushNotificationManager = require("scripts.PushNotificationManager")
local Constants = require("scripts.Constants")
local Header = require("scripts.views.HeaderFrame")

local mWidget

function loadFrame()
    local widget = GUIReader:shareReader():widgetFromJsonFile("scenes/PushNotification.json")
    mWidget = widget
    mWidget:registerScriptHandler( EnterOrExit )
    SceneManager.clearNAddWidget( widget )

    Header.loadFrame( mWidget, Constants.String.settings.push_notification, true )

    local general = tolua.cast( widget:getChildByName("Label_General"), "Label" )
    local prediction = tolua.cast( widget:getChildByName("Label_Prediction"), "Label" )

    general:setText( Constants.String.settings.general )
    prediction:setText( Constants.String.settings.prediction )

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

function generalCheckHandler( sender,eventType )
    if eventType == TOUCH_EVENT_ENDED then
        local check = tolua.cast( sender, "CheckBox" )
        PushNotificationManager.setGeneralSwitch( not check:getSelectedState() )
        
        AudioEngine.playEffect( AudioEngine.SETTINGS_ON_OFF )
    end
end

function predictionCheckHandler( sender,eventType )
    if eventType == TOUCH_EVENT_ENDED then
        local check = tolua.cast( sender, "CheckBox" )
        PushNotificationManager.setPredictionSwitch( not check:getSelectedState() )

        AudioEngine.playEffect( AudioEngine.SETTINGS_ON_OFF )
    end
end