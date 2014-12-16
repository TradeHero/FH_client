module(..., package.seeall)

local Constants = require("scripts.Constants")
local RequestUtils = require("scripts.RequestUtils")

LEADERBOARD_TOP = 1
LEADERBOARD_FRIENDS = 2

LEADERBOARD_TYPE_ROI = 1
LEADERBOARD_TYPE_WP = 2
LEADERBOARD_TYPE_PROFIT = 3

LeaderboardType = {
	{ ["displayName"] = Constants.String.top_performers, ["logo"] = Constants.LEADERBOARD_IMAGE_PATH.."top-performers.png", ["request"] = RequestUtils.GET_MAIN_LEADERBOARD_REST_CALL },
	
	{ ["displayName"] = Constants.String.friends, ["logo"] = Constants.LEADERBOARD_IMAGE_PATH.."friends.png", ["request"] = RequestUtils.GET_FRIENDS_LEADERBOARD_REST_CALL },
	
--[[
	{ ["displayName"] = "Followers", ["logo"] = Constants.LEADERBOARD_IMAGE_PATH.."followers.png" },

	{ ["displayName"] = "Monthly", ["logo"] = Constants.LEADERBOARD_IMAGE_PATH.."monthly.png" },
	
	{ ["displayName"] = "Competitions", ["logo"] = Constants.LEADERBOARD_IMAGE_PATH.."competition.png" },
	
	{ ["displayName"] = "Prediction Types", ["logo"] = Constants.LEADERBOARD_IMAGE_PATH.."prediction-types.png" },
--]]
}

LeaderboardSubType = {
	{ ["sortType"] = 1, ["dataColumnId"] = "Roi", ["title"] = Constants.String.leaderboard.gain_per_prediction_title, ["description"] = Constants.String.leaderboard.gain_per_prediction_desc, },
	{ ["sortType"] = 2, ["dataColumnId"] = "WinPercentage", ["title"] = Constants.String.leaderboard.win_ratio_title, ["description"] = Constants.String.leaderboard.win_ratio_desc, },
	{ ["sortType"] = 3, ["dataColumnId"] = "Profit", ["title"] = Constants.String.leaderboard.high_score_title, ["description"] = Constants.String.leaderboard.high_score_desc, },
}