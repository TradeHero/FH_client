module(..., package.seeall)

ChatMessages = {}

--[[
Data structure:

[

   {

      "Id": 2,

      "Username": "tttt",

      "MessageText": "tttt",

      "Time": "1403249853",

   }

]

--]]

function ChatMessages:new( list )
	local obj = {
		List = list,
	}

	setmetatable(obj, self)
    self.__index = self
    
    obj.__newindex = function(t, k, v) assert(false, "ChatMessages--"..k .. "__newindex not exist") end
    
    return obj 
end

function ChatMessages:getSize()
    return table.getn( self.List )
end

function ChatMessages:get( index )
    return self.List[index]
end