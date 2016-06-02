module(..., package.seeall)

function action( param )
    local token = param
 	local AskForJoinScene = require("scripts.views.AskForJoin")
	AskForJoinScene.loadFrame(token)
end