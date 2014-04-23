module(..., package.seeall)

local JsonConfigReader = require("scripts.config.JsonConfigReader")


local FILE_NAME = "config/leagues.txt"
local mConfig = {}
local mConfigNum = 0

function init()
	if mConfigNum > 0 then 
		return
	end
	print("Read League config.")
	mConfig, mConfigNum = JsonConfigReader.read( FILE_NAME, "leagueId" )
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

function getCountryId( id )
	local config = getConfig( id )
	return config["countryId"]
end

function getLogo( id )
	local config = getConfig( id )
	return config["leagueId"]..".png"
end

function getLeagueName( id )
	local config = getConfig( id )
	return config["leagueName"]
end

function getThumbUrl( id )
	local config = getConfig( id )
	return config["thumbUrl"]
end

init()