module(..., package.seeall)


function action( param )

--[[
	local selFavTeamScene = require("scripts.views.SelFavTeamScene")
    selFavTeamScene.loadFrame()
--]]

    local EventManager = require("scripts.events.EventManager").getInstance()
	local Event = require("scripts.events.Event").EventList
    EventManager:postEvent( Event.Enter_Match_List )

end