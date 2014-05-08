module(..., package.seeall)

function action( param )
	local historyMainScene = require("scripts.views.HistoryMainScene")
    historyMainScene.loadFrame()
end