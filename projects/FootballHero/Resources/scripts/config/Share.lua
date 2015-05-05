module(..., package.seeall)

local Constants = require("scripts.Constants")

SHARE_COMPETITION = "competition"
SHARE_SPINTHEWHEEL = "spinTheWheel"
SHARE_PREDICTION = "prediction"
SHARE_PREDRESULT = "predResult"
SHARE_VIDEO = "video"

SCREEN_SHOT = "ScreenShot"
PARAM_VALUE = "ParamValue"

ShareContent = {
	{	["id"] = SHARE_COMPETITION, 
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

	{	["id"] = SHARE_PREDICTION, 
		["content"] = Constants.String.share.prediction_content,
		["image"] = "http://fhmainstorage.blob.core.windows.net/fhres/facebook-share-1.png",
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