module(..., package.seeall)

local Constants = require("scripts.Constants")
local JsonConfigReader = require("scripts.config.JsonConfigReader")


local FILE_NAME = "config/teams.txt"
local mConfig = {}
local mIndex = {}
local mConfigNum = 0

function init()
	if mConfigNum > 0 then 
		return
	end
	print("Read Team config.")
	mConfig, mConfigNum, mIndex = JsonConfigReader.read( FILE_NAME, "Id" )
end

function getConfig( id )
	assert( mConfig[id] ~= nil, FILE_NAME.." dosen't has "..id )

	return mConfig[id]
end

function getConfigIdByKey( key )
	assert( mIndex[key] ~= nil, FILE_NAME.." dosen't has "..key )

	return mIndex[key]
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

	local fileUtils = CCFileUtils:sharedFileUtils()
	local filePath = fileUtils:fullPathForFilename( Constants.TEAM_IMAGE_PATH..config["Id"]..".png" )
	if fileUtils:isFileExist( filePath ) then
		return config["Id"]..".png"
	else
		return "default.png"
	end
end

function getThumbUrl( id )
	local config = getConfig( id )
	return config["thumbUrl"]
end

init()