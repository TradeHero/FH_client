module(..., package.seeall)

local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList


TOUCH_PRIORITY_ZERO = 0
TOUCH_PRIORITY_MINUS_ONE = -1
TOUCH_PRIORITY_MINUS_TWO = -2

local mSceneGameLayer
local mKeyPadBackEnabled = true
local mKeypadBackListener = nil
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

    mSceneGameLayer:setKeypadEnabled( true )
    mSceneGameLayer:registerScriptKeypadHandler( keypadEventHandler )

    initEvents()
end

function initEvents()
	EventManager:registerEventHandler( Event.Check_File_Version, "scripts.actions.CheckFilesVersionAction" )
	EventManager:registerEventHandler( Event.Check_Start_Tutorial, "scripts.actions.CheckStartTutorialAction" )
	EventManager:registerEventHandler( Event.Enter_Login_N_Reg, "scripts.actions.EnterLoginNRegAction" )
	EventManager:registerEventHandler( Event.Enter_Email_Login_N_Reg, "scripts.actions.EnterEmailLoginNRegAction" )
	EventManager:registerEventHandler( Event.Enter_Register, "scripts.actions.EnterRegisterAction" )
	EventManager:registerEventHandler( Event.Enter_Register_Name, "scripts.actions.EnterRegisterNameAction" )
	EventManager:registerEventHandler( Event.Enter_Login, "scripts.actions.EnterLoginAction" )
	EventManager:registerEventHandler( Event.Enter_Forgot_Password, "scripts.actions.EnterForgotPasswordAction" )
	EventManager:registerEventHandler( Event.Enter_Match_List, "scripts.actions.EnterMatchListAction" )
	EventManager:registerEventHandler( Event.Enter_Match, "scripts.actions.EnterMatchAction" )
	EventManager:registerEventHandler( Event.Enter_Prediction_Confirm, "scripts.actions.EnterPredictionConfirmAction" )
	EventManager:registerEventHandler( Event.Enter_Pred_Total_Confirm, "scripts.actions.EnterPredTotalConfirmAction" )
	EventManager:registerEventHandler( Event.Enter_Sel_Fav_Team, "scripts.actions.EnterSelFavTeamAction" )
	EventManager:registerEventHandler( Event.Enter_Next_Prediction, "scripts.actions.EnterNextPredictionAction" )
	EventManager:registerEventHandler( Event.Enter_History, "scripts.actions.EnterHistoryAction" )
	EventManager:registerEventHandler( Event.Enter_History_Detail, "scripts.actions.EnterHistoryDetailAction" )
	EventManager:registerEventHandler( Event.Enter_Community, "scripts.actions.EnterCommunityAction" )
	EventManager:registerEventHandler( Event.Enter_Leaderboard_List, "scripts.actions.EnterLeaderboardListAction" )
	EventManager:registerEventHandler( Event.Enter_Settings, "scripts.actions.EnterSettingsAction" )
	EventManager:registerEventHandler( Event.Enter_Push_Notification, "scripts.actions.EnterPushNotificationAction" )
	EventManager:registerEventHandler( Event.Enter_Sound_Settings, "scripts.actions.EnterSoundSettingsAction" )
	EventManager:registerEventHandler( Event.Enter_FAQ, "scripts.actions.EnterFAQAction" )
	EventManager:registerEventHandler( Event.Enter_Create_Competition, "scripts.actions.EnterCreateCompetitionAction" )
	EventManager:registerEventHandler( Event.Enter_View_Selected_Leagues, "scripts.actions.EnterViewSelectedLeaguesAction" )
	EventManager:registerEventHandler( Event.Enter_Competition_Leagues, "scripts.actions.EnterCompetitionLeaguesAction" )
	EventManager:registerEventHandler( Event.Enter_Competition_Detail, "scripts.actions.EnterCompetitionDetailAction" )
	EventManager:registerEventHandler( Event.Enter_Competition_More, "scripts.actions.EnterCompetitionMoreAction" )
	EventManager:registerEventHandler( Event.Enter_Competition_Chat, "scripts.actions.EnterCompetitionChatAction" )
	EventManager:registerEventHandler( Event.Enter_Competition_Prize, "scripts.actions.EnterCompetitionPrizeAction" )
	EventManager:registerEventHandler( Event.Enter_Competition_Rules, "scripts.actions.EnterCompetitionRulesAction" )
	EventManager:registerEventHandler( Event.Enter_Competition_Terms, "scripts.actions.EnterCompetitionTermsAction" )
	EventManager:registerEventHandler( Event.Enter_Tutorial_Ui_With_Type, "scripts.actions.EnterTutorialUiWithTypeAction" )
	EventManager:registerEventHandler( Event.Enter_League_Chat, "scripts.actions.EnterLeagueChatAction" )
	EventManager:registerEventHandler( Event.Enter_League_Chat_List, "scripts.actions.EnterLeagueChatListAction" )
	EventManager:registerEventHandler( Event.Enter_Share, "scripts.actions.EnterShareAction" )
	EventManager:registerEventHandler( Event.Do_Register, "scripts.actions.DoRegisterAction" )
	EventManager:registerEventHandler( Event.Do_Register_Name, "scripts.actions.DoRegisterNameAction" )
	EventManager:registerEventHandler( Event.Do_Login, "scripts.actions.DoLoginAction" )
	EventManager:registerEventHandler( Event.Do_FB_Connect, "scripts.actions.DoFBConnectAction" )
	EventManager:registerEventHandler( Event.Do_FB_Connect_With_User, "scripts.actions.DoFBConnectWithUserAction" )
	EventManager:registerEventHandler( Event.Do_Post_Predictions, "scripts.actions.DoPostPredictionsAction" )
	EventManager:registerEventHandler( Event.Do_Post_Fav_Team, "scripts.actions.DoPostFavTeamAction" )
	EventManager:registerEventHandler( Event.Do_Post_Logo, "scripts.actions.DoPostLogoAction" )
	EventManager:registerEventHandler( Event.Do_Post_PN_User_Settings, "scripts.actions.DoPostPNUserSettingAction" )
	EventManager:registerEventHandler( Event.Do_Post_PN_Comp_Settings, "scripts.actions.DoPostPNCompetitionSettingAction" )
	EventManager:registerEventHandler( Event.Do_Post_Device_Token, "scripts.actions.DoPostDeviceTokenAction" )
	EventManager:registerEventHandler( Event.Do_Log_Out, "scripts.actions.DoLogOutAction" )
	EventManager:registerEventHandler( Event.Do_Create_Competition, "scripts.actions.DoCreateCompetitionAction" )
	EventManager:registerEventHandler( Event.Do_Join_Competition, "scripts.actions.DoJoinCompetitionAction" )
	EventManager:registerEventHandler( Event.Do_Leave_Competition, "scripts.actions.DoLeaveCompetitionAction" )
	EventManager:registerEventHandler( Event.Do_Share_Competition, "scripts.actions.DoShareCompetitionAction" )
	EventManager:registerEventHandler( Event.Do_Send_Feedback, "scripts.actions.DoSendFeedbackAction" )
	EventManager:registerEventHandler( Event.Do_Password_Reset, "scripts.actions.DoPasswordResetAction" )
	EventManager:registerEventHandler( Event.Do_Send_Chat_Message, "scripts.actions.DoPostChatMessageAction" )
	EventManager:registerEventHandler( Event.Do_Get_Chat_Message, "scripts.actions.DoGetChatMessageAction" )
	EventManager:registerEventHandler( Event.Do_Share_By_SMS, "scripts.actions.DoShareBySMSAction" )
	EventManager:registerEventHandler( Event.Do_Share_By_Email, "scripts.actions.DoShareByEmailAction" )
	EventManager:registerEventHandler( Event.Show_Error_Message, "scripts.actions.ShowErrorMessageAction" )
	EventManager:registerEventHandler( Event.Show_Choice_Message, "scripts.actions.ShowChoiceMessageAction" )
	EventManager:registerEventHandler( Event.Show_Info, "scripts.actions.ShowInfoAction" )
	EventManager:registerEventHandler( Event.Show_Marketing_Message, "scripts.actions.ShowMarketingAction" )
	EventManager:registerEventHandler( Event.Show_Please_Update, "scripts.actions.ShowPleaseUpdateAction" )
	EventManager:registerEventHandler( Event.Load_More_In_Leaderboard, "scripts.actions.LoadMoreInLeaderboardAction" )
	EventManager:registerEventHandler( Event.Load_More_In_History, "scripts.actions.LoadMoreInHistoryAction" )
	EventManager:registerEventHandler( Event.Load_More_In_Competition_Detail, "scripts.actions.LoadMoreInCompetitionDetailAction" )
