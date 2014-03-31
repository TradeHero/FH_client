module(..., package.seeall)

local Constants = require("scripts.Constants")
local SceneManager = require("scripts.SceneManager")
local MatchConfig = require("scripts.config.Match")
local Logic = require("scripts.Logic").getInstance()
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList

local mPrediction
local mTeamName
local mReward
local mWidget

function loadFrame( prediction, teamName, reward )

	mPrediction = prediction
	mTeamName = teamName
	mReward = reward

	local widget = GUIReader:shareReader():widgetFromJsonFile("scenes/PredConfirm/PredConfirm.ExportJson")
    SceneManager.clearNAddWidget(widget)
    mWidget = widget

	initContent()    
    createTextInput()

    local submitBt = widget:getChildByName("Submit")
    submitBt:addTouchEventListener( submitEventHandler )

    local backBt = widget:getChildByName("Back")
    backBt:addTouchEventListener( backEventHandler )
end

function submitEventHandler( sender, eventType )
	if eventType == TOUCH_EVENT_ENDED then
		local matchIndex = Logic:getSelectedMatchIndex()

		local scorePredictionList = MatchConfig.getPredictionList( matchIndex )

		Logic:addPrediction( matchIndex, mPrediction )
	    EventManager:postEvent( Event.Load_Match_List )
	    --[[
	    if table.getn( scorePredictionList ) == 0 then
	        EventManager:postEvent( Event.Load_Match_List )
	    else
	        ScorePrediction.loadFrame()
	    end
	    ]]
	end
end

function backEventHandler( sender, eventType )
	if eventType == TOUCH_EVENT_ENDED then
		EventManager:postEvent( Event.Enter_Match )
	end
end

function createTextInput() 
	local textInput = CCEditBox:create( CCSizeMake( 500, 40 ), CCScale9Sprite:create( "images/6.png" ) )
    local container = mWidget:getChildByName("TextInput")
    container:addNode( textInput )
    textInput:setPosition( 250, 20 )
    textInput:setFont("Newgtbxc", 20)
    textInput:setPlaceHolder("Write something here to share...")
end

function initContent()
	local question = tolua.cast( mWidget:getChildByName("Question"), "Label" )
	local answer = tolua.cast( mWidget:getChildByName("Answer"), "Label" )
	local reward = tolua.cast( mWidget:getChildByName("Reward"), "Label" )

	question:setFontName( "Newgtbxc" )
	answer:setFontName( "Newgtbxc" )
	reward:setFontName( "Newgtbxc" )

	answer:setText( mTeamName )
	reward:setText( "-Win "..mReward.." points." )
end