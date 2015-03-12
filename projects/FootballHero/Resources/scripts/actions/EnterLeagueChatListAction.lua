module(..., package.seeall)

local Json = require("json")
local Constants = require("scripts.Constants")
local ConnectingMessage = require("scripts.views.ConnectingMessage")
local Logic = require("scripts.Logic").getInstance()
local RequestUtils = require("scripts.RequestUtils")
local LeagueChat = require("scripts.config.LeagueChat")
local LeagueChatConfig = LeagueChat.LeagueChatType


--[[
	Response ds

	{
    "total_entries": 2,
    "skip": 0,
    "limit": 100,
    "items": [
        {
            "_id": "54feb61c535c120b70010dee",
            "created_at": "2015-03-10T09:15:08Z",
            "last_message": "nshshd",
            "last_message_date_sent": 1426067832,
            "last_message_user_id": 2491167,
            "name": "Spanish Chat",
            "occupants_ids": [],
            "photo": "",
            "type": 1,
            "user_id": 2243222,
            "xmpp_room_jid": "20587_54feb61c535c120b70010dee@muc.chat.quickblox.com",
            "unread_messages_count": 0
        },
        {
            "_id": "54feb614535c12834e08647b",
            "created_at": "2015-03-10T09:15:00Z",
            "last_message": "hdbdgdh",
            "last_message_date_sent": 1426067795,
            "last_message_user_id": 2491167,
            "name": "English Chat",
            "occupants_ids": [],
            "photo": "",
            "type": 1,
            "user_id": 2243222,
            "xmpp_room_jid": "20587_54feb614535c12834e08647b@muc.chat.quickblox.com",
            "unread_messages_count": 0
        }
    ]
}

--]]

local mUnreadMessageCountInfo = {}		-- { quickbloxRoomId: unreadMessageCount }

function action( param )

	getUnreadMessageCount( 1 )

    ConnectingMessage.loadFrame()
end

function getUnreadMessageCount( index )
	if index > table.getn( LeagueChatConfig ) then
		ConnectingMessage.selfRemove()
		compelte()
	else
		local chatConfig = LeagueChatConfig[index]
		if chatConfig["useQuickBlox"] then
			local requestContent = {}
		    local requestContentText = Json.encode( requestContent )
		    
		    local roomId = chatConfig["quickBloxID"]
		    local lastMessageTimeStamp = chatConfig["lastMessageTime"]

		    local url = "https://api.quickblox.com/chat/Message.json?chat_dialog_id="..roomId.."&count=1&date_sent[gt]="..lastMessageTimeStamp

		    local requestInfo = {}
		    requestInfo.requestData = requestContentText
		    requestInfo.url = url

		    function onRequestSuccess( jsonResponse )
				local config = jsonResponse["items"]
				mUnreadMessageCountInfo[chatConfig["quickBloxID"]] = config["count"]

			    index =  index + 1
				getUnreadMessageCount( index )
			end

		    local handler = function( isSucceed, body, header, status, errorBuffer )
		        RequestUtils.messageHandler( requestInfo, isSucceed, body, header, status, errorBuffer, RequestUtils.HTTP_200, false, onRequestSuccess )
		    end

		    local httpRequest = HttpRequestForLua:create( CCHttpRequest.kHttpGet )
		    httpRequest:addHeader( Logic:getQuickbloxSessionString() )
		    httpRequest:sendHttpRequest( url, handler )
		else
			index =  index + 1
			getUnreadMessageCount( index )
		end
	end
end

function compelte()
	local LeagueChatListScene = require("scripts.views.LeagueChatListScene")
	
	if LeagueChatListScene.isFrameShown() then
		LeagueChatListScene.reloadFrame( mUnreadMessageCountInfo )
	else
    	LeagueChatListScene.loadFrame( mUnreadMessageCountInfo )
    end
end