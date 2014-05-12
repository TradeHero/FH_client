module(..., package.seeall)

function action( param )
	local leaderboardMainScene = require("scripts.views.LeaderboardMainScene")
    leaderboardMainScene.loadFrame()
end