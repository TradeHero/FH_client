module(..., package.seeall)

local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local CheckFilesVersionAction = require("scripts.actions.CheckFilesVersionAction")
local EnterMatchListAction = require("scripts.actions.EnterMatchListAction")
local EnterMatchAction = require("scripts.actions.EnterMatchAction")
local EnterPredictionConfirmAction = require("scripts.actions.EnterPredictionConfirmAction")
local EnterPredTotalConfirmAction = require("scripts.actions.EnterPredTotalConfirmAction")
local EnterLoginNRegAction = require("scripts.actions.EnterLoginNRegAction")
local EnterRegisterAction = require("scripts.actions.EnterRegisterAction")
local EnterRegisterNameAction = require("scripts.actions.EnterRegisterNameAction")
local EnterLoginAction = require("scripts.actions.EnterLoginAction")
local EnterForgotPasswordAction = require("scripts.actions.EnterForgotPasswordAction")
local EnterSelFavTeamAction = require("scripts.actions.EnterSelFavTeamAction")
local EnterNextPredictionAction = require("scripts.actions.EnterNextPredictionAction")
local EnterHistoryAction = require("scripts.actions.EnterHistoryAction")
local EnterHistoryDetailAction = require("scripts.actions.EnterHistoryDetailAction")
local EnterLeaderboardAction = require("scripts.actions.EnterLeaderboardAction")
local EnterLeaderboardListAction = require("scripts.actions.EnterLeaderboardListAction")
local EnterSettingsAction = require("scripts.actions.EnterSettingsAction")
local EnterFAQAction = require("scripts.actions.EnterFAQAction")
local DoRegisterAction = require("scripts.actions.DoRegisterAction")
local DoLoginAction = require("scripts.actions.DoLoginAction")
local DoRegisterNameAction = require("scripts.actions.DoRegisterNameAction")
local DoFBConnectAction = require("scripts.actions.DoFBConnectAction")
local DoFBConnectWithUserAction = require("scripts.actions.DoFBConnectWithUserAction")
local DoPostPredictionsAction = require("scripts.actions.DoPostPredictionsAction")
local DoPostFavTeamAction = require("scripts.actions.DoPostFavTeamAction")
local ShowErrorMessageAction = require("scripts.actions.ShowErrorMessageAction")
local LoadMoreInLeaderboardAction = require("scripts.actions.LoadMoreInLeaderboardAction")
local LoadMoreInHistoryAction = require("scripts.actions.LoadMoreInHistoryAction")

TOUCH_PRIORITY_ZERO = 0
TOUCH_PRIORITY_MINUS_ONE = -1

local mSceneGameLayer
local mWidgets = {}		-- Store widget show in the list to save time loading the same json file.

function init()
	local eglView = CCEGLView:sharedOpenGLView()
	if CCApplication:sharedApplication():getTargetPlatform() == kTargetWindows then
		eglView:setFrameSize( 541, 960 )
	end
	eglView:setDesignResolutionSize( 640, 1136, kResolutionShowAll )

	local sceneGame = CCScene:create()
	local director = CCDirector:sharedDirector()
    if director:getRunningScene() ~= nil then
    	director:replaceScene( sceneGame )
    else
    	director:runWithScene( sceneGame )
    end
    
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
	EventManager:registerEventHandler( Event.Enter_Pred_Total_Confirm, EnterPredTotalConfirmAction )
	EventManager:registerEventHandler( Event.Enter_Sel_Fav_Team, EnterSelFavTeamAction )
	EventManager:registerEventHandler( Event.Enter_Next_Prediction, EnterNextPredictionAction )
	EventManager:registerEventHandler( Event.Enter_History, EnterHistoryAction )
	EventManager:registerEventHandler( Event.Enter_History_Detail, EnterHistoryDetailAction )
	EventManager:registerEventHandler( Event.Enter_Leaderboard, EnterLeaderboardAction )
	EventManager:registerEventHandler( Event.Enter_Leaderboard_List, EnterLeaderboardListAction )
	EventManager:registerEventHandler( Event.Enter_Settings, EnterSettingsAction )
	EventManager:registerEventHandler( Event.Enter_FAQ, EnterFAQAction )
	EventManager:registerEventHandler( Event.Do_Register, DoRegisterAction )
	EventManager:registerEventHandler( Event.Do_Register_Name, DoRegisterNameAction )
	EventManager:registerEventHandler( Event.Do_Login, DoLoginAction )
	EventManager:registerEventHandler( Event.Do_FB_Connect, DoFBConnectAction )
	EventManager:registerEventHandler( Event.Do_FB_Connect_With_User, DoFBConnectWithUserAction )
	EventManager:registerEventHandler( Event.Do_Post_Predictions, DoPostPredictionsAction )
	EventManager:registerEventHandler( Event.Do_Post_Fav_Team, DoPostFavTeamAction )
	EventManager:registerEventHandler( Event.Show_Error_Message, ShowErrorMessageAction )
	EventManager:registerEventHandler( Event.Load_More_In_Leaderboard, LoadMoreInLeaderboardAction )
	EventManager:registerEventHandler( Event.Load_More_In_History, LoadMoreInHistoryAction )
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

function widgetFromJsonFile( fileName )
	if mWidgets[fileName] == nil then
		local content = GUIReader:shareReader():widgetFromJsonFile( fileName )
		content:retain()
		mWidgets[fileName] = content
	end
	return mWidgets[fileName]:clone()
end