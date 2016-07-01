module(..., package.seeall)

local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local ConnectingMessage = require("scripts.views.ConnectingMessage")
local Constants = require("scripts.Constants")
local Json = require("json")

function action( param )
 	ConnectingMessage.loadFrame()
    FacebookDelegate:sharedDelegate():inviteFriend( Constants.FACEBOOK_REFERRAL_URL, inviteFriendHandler )
end

function inviteFriendHandler( success )
	if success then
    local params = { Action = "facebook invite" }
    Analytics:sharedDelegate():postEvent( Constants.ANALYTICS_EVENT_FRIENDS_REFERRAL, Json.encode( params ) )
    Analytics:sharedDelegate():postFlurryEvent( Constants.ANALYTICS_EVENT_FRIENDS_REFERRAL, Json.encode( params ) )
    Analytics:sharedDelegate():postTongdaoEvent( Constants.ANALYTICS_EVENT_FRIENDS_REFERRAL, Json.encode( params ) )
    EventManager:postEvent( Event.Do_Friend_Referal_Success, { Constants.REFERRAL_TYPE_FACEBOOK_INVITE } )
	else
		CCLuaLog("facebook invite friend failed")
	end

	ConnectingMessage.selfRemove()
end