module(..., package.seeall)

local Constants = require("scripts.Constants")
local SceneManager = require("scripts.SceneManager")
local TeamConfig = require("scripts.config.Team")
local MarketConfig = require("scripts.config.Market")
local Logic = require("scripts.Logic").getInstance()
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local MarketsForGameData = require("scripts.data.MarketsForGameData")
local MatchPrediction = require("scripts.views.PredictionType.Match")
local TotalGoalPrediction = require("scripts.views.PredictionType.TotalGoal")
local AsianHandicapPrediction = require("scripts.views.PredictionType.AsianHandicap")
local Header = require("scripts.views.HeaderFrame")

-- Children list:
-- 1 to 3: prediction status buttons
local mWidget
local mMovableContainer
local mPredictionWidget

local mMatch
local mMarketsInfo
local mCurrentPredictionIndex
local mPredictionStatus
local mPredictionAnswers

local MIN_MOVE_DISTANCE = 100
local SWITCH_MOVE_TIME = 0.4

local mBigBetStatus = {}

function loadFrame()
    mMatch = Logic:getSelectedMatch()
    mMarketsInfo = Logic:getCurMarketInfo()
    mBigBetStatus[MarketConfig.MARKET_NAME_MATCH] = false
    mBigBetStatus[MarketConfig.MARKET_NAME_TOTAL_GOAL] = false
    mBigBetStatus[MarketConfig.MARKET_NAME_ASIAN_HANDICAP] = false

	mWidget = SceneManager.secondLayerWidgetFromJsonFile("scenes/PredictionBG.json")
    mWidget:registerScriptHandler( EnterOrExit )
    mWidget:setName( "TappablePredictionScene" )

    SceneManager.clearNAddWidget( mWidget )
    
    Header.loadFrame( mWidget, nil, true )

    local team1 = tolua.cast( mWidget:getChildByName("team1"), "ImageView" )
    local team2 = tolua.cast( mWidget:getChildByName("team2"), "ImageView" )
    local team1Name = tolua.cast( mWidget:getChildByName("team1Name"), "Label" )
    local team2Name = tolua.cast( mWidget:getChildByName("team2Name"), "Label" )
    local vs = tolua.cast( mWidget:getChildByName("Label_VS"), "Label" )

    team1:loadTexture( TeamConfig.getLogo( TeamConfig.getConfigIdByKey( mMatch["HomeTeamId"] ), true ) )
    team2:loadTexture( TeamConfig.getLogo( TeamConfig.getConfigIdByKey( mMatch["AwayTeamId"] ), false ) )
    team1Name:setText( TeamConfig.getTeamName( TeamConfig.getConfigIdByKey( mMatch["HomeTeamId"] ) ) )
    team2Name:setText( TeamConfig.getTeamName( TeamConfig.getConfigIdByKey( mMatch["AwayTeamId"] ) ) )
    vs:setText( Constants.String.vs )
    
    mMovableContainer = Layout:create()
    mMovableContainer:setSize( CCSize:new( Constants.GAME_WIDTH, Constants.GAME_HEIGHT ) )
    mMovableContainer:setTouchEnabled( true )
    mMovableContainer:addTouchEventListener( onFrameTouch )
    mWidget:addChild( mMovableContainer )

    mCurrentPredictionIndex = 1
    initPredictionStatus()
    initCurrentPredictionUI()
    mPredictionWidget.helperSetTouchEnabled( true )
end

function EnterOrExit( eventType )
    if eventType == "enter" then
    elseif eventType == "exit" then
        mWidget = nil
    end
end

function initPredictionStatus()
    local intervalX = 150
    local widgetWidth = 103
    local startX = ( Constants.GAME_WIDTH - intervalX * ( mMarketsInfo:getNum() - 1 ) ) / 2 - widgetWidth / 2
    local startY = 50

    local fileUtils = CCFileUtils:sharedFileUtils()
    mPredictionStatus = {}
    mPredictionAnswers = {}
    for i = 1, mMarketsInfo:getNum()  do
        local statusIndi = SceneManager.widgetFromJsonFile("scenes/PredictionStatus.json")
        mWidget:addChild( statusIndi, 0, i )
        statusIndi:setPosition( ccp( startX + ( i - 1 ) * intervalX, startY ) )
        local index = tolua.cast( statusIndi:getChildByName("index"), "Label" )
        index:setText( i )

        mPredictionStatus[i] = Constants.STATUS_PENDING
    end

    updatePageIndicator()
