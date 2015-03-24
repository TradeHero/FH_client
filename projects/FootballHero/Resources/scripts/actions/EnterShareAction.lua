module(..., package.seeall)

local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local Logic = require("scripts.Logic").getInstance()
local ShareConfig = require("scripts.config.Share")
local ConnectingMessage = require("scripts.views.ConnectingMessage")

--[[
	Share logic:
	1. Use ShareSDK to share, player could choose FB or Wechat. Or even cancel, if canceled, we will do nothing.
	2. If shared with Wechat, goto step 4. If shared with FB, goto step 3.
	3. If Logic:getFbId() does not exist, then we post Do_FB_Connect_With_User so that server can save it. If it is already exist, continue.
	4. Callback
--]]

local mCallback

function action( param )
	local shareId = param[1]
    mCallback = param[2]
    local shareStringParam = param[3]
    
    ConnectingMessage.loadFrame()
    local shareContent = ShareConfig.getContentDictionaryById( shareId )
    local shareStringFormat = shareContent:valueForKey("content"):getCString()
    local shareString = string.format( shareStringFormat, shareStringParam )
    shareContent:setObject( CCString:create( shareString ), "content" )
    C2DXShareSDK:showShareMenu( nil, shareContent, shareHandler )
end

function shareHandler( state, platType, errorMsg )
	if state == C2DXResponseStateSuccess then
		CCLuaLog("Share Success with: "..platType)

        -- Check and try bind the FB account with the current email account.
		if platType == C2DXPlatTypeFacebook and Logic:getFbId() == false then
			local handler = function()
	            -- Nothing to do.
	        end
            C2DXShareSDK:getCredentialWithType( C2DXPlatTypeFacebook, function( accessToken )
            	if accessToken then
            		EventManager:postEvent( Event.Do_FB_Connect_With_User, { accessToken, handler, handler } )
            	end
            end )
			
		end
	elseif state == C2DXResponseStateFail then
		CCLuaLog("Share failed.")
		EventManager:postEvent( Event.Show_Error_Message, { errorMsg } )
	end  

	ConnectingMessage.selfRemove()
    mCallback( state == C2DXResponseStateSuccess, platType )
end