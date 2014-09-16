module(..., package.seeall)

function action( param )
	local message = param[1]

	local errorMessage = require("scripts.views.ErrorMessage")
    errorMessage.loadFrame()
    errorMessage.setErrorMessage( message, function()
    	Misc:sharedDelegate():openUrl("http://www.footballheroapp.com/download")
    end )
    errorMessage.setButtonText("Go to Store")
end