module(..., package.seeall)

local Json = require("json")
local Constants = require("scripts.Constants")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local ConnectingMessage = require("scripts.views.ConnectingMessage")
local RequestUtils = require("scripts.RequestUtils")
local Logic = require("scripts.Logic").getInstance()


local mCompetitionId

function action( param )

    mCompetitionId = param[1]
    local last = param[2]

    local requestContent = {}
    local requestContentText = Json.encode( requestContent )
    
    local url = RequestUtils.GET_CHAT_MESSAGE_REST_CALL
    url = url.."?competitionId="..mCompetitionId.."&last="..last
    if RequestUtils.USE_DEV then
        url = url.."&useDev=true"
    end

    local requestInfo = {}
    requestInfo.requestData = requestContentText
    requestInfo.url = url

     local handler = function( isSucceed, body, header, status, errorBuffer )
        RequestUtils.messageHandler( requestInfo, isSucceed, body, header, status, errorBuffer, RequestUtils.HTTP_200, onRequestSuccess )
    end

    local httpRequest = HttpRequestForLua:create( CCHttpRequest.kHttpGet )
    httpRequest:addHeader( Logic:getAuthSessionString() )
    httpRequest:sendHttpRequest( url, handler )

    ConnectingMessage.loadFrame()
end

function onRequestSuccess( jsonResponse )
    local ChatMessages = require("scripts.data.ChatMessages").ChatMessages

    local chatMessages = ChatMessages:new()
    for k,v in pairs( jsonResponse ) do
        chatMessages:addMessage( v )
    end

    -- Get the time stamp for the last message.
    local lastMessage = jsonResponse[table.getn( jsonResponse )]
    Logic:setLastChatMessageTimestamp( lastMessage["UnixTimeStamp"] )

    -- Display the messages.
    local ChatScene = require("scripts.views.CompetitionChatScene")
    if ChatScene.isFrameShown() then
        ChatScene.addMessage( chatMessages )
    else
        ChatScene.loadFrame( mCompetitionId, chatMessages )
    end
end