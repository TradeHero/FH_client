module(..., package.seeall)

local Json = require("json")
local Constants = require("scripts.Constants")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local ConnectingMessage = require("scripts.views.ConnectingMessage")
local RequestUtils = require("scripts.RequestUtils")
local Logic = require("scripts.Logic").getInstance()
local LeagueChat = require("scripts.config.LeagueChat")
local LeagueChatConfig = LeagueChat.LeagueChatType
local QuickBloxUsers = require("scripts.data.QuickBloxUsers")
local QuickBloxService = require("scripts.QuickBloxService")

--[[

Data structure of the Quickblox messages.
{
    "skip": 0,
    "limit": 20,
    "items": [
        {
            "_id": "54d1edba00fcc9e5c4c104b7",
            "attachments": [],
            "chat_dialog_id": "54c88072535c12629c025a37",
            "created_at": "2015-02-04T10:00:28Z",
            "date_sent": 1423044026,
            "message": "mdbnfjdm",
            "recipient_id": null,
            "sender_id": 2277646,
            "updated_at": null,
            "read": 0
        },
        {
            "_id": "54d1edb700fcc9e5c4c104b6",
            "attachments": [],
            "chat_dialog_id": "54c88072535c12629c025a37",
            "created_at": "2015-02-04T10:00:24Z",
            "date_sent": 1423044023,
            "message": "yeah",
            "recipient_id": null,
            "sender_id": 2277646,
            "updated_at": null,
            "read": 0
        }
    ]
}

--]]

local mRoomId
local mChatMessages

function action( param )
    mRoomId = param[1]

    local requestContent = {}
    local requestContentText = Json.encode( requestContent )
    
    local url = "https://api.quickblox.com/chat/Message.json"
    url = url.."?chat_dialog_id="..mRoomId.."&limit=20&sort_desc=date_sent"

    local requestInfo = {}
    requestInfo.requestData = requestContentText
    requestInfo.url = url

     local handler = function( isSucceed, body, header, status, errorBuffer )
        RequestUtils.messageHandler( requestInfo, isSucceed, body, header, status, errorBuffer, RequestUtils.HTTP_200, true, onRequestSuccess )
    end

    local httpRequest = HttpRequestForLua:create( CCHttpRequest.kHttpGet )
    httpRequest:addHeader( Logic:getQuickbloxSessionString() )
    httpRequest:sendHttpRequest( url, handler )

    ConnectingMessage.loadFrame()
end

function onRequestSuccess( jsonResponse )
    CCLuaLog("Quickblox history.")
    local messages = jsonResponse["items"]
    mChatMessages = messages
    local unCachedUsers = ""
    for k,v in pairs( messages ) do
        local userId = v["sender_id"]
        if not QuickBloxUsers.hasUserById( userId ) then
            unCachedUsers = unCachedUsers..userId..","
        end
    end
    if string.len( unCachedUsers ) > 0 then
        unCachedUsers = unCachedUsers.."0"
        
        EventManager:postEvent( Event.Do_Get_Quickblox_Users, { unCachedUsers, showChatMessages } )
    else
        showChatMessages()
    end   
end

function showChatMessages()
    local ChatScene = require("scripts.views.LeagueChatScene")

    -- Display the messages. This function will sort the mChatMessages by time
    local chatMessages = QuickBloxService.createChatMessages( mChatMessages )

    -- Update the last received message's timestamp for this room.
    local lastChatMessage = mChatMessages[ table.getn( mChatMessages ) ]
    EventManager:postEvent( Event.Do_Quickblox_Last_Message, { "Save", mRoomId, lastChatMessage["date_sent"] } )

    ChatScene.initMessages( chatMessages )
end