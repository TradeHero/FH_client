module(..., package.seeall)

function action( param )
	
	local eggID = param[1]
	local fbToken = param[2]

	local MinigameWebview = require("scripts.views.MinigameWebview")
    MinigameWebview.loadFrame( eggID, fbToken )
end