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
                "HomeGoals": 2,
                "AwayGoals": 3,
                "PredictionsPlayed": 0,
                "PredictionsAvailable": 0,
                "Profit": null,
                "TotalUsersPlayed": 888,
                "LeagueName": "Premier League"
            },
            {
                "Id": 4555,
                "HomeTeamId": 1573,
                "AwayTeamId": 6914,
                "StartTime": 1398311338
                "HomeGoals": 2,
                "AwayGoals": 3,
                "PredictionsPlayed": 0,
                "PredictionsAvailable": 0,
                "Profit": null,
                "TotalUsersPlayed": 888,
                "LeagueName": "Premier League"
            },
            {
                "Id": 4083,
                "HomeTeamId": 10310,
                "AwayTeamId": 58760,
                "StartTime": 1398311338
                "HomeGoals": 2,
                "AwayGoals": 3,
                "PredictionsPlayed": 0,
                "PredictionsAvailable": 0,
                "Profit": null,
                "TotalUsersPlayed": 888,
                "LeagueName": "Premier League"
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
                "HomeGoals": 2,
                "AwayGoals": 3,
                "PredictionsPlayed": 0,
                "PredictionsAvailable": 0,
                "Profit": null,
                "TotalUsersPlayed": 888,
                "LeagueName": "Premier League"
            },
            {
                "Id": 4555,
                "HomeTeamId": 1573,
                "AwayTeamId": 6914,
                "StartTime": 1398311338
                "HomeGoals": 2,
                "AwayGoals": 3,
                "PredictionsPlayed": 0,
                "PredictionsAvailable": 0,
                "Profit": null,
                "TotalUsersPlayed": 888,
                "LeagueName": "Premier League"
            },
            {
                "Id": 4083,
                "HomeTeamId": 10310,
                "AwayTeamId": 58760,
                "StartTime": 1398311338
                "HomeGoals": 2,
                "AwayGoals": 3,
                "PredictionsPlayed": 0,
                "PredictionsAvailable": 0,
                "Profit": null,
                "TotalUsersPlayed": 888,
                "LeagueName": "Premier League"
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

function MatchListData:getOrCreateMatchListOnDate( date, dateDisplay, timeDisplay )
	for k,v in pairs( self.matchDateList ) do
		if v["date"] == date then
			return v
		end
	end

	local matchDate = {}
	matchDate["date"] = date
	matchDate["dateDisplay"] = dateDisplay
    matchDate["timeDisplay"] = timeDisplay
	matchDate["matches"] = {}
	table.insert( self.matchDateList, matchDate )
	return matchDate
end

function MatchListData:addMatch( match )
	local startTimeNum = match["StartTime"]
    --local startTimeDate = os.date("%y", startTimeNum) * 10000 + os.date("%m", startTimeNum) * 100 + os.date("%d", startTimeNum)
    local Constants = require("scripts.Constants")
    local dateDisplay = os.date( Constants.String.match_list.date, startTimeNum )
    local timeDisplay = os.date( "%H:%M", startTimeNum )
    local matchDate = self:getOrCreateMatchListOnDate( startTimeNum, dateDisplay, timeDisplay )
    table.insert( matchDate["matches"], match )
end

function MatchListData:getMatchDateList()
	return self.matchDateList
end