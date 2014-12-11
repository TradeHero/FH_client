module(..., package.seeall)

local Constants = require("scripts.Constants")


function action( param )
	local SigninTypeSelectScene = require("scripts.views.Tutorial.SigninTypeSelectScene")
	local EmailSelectScene = require("scripts.views.Tutorial.EmailSelectScene")
	local EmailSigninScene = require("scripts.views.Tutorial.EmailSigninScene")
	local EmailRegisterScene = require("scripts.views.Tutorial.EmailRegisterScene")
	local EmailForgotPasswordScene = require("scripts.views.Tutorial.EmailForgotPasswordScene")
	
	local uiType = param[1]
	print( "uiType"..uiType )
	if uiType == Constants.TUTORIAL_SHOW_SIGNIN_TYPE then
		if EmailSelectScene.isFrameShown() then
			local delayTime = EmailSelectScene.playMoveAnim( 1 )
	    	SigninTypeSelectScene.playMoveAnim( 1, delayTime )
		else
			SigninTypeSelectScene.playFadeInAnim()
		end
		SigninTypeSelectScene.onShown()
	elseif uiType == Constants.TUTORIAL_SHOW_EMAIL_SELECT then
		if SigninTypeSelectScene.isFrameShown() then
			local delayTime = SigninTypeSelectScene.playMoveAnim( -1 )
	    	EmailSelectScene.playMoveAnim( -1, delayTime )
		elseif EmailSigninScene.isFrameShown() then
			local delayTime = EmailSigninScene.playMoveAnim( 1 )
	    	EmailSelectScene.playMoveAnim( 1, delayTime )
	    elseif EmailRegisterScene.isFrameShown() then
	    	local delayTime = EmailRegisterScene.playMoveAnim( 1 )
	    	EmailSelectScene.playMoveAnim( 1, delayTime )
		end
		EmailSelectScene.onShown()
	elseif uiType == Constants.TUTORIAL_SHOW_EMAIL_SIGNIN then
		if EmailSelectScene.isFrameShown() then
			local delayTime = EmailSelectScene.playMoveAnim( -1 )
	    	EmailSigninScene.playMoveAnim( -1, delayTime )
		elseif EmailForgotPasswordScene.isFrameShown() then
			local delayTime = EmailForgotPasswordScene.playMoveAnim( 1 )
	    	EmailSigninScene.playMoveAnim( 1, delayTime )
		end
		EmailSigninScene.onShown()
	elseif uiType == Constants.TUTORIAL_SHOW_EMAIL_REGISTER then
		if EmailSelectScene.isFrameShown() then
			local delayTime = EmailSelectScene.playMoveAnim( -1 )
	    	EmailRegisterScene.playMoveAnim( -1, delayTime )
		end
		EmailRegisterScene.onShown()
	elseif uiType == Constants.TUTORIAL_SHOW_FORGOT_PASSWORD then
		if EmailSigninScene.isFrameShown() then
			local delayTime = EmailSigninScene.playMoveAnim( -1 )
	    	EmailForgotPasswordScene.playMoveAnim( -1, delayTime )
		end
		EmailForgotPasswordScene.onShown()
	end
	
end