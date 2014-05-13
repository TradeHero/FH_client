module(..., package.seeall)

function action( param )
	local leaderboardMainScene = require("scripts.views.LeaderboardMainScene")
	if leaderboardMainScene.isFrameShown() then
		return
	end
    leaderboardMainScene.loadFrame()
end