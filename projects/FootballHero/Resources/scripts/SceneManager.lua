module(..., package.seeall)

local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local EnterMatchListAction = require("scripts.actions.EnterMatchListAction")
local EnterMatchAction = require("scripts.actions.EnterMatchAction")
local EnterPredictionConfirmAction = require("scripts.actions.EnterPredictionConfirmAction")
local EnterLoginNRegAction = require("scripts.actions.EnterLoginNRegAction")
local EnterRegisterAction = require("scripts.actions.EnterRegisterAction")
local EnterRegisterNameAction = require("scripts.actions.EnterRegisterNameAction")
local EnterLoginAction = require("scripts.actions.EnterLoginAction")
local EnterForgotPasswordAction = require("scripts.actions.EnterForgotPasswordAction")

local mSceneGameLayer

function init()
	local eglView = CCEGLView:sharedOpenGLView()
	if CCApplication:sharedApplication():getTargetPlatform() == kTargetWindows then
		eglView:setFrameSize( 640, 1136 )
	end
	eglView:setDesignResolutionSize( 640, 1136, kResolutionShowAll )

	local sceneGame = CCScene:create()
    CCDirector:sharedDirector():runWithScene( sceneGame )
    mSceneGameLayer = TouchGroup:create()
    sceneGame:addChild( mSceneGameLayer )

    initEvents()
end

function initEvents()
	EventManager:registerEventHandler( Event.Enter_Login_N_Reg, EnterLoginNRegAction )
	EventManager:registerEventHandler( Event.Enter_Register, EnterRegisterAction )
	EventManager:registerEventHandler( Event.Enter_Register_Name, EnterRegisterNameAction )
	EventManager:registerEventHandler( Event.Enter_Login, EnterLoginAction )
	EventManager:registerEventHandler( Event.Enter_Forgot_Password, EnterForgotPasswordAction )
	EventManager:registerEventHandler( Event.Enter_Match_List, EnterMatchListAction )
	EventManager:registerEventHandler( Event.Enter_Match, EnterMatchAction )
	EventManager:registerEventHandler( Event.Enter_Prediction_Confirm, EnterPredictionConfirmAction )
end

function clearNAddWidget( widget )
	mSceneGameLayer:clear()
	addWidget( widget )
end

function addWidget( widget )
	mSceneGameLayer:addWidget( widget )
end