module(..., package.seeall)

function action( param )
	local CreateCompetitionScene = require("scripts.views.CreateCompetitionScene")
    CreateCompetitionScene.loadFrame()
end