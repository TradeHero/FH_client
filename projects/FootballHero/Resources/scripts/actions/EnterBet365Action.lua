module(..., package.seeall)

function action( param )
	local registerScene = require("scripts.views.Bet365Scene")
    registerScene.loadFrame()
end