module(..., package.seeall)

function action( param )
	local errorMessage = require("scripts.views.ErrorMessage")
	local Constants = require("scripts.Constants")

	if errorMessage.isShown() then
		-- Ignore or replace
		errorMessage.setTitle( Constants.String.error.title_default )
    	errorMessage.setErrorMessage( param[1], param[2] )
	else
		errorMessage.loadFrame()
    	errorMessage.setTitle( Constants.String.error.title_default )
    	errorMessage.setErrorMessage( param[1], param[2] )
	end
end