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
		mEventHandler = {},
		mEventHistory = {}
	}
    
    setmetatable(obj, self)
    self.__index = self
    
    obj.__newindex = function(t, k, v) assert(false, "EventManager--"..k .. "__newindex not exist") end
    
    instance = obj
    return obj 
end

function EventManager:registerEventHandler( eventId, actionName )
	local handler = require( actionName )
	self.mEventHandler[eventId] = handler
end

function EventManager:postEvent( eventId, param )
	if self.mEventHandler[eventId] == nil then
		print( "Event id = "..Event.GetEventNameById( eventId ).." has no action." )
	else
		print( "Event id = "..Event.GetEventNameById( eventId ).." handled." )
		CCTextureCache:sharedTextureCache():removeUnusedTextures()
		self:addHistory( eventId, param )
		self.mEventHandler[eventId].action( param )
	end
end

function EventManager:scheduledExecutor( func, time )
	local taskArray = CCArray:create()
	taskArray:addObject( CCDelayTime:create( time ) )
	taskArray:addObject( CCCallFuncN:create( func ) )

	CCDirector:sharedDirector():getRunningScene():runAction( CCSequence:create( taskArray ) )
end

function EventManager:addHistory( eventId, param )
	local eventName = Event.GetEventNameById( eventId )
	if Event.EventDosenotTrackList[eventName] == nil then
		print("Track: "..eventName)
		local history = {
			["eventId"] = eventId,
			["param"] = param
		}

		table.insert( self.mEventHistory, history )
	else
		print("Does not track: "..eventName)
	end
end

function EventManager:popHistory()
	table.remove( self.mEventHistory ) -- Throw away the current one.
	local lastHistory = table.remove( self.mEventHistory ) 
	if lastHistory ~= nil then
		self:postEvent( lastHistory["eventId"], lastHistory["param"] )
	else
		print( "Dose not have history event." )
	end
end

function EventManager:popHistoryWithoutExec()
	table.remove( self.mEventHistory )
end
