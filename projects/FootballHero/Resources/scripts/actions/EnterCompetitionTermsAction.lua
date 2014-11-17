module(..., package.seeall)

function action( param )
	local competitionName = param[1]
	local competitionToken = param[2]

	local CompetitionPrize = require("scripts.views.CompetitionTerms")
    CompetitionPrize.loadFrame( competitionName, competitionToken )
end