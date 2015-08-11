module(..., package.seeall)

function action( param )
	local FollowListScene = require("scripts.views.SettingsFollowListScene")
    FollowListScene.loadFrame( param[1] )
end