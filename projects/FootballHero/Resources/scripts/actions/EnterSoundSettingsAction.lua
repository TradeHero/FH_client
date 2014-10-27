module(..., package.seeall)

function action( param )
	local SoundSettingsScene = require("scripts.views.SoundSettingsScene")
    SoundSettingsScene.loadFrame()
end