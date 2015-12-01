module(..., package.seeall)

require "extern"

local SceneManager = require("scripts.SceneManager")
local Constants = require("scripts.Constants")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local TeamConfig = require("scripts.config.Team")
local MarketConfig = require("scripts.config.Market")
local SportsConfig = require("scripts.config.Sports")
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

local TYPE_STRING = "AH"
local FINISH_SCALE_TIME = 0.5
local FINISH_DELAY_TIME = 0.5
local SCALE_UP_VALUE = 1.1
local SCALE_DOWN_VALUE = 0.7
local FADE_OUT_VALUE = 80
local MOVE_TIME = 0.2

local mRemainingTime

function loadFrame( parent, matchInfo, marketInfo, finishCallback, bigBetStatus, makeBigBetCallback )
    mWidget = SceneManager.widgetFromJsonFile("scenes/WTWBEGPrediction.json")
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
    local stake = tolua.cast( mWidget:getChildByName("stake"), "ImageView" )
    local bigBet = tolua.cast( mWidget:getChildByName("bigBet"), "CheckBox" )
    local cooldown = mWidget:getChildByName("cooldown")
    local lbStake = tolua.cast( stake:getChildByName("Label_Stake"), "Label" )
    local vs = tolua.cast( mWidget:getChildByName("VS"), "Label" )
    local titleHandicap = tolua.cast( question:getChildByName("Label_Header"), "Label" )
    local btnHandicap = tolua.cast( mWidget:getChildByName("CheckBox_Handicap"), "CheckBox" )
    local stakenum = tolua.cast( stake:getChildByName("stake"), "Label" )
    local btnBuy= tolua.cast( cooldown:getChildByName("Button_bigbet"), "Button" )

    local popupHandicap = tolua.cast( mWidget:getChildByName("Image_HandicapPopup"), "ImageView" )

    lbStake:setText( Constants.String.match_prediction.stake )
    yesToWin:setText( Constants.String.match_prediction.stand_to_win )
    noToWin:setText( Constants.String.match_prediction.stand_to_win )
    stakenum:setText( Constants.String.match_prediction.stake )
    vs:setText( Constants.String.vs )
    if SportsConfig.getCurrentSportId() == SportsConfig.BASEBALL_ID then
        titleHandicap:setText( Constants.String.handicap_baseball.name )
    else
        titleHandicap:setText( Constants.String.handicap.name )
    end
    popupHandicap:setEnabled( false )
    -- not working
    --popupHandicap:setCascadeOpacityEnabled( true )
    

    local popupEventHandler = function( sender, eventType )
        if eventType == TOUCH_EVENT_ENDED then
            toggleHandicapPopup( btnHandicap:getSelectedState(), popupHandicap )
        end
    end
    btnHandicap:addTouchEventListener( popupEventHandler )

    selectBigBet( bigBetStatus[MarketConfig.MARKET_NAME_ASIAN_HANDICAP] )
    bigBet:setSelectedState( bigBetStatus[MarketConfig.MARKET_NAME_ASIAN_HANDICAP] )
    bigBet:addTouchEventListener( bigBetHandler )
    cooldown:setEnabled( false )

    if bigBetStatus[MarketConfig.MARKET_NAME_ASIAN_HANDICAP] == false and bigBetStatus["timeToNextBet"] > 0 then
        -- show countdown
        cooldown:setEnabled( true )
        bigBet:setEnabled( false )
        mRemainingTime = bigBetStatus["timeToNextBet"]
        local labelTime = tolua.cast( cooldown:getChildByName("Label_Time"), "Label" )
        labelTime:setText( os.date( "!%X", mRemainingTime ) )
        performWithDelay( mWidget, doCountdown, 1 )

        local buyHandler =  function( sender, eventType )
            if eventType == TOUCH_EVENT_ENDED then
                if Logic:getTicket() > 0 then
                    cooldown:setEnabled( false )
                    bigBet:setEnabled( true )
                    selectBigBet( true )
                    bigBet:setSelectedState( true )
                else
                    EventManager:postEvent( Event.Show_Get_Tickets )
                end
            end
        end
        btnBuy:addTouchEventListener( buyHandler )
    end
 
    local line = MarketsForGameData.getMarketLine( mMarketInfo )
    local absLine = line
    local teamName = TeamConfig.getTeamName( TeamConfig.getConfigIdByKey( mMatch["AwayTeamId"] ) )
    if line <= 0 then
        teamName = TeamConfig.getTeamName( TeamConfig.getConfigIdByKey( mMatch["HomeTeamId"] ) )
        absLine = line * ( -1 )
    end
    if SportsConfig.getCurrentSportId() == SportsConfig.BASEBALL_ID then
        if line == 0 then
            question:setText( string.format( Constants.String.match_prediction.will_win_by_line0_baseball, teamName ) )
        else
            question:setText( string.format( Constants.String.match_prediction.will_win_by_baseball, teamName, tostring(absLine) ) )
        end
    else
        if line == 0 then
            question:setText( string.format( Constants.String.match_prediction.will_win_by_line0, teamName ) )
        else
            question:setText( string.format( Constants.String.match_prediction.will_win_by, teamName, tostring(absLine) ) )
        end
    end
    
    
    yesWinPoint:setText( MarketsForGameData.getOddsForType( mMarketInfo, MarketConfig.ODDS_TYPE_ONE_OPTION ) * mStake )
    noWinPoint:setText( MarketsForGameData.getOddsForType( mMarketInfo, MarketConfig.ODDS_TYPE_TWO_OPTION ) * mStake )
    stakenum:setText( mStake )

    local labelHome = tolua.cast( popupHandicap:getChildByName( "Label_TitleHome"), "Label" )
    local labelAway = tolua.cast( popupHandicap:getChildByName( "Label_TitleAway"), "Label" )
    local txtHome = tolua.cast( popupHandicap:getChildByName( "Label_GuideHome"), "Label" )
    local txtAway = tolua.cast( popupHandicap:getChildByName( "Label_GuideAway"), "Label" )

    local homeTeam = TeamConfig.getTeamName( TeamConfig.getConfigIdByKey( mMatch["HomeTeamId"] ) )
    local awayTeam = TeamConfig.getTeamName( TeamConfig.getConfigIdByKey( mMatch["AwayTeamId"] ) )
    labelHome:setText( string.format( Constants.String.handicap.predict_on, Constants.String.button.yes ) )
    labelAway:setText( string.format( Constants.String.handicap.predict_on, Constants.String.button.no ) )

    local yesText, noText = ViewUtils.getYesNoText( line, homeTeam, awayTeam, SportsConfig.getCurrentSportId() )
    txtHome:setText( yesText )
    txtAway:setText( noText )

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

