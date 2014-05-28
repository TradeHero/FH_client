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
        RequestUtils.onRequestFailed( "Email is blank." )
        return
    end
    if string.len( mPassword ) == 0 then
        RequestUtils.onRequestFailed( "Password is blank." )
        return
    end

    local requestContent = { Email = mEmail, Password = mPassword, useDev = RequestUtils.USE_DEV }
    local requestContentText = Json.encode( requestContent )
    
    local url = RequestUtils.EMAIL_LOGIN_REST_CALL

    local requestInfo = {}
    requestInfo.requestData = requestContentText
    requestInfo.url = url

     local handler = function( isSucceed, body, header, status, errorBuffer )
        RequestUtils.messageHandler( requestInfo, isSucceed, body, header, status, errorBuffer, RequestUtils.HTTP_200, onRequestSuccess )
    end

    local httpRequest = HttpRequestForLua:create( CCHttpRequest.kHttpPost )
    httpRequest:addHeader( Constants.CONTENT_TYPE_JSON )
    httpRequest:getRequest():setRequestData( requestContentText, string.len( requestContentText ) )
    httpRequest:sendHttpRequest( url, handler )

    ConnectingMessage.loadFrame()
end

function onRequestSuccess( jsonResponse )
    local sessionToken = jsonResponse["ProfileDto"]["SessionToken"]
    local userId = jsonResponse["ProfileDto"]["Id"]
    local configMd5Info = jsonResponse["ProfileDto"]["ConfigMd5Info"]
    local displayName = jsonResponse["ProfileDto"]["DisplayName"]
    local startLeagueId = jsonResponse["ProfileDto"]["StartLeagueId"]
    local balance = jsonResponse["ProfileDto"]["Balance"]
    local FbLinked = jsonResponse["ProfileDto"]["FbLinked"]

    local Logic = require("scripts.Logic").getInstance()
    Logic:setUserInfo( mEmail, mPassword, sessionToken, userId )
    Logic:setDisplayName( displayName )
    Logic:setStartLeagueId( startLeagueId )
    Logic:setBalance( balance )
    Logic:setFbLinked( FbLinked )

    local finishEvent = Event.Enter_Sel_Fav_Team
    if displayName == nil then
        finishEvent = Event.Enter_Register_Name
    end
    EventManager:postEvent( Event.Check_File_Version, { configMd5Info, finishEvent } )
end