module(..., package.seeall)

local Json = require("json")
local Constants = require("scripts.Constants")

local mSentOnce = false

function action( param )
	local LeagueChatListScene = require("scripts.views.LeagueChatListScene")
    LeagueChatListScene.loadFrame()
end