module(..., package.seeall)

local Constants = require("scripts.Constants")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local ConnectingMessage = require("scripts.views.ConnectingMessage")
local Json = require("json")
local RequestUtils = require("scripts.RequestUtils")

local mEmail = "test126@abc.com"
local mPassword = "test126"
local mPasswordConf = "test126"


function action( param )

    mEmail, mPassword, mPasswordConf = param[1], param[2], param[3]
    if string.len( mEmail ) == 0 then
        onRequestFailed( "Email is blank." )
        return
    end
    if mPassword ~= mPasswordConf then
        onRequestFailed( "Two passwords are not the same." )
        return
    end
    if string.len( mPassword ) < 6 then
        onRequestFailed( "Password too short." )
        return
    end
    if string.len( mPassword ) > 160 then
        onRequestFailed( "Password too long." )
        return
    end
    if string.find( mEmail, "([-%a%d%._]+)@([-%a%d.]+)" ) == nil then
        onRequestFailed( "Bad email format." )
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
            local sessionToken = jsonResponse["SessionToken"]
            local configMd5Info = jsonResponse["ConfigMd5Info"]
            onRequestSuccess( sessionToken, configMd5Info )
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
    httpRequest:sendHttpRequest( RequestUtils.EMAIL_REGISTER_REST_CALL, handler )

    ConnectingMessage.loadFrame()
end

function onRequestSuccess( sessionToken, configMd5Info )
    local Logic = require("scripts.Logic").getInstance()
    Logic:setUserInfo( mEmail, mPassword, sessionToken )

    EventManager:postEvent( Event.Check_File_Version, { configMd5Info, Event.Enter_Register_Name } )
end

function onRequestFailed( errorBuffer )
    EventManager:postEvent( Event.Show_Error_Message, { errorBuffer } )
end