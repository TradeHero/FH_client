module(..., package.seeall)

local Json = require("json")
local Constants = require("scripts.Constants")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local ConnectingMessage = require("scripts.views.ConnectingMessage")
local RequestUtils = require("scripts.RequestUtils")
local Logic = require("scripts.Logic").getInstance()
local LeagueChat = require("scripts.config.LeagueChat")
local LeagueChatConfig = LeagueChat.LeagueChatType
local QuickBloxUsers = require("scripts.data.QuickBloxUsers")


local mCallback

function action( param )
    local unCachedUsers = param[1]
    mCallback = param[2]

    local requestContent = {}
    local requestContentText = Json.encode( requestContent )
    
    local url = "https://api.quickblox.com/users.json"
    url = url.."?page=1&per_page=100&filter[]=number+id+in+"..unCachedUsers

    local requestInfo = {}
    requestInfo.requestData = requestContentText
    requestInfo.url = url

     local handler = function( isSucceed, body, header, status, errorBuffer )
        RequestUtils.messageHandler( requestInfo, isSucceed, body, header, status, errorBuffer, RequestUtils.HTTP_200, false, onRequestSuccess )
    end

    local httpRequest = HttpRequestForLua:create( CCHttpRequest.kHttpGet )
    httpRequest:addHeader( Logic:getQuickbloxSessionString() )
    httpRequest:sendHttpRequest( url, handler )
end

function onRequestSuccess( jsonResponse )

    CCLuaLog("Quickblox users.")
    for k,v in pairs( jsonResponse["items"] ) do
        local user = v["user"]
        QuickBloxUsers.addUser( user["id"], user )
    end

    mCallback()
end