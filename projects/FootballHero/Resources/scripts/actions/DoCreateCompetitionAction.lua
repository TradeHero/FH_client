module(..., package.seeall)

local Json = require("json")
local Constants = require("scripts.Constants")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local ConnectingMessage = require("scripts.views.ConnectingMessage")
local RequestUtils = require("scripts.RequestUtils")
local Logic = require("scripts.Logic").getInstance()

function action( param )

    local name, description, startTime, endTime, selectedLeagues = param[1], param[2], param[3], param[4], param[5]

    if string.len( name ) == 0 then
        RequestUtils.onRequestFailed( "Title is blank." )
        return
    end
    if string.len( description ) == 0 then
        RequestUtils.onRequestFailed( "Description is blank." )
        return
    end

    if endTime < startTime then
        RequestUtils.onRequestFailed( "The end date is in the past." )
        return
    end

    if table.getn( selectedLeagues ) == 0 then
        RequestUtils.onRequestFailed( "Selected League is blank." )
        return
    end

    local requestContent = { Name = name, 
                            Description = description, 
                            StartTime = startTime, 
                            EndTime = endTime, 
                            AllowedLeaguesIds = Json.encode( selectedLeagues ) }
    local requestContentText = Json.encode( requestContent )
    print( requestContentText )
    
    local url = RequestUtils.POST_CREATE_COMPETITION_REST_CALL

    local requestInfo = {}
    requestInfo.requestData = requestContentText
    requestInfo.url = url

     local handler = function( isSucceed, body, header, status, errorBuffer )
        RequestUtils.messageHandler( requestInfo, isSucceed, body, header, status, errorBuffer, RequestUtils.HTTP_200, onRequestSuccess )
    end

    local httpRequest = HttpRequestForLua:create( CCHttpRequest.kHttpPost )
    httpRequest:addHeader( Constants.CONTENT_TYPE_JSON )
    httpRequest:addHeader( Logic:getAuthSessionString() )
    httpRequest:getRequest():setRequestData( requestContentText, string.len( requestContentText ) )
    httpRequest:sendHttpRequest( url, handler )

    ConnectingMessage.loadFrame()
end

function onRequestSuccess( jsonResponse )

end