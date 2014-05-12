module(..., package.seeall)

local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local ConnectingMessage = require("scripts.views.ConnectingMessage")
local Logic = require("scripts.Logic").getInstance()


function action( param )
	local Json = require("json")
	local RequestUtils = require("scripts.RequestUtils")

    favTeamID = param[1]

    local handler = function( isSucceed, body, header, status, errorBuffer )
        print( "Http reponse: "..status.." and errorBuffer: "..errorBuffer )
        print( "Http reponse body: "..body )
        
        local jsonResponse = {}
        if string.len( body ) > 0 then
            jsonResponse = Json.decode( body )
        else
            jsonResponse["Message"] = errorBuffer
        end
        ConnectingMessage.selfRemove()
        if status == RequestUtils.HTTP_200 then
            onRequestSuccess()
        else
            onRequestFailed( jsonResponse["Message"] )
        end
    end

    local requestContent = { TeamId = favTeamID }
    local requestContentText = Json.encode( requestContent )
    print("Request content is "..requestContentText)

    local httpRequest = HttpRequestForLua:create( CCHttpRequest.kHttpPost )
    httpRequest:addHeader( "Content-Type: application/json" )
    httpRequest:addHeader( Logic:getAuthSessionString() )
    httpRequest:getRequest():setRequestData( requestContentText, string.len( requestContentText ) )
    httpRequest:sendHttpRequest( RequestUtils.POST_FAV_TEAM_REST_CALL, handler )

    ConnectingMessage.loadFrame()
end

function onRequestSuccess()
    EventManager:postEvent( Event.Enter_Match_List )
end

function onRequestFailed( errorBuffer )
    EventManager:postEvent( Event.Show_Error_Message, { errorBuffer } )
end