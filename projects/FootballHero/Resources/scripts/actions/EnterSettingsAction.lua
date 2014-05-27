module(..., package.seeall)

function action( param )
	local SettingsScene = require("scripts.views.SettingsScene")
	if SettingsScene.isFrameShown() then
		return
	end
    SettingsScene.loadFrame()
end