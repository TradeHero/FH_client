module(..., package.seeall)

local Json = require("json")
local Constants = require("scripts.Constants")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local ConnectingMessage = require("scripts.views.ConnectingMessage")
local RequestUtils = require("scripts.RequestUtils")
local Logic = require("scripts.Logic").getInstance()
local LeagueChatConfig = require("scripts.config.LeagueChat").LeagueChatType

local mChannelId
local mIsLeague

function action( param )

    mChannelId = param[1]
    local message = param[2]
    mIsLeague = param[3] or false

    if string.len( message ) == 0 then
        return
    end

    local channel
    if mIsLeague then
        channel = LeagueChatConfig[mChannelId]["chatRoomId"]
    else
        channel = mChannelId
    end

    local requestContent = { channel = channel, 
                            MessageText = message, 
                            useDev = RequestUtils.USE_DEV }
    local requestContentText = Json.encode( requestContent )
    print( "Post message: "..requestContentText )
    
    local url = RequestUtils.POST_CHAT_MESSAGE_REST_CALL

    local requestInfo = {}
    requestInfo.requestData = requestContentText
    requestInfo.url = url

     local handler = function( isSucceed, body, header, status, errorBuffer )
        RequestUtils.messageHandler( requestInfo, isSucceed, body, header, status, errorBuffer, RequestUtils.HTTP_200, onRequestSuccess )
    end

    local httpRequest = HttpRequestForLua:create( CCHttpRequest.kHttpPost )
    httpRequest:addHeader( Constants.CONTENT_TYPE_JSON )
    httpRequest:addHeader( Logic:getAuthSessionString() )
    httpRequest:getRequest():setRequestData( requestContentText, string.len( requestContentText ) )
    httpRequest:sendHttpRequest( url, handler )

    ConnectingMessage.loadFrame()
end

function onRequestSuccess( jsonResponse )
    local lastChatMesageTimestamp = Logic:getLastChatMessageTimestamp()
    local isSilent, callback, isLeague = true, nil , mIsLeague
    EventManager:postEvent( Event.Do_Get_Chat_Message, { mChannelId, lastChatMesageTimestamp, isSilent, callback, isLeague } )
end