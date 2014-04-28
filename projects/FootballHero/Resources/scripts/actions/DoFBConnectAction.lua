module(..., package.seeall)

local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local ConnectingMessage = require("scripts.views.ConnectingMessage")
local Json = require("json")
local RequestConstants = require("scripts.RequestConstants")


function action( param )
	local Json = require("json")
	local RequestConstants = require("scripts.RequestConstants")

    local successHandler = function( accessToken )
        if accessToken == nil then
            -- To handle user reject to the oAuth.
            onFBConnectFailed()
        else
            print("Get login result "..accessToken)
            onFBConnectSuccess( accessToken )
        end
    end

    FacebookDelegate:sharedDelegate():login( successHandler, successHandler )
end

function onFBConnectFailed()

end

function onFBConnectSuccess( accessToken )
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
        if status == RequestConstants.HTTP_200 then
            local sessionToken = jsonResponse["sessionToken"]
            local email = jsonResponse["email"]
            onRequestSuccess( sessionToken, email )
        else
            onRequestFailed( jsonResponse["Message"] )
        end
    end

    local requestContent = { SocialNetworkType = 0, AuthToken = accessToken }
    local requestContentText = Json.encode( requestContent )
    print("Request content is "..requestContentText)

    local httpRequest = HttpRequestForLua:create( CCHttpRequest.kHttpPost, "Content-Type: application/json" )
    httpRequest:getRequest():setRequestData( requestContentText, string.len( requestContentText ) )
    httpRequest:sendHttpRequest( RequestConstants.FB_LOGIN_REST_CALL, handler )

    ConnectingMessage.loadFrame()
end

function onRequestSuccess( sessionToken, email )
    local Logic = require("scripts.Logic").getInstance()
    Logic:setUserInfo( "", "", sessionToken )
    EventManager:postEvent( Event.Enter_Register_Name, { email } )
end

function onRequestFailed( errorBuffer )
    EventManager:postEvent( Event.Show_Error_Message, { errorBuffer } )
end