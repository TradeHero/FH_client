module(..., package.seeall)

function action( param )
	local choiceMessage = require("scripts.views.ChoiceMessage")
    choiceMessage.loadFrame()
    choiceMessage.setTitle( param[1] )
    choiceMessage.setMessage( param[2] )
    choiceMessage.setCallbacks( param[3], param[4] )
end