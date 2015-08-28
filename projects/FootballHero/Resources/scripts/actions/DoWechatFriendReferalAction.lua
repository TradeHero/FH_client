module(..., package.seeall)

local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local ConnectingMessage = require("scripts.views.ConnectingMessage")
local ShareConfig = require("scripts.config.Share")


function action( param )
	ConnectingMessage.loadFrame()

	local shareContent = ShareConfig.getContentDictionaryById( ShareConfig.INVITE_WECHAT )
	C2DXShareSDK:shareContent( C2DXPlatTypeWeixiSession, shareContent, shareHandler )
end


function shareHandler( state, platType, errorMsg )

	local delayedTask = function()
		if state == C2DXResponseStateSuccess then
			CCLuaLog("Share Success with: "..platType)
			EventManager:postEvent( Event.Do_Friend_Referal_Success, { 3 } )

		elseif state == C2DXResponseStateFail then
			CCLuaLog("Share failed.")
			EventManager:postEvent( Event.Show_Error_Message, { errorMsg } )
		end	

		ConnectingMessage.selfRemove()
	end

	EventManager:scheduledExecutor( delayedTask, 0.1 )
end