end

function initCurrentPredictionUI()
    local marketInfo = mMarketsInfo:getMarketAt( mCurrentPredictionIndex )
    local marketType = MarketsForGameData.getMarketType( marketInfo )
        
    if mPredictionWidget ~= nil then
        mPredictionWidget.releaseFrame()
    end

    if marketType == MarketConfig.MARKET_TYPE_MATCH or marketType == MarketConfig.MARKET_TYPE_MATCH_NODRAW then

        mPredictionWidget = MatchPrediction
    elseif marketType == MarketConfig.MARKET_TYPE_TOTAL_GOAL then

        mPredictionWidget = TotalGoalPrediction
    elseif marketType == MarketConfig.MARKET_TYPE_ASIAN_HANDICAP then

        mPredictionWidget = AsianHandicapPrediction
    end

    mBigBetStatus["timeToNextBet"] = mMarketsInfo:getNextBigBetRemainingTime()
    mPredictionWidget.loadFrame( mMovableContainer, mMatch, marketInfo, makePredictionCallback, mBigBetStatus, makeBigBetCallback )
    
    if mPredictionStatus[mCurrentPredictionIndex] ~= Constants.STATUS_PENDING 
        and mPredictionStatus[mCurrentPredictionIndex] ~= Constants.STATUS_SKIPPED then
        mPredictionWidget.choose( mPredictionStatus[mCurrentPredictionIndex] )
    end
end

function makeBigBetCallback( mIndex, status )
    mBigBetStatus[mIndex] = status
end

function makePredictionCallback( selectedIndex, prediction )
    mPredictionStatus[mCurrentPredictionIndex] = selectedIndex
    mPredictionAnswers[mCurrentPredictionIndex] = prediction

    if mCurrentPredictionIndex < mMarketsInfo:getNum() then
        gotoPredictionByOffset( 1 )
    elseif mCurrentPredictionIndex == mMarketsInfo:getNum() then
        goToConfirm()
        mCurrentPredictionIndex = mCurrentPredictionIndex + 1
    end
end

function goToConfirm()
    -- DS. see data/Prediction
    for i = 1, mMarketsInfo:getNum() do
        if mPredictionAnswers[i] ~= nil then
            local p = mPredictionAnswers[i]
            Logic:addPrediction( p["OddId"], p["Question"], p["Answer"], p["Rewards"], p["AnswerImagePath"], p["PredictionType"],
                                Logic:getPreviousLeagueSelected(), mMatch["HomeTeamId"], mMatch["AwayTeamId"], p["Stake"] )
        end
    end
    
    EventManager:postEvent( Event.Enter_Pred_Total_Confirm )
end

function gotoPredictionByOffset( offset )
    if mCurrentPredictionIndex + offset <= 0 or mCurrentPredictionIndex + offset > mMarketsInfo:getNum() then
        return
    end

    local moveDirection = 1
    if offset > 0 then
        moveDirection = -1
    end

    local resultSeqArray = CCArray:create()
    resultSeqArray:addObject( CCMoveBy:create( SWITCH_MOVE_TIME, ccp( Constants.GAME_WIDTH * moveDirection * 2, 0 ) ) )
    resultSeqArray:addObject( CCCallFunc:create( function()
        mCurrentPredictionIndex = mCurrentPredictionIndex + offset
        initCurrentPredictionUI()
        mMovableContainer:setPosition( ccp( Constants.GAME_WIDTH * moveDirection * (-2), 0 ) )
    end ) )
    resultSeqArray:addObject( CCMoveBy:create( SWITCH_MOVE_TIME, ccp( Constants.GAME_WIDTH * moveDirection * 2, 0 ) ) )
    resultSeqArray:addObject( CCCallFunc:create( function()
        mPredictionWidget.helperSetTouchEnabled( true )
        updatePageIndicator()
    end ) )

    mMovableContainer:runAction( CCSequence:create( resultSeqArray ) )
end

