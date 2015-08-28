module(..., package.seeall)

local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local ConnectingMessage = require("scripts.views.ConnectingMessage")

function action( param )
    FacebookDelegate:sharedDelegate():inviteFriend( "https://fb.me/1053951204628560", inviteFriendHandler )
end

function inviteFriendHandler( success )
	if success then
		CCLuaLog("facebook invite friend success")
	else
		CCLuaLog("facebook invite friend failed")
	end
	EventManager:postEvent( Event.Do_Friend_Referal_Success, { 1, 1 } )

	ConnectingMessage.selfRemove()


end