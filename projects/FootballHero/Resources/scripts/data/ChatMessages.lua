module(..., package.seeall)

local Constants = require("scripts.Constants")

ChatMessages = {}

--[[
Data structure:
[
    {
        "date": "2014/4/25",
        "dateDisplay": "25 April",
        "messages": [
           {
              "MessageText": "Test message.",
              "UserName": "Test001",
              "UnixTimeStamp": 1405405019
           },

           {
              "MessageText": "Test message 001.",
              "UserName": "Test001",
              "UnixTimeStamp": 1405406475
           },

           {
              "MessageText": "Test message 002.",
              "UserName": "Test001",
              "UnixTimeStamp": 1405406651
           }
        ]
    },

    {
        "date": "2014/4/27",
        "dateDisplay": "27 April",
        "messages": [
           {
              "MessageText": "Test message.",
              "UserName": "Test001",
              "UnixTimeStamp": 1405405019
           },

           {
              "MessageText": "Test message 001.",
              "UserName": "Test001",
              "UnixTimeStamp": 1405406475
           },

           {
              "MessageText": "Test message 002.",
              "UserName": "Test001",
              "UnixTimeStamp": 1405406651
           }
        ]
    }
]

--]]

function ChatMessages:new( list )
	local obj = {
		List = {},
	}

	setmetatable(obj, self)
    self.__index = self
    
    obj.__newindex = function(t, k, v) assert(false, "ChatMessages--"..k .. "__newindex not exist") end
    
    return obj 
end

function ChatMessages:getOrCreateMessageListOnDate( date, dateDisplay )
    for k,v in pairs( self.List ) do
        if v["date"] == date then
            return v
        end
    end

    local messageDate = {}
    messageDate["date"] = date
    messageDate["dateDisplay"] = dateDisplay
    messageDate["messages"] = {}
    table.insert( self.List, messageDate )
    return messageDate
end

function ChatMessages:addMessage( message )
    local now = os.time()
    local todayYear = os.date("%y", now)
    local todayMonth = os.date("%m", now)
    local todayDay = os.date("%d", now)

    local time = message["UnixTimeStamp"]
    local year = os.date("%y", time)
    local month = os.date("%m", time)
    local day = os.date("%d", time)

    local timeDate = year * 10000 + month * 100 + day
    local timeDisplay
    if todayYear == year and todayMonth == month and todayDay == day then
        timeDisplay = Constants.String.today
    else
        timeDisplay = os.date( "%d %B", time )
    end

    local messageDate = self:getOrCreateMessageListOnDate( timeDate, timeDisplay )
    table.insert( messageDate["messages"], message )
end

function ChatMessages:getSize()
    return table.getn( self.List )
end

function ChatMessages:getMessageDateList( index )
    return self.List
end