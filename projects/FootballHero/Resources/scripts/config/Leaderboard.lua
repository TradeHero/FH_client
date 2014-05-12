module(..., package.seeall)

local Constants = require("scripts.Constants")

LeaderboardType = {
	{ ["displayName"] = "Top Performers", ["logo"] = Constants.LEADERBOARD_IMAGE_PATH.."top-performers.png" },
	
	{ ["displayName"] = "Friends", ["logo"] = Constants.LEADERBOARD_IMAGE_PATH.."friends.png" },
	
--[[
	{ ["displayName"] = "Followers", ["logo"] = Constants.LEADERBOARD_IMAGE_PATH.."followers.png" },

	{ ["displayName"] = "Monthly", ["logo"] = Constants.LEADERBOARD_IMAGE_PATH.."monthly.png" },
	
	{ ["displayName"] = "Competitions", ["logo"] = Constants.LEADERBOARD_IMAGE_PATH.."competition.png" },
	
	{ ["displayName"] = "Prediction Types", ["logo"] = Constants.LEADERBOARD_IMAGE_PATH.."prediction-types.png" },
--]]
}