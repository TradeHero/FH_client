module(..., package.seeall)

function action( param )
	local errorMessage = require("scripts.views.ErrorMessage")
	local Constants = require("scripts.Constants")
    errorMessage.loadFrame()
    errorMessage.setTitle( Constants.String.error.title_default )
    errorMessage.setErrorMessage( param[1], param[2] )
end