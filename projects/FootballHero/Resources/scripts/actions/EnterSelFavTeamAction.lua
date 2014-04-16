module(..., package.seeall)

function action( param )
	local selFavTeamScene = require("scripts.views.SelFavTeamScene")
    selFavTeamScene.loadFrame()
end