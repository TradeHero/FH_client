module(..., package.seeall)

function action( param )
	local prizeScene = require("scripts.views.PrizeScene")
    prizeScene.loadFrame(param[1])
end