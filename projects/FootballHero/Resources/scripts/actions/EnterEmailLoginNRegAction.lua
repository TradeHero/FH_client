module(..., package.seeall)

function action( param )
	local LoginNRegEmailScene = require("scripts.views.LoginNRegEmailScene")
    LoginNRegEmailScene.loadFrame()
end