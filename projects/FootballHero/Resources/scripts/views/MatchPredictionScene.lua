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
local mMarketsData

local MIN_MOVE_DISTANCE = 100
local SCALE_UP_OFFSET_MAX = 0.2
local SCALE_DOWN_OFFSET_MAX = -0.2
local OPACITY = 255


-- Param: marketsData is the object for MarketsForGameData
function loadFrame( marketsData )
	local widget = GUIReader:shareReader():widgetFromJsonFile("scenes/MatchPrediction.json")
    mMarketsData = marketsData

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
    local match = Logic:getSelectedMatch()
    local matchMarketData = mMarketsData:getMatchMarket()

    makePrediction( Constants.TEAM1_WIN, 
        TeamConfig.getTeamName( TeamConfig.getConfigIdByKey( match["HomeTeamId"] ) ), 
        MarketsForGameData.getOddsForType( matchMarketData, MarketConfig.ODDS_TYPE_HOME_WIN ) )
end

function selectTeam2Win()
    local match = Logic:getSelectedMatch()
    local matchMarketData = mMarketsData:getMatchMarket()

    makePrediction( Constants.TEAM2_WIN, 
        TeamConfig.getTeamName( TeamConfig.getConfigIdByKey( match["AwayTeamId"] ) ), 
        MarketsForGameData.getOddsForType( matchMarketData, MarketConfig.ODDS_TYPE_AWAY_WIN ) )
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

function helperUpdatePoint( content )
    local point = Logic:getPoint()
    local pointLabel = tolua.cast( content:getChildByName("myPoint"), "Label" )
    pointLabel:setText( point )
end

function helperInitMatchInfo( content, marketsData )
    local match = Logic:getSelectedMatch()
    local matchMarketData = mMarketsData:getMatchMarket()

    local team1 = tolua.cast( content:getChildByName("team1"), "ImageView" )
    local team2 = tolua.cast( content:getChildByName("team2"), "ImageView" )
    local team1Name = tolua.cast( content:getChildByName("team1Name"), "Label" )
    local team2Name = tolua.cast( content:getChildByName("team2Name"), "Label" )
    local team1WinPoint = tolua.cast( team1:getChildByName("team1WinPoint"), "Label" )
    local team2WinPoint = tolua.cast( team2:getChildByName("team2WinPoint"), "Label" )

    team1:loadTexture( Constants.TEAM_IMAGE_PATH..TeamConfig.getLogo( TeamConfig.getConfigIdByKey( match["HomeTeamId"] ) ) )
    team2:loadTexture( Constants.TEAM_IMAGE_PATH..TeamConfig.getLogo( TeamConfig.getConfigIdByKey( match["AwayTeamId"] ) ) )
    team1Name:setText( TeamConfig.getTeamName( TeamConfig.getConfigIdByKey( match["HomeTeamId"] ) ) )
    team2Name:setText( TeamConfig.getTeamName( TeamConfig.getConfigIdByKey( match["AwayTeamId"] ) ) )
    team1WinPoint:setText( MarketsForGameData.getOddsForType( matchMarketData, MarketConfig.ODDS_TYPE_HOME_WIN ).." points" )
    team2WinPoint:setText( MarketsForGameData.getOddsForType( matchMarketData, MarketConfig.ODDS_TYPE_AWAY_WIN ).." points" )
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
            team1:setScale( 1 )
            team2:setScale( 1 )
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
            team2:setScale( scalePercentage * SCALE_UP_OFFSET_MAX + 1 )
            team1:setScale( scalePercentage * SCALE_DOWN_OFFSET_MAX + 1 )
            team2:setOpacity( OPACITY )
            team1:setOpacity( OPACITY / 3 )
        else
            team1:setScale( scalePercentage * SCALE_UP_OFFSET_MAX + 1 )
            team2:setScale( scalePercentage * SCALE_DOWN_OFFSET_MAX + 1 )
            team1:setOpacity( OPACITY )
            team2:setOpacity( OPACITY / 3 )
        end
    end
end