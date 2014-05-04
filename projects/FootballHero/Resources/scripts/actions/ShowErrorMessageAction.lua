module(..., package.seeall)

function action( param )
	local errorMessage = require("scripts.views.ErrorMessage")
    errorMessage.loadFrame()
    errorMessage.setErrorMessage( param[1], param[2] )
end