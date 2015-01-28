module(..., package.seeall)

function action( param )
	local leagueKey = param

	local SettingsSelectTeamScene = require("scripts.views.SettingsSelectTeamScene")
	
    SettingsSelectTeamScene.loadFrame( leagueKey )
end