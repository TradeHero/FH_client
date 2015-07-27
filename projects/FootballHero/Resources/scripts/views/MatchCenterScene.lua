module(..., package.seeall)

local Constants = require("scripts.Constants")
local SceneManager = require("scripts.SceneManager")
local Navigator = require("scripts.views.Navigator")
local TeamConfig = require("scripts.config.Team")
local MatchCenterConfig = require("scripts.config.MatchCenter")
local Logic = require("scripts.Logic").getInstance()
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local Header = require("scripts.views.HeaderFrame")
local SportsConfig = require("scripts.config.Sports")


local mWidget

local mMatch
local mMarketsInfo

local MIN_MOVE_DISTANCE = 100
local SWITCH_MOVE_TIME = 0.4

local CONTENT_HEIGHT_LARGE = 960
local CONTENT_HEIGHT_SMALL = 600
local CONTENT_HEIGHT_SPEED = 30

local mBigBetStatus = {}

function loadFrame( jsonResponse, tabID )
    
    if jsonResponse["GameInformation"] == nil then
        mMatch = Logic:getSelectedMatch()
    else
        mMatch = jsonResponse["GameInformation"]
        Logic:setSelectedMatch( mMatch )
    end
    
    mTabID = tabID
    
	mWidget = GUIReader:shareReader():widgetFromJsonFile("scenes/MatchCenterTopScene.json") 
    mWidget:registerScriptHandler( EnterOrExit )
    SceneManager.clearNAddWidget( mWidget )
    
    Header.loadFrame( mWidget, Constants.String.match_center.title, true )
    Navigator.loadFrame( mWidget )

    -- init Last Meetings, Discussion header tab
    initMatchCenterTab()
    
    initMatchPredictionContent()
    
    loadMainContent( jsonResponse )
end

function refreshFrame( jsonResponse, tabID )
    mTabID = tabID

    -- init Last Meetings, Discussion header tab
    initMatchCenterTab()
    loadMainContent( jsonResponse )
end

function isShown()
    return mWidget ~= nil
end

function EnterOrExit( eventType )
    if eventType == "enter" then
    elseif eventType == "exit" then
        mWidget = nil
    end
end

function loadMainContent( jsonResponse )

    local contentContainer = mWidget:getChildByName("Panel_Content")
    contentContainer:removeAllChildrenWithCleanup( true )

    if mTabID == MatchCenterConfig.MATCH_CENTER_TAB_ID_MEETINGS then
        loadLastMeetingsScene( contentContainer, jsonResponse )
    elseif mTabID == MatchCenterConfig.MATCH_CENTER_TAB_ID_DISCUSSION then
        loadDiscussionsScene( contentContainer, jsonResponse )
    end
end

function initMatchCenterTab()
    local fade = mWidget:getChildByName("Panel_Fade")
    for i = 1, table.getn( MatchCenterConfig.MatchCenterType ) do
        
        local tab = tolua.cast( fade:getChildByName( MatchCenterConfig.MatchCenterType[i]["id"] ), "Button" )
        tab:setTitleText( Constants.String.match_center[MatchCenterConfig.MatchCenterType[i]["displayNameKey"]] )

        local isActive = mTabID == i

        if isActive then
            tab:setBright( false )
            tab:setTouchEnabled( false )
            tab:setTitleColor( ccc3( 255, 255, 255 ) )
        else
            local eventHandler = function( sender, eventType )
                if eventType == TOUCH_EVENT_ENDED then
                    if MatchCenterConfig.MatchCenterType[i]["enabled"] then
                        onSelectTab( i )
                    else
                        EventManager:postEvent( Event.Show_Info, { Constants.String.info.coming_soon } )
                    end
                end
            end
            tab:addTouchEventListener( eventHandler )
        
            tab:setBright( true )
            tab:setTouchEnabled( true )
            tab:setTitleColor( ccc3( 127, 127, 127 ) )
        end
    end
end