function goToConfirmWithSwapAnim()
    local moveDirection = -1
    
    local resultSeqArray = CCArray:create()
    resultSeqArray:addObject( CCCallFunc:create( function()
        mPredictionWidget.helperSetTouchEnabled( false )
    end ) )
    resultSeqArray:addObject( CCMoveBy:create( SWITCH_MOVE_TIME, ccp( Constants.GAME_WIDTH * moveDirection * 2, 0 ) ) )
    resultSeqArray:addObject( CCCallFunc:create( function()
        goToConfirm()
    end ) )

    mMovableContainer:runAction( CCSequence:create( resultSeqArray ) )
end

local originWidgetX
function onFrameTouch( sender, eventType )
    if not mPredictionWidget.helperGetTouchEnabled() then
        return
    end

    if eventType == TOUCH_EVENT_BEGAN then
        originWidgetX = mMovableContainer:getPositionX()
    elseif eventType == TOUCH_EVENT_ENDED or eventType == TOUCH_EVENT_CANCELED then
        local touchBeginPoint = sender:getTouchStartPos()
        local touchEndPoint = sender:getTouchEndPos()
        local reset = false
        if touchBeginPoint.x - touchEndPoint.x > MIN_MOVE_DISTANCE then
            -- Swap to Left
            if mPredictionStatus[mCurrentPredictionIndex] == Constants.STATUS_PENDING then
                mPredictionStatus[mCurrentPredictionIndex] = Constants.STATUS_SKIPPED
            end

            if mCurrentPredictionIndex < mMarketsInfo:getNum() then
                gotoPredictionByOffset( 1 )
            else
                -- If NOT all the answers are empty, goto the confirm page.
                local allEmpty = true
                for i = 1, mMarketsInfo:getNum() do
                    if mPredictionAnswers[i] ~= nil then
                        allEmpty = false
                        break
                    end
                end
                if allEmpty then
                    reset = true
                else
                    goToConfirmWithSwapAnim()
                end
            end
            
        elseif touchBeginPoint.x - touchEndPoint.x < MIN_MOVE_DISTANCE * (-1) and mCurrentPredictionIndex > 1 then
            -- Swap to Right
            gotoPredictionByOffset( -1 )
        else
            reset = true
        end
        if reset then
             -- Reset back
            local seqArray = CCArray:create()
            seqArray:addObject( CCCallFunc:create( function()
                mMovableContainer:setTouchEnabled( false )
            end ) )
            seqArray:addObject( CCMoveTo:create( SWITCH_MOVE_TIME, ccp( 0, 0 ) ) )
            seqArray:addObject( CCCallFunc:create( function()
                mMovableContainer:setTouchEnabled( true )
            end ) )

            mMovableContainer:runAction( CCSequence:create( seqArray ) )
        end
    elseif eventType == TOUCH_EVENT_MOVED then
        local touchBeginPoint = sender:getTouchStartPos()
        local touchMovPoint = sender:getTouchMovePos()
        local moveOffsetX = touchBeginPoint.x - touchMovPoint.x

        mMovableContainer:setPosition( ccp( originWidgetX - moveOffsetX, mMovableContainer:getPositionY() ) )
    end
end

function updatePageIndicator()
    for i = 1, mMarketsInfo:getNum() do
        local statusIndi = mWidget:getChildByTag( i )
        local button = tolua.cast( statusIndi:getChildByName("button"), "Button" )
        if i == mCurrentPredictionIndex then
            button:setBrightStyle( BRIGHT_HIGHLIGHT )
        else
            button:setBrightStyle( BRIGHT_NORMAL )
        end

        local pending = statusIndi:getChildByName("pending")
        local selected = statusIndi:getChildByName("selected")
        local skipped = statusIndi:getChildByName("skipped")
        pending:setEnabled( false )
        selected:setEnabled( false )
        skipped:setEnabled( false )
        if mPredictionStatus[i] == Constants.STATUS_PENDING then
            pending:setEnabled( true )
        elseif mPredictionStatus[i] == Constants.STATUS_SELECTED_LEFT 
            or mPredictionStatus[i] == Constants.STATUS_SELECTED_RIGHT 
            or mPredictionStatus[i] == Constants.STATUS_SELECTED_THIRD then
            selected:setEnabled( true )
            if i == mCurrentPredictionIndex then
                selected:setColor( ccc3( 255, 255, 255 ) )
            else
                selected:setColor( ccc3( 92, 200, 80 ) )
            end
        elseif mPredictionStatus[i] == Constants.STATUS_SKIPPED then
            skipped:setEnabled( true )
        end
    end
end