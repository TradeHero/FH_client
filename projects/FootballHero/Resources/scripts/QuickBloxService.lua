module(..., package.seeall)

local LeagueChatConfig = require("scripts.config.LeagueChat").LeagueChatType
local QuickBloxUsers = require("scripts.data.QuickBloxUsers")
local ChatMessages = require("scripts.data.ChatMessages").ChatMessages

local mQuickBloxChatEnabled

function login(displayName, pictureUrl, userId, callback)
	if isQuickBloxEnabled() then
		QuickBloxChat:sharedDelegate():login( displayName, pictureUrl, userId, callback )
	end
end

function logout()
	if isQuickBloxEnabled() then
		QuickBloxChat:sharedDelegate():logout()
	end
end

function sendMessage( message )
	if isQuickBloxEnabled() then
		QuickBloxChat:sharedDelegate():sendMessage( message )
	end
end

function joinChatRoom( chatRoomJID, callback )
	if isQuickBloxEnabled() then
		QuickBloxChat:sharedDelegate():joinChatRoom( chatRoomJID, callback )
	end
end

function leaveChatRoom( callback )
	if isQuickBloxEnabled() then
		QuickBloxChat:sharedDelegate():leaveChatRoom( callback )
	else
		callback()
	end
end

function setNewMessageHandler( handler )
	if isQuickBloxEnabled() then
		QuickBloxChat:sharedDelegate():setNewMessageHandler( handler )
	end
end


function init()
	mQuickBloxChatEnabled = false

	for k,v in pairs( LeagueChatConfig ) do
		if v["useQuickBlox"] then
			mQuickBloxChatEnabled = true
			break
		end
	end
	if mQuickBloxChatEnabled then
		CCLuaLog("QuickBlox enabled.")
	else
		CCLuaLog("QuickBlox disabled.")
	end
end

function isQuickBloxEnabled()
	return mQuickBloxChatEnabled
end

function createChatMessagesWithData( sender, text, timeStamp )
	local oneMessage = {}
	oneMessage["sender_id"] = tonumber( sender )
	oneMessage["message"] = text
	oneMessage["date_sent"] = timeStamp

	return createChatMessages( { oneMessage } )
end

function createChatMessages( messages )
    table.sort( messages, function ( n1, n2 )
        if n1["date_sent"] < n2["date_sent"] then
            return true
        else
            return false
        end
    end )

    local chatMessages = ChatMessages:new()
    for k,v in pairs( messages ) do
        chatMessages:addMessage( helperMappingtoChatMessage( v ) )
    end

    return chatMessages
end

function helperMappingtoChatMessage( quickbloxMessage )
    local message = {}

    local quickBloxUser = QuickBloxUsers.getUserById( quickbloxMessage["sender_id"] )
    if quickBloxUser then
    	message["UserId"] = quickBloxUser["login"]
    	message["UserName"] =  quickBloxUser["full_name"]
    	message["PictureUrl"] = quickBloxUser["website"]
    else
    	message["UserId"] = quickbloxMessage["sender_id"]
    	message["UserName"] =  quickbloxMessage["sender_id"]
    	message["PictureUrl"] = nil
    end
    
    message["MessageText"] = quickbloxMessage["message"]
    message["UnixTimeStamp"] = quickbloxMessage["date_sent"]

    return message
end

init()