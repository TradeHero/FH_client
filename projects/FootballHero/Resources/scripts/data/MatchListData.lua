module(..., package.seeall)

MatchListData = {}

--[[

[
    {
        "date": "2014/4/25",
        "dateDisplay": "April 25, Thursday",
        "matches": [
            {
                "Id": 4077,
                "HomeTeamId": 2744,
                "AwayTeamId": 2942,
                "StartTime": 1398311338
            },
            {
                "Id": 4555,
                "HomeTeamId": 1573,
                "AwayTeamId": 6914,
                "StartTime": 1398311338
            },
            {
                "Id": 4083,
                "HomeTeamId": 10310,
                "AwayTeamId": 58760,
                "StartTime": 1398311338
            }
        ]
    },

    {
        "date": "2014/4/27",
        "dateDisplay": "April 27, Saturday",
        "matches": [
            {
                "Id": 4077,
                "HomeTeamId": 2744,
                "AwayTeamId": 2942,
                "StartTime": 1398311338
            },
            {
                "Id": 4555,
                "HomeTeamId": 1573,
                "AwayTeamId": 6914,
                "StartTime": 1398311338
            },
            {
                "Id": 4083,
                "HomeTeamId": 10310,
                "AwayTeamId": 58760,
                "StartTime": 1398311338
            }
        ]
    }
]

--]]

function MatchListData:new()
	local obj = {
		matchDateList = {}
	}

	setmetatable(obj, self)
    self.__index = self
    
    obj.__newindex = function(t, k, v) assert(false, "MatchListData--"..k .. "__newindex not exist") end
    
    return obj 
end

function MatchListData:getMatchListOnDate( date, dateDisplay )
	for k,v in pairs( self.matchDateList ) do
		if v["date"] == date then
			return v
		end
	end

	local matchDate = {}
	matchDate["date"] = date
	matchDate["dateDisplay"] = dateDisplay
	matchDate["matches"] = {}
	table.insert( self.matchDateList, matchDate )
	return matchDate
end

function MatchListData:addMatch( match )
	local startTimeNum = match["StartTime"]
    local startTimeDate = os.date( "%x", startTimeNum )
    local startTimeDisplay = os.date( "%B %d, %A", startTimeNum )

    local matchDate = self:getMatchListOnDate( startTimeDate, startTimeDisplay )
    table.insert( matchDate["matches"], match )
end

function MatchListData:getMatchDateList()
	return self.matchDateList
end