module(..., package.seeall)

local Json = require("json")
local Constants = require("scripts.Constants")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local ConnectingMessage = require("scripts.views.ConnectingMessage")
local RequestUtils = require("scripts.RequestUtils")

local mEmail = "test126@abc.com"
local mPassword = "test126"


function action( param )

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
        
        local jsonResponse = {}
        if string.len( body ) > 0 then
            jsonResponse = Json.decode( body )
        else
            jsonResponse["Message"] = errorBuffer
        end
        ConnectingMessage.selfRemove()
        if status == RequestUtils.HTTP_200 then
            local sessionToken = jsonResponse["ProfileDto"]["SessionToken"]
            onRequestSuccess( sessionToken )
        else
            onRequestFailed( jsonResponse["Message"] )
        end
    end

    local requestContent = { Email = mEmail, Password = mPassword }
    local requestContentText = Json.encode( requestContent )
    print("Request content is "..requestContentText)

    local httpRequest = HttpRequestForLua:create( CCHttpRequest.kHttpPost )
    httpRequest:addHeader( Constants.CONTENT_TYPE_JSON )
    httpRequest:getRequest():setRequestData( requestContentText, string.len( requestContentText ) )
    httpRequest:sendHttpRequest( RequestUtils.EMAIL_LOGIN_REST_CALL, handler )

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