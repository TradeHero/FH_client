module(..., package.seeall)

local Json = require("json")
local Constants = require("scripts.Constants")
local QuickBloxService = require("scripts.QuickBloxService")
local EventManager = require("scripts.events.EventManager").getInstance()

local mSentOnce = false

function action( param )
	
	local chatRoomJID = param[1]
	local channelId = param[2]

	QuickBloxService.joinChatRoom( chatRoomJID, function( success )
	    local delayedTask = function()
            -- Load empty chat scene
			-- Chat message GET logic is within DoGetChatMessageAction.lua
		    local ChatScene = require("scripts.views.LeagueChatScene")
		    ChatScene.loadFrame( channelId )
        end

        EventManager:scheduledExecutor( delayedTask, 0.2 )
	end )
end