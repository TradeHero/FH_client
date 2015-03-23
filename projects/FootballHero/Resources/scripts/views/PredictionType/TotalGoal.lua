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
local mLine
local mMarketInfo
local mFinishCallback
local mBigBetCallback
local mStake

local TYPE_STRING = "TG"
local FINISH_SCALE_TIME = 0.5
local FINISH_DELAY_TIME = 0.5
local SCALE_UP_VALUE = 1.1
local SCALE_DOWN_VALUE = 0.7
local FADE_OUT_VALUE = 80
local MOVE_TIME = 0.2

local mRemainingTime

function loadFrame( parent, matchInfo, marketInfo, finishCallback, bigBetStatus, makeBigBetCallback )
    mWidget = SceneManager.widgetFromJsonFile("scenes/WTGBMTPrediction.json")
    mMatch = matchInfo
    mMarketInfo = marketInfo
    mFinishCallback = finishCallback
    mBigBetCallback = makeBigBetCallback

    mWidget:registerScriptHandler( EnterOrExit )

    local question = tolua.cast( mWidget:getChildByName("question"), "Label" )
    local yes = tolua.cast( mWidget:getChildByName("yes"), "ImageView" )
    local no = tolua.cast( mWidget:getChildByName("no"), "ImageView" )
    local yesWinPoint = tolua.cast( yes:getChildByName("yesWinPoint"), "Label" )
    local yesToWin = tolua.cast( yes:getChildByName("Label_ToWin"), "Label" )
    local noWinPoint = tolua.cast( no:getChildByName("noWinPoint"), "Label" )
    local noToWin = tolua.cast( no:getChildByName("Label_ToWin"), "Label" )
    local stake = tolua.cast( mWidget:getChildByName("stake"), "Label" )
    local balance = tolua.cast( mWidget:getChildByName("balance"), "Label" )
    local bigBet = tolua.cast( mWidget:getChildByName("CheckBox_BigBet"), "CheckBox" )
    local countdown = mWidget:getChildByName("Button_Countdown")
    local lbBalance = tolua.cast( mWidget:getChildByName("Label_Balance"), "Label" )
    local lbStake = tolua.cast( mWidget:getChildByName("Label_Stake"), "Label" )
    local vs = tolua.cast( mWidget:getChildByName("VS"), "Label" )

    lbBalance:setText( Constants.String.match_prediction.balance )
    lbStake:setText( Constants.String.match_prediction.stake )
    yesToWin:setText( Constants.String.match_prediction.stand_to_win )
    noToWin:setText( Constants.String.match_prediction.stand_to_win )
    balance:setText( Constants.String.match_prediction.balance )
    stake:setText( Constants.String.match_prediction.stake )
    vs:setText( Constants.String.vs )
    

    mStake = Constants.STAKE
    if bigBetStatus["timeToNextBet"] > 0 then
        -- show countdown
        bigBet:setEnabled( false )
    
        mRemainingTime = bigBetStatus["timeToNextBet"]
        local labelTime = tolua.cast( countdown:getChildByName("Label_Time"), "Label" )
        labelTime:setText( os.date( "!%X", mRemainingTime ) )
        performWithDelay( mWidget, doCountdown, 1 )
    else
        countdown:setEnabled( false )
        if bigBetStatus["currBigBet"] == MarketConfig.MARKET_TYPE_TOTAL_GOAL then
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

    mLine = MarketsForGameData.getMarketLine( mMarketInfo )
    question:setText( string.format( Constants.String.match_prediction.will_total_goals, math.ceil( mLine ) ) )
    yesWinPoint:setText( string.format( Constants.String.num_of_points, MarketsForGameData.getOddsForType( mMarketInfo, MarketConfig.ODDS_TYPE_ONE_OPTION ) * mStake ) )
    noWinPoint:setText( string.format( Constants.String.num_of_points, MarketsForGameData.getOddsForType( mMarketInfo, MarketConfig.ODDS_TYPE_TWO_OPTION ) * mStake ) )
    stake:setText( string.format( Constants.String.num_of_points, mStake ) )
    balance:setText( string.format( Constants.String.num_of_points, Logic:getBalance() - Logic:getUncommitedBalance() ) )

    yes:addTouchEventListener( selectYes )
    no:addTouchEventListener( selectNo )

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
    if selectedIndex == Constants.STATUS_SELECTED_LEFT then
        selected = tolua.cast( mWidget:getChildByName("yes"), "ImageView" )
        notSelected = tolua.cast( mWidget:getChildByName("no"), "ImageView" )
    elseif selectedIndex == Constants.STATUS_SELECTED_RIGHT then
        selected = tolua.cast( mWidget:getChildByName("no"), "ImageView" )
        notSelected = tolua.cast( mWidget:getChildByName("yes"), "ImageView" )
    end

    selected:setScale( SCALE_UP_VALUE )
    selected:setOpacity( 255 )
    notSelected:setScale( SCALE_DOWN_VALUE )
    notSelected:setOpacity( FADE_OUT_VALUE )
end

function EnterOrExit( eventType )
    if eventType == "enter" then
    elseif eventType == "exit" then
        mWidget = nil
    end
end

function selectYes( sender, eventType )
    if eventType == TOUCH_EVENT_ENDED then
        local question = tolua.cast( mWidget:getChildByName("question"), "Label" )
        local line = MarketsForGameData.getMarketLine( mMarketInfo )
        makePrediction(
            MarketsForGameData.getOddsForType( mMarketInfo, MarketConfig.ODDS_TYPE_ONE_OPTION ) * mStake,
            MarketsForGameData.getOddIdForType( mMarketInfo, MarketConfig.ODDS_TYPE_ONE_OPTION ),
            question:getStringValue(),
            string.format( Constants.String.match_prediction.answer_total_goal_yes, math.ceil( mLine ) ),
            Constants.STATUS_SELECTED_LEFT )
    end
end

function selectNo( sender, eventType )
    if eventType == TOUCH_EVENT_ENDED then
        local question = tolua.cast( mWidget:getChildByName("question"), "Label" )
        local line = MarketsForGameData.getMarketLine( mMarketInfo )
        makePrediction(
            MarketsForGameData.getOddsForType( mMarketInfo, MarketConfig.ODDS_TYPE_TWO_OPTION ) * mStake,
            MarketsForGameData.getOddIdForType( mMarketInfo, MarketConfig.ODDS_TYPE_TWO_OPTION ),
            question:getStringValue(),
            string.format( Constants.String.match_prediction.answer_total_goal_no, math.ceil( mLine ) - 1 ),
            Constants.STATUS_SELECTED_RIGHT )
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
            mBigBetCallback( MarketConfig.MARKET_TYPE_TOTAL_GOAL )
            mStake = Constants.STAKE_BIGBET
        end
        
        local stake = tolua.cast( mWidget:getChildByName("stake"), "Label" )
        local yes = tolua.cast( mWidget:getChildByName("yes"), "ImageView" )
        local no = tolua.cast( mWidget:getChildByName("no"), "ImageView" )
        local yesWinPoint = tolua.cast( yes:getChildByName("yesWinPoint"), "Label" )
        local noWinPoint = tolua.cast( no:getChildByName("noWinPoint"), "Label" )

        stake:setText( string.format( Constants.String.num_of_points, mStake ) )
        yesWinPoint:setText( string.format( Constants.String.num_of_points, MarketsForGameData.getOddsForType( mMarketInfo, MarketConfig.ODDS_TYPE_ONE_OPTION ) * mStake ) )
        noWinPoint:setText( string.format( Constants.String.num_of_points, MarketsForGameData.getOddsForType( mMarketInfo, MarketConfig.ODDS_TYPE_TWO_OPTION ) * mStake ) )
    end
end

function makePrediction( rewards, oddId, question, answer, selectedIndex )
    local selected
    local notSelected
    if selectedIndex == Constants.STATUS_SELECTED_LEFT then
        selected = tolua.cast( mWidget:getChildByName("yes"), "ImageView" )
        notSelected = tolua.cast( mWidget:getChildByName("no"), "ImageView" )
    elseif selectedIndex == Constants.STATUS_SELECTED_RIGHT then
        selected = tolua.cast( mWidget:getChildByName("no"), "ImageView" )
        notSelected = tolua.cast( mWidget:getChildByName("yes"), "ImageView" )
    end
    helperSetTouchEnabled( false )

    local resultSeqArray = CCArray:create()
    
    local spawnArray = CCArray:create()
    spawnArray:addObject( CCTargetedAction:create( selected, CCScaleTo:create( FINISH_SCALE_TIME, SCALE_UP_VALUE ) ) )
    spawnArray:addObject( CCTargetedAction:create( selected, CCFadeTo:create( FINISH_SCALE_TIME, 255 ) ) )
    spawnArray:addObject( CCTargetedAction:create( notSelected, CCScaleTo:create( FINISH_SCALE_TIME, SCALE_DOWN_VALUE ) ) )
    spawnArray:addObject( CCTargetedAction:create( notSelected, CCFadeTo:create( FINISH_SCALE_TIME, FADE_OUT_VALUE ) ) )
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
    local yes = mWidget:getChildByName("yes")
    yes:setTouchEnabled( enabled )

    local no = mWidget:getChildByName("no")
    no:setTouchEnabled( enabled )
end

function helperGetTouchEnabled()
    local yes = mWidget:getChildByName("yes")
    return yes:isTouchEnabled()
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