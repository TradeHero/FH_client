module(..., package.seeall)

local Constants = require("scripts.Constants")
local SceneManager = require("scripts.SceneManager")
local TeamConfig = require("scripts.config.Team")
local MarketConfig = require("scripts.config.Market")
local Logic = require("scripts.Logic").getInstance()
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local MarketsForGameData = require("scripts.data.MarketsForGameData")

local mWidget
local mMatch
local mMarketsData

local MIN_MOVE_DISTANCE = 100
local SCALE_BASE = 0.8
local SCALE_UP_OFFSET_MAX = 0.2
local SCALE_DOWN_OFFSET_MAX = -0.2
local OPACITY = 255


function loadFrame()
	local widget = GUIReader:shareReader():widgetFromJsonFile("scenes/MatchPrediction.json")
    mMatch = Logic:getSelectedMatch()
    mMarketsData = Logic:getCurMarketInfo():getMatchMarket()

    local backBt = widget:getChildByName("Back")
    backBt:addTouchEventListener( backEventHandler )

    helperInitMatchInfo( widget )

    widget:addTouchEventListener( onFrameTouch )
    mWidget = widget
    mWidget:registerScriptHandler( EnterOrExit )
    SceneManager.clearNAddWidget(widget)
end

function EnterOrExit( eventType )
    if eventType == "enter" then
    elseif eventType == "exit" then
        mWidget = nil
    end
end

function selectTeam1Win()
    local team1 = tolua.cast( mWidget:getChildByName("team1"), "ImageView" )
    makePrediction(
        MarketsForGameData.getOddsForType( mMarketsData, MarketConfig.ODDS_TYPE_ONE_OPTION ),
        MarketsForGameData.getOddIdForType( mMarketsData, MarketConfig.ODDS_TYPE_ONE_OPTION ),
        TeamConfig.getTeamName( TeamConfig.getConfigIdByKey( mMatch["HomeTeamId"] ) ).." to win.",
        team1:getTextureFile() )
end

function selectTeam2Win()
    local team2 = tolua.cast( mWidget:getChildByName("team2"), "ImageView" )
    makePrediction(
        MarketsForGameData.getOddsForType( mMarketsData, MarketConfig.ODDS_TYPE_TWO_OPTION ),
        MarketsForGameData.getOddIdForType( mMarketsData, MarketConfig.ODDS_TYPE_TWO_OPTION ),
        TeamConfig.getTeamName( TeamConfig.getConfigIdByKey( mMatch["AwayTeamId"] ) ).." to win.",
        team2:getTextureFile() )
end

function backEventHandler( sender, eventType )
    if eventType == TOUCH_EVENT_ENDED then
        EventManager:postEvent( Event.Enter_Match_List )
    end
end

function makePrediction( rewards, oddId, answer, answerIcon )
    local seqArray = CCArray:create()
    seqArray:addObject( CCDelayTime:create( 0.1 ) )
    seqArray:addObject( CCCallFuncN:create( function()
        --EventManager:postEvent( Event.Enter_Prediction_Confirm, { answer, rewards, oddId, answerIcon } )

        Logic:addPrediction( oddId, "", false, answer, rewards, answerIcon )
        EventManager:postEvent( Event.Enter_Next_Prediction )
    end ) )

    mWidget:runAction( CCSequence:create( seqArray ) )
    
end

function helperUpdatePoint( content )
    local point = Logic:getPoint()
    local pointLabel = tolua.cast( content:getChildByName("myPoint"), "Label" )
    pointLabel:setText( point )
end

function helperInitMatchInfo( content, marketsData )
    local team1 = tolua.cast( content:getChildByName("team1"), "ImageView" )
    local team2 = tolua.cast( content:getChildByName("team2"), "ImageView" )
    local team1Name = tolua.cast( content:getChildByName("team1Name"), "Label" )
    local team2Name = tolua.cast( content:getChildByName("team2Name"), "Label" )
    local team1WinPoint = tolua.cast( team1:getChildByName("team1WinPoint"), "Label" )
    local team2WinPoint = tolua.cast( team2:getChildByName("team2WinPoint"), "Label" )

    team1:loadTexture( TeamConfig.getLogo( TeamConfig.getConfigIdByKey( mMatch["HomeTeamId"] ) ) )
    team2:loadTexture( TeamConfig.getLogo( TeamConfig.getConfigIdByKey( mMatch["AwayTeamId"] ) ) )
    team1Name:setText( TeamConfig.getTeamName( TeamConfig.getConfigIdByKey( mMatch["HomeTeamId"] ) ) )
    team2Name:setText( TeamConfig.getTeamName( TeamConfig.getConfigIdByKey( mMatch["AwayTeamId"] ) ) )
    team1WinPoint:setText( MarketsForGameData.getOddsForType( mMarketsData, MarketConfig.ODDS_TYPE_ONE_OPTION ).." points" )
    team2WinPoint:setText( MarketsForGameData.getOddsForType( mMarketsData, MarketConfig.ODDS_TYPE_TWO_OPTION ).." points" )
end


function onFrameTouch( sender, eventType )
    local team1 = tolua.cast( mWidget:getChildByName("team1"), "ImageView" )
    local team2 = tolua.cast( mWidget:getChildByName("team2"), "ImageView" )
    if eventType == TOUCH_EVENT_ENDED then
        local touchBeginPoint = sender:getTouchStartPos()
        local touchEndPoint = sender:getTouchEndPos()
        if touchBeginPoint.x - touchEndPoint.x > MIN_MOVE_DISTANCE then
            -- Swap to Left
            selectTeam2Win()
        elseif touchBeginPoint.x - touchEndPoint.x < MIN_MOVE_DISTANCE * (-1) then
            -- Swap to Right
            selectTeam1Win()
        else
            team1:setScale( SCALE_BASE )
            team2:setScale( SCALE_BASE )
            team1:setOpacity( OPACITY )
            team2:setOpacity( OPACITY )
        end
    elseif eventType == TOUCH_EVENT_MOVED then
        local touchBeginPoint = sender:getTouchStartPos()
        local touchMovPoint = sender:getTouchMovePos()

        local scalePercentage = math.abs( touchBeginPoint.x - touchMovPoint.x ) / MIN_MOVE_DISTANCE
        if scalePercentage > 1 then
            scalePercentage = 1
        end
        if touchBeginPoint.x - touchMovPoint.x > 0 then
            team2:setScale( scalePercentage * SCALE_UP_OFFSET_MAX + SCALE_BASE )
            team1:setScale( scalePercentage * SCALE_DOWN_OFFSET_MAX + SCALE_BASE )
            team2:setOpacity( OPACITY )
            team1:setOpacity( OPACITY / 3 )
        else
            team1:setScale( scalePercentage * SCALE_UP_OFFSET_MAX + SCALE_BASE )
            team2:setScale( scalePercentage * SCALE_DOWN_OFFSET_MAX + SCALE_BASE )
            team1:setOpacity( OPACITY )
            team2:setOpacity( OPACITY / 3 )
        end
    end
end