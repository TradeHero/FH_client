module(..., package.seeall)

local Constants = require("scripts.Constants")

FOOTBALL_ID = 1
BASEBALL_ID = 5

local mAvailableSports = {}

table.insert( mAvailableSports, { ["key"] = "football", ["id"] = FOOTBALL_ID, ["overunderStats"] = { "15", "25", "35" }, } )
table.insert( mAvailableSports, { ["key"] = "baseball", ["id"] = BASEBALL_ID, ["overunderStats"] = { "65", "75", "85", "95" },  } )
--table.insert( mAvailableSports, { ["key"] = "basketball", ["id"] = 3  } )
--table.insert( mAvailableSports, { ["key"] = "afootball", ["id"] = 4  } )



local mCurrentSport = mAvailableSports[1]

function getAllSports()
	return mAvailableSports
end

function getCurrentSportKey()
	return mCurrentSport["key"]
end

function getCurrentSportId()
	return mCurrentSport["id"]
end

function getCurrentSportOverunderStats()
	return mCurrentSport["overunderStats"]
end

function getCurrentSportLogoPath()
	return Constants.IMAGE_PATH.."icn-"..mCurrentSport["key"]..".png"
end

function getCurrentSportBkgPath()
	return Constants.IMAGE_PATH.."bkg-"..mCurrentSport["key"]..".png"
end

function getSportIdByIndex( index )
	return mAvailableSports[index]["id"]
end

function setCurrentSportByKey( sportKey )
	if mCurrentSport["key"] == sportKey then
		return
	end

	for i = 1, table.getn( mAvailableSports ) do
		if mAvailableSports[i]["key"] == sportKey then
			mCurrentSport = mAvailableSports[i]
			break
		end
	end
end

function getSportLogoPathByIndex( index )
	return Constants.IMAGE_PATH.."icn-"..mAvailableSports[index]["key"]..".png"
end

function getSportLogoPathById( id )
	for i = 1, table.getn( mAvailableSports ) do
		if mAvailableSports[i]["id"] == id then
			return Constants.IMAGE_PATH.."icn-"..mAvailableSports[i]["key"]..".png"
		end
	end

	return ""
end

function getSportBkgPathById( id )
	for i = 1, table.getn( mAvailableSports ) do
		if mAvailableSports[i]["id"] == id then
			return Constants.IMAGE_PATH.."bkg-"..mAvailableSports[i]["key"]..".png"
		end
	end

	return ""
end

function appendSportIdToURLHelper( url )
	local containsParameters = string.find( url, "?" )
	if containsParameters ~= nil then
		url = url.."&sportId="..getCurrentSportId()
	else
		url = url.."?sportId="..getCurrentSportId()
	end

	return url
end