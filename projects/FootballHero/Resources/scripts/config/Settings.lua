module(..., package.seeall)

local Event = require("scripts.events.Event").EventList
local Constants = require("scripts.Constants")

SettingsItem = {
	{ ["itemName"] = Constants.String.settings.push_notification, ["event"] = Event.Enter_Push_Notification, },
	{ ["itemName"] = Constants.String.settings.sounds, ["event"] = Event.Enter_Sound_Settings, },
	{ ["itemName"] = Constants.String.settings.send_feedback, ["event"] = Event.Do_Send_Feedback, },
	--{ ["itemName"] = "Profile", ["event"] = Event.Do_Send_Feedback, },
	{ ["itemName"] = Constants.String.settings.faq, ["event"] = Event.Enter_FAQ, },
	--{ ["itemName"] = "Send review", ["event"] = Event.Do_Send_Feedback, },
	--{ ["itemName"] = "About", ["event"] = Event.Do_Send_Feedback, },
	{ ["itemName"] = Constants.String.settings.logout, ["event"] = Event.Do_Log_Out, },
}
