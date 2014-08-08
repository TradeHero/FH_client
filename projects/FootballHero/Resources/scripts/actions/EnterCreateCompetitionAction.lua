module(..., package.seeall)

function action( param )
	local preSetContent = nil
	local leagueId = nil
	if param ~= nil then
		preSetContent = param[1]
		leagueId = param[2]
	end

	local CreateCompetitionScene = require("scripts.views.CreateCompetitionScene")

    if preSetContent then
    	CreateCompetitionScene.loadFrame( leagueId )
    	CreateCompetitionScene.preSetContent()
    else
    	CreateCompetitionScene.loadFrame()
    end
end