module(..., package.seeall)

local Constants = require("scripts.Constants")
local RequestUtils = require("scripts.RequestUtils")

COMMUNITY_TAB_ID_COMPETITION = 1
COMMUNITY_TAB_ID_LEADERBOARD = 2

CommunityType = {
	{ ["id"] = "Button_Competition", ["displayName"] = Constants.String.community.title_competition},
	
	{ ["id"] = "Button_Leaderboard", ["displayName"] = Constants.String.community.title_leaderboard}
}

