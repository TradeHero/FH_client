module(..., package.seeall)

local Constants = require("scripts.Constants")

SHARE_COMPETITION = "competition"
SHARE_SPINTHEWHEEL = "spinTheWheel"
SHARE_PREDICTION = "prediction"


ShareContent = {
	{	["id"] = SHARE_COMPETITION, 
		["content"] = Constants.String.share.competition_content,
		["image"] = "http://fhmainstorage.blob.core.windows.net/fhres/facebook-share-1.png",
		["title"] = Constants.String.football_hero,
		["description"] = Constants.String.football_hero,
		["url"] = "http://www.footballheroapp.com/download",
		["type"] = C2DXContentTypeNews,
		["siteUrl"] = "http://www.footballheroapp.com",
		["site"] = Constants.String.football_hero,
		["extInfo"] = "extInfo",
	},
	
	{	["id"] = SHARE_SPINTHEWHEEL, 
		["content"] = Constants.String.share.spinTheWheel_content,
		["image"] = "http://fhmainstorage.blob.core.windows.net/fhres/spin-the-wheel-1200x650.png",
		["title"] = Constants.String.football_hero,
		["description"] = Constants.String.football_hero,
		["url"] = "http://www.footballheroapp.com/download",
		["type"] = C2DXContentTypeNews,
		["siteUrl"] = "http://www.footballheroapp.com",
		["site"] = Constants.String.football_hero, 
		["extInfo"] = "extInfo",
	},

	{	["id"] = SHARE_PREDICTION, 
		["content"] = Constants.String.share.prediction_content,
		["image"] = "http://fhmainstorage.blob.core.windows.net/fhres/facebook-share-1.png",
		["title"] = Constants.String.football_hero,
		["description"] = Constants.String.football_hero,
		["url"] = "http://www.footballheroapp.com/download",
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