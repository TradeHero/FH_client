module(..., package.seeall)

local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local Logic = require("scripts.Logic").getInstance()
local Json = require("json")
local RequestUtils = require("scripts.RequestUtils")


local KEY_OF_START_TUTORIAL = "start_tutorial_1.0"

function action( param )
    local record = CCUserDefault:sharedUserDefault():getBoolForKey( KEY_OF_START_TUTORIAL )
    if record == false then
    	local StartTutorialScene = require("scripts.views.StartTutorialScene")
    	StartTutorialScene.loadFrame( tutorialEnd )
    else
        tutorialEnd()
    end
end

function tutorialEnd()
	CCUserDefault:sharedUserDefault():setBoolForKey( KEY_OF_START_TUTORIAL, true )
    EventManager:postEvent( Event.Enter_Login_N_Reg )
end