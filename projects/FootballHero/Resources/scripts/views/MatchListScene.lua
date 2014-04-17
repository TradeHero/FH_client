module(..., package.seeall)

local Constants = require("scripts.Constants")
local SceneManager = require("scripts.SceneManager")
local TeamConfig = require("scripts.config.Team")
local MatchConfig = require("scripts.config.Match")
local Navigator = require("scripts.views.Navigator")
local Logic = require("scripts.Logic").getInstance()
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList


local mMatchNum = MatchConfig.getConfigNum()

function loadFrame()
	local widget = GUIReader:shareReader():widgetFromJsonFile("scenes/MatchList/MatchListScene.json")
    SceneManager.clearNAddWidget( widget )

    Navigator.loadFrame()

    local contentContainer = tolua.cast( widget:getChildByName("ScrollView"), "ScrollView" )
    local layoutParameter = LinearLayoutParameter:create()
    layoutParameter:setGravity(LINEAR_GRAVITY_CENTER_VERTICAL)
    local contentHeight = 0

    -- Add the date
    local content = GUIReader:shareReader():widgetFromJsonFile("scenes/MatchList/MatchDate.json")
    content:setLayoutParameter( layoutParameter )
    contentContainer:addChild( content )
    contentHeight = contentHeight + content:getSize().height

    -- Add the seprater
    local upper = ImageView:create()
    upper:loadTexture("images/guang.png")
    upper:setLayoutParameter( layoutParameter )
    contentContainer:addChild( upper )
    contentHeight = contentHeight + upper:getSize().height

    for i = 1, mMatchNum do
        local eventHandler = function( sender, eventType )
            if eventType == TOUCH_EVENT_ENDED then
                enterMatch( i )
            end
        end

        local content = GUIReader:shareReader():widgetFromJsonFile("scenes/MatchList/MatchListContent.ExportJson")
        helperInitMatchInfo( content, i )

        content:setLayoutParameter( layoutParameter )
        contentContainer:addChild( content )
        contentHeight = contentHeight + content:getSize().height

        local vsBt = content:getChildByName("VS")
        vsBt:addTouchEventListener( eventHandler )
    end

    -- Add the seprater
    local bottom = ImageView:create()
    bottom:loadTexture("images/guang-xia.png")
    bottom:setLayoutParameter( layoutParameter )
    contentContainer:addChild( bottom )
    contentHeight = contentHeight + bottom:getSize().height

    contentContainer:setInnerContainerSize( CCSize:new( 0, contentHeight ) )
    local layout = tolua.cast( contentContainer, "Layout" )
    layout:requestDoLayout()
end

function enterMatch( index )
    Logic:setSelectedMatchIndex( index )
    EventManager:postEvent( Event.Enter_Match )
end

function helperInitMatchInfo( content, matchIndex )
    local team1 = tolua.cast( content:getChildByName("team1"), "ImageView" )
    local team2 = tolua.cast( content:getChildByName("team2"), "ImageView" )
    local team1Name = tolua.cast( content:getChildByName("team1Name"), "Label" )
    local team2Name = tolua.cast( content:getChildByName("team2Name"), "Label" )
    team1:loadTexture( Constants.TEAM_IMAGE_PATH..TeamConfig.getLogo( MatchConfig.getTeam1( matchIndex ) ) )
    team2:loadTexture( Constants.TEAM_IMAGE_PATH..TeamConfig.getLogo( MatchConfig.getTeam2( matchIndex ) ) )
    team1Name:setText( TeamConfig.getDisplayName( MatchConfig.getTeam1( matchIndex ) ) )
    team2Name:setText( TeamConfig.getDisplayName( MatchConfig.getTeam2( matchIndex ) ) )
    team1Name:setFontName("fonts/Newgtbxc.ttf")
    team2Name:setFontName("fonts/Newgtbxc.ttf")

    local previousPrediction = Logic:getPrediction( matchIndex )
    local vsBt = tolua.cast( content:getChildByName("VS"), "Button" )
    if previousPrediction == nil then
        vsBt:setBright( true )
        vsBt:setTouchEnabled( true )
    else
        vsBt:setBright( false )
        vsBt:setTouchEnabled( false )
    end
end