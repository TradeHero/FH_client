module(..., package.seeall)

local Json = require("json")

function read( fileName, primaryKey )
	if primaryKey == nil then
		return readWithoutPrimaryKey( fileName )
	else
		return readWithPrimaryKey( fileName, primaryKey )
	end
end

function readWithPrimaryKey( fileName, primaryKey )
	local config = {}
	local configNum = 0

	local fileName = CCFileUtils:sharedFileUtils():fullPathForFilename( fileName )
	local text = CCFileUtils:sharedFileUtils():getFileData( fileName, "r", 0 )
	--print( text )
	local jsonObject = Json.decode( text )
	for i,v in pairs(jsonObject) do
	    local id = v[primaryKey]

	    config[id] = v
	    configNum = configNum + 1
	end

	return config, configNum
end

function readWithoutPrimaryKey( fileName )
	local config = {}
	local configNum = 0

	local fileName = CCFileUtils:sharedFileUtils():fullPathForFilename( fileName )
	local text = CCFileUtils:sharedFileUtils():getFileData( fileName, "r", 0 )
	--print( text )
	local jsonObject = Json.decode( text )
	for i,v in pairs(jsonObject) do
		table.insert( config, v )
	    configNum = configNum + 1
	end

	return config, configNum
end