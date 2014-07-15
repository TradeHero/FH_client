module(..., package.seeall)

function action( param )
	local ChatScene = require("scripts.views.CompetitionChatScene")
	if ChatScene.isFrameShown() then
		return
	end
    ChatScene.loadFrame()
end