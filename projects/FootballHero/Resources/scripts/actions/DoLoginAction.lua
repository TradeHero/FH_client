module(..., package.seeall)

local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local ConnectingMessage = require("scripts.views.ConnectingMessage")

local mEmail = "test126@abc.com"
local mPassword = "test126"


function action( param )
	local Json = require("json")
	local RequestConstants = require("scripts.RequestConstants")

    mEmail, mPassword = param[1], param[2]

    if string.len( mEmail ) == 0 then
        onRequestFailed( "Email is blank." )
        return
    end
    if string.len( mPassword ) == 0 then
        onRequestFailed( "Password is blank." )
        return
    end

    local handler = function( isSucceed, body, header, status, errorBuffer )
        print( "Http reponse: "..status.." and errorBuffer: "..errorBuffer )
        print( "Http reponse body: "..body )
        local jsonResponse = Json.decode( body )
        ConnectingMessage.selfRemove()
        if status == RequestConstants.HTTP_200 then
            local sessionToken = jsonResponse["profileDTO"]["sessionToken"]
            onRequestSuccess()
        else
            onRequestFailed( jsonResponse["Message"] )
        end
    end

    local requestContent = { Email = mEmail, Password = mPassword }
    local requestContentText = Json.encode( requestContent )
    print("Request content is "..requestContentText)

    local httpRequest = HttpRequestForLua:create( CCHttpRequest.kHttpPost, "Content-Type: application/json" )
    httpRequest:getRequest():setRequestData( requestContentText, string.len( requestContentText ) )
    httpRequest:sendHttpRequest( RequestConstants.EMAIL_LOGIN_REST_CALL, handler )

    ConnectingMessage.loadFrame()
end

function onRequestSuccess( sessionToken )
    local Logic = require("scripts.Logic").getInstance()
    Logic:setUserInfo( mEmail, mPassword, sessionToken )
    EventManager:postEvent( Event.Enter_Match_List )
end

function onRequestFailed( errorBuffer )
    EventManager:postEvent( Event.Show_Error_Message, { errorBuffer } )
end