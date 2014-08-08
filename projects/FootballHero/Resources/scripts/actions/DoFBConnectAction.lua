module(..., package.seeall)

local Constants = require("scripts.Constants")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local ConnectingMessage = require("scripts.views.ConnectingMessage")
local Json = require("json")
local RequestUtils = require("scripts.RequestUtils")


function action( param )
	local Json = require("json")
	local RequestUtils = require("scripts.RequestUtils")

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
    ConnectingMessage.loadFrame()
end

function onFBConnectFailed()
    ConnectingMessage.selfRemove()
end

function onFBConnectSuccess( accessToken )
    local requestContent = { SocialNetworkType = 0, AuthToken = accessToken, useDev = RequestUtils.USE_DEV }
    local requestContentText = Json.encode( requestContent )
    
    local url = RequestUtils.FB_LOGIN_REST_CALL
    
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
end

function onRequestSuccess( jsonResponse )
    local sessionToken = jsonResponse["SessionToken"]
    local userId = jsonResponse["Id"]
    local configMd5Info = jsonResponse["ConfigMd5Info"]
    local displayName = jsonResponse["DisplayName"]
    local pictureUrl = jsonResponse["PictureUrl"]
    local startLeagueId = jsonResponse["StartLeagueId"]
    local balance = jsonResponse["Balance"]
    local active = jsonResponse["ProfileDto"]["ActiveInCompetition"]
    local FbId = jsonResponse["FbId"]

    local Logic = require("scripts.Logic").getInstance()
    Logic:setUserInfo( "", "", sessionToken, userId )
    Logic:setDisplayName( displayName )
    Logic:setPictureUrl( pictureUrl )
    Logic:setStartLeagueId( startLeagueId )
    Logic:setBalance( balance )
    Logic:setActiveInCompetition( active )
    Logic:setFbId( FbId )
    
    local finishEvent = Event.Enter_Sel_Fav_Team
    if displayName == nil then
        finishEvent = Event.Enter_Register_Name
    end

    EventManager:postEvent( Event.Check_File_Version, { configMd5Info, finishEvent } )
end