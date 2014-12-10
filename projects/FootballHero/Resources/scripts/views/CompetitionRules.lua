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
    
    local competitionId = CompetitionsConfig.getConfigIdByKey( token )
    local competitionRulesContent = CompetitionsConfig.getRules( competitionId )
    local competitionRulesHeight = CompetitionsConfig.getRulesContentHeight( competitionId )

    local rules = tolua.cast( widget:getChildByName( "title"), "Label" )
    rules:setText( Constants.String.community.title_rules )

    local disclaimer = tolua.cast( widget:getChildByName( "disclaimer"), "Label" )
    disclaimer:setText( Constants.String.community.disclaimer )

    local ruleContentContainer = tolua.cast( widget:getChildByName("ScrollView_ruleContent"), "ScrollView" )
    local ruleContent = tolua.cast( ruleContentContainer:getChildByName("ruleContent"), "Label" )
    ruleContent:setText( competitionRulesContent )
    ruleContent:setSize( CCSize:new( ruleContent:getSize().width, competitionRulesHeight ) )
    ruleContent:setTextAreaSize( CCSize:new( ruleContent:getSize().width, competitionRulesHeight ) )

    ruleContentContainer:setInnerContainerSize( CCSize:new( 0, competitionRulesHeight ) )
    ruleContentContainer:requestDoLayout()
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
    EventManager:popHistory()
end