module(..., package.seeall)

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
local SCALE_UP_VALUE = 1.1
local SCALE_DOWN_VALUE = 0.7
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
    local team1WinPoint = tolua.cast( team1:getChildByName("team1WinPoint"), "Label" )
    local team2WinPoint = tolua.cast( team2:getChildByName("team2WinPoint"), "Label" )
    local stake = tolua.cast( mWidget:getChildByName("stake"), "Label" )
    local balance = tolua.cast( mWidget:getChildByName("balance"), "Label" )
    local bigBet = tolua.cast( mWidget:getChildByName("CheckBox_BigBet"), "CheckBox" )
    local countdown = mWidget:getChildByName("Image_Countdown")

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
    team1WinPoint:setText( string.format( team1WinPoint:getStringValue(), MarketsForGameData.getOddsForType( mMarketInfo, MarketConfig.ODDS_TYPE_ONE_OPTION ) * mStake ) )
    team2WinPoint:setText( string.format( team2WinPoint:getStringValue(), MarketsForGameData.getOddsForType( mMarketInfo, MarketConfig.ODDS_TYPE_TWO_OPTION ) * mStake ) )
    stake:setText( string.format( stake:getStringValue(), mStake ) )
    balance:setText( string.format( balance:getStringValue(), Logic:getBalance() - Logic:getUncommitedBalance() ) )

    team1:addTouchEventListener( selectTeam1Win )
    team2:addTouchEventListener( selectTeam2Win )

    helperSetTouchEnabled( false )

    parent:addChild( mWidget )
end

function releaseFrame()
    if mWidget ~= nil then
        mWidget:removeFromParent()
    end
end

function choose( selectLeft )
    local selected
    local notSelected
    if selectLeft then
        selected = tolua.cast( mWidget:getChildByName("team1"), "ImageView" )
        notSelected = tolua.cast( mWidget:getChildByName("team2"), "ImageView" )
    else
        selected = tolua.cast( mWidget:getChildByName("team2"), "ImageView" )
        notSelected = tolua.cast( mWidget:getChildByName("team1"), "ImageView" )
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

function selectTeam1Win( sender, eventType )
    if eventType == TOUCH_EVENT_ENDED then
        local question = tolua.cast( mWidget:getChildByName("question"), "Label" )
        makePrediction(
            MarketsForGameData.getOddsForType( mMarketInfo, MarketConfig.ODDS_TYPE_ONE_OPTION ) * mStake,
            MarketsForGameData.getOddIdForType( mMarketInfo, MarketConfig.ODDS_TYPE_ONE_OPTION ),
            question:getStringValue(),
            true )
    end
end

function selectTeam2Win( sender, eventType )
    if eventType == TOUCH_EVENT_ENDED then
        local question = tolua.cast( mWidget:getChildByName("question"), "Label" )
        makePrediction(
            MarketsForGameData.getOddsForType( mMarketInfo, MarketConfig.ODDS_TYPE_TWO_OPTION ) * mStake,
            MarketsForGameData.getOddIdForType( mMarketInfo, MarketConfig.ODDS_TYPE_TWO_OPTION ),
            question:getStringValue(),
            false )
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
        local team1WinPoint = tolua.cast( team1:getChildByName("team1WinPoint"), "Label" )
        local team2WinPoint = tolua.cast( team2:getChildByName("team2WinPoint"), "Label" )

        stake:setText( string.format( Constants.String.num_of_points, mStake ) )
        team1WinPoint:setText( string.format( Constants.String.num_of_points, MarketsForGameData.getOddsForType( mMarketInfo, MarketConfig.ODDS_TYPE_ONE_OPTION ) * mStake ) )
        team2WinPoint:setText( string.format( Constants.String.num_of_points, MarketsForGameData.getOddsForType( mMarketInfo, MarketConfig.ODDS_TYPE_TWO_OPTION ) * mStake ) )
    end
end

function makePrediction( rewards, oddId, answer, selectLeft )
    local selected
    local notSelected
    if selectLeft then
        selected = tolua.cast( mWidget:getChildByName("team1"), "ImageView" )
        notSelected = tolua.cast( mWidget:getChildByName("team2"), "ImageView" )
    else
        selected = tolua.cast( mWidget:getChildByName("team2"), "ImageView" )
        notSelected = tolua.cast( mWidget:getChildByName("team1"), "ImageView" )
    end
    
    local resultSeqArray = CCArray:create()
    
    local spawnArray = CCArray:create()
    spawnArray:addObject( CCTargetedAction:create( selected, CCScaleTo:create( FINISH_SCALE_TIME, SCALE_UP_VALUE ) ) )
    spawnArray:addObject( CCTargetedAction:create( selected, CCFadeTo:create( FINISH_SCALE_TIME, 255 ) ) )
    spawnArray:addObject( CCTargetedAction:create( notSelected, CCScaleTo:create( FINISH_SCALE_TIME, SCALE_DOWN_VALUE ) ) )
    spawnArray:addObject( CCTargetedAction:create( notSelected, CCFadeTo:create( FINISH_SCALE_TIME, FADE_OUT_VALUE ) ) )
    resultSeqArray:addObject( CCSpawn:create( spawnArray ) )

    resultSeqArray:addObject( CCDelayTime:create( FINISH_DELAY_TIME ) )
    resultSeqArray:addObject( CCCallFuncN:create( function()
        local prediction = Prediction:new( oddId, answer, rewards, selected:getTextureFile(), TYPE_STRING, mStake )
        mFinishCallback( selectLeft, prediction )
    end ) )

    mWidget:runAction( CCSequence:create( resultSeqArray ) )

    AudioEngine.playEffect( AudioEngine.SELECT_PREDICTION )
end

function playMoveAnim( moveDirection, delayTime )
    local resultSeqArray = CCArray:create()
    if delayTime ~= nil and delayTime > 0 then
        resultSeqArray:addObject( CCDelayTime:create( delayTime ) )
    end
    if helperGetTouchEnabled() then
        resultSeqArray:addObject( CCCallFunc:create( function()
            helperSetTouchEnabled( false )
        end ) )
    end
    resultSeqArray:addObject( CCMoveBy:create( MOVE_TIME, ccp( Constants.GAME_WIDTH * moveDirection, 0 ) ) )
    if not helperGetTouchEnabled() then
        resultSeqArray:addObject( CCCallFunc:create( function()
            helperSetTouchEnabled( true )
        end ) )
    end

    mWidget:runAction( CCSequence:create( resultSeqArray ) )

    return MOVE_TIME
end

function helperSetTouchEnabled( enabled )
    local team1 = mWidget:getChildByName("team1")
    team1:setTouchEnabled( enabled )

    local team2 = mWidget:getChildByName("team2")
    team2:setTouchEnabled( enabled )
end

function helperGetTouchEnabled()
    local team1 = mWidget:getChildByName("team1")
    return team1:isTouchEnabled()
end

function doCountdown()
    updateTimer()
end

function updateTimer()
    local countdown = mWidget:getChildByName("Image_Countdown")
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