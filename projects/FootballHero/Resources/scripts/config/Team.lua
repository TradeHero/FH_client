module(..., package.seeall)

local JsonConfigReader = require("scripts.config.JsonConfigReader")


local FILE_NAME = "config/teams.json"
local mConfig = {}
local mConfigNum = 0

mConfig, mConfigNum = JsonConfigReader.read( FILE_NAME, "id" )

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