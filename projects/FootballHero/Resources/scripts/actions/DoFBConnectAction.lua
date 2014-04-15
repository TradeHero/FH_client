module(..., package.seeall)

local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local ConnectingMessage = require("scripts.views.ConnectingMessage")

function action( param )
	local Json = require("json")
	local RequestConstants = require("scripts.RequestConstants")

    local successHandler = function( num )
        print("Get login result "..num)
    end

    local failHandler = function( num )
        print("Get login result "..num)
    end

    FacebookDelegate:sharedDelegate():login( successHandler, failHandler )
end