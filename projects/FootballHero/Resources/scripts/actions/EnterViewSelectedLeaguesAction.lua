module(..., package.seeall)

function action( param )
	local SelectedLeaguesScene = require("scripts.views.SelectedLeaguesScene")
    SelectedLeaguesScene.loadFrame( {}, true )
end