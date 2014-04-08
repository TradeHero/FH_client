module(..., package.seeall)

local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local LoadMatchListAction = require("scripts.actions.LoadMatchListAction")
local EnterMatchAction = require("scripts.actions.EnterMatchAction")
local PredictionConfirmAction = require("scripts.actions.PredictionConfirmAction")
local LoginNRegAction = require("scripts.actions.LoginNRegAction")
local RegisterAction = require("scripts.actions.RegisterAction")
local RegisterNameAction = require("scripts.actions.RegisterNameAction")

local mSceneGameLayer

function init()
	local eglView = CCEGLView:sharedOpenGLView()
	if CCApplication:sharedApplication():getTargetPlatform() == kTargetWindows then
		eglView:setFrameSize( 640, 960 )
	end
	eglView:setDesignResolutionSize( 640, 960, kResolutionShowAll )

	local sceneGame = CCScene:create()
    CCDirector:sharedDirector():runWithScene( sceneGame )
    mSceneGameLayer = TouchGroup:create()
    sceneGame:addChild( mSceneGameLayer )

    initEvents()
end

function initEvents()
	EventManager:registerEventHandler( Event.Login_N_Reg, LoginNRegAction )
	EventManager:registerEventHandler( Event.Register, RegisterAction )
	EventManager:registerEventHandler( Event.Register_Name, RegisterNameAction )
	EventManager:registerEventHandler( Event.Load_Match_List, LoadMatchListAction )
	EventManager:registerEventHandler( Event.Enter_Match, EnterMatchAction )
	EventManager:registerEventHandler( Event.Prediction_Confirm, PredictionConfirmAction )
end

function clearNAddWidget( widget )
	mSceneGameLayer:clear()
	addWidget( widget )
end

function addWidget( widget )
	mSceneGameLayer:addWidget( widget )
end