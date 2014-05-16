module(..., package.seeall)

local Constants = require("scripts.Constants")
local SceneManager = require("scripts.SceneManager")
local TeamConfig = require("scripts.config.Team")
local MarketConfig = require("scripts.config.Market")
local Logic = require("scripts.Logic").getInstance()
local MarketsForGameData = require("scripts.data.MarketsForGameData")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList

local mWidget
local mMatch
local mMarketsData

local MIN_MOVE_DISTANCE = 100
local SCALE_BASE = 0.6
local SCALE_UP_OFFSET_MAX = 0.2
local SCALE_DOWN_OFFSET_MAX = -0.2
local OPACITY = 255

function loadFrame()
    mMatch = Logic:getSelectedMatch()
    mMarketsData = Logic:getCurMarketInfo():getMarketAt( Logic:getCurDisplayMarketIndex() )

    local widget = GUIReader:shareReader():widgetFromJsonFile( getWidgetConfigFile() )
    mWidget = widget
    mWidget:registerScriptHandler( EnterOrExit )
    mWidget:addTouchEventListener( onFrameTouch )
    SceneManager.clearNAddWidget( widget )

    local backBt = widget:getChildByName("Back")
    local skipBt = widget:getChildByName("skip")
    backBt:addTouchEventListener( backEventHandler )
    skipBt:addTouchEventListener( skipEventHandler )

    helperInitMarketInfo( widget )
end

function EnterOrExit( eventType )
    if eventType == "enter" then
    elseif eventType == "exit" then
        mWidget = nil
    end
end

function getWidgetConfigFile()
    local marketType = MarketsForGameData.getMarketType( mMarketsData )

    if marketType == MarketConfig.MARKET_TYPE_TOTAL_GOAL then
        return "scenes/WTGBMTPrediction.json"
    elseif marketType == MarketConfig.MARKET_TYPE_ASIAN_HANDICAP then
        return "scenes/WTWBEGPrediction.json"
    end

    return "scenes/WTCBMTPrediction.json"
end

function selectYes()
    local yes = tolua.cast( mWidget:getChildByName("yes"), "ImageView" )
    makePrediction(
        MarketsForGameData.getOddsForType( mMarketsData, MarketConfig.ODDS_TYPE_ONE_OPTION ),
        MarketsForGameData.getOddIdForType( mMarketsData, MarketConfig.ODDS_TYPE_ONE_OPTION ),
        helperGetTheAnswer( true ),
        yes:getTextureFile() )
end

function selectNo()
    local no = tolua.cast( mWidget:getChildByName("no"), "ImageView" )
    makePrediction(
        MarketsForGameData.getOddsForType( mMarketsData, MarketConfig.ODDS_TYPE_TWO_OPTION ),
        MarketsForGameData.getOddIdForType( mMarketsData, MarketConfig.ODDS_TYPE_TWO_OPTION ),
        helperGetTheAnswer( false ),
        no:getTextureFile() )
end

function skipEventHandler( sender, eventType )
    if eventType == TOUCH_EVENT_ENDED then
        SceneManager.clear()
        EventManager:postEvent( Event.Enter_Next_Prediction )
    end
end

function backEventHandler( sender, eventType )
    if eventType == TOUCH_EVENT_ENDED then
        EventManager:postEvent( Event.Do_Post_Predictions )
    end
end

function makePrediction( rewards, oddId, answer, answerIcon )
    local seqArray = CCArray:create()
    seqArray:addObject( CCDelayTime:create( 0.1 ) )
    seqArray:addObject( CCCallFuncN:create( function()
        --EventManager:postEvent( Event.Enter_Prediction_Confirm, { answer, rewards, oddId, answerIcon } )

        Logic:addPrediction( oddId, "", false, answer, rewards, answerIcon )
        SceneManager.clear()
        EventManager:postEvent( Event.Enter_Next_Prediction )
    end ) )

    mWidget:runAction( CCSequence:create( seqArray ) )
    
end

function helperInitMarketInfo( content )
    local team1Name = tolua.cast( content:getChildByName("team1Name"), "Label" )
    local team2Name = tolua.cast( content:getChildByName("team2Name"), "Label" )
    local yes = tolua.cast( mWidget:getChildByName("yes"), "ImageView" )
    local no = tolua.cast( mWidget:getChildByName("no"), "ImageView" )
    local answer1Point = tolua.cast( yes:getChildByName("answer1Point"), "Label" )
    local answer2Point = tolua.cast( no:getChildByName("answer2Point"), "Label" )
    
    team1Name:setText( TeamConfig.getTeamName( TeamConfig.getConfigIdByKey( mMatch["HomeTeamId"] ) ) )
    team2Name:setText( TeamConfig.getTeamName( TeamConfig.getConfigIdByKey( mMatch["AwayTeamId"] ) ) )
    answer1Point:setText( MarketsForGameData.getOddsForType( mMarketsData, MarketConfig.ODDS_TYPE_ONE_OPTION ).." points" )
    answer2Point:setText( MarketsForGameData.getOddsForType( mMarketsData, MarketConfig.ODDS_TYPE_TWO_OPTION ).." points" )
    
    helperInitQuestion( content )