end

function keypadEventHandler( eventType )
    if mKeyPadBackEnabled and eventType == "backClicked" then
        if mKeypadBackListener ~= nil then
        	mKeypadBackListener()
        else
        	-- Todo exit the app
        	local TerminateMessage = require("scripts.views.TerminateMessage")

        	if TerminateMessage.isShown() then
        		if CCApplication:sharedApplication():getTargetPlatform() == kTargetAndroid then
			        Misc:sharedDelegate():terminate()
			    else
			        TerminateMessage.selfRemove()
			    end
        	else
        		TerminateMessage.loadFrame()
        	end
        end
    end
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

function getWidgetByName( name )
	return mSceneGameLayer:getWidgetByName( name )
end

function setKeyPadBackEnabled( enabled )
	mKeyPadBackEnabled = enabled
end

function setKeypadBackListener( func )
	mKeypadBackListener = func
	mKeyPadBackEnabled = true
end

function clearKeypadBackListener()
	mKeypadBackListener = nil
	mKeyPadBackEnabled = true
end

function widgetFromJsonFile( fileName )
	if mWidgets[fileName] == nil then
		local content = GUIReader:shareReader():widgetFromJsonFile( fileName )
		content:retain()
		mWidgets[fileName] = content
	end
	return mWidgets[fileName]:clone()
end