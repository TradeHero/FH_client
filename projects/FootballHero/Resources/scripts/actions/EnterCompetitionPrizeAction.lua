module(..., package.seeall)

function action( param )
	local competitionName = param[1]
	local competitionToken = param[2]
	local competitionType = param[3]
	local competitionIndex = param[4] or 0

	local CompetitionPrize = require("scripts.views.CompetitionPrize")
    CompetitionPrize.loadFrame( competitionName, competitionToken, competitionType, competitionIndex )
end