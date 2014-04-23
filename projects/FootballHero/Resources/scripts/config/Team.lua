module(..., package.seeall)

local JsonConfigReader = require("scripts.config.JsonConfigReader")


local FILE_NAME = "config/teams.txt"
local mConfig = {}
local mConfigNum = 0

function init()
	if mConfigNum > 0 then 
		return
	end
	print("Read Team config.")
	mConfig, mConfigNum = JsonConfigReader.read( FILE_NAME, "teamId" )
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

function getTeamName( id )
	local config = getConfig( id )
	return config["teamName"]
end

function getLogo( id )
	local config = getConfig( id )
	return config["teamId"]..".png"
end

function getThumbUrl( id )
	local config = getConfig( id )
	return config["thumbUrl"]
end

init()