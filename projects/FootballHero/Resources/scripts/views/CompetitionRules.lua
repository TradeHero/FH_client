module(..., package.seeall)

local SceneManager = require("scripts.SceneManager")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local Navigator = require("scripts.views.Navigator")
local Constants = require("scripts.Constants")
local CompetitionsConfig = require("scripts.config.Competitions")
local Navigator = require("scripts.views.Navigator")


local mWidget

function loadFrame( token )
	local widget = GUIReader:shareReader():widgetFromJsonFile("scenes/CompetitionRules.json")
    mWidget = widget
    mWidget:registerScriptHandler( EnterOrExit )
    SceneManager.clearNAddWidget( widget )
    SceneManager.setKeypadBackListener( keypadBackEventHandler )

    Navigator.loadFrame( widget )

    local backBt = widget:getChildByName("back")
    backBt:addTouchEventListener( backEventHandler )
    local ruleContent = tolua.cast( widget:getChildByName("ruleContent"), "Label" )
    local competitionId = CompetitionsConfig.getConfigIdByKey( token )
    ruleContent:setText( CompetitionsConfig.getRules( competitionId ) )
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