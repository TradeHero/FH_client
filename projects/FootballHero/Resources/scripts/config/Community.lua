module(..., package.seeall)

local Constants = require("scripts.Constants")
local RequestUtils = require("scripts.RequestUtils")

COMMUNITY_TAB_ID_COMPETITION = 1
COMMUNITY_TAB_ID_EXPERT = 6
COMMUNITY_TAB_ID_VIDEO = 2
COMMUNITY_TAB_ID_LEADERBOARD = 3
COMMUNITY_TAB_ID_TIMELINE = 4
COMMUNITY_TAB_ID_PREMIUM = 5

CommunityType = {
	{ ["id"] = "Button_Competition", ["displayNameKey"] = "title_competition"},
	
	-- { ["id"] = "Button_Expert", ["displayNameKey"] = "title_expert"},

	{ ["id"] = "Button_Videos", ["displayNameKey"] = "title_video"},

	{ ["id"] = "Button_Leaderboard", ["displayNameKey"] = "title_leaderboard" },

  { ["id"] = "Button_Timeline", ["displayNameKey"] = "title_timeline" },

  { ["id"] = "Button_Premium", ["displayNameKey"] = "title_premium" },
}

