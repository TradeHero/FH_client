module(..., package.seeall)

local SceneManager = require("scripts.SceneManager")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local Constants = require("scripts.Constants")
local Navigator = require("scripts.views.Navigator")
local Header = require("scripts.views.HeaderFrame")

local mWidget 

function loadFrame()
    local widget = GUIReader:shareReader():widgetFromJsonFile( "scenes/lucky8MainScene.json" )
    mWidget = widget
    widget:registerScriptHandler( EnterOrExit )
    SceneManager.clearNAddWidget( widget )
    Header.loadFrame( widget, Constants.String.lucky8.lucky8_title, true )
    Navigator.loadFrame( widget )

    initButtonInfo()
end

function getCurrentTime(  )
    local currentTime = os.time()
    local currentDate = os.date( "%B %")
end

function initButtonInfo(  )
    local btnPicks = tolua.cast( mWidget:getChildByName( "Button_Picks" ), "Button" )  
    btnPicks:setTitleText( Constants.String.lucky8.btn_picks_title )

    local btnMatchLists = tolua.cast( mWidget:getChildByName( "Button_MatchLists" ), "Button" )
    getCurrentTime()

    local btnRules = tolua.cast( mWidget:getChildByName( "Button_Rules" ), "Button" )
    btnRules:setTitleText( Constants.String.lucky8.btn_rules_title )
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
