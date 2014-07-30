module(..., package.seeall)

local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local Logic = require("scripts.Logic").getInstance()
local Json = require("json")
local RequestUtils = require("scripts.RequestUtils")


local KEY_OF_START_TUTORIAL = "start_tutorial_1.0"

function action( param )
    local StartTutorialScene = require("scripts.views.StartTutorialScene")
    local SigninTypeSelectScene = require("scripts.views.Tutorial.SigninTypeSelectScene")
    local EmailSelectScene = require("scripts.views.Tutorial.EmailSelectScene")
    local EmailSigninScene = require("scripts.views.Tutorial.EmailSigninScene")
    local EmailRegisterScene = require("scripts.views.Tutorial.EmailRegisterScene")
    local EmailForgotPasswordScene = require("scripts.views.Tutorial.EmailForgotPasswordScene")
    local EmailRegisterNameScene = require("scripts.views.Tutorial.EmailRegisterNameScene")

    StartTutorialScene.loadFrame()
    SigninTypeSelectScene.loadFrame()
    EmailSelectScene.loadFrame()
    EmailSigninScene.loadFrame()
    EmailRegisterScene.loadFrame()
    EmailForgotPasswordScene.loadFrame()
    EmailRegisterNameScene.loadFrame()
end

function tutorialEnd()
	CCUserDefault:sharedUserDefault():setBoolForKey( KEY_OF_START_TUTORIAL, true )
    EventManager:postEvent( Event.Enter_Login_N_Reg )
end