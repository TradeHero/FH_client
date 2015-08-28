module(..., package.seeall)

local Constants = require("scripts.Constants")

SHARE_COMPETITION = "competition"
SHARE_SPINTHEWHEEL = "spinTheWheel"
SHARE_PREDICTION = "prediction"
SHARE_PREDRESULT = "predResult"
SHARE_VIDEO = "video"
INVITE_WECHAT = "inviteWechat"
INVITE_FACEBOOK = "inviteFacebook"

SCREEN_SHOT = "ScreenShot"
PARAM_VALUE = "ParamValue"

ShareContent = {
	{	["id"] = SHARE_COMPETITION.."fhchamp", 
		["content"] = Constants.String.share.competition_content,
		["image"] = "http://fhmainstorage.blob.core.windows.net/fhres/facebook-share-1.png",
		["title"] = Constants.String.share.competition_title,
		["description"] = Constants.String.football_hero,
		["url"] = "http://www.footballheroapp.com",
		["type"] = C2DXContentTypeNews,
		["siteUrl"] = "http://www.footballheroapp.com",
		["site"] = Constants.String.football_hero,
		["extInfo"] = "extInfo",
	},

	{	["id"] = SHARE_COMPETITION.."fhc1516", 
		["content"] = Constants.String.share.competition_content,
		["image"] = "http://fhmainstorage.blob.core.windows.net/fhres/facebook-share-1.png",
		["title"] = Constants.String.share.competition_title,
		["description"] = Constants.String.football_hero,
		["url"] = "http://www.footballheroapp.com",
		["type"] = C2DXContentTypeNews,
		["siteUrl"] = "http://www.footballheroapp.com",
		["site"] = Constants.String.football_hero,
		["extInfo"] = "extInfo",
	},

	{	["id"] = SHARE_COMPETITION.."seacup15", 
		["content"] = Constants.String.share.competition_seacup15_content,
		["image"] = "http://fhmainstorage.blob.core.windows.net/fhres/fb-share-seacup.png",
		["title"] = Constants.String.share.competition_title,
		["description"] = Constants.String.football_hero,
		["url"] = "http://www.footballheroapp.com",
		["type"] = C2DXContentTypeNews,
		["siteUrl"] = "http://www.footballheroapp.com",
		["site"] = Constants.String.football_hero,
		["extInfo"] = "extInfo",
	},
	
	{	["id"] = SHARE_COMPETITION.."americacup15", 
		["content"] = Constants.String.share.competition_americacup15_content,
		["image"] = "http://fhmainstorage.blob.core.windows.net/fhres/fb-share-copa.png",
		["title"] = Constants.String.share.competition_title,
		["description"] = Constants.String.football_hero,
		["url"] = "http://www.footballheroapp.com",
		["type"] = C2DXContentTypeNews,
		["siteUrl"] = "http://www.footballheroapp.com",
		["site"] = Constants.String.football_hero,
		["extInfo"] = "extInfo",
	},

	{	["id"] = SHARE_SPINTHEWHEEL, 
		["content"] = Constants.String.share.spinTheWheel_content,
		["image"] = "http://fhmainstorage.blob.core.windows.net/fhres/spin-the-wheel-1200x650.png",
		["title"] = Constants.String.share.spinTheWheel_title,
		["description"] = Constants.String.football_hero,
		["url"] = "http://www.footballheroapp.com",
		["type"] = C2DXContentTypeNews,
		["siteUrl"] = "http://www.footballheroapp.com",
		["site"] = Constants.String.football_hero, 
		["extInfo"] = "extInfo",
	},

	{	["id"] = SHARE_PREDICTION.."_football", 
		["content"] = Constants.String.share.prediction_football_content,
		["image"] = "http://fhmainstorage.blob.core.windows.net/fhres/facebook-share-1.png",
		["title"] = Constants.String.share.prediction_title,
		["description"] = Constants.String.football_hero,
		["url"] = "http://www.footballheroapp.com",
		["type"] = C2DXContentTypeNews,
		["siteUrl"] = "http://www.footballheroapp.com",
		["site"] = Constants.String.football_hero,
		["extInfo"] = "extInfo",
	},

	{	["id"] = SHARE_PREDICTION.."_baseball", 
		["content"] = Constants.String.share.prediction_baseball_content,
		["image"] = "http://fhmainstorage.blob.core.windows.net/fhres/baseball-fb-share.png",
		["title"] = Constants.String.share.prediction_title,
		["description"] = Constants.String.football_hero,
		["url"] = "http://www.footballheroapp.com",
		["type"] = C2DXContentTypeNews,
		["siteUrl"] = "http://www.footballheroapp.com",
		["site"] = Constants.String.football_hero,
		["extInfo"] = "extInfo",
	},

	{	["id"] = SHARE_PREDRESULT, 
		["content"] = Constants.String.share.predResult_content,
		["image"] = SCREEN_SHOT,
		["title"] = Constants.String.share.predResult_title,
		["description"] = Constants.String.football_hero,
		["url"] = "http://www.footballheroapp.com",
		["type"] = C2DXContentTypeNews,
		["siteUrl"] = "http://www.footballheroapp.com",
		["site"] = Constants.String.football_hero,
		["extInfo"] = "extInfo",
	},

	{	["id"] = SHARE_VIDEO, 
		["content"] = Constants.String.share.video_content,
		["image"] = PARAM_VALUE,
		["title"] = Constants.String.share.video_title,
		["description"] = Constants.String.football_hero,
		["url"] = "http://www.footballheroapp.com",
		["type"] = C2DXContentTypeNews,
		["siteUrl"] = "http://www.footballheroapp.com",
		["site"] = Constants.String.football_hero,
		["extInfo"] = "extInfo",
	},

	{	["id"] = INVITE_WECHAT, 
		["content"] = Constants.String.share.wechat_content,
		["image"] = "http://fhmainstorage.blob.core.windows.net/fhres/facebook-share-1.png",
		["title"] = Constants.String.share.wechat_title,
		["description"] = Constants.String.football_hero,
		["url"] = "http://www.footballheroapp.com",
		["type"] = C2DXContentTypeApp,
		["siteUrl"] = "http://www.footballheroapp.com",
		["site"] = Constants.String.football_hero,
		["extInfo"] = "extInfo",
	},
}

function getContentDictionaryById( id )
	local config = nil
	for i = 1, table.getn( ShareContent ) do
		if ShareContent[i]["id"] == id then
			config = ShareContent[i]
			break
		end
	end

	if config then
		local content = CCDictionary:create()
    	for k, v in pairs( config ) do
    		content:setObject( CCString:create( v ), k )
    	end

    	return content
	else
		return nil
	end
	
end