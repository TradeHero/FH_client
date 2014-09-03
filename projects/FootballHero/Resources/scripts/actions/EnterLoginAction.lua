module(..., package.seeall)

function action( param )
	local loginScene = require("scripts.views.LoginScene")
    loginScene.loadFrame()
end