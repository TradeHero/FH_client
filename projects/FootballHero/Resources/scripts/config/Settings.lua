module(..., package.seeall)

local Event = require("scripts.events.Event").EventList
local Constants = require("scripts.Constants")

SETTING_TYPE_INFO = 1
SETTING_TYPE_FAVORITE_TEAM = 2
SETTING_TYPE_LANGUAGE = 3
SETTING_TYPE_OTHERS = 4
SETTING_TYPE_FOLLOW = 5



SettingsItem = {
	{ ["SettingType"] = SETTING_TYPE_INFO, ["TitleKey"] = "user_info", ["Enabled"] = true, ["Items"] = 
		{
			--{ ["itemName"] = Constants.String.settings.email, ["event"] = Event.Update_Email_Address, },
			--{ ["itemName"] = Constants.String.settings.phone_num, ["event"] = Event.Update_Phone_Number, },
		},
	},
	{ ["SettingType"] = SETTING_TYPE_FAVORITE_TEAM, ["TitleKey"] = "favorite_team", ["Enabled"] = true, ["Items"] = 
		{
			--{ ["itemName"] = Constants.String.settings.choose_fav_team, ["event"] = Event.Update_Favorite_Team },
		},
	},
	{ ["SettingType"] = SETTING_TYPE_FOLLOW, ["TitleKey"] = "follow_user", ["Enabled"] = true },
	{ ["SettingType"] = SETTING_TYPE_LANGUAGE, ["TitleKey"] = "select_language", ["Enabled"] = true },
	{ ["SettingType"] = SETTING_TYPE_OTHERS, ["TitleKey"] = "others", ["Enabled"] = true, ["Items"] = 
		{
			{ ["itemName"] = "push_notification", ["event"] = Event.Enter_Push_Notification, },
			{ ["itemName"] = "sounds", ["event"] = Event.Enter_Sound_Settings, },
			{ ["itemName"] = "send_feedback", ["event"] = Event.Do_Send_Feedback, },
			{ ["itemName"] = "faq", ["event"] = Event.Enter_FAQ, },
			--{ ["itemName"] = "Send review", ["event"] = Event.Do_Send_Feedback, },
			--{ ["itemName"] = "About", ["event"] = Event.Do_Send_Feedback, },
			--{ ["itemName"] = Constants.String.settings.logout, ["event"] = Event.Do_Log_Out, },
		},
	},

	
}