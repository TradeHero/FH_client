module(..., package.seeall)

local Constants = require("scripts.Constants")
local JsonConfigReader = require("scripts.config.JsonConfigReader")


local FILE_NAME = "config/leagueteams.txt"
local mConfig = {}

function init()
	print("Read LeagueTeam config.")
	mConfig = JsonConfigReader.readAndCombine( FILE_NAME, "leagueId" )
end

function getConfig( id )
	if id == nil then
		return nil
	end
	if mConfig[id] == nil then
		print( FILE_NAME.." dosen't has "..id )
		return nil
	end

	return mConfig[id]
end

--[[
	Provide additional getters.
--]]


init()