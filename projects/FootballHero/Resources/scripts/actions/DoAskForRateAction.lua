module(..., package.seeall)

function action( param )
	local AskForRateScene = require("scripts.views.AskForRateScene")
	AskForRateScene.loadFrame()
end