module(..., package.seeall)

local Constants = require("scripts.Constants")
local SceneManager = require("scripts.SceneManager")
local TeamConfig = require("scripts.config.Team")
local MarketConfig = require("scripts.config.Market")
local MatchListScene = require("scripts.MatchListScene")
local Logic = require("scripts.Logic").getInstance()
local MarketsForGameData = require("scripts.data.MarketsForGameData")

local mWidget
local mMatch
local mMarketsData

local MIN_MOVE_DISTANCE = 100
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
    SceneManager.clearNAddWidget(widget)

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

    if marketType == 26 then
        return "scenes/WBTSPrediction.json"
    elseif marketType == 27 then
        return "scenes/WTCBMTPrediction.json"
    elseif marketType == 28 then
        return "scenes/WTGBMTPrediction.json"
    elseif marketType == 29 then
        return "scenes/WTSPrediction.json"
    elseif marketType == 30 then
        return "scenes/WTWBEGPrediction.json"        
    end

    return "scenes/WBTSPrediction.json"
end

function selectYes()
    makePrediction(
        TeamConfig.getTeamName( TeamConfig.getConfigIdByKey( mMatch["HomeTeamId"] ) ), 
        MarketsForGameData.getOddsForType( mMarketsData, MarketConfig.ODDS_TYPE_HOME_WIN ),
        MarketsForGameData.getOddIdForType( mMarketsData, MarketConfig.ODDS_TYPE_HOME_WIN ) )
end

function selectNo()
    makePrediction(
        TeamConfig.getTeamName( TeamConfig.getConfigIdByKey( mMatch["AwayTeamId"] ) ), 
        MarketsForGameData.getOddsForType( mMarketsData, MarketConfig.ODDS_TYPE_AWAY_WIN ),
        MarketsForGameData.getOddIdForType( mMarketsData, MarketConfig.ODDS_TYPE_AWAY_WIN ) )
end

function backEventHandler( sender, eventType )
    if eventType == TOUCH_EVENT_ENDED then
        EventManager:postEvent( Event.Enter_Match_List )
    end
end

function makePrediction( prediction, teamName, reward )
    local seqArray = CCArray:create()
    seqArray:addObject( CCDelayTime:create( 0.1 ) )
    seqArray:addObject( CCCallFuncN:create( function()
        EventManager:postEvent( Event.Enter_Prediction_Confirm, { prediction, teamName, reward } )
    end ) )

    mWidget:runAction( CCSequence:create( seqArray ) )
    
end
function helperInitMarketInfo( content )
    local team1Name = tolua.cast( content:getChildByName("team1Name"), "Label" )
    local team2Name = tolua.cast( content:getChildByName("team2Name"), "Label" )
    local answer1Point = tolua.cast( team1:getChildByName("answer1Point"), "Label" )
    local answer2Point = tolua.cast( team2:getChildByName("answer2Point"), "Label" )

    team1Name:setText( TeamConfig.getTeamName( TeamConfig.getConfigIdByKey( mMatch["HomeTeamId"] ) ) )
    team2Name:setText( TeamConfig.getTeamName( TeamConfig.getConfigIdByKey( mMatch["AwayTeamId"] ) ) )
    answer1Point:setText( MarketsForGameData.getOddsForType( mMarketsData, MarketConfig.ODDS_TYPE_HOME_WIN ).." points" )
    answer2Point:setText( MarketsForGameData.getOddsForType( mMarketsData, MarketConfig.ODDS_TYPE_AWAY_WIN ).." points" )
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
            yes:setScale( 1 )
            no:setScale( 1 )
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
            no:setScale( scalePercentage * SCALE_UP_OFFSET_MAX + 1 )
            yes:setScale( scalePercentage * SCALE_DOWN_OFFSET_MAX + 1 )
            no:setOpacity( OPACITY )
            yes:setOpacity( OPACITY / 3 )
        else
            yes:setScale( scalePercentage * SCALE_UP_OFFSET_MAX + 1 )
            no:setScale( scalePercentage * SCALE_DOWN_OFFSET_MAX + 1 )
            yes:setOpacity( OPACITY )
            no:setOpacity( OPACITY / 3 )
        end
    end
end