module(..., package.seeall)

local Constants = require("scripts.Constants")

COMPETITION_TAB_ID_OVERALL = 1
COMPETITION_TAB_ID_MONTHLY = 2
COMPETITION_TAB_ID_WEEKLY = 3

CompetitionTabs = {
  { ["id"] = "Button_Overall", ["displayNameKey"] = "ranking_overall" },
  { ["id"] = "Button_Monthly", ["displayNameKey"] = "ranking_monthly" },
  { ["id"] = "Button_Weekly", ["displayNameKey"] = "ranking_weekly" },
}

CompetitionType = {
  ["Private"] = 1,
  ["DetailedRanking"] = 2,  -- FH Championship, with weekly, monthly rankings
  ["SimpleRanking"] = 3,  -- Special competitions with only a single ranking
  ["Preview"] = 4,    -- can view information but cannot join
}

CompetitionStatus = {
  ["Available"] = 2,  -- can start joining competition
  ["Joined"] = 3,     -- already joined competition
  ["Ended"] = 4,      -- competition ended, can view rankings
}

Competitions = {}

--[[
Data structure:

[
   {
        "Id": 12737,
        "Name": "Team Football Hero",
        "Description": "My Hero company challenge ",
        "StartTimeStamp": 1414650801,
        "EndTimeStamp": 0,
        "JoinToken": "779dpc",
        "Open": true,
        "OwningUserName": "Adrian Lam",
        "OwnedByMe": false,
        "CompetitionStatus": 0,
        "CompetitionType": 1
    }
]

--]]

function Competitions:new( list )
	local obj = {
		List = list,
	}

	setmetatable(obj, self)
    self.__index = self
    
    obj.__newindex = function(t, k, v) assert(false, "Competitions--"..k .. "__newindex not exist") end
    
    return obj 
end

function Competitions:getSize()
    return table.getn( self.List )
end

function Competitions:get( index )
    return self.List[index]
end

function Competitions:getSpecialCompetitions()

  local specialCompetitions = {}

  for i = 1, table.getn( self.List ) do
    local competition = self.List[i]
    if competition ~= nil then
      if competition["CompetitionType"] ~= CompetitionType["Private"] then
          print( "Special Competition! ID = "..competition["Id"] )
          table.insert( specialCompetitions, competition )
          
      end
    end
  end

  return specialCompetitions
end