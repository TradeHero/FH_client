module(..., package.seeall)

local mAvailableSports = {}

table.insert( mAvailableSports, { ["key"] = "Football", ["id"] = 1 } )
table.insert( mAvailableSports, { ["key"] = "Basketball", ["id"] = 23  } )
table.insert( mAvailableSports, { ["key"] = "Baseball", ["id"] = 26  } )
table.insert( mAvailableSports, { ["key"] = "AFootball", ["id"] = 24  } )


local mCurrentSport = mAvailableSports[1]


function getCurrentSportId()
	return mCurrentSport["id"]
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