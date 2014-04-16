module(..., package.seeall)

local JsonConfigReader = require("scripts.config.JsonConfigReader")

local FILE_NAME = "config/leagues/leagues.json"
local mConfig = {}
local mConfigNum = 0

function init()
	mConfig, mConfigNum = JsonConfigReader.read( FILE_NAME, "id" )

	-- put in the team list
	for i = 1, mConfigNum do
		local leagueConfig = getConfig( i )
		local leagueId = leagueConfig["id"]
		local leagueTeamConfig, leagueTeamConfigNum = JsonConfigReader.read( "config/leagues/league"..leagueId..".json", "id" )
		local teamList = {}
		for j = 1, leagueTeamConfigNum do
			table.insert( teamList, leagueTeamConfig[j]["teamList"] )
		end
		leagueConfig["teamList"] = teamList
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

function getLogo( id )
	local config = getConfig( id )
	return config["logo"]
end

function getDisplayName( id )
	local config = getConfig( id )
	return config["displayName"]
end

function getTeamList( id )
	local config = getConfig( id )
	return config["teamList"]
end

init()