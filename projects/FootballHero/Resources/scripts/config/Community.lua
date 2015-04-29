module(..., package.seeall)

local Constants = require("scripts.Constants")
local RequestUtils = require("scripts.RequestUtils")

COMMUNITY_TAB_ID_COMPETITION = 1
COMMUNITY_TAB_ID_HIGHLIGHT = 2
COMMUNITY_TAB_ID_LEADERBOARD = 3

CommunityType = {
	{ ["id"] = "Button_Competition", ["displayNameKey"] = "title_competition"},
	
	{ ["id"] = "Button_Highlight", ["displayNameKey"] = "title_highlight"},

	{ ["id"] = "Button_Leaderboard", ["displayNameKey"] = "title_leaderboard" }
}

