module(..., package.seeall)

local Constants = require("scripts.Constants")
local RequestUtils = require("scripts.RequestUtils")

LeaderboardType = {
	{ ["displayName"] = "Top Performers", ["logo"] = Constants.LEADERBOARD_IMAGE_PATH.."top-performers.png", ["request"] = RequestUtils.GET_MAIN_LEADERBOARD_REST_CALL },
	
	{ ["displayName"] = "Friends", ["logo"] = Constants.LEADERBOARD_IMAGE_PATH.."friends.png", ["request"] = RequestUtils.GET_FRIENDS_LEADERBOARD_REST_CALL },
	
--[[
	{ ["displayName"] = "Followers", ["logo"] = Constants.LEADERBOARD_IMAGE_PATH.."followers.png" },

	{ ["displayName"] = "Monthly", ["logo"] = Constants.LEADERBOARD_IMAGE_PATH.."monthly.png" },
	
	{ ["displayName"] = "Competitions", ["logo"] = Constants.LEADERBOARD_IMAGE_PATH.."competition.png" },
	
	{ ["displayName"] = "Prediction Types", ["logo"] = Constants.LEADERBOARD_IMAGE_PATH.."prediction-types.png" },
--]]
}

LeaderboardSubType = {
	{ ["sortType"] = 1, ["dataColumnId"] = "Roi", ["title"] = "Roi", ["description"] = "%d%% won", },
	{ ["sortType"] = 2, ["dataColumnId"] = "WinPercentage", ["title"] = "Win %", ["description"] = "%d%% won", },
	{ ["sortType"] = 3, ["dataColumnId"] = "Profit", ["title"] = "Profit", ["description"] = "%d won", },
}