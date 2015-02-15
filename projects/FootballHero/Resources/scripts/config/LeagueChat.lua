module(..., package.seeall)

local Constants = require("scripts.Constants")
local QuickBloxUsers = require("scripts.data.QuickBloxUsers")
local ChatMessages = require("scripts.data.ChatMessages").ChatMessages

LeagueChatType = {
	{
		["labelName"] = "Label_English", 
		["buttonName"] = "Button_English", 
		["displayNameKey"] = "english", 
		["logo"] = Constants.CHAT_IMAGE_PATH.."icn-england-logo.png", 
		["chatRoomId"] = "global-english",
		["color"] = ccc3( 29, 49, 141 ),
		["useQuickBlox"] = true,
		["quickBloxJID"] = "18975_54c88072535c12629c025a37@muc.chat.quickblox.com",
		["quickBloxID"] = "54c88072535c12629c025a37",
	},
	{
		["labelName"] = "Label_Spanish", 
		["buttonName"] = "Button_Spanish", 
		["displayNameKey"] = "spanish", 
		["logo"] = Constants.CHAT_IMAGE_PATH.."icn-spanish-logo.png", 
		["chatRoomId"] = "global-spanish",
		["color"] = ccc3( 35, 91, 28 ),
		["useQuickBlox"] = false,
	},
	{
		["labelName"] = "Label_Italian", 
		["buttonName"] = "Button_Italian", 
		["displayNameKey"] = "italian", 
		["logo"] = Constants.CHAT_IMAGE_PATH.."icn-italian-logo.png", 
		["chatRoomId"] = "global-italian",
		["color"] = ccc3( 193, 3, 5 ),
		["useQuickBlox"] = false,
	},
	{
		["labelName"] = "Label_German", 
		["buttonName"] = "Button_German", 
		["displayNameKey"] = "german", 
		["logo"] = Constants.CHAT_IMAGE_PATH.."icn-german-logo.png", 
		["chatRoomId"] = "global-german",
		["color"] = ccc3( 197, 187, 11 ),
		["useQuickBlox"] = false,
	},
	{
		["labelName"] = "Label_Uefa", 
		["buttonName"] = "Button_Uefa", 
		["displayNameKey"] = "uefa", 
		["logo"] = Constants.CHAT_IMAGE_PATH.."icn-uefa-logo.png", 
		["chatRoomId"] = "global-uefa",
		["color"] = ccc3( 12, 121, 149 ),
		["useQuickBlox"] = false,
	},
	{
		["labelName"] = "Label_Others", 
		["buttonName"] = "Button_Others", 
		["displayNameKey"] = "others", 
		["logo"] = Constants.CHAT_IMAGE_PATH.."icn-misc-logo.png", 
		["chatRoomId"] = "global-others",
		["color"] = ccc3( 137, 10, 108 ),
		["useQuickBlox"] = false,
	},
	{
		["labelName"] = "Label_Feedback", 
		["buttonName"] = "Button_Feedback", 
		["displayNameKey"] = "feedback", 
		["logo"] = Constants.CHAT_IMAGE_PATH.."icn-feedback-logo.png", 
		["chatRoomId"] = "global-feedback",
		["color"] = ccc3( 153, 160, 171 ),
		["useQuickBlox"] = false,
	},
}

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
    	message["UserId"] = quickBloxUser["external_user_id"]
    	message["UserName"] =  quickBloxUser["login"]
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