module(..., package.seeall)

function action( param )
	local FAQScene = require("scripts.views.FAQScene")
	if FAQScene.isFrameShown() then
		return
	end
    FAQScene.loadFrame()
end