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
        if status == RequestUtils.HTTP_200 then
            local sessionToken = jsonResponse["SessionToken"]
            local userId = jsonResponse["UserId"]
            local configMd5Info = jsonResponse["ConfigMd5Info"]
            local displayName = jsonResponse["DisplayName"]
            local startLeagueId = jsonResponse["StartLeagueId"]
            local balance = jsonResponse["Balance"]
            onRequestSuccess( sessionToken, userId, configMd5Info, displayName, startLeagueId, balance )
        else
            onRequestFailed( jsonResponse["Message"] )
        end
    end

    local requestContent = { SocialNetworkType = 0, AuthToken = accessToken, useDev = RequestUtils.USE_DEV }
    local requestContentText = Json.encode( requestContent )
    print("Request content is "..requestContentText)

    local httpRequest = HttpRequestForLua:create( CCHttpRequest.kHttpPost )
    httpRequest:addHeader( Constants.CONTENT_TYPE_JSON )
    httpRequest:getRequest():setRequestData( requestContentText, string.len( requestContentText ) )
    httpRequest:sendHttpRequest( RequestUtils.FB_LOGIN_REST_CALL, handler )

    ConnectingMessage.loadFrame()
end

function onRequestSuccess( sessionToken, userId, configMd5Info, displayName, startLeagueId, balance )
    local Logic = require("scripts.Logic").getInstance()
    Logic:setUserInfo( "", "", sessionToken, userId )
    Logic:setDisplayName( displayName )
    Logic:setStartLeagueId( startLeagueId )
    Logic:setBalance( balance )
    
    local finishEvent = Event.Enter_Match_List
    if displayName == nil then
        finishEvent = Event.Enter_Register_Name
    end

    EventManager:postEvent( Event.Check_File_Version, { configMd5Info, finishEvent } )
end

function onRequestFailed( errorBuffer )
    EventManager:postEvent( Event.Show_Error_Message, { errorBuffer } )
end