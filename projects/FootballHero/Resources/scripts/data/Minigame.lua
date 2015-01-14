module(..., package.seeall)

local Constants = require("scripts.Constants")

MINIGAME_END_DATE = 1


Minigame = {}

--[[
Data structure:

{
 "joined":true,"goals_scored":7,
 "target":100,
 "goals_to_target":93,
 "users_helping":[{
                   "playingUserId":80114,
                   "points":2
                   },
                   {
                   "playingUserId":1068,
                   "points":3
                   }],
 "previous_winners":[]
}

--]]

function Minigame:new( response )

  --for key,value in pairs(response) do print(key,value) end

  local obj
  if response == nil then
    obj = {
      Joined = nil,
      GoalsScored = nil,
      Target = nil,
      GoalsToTarget = nil,
      GoalScorers = nil,
      Winners = nil
    }
  else
    obj = {
      Joined = response["joined"],
      GoalsScored = response["goals_scored"],
      Target = response["target"],
      GoalsToTarget = response["goals_to_target"],
      GoalScorers = response["users_helping"],
      Winners = response["previous_winners"]
    }
  end

  setmetatable(obj, self)
  self.__index = self
  
  obj.__newindex = function(t, k, v) assert(false, "Minigame--"..k .. "__newindex not exist") end
  
  return obj
end

function Minigame:getJoined()
    return self.Joined
end

function Minigame:getGoalsScored()
  return self.GoalsScored
end

function Minigame:getTarget()
  return self.Target
end

function Minigame:getGoalsToTarget()
  return self.GoalsToTarget
end

function Minigame:getGoalScorers()
  return self.getGoalScorers
end
