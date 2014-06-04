module(..., package.seeall)

local Json = require("json")

function writeStringToFile( fileName, str )
	local fileUtils = CCFileUtils:sharedFileUtils()
	local writePath = fileUtils:getWritablePath()..fileName

	createFolderRecur( fileUtils:getWritablePath(), fileName )

	local fileHandle, errorCode = io.open( writePath, "w+" )
	--print( "Write to: "..writePath )
	if fileHandle == nil then
		assert( false, "Write failed to file"..fileName.." with error: "..errorCode )
		return
	end

	fileHandle:write( str )
	fileHandle:close()
end

function createFolderRecur( existFolder, toCreateFolder )
	print("createFolderRecur: "..existFolder.."|"..toCreateFolder)
	local pos = string.find( toCreateFolder, "/" )
	if pos ~= nil then
		local folderToCreate = existFolder..string.sub( toCreateFolder, 1, pos )
		if lfs.mkdir( folderToCreate ) then
			createFolderRecur( folderToCreate, string.sub( toCreateFolder, pos + 1 ) )
		end
	end
end

-- 1. check the writable path
-- 2. check the file in the package
function readStringFromFile( fileName )
	local text = ""
	local fileUtils = CCFileUtils:sharedFileUtils()
	local fileName = fileUtils:fullPathForFilename( fileName )
	print("Read file from: "..fileName)
	text = fileUtils:getFileData( fileName, "r", 0 )

	return text
end
