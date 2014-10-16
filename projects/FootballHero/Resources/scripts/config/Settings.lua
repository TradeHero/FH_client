module(..., package.seeall)

local Event = require("scripts.events.Event").EventList


SettingsItem = {
	{ ["itemName"] = "Push Notification", ["event"] = Event.Enter_Push_Notification, },
	{ ["itemName"] = "Sounds", ["event"] = Event.Enter_Sound_Settings, },
	{ ["itemName"] = "Send feedback", ["event"] = Event.Do_Send_Feedback, },
	--{ ["itemName"] = "Profile", ["event"] = Event.Do_Send_Feedback, },
	{ ["itemName"] = "FAQ", ["event"] = Event.Enter_FAQ, },
	--{ ["itemName"] = "Send review", ["event"] = Event.Do_Send_Feedback, },
	--{ ["itemName"] = "About", ["event"] = Event.Do_Send_Feedback, },
	{ ["itemName"] = "Logout", ["event"] = Event.Do_Log_Out, },
}
