module(..., package.seeall)

local SceneManager = require("scripts.SceneManager")
local Navigator = require("scripts.views.Navigator")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local SettingsConfig = require("scripts.config.Settings")
local SpinWheelConfig = require("scripts.config.SpinWheel")
local Constants = require("scripts.Constants")

local mWidget

function loadFrame()
	local widget = GUIReader:shareReader():widgetFromJsonFile("scenes/SpinWheel.json")
    mWidget = widget

    widget:registerScriptHandler( EnterOrExit )
    SceneManager.clearNAddWidget( widget )
    SceneManager.setKeypadBackListener( keypadBackEventHandler )

    local backBt = widget:getChildByName("Button_Back")
    backBt:addTouchEventListener( backEventHandler )

    Navigator.loadFrame( widget )

    initContent()
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

function initContent()
    local wheelBG = mWidget:getChildByName("wheelBG")

    for i = 1, table.getn( SpinWheelConfig.Prizes ) do
        local prize = tolua.cast( wheelBG:getChildByName("prize"..i), "ImageView" )
        local text = tolua.cast (wheelBG:getChildByName("text"..i), "Label" )
        local config = SpinWheelConfig.Prizes[i]

        prize:loadTexture( config["image"] )
        text:setText( config["text"] )
        
    end
end