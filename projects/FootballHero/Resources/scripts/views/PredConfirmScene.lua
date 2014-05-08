module(..., package.seeall)

local Constants = require("scripts.Constants")
local SceneManager = require("scripts.SceneManager")
local Logic = require("scripts.Logic").getInstance()
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList

local mAnswer
local mReward
local mOddId
local mAnswerIcon
local mWidget
local mTextInput

function loadFrame( answer, reward, oddId, answerIcon )

	print(answerIcon)
	mAnswer = answer
	mReward = reward
	mOddId = oddId
	mAnswerIcon = answerIcon

	local widget = GUIReader:shareReader():widgetFromJsonFile("scenes/PredConfirm.json")
    mWidget = widget
    mWidget:registerScriptHandler( EnterOrExit )
    mWidget:addTouchEventListener( bgEventHandler )
    SceneManager.addWidget(widget)

	initContent()    
    createTextInput()

    local confirmBt = widget:getChildByName("confirm")
    confirmBt:addTouchEventListener( confirmEventHandler )

    local cancelBt = widget:getChildByName("cancel")
    cancelBt:addTouchEventListener( cancelEventHandler )

    local textDisplay = mWidget:getChildByName("Text")
	textDisplay:addTouchEventListener( inputEventHandler )
end

function EnterOrExit( eventType )
    if eventType == "enter" then
    elseif eventType == "exit" then
        mWidget = nil
        mTextInput = nil
    end
end

function confirmEventHandler( sender, eventType )
	if eventType == TOUCH_EVENT_ENDED then
		local textDisplay = tolua.cast( mWidget:getChildByName("Text"), "Label" )
		local comment = textDisplay:getStringValue()

		SceneManager.clear()
		Logic:addPrediction( mOddId, comment, false )
	    EventManager:postEvent( Event.Enter_Next_Prediction )
	end
end

function cancelEventHandler( sender, eventType )
	if eventType == TOUCH_EVENT_ENDED then
		SceneManager.removeWidget( mWidget )
	end
end

function bgEventHandler( sender, eventType )
	-- Do nothing, just block
end

function inputEventHandler( sender, eventType )
	if eventType == TOUCH_EVENT_ENDED then
		mTextInput:touchDownAction( sender, eventType )
	end
end

function createTextInput()
	local container = mWidget:getChildByName("TextInput")

	local inputDelegate = EditBoxDelegateForLua:create()
	inputDelegate:registerEventScriptHandler( EDIT_BOX_EVENT_TEXT_CHANGED, function ( textBox, text )
		local textDisplay = tolua.cast( mWidget:getChildByName("Text"), "Label" )
		textDisplay:setText( text )
	end )
	container:addNode( tolua.cast( inputDelegate, "CCNode" ) )

	mTextInput = CCEditBox:create( CCSizeMake( 550, 35 ), CCScale9Sprite:create() )
    container:addNode( mTextInput )
    mTextInput:setPosition( 550 / 2, 35 / 2 )
    mTextInput:setFontColor( ccc3( 0, 0, 0 ) )
    mTextInput:setVisible( false )
    mTextInput:setDelegate( inputDelegate.__CCEditBoxDelegate__ )
    mTextInput:setTouchPriority( SceneManager.TOUCH_PRIORITY_MINUS_ONE )
end

function initContent()
	local question = tolua.cast( mWidget:getChildByName("Question"), "Label" )
	local reward = tolua.cast( mWidget:getChildByName("Reward"), "Label" )
	local answerIcon = tolua.cast( mWidget:getChildByName("answerIcon"), "ImageView" )

	question:setFontName( "Newgtbxc" )
	reward:setFontName( "Newgtbxc" )

	question:setText( mAnswer )
	reward:setText( string.format( reward:getStringValue(), mReward ) )
	answerIcon:loadTexture( mAnswerIcon )
end