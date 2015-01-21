module(..., package.seeall)

local Constants = require("scripts.Constants")
local SceneManager = require("scripts.SceneManager")
local Navigator = require("scripts.views.Navigator")
local TeamConfig = require("scripts.config.Team")
local MatchCenterConfig = require("scripts.config.MatchCenter")
local Logic = require("scripts.Logic").getInstance()
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList

local mWidget

local mMatch
local mMarketsInfo

local MIN_MOVE_DISTANCE = 100
local SWITCH_MOVE_TIME = 0.4

local mBigBetStatus = {}

function loadFrame( jsonResponse, tabID )
    
    mMatch = Logic:getSelectedMatch()
    mTabID = tabID
    
	mWidget = GUIReader:shareReader():widgetFromJsonFile("scenes/MatchCenterTopScene.json")
    mWidget:registerScriptHandler( EnterOrExit )
    SceneManager.clearNAddWidget( mWidget )
    SceneManager.setKeypadBackListener( keypadBackEventHandler )
    
    Navigator.loadFrame( mWidget )

    -- init Last Meetings, Discussion header tab
    initMatchCenterTab()
    
    initMatchPredictionContent()
    
    loadMainContent( jsonResponse, tabID )

    local backBt = mWidget:getChildByName("Button_Back")
    backBt:addTouchEventListener( backEventHandler )
end

function refreshFrame( jsonResponse, tabID )
    mTabID = tabID

    -- init Last Meetings, Discussion header tab
    initMatchCenterTab()
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

function backEventHandler( sender, eventType )
    if eventType == TOUCH_EVENT_ENDED then
        keypadBackEventHandler()
    end
end

function keypadBackEventHandler()
    EventManager:popHistory()
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
    for i = 1, table.getn( MatchCenterConfig.MatchCenterType ) do
        
        local tab = tolua.cast( mWidget:getChildByName( MatchCenterConfig.MatchCenterType[i]["id"] ), "Button" )
        tab:setTitleText( Constants.String.match_center[MatchCenterConfig.MatchCenterType[i]["displayNameKey"]] )

        local isActive = mTabID == i

        if isActive then
            tab:setBright( false )
            tab:setTouchEnabled( false )
            tab:setTitleColor( ccc3( 255, 255, 255 ) )
        else

            if MatchCenterConfig.MatchCenterType[i]["enabled"] then
                local eventHandler = function( sender, eventType )
                    if eventType == TOUCH_EVENT_ENDED then
                        onSelectTab( i )
                    end
                end
                tab:addTouchEventListener( eventHandler )
            end
            tab:setBright( true )
            tab:setTouchEnabled( true )
            tab:setTitleColor( ccc3( 127, 127, 127 ) )
        end
    end
end

function initMatchPredictionContent()
    local title = tolua.cast( mWidget:getChildByName("Label_Title"), "Label" )
    local date = tolua.cast( mWidget:getChildByName("Label_Date"), "Label" )
    local played = tolua.cast( mWidget:getChildByName("Label_Played"), "Label" )
    local predict = tolua.cast( mWidget:getChildByName("Button_Prediction"), "Button" )
    local discussion = tolua.cast( mWidget:getChildByName("Button_Discussion"), "Button" )
    local meetings = tolua.cast( mWidget:getChildByName("Button_Meetings"), "Button" )

    local team1 = tolua.cast( mWidget:getChildByName("Image_Team1"), "ImageView" )
    local team2 = tolua.cast( mWidget:getChildByName("Image_Team2"), "ImageView" )
    local team1Name = tolua.cast( mWidget:getChildByName("Label_Team1"), "Label" )
    local team2Name = tolua.cast( mWidget:getChildByName("Label_Team2"), "Label" )
    local vs = tolua.cast( mWidget:getChildByName("Label_VS"), "Label" )

    title:setText( Constants.String.match_center.title )
    date:setText( os.date( "%b %d, %H:%M", mMatch["StartTime"] ) )
    played:setText( string.format( Constants.String.match_center.played, mMatch["PredictionsPlayed"], mMatch["PredictionsAvailable"] ) )
    discussion:setTitleText( Constants.String.match_center.title_discussion )
    meetings:setTitleText( Constants.String.match_center.title_meetings )

    if mMatch["PredictionsAvailable"] > 0 and mMatch["PredictionsPlayed"] == mMatch["PredictionsAvailable"] then
        predict:setTitleText( Constants.String.match_center.prediction_made )
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

    team1:loadTexture( TeamConfig.getLogo( TeamConfig.getConfigIdByKey( mMatch["HomeTeamId"] ) ) )
    team2:loadTexture( TeamConfig.getLogo( TeamConfig.getConfigIdByKey( mMatch["AwayTeamId"] ) ) )
    team1Name:setText( TeamConfig.getTeamName( TeamConfig.getConfigIdByKey( mMatch["HomeTeamId"] ) ) )
    team2Name:setText( TeamConfig.getTeamName( TeamConfig.getConfigIdByKey( mMatch["AwayTeamId"] ) ) )
    vs:setText( Constants.String.vs )
end

function loadLastMeetingsScene( contentContainer, jsonResponse )
    --TODO
end

function loadDiscussionsScene( contentContainer, jsonResponse )
    local MatchCenterDiscussionsFrame = require("scripts.views.MatchCenterDiscussionsFrame")
    MatchCenterDiscussionsFrame.loadFrame( contentContainer, jsonResponse )
end

function onSelectTab( tabID )
    EventManager:postEvent( Event.Enter_Match_Center, { tabID, 1, 1 } )
end

function enterMatch()
    EventManager:postEvent( Event.Enter_Match, { mMatch["Id"] } )
end
