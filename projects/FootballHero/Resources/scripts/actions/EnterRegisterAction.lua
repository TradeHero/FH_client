module(..., package.seeall)

function action( param )
	local registerScene = require("scripts.views.RegisterScene")
    registerScene.loadFrame()
end