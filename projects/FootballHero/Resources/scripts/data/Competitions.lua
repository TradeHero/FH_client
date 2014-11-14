module(..., package.seeall)

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