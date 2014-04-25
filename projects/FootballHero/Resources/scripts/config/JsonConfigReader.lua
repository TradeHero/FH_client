module(..., package.seeall)

local Json = require("json")

function read( fileName, primaryKey, filter )
	filter = filter or passAll
	if primaryKey == nil then
		return readWithoutPrimaryKey( fileName, filter )
	else
		return readWithPrimaryKey( fileName, primaryKey, filter )
	end
end

function readWithPrimaryKey( fileName, primaryKey, filter )
	local config = {}
	local index = {}
	local configNum = 0

	local fileName = CCFileUtils:sharedFileUtils():fullPathForFilename( fileName )
	local text = CCFileUtils:sharedFileUtils():getFileData( fileName, "r", 0 )
	--print( text )
	local jsonObject = Json.decode( text )
	for i,v in pairs(jsonObject) do
		if filter( v ) then
		    table.insert( config, v )
	    	configNum = configNum + 1

	    	local id = v[primaryKey]
		    index[id] = configNum
		end
	end

	return config, configNum, index
end

function readWithoutPrimaryKey( fileName, filter )
	local config = {}
	local configNum = 0

	local fileName = CCFileUtils:sharedFileUtils():fullPathForFilename( fileName )
	local text = CCFileUtils:sharedFileUtils():getFileData( fileName, "r", 0 )
	--print( text )
	local jsonObject = Json.decode( text )
	for i,v in pairs(jsonObject) do
		if filter( v ) then
			table.insert( config, v )
	    	configNum = configNum + 1
		end
	end

	return config, configNum
end

function passAll( v )
	return true
end