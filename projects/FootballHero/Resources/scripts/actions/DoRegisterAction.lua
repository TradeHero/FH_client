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
        RequestUtils.onRequestFailed( "Email is blank." )
        return
    end
    if mPassword ~= mPasswordConf then
        RequestUtils.onRequestFailed( "Two passwords are not the same." )
        return
    end
    if string.len( mPassword ) < 6 then
        RequestUtils.onRequestFailed( "Password too short." )
        return
    end
    if string.len( mPassword ) > 160 then
        RequestUtils.onRequestFailed( "Password too long." )
        return
    end
    if string.find( mEmail, "([-%a%d%._]+)@([-%a%d.]+)" ) == nil then
        RequestUtils.onRequestFailed( "Bad email format." )
        return
    end

    local requestContent = { Email = mEmail, Password = mPassword, useDev = RequestUtils.USE_DEV }
    local requestContentText = Json.encode( requestContent )
    
    local url = RequestUtils.EMAIL_REGISTER_REST_CALL

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
    local sessionToken = jsonResponse["SessionToken"]
    local userId = jsonResponse["Id"]
    local configMd5Info = jsonResponse["ConfigMd5Info"]
    local displayName = jsonResponse["DisplayName"]
    local pictureUrl = jsonResponse["PictureUrl"]
    local startLeagueId = jsonResponse["StartLeagueId"]
    local balance = jsonResponse["Balance"]
    local FbId = jsonResponse["FbId"]

    local Logic = require("scripts.Logic").getInstance()
    Logic:setUserInfo( mEmail, mPassword, sessionToken, userId )
    Logic:setDisplayName( displayName )
    Logic:setPictureUrl( pictureUrl )
    Logic:setStartLeagueId( startLeagueId )
    Logic:setBalance( balance )
    Logic:setFbId( FbId )

    EventManager:postEvent( Event.Check_File_Version, { configMd5Info, Event.Enter_Register_Name } )
end