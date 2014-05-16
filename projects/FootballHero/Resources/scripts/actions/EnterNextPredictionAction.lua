module(..., package.seeall)

local Constants = require("scripts.Constants")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local Logic = require("scripts.Logic").getInstance()
local SceneManager = require("scripts.SceneManager")


function action( param )
	local marketInfo = Logic:getCurMarketInfo()
	local curDisplayMarketIndex = Logic:getCurDisplayMarketIndex()

	curDisplayMarketIndex = curDisplayMarketIndex + 1
	Logic:setCurDisplayMarketIndex( curDisplayMarketIndex )

	if curDisplayMarketIndex > marketInfo:getNum() then
		EventManager:postEvent( Event.Enter_Pred_Total_Confirm )
	else
		print( "Display the next prediction: "..curDisplayMarketIndex )
		local ScorePrediction = require("scripts.views.ScorePrediction")
		local matchMarketData = marketInfo:getMarketAt( curDisplayMarketIndex )

		SceneManager.clear()
		ScorePrediction.loadFrame( matchMarketData )
	end
end