function initMatchPredictionContent()
    
    local fade = mWidget:getChildByName("Panel_Fade")
    
    local date = tolua.cast( fade:getChildByName("Label_Date"), "Label" )
    local played = tolua.cast( fade:getChildByName("Label_Played"), "Label" )
    local playedCount = tolua.cast( fade:getChildByName("Label_PlayedCount"), "Label" )
    local predict = tolua.cast( fade:getChildByName("Button_Prediction"), "Button" )
    local discussion = tolua.cast( fade:getChildByName("Button_Discussion"), "Button" )
    local meetings = tolua.cast( fade:getChildByName("Button_Meetings"), "Button" )
    local compName = tolua.cast( fade:getChildByName("Label_CompetitionName"), "Label" )
    local lbTotalFans = tolua.cast( fade:getChildByName("Label_Fans"), "Label" )
    local fansCount = tolua.cast( fade:getChildByName("Label_FansCount"), "Label" )

    local team1 = tolua.cast( fade:getChildByName("Image_Team1"), "ImageView" )
    local team2 = tolua.cast( fade:getChildByName("Image_Team2"), "ImageView" )
    local team1Name = tolua.cast( fade:getChildByName("Label_Team1"), "Label" )
    local team2Name = tolua.cast( fade:getChildByName("Label_Team2"), "Label" )
    local vs = tolua.cast( fade:getChildByName("Label_VS"), "Label" )

    local homePercent = tolua.cast( fade:getChildByName("Label_HomePercent"), "Label" )
    local awayPercent = tolua.cast( fade:getChildByName("Label_AwayPercent"), "Label" )
    local drawPercent = tolua.cast( fade:getChildByName("Label_DrawPercent"), "Label" )
    local lbDraw = tolua.cast( fade:getChildByName("Label_Draw"), "Label" )

    if not SportsConfig.isCurrentSportHasDraw() then
        lbDraw:setEnabled( false )
        drawPercent:setEnabled( false )
        fade:getChildByName("Label_SeparatorHome"):setEnabled( false )
        fade:getChildByName("Label_SeparatorAway"):setEnabled( false )
    end

    lbDraw:setText( Constants.String.match_list.draw )
    lbTotalFans:setText( Constants.String.match_list.total_fans )
    fansCount:setText( mMatch["TotalUsersPlayed"] )
    
    local totalWinPredictions = mMatch["HomePredictions"] + mMatch["AwayPredictions"] + mMatch["DrawPredictions"]
    local homeWinPercent = 0
    local awayWinPercent = 0
    local drawWinPercent = 0
    if totalWinPredictions > 0 then
        homeWinPercent = mMatch["HomePredictions"] / totalWinPredictions * 100
        awayWinPercent = mMatch["AwayPredictions"] / totalWinPredictions * 100
        drawWinPercent = mMatch["DrawPredictions"] / totalWinPredictions * 100
    end
    homePercent:setText( string.format( homePercent:getStringValue(), homeWinPercent ) )
    awayPercent:setText( string.format( awayPercent:getStringValue(), awayWinPercent ) )
    drawPercent:setText( string.format( drawPercent:getStringValue(), drawWinPercent ) )

    compName:setText( mMatch["LeagueName"] )
    
    date:setText( os.date( "%b %d, %H:%M", mMatch["StartTime"] ) )
    played:setText( Constants.String.match_center.played )
    playedCount:setText( string.format( Constants.String.match_center.played_out_of, mMatch["PredictionsPlayed"], mMatch["PredictionsAvailable"] ) )
    discussion:setTitleText( Constants.String.match_center.title_discussion )
    meetings:setTitleText( Constants.String.match_center.title_meetings )

    if mMatch["PredictionsAvailable"] > 0 and mMatch["PredictionsPlayed"] == mMatch["PredictionsAvailable"] then
        predict:setTitleText( Constants.String.match_center.prediction_made )
        predict:setBright( false )
        predict:setTitleColor( ccc3( 127, 127, 127 ) )
    elseif mMatch["StartTime"] <= os.time() then
        predict:setBright( false )
        predict:setTitleColor( ccc3( 127, 127, 127 ) )
    else
        predict:setTitleText( Constants.String.match_center.make_prediction )

        local eventHandler = function( sender, eventType )
            if eventType == TOUCH_EVENT_ENDED then
                enterMatch()
            end
        end
        predict:addTouchEventListener( eventHandler )
    end

    team1:loadTexture( TeamConfig.getLogo( TeamConfig.getConfigIdByKey( mMatch["HomeTeamId"] ), true ) )
    team2:loadTexture( TeamConfig.getLogo( TeamConfig.getConfigIdByKey( mMatch["AwayTeamId"] ), false ) )
    team1Name:setText( TeamConfig.getTeamName( TeamConfig.getConfigIdByKey( mMatch["HomeTeamId"] ) ) )
    team2Name:setText( TeamConfig.getTeamName( TeamConfig.getConfigIdByKey( mMatch["AwayTeamId"] ) ) )
    vs:setText( Constants.String.vs )
end

function loadLastMeetingsScene( contentContainer, jsonResponse )
    local MatchCenterStatsScene = require("scripts.views.MatchCenterStatsScene")
    MatchCenterStatsScene.loadFrame( contentContainer, jsonResponse )
end

function loadDiscussionsScene( contentContainer, jsonResponse )
    local MatchCenterDiscussionsFrame = require("scripts.views.MatchCenterDiscussionsFrame")
    MatchCenterDiscussionsFrame.loadFrame( contentContainer, jsonResponse, showMatchInfo )
end

function onSelectTab( tabID )
    EventManager:postEvent( Event.Enter_Match_Center, { tabID, mMatch["Id"] } )
end

function enterMatch()
    EventManager:postEvent( Event.Enter_Match, { mMatch["Id"] } )
end

function showMatchInfo( bShow )
    local contentContainer = mWidget:getChildByName("Panel_Content")
    local currentHeight = contentContainer:getSize().height
    local newHeight =currentHeight

    if bShow then
        newHeight = currentHeight - CONTENT_HEIGHT_SPEED

        if newHeight <= CONTENT_HEIGHT_SMALL then
            newHeight = CONTENT_HEIGHT_SMALL
        end
        
    else
        newHeight = currentHeight + CONTENT_HEIGHT_SPEED

        if newHeight >= CONTENT_HEIGHT_LARGE then
            newHeight = CONTENT_HEIGHT_LARGE
        end
    end

    if newHeight ~= currentHeight then
        contentContainer:setSize( CCSize:new( contentContainer:getSize().width, newHeight ) )
        local layout = tolua.cast( contentContainer, "Layout" )
        layout:requestDoLayout()
    end
end
