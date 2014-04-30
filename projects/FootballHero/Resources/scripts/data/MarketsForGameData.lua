module(..., package.seeall)

local MarketConfig = require("scripts.config.Market")

MarketsForGameData = {}

--[[
[
    {
        "marketTypeId": 25,
        "Line": null,
        "odds": [
            {
                "Id": 2303086,
                "Odd": 4,
                "OutcomeUIPosition": 1
            },
            {
                "Id": 2303100,
                "Odd": 1.83,
                "OutcomeUIPosition": 2
            }
        ]
    },
    {
        "marketTypeId": 26,
        "Line": 2.5,
        "odds": [
            {
                "Id": 2303110,
                "Odd": 1.7,
                "OutcomeUIPosition": 1
            },
            {
                "Id": 2303116,
                "Odd": 2.1,
                "OutcomeUIPosition": 2
            }
        ]
    },
    {
        "marketTypeId": 27,
        "Line": 0.5,
        "odds": [
            {
                "Id": 2397661,
                "Odd": 2.02,
                "OutcomeUIPosition": 1
            },
            {
                "Id": 2397666,
                "Odd": 1.86,
                "OutcomeUIPosition": 2
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
		table.remove( list, matchIndex )
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

function getMarketType( market )
    return market["marketTypeId"]
end

function getMarketLine( market )
    return market["Line"]
end

function getOddConfigForType( market, oddsType )
    for k, v in pairs( market["odds"] ) do
        local odds = v
        if odds["OutcomeUIPosition"] == oddsType then
            return odds
        end
    end
    return nil
end

function getOddIdForType( market, oddsType )
    local oddsConfig = getOddConfigForType( market, oddsType )
    
    if oddsConfig ~= nil then
        return oddsConfig["Id"]
    end
    return 0
end

function getOddsForType( market, oddsType )
	local oddsConfig = getOddConfigForType( market, oddsType )
	
	if oddsConfig ~= nil then
		return oddsConfig["Odd"] * 1000
	end
	return 0
end
