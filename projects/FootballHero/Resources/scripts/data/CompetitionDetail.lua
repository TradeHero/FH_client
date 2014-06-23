module(..., package.seeall)

CompetitionDetail = {}

--[[

{

   "LeaderboardUserBaseDtos": [

      {

         "Roi": 0,

         "Id": 3,

         "DisplayName": null,

         "NumberOfCoupons": 0,

         "PictureUrl": null

      }

   ],

   "CompetitionInfoDTO": {

      "Id": 3,

      "Name": "2222",

      "Description": "2222",

      "StartTimeStamp": "2014-06-20T08:30:36",

      "EndTimeStamp": "2014-09-11T16:00:00",

      "JoinToken":"5i7o0izr",

      "Open": true,

      "OwningUserName": "Test001"

   }

}

--]]


function CompetitionDetail:new( detail )
   local obj = {
      leaderboardUserBaseDtos = detail.LeaderboardUserBaseDtos,
      name = detail.CompetitionInfoDTO.Name,
      description = detail.CompetitionInfoDTO.Description,
      startTimeStamp = detail.CompetitionInfoDTO.StartTimeStamp,
      endTimeStamp = detail.CompetitionInfoDTO.EndTimeStamp,
      joinToken = detail.CompetitionInfoDTO.JoinToken,
      open = detail.CompetitionInfoDTO.Open,
      owningUserName = detail.CompetitionInfoDTO.OwningUserName,
   }

   setmetatable(obj, self)
    self.__index = self
    
    obj.__newindex = function(t, k, v) assert(false, "CompetitionDetail--"..k .. "__newindex not exist") end
    
    return obj 
end

function CompetitionDetail:getDto()
   return self.leaderboardUserBaseDtos
end

function CompetitionDetail:getName()
   return self.name
end

function CompetitionDetail:getDescription()
   return self.description
end

function CompetitionDetail:getStartTime()
   return self.startTimeStamp
end

function CompetitionDetail:getEndTime()
   return self.endTimeStamp
end

function CompetitionDetail:getJoinToken()
   return self.joinToken
end

function CompetitionDetail:getOpen()
   return self.open
end

function CompetitionDetail:getOwningUserName()
   return self.owningUserName
end