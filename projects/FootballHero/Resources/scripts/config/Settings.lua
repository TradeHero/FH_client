module(..., package.seeall)

local Event = require("scripts.events.Event").EventList
local Constants = require("scripts.Constants")

SETTING_TYPE_INFO = 1
SETTING_TYPE_FAVORITE_TEAM = 2
SETTING_TYPE_LANGUAGE = 3
SETTING_TYPE_OTHERS = 4

KEY_OF_LANGUAGE = "app-language"

SettingsItem = {
	{ ["SettingType"] = SETTING_TYPE_INFO, ["Title"] = Constants.String.settings.user_info, ["Enabled"] = true, ["Items"] = 
		{
			--{ ["itemName"] = Constants.String.settings.email, ["event"] = Event.Update_Email_Address, },
			--{ ["itemName"] = Constants.String.settings.phone_num, ["event"] = Event.Update_Phone_Number, },
		},
	},
	{ ["SettingType"] = SETTING_TYPE_FAVORITE_TEAM, ["Title"] = Constants.String.settings.favorite_team, ["Enabled"] = false, ["Items"] = 
		{
			--{ ["itemName"] = Constants.String.settings.choose_fav_team, ["event"] = Event.Update_Favorite_Team },
		},
	},
	{ ["SettingType"] = SETTING_TYPE_LANGUAGE, ["Title"] = Constants.String.settings.select_language, ["Enabled"] = true },
	{ ["SettingType"] = SETTING_TYPE_OTHERS, ["Title"] = Constants.String.settings.others, ["Enabled"] = true, ["Items"] = 
		{
			{ ["itemName"] = Constants.String.settings.push_notification, ["event"] = Event.Enter_Push_Notification, },
			{ ["itemName"] = Constants.String.settings.sounds, ["event"] = Event.Enter_Sound_Settings, },
			{ ["itemName"] = Constants.String.settings.send_feedback, ["event"] = Event.Do_Send_Feedback, },
			{ ["itemName"] = Constants.String.settings.faq, ["event"] = Event.Enter_FAQ, },
			--{ ["itemName"] = "Send review", ["event"] = Event.Do_Send_Feedback, },
			--{ ["itemName"] = "About", ["event"] = Event.Do_Send_Feedback, },
			--{ ["itemName"] = Constants.String.settings.logout, ["event"] = Event.Do_Log_Out, },
		},
	},

	
}