end

function helperInitQuestion( content )
    local marketType = MarketsForGameData.getMarketType( mMarketsData )
    local question = tolua.cast( content:getChildByName("question"), "Label" )

    local line = MarketsForGameData.getMarketLine( mMarketsData )
    if marketType == MarketConfig.MARKET_TYPE_TOTAL_GOAL then
        question:setText( string.format( question:getStringValue(), math.ceil( line ) ) )
    elseif marketType == MarketConfig.MARKET_TYPE_ASIAN_HANDICAP then
        local teamName = TeamConfig.getTeamName( TeamConfig.getConfigIdByKey( mMatch["AwayTeamId"] ) )
        if line < 0 then
            teamName = TeamConfig.getTeamName( TeamConfig.getConfigIdByKey( mMatch["HomeTeamId"] ) )
            line = line * ( -1 )
        end 
        question:setText( string.format( question:getStringValue(), teamName, math.ceil( line ) ) )
    end
end

function helperGetTheAnswer( answerId )
    local marketType = MarketsForGameData.getMarketType( mMarketsData )

    local line = MarketsForGameData.getMarketLine( mMarketsData )
    if marketType == MarketConfig.MARKET_TYPE_TOTAL_GOAL then
        if answerId then
            return string.format( "Total goals will be %d or more.", math.ceil( line ) )
        else
            return string.format( "Total goals will less than %d.", math.ceil( line ) )
        end
    elseif marketType == MarketConfig.MARKET_TYPE_ASIAN_HANDICAP then
        local teamName = TeamConfig.getTeamName( TeamConfig.getConfigIdByKey( mMatch["AwayTeamId"] ) )
        if line < 0 then
            teamName = TeamConfig.getTeamName( TeamConfig.getConfigIdByKey( mMatch["HomeTeamId"] ) )
            line = line * ( -1 )
        end 
        
        if answerId then
            return string.format( "%s will win by %d goals or more.", teamName, math.ceil( line ) )
        else
            return string.format( "%s will not win by %d goals or more.", teamName, math.ceil( line ) )
        end
    end
end

function onFrameTouch( sender, eventType )
    local yes = tolua.cast( mWidget:getChildByName("yes"), "ImageView" )
    local no = tolua.cast( mWidget:getChildByName("no"), "ImageView" )
    if eventType == TOUCH_EVENT_ENDED then
        local touchBeginPoint = sender:getTouchStartPos()
        local touchEndPoint = sender:getTouchEndPos()
        if touchBeginPoint.x - touchEndPoint.x > MIN_MOVE_DISTANCE then
            -- Swap to Left
            selectNo()
        elseif touchBeginPoint.x - touchEndPoint.x < MIN_MOVE_DISTANCE * (-1) then
            -- Swap to Right
            selectYes()
        else
            yes:setScale( SCALE_BASE )
            no:setScale( SCALE_BASE )
            yes:setOpacity( OPACITY )
            no:setOpacity( OPACITY )
        end
    elseif eventType == TOUCH_EVENT_MOVED then
        local touchBeginPoint = sender:getTouchStartPos()
        local touchMovPoint = sender:getTouchMovePos()

        local scalePercentage = math.abs( touchBeginPoint.x - touchMovPoint.x ) / MIN_MOVE_DISTANCE
        if scalePercentage > 1 then
            scalePercentage = 1
        end
        if touchBeginPoint.x - touchMovPoint.x > 0 then
            no:setScale( scalePercentage * SCALE_UP_OFFSET_MAX + SCALE_BASE )
            yes:setScale( scalePercentage * SCALE_DOWN_OFFSET_MAX + SCALE_BASE )
            no:setOpacity( OPACITY )
            yes:setOpacity( OPACITY / 3 )
        else
            yes:setScale( scalePercentage * SCALE_UP_OFFSET_MAX + SCALE_BASE )
            no:setScale( scalePercentage * SCALE_DOWN_OFFSET_MAX + SCALE_BASE )
            yes:setOpacity( OPACITY )
            no:setOpacity( OPACITY / 3 )
        end
    end
end