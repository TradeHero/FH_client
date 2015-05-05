module(..., package.seeall)

local Json = require("json")
local RequestUtils = require("scripts.RequestUtils")
local ConnectingMessage = require("scripts.views.ConnectingMessage")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local Logic = require("scripts.Logic").getInstance()


function action( param )
    local videoURL = param[1]
    local youtubeKey = param[2]

    local VideoInfoScene = require("scripts.views.VideoInfoScene")
    VideoInfoScene.loadFrame( videoURL, youtubeKey )
end