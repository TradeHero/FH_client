module(..., package.seeall)

function action( param )
	local historyDetailScene = require("scripts.views.HistoryDetailScene")
    historyDetailScene.loadFrame( param[1], param[2] )
end