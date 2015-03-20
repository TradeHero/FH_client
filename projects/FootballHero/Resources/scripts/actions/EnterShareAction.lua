module(..., package.seeall)

local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local Logic = require("scripts.Logic").getInstance()


--[[
	Share logic:
	1. Use ShareSDK to share, player could choose FB or Wechat. Or even cancel, if canceled, we will do nothing.
	2. If shared with Wechat, goto step 4. If shared with FB, goto step 3.
	3. If Logic:getFbId() does not exist, then we post Do_FB_Connect_With_User so that server can save it. If it is already exist, continue.
	4. Callback
--]]

local mCallback

function action( param )
    mCallback = param[1]

    local content = CCDictionary:create()
    content:setObject( CCString:create("I have won a prize in FootballHero Spin-The-Wheel game! Download now for a chance to win Messi & Ronaldo Signed Jerseys!"), "content")
    content:setObject( CCString:create("https://fbexternal-a.akamaihd.net/safe_image.php?d=AQDUZiW0WQBqnF67&w=487&h=255&url=http%3A%2F%2Ffhmainstorage.blob.core.windows.net%2Ffhres%2Fspin-the-wheel-1200x650.png&cfs=1&upscale=1"), "image")
    content:setObject( CCString:create("Football Hero"), "title")
    content:setObject( CCString:create("Football Hero"), "description")
    content:setObject( CCString:create("http://www.footballheroapp.com/download"), "url")
    content:setObject( CCString:create( C2DXContentTypeNews ), "type")
    content:setObject( CCString:create("http://www.footballheroapp.com"), "siteUrl")
    content:setObject( CCString:create("FootballHero"), "site")
    content:setObject( CCString:create("extInfo"), "extInfo")
    
    C2DXShareSDK:showShareMenu( nil, content, shareHandler )
end

function shareHandler( success, platType )
	if success then
		CCLuaLog("Share Success with: "..platType)

        -- Check and try bind the FB account with the current email account.
		if platType == C2DXPlatTypeFacebook and Logic:getFbId() == false then
			local handler = function()
	            -- Nothing to do.
	        end
            local accessToken = C2DXShareSDK:getCredentialWithType( C2DXPlatTypeFacebook )
			EventManager:postEvent( Event.Do_FB_Connect_With_User, { accessToken, handler, handler } )
		end
	else
		CCLuaLog("Share failed.")
	end  

    mCallback( success, platType )
end