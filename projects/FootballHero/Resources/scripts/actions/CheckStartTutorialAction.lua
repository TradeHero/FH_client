module(..., package.seeall)

local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local Logic = require("scripts.Logic").getInstance()
local Json = require("json")
local RequestUtils = require("scripts.RequestUtils")


function action( param )
    local StartTutorialScene = require("scripts.views.StartTutorialScene")
    local SigninTypeSelectScene = require("scripts.views.Tutorial.SigninTypeSelectScene")
    local EmailSelectScene = require("scripts.views.Tutorial.EmailSelectScene")
    local EmailSigninScene = require("scripts.views.Tutorial.EmailSigninScene")
    local EmailRegisterScene = require("scripts.views.Tutorial.EmailRegisterScene")
    local EmailForgotPasswordScene = require("scripts.views.Tutorial.EmailForgotPasswordScene")
    local YuuzooSigninScene = require("scripts.views.Tutorial.YuuzooSigninScene")

    if Logic:getEmail() ~= nil and string.len( Logic:getEmail() ) > 0 and
        Logic:getPassword() ~= nil and string.len( Logic:getPassword() ) > 0 then
        StartTutorialScene.loadFrame( true )
        if Logic:getFBAccessToken() == "yuuzoo" then
            EventManager:postEvent( Event.Do_YZ_Connect, { Logic:getEmail(), Logic:getPassword() } )
        else
            EventManager:postEvent( Event.Do_Login, { Logic:getEmail(), Logic:getPassword() } )
        end
    elseif Logic:getFBAccessToken() ~= nil and string.len( Logic:getFBAccessToken() ) > 0 then
        StartTutorialScene.loadFrame( true )
        EventManager:postEvent( Event.Do_FB_Connect )
    else
        StartTutorialScene.loadFrame( true )
    end
    SigninTypeSelectScene.loadFrame()
    EmailSelectScene.loadFrame()
    EmailSigninScene.loadFrame()
    EmailRegisterScene.loadFrame()
    EmailForgotPasswordScene.loadFrame()
    YuuzooSigninScene.loadFrame()
end