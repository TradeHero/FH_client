module(..., package.seeall)

local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local ConnectingMessage = require("scripts.views.ConnectingMessage")
local Logic = require("scripts.Logic").getInstance()

local mUserName = "SamYu"
local mFirstName = "Yu"
local mLastName = "Zheng"


function action( param )
	local Json = require("json")
	local RequestUtils = require("scripts.RequestUtils")

    mUserName, mFirstName, mLastName = param[1], param[2], param[3]
    if string.len( mUserName ) == 0 then
        RequestUtils.onRequestFailed( "User name is blank." )
        return
    end
    if mFirstName == nil then
        mFirstName = ""
    end

    if mLastName == nil then
        mLastName = ""
    end

    local requestContent = { DisplayName = mUserName, FirstName = mFirstName, LastName = mLastName, DoB = "" }
    local requestContentText = Json.encode( requestContent )
    
    local url = RequestUtils.SET_USER_METADATA_REST_CALL

    local requestInfo = {}
    requestInfo.requestData = requestContentText
    requestInfo.url = url

    local handler = function( isSucceed, body, header, status, errorBuffer )
        RequestUtils.messageHandler( requestInfo, isSucceed, body, header, status, errorBuffer, RequestUtils.HTTP_200, onRequestSuccess )
    end

    local httpRequest = HttpRequestForLua:create( CCHttpRequest.kHttpPost )
    httpRequest:addHeader( "Content-Type: application/json" )
    httpRequest:addHeader( Logic:getAuthSessionString() )
    httpRequest:getRequest():setRequestData( requestContentText, string.len( requestContentText ) )
    httpRequest:sendHttpRequest( url, handler )

    ConnectingMessage.loadFrame()
end

function onRequestSuccess( jsonResponse )
    Logic:setDisplayName( mUserName )
    
    EventManager:postEvent( Event.Do_Post_Logo )
    EventManager:postEvent( Event.Enter_Sel_Fav_Team )
end