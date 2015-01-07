module(..., package.seeall)

local Constants = require("scripts.Constants")
local SceneManager = require("scripts.SceneManager")
local TeamConfig = require("scripts.config.Team")

local Logic = require("scripts.Logic").getInstance()
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList


-- Children list:
-- 1 to 3: prediction status buttons
local mWidget

local mMatch
local mMarketsInfo

local MIN_MOVE_DISTANCE = 100
local SWITCH_MOVE_TIME = 0.4

local mBigBetStatus = {}

function loadFrame()
    mMatch = Logic:getSelectedMatch()
    
	mWidget = GUIReader:shareReader():widgetFromJsonFile("scenes/MatchCenterTopScene.json")
    mWidget:registerScriptHandler( EnterOrExit )
    SceneManager.clearNAddWidget( mWidget )
    SceneManager.setKeypadBackListener( keypadBackEventHandler )
    
    local title = tolua.cast( mWidget:getChildByName("Label_Title"), "Label" )
    local date = tolua.cast( mWidget:getChildByName("Label_Date"), "Label" )
    local played = tolua.cast( mWidget:getChildByName("Label_Played"), "Label" )
    local predict = tolua.cast( mWidget:getChildByName("Button_Prediction"), "Button" )
    local discussion = tolua.cast( mWidget:getChildByName("Button_Discussion"), "Button" )
    local meetings = tolua.cast( mWidget:getChildByName("Button_Meetings"), "Button" )

    local team1 = tolua.cast( mWidget:getChildByName("Image_Team1"), "ImageView" )
    local team2 = tolua.cast( mWidget:getChildByName("Image_Team2"), "ImageView" )
    local team1Name = tolua.cast( mWidget:getChildByName("Label_Team1"), "Label" )
    local team2Name = tolua.cast( mWidget:getChildByName("Label_Team2"), "Label" )
    local vs = tolua.cast( mWidget:getChildByName("Label_VS"), "Label" )

    title:setText( Constants.String.match_center.title )
    date:setText( os.date( "%b %d, %H:%M", mMatch["StartTime"] ) )
    played:setText( string.format( Constants.String.match_center.played, mMatch["PredictionsPlayed"], mMatch["PredictionsAvailable"] ) )
    discussion:setTitleText( Constants.String.match_center.title_discussion )
    meetings:setTitleText( Constants.String.match_center.title_meetings )

    if mMatch["PredictionsAvailable"] > 0 and mMatch["PredictionsPlayed"] == mMatch["PredictionsAvailable"] then
        predict:setTitleText( Constants.String.match_center.prediction_made )
        predict:setBright( false )
    else
        predict:setTitleText( Constants.String.match_center.make_prediction )

        local eventHandler = function( sender, eventType )
            if eventType == TOUCH_EVENT_ENDED then
                enterMatch()
            end
        end
        predict:addTouchEventListener( eventHandler )
    end

    team1:loadTexture( TeamConfig.getLogo( TeamConfig.getConfigIdByKey( mMatch["HomeTeamId"] ) ) )
    team2:loadTexture( TeamConfig.getLogo( TeamConfig.getConfigIdByKey( mMatch["AwayTeamId"] ) ) )
    team1Name:setText( TeamConfig.getTeamName( TeamConfig.getConfigIdByKey( mMatch["HomeTeamId"] ) ) )
    team2Name:setText( TeamConfig.getTeamName( TeamConfig.getConfigIdByKey( mMatch["AwayTeamId"] ) ) )
    vs:setText( Constants.String.vs )

    local backBt = mWidget:getChildByName("Button_Back")
    backBt:addTouchEventListener( backEventHandler )
end

function EnterOrExit( eventType )
    if eventType == "enter" then
    elseif eventType == "exit" then
        mWidget = nil
    end
end

function backEventHandler( sender, eventType )
    if eventType == TOUCH_EVENT_ENDED then
        keypadBackEventHandler()
    end
end

function keypadBackEventHandler()
    EventManager:popHistory()
end

function enterMatch()
    EventManager:postEvent( Event.Enter_Match, { mMatch["Id"] } )
end
