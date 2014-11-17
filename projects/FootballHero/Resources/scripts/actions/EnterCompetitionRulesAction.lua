module(..., package.seeall)

function action( param )
	local competitionName = param[1]
	local competitionToken = param[2]

	local CompetitionPrize = require("scripts.views.CompetitionRules")
    CompetitionPrize.loadFrame( competitionName, competitionToken )
end