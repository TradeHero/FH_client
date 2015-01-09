module(..., package.seeall)

local Constants = require("scripts.Constants")
local RequestUtils = require("scripts.RequestUtils")

MATCH_CENTER_TAB_ID_MEETINGS = 1
MATCH_CENTER_TAB_ID_DISCUSSION = 2

DISCUSSION_POST_TYPE_GAME = 1
DISCUSSION_POST_TYPE_LEAGUE = 2
DISCUSSION_POST_TYPE_USER = 3

MatchCenterType = {
	{ ["id"] = "Button_Meetings", ["displayName"] = Constants.String.match_center.title_meetings },
	
	{ ["id"] = "Button_Discussion", ["displayName"] = Constants.String.match_center.title_discussion }
}

