module(..., package.seeall)

local JsonConfigReader = require("scripts.config.JsonConfigReader")


local FILE_NAME = "config/matchs.json"
local PREDICTION_FILE_NAME = "config/matchPredictions.json"
local mConfig = {}
local mConfigNum = 0

function init()
	mConfig, mConfigNum = JsonConfigReader.read( FILE_NAME, "id" )
	local predictionConfig, predictionConfigNum = JsonConfigReader.read( PREDICTION_FILE_NAME, "id" )

	for i = 1, predictionConfigNum do
		assert( predictionConfig[i] ~= nil, PREDICTION_FILE_NAME.." dosen't has "..i )
		local pConfig = predictionConfig[i]
		local matchID = pConfig["matchID"]
		table.insert( getPredictionList( matchID ), pConfig )
	end
end

function getConfig( id )
	assert( mConfig[id] ~= nil, FILE_NAME.." dosen't has "..id )

	return mConfig[id]
end

function getConfigNum()
	return mConfigNum
end

--[[
	Provide additional getters.
--]]

function getTeam1( id )
	local config = getConfig( id )
	return config["team1"]
end

function getTeam2( id )
	local config = getConfig( id )
	return config["team2"]
end

function getTeam1WinOdds( id )
	local config = getConfig( id )
	return config["team1WinOdds"]
end

function getTeam2WinOdds( id )
	local config = getConfig( id )
	return config["team2WinOdds"]
end

function getDrawOdds( id )
	local config = getConfig( id )
	return config["drawOdds"]
end

--[[ Prediction structure:
 id	matchID	predictionType	value1	value2	value3
 Code to go through the predictionList
 for i = 1, table.getn( match.getPredictionList( id ) ) do
 end
--]]
function getPredictionList( id )
	local config = getConfig( id )
	if config["predictionList"] == nil then
		config["predictionList"] = {}
	end
	return config["predictionList"]
end

init()
