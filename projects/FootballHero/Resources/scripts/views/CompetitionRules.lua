module(..., package.seeall)

local SceneManager = require("scripts.SceneManager")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local Navigator = require("scripts.views.Navigator")
local Constants = require("scripts.Constants")
local CompetitionsConfig = require("scripts.config.Competitions")
local Navigator = require("scripts.views.Navigator")
local Header = require("scripts.views.HeaderFrame")

local mWidget

function loadFrame( token )
	local widget = SceneManager.secondLayerWidgetFromJsonFile("scenes/CompetitionRules.json")
    mWidget = widget
    mWidget:registerScriptHandler( EnterOrExit )
    SceneManager.clearNAddWidget( widget )
    
    Header.loadFrame( widget, Constants.String.community.title_rules, true )

    Navigator.loadFrame( widget )
    
    local competitionId = CompetitionsConfig.getConfigIdByKey( token )
    local competitionRulesContent = CompetitionsConfig.getRules( competitionId )
    local competitionRulesHeight = CompetitionsConfig.getRulesContentHeight( competitionId )

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
