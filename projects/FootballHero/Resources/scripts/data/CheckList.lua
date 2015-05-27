module(..., package.seeall)

local MD5 = require("MD5")
local Json = require("json")
local FileUtils = require("scripts.FileUtils")
local RequestUtils = require("scripts.RequestUtils")


CHECK_LIST_HIGHLIGHTS = "highlights"
CHECK_LIST_VIDEOS = "videos"

local mCheckList = {}
local mLocalCheckListContentJson = {}
local CHECK_LIST_LOCAL_FILE = "checkList.txt"

function addCheckItem( item )
	table.insert( mCheckList, item )
end

function getCheckList()
	return mCheckList
end

function isItemNew( name )
	for i = 1, table.getn( mCheckList ) do
		local item = mCheckList[i]
		if item["name"] == name then
			return item["isNew"]
		end
	end

	return false
end

function clearCheckItemNewFlag( name )
	for i = 1, table.getn( mCheckList )  do
		local item = mCheckList[i]
		if item["name"] == name then
			if item["isNew"] then
				item["isNew"] = false
				mLocalCheckListContentJson[item["name"]] = item["localMD5Value"]
				FileUtils.writeStringToFile( CHECK_LIST_LOCAL_FILE, Json.encode( mLocalCheckListContentJson ) )
			end
			
			return
		end
	end
end

function compareMD5( localItemIndex, remoteResponse )
	local remoteMD5 = MD5.sumhexa( remoteResponse )
	local localItem = mCheckList[localItemIndex]
	local localMD5 = mLocalCheckListContentJson[localItem["name"]]

	if remoteMD5 ~= localMD5 then
		localItem["isNew"] = true
		localItem["localMD5Value"] = remoteMD5
		CCLuaLog( "New item: "..localItem["name"] )
	end
end


-- Load the config
local localChecklistContent = FileUtils.readStringFromFile( CHECK_LIST_LOCAL_FILE )
if localChecklistContent and string.len( localChecklistContent ) > 0 then
	mLocalCheckListContentJson = Json.decode( localChecklistContent )
end

addCheckItem( {
	["name"] = CHECK_LIST_HIGHLIGHTS,
	["URL"] = RequestUtils.CDN_SERVER_IP.."highlights.txt",
	["isNew"] = false,
	["localMD5Value"] = 0,
	["checkNewFunction"] = function( response )
		compareMD5( 1, response )
	end
 } )

addCheckItem( {
	["name"] = CHECK_LIST_VIDEOS,
	["URL"] = RequestUtils.CDN_SERVER_IP.."videos.txt",
	["isNew"] = false,
	["checkNewFunction"] = function( response )
		compareMD5( 2, response )
	end
 } )