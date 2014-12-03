module(..., package.seeall)

local Constants = require("scripts.Constants")
local RequestUtils = require("scripts.RequestUtils")

LeagueChatType = {
	{ ["displayName"] = Constants.String.league_chat.english, ["logo"] = Constants.CHAT_IMAGE_PATH.."icn-england-room.png", ["chatRoomId"] = "global-1" },
	{ ["displayName"] = Constants.String.league_chat.spanish, ["logo"] = Constants.CHAT_IMAGE_PATH.."icn-spanish-room.png", ["chatRoomId"] = "global-2" },
	{ ["displayName"] = Constants.String.league_chat.italian, ["logo"] = Constants.CHAT_IMAGE_PATH.."icn-italian-room.png", ["chatRoomId"] = "global-3" },
	{ ["displayName"] = Constants.String.league_chat.german, ["logo"] = Constants.CHAT_IMAGE_PATH.."icn-german-room.png", ["chatRoomId"] = "global-4" },
	{ ["displayName"] = Constants.String.league_chat.uefa, ["logo"] = Constants.CHAT_IMAGE_PATH.."icn-uefa-room.png", ["chatRoomId"] = "global-5" },
	{ ["displayName"] = Constants.String.league_chat.others, ["logo"] = Constants.CHAT_IMAGE_PATH.."icn-misc-room.png", ["chatRoomId"] = "global-6" },
	{ ["displayName"] = Constants.String.league_chat.feedback, ["logo"] = Constants.CHAT_IMAGE_PATH.."icn-feedback-room.png", ["chatRoomId"] = "global-7" },
}
