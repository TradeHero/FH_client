module(..., package.seeall)

local Json = require("json")
local Constants = require("scripts.Constants")
local QuickBloxService = require("scripts.QuickBloxService")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList

local mSentOnce = false

function action( param )
	
	local chatRoomJID = param[1]
	local channelId = param[2]

	QuickBloxService.joinChatRoom( chatRoomJID, function( success )
		if success then
			local delayedTask = function()
	            -- Load empty chat scene
				-- Chat message GET logic is within DoGetChatMessageAction.lua
			    local ChatScene = require("scripts.views.LeagueChatScene")
			    ChatScene.loadFrame( channelId )
	        end

	        EventManager:scheduledExecutor( delayedTask, 0.2 )
		
	    else
	    	EventManager:postEvent( Event.Show_Error_Message, { Constants.String.serverError.DEFAULT } )
		end
	end )
end