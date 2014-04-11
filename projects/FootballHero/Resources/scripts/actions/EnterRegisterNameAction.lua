module(..., package.seeall)

function action( param )
	local registerNameScene = require("scripts.views.RegisterNameScene")
    registerNameScene.loadFrame()
end