module(..., package.seeall)

function action( param )
	local forgotPasswordScene = require("scripts.views.ForgotPasswordScene")
    forgotPasswordScene.loadFrame()
end