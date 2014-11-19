module(..., package.seeall)

COMPETITION_TAB_ID_OVERALL = 1
COMPETITION_TAB_ID_MONTHLY = 2
COMPETITION_TAB_ID_WEEKLY = 3

CompetitionType = {
  ["Private"] = 1,
  ["DetailedRanking"] = 2,  -- FH Championship, with weekly, monthly rankings
  ["SimpleRanking"] = 3,  -- Special competitions with only a single ranking
}

CompetitionStatus = {
  ["Preview"] = 1,    -- can view information but cannot join
  ["Available"] = 2,  -- can start joining competition
  ["Joined"] = 3,     -- already joined competition
  ["Ended"] = 4,      -- competition ended, can view rankings
}

Competitions = {}

--[[
Data structure:

[

   {

      "Id": 2,

      "Name": "tttt",

      "Description": "tttt",

      "StartTime": "1403249853",

      "EndTime": "1418313600",

      "Open": true,

      "OwnedByMe": true,

      "OwningUserName": "Test001"

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