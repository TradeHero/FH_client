module(..., package.seeall)

CompetitionDetail = {}

--[[

{
   "Me": {
        "Id": 10724,
        "DisplayName": "boro84",
        "NumberOfCoupons": 27,
        "NumberOfCouponsWon": 12,
        "NumberOfCouponsLost": 15,
        "WinPercentage": 44.44,
        "Roi": -28.12,
        "Profit": -12090,
        "Position": 12,
        "WinStreakCouponsWon": 3,
        "WinStreakCouponsLost": 7,
        "PictureUrl": ""
    },

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
        "CompetitionType": 3,
        "NumberOfEnrolledUsers":20,
        "LinkedLeagueId": -1
    },

   "LatestChatMessage": {
      "MessageText":"111",
      "UserName":"Test003",
      "UnixTimeStamp":1405419592
   },

   "PushNotificationsEnabled":false

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
      NumberOfEnrolledUsers = detail.CompetitionInfoDTO.NumberOfEnrolledUsers,
      open = detail.CompetitionInfoDTO.Open,
      owningUserName = detail.CompetitionInfoDTO.OwningUserName,
      competitionType = detail.CompetitionInfoDTO.CompetitionType,
      linkedLeagueId = detail.CompetitionInfoDTO.LinkedLeagueId,
      latestChatMessage = detail.LatestChatMessage,
      pnSetting = detail.PushNotificationsEnabled,
      selfInfo = detail.Me
      newChatMessages = detail.NewChatMessages
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

function CompetitionDetail:getPlayerNum()
    return self.NumberOfEnrolledUsers
end

function CompetitionDetail:getOpen()
   return self.open
end

function CompetitionDetail:getCompetitionType()
   return self.competitionType
end

function CompetitionDetail:getOwningUserName()
   return self.owningUserName
end

function CompetitionDetail:getLatestChatMessage()
   return self.latestChatMessage
end

function CompetitionDetail:getPNSetting()
   return self.pnSetting
end

function CompetitionDetail:getSelfInfo()
   return self.selfInfo
end

function CompetitionDetail:getLinkedLeagueId()
    return self.linkedLeagueId
end

function CompetitionDetail:getNewChatMessages()
    return self.newChatMessages
end
