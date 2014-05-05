module(..., package.seeall)

local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local ConnectingMessage = require("scripts.views.ConnectingMessage")

local mUserName = "SamYu"
local mFirstName = "Yu"
local mLastName = "Zheng"


function action( param )
	local Json = require("json")
	local RequestUtils = require("scripts.RequestUtils")

    mUserName, mFirstName, mLastName = param[1], param[2], param[3]
    if string.len( mUserName ) == 0 then
        onRequestFailed( "User name is blank." )
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
            local sessionToken = jsonResponse["sessionToken"]
            onRequestSuccess()
        else
            onRequestFailed( jsonResponse["Message"] )
        end
    end

--[[
    local requestContent = { Email = mEmail, Password = mPassword }
    local requestContentText = Json.encode( requestContent )
    print("Request content is "..requestContentText)

    local httpRequest = HttpRequestForLua:create( CCHttpRequest.kHttpPost )
    httpRequest:addHeader( "Content-Type: application/json" )
    httpRequest:getRequest():setRequestData( requestContentText, string.len( requestContentText ) )
    httpRequest:sendHttpRequest( RequestUtils.EMAIL_REGISTER_REST_CALL, handler )

    ConnectingMessage.loadFrame()
--]]
    onRequestSuccess( nil )
end

function onRequestSuccess( sessionToken )
    EventManager:postEvent( Event.Enter_Sel_Fav_Team )
end

function onRequestFailed( errorBuffer )
    EventManager:postEvent( Event.Show_Error_Message, { errorBuffer } )
end