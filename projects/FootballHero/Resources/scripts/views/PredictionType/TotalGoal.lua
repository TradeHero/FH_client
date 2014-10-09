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

local TYPE_STRING = "TG"
local FINISH_SCALE_TIME = 0.5
local FINISH_DELAY_TIME = 0.5
local SCALE_UP_VALUE = 1.1
local SCALE_DOWN_VALUE = 0.7
local FADE_OUT_VALUE = 80
local MOVE_TIME = 0.2

function loadFrame( parent, matchInfo, marketInfo, finishCallback )
    mWidget = SceneManager.widgetFromJsonFile("scenes/WTGBMTPrediction.json")
    mMatch = matchInfo
    mMarketInfo = marketInfo
    mFinishCallback = finishCallback

    mWidget:registerScriptHandler( EnterOrExit )

    local question = tolua.cast( mWidget:getChildByName("question"), "Label" )
    local yes = tolua.cast( mWidget:getChildByName("yes"), "ImageView" )
    local no = tolua.cast( mWidget:getChildByName("no"), "ImageView" )
    local yesWinPoint = tolua.cast( yes:getChildByName("yesWinPoint"), "Label" )
    local noWinPoint = tolua.cast( no:getChildByName("noWinPoint"), "Label" )
    local stake = tolua.cast( mWidget:getChildByName("stake"), "Label" )
    local balance = tolua.cast( mWidget:getChildByName("balance"), "Label" )

    local line = MarketsForGameData.getMarketLine( mMarketInfo )
    question:setText( string.format( question:getStringValue(), math.ceil( line ) ) )
    yesWinPoint:setText( string.format( yesWinPoint:getStringValue(), MarketsForGameData.getOddsForType( mMarketInfo, MarketConfig.ODDS_TYPE_ONE_OPTION ) ) )
    noWinPoint:setText( string.format( noWinPoint:getStringValue(), MarketsForGameData.getOddsForType( mMarketInfo, MarketConfig.ODDS_TYPE_TWO_OPTION ) ) )
    stake:setText( string.format( stake:getStringValue(), Constants.STAKE ) )
    balance:setText( string.format( balance:getStringValue(), Logic:getBalance() - Logic:getUncommitedBalance() ) )

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

function choose( selectLeft )
    local selected
    local notSelected
    if selectLeft then
        selected = tolua.cast( mWidget:getChildByName("yes"), "ImageView" )
        notSelected = tolua.cast( mWidget:getChildByName("no"), "ImageView" )
    else
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
            MarketsForGameData.getOddsForType( mMarketInfo, MarketConfig.ODDS_TYPE_ONE_OPTION ),
            MarketsForGameData.getOddIdForType( mMarketInfo, MarketConfig.ODDS_TYPE_ONE_OPTION ),
            question:getStringValue(),
            true )
    end
end

function selectNo( sender, eventType )
    if eventType == TOUCH_EVENT_ENDED then
        local question = tolua.cast( mWidget:getChildByName("question"), "Label" )
        local line = MarketsForGameData.getMarketLine( mMarketInfo )
        makePrediction(
            MarketsForGameData.getOddsForType( mMarketInfo, MarketConfig.ODDS_TYPE_TWO_OPTION ),
            MarketsForGameData.getOddIdForType( mMarketInfo, MarketConfig.ODDS_TYPE_TWO_OPTION ),
            question:getStringValue(),
            false )
    end
end

function makePrediction( rewards, oddId, answer, selectLeft )
    local selected
    local notSelected
    if selectLeft then
        selected = tolua.cast( mWidget:getChildByName("yes"), "ImageView" )
        notSelected = tolua.cast( mWidget:getChildByName("no"), "ImageView" )
    else
        selected = tolua.cast( mWidget:getChildByName("no"), "ImageView" )
        notSelected = tolua.cast( mWidget:getChildByName("yes"), "ImageView" )
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
        local prediction = Prediction:new( oddId, answer, rewards, selected:getTextureFile(), TYPE_STRING )
        mFinishCallback( selectLeft, prediction )
    end ) )

    mWidget:runAction( CCSequence:create( resultSeqArray ) )
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
    local yes = mWidget:getChildByName("yes")
    yes:setTouchEnabled( enabled )

    local no = mWidget:getChildByName("no")
    no:setTouchEnabled( enabled )
end

function helperGetTouchEnabled()
    local yes = mWidget:getChildByName("yes")
    return yes:isTouchEnabled()
end