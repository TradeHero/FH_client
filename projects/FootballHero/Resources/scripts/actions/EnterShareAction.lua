module(..., package.seeall)

function action( param )
	local title = param[1]
	local body = param[2]
	local shareByFacebook = param[3]

	local ShareScene = require("scripts.views.ShareScene")
    ShareScene.loadFrame( title, body, shareByFacebook )
end