module(..., package.seeall)

local Constants = require("scripts.Constants")

LeagueChatType = {
	{
		["labelName"] = "Label_English", 
		["buttonName"] = "Button_English", 
		["displayName"] = Constants.String.league_chat.english, 
		["logo"] = Constants.CHAT_IMAGE_PATH.."icn-england-logo.png", 
		["chatRoomId"] = "global-english",
		["color"] = ccc3( 29, 49, 141 )
	},
	{
		["labelName"] = "Label_Spanish", 
		["buttonName"] = "Button_Spanish", 
		["displayName"] = Constants.String.league_chat.spanish, 
		["logo"] = Constants.CHAT_IMAGE_PATH.."icn-spanish-logo.png", 
		["chatRoomId"] = "global-spanish",
		["color"] = ccc3( 35, 91, 28 )
	},
	{
		["labelName"] = "Label_Italian", 
		["buttonName"] = "Button_Italian", 
		["displayName"] = Constants.String.league_chat.italian, 
		["logo"] = Constants.CHAT_IMAGE_PATH.."icn-italian-logo.png", 
		["chatRoomId"] = "global-italian",
		["color"] = ccc3( 193, 3, 5 )
	},
	{
		["labelName"] = "Label_German", 
		["buttonName"] = "Button_German", 
		["displayName"] = Constants.String.league_chat.german, 
		["logo"] = Constants.CHAT_IMAGE_PATH.."icn-german-logo.png", 
		["chatRoomId"] = "global-german",
		["color"] = ccc3( 197, 187, 11 )
	},
	{
		["labelName"] = "Label_Uefa", 
		["buttonName"] = "Button_Uefa", 
		["displayName"] = Constants.String.league_chat.uefa, 
		["logo"] = Constants.CHAT_IMAGE_PATH.."icn-uefa-logo.png", 
		["chatRoomId"] = "global-uefa",
		["color"] = ccc3( 12, 121, 149 )
	},
	{
		["labelName"] = "Label_Others", 
		["buttonName"] = "Button_Others", 
		["displayName"] = Constants.String.league_chat.others, 
		["logo"] = Constants.CHAT_IMAGE_PATH.."icn-misc-logo.png", 
		["chatRoomId"] = "global-others",
		["color"] = ccc3( 137, 10, 108 )
	},
	{
		["labelName"] = "Label_Feedback", 
		["buttonName"] = "Button_Feedback", 
		["displayName"] = Constants.String.league_chat.feedback, 
		["logo"] = Constants.CHAT_IMAGE_PATH.."icn-feedback-logo.png", 
		["chatRoomId"] = "global-feedback",
		["color"] = ccc3( 153, 160, 171 )
	},
}
