module(..., package.seeall)

local Event = require("scripts.events.Event")

local instance

function getInstance()
	if instance == nil then
		instance = EventManager:new()
	end

	return instance
end

EventManager = {}

function EventManager:new()
	if instance ~= nil then
		assert( false )
		return instance
	end
	
	local obj = {
		mEventHandler = {}
	}
    
    setmetatable(obj, self)
    self.__index = self
    
    obj.__newindex = function(t, k, v) assert(false, "EventManager--"..k .. "__newindex not exist") end
    
    instance = obj
    return obj 
end

function EventManager:registerEventHandler( eventId, action )
	self.mEventHandler[eventId] = action
end

function EventManager:postEvent( eventId, param )
	if self.mEventHandler[eventId] == nil then
		print( "Event id = "..eventId.." has no action." )
	else
		print( "Event id = "..Event.GetEventNameById( eventId ).." handled." )
		self.mEventHandler[eventId].action( param )
	end
end