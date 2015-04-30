module( ..., package.seeall )

local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local Constants = require("scripts.Constants")

Lucky8MatchListCell = {
	btn1, 
	btn2, 
	btnDraw,
	team1Cloth,
	team2Cloth,
}

function Lucky8MatchListCell:new( filePath )
	obj = {}
	setmetatable( obj, self )
	self.__index = self

	local 
	return obj
end



