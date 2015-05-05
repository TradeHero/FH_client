module(..., package.seeall)

function action( param )
	local errorMessage = require("scripts.views.ErrorMessage")
	local Constants = require("scripts.Constants")
	if not errorMessage.isShown() then
		errorMessage.loadFrame()
	end

    errorMessage.setTitle( param[3] or Constants.String.info.title )
    errorMessage.setErrorMessage( param[1], param[2] )
end