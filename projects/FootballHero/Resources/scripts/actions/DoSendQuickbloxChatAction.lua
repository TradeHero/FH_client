module(..., package.seeall)

local Json = require("json")
local Constants = require("scripts.Constants")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local ConnectingMessage = require("scripts.views.ConnectingMessage")
local RequestUtils = require("scripts.RequestUtils")
local Logic = require("scripts.Logic").getInstance()
local LeagueChatConfig = require("scripts.config.LeagueChat").LeagueChatType
local QuickBloxService = require("scripts.QuickBloxService")


function action( param )
    local message = param[1]

    if string.len( message ) == 0 then
        return
    end

    QuickBloxService.sendMessage( message )
end
