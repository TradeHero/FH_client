module(..., package.seeall)

local Json = require("json")
local LeagueChat = require("scripts.config.LeagueChat")
local LeagueChatConfig = LeagueChat.LeagueChatType
local FileUtils = require("scripts.FileUtils")

local FILE = "quickblox.txt"
local INFO_ROOMID = "roomid"
local INFO_TIMESTAMP = "timestamp"


function action( param )
	local command = param[1]
	local roomId = param[2]
	local timeStamp = param[3]

	if command == "Save" then
		local chatConfig = LeagueChat.getChatConfigByQuickbloxId( roomId )
	    if chatConfig then
	    	
	    	if chatConfig["lastMessageTime"] < timeStamp then	
	    		chatConfig["lastMessageTime"] = timeStamp

	    		writeToFile()
	    	end
	    end
	elseif command == "Load" then
		loadFromFile()
	end
end

function writeToFile()
	local lastMessageInfo = {}
	for i = 1, table.getn( LeagueChatConfig ) do
		local chatConfig = LeagueChatConfig[i]
		if chatConfig["useQuickBlox"] then
			lastMessageInfo[ chatConfig["quickBloxID"] ] = chatConfig["lastMessageTime"]
		end
	end

	FileUtils.writeStringToFile( FILE, Json.encode( lastMessageInfo ) )
end

function loadFromFile()
	local savedContent = FileUtils.readStringFromFile( FILE )
	if savedContent then
		local lastMessageInfo = Json.decode( savedContent )
		for k , v in pairs( lastMessageInfo ) do
			local chatConfig = LeagueChat.getChatConfigByQuickbloxId( k )
			if chatConfig then
				chatConfig["lastMessageTime"] = v
			end
		end
	end
end