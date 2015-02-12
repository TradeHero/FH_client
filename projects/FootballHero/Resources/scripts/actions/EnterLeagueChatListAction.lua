module(..., package.seeall)

local Json = require("json")
local Constants = require("scripts.Constants")

local mSentOnce = false

function action( param )
	local LeagueChatListScene = require("scripts.views.LeagueChatListScene")

	if LeagueChatListScene.isFrameShown() then
		LeagueChatListScene.reloadFrame()
	else
    	LeagueChatListScene.loadFrame()
    end
end