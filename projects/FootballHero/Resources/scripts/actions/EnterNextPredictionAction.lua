module(..., package.seeall)

local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local Logic = require("scripts.Logic").getInstance()


function action( param )
	local marketInfo = Logic:getCurMarketInfo()
	local curDisplayMarketIndex = Logic:getCurDisplayMarketIndex()

	curDisplayMarketIndex = curDisplayMarketIndex + 1
	Logic:setCurDisplayMarketIndex( curDisplayMarketIndex )

	if curDisplayMarketIndex > marketInfo:getNum() then
		print( "All market prediciton are done." )
		EventManager:postEvent( Event.Enter_Match_List )
	else
		print( "Display the next prediction: "..curDisplayMarketIndex )
		local ScorePrediction = require("scripts.views.ScorePrediction")
		local matchMarketData = marketInfo:getMarketAt( curDisplayMarketIndex )

		ScorePrediction.loadFrame( matchMarketData )
	end
end