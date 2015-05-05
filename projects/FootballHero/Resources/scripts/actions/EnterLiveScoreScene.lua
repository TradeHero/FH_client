module(..., package.seeall)

local Json = require("json")
local ConnectingMessage = require("scripts.views.ConnectingMessage")
local Logic = require("scripts.Logic").getInstance()
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local RequestUtils = require("scripts.RequestUtils")
local Constants = require("scripts.Constants")

function action( param )
    local liveScoreScene = require( "scripts.views.LiveScoreScene" )
    if liveScoreScene.isFrameShown() ~= true then
        liveScoreScene.loadFrame()
    end
end

