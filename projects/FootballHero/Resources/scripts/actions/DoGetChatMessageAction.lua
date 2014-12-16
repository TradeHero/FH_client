module(..., package.seeall)

local Json = require("json")
local Constants = require("scripts.Constants")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local ConnectingMessage = require("scripts.views.ConnectingMessage")
local RequestUtils = require("scripts.RequestUtils")
local Logic = require("scripts.Logic").getInstance()
local LeagueChatConfig = require("scripts.config.LeagueChat").LeagueChatType

local mIsSending = false
local mChannelId
local mCallback
local mIsLeague
local mSilent

function action( param )
    if mIsSending then
        print(" Is sending, skip... ")
        local callback = param[4]
        if callback ~= nil then
            callback()
        end
        return
    end
    mIsSending = true

    mChannelId = param[1]
    local last = param[2]
    mSilent = param[3]
    mCallback = param[4]
    mIsLeague = param[5] or false

    local requestContent = {}
    local requestContentText = Json.encode( requestContent )
    
    local channel
    if mIsLeague then
        channel = LeagueChatConfig[mChannelId]["chatRoomId"]
    else
        channel = mChannelId
    end

    local url = RequestUtils.GET_CHAT_MESSAGE_REST_CALL
    url = url.."?channel="..channel.."&last="..last
    if RequestUtils.USE_DEV then
        url = url.."&useDev=true"
    end

    local requestInfo = {}
    requestInfo.requestData = requestContentText
    requestInfo.url = url

     local handler = function( isSucceed, body, header, status, errorBuffer )
        RequestUtils.messageHandler( requestInfo, isSucceed, body, header, status, errorBuffer, RequestUtils.HTTP_200, onRequestSuccess, onRequestFailed )
    end

    local httpRequest = HttpRequestForLua:create( CCHttpRequest.kHttpGet )
    httpRequest:addHeader( Logic:getAuthSessionString() )
    httpRequest:sendHttpRequest( url, handler )

    if not mSilent then
        ConnectingMessage.loadFrame()
    end
end

function onRequestSuccess( jsonResponse )
    local ChatScene
    if mIsLeague then
        ChatScene = require("scripts.views.LeagueChatScene")
    else
        ChatScene = require("scripts.views.CompetitionChatScene")
    end
    local ChatMessages = require("scripts.data.ChatMessages").ChatMessages

    local chatMessages = ChatMessages:new()
    for k,v in pairs( jsonResponse ) do
        chatMessages:addMessage( v )
    end

    -- Get the time stamp for the last message.
    local lastMessage = jsonResponse[table.getn( jsonResponse )]
    if lastMessage ~= nil then
        Logic:setLastChatMessageTimestamp( lastMessage["UnixTimeStamp"] )
    end

    -- Display the messages.
    if mSilent then
        ChatScene.addMessage( chatMessages )
    else
        ChatScene.initMessages( chatMessages )
    end

    if mCallback ~= nil then
        mCallback()
    end

    mIsSending = false
end

function onRequestFailed( errorBuffer )
    if mCallback ~= nil then
        mCallback()
    end

    mIsSending = false
end