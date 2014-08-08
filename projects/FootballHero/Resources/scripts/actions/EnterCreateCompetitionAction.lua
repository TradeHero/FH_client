module(..., package.seeall)

function action( param )
	local preSetContent = param[1]
	local leagueId = param[2]

	local CreateCompetitionScene = require("scripts.views.CreateCompetitionScene")
    

    if preSetContent then
    	CreateCompetitionScene.loadFrame( leagueId )
    	CreateCompetitionScene.preSetContent()
    else
    	CreateCompetitionScene.loadFrame()
    end
end