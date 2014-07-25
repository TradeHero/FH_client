module(..., package.seeall)

local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local Logic = require("scripts.Logic")


function action( param )
	if string.len( Logic.getInstance():getEmail() ) > 0 and string.len( Logic.getInstance():getPassword() ) > 0 then
		EventManager:postEvent( Event.Do_Login, { Logic.getInstance():getEmail(), Logic.getInstance():getPassword() } )
	else
		local loginScene = require("scripts.views.LoginScene")
    	loginScene.loadFrame()	
	end
end