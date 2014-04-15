module(..., package.seeall)

local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local ConnectingMessage = require("scripts.views.ConnectingMessage")

function action( param )
	local Json = require("json")
	local RequestConstants = require("scripts.RequestConstants")

    local successHandler = function( num )
        if num == nil then
            -- To handle user reject to the oAuth.
        else
            print("Get login result "..num)
        end
    end

    FacebookDelegate:sharedDelegate():login( successHandler, successHandler )
end