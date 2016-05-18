module(..., package.seeall)

local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local ConnectingMessage = require("scripts.views.ConnectingMessage")
local Constants = require("scripts.Constants")
local Json = require("json")

function action( param )
 	ConnectingMessage.loadFrame()
    FacebookDelegate:sharedDelegate():shareTimeline( Constants.String.share.share_app_title, 
    	Constants.String.share.share_app_content, 
    	"http://www.sportshero.mobi", 
    	inviteFriendHandler )
end

function inviteFriendHandler( success )
	if success then
        local params = { Action = "facebook timeline" }
        Analytics:sharedDelegate():postEvent( Constants.ANALYTICS_EVENT_FRIENDS_REFERRAL, Json.encode( params ) )
        Analytics:sharedDelegate():postFlurryEvent( Constants.ANALYTICS_EVENT_FRIENDS_REFERRAL, Json.encode( params ) )
		EventManager:postEvent( Event.Do_Friend_Referal_Success, { Constants.REFERRAL_TYPE_FACEBOOK_TIMELINE } )
	else
		CCLuaLog("facebook share timeline failed")
	end

	ConnectingMessage.selfRemove()
end