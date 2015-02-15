module(..., package.seeall)

local Json = require("json")
local Constants = require("scripts.Constants")

local mSentOnce = false

function action( param )
	
	local chatRoomJID = param[1]
	local channelId = param[2]

	QuickBloxChat:sharedDelegate():joinChatRoom( chatRoomJID, function( success )
		-- Load empty chat scene
		-- Chat message GET logic is within DoGetChatMessageAction.lua
	    local ChatScene = require("scripts.views.LeagueChatScene")
	    ChatScene.loadFrame( channelId )
	end )
end