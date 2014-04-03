module(..., package.seeall)

local Constants = require("scripts.Constants")
local SceneManager = require("scripts.SceneManager")
local TeamConfig = require("scripts.config.Team")
local MatchConfig = require("scripts.config.Match")
local MatchListScene = require("scripts.MatchListScene")
local Logic = require("scripts.Logic").getInstance()

local mWidget
local mMatchIndex = 0
local mCurrentPredictionQuest = 1

function loadFrame()
	mMatchIndex = Logic:getSelectedMatchIndex()

	local widget = GUIReader:shareReader():widgetFromJsonFile("scenes/MatchPrediction/ScorePrediction.ExportJson")
    SceneManager.clearNAddWidget(widget)
    mWidget = widget

    helperInitMatchInfo( widget, mMatchIndex )
    initPredictionQuest()
end

function initPredictionQuest()
	local scorePredictionList = MatchConfig.getPredictionList( mMatchIndex )
	if mCurrentPredictionQuest > table.getn( scorePredictionList ) then
		MatchListScene.loadFrame()
	else
		local prediction = scorePredictionList[mCurrentPredictionQuest]
		local predictionType = prediction["predictionType"]
		local questionString = ""
		if predictionType == "Handicap" then
			questionString = "Will teamA win by more than "..prediction["value1"].." goals?"
		elseif predictionType == "TotalGoals" then
			questionString = "Will total goals be more than "..prediction["value1"].." ?"
		elseif predictionType == "BothToScore" then
			questionString = "Will both teams score?"
		elseif predictionType == "OddEven" then
			questionString = "Will total number of goals be Even?"
		end

		local questionLabel = tolua.cast( mWidget:getChildByName("question"), "Label" )
		questionLabel:setText( questionString )
 	end
end

function yesEventHandler( sender, eventType )
    if eventType == TOUCH_EVENT_ENDED then
    	Logic:addScorePrediction( mMatchIndex, mCurrentPredictionQuest, Constants.YES )

        mCurrentPredictionQuest = mCurrentPredictionQuest + 1
        initPredictionQuest()
    end
end

function noEventHandler( sender, eventType )
    if eventType == TOUCH_EVENT_ENDED then
    	Logic:addScorePrediction( mMatchIndex, mCurrentPredictionQuest, Constants.NO )

        mCurrentPredictionQuest = mCurrentPredictionQuest + 1
        initPredictionQuest()
    end
end

function helperInitMatchInfo( content, matchIndex )
    local team1 = tolua.cast( content:getChildByName("team1"), "ImageView" )
    local team2 = tolua.cast( content:getChildByName("team2"), "ImageView" )

    team1:loadTexture( Constants.TEAM_IMAGE_PATH..TeamConfig.getLogo( MatchConfig.getTeam1( matchIndex ) ) )
    team2:loadTexture( Constants.TEAM_IMAGE_PATH..TeamConfig.getLogo( MatchConfig.getTeam2( matchIndex ) ) )
end