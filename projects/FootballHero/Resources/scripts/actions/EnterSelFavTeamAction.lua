module(..., package.seeall)

local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local Logic = require("scripts.Logic").getInstance()

function action( param )
	EventManager:postEvent( Event.Enter_Match_List )

	--[[
	if Logic:getStartLeagueId() == 0 then
		local selFavTeamScene = require("scripts.views.SelFavTeamScene")
    	selFavTeamScene.loadFrame()
	else
	    EventManager:postEvent( Event.Enter_Match_List )
	end
	--]]
end