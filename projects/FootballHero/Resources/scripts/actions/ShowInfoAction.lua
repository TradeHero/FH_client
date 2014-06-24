module(..., package.seeall)

function action( param )
	local errorMessage = require("scripts.views.ErrorMessage")
    errorMessage.loadFrame()
    errorMessage.setTitle( param[3] or "Info" )
    errorMessage.setErrorMessage( param[1], param[2] )
end