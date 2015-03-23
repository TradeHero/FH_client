module(..., package.seeall)

require "extern"

local SceneManager = require("scripts.SceneManager")
local Constants = require("scripts.Constants")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local TeamConfig = require("scripts.config.Team")
local MarketConfig = require("scripts.config.Market")
local MarketsForGameData = require("scripts.data.MarketsForGameData")
local Logic = require("scripts.Logic").getInstance()
local Prediction = require("scripts.data.Prediction").Prediction
local ViewUtils = require("scripts.views.ViewUtils")


local mWidget

local mMatch
local mMarketInfo
local mFinishCallback
local mBigBetCallback
local mStake

local TYPE_STRING = "WL"
local FINISH_SCALE_TIME = 0.5
local FINISH_DELAY_TIME = 0.5
local SCALE_UP_VALUE = 0.95
local SCALE_DOWN_VALUE = 0.6
local FADE_OUT_VALUE = 80
local MOVE_TIME = 0.2

local mRemainingTime

function loadFrame( parent, matchInfo, marketInfo, finishCallback, bigBetStatus, makeBigBetCallback )
    mWidget = SceneManager.widgetFromJsonFile("scenes/MatchPrediction.json")
    mMatch = matchInfo
    mMarketInfo = marketInfo
    mFinishCallback = finishCallback
    mBigBetCallback = makeBigBetCallback

    mWidget:registerScriptHandler( EnterOrExit )

    local team1 = tolua.cast( mWidget:getChildByName("team1"), "ImageView" )
    local team2 = tolua.cast( mWidget:getChildByName("team2"), "ImageView" )
    local draw = tolua.cast( mWidget:getChildByName("draw"), "ImageView" )
    local team1WinPoint = tolua.cast( team1:getChildByName("team1WinPoint"), "Label" )
    local team2WinPoint = tolua.cast( team2:getChildByName("team2WinPoint"), "Label" )
    local drawWinPoint = tolua.cast( draw:getChildByName("drawWinPoint"), "Label" )
    local stake = tolua.cast( mWidget:getChildByName("stake"), "Label" )
    local balance = tolua.cast( mWidget:getChildByName("balance"), "Label" )
    local bigBet = tolua.cast( mWidget:getChildByName("CheckBox_BigBet"), "CheckBox" )
    local countdown = mWidget:getChildByName("Button_Countdown")
    local lbQuestion = tolua.cast( mWidget:getChildByName("question"), "Label" )
    local lbBalance = tolua.cast( mWidget:getChildByName("Label_Balance"), "Label" )
    local lbStake = tolua.cast( mWidget:getChildByName("Label_Stake"), "Label" )
    local lb1ToWin = tolua.cast( team1:getChildByName("Label_StandToWin"), "Label" )
    local lb2ToWin = tolua.cast( team2:getChildByName("Label_StandToWin"), "Label" )
    local lbDrawToWin = tolua.cast( draw:getChildByName("Label_StandToWin"), "Label" )

    -- labels
    lbQuestion:setText( Constants.String.match_prediction.team_to_win )
    lbBalance:setText( Constants.String.match_prediction.balance )
    lbStake:setText( Constants.String.match_prediction.stake )
    lb1ToWin:setText( Constants.String.match_prediction.stand_to_win )
    lb2ToWin:setText( Constants.String.match_prediction.stand_to_win )
    lbDrawToWin:setText( Constants.String.match_prediction.stand_to_win )

    mStake = Constants.STAKE
    if bigBetStatus["timeToNextBet"] > 0 then
        -- show countdown
        bigBet:setEnabled( false )
    
        mRemainingTime = bigBetStatus["timeToNextBet"]
        local labelTime = tolua.cast( countdown:getChildByName("Label_Time"), "Label" )
        labelTime:setText( os.date( "!%X", mRemainingTime ) )
        performWithDelay( mWidget, doCountdown, 1 )

        local eventHandler = function( sender, eventType )
            if eventType == TOUCH_EVENT_ENDED then
                EventManager:postEvent( Event.Show_Info, { Constants.String.info.star_bet } )
            end
        end
        countdown:addTouchEventListener( eventHandler )
    else
        countdown:setEnabled( false )
        if bigBetStatus["currBigBet"] == MarketConfig.MARKET_TYPE_MATCH then
            -- active
            bigBet:setSelectedState( true )
            bigBet:addTouchEventListener( selectBigBet )
            mStake = Constants.STAKE_BIGBET
        elseif bigBetStatus["currBigBet"] == MarketConfig.MARKET_TYPE_INVALID then
            --inactive
            bigBet:setOpacity( 127 )
            bigBet:setSelectedState( false )
            bigBet:addTouchEventListener( selectBigBet )
        else
            --disabled
            bigBet:setBright( false )
        end
    end

    team1:loadTexture( TeamConfig.getLogo( TeamConfig.getConfigIdByKey( mMatch["HomeTeamId"] ) ) )
    team2:loadTexture( TeamConfig.getLogo( TeamConfig.getConfigIdByKey( mMatch["AwayTeamId"] ) ) )
    team1WinPoint:setText( string.format( Constants.String.num_of_points, MarketsForGameData.getOddsForType( mMarketInfo, MarketConfig.ODDS_TYPE_ONE_OPTION ) * mStake ) )
    team2WinPoint:setText( string.format( Constants.String.num_of_points, MarketsForGameData.getOddsForType( mMarketInfo, MarketConfig.ODDS_TYPE_TWO_OPTION ) * mStake ) )
    drawWinPoint:setText( string.format( Constants.String.num_of_points, MarketsForGameData.getOddsForType( mMarketInfo, MarketConfig.ODDS_TYPE_THREE_OPTION ) * mStake ) )
    stake:setText( string.format( Constants.String.num_of_points, mStake ) )
    balance:setText( string.format( Constants.String.num_of_points, Logic:getBalance() - Logic:getUncommitedBalance() ) )

    team1:addTouchEventListener( selectTeam1Win )
    team2:addTouchEventListener( selectTeam2Win )
    draw:addTouchEventListener( selectDraw )

    helperSetTouchEnabled( false )

    parent:addChild( mWidget )
end

function releaseFrame()
    if mWidget ~= nil then
        mWidget:removeFromParent()
    end
end

function choose( selectedIndex )
    local selected
    local notSelected
    local notSelected2
    if selectedIndex == Constants.STATUS_SELECTED_LEFT then
        selected = tolua.cast( mWidget:getChildByName("team1"), "ImageView" )
        notSelected = tolua.cast( mWidget:getChildByName("team2"), "ImageView" )
        notSelected2 = tolua.cast( mWidget:getChildByName("draw"), "ImageView" )
    elseif selectedIndex == Constants.STATUS_SELECTED_RIGHT then
        selected = tolua.cast( mWidget:getChildByName("team2"), "ImageView" )
        notSelected = tolua.cast( mWidget:getChildByName("team1"), "ImageView" )
        notSelected2 = tolua.cast( mWidget:getChildByName("draw"), "ImageView" )
    elseif selectedIndex == Constants.STATUS_SELECTED_THIRD then
        selected = tolua.cast( mWidget:getChildByName("draw"), "ImageView" )
        notSelected = tolua.cast( mWidget:getChildByName("team1"), "ImageView" )
        notSelected2 = tolua.cast( mWidget:getChildByName("team2"), "ImageView" )
    end

    selected:setScale( SCALE_UP_VALUE )
    selected:setOpacity( 255 )
    notSelected:setScale( SCALE_DOWN_VALUE )
    notSelected:setOpacity( FADE_OUT_VALUE )
    notSelected2:setScale( SCALE_DOWN_VALUE )
    notSelected2:setOpacity( FADE_OUT_VALUE )
end

function EnterOrExit( eventType )
    if eventType == "enter" then
    elseif eventType == "exit" then
        mWidget = nil
    end
end

function selectTeam1Win( sender, eventType )
    if eventType == TOUCH_EVENT_ENDED then
        local question = tolua.cast( mWidget:getChildByName("question"), "Label" )
        makePrediction(
            MarketsForGameData.getOddsForType( mMarketInfo, MarketConfig.ODDS_TYPE_ONE_OPTION ) * mStake,
            MarketsForGameData.getOddIdForType( mMarketInfo, MarketConfig.ODDS_TYPE_ONE_OPTION ),
            question:getStringValue(),
            string.format( Constants.String.match_prediction.answer_match_win, TeamConfig.getTeamName( TeamConfig.getConfigIdByKey( mMatch["HomeTeamId"] ) ) ),
            Constants.STATUS_SELECTED_LEFT )
    end
end

function selectTeam2Win( sender, eventType )
    if eventType == TOUCH_EVENT_ENDED then
        local question = tolua.cast( mWidget:getChildByName("question"), "Label" )
        makePrediction(
            MarketsForGameData.getOddsForType( mMarketInfo, MarketConfig.ODDS_TYPE_TWO_OPTION ) * mStake,
            MarketsForGameData.getOddIdForType( mMarketInfo, MarketConfig.ODDS_TYPE_TWO_OPTION ),
            question:getStringValue(),
            string.format( Constants.String.match_prediction.answer_match_win, TeamConfig.getTeamName( TeamConfig.getConfigIdByKey( mMatch["AwayTeamId"] ) ) ),
            Constants.STATUS_SELECTED_RIGHT )
    end
end

function selectDraw( sender, eventType )
    if eventType == TOUCH_EVENT_ENDED then
        local question = tolua.cast( mWidget:getChildByName("question"), "Label" )
        makePrediction(
            MarketsForGameData.getOddsForType( mMarketInfo, MarketConfig.ODDS_TYPE_THREE_OPTION ) * mStake,
            MarketsForGameData.getOddIdForType( mMarketInfo, MarketConfig.ODDS_TYPE_THREE_OPTION ),
            question:getStringValue(),
            Constants.String.match_prediction.answer_match_draw,
            Constants.STATUS_SELECTED_THIRD )
    end
end

function selectBigBet( sender, eventType )
    local checkbox = tolua.cast( sender, "CheckBox" )
    if eventType == TOUCH_EVENT_ENDED then
        if checkbox:getSelectedState() then
            checkbox:setOpacity( 127 )
            mBigBetCallback( MarketConfig.MARKET_TYPE_INVALID )
            mStake = Constants.STAKE
        else
            checkbox:setOpacity( 255 )
            mBigBetCallback( MarketConfig.MARKET_TYPE_MATCH )
            mStake = Constants.STAKE_BIGBET
        end
        
        local stake = tolua.cast( mWidget:getChildByName("stake"), "Label" )
        local team1 = tolua.cast( mWidget:getChildByName("team1"), "ImageView" )
        local team2 = tolua.cast( mWidget:getChildByName("team2"), "ImageView" )
        local draw = tolua.cast( mWidget:getChildByName("draw"), "ImageView" )
        local team1WinPoint = tolua.cast( team1:getChildByName("team1WinPoint"), "Label" )
        local team2WinPoint = tolua.cast( team2:getChildByName("team2WinPoint"), "Label" )
        local drawWinPoint = tolua.cast( draw:getChildByName("drawWinPoint"), "Label" )

        stake:setText( string.format( Constants.String.num_of_points, mStake ) )
        team1WinPoint:setText( string.format( Constants.String.num_of_points, MarketsForGameData.getOddsForType( mMarketInfo, MarketConfig.ODDS_TYPE_ONE_OPTION ) * mStake ) )
        team2WinPoint:setText( string.format( Constants.String.num_of_points, MarketsForGameData.getOddsForType( mMarketInfo, MarketConfig.ODDS_TYPE_TWO_OPTION ) * mStake ) )
        drawWinPoint:setText( string.format( Constants.String.num_of_points, MarketsForGameData.getOddsForType( mMarketInfo, MarketConfig.ODDS_TYPE_THREE_OPTION ) * mStake ) )
    end
end

function makePrediction( rewards, oddId, question, answer, selectedIndex )
    local selected
    local notSelected
    local notSelected2
    if selectedIndex == Constants.STATUS_SELECTED_LEFT then
        selected = tolua.cast( mWidget:getChildByName("team1"), "ImageView" )
        notSelected = tolua.cast( mWidget:getChildByName("team2"), "ImageView" )
        notSelected2 = tolua.cast( mWidget:getChildByName("draw"), "ImageView" )
    elseif selectedIndex == Constants.STATUS_SELECTED_RIGHT then
        selected = tolua.cast( mWidget:getChildByName("team2"), "ImageView" )
        notSelected = tolua.cast( mWidget:getChildByName("team1"), "ImageView" )
        notSelected2 = tolua.cast( mWidget:getChildByName("draw"), "ImageView" )
    elseif selectedIndex == Constants.STATUS_SELECTED_THIRD then
        selected = tolua.cast( mWidget:getChildByName("draw"), "ImageView" )
        notSelected = tolua.cast( mWidget:getChildByName("team1"), "ImageView" )
        notSelected2 = tolua.cast( mWidget:getChildByName("team2"), "ImageView" )
    end
    helperSetTouchEnabled( false )

    local resultSeqArray = CCArray:create()
    
    local spawnArray = CCArray:create()
    spawnArray:addObject( CCTargetedAction:create( selected, CCScaleTo:create( FINISH_SCALE_TIME, SCALE_UP_VALUE ) ) )
    spawnArray:addObject( CCTargetedAction:create( selected, CCFadeTo:create( FINISH_SCALE_TIME, 255 ) ) )
    spawnArray:addObject( CCTargetedAction:create( notSelected, CCScaleTo:create( FINISH_SCALE_TIME, SCALE_DOWN_VALUE ) ) )
    spawnArray:addObject( CCTargetedAction:create( notSelected, CCFadeTo:create( FINISH_SCALE_TIME, FADE_OUT_VALUE ) ) )
    spawnArray:addObject( CCTargetedAction:create( notSelected2, CCScaleTo:create( FINISH_SCALE_TIME, SCALE_DOWN_VALUE ) ) )
    spawnArray:addObject( CCTargetedAction:create( notSelected2, CCFadeTo:create( FINISH_SCALE_TIME, FADE_OUT_VALUE ) ) )
    resultSeqArray:addObject( CCSpawn:create( spawnArray ) )

    resultSeqArray:addObject( CCDelayTime:create( FINISH_DELAY_TIME ) )
    resultSeqArray:addObject( CCCallFuncN:create( function()
        local prediction = Prediction:new( oddId, question, answer, rewards, selected:getTextureFile(), TYPE_STRING, mStake )
        mFinishCallback( selectedIndex, prediction )
    end ) )

    mWidget:runAction( CCSequence:create( resultSeqArray ) )

    AudioEngine.playEffect( AudioEngine.SELECT_PREDICTION )
end

function helperSetTouchEnabled( enabled )
    local team1 = mWidget:getChildByName("team1")
    team1:setTouchEnabled( enabled )

    local team2 = mWidget:getChildByName("team2")
    team2:setTouchEnabled( enabled )

    local draw = mWidget:getChildByName("draw")
    draw:setTouchEnabled( enabled )
end

function helperGetTouchEnabled()
    local team1 = mWidget:getChildByName("team1")
    return team1:isTouchEnabled()
end

function doCountdown()
    updateTimer()
end

function updateTimer()
    local countdown = mWidget:getChildByName("Button_Countdown")
    local labelTime = tolua.cast( countdown:getChildByName("Label_Time"), "Label" )

    mRemainingTime = mRemainingTime - 1
    if mRemainingTime < 0 then
        local bigBet = tolua.cast( mWidget:getChildByName("CheckBox_BigBet"), "CheckBox" ) 
        --inactive
        bigBet:setEnabled( true )
        bigBet:setOpacity( 127 )
        bigBet:setSelectedState( false )
        bigBet:addTouchEventListener( selectBigBet )
        countdown:setEnabled( false )
    else
        labelTime:setText( os.date( "!%X", mRemainingTime ) )
        performWithDelay( mWidget, doCountdown, 1 )
    end
end