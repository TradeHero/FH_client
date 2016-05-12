module(..., package.seeall)

local Json = require("json")
local Constants = require("scripts.Constants")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local ConnectingMessage = require("scripts.views.ConnectingMessage")
local RequestUtils = require("scripts.RequestUtils")
local Logic = require("scripts.Logic").getInstance()
local CompetitionType = require("scripts.data.Competitions").CompetitionType
local CompetitionConfig = require("scripts.data.Competitions")

function action( param )

    local token = param[1]

    if string.len( token ) == 0 then
        RequestUtils.onRequestFailed( Constants.String.error.blank_token )
        return
    end

    local requestContent = { JoinToken = token }
    local requestContentText = Json.encode( requestContent )
    
    local url = RequestUtils.POST_JOIN_COMPETITION_REST_CALL

    local requestInfo = {}
    requestInfo.requestData = requestContentText
    requestInfo.url = url

     local handler = function( isSucceed, body, header, status, errorBuffer )
        RequestUtils.messageHandler( requestInfo, isSucceed, body, header, status, errorBuffer, RequestUtils.HTTP_200, true, onRequestSuccess )
    end

    local httpRequest = HttpRequestForLua:create( CCHttpRequest.kHttpPost )
    httpRequest:addHeader( Constants.CONTENT_TYPE_JSON )
    httpRequest:addHeader( Logic:getAuthSessionString() )
    httpRequest:getRequest():setRequestData( requestContentText, string.len( requestContentText ) )
    httpRequest:sendHttpRequest( url, handler )

    ConnectingMessage.loadFrame()
end

function onRequestSuccess( jsonResponse )
    local competitionId = jsonResponse["CompetitionId"]
    local joinToken = jsonResponse["JoinToken"]
    local competitionType = jsonResponse["CompetitionType"]
    local ticket = jsonResponse["Ticket"]

    local params = { Action = "join" }
    CCLuaLog("Send ANALYTICS_EVENT_COMPETITION: "..Json.encode( params ) )
    Analytics:sharedDelegate():postEvent( Constants.ANALYTICS_EVENT_COMPETITION, Json.encode( params ) )
    Analytics:sharedDelegate():postFlurryEvent( Constants.ANALYTICS_EVENT_COMPETITION, Json.encode( params ) )

    if competitionType ~=CompetitionType["Private"] then
        local params = { Action = "join", Competition = joinToken }
        CCLuaLog("Send ANALYTICS_EVENT_SPECIAL_COMPETITION: "..Json.encode( params ) )
        Analytics:sharedDelegate():postEvent( Constants.ANALYTICS_EVENT_SPECIAL_COMPETITION, Json.encode( params ) )
        Analytics:sharedDelegate():postFlurryEvent( Constants.ANALYTICS_EVENT_SPECIAL_COMPETITION, Json.encode( params ) )
    end

    local sortType = 3
    Logic:setTicket( ticket)
    EventManager:postEvent( Event.Enter_Competition_Detail, { competitionId, true, sortType, CompetitionConfig.COMPETITION_TAB_ID_OVERALL } )
end