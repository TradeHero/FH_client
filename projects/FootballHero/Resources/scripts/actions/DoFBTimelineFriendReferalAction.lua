module(..., package.seeall)

local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local ConnectingMessage = require("scripts.views.ConnectingMessage")
local Constants = require("scripts.Constants")

function action( param )
 --	ConnectingMessage.loadFrame()
    FacebookDelegate:sharedDelegate():shareTimeline( Constants.String.share.share_app_title, 
    	Constants.String.share.share_app_content, 
    	"http://www.footballheroapp.com", 
    	inviteFriendHandler )
end

function inviteFriendHandler( success )
	if success then
		EventManager:postEvent( Event.Do_Friend_Referal_Success, { 2 } )
	else
		CCLuaLog("facebook invite friend failed")
	end

	ConnectingMessage.selfRemove()
end