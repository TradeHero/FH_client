module(..., package.seeall)

local Json = require("json")
local Constants = require("scripts.Constants")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local ConnectingMessage = require("scripts.views.ConnectingMessage")
local RequestUtils = require("scripts.RequestUtils")
local Logic = require("scripts.Logic").getInstance()
local PushNotificationManager = require("scripts.PushNotificationManager")
local QuickBloxService = require("scripts.QuickBloxService")

function action( param )

    local testDemo = require( "scripts.views.TestDemo" )
    testDemo.loadFrame()
    
end