function toggleHandicapPopup( isSelected, popupHandicap )
    if isSelected then
        -- remove popup
       popupHandicap:setEnabled( false )
    else
        -- show popup
       popupHandicap:setEnabled( true )
       --mWidget:runAction( CCTargetedAction:create( popupHandicap, CCFadeIn:create( 5.0 ) ) )
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
        local teamName = TeamConfig.getTeamName( TeamConfig.getConfigIdByKey( mMatch["AwayTeamId"] ) )
        if line < 0 then
            teamName = TeamConfig.getTeamName( TeamConfig.getConfigIdByKey( mMatch["HomeTeamId"] ) )
            line = line * ( -1 )
        end 
        makePrediction(
            MarketsForGameData.getOddsForType( mMarketInfo, MarketConfig.ODDS_TYPE_ONE_OPTION ) * mStake,
            MarketsForGameData.getOddIdForType( mMarketInfo, MarketConfig.ODDS_TYPE_ONE_OPTION ),
            question:getStringValue(),
            string.format( Constants.String.match_prediction.answer_asian_handicap_yes, teamName, math.ceil( line ) ),
            Constants.STATUS_SELECTED_LEFT )
    end
end

function selectNo( sender, eventType )
    if eventType == TOUCH_EVENT_ENDED then
        local question = tolua.cast( mWidget:getChildByName("question"), "Label" )
        local line = MarketsForGameData.getMarketLine( mMarketInfo )
        local teamName = TeamConfig.getTeamName( TeamConfig.getConfigIdByKey( mMatch["AwayTeamId"] ) )
        if line < 0 then
            teamName = TeamConfig.getTeamName( TeamConfig.getConfigIdByKey( mMatch["HomeTeamId"] ) )
            line = line * ( -1 )
        end 
        makePrediction(
            MarketsForGameData.getOddsForType( mMarketInfo, MarketConfig.ODDS_TYPE_TWO_OPTION ) * mStake,
            MarketsForGameData.getOddIdForType( mMarketInfo, MarketConfig.ODDS_TYPE_TWO_OPTION ),
            question:getStringValue(),
            string.format( Constants.String.match_prediction.answer_asian_handicap_no, teamName, math.ceil( line ) - 1 ),
            Constants.STATUS_SELECTED_RIGHT )
    end
end

function selectBigBet( status )
    mBigBetCallback( MarketConfig.MARKET_NAME_ASIAN_HANDICAP, status )
    bigBet = tolua.cast( mWidget:getChildByName("bigBet"), "CheckBox" )
    if status == true then
        bigBet:setOpacity( 255 )
        mStake = Constants.STAKE_BIGBET
    else
        bigBet:setOpacity( 127 )
        mStake = Constants.STAKE
    end
        
    local stake = tolua.cast( mWidget:getChildByName("stake"):getChildByName("stake"), "Label" )
    local yes = tolua.cast( mWidget:getChildByName("yes"), "ImageView" )
    local no = tolua.cast( mWidget:getChildByName("no"), "ImageView" )
    local yesWinPoint = tolua.cast( yes:getChildByName("yesWinPoint"), "Label" )
    local noWinPoint = tolua.cast( no:getChildByName("noWinPoint"), "Label" )

    stake:setText( mStake )
    yesWinPoint:setText( MarketsForGameData.getOddsForType( mMarketInfo, MarketConfig.ODDS_TYPE_ONE_OPTION ) * mStake )
    noWinPoint:setText( MarketsForGameData.getOddsForType( mMarketInfo, MarketConfig.ODDS_TYPE_TWO_OPTION ) * mStake )
end

function bigBetHandler( sender, eventType )
    if eventType == TOUCH_EVENT_ENDED then
        local checkbox = tolua.cast( sender, "CheckBox" )
        selectBigBet( not checkbox:getSelectedState() )
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
    local cooldown = mWidget:getChildByName("cooldown")
    local labelTime = tolua.cast( cooldown:getChildByName("Label_Time"), "Label" )

    mRemainingTime = mRemainingTime - 1
    if mRemainingTime < 0 then
        local bigBet = tolua.cast( mWidget:getChildByName("bigBet"), "CheckBox" ) 
        --inactive
        bigBet:setOpacity( 127 )
        bigBet:setSelectedState( false )
        bigBet:addTouchEventListener( selectBigBet )
        cooldown:setEnabled( false )
    else
        labelTime:setText( os.date( "!%X", mRemainingTime ) )
        performWithDelay( mWidget, doCountdown, 1 )
    end
end