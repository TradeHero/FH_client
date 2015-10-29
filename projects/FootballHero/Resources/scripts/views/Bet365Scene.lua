module(..., package.seeall)

local SceneManager = require("scripts.SceneManager")
local Constants = require("scripts.Constants")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local Json = require("json")

local mWidget
local mAwardWidget

function loadFrame()
    local widget = SceneManager.secondLayerWidgetFromJsonFile("scenes/Bet365Scene.json")
    mWidget = widget
    mWidget:registerScriptHandler( EnterOrExit )
    SceneManager.clearNAddWidget( widget )
    SceneManager.clearKeypadBackListener()
    SceneManager.setKeypadBackListener( keypadBackEventHandler )

    local btnBack = mWidget:getChildByName("Button_Back")
    btnBack:addTouchEventListener( backEventHandler )

    local btnBet = mWidget:getChildByName("Button_Bet")
    btnBet:addTouchEventListener( betEventHandler )
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

function keypadBackEventHandler()
    EventManager:popHistory()
end

function backEventHandler( sender, eventType )
    if eventType == TOUCH_EVENT_ENDED then
        keypadBackEventHandler()
    end
end

function betEventHandler( sender, eventType )
    if eventType == TOUCH_EVENT_ENDED then
        local params = { Action = "bet365" }
        Analytics:sharedDelegate():postEvent( Constants.ANALYTICS_EVENT_BET365, Json.encode( params ) )
        Analytics:sharedDelegate():postFlurryEvent( Constants.ANALYTICS_EVENT_BET365, Json.encode( params ) )
        Misc:sharedDelegate():openUrl( Constants.BET365_URL )
    end
end
