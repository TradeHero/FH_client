module(..., package.seeall)

local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList

function action( param )
	EventManager:postEvent( Event.Enter_Login_N_Reg )
end