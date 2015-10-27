module(..., package.seeall)

local Constants = require("scripts.Constants")
local SceneManager = require("scripts.SceneManager")
local Logic = require("scripts.Logic").getInstance()
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local ConnectingMessage = require("scripts.views.ConnectingMessage")
local PushNotificationManager = require("scripts.PushNotificationManager")
local ShareConfig = require("scripts.config.Share")
local TeamConfig = require("scripts.config.Team")
local SportsConfig = require("scripts.config.Sports")


local mWidget
local mAccessToken

function loadFrame()
	local widget = GUIReader:shareReader():widgetFromJsonFile("scenes/PredFinalConfirm.json")
    mWidget = widget
    mWidget:registerScriptHandler( EnterOrExit )
    mWidget:addTouchEventListener( bgEventHandler )
    SceneManager.addWidget(mWidget)
    SceneManager.clearKeypadBackListener()
    mWidget:setName( "PredTotalConfirmScene" )

	initContent()

	mAccessToken = nil
end

function EnterOrExit( eventType )
    if eventType == "enter" then
    elseif eventType == "exit" then
        mWidget = nil
    end
end

function bgEventHandler( sender, eventType )
	-- Do nothing, just block
end

function confirmEventHandler( sender, eventType )
	if eventType == TOUCH_EVENT_ENDED then
		local callback = function()
			Logic:setPredictionMetadata( "", false )
	    	EventManager:postEvent( Event.Do_Post_Predictions, { mAccessToken } )
		end

	    AudioEngine.playEffect( AudioEngine.SUBMIT_PREDICTION )
	    
		PushNotificationManager.checkShowPredictionSwitch( callback, callback )	
	end
end

function cancelEventHandler( sender, eventType )
	if eventType == TOUCH_EVENT_ENDED then
		Logic:resetPredictions()
    	EventManager:postEvent( Event.Enter_Match_List )
	end
end

function shareEventHandler( sender, eventType )
	if eventType == TOUCH_EVENT_ENDED then
		local callback = function( success, platType )
            -- Do nothing
        end

        local match = Logic:getSelectedMatch()
        local firstPrediction = Logic:getPredictions():get( 1 )
        local homeTeamName = TeamConfig.getTeamName( TeamConfig.getConfigIdByKey( match["HomeTeamId"] ) )
        local awayTeamName = TeamConfig.getTeamName( TeamConfig.getConfigIdByKey( match["AwayTeamId"] ) )
       	local shareContent = homeTeamName.." vs "..awayTeamName.."\n"
       	shareContent = shareContent..firstPrediction["Answer"]

        EventManager:postEvent( Event.Enter_Share, { ShareConfig.SHARE_PREDICTION.."_"..SportsConfig.getCurrentSportKey(), callback, shareContent } )
	end
end

function betEventHandler( sender, eventType )
	if eventType == TOUCH_EVENT_ENDED then
    	EventManager:postEvent( Event.Enter_Bet365 )
	end
end

function initContent()

	local title = tolua.cast( mWidget:getChildByName("Label_Title"), "Label" )
	title:setText( Constants.String.match_prediction.prediction_summary )

	local contentContainer = tolua.cast( mWidget:getChildByName("resultContainer"), "ScrollView" )
    contentContainer:removeAllChildrenWithCleanup( true )

    local layoutParameter = LinearLayoutParameter:create()
    layoutParameter:setGravity(LINEAR_GRAVITY_CENTER_VERTICAL)
    local contentHeight = 0

    local predictions = Logic:getPredictions()
	for i = 1, predictions:getSize() do
		local content = SceneManager.widgetFromJsonFile("scenes/PredFinalConfirmContent.json")
		local coupon = predictions:get( i )
		local question = tolua.cast( content:getChildByName("Question"), "Label" )
		local reward = tolua.cast( content:getChildByName("Reward"), "Label" )
		local stake = tolua.cast( content:getChildByName("stake"), "Label" )
		local answerIcon = tolua.cast( content:getChildByName("answerIcon"), "ImageView" )
		local bigBet = content:getChildByName("Image_BigBet")
		local lbStake = tolua.cast( content:getChildByName("Label_Stake"), "Label" )
		local lbWin = tolua.cast( content:getChildByName("Label_Win"), "Label" )

		lbStake:setText( Constants.String.match_prediction.stake )
		lbWin:setText( Constants.String.match_prediction.win )
		question:setText( coupon["Question"] )
		reward:setText( string.format( Constants.String.num_of_points, coupon["Reward"] ) )
		stake:setText( string.format( Constants.String.num_of_points, coupon["Stake"] ) )
		answerIcon:loadTexture( coupon["AnswerIcon"] )

		if coupon["Stake"] ~= Constants.STAKE_BIGBET then
			bigBet:setEnabled( false )
		end

        content:setLayoutParameter( layoutParameter )
        contentContainer:addChild( content )
        contentHeight = contentHeight + content:getSize().height
	end

	local buttonsWidget = SceneManager.widgetFromJsonFile("scenes/PredFinalConfirmButton.json")
	buttonsWidget:setLayoutParameter( layoutParameter )
    contentContainer:addChild( buttonsWidget )
    contentHeight = contentHeight + buttonsWidget:getSize().height

    local confirmBt = tolua.cast( buttonsWidget:getChildByName("confirm"), "Button" )
    confirmBt:addTouchEventListener( confirmEventHandler )
    local cancelBt = tolua.cast( buttonsWidget:getChildByName("cancel"), "Button" )
    cancelBt:addTouchEventListener( cancelEventHandler )
    local shareBt = tolua.cast( buttonsWidget:getChildByName("share"), "CheckBox" )
    shareBt:addTouchEventListener( shareEventHandler )
    local betBt = tolua.cast( buttonsWidget:getChildByName("bet365"), "Button" )
    betBt:addTouchEventListener( betEventHandler )
    if Logic:getBetBlock() then
    	betBt:setEnabled( false )
    end

    confirmBt:setTitleText( Constants.String.button.confirm )
    cancelBt:setTitleText( Constants.String.button.cancel )

	-- Update the size of the scroll view so that it locate just above the facebook button.
	local originSize = contentContainer:getSize()
	print(originSize.height.." | "..contentHeight)
	if originSize.height > contentHeight then
		contentContainer:setTouchEnabled( false )
	end

	contentContainer:setInnerContainerSize( CCSize:new( 0, contentHeight ) )
    local layout = tolua.cast( contentContainer, "Layout" )
    layout:requestDoLayout()
end