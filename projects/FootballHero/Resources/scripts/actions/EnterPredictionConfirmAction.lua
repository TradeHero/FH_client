module(..., package.seeall)

function action( param )
	local prediction, teamName, reward, answerIcon = param[1], param[2], param[3], param[4]

	local predConfirmScene = require("scripts.views.PredConfirmScene")
    predConfirmScene.loadFrame( prediction, teamName, reward, answerIcon )
end