module(..., package.seeall)

local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local ConnectingMessage = require("scripts.views.ConnectingMessage")
local Logic = require("scripts.Logic").getInstance()
local Json = require("json")
local Constants = require("scripts.Constants")
local RequestUtils = require("scripts.RequestUtils")


function action( param )
    local competitionId = param[1]
    local accessToken = param[2]

    local requestContent = { CompetitionId = competitionId, FacebookToken = accessToken }
    local requestContentText = Json.encode( requestContent )
    
    local url = RequestUtils.POST_SHARE_COMPETITION_REST_CALL

    local requestInfo = {}
    requestInfo.requestData = requestContentText
    requestInfo.url = url

    local handler = function( isSucceed, body, header, status, errorBuffer )
        RequestUtils.messageHandler( requestInfo, isSucceed, body, header, status, errorBuffer, RequestUtils.HTTP_200, false, onRequestSuccess )
    end

    local httpRequest = HttpRequestForLua:create( CCHttpRequest.kHttpPost )
    httpRequest:addHeader( "Content-Type: application/json" )
    httpRequest:addHeader( Logic:getAuthSessionString() )
    httpRequest:getRequest():setRequestData( requestContentText, string.len( requestContentText ) )
    httpRequest:sendHttpRequest( url, handler )
end

function onRequestSuccess( jsonResponse )
    local refreshLeaderboard = false
    if type( jsonResponse ) == "table" and jsonResponse["RefreshLeaderboard"] then
        refreshLeaderboard = true
    end
    if refreshLeaderboard then
        -- Invalid the cache.
        RequestUtils.invalidResponseCacheContainsUrl( RequestUtils.GET_COMPETITION_DETAIL_REST_CALL )
        -- Reload the current page.
        EventManager:reloadCurrent()
    end
end