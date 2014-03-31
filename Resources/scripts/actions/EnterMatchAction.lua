module(..., package.seeall)

function action( param )
	local matchPredictionScene = require("scripts.views.MatchPredictionScene")
    matchPredictionScene.loadFrame()
end