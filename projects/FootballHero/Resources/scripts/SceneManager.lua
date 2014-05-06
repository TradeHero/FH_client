module(..., package.seeall)

local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local CheckFilesVersionAction = require("scripts.actions.CheckFilesVersionAction")
local EnterMatchListAction = require("scripts.actions.EnterMatchListAction")
local EnterMatchAction = require("scripts.actions.EnterMatchAction")
local EnterPredictionConfirmAction = require("scripts.actions.EnterPredictionConfirmAction")
local EnterLoginNRegAction = require("scripts.actions.EnterLoginNRegAction")
local EnterRegisterAction = require("scripts.actions.EnterRegisterAction")
local EnterRegisterNameAction = require("scripts.actions.EnterRegisterNameAction")
local EnterLoginAction = require("scripts.actions.EnterLoginAction")
local EnterForgotPasswordAction = require("scripts.actions.EnterForgotPasswordAction")
local EnterSelFavTeamAction = require("scripts.actions.EnterSelFavTeamAction")
local EnterNextPredictionAction = require("scripts.actions.EnterNextPredictionAction")
local DoRegisterAction = require("scripts.actions.DoRegisterAction")
local DoLoginAction = require("scripts.actions.DoLoginAction")
local DoRegisterNameAction = require("scripts.actions.DoRegisterNameAction")
local DoFBConnectAction = require("scripts.actions.DoFBConnectAction")
local DoPostPredictionsAction = require("scripts.actions.DoPostPredictionsAction")
local ShowErrorMessageAction = require("scripts.actions.ShowErrorMessageAction")

TOUCH_PRIORITY_ZERO = 0
TOUCH_PRIORITY_MINUS_ONE = -1

local mSceneGameLayer

function init()
	local eglView = CCEGLView:sharedOpenGLView()
	if CCApplication:sharedApplication():getTargetPlatform() == kTargetWindows then
		eglView:setFrameSize( 541, 960 )
	end
	eglView:setDesignResolutionSize( 640, 1136, kResolutionShowAll )

	local sceneGame = CCScene:create()
    CCDirector:sharedDirector():runWithScene( sceneGame )
    mSceneGameLayer = TouchGroup:create()
    sceneGame:addChild( mSceneGameLayer )

    initEvents()
end

function initEvents()
	EventManager:registerEventHandler( Event.Check_File_Version, CheckFilesVersionAction )
	EventManager:registerEventHandler( Event.Enter_Login_N_Reg, EnterLoginNRegAction )
	EventManager:registerEventHandler( Event.Enter_Register, EnterRegisterAction )
	EventManager:registerEventHandler( Event.Enter_Register_Name, EnterRegisterNameAction )
	EventManager:registerEventHandler( Event.Enter_Login, EnterLoginAction )
	EventManager:registerEventHandler( Event.Enter_Forgot_Password, EnterForgotPasswordAction )
	EventManager:registerEventHandler( Event.Enter_Match_List, EnterMatchListAction )
	EventManager:registerEventHandler( Event.Enter_Match, EnterMatchAction )
	EventManager:registerEventHandler( Event.Enter_Prediction_Confirm, EnterPredictionConfirmAction )
	EventManager:registerEventHandler( Event.Enter_Sel_Fav_Team, EnterSelFavTeamAction )
	EventManager:registerEventHandler( Event.Enter_Next_Prediction, EnterNextPredictionAction )
	EventManager:registerEventHandler( Event.Do_Register, DoRegisterAction )
	EventManager:registerEventHandler( Event.Do_Register_Name, DoRegisterNameAction )
	EventManager:registerEventHandler( Event.Do_Login, DoLoginAction )
	EventManager:registerEventHandler( Event.Do_FB_Connect, DoFBConnectAction )
	EventManager:registerEventHandler( Event.Do_Post_Predictions, DoPostPredictionsAction )
	EventManager:registerEventHandler( Event.Show_Error_Message, ShowErrorMessageAction )
end

function clearNAddWidget( widget )
	mSceneGameLayer:clear()
	addWidget( widget )
end

function clear()
	mSceneGameLayer:clear()
end

function addWidget( widget )
	mSceneGameLayer:addWidget( widget )
end

function removeWidget( widget )
	mSceneGameLayer:removeWidget( widget )
end