module(..., package.seeall)

local MarketConfig = require("scripts.config.Market")

MarketsForGameData = {}

--[[
[
    {
        "marketTypeId": 25,
        "odds": [
            {
                "Id": 2273377,
                "Odd": 2.91,
                "OutcomeName": "1",
                "Line": null
            },
            {
                "Id": 2273383,
                "Odd": 3.45,
                "OutcomeName": "x",
                "Line": null
            },
            {
                "Id": 2273388,
                "Odd": 2.41,
                "OutcomeName": "2",
                "Line": null
            }
        ]
    },
    {
        "marketTypeId": 26,
        "odds": [
            {
                "Id": 2273395,
                "Odd": 1.75,
                "OutcomeName": "over",
                "Line": 2.5
            },
            {
                "Id": 2273403,
                "Odd": 2.08,
                "OutcomeName": "under",
                "Line": 2.5
            }
        ]
    },
    {
        "marketTypeId": 27,
        "odds": [
            {
                "Id": 2273470,
                "Odd": 2.11,
                "OutcomeName": "home",
                "Line": 0
            },
            {
                "Id": 2273485,
                "Odd": 1.8,
                "OutcomeName": "away",
                "Line": 0
            }
        ]
    }
]
--]]

function MarketsForGameData:new( list )
	local match = nil
	local matchIndex = 0
	for k, v in pairs( list ) do
		local market = v
		if market["marketTypeId"] == MarketConfig.MARKET_TYPE_MATCH then
			match = market
			matchIndex = k
		end
	end
	if match ~= nil then
		table.remove( list, k )
	end

	local obj = {
		matchMarket = match,
		marketList = list
	}

	setmetatable(obj, self)
    self.__index = self
    
    obj.__newindex = function(t, k, v) assert(false, "MatchListData--"..k .. "__newindex not exist") end
    
    return obj 
end

function MarketsForGameData:getMatchMarket()
	return self.matchMarket
end

function MarketsForGameData:getNum()
	return table.getn( self.marketList )
end

function MarketsForGameData:getMarketAt( index )
	return self.marketList[index]
end

-- Getters for inner data structure
function getOddsForType( market, oddsType )
	local oddsConfig = nil 
	for k, v in pairs( market["odds"] ) do
		local odds = v
		if odds["OutcomeName"] == oddsType then
			oddsConfig = v
		end
	end
	
	if oddsConfig ~= nil then
		return oddsConfig["Odd"] * 1000
	end
	return 0
end