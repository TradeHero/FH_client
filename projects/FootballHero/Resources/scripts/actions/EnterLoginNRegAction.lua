module(..., package.seeall)

function action( param )
	local loginNRegScene = require("scripts.views.LoginNRegScene")
    loginNRegScene.loadFrame()
end