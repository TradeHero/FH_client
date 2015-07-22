module(..., package.seeall)

local Constants = require("scripts.Constants")

LeagueChatType = {
	{
		["buttonName"] = "Button_English", 
		["displayNameKey"] = "group_chat", 
		["chatRoomId"] = "global-english",
		["color"] = ccc3( 29, 49, 141 ),
		["useQuickBlox"] = true,
		--["quickBloxJID"] = "18975_54c88072535c12629c025a37@muc.chat.quickblox.com",
		--["quickBloxID"] = "54c88072535c12629c025a37",
		["quickBloxJID"] = "20587_54feb614535c12834e08647b@muc.chat.quickblox.com",
		["quickBloxID"] = "54feb614535c12834e08647b",
		["lastMessageTime"] = 0,
	},
	{
		["buttonName"] = "Button_Bahasa", 
		["displayNameKey"] = "bahasa_chat", 
		["chatRoomId"] = "global-spanish",
		["color"] = ccc3( 35, 91, 28 ),
		["useQuickBlox"] = true,
		--["quickBloxJID"] = "18975_54c89dbf535c1223b2026b25@muc.chat.quickblox.com",
		--["quickBloxID"] = "54c89dbf535c1223b2026b25",
		["quickBloxJID"] = "20587_54feb61c535c120b70010dee@muc.chat.quickblox.com",
		["quickBloxID"] = "54feb61c535c120b70010dee",
		["lastMessageTime"] = 0,
	},
	{
		["buttonName"] = "Button_Thai", 
		["displayNameKey"] = "thai_chat", 
		["chatRoomId"] = "global-italian",
		["color"] = ccc3( 193, 3, 5 ),
		["useQuickBlox"] = true,
		["quickBloxJID"] = "20587_552379b9535c123fc5105765@muc.chat.quickblox.com",
		["quickBloxID"] = "552379b9535c123fc5105765",
		["lastMessageTime"] = 0,
	},
	{
		["buttonName"] = "Button_Chinese", 
		["displayNameKey"] = "chinese_chat", 
		["chatRoomId"] = "global-german",
		["color"] = ccc3( 197, 187, 11 ),
		["useQuickBlox"] = true,
		["quickBloxJID"] = "20587_552379c0535c123fc5105771@muc.chat.quickblox.com",
		["quickBloxID"] = "552379c0535c123fc5105771",
		["lastMessageTime"] = 0,
	},
	{
		["buttonName"] = "Button_Arabic", 
		["displayNameKey"] = "arabic_chat", 
		["chatRoomId"] = "global-uefa",
		["color"] = ccc3( 12, 121, 149 ),
		["useQuickBlox"] = true,
		["quickBloxJID"] = "20587_552379c7535c123fc510578d@muc.chat.quickblox.com",
		["quickBloxID"] = "552379c7535c123fc510578d",
		["lastMessageTime"] = 0,
	},
	{
		["buttonName"] = "Button_Football", 
		["displayNameKey"] = "football_chat", 
		["chatRoomId"] = "global-uefa",
		["color"] = ccc3( 12, 121, 149 ),
		["useQuickBlox"] = true,
		["quickBloxJID"] = "20587_55af47a4535c12268d0002bc@muc.chat.quickblox.com",
		["quickBloxID"] = "55af47a4535c12268d0002bc",
		["lastMessageTime"] = 0,
	},
	{
		["buttonName"] = "Button_Baseball", 
		["displayNameKey"] = "baseball_chat", 
		["chatRoomId"] = "global-others",
		["color"] = ccc3( 12, 121, 149 ),
		["useQuickBlox"] = true,
		["quickBloxJID"] = "20587_55af47ad535c12c4f0002515@muc.chat.quickblox.com",
		["quickBloxID"] = "55af47ad535c12c4f0002515",
		["lastMessageTime"] = 0,
	},
	{
		["buttonName"] = "Button_Feedback", 
		["displayNameKey"] = "feedback", 
		["chatRoomId"] = "global-others",
		["color"] = ccc3( 137, 10, 108 ),
		["useQuickBlox"] = true,
		["quickBloxJID"] = "20587_552379db535c12fc0b103ee5@muc.chat.quickblox.com",
		["quickBloxID"] = "552379db535c12fc0b103ee5",
		["lastMessageTime"] = 0,
	},
}

function getChatConfigByQuickbloxId( id )
	for i = 1, table.getn( LeagueChatType ) do
		local chatConfig = LeagueChatType[i]
		if chatConfig["useQuickBlox"] and chatConfig["quickBloxID"] == id then
			return chatConfig
		end
	end

	return nil
end