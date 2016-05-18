module(..., package.seeall)

function action( param )
	local message = param[1]

	local errorMessage = require("scripts.views.ErrorMessage")
	local Constants = require("scripts.Constants")
    errorMessage.loadFrame()
    errorMessage.setErrorMessage( message, function()
    	Misc:sharedDelegate():openUrl("http://www.sportshero.mobi/download")
    end )
    errorMessage.setButtonText( Constants.String.error.go_to_store )
end