module(..., package.seeall)

function action( param )
	local prediction, teamName, reward = param[1], param[2], param[3]

	local predConfirmScene = require("scripts.views.PredConfirmScene")
    predConfirmScene.loadFrame( prediction, teamName, reward )
end