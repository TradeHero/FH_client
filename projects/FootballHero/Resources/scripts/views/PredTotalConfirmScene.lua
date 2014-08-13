module(..., package.seeall)

local Constants = require("scripts.Constants")
local SceneManager = require("scripts.SceneManager")
local Logic = require("scripts.Logic").getInstance()
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local ConnectingMessage = require("scripts.views.ConnectingMessage")


local mWidget
local mFacebookBt
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
        mFacebookBt = nil
    end
end

function bgEventHandler( sender, eventType )
	-- Do nothing, just block
end

function confirmEventHandler( sender, eventType )
	if eventType == TOUCH_EVENT_ENDED then
		Logic:setPredictionMetadata( "", mFacebookBt:getSelectedState() )
	    EventManager:postEvent( Event.Do_Post_Predictions, { mAccessToken } )
	end
end

function cancelEventHandler( sender, eventType )
	if eventType == TOUCH_EVENT_ENDED then
		Logic:resetPredictions()
    	EventManager:postEvent( Event.Enter_Match_List )
	end
end

function facebookEventHandler( sender, eventType )
	if eventType == TOUCH_EVENT_ENDED then
		if mFacebookBt:getSelectedState() == false then
			local doShare = function()
				print("Do Share")
	            local handler = function( accessToken, success )
	            	if success then
	            		mAccessToken = accessToken
	            	else
	            		mFacebookBt:setSelectedState( false )
	            	end
	                
	                ConnectingMessage.selfRemove()
	            end
	            ConnectingMessage.loadFrame()
	            FacebookDelegate:sharedDelegate():grantPublishPermission( "publish_actions", handler )
	        end

	        if Logic:getFbId() == false then
	            local successHandler = function()
	                doShare()
	            end
	            local failedHandler = function()
	            	print("FB connect failed.")
	                mFacebookBt:setSelectedState( false )
	            end
	            EventManager:postEvent( Event.Do_FB_Connect_With_User, { successHandler, failedHandler } )
	        else
	            doShare()
	        end
		end
	end
end

function initContent()
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

		question:setText( coupon["Answer"] )
		reward:setText( string.format( reward:getStringValue(), coupon["Reward"] ) )
		stake:setText( string.format( stake:getStringValue(), coupon["Stake"] ) )
		answerIcon:loadTexture( coupon["AnswerIcon"] )

        content:setLayoutParameter( layoutParameter )
        contentContainer:addChild( content )
        contentHeight = contentHeight + content:getSize().height
	end

	local buttonsWidget = SceneManager.widgetFromJsonFile("scenes/PredFinalConfirmButton.json")
	buttonsWidget:setLayoutParameter( layoutParameter )
    contentContainer:addChild( buttonsWidget )
    contentHeight = contentHeight + buttonsWidget:getSize().height

    local confirmBt = buttonsWidget:getChildByName("confirm")
    confirmBt:addTouchEventListener( confirmEventHandler )
    local cancelBt = buttonsWidget:getChildByName("cancel")
    cancelBt:addTouchEventListener( cancelEventHandler )
    mFacebookBt = tolua.cast( buttonsWidget:getChildByName("facebook"), "CheckBox" )
    mFacebookBt:addTouchEventListener( facebookEventHandler )

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