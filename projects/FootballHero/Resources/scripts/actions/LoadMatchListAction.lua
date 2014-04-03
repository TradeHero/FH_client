module(..., package.seeall)

function action( param )
	local matchListScene = require("scripts.views.MatchListScene")
    matchListScene.loadFrame()
end