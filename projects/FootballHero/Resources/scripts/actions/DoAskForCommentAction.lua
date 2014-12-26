module(..., package.seeall)

function action( param )
	local AskForCommentScene = require("scripts.views.AskForCommentScene")
	AskForCommentScene.loadFrame()
end