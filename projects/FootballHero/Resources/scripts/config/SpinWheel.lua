module(..., package.seeall)

local Constants = require("scripts.Constants")
local RequestUtils = require("scripts.RequestUtils")

--[[
 Data structure

 {
   "Prices": [
      {
         "Id": 1,
         "Name": "3000 Points",
         "ImageUrl": "http://fhmainstorage.blob.core.windows.net/wheelres/img-point.png",
		 "LocalUrl": "......"
         "DrawTicket": false
      },
   ],
   "Order": [
           1, 2, 1, 3
   ]
}
--]]

local mInit = false
local mPrizeConfig = {}
local mPrizeOrder = {}
local mLuckDrawPrizeId
local mLuckDrawPrizeDescription

function isInit()
	return mInit
end

function init( prizeConfig, prizeOrder )
	mPrizeConfig = prizeConfig
	mPrizeOrder = prizeOrder
	mInit = true
	for i = 1, table.getn( prizeConfig ) do
		local config = prizeConfig[i]
		if config["DrawTicket"] then
			mLuckDrawPrizeId = i
			mLuckDrawPrizeDescription = config["DrawInformation"]
		end
	end
end

function getPrizeOrder()
	return mPrizeOrder
end

function getPrizeConfigWithID( id )
	for i = 1 , table.getn( mPrizeConfig ) do
		local prizeConfig = mPrizeConfig[i]
		if prizeConfig["Id"] == id then
			return prizeConfig
		end
	end

	return nil
end

function isLuckDrawPrizeId( id )
	return mLuckDrawPrizeId == id
end

function getLuckDrawDescription()
	return mLuckDrawPrizeDescription
end

function getStopAngleByPrizeID( prizeID )
	local prizesWithThisID = {}
	for i = 1, table.getn( mPrizeOrder ) do
		local prize = mPrizeOrder[i]
		if prize == prizeID then
			table.insert( prizesWithThisID, i )
		end
	end

	local selectedPrize
	if table.getn( prizesWithThisID ) > 1 then
		local randomIndex = math.random( table.getn( prizesWithThisID ) )
		selectedPrize = prizesWithThisID[randomIndex]
	else
		selectedPrize = prizesWithThisID[1]
	end

	local range = 360 / 13
	local borderWidth = 2

	return ( selectedPrize - 1 ) * range + borderWidth + math.random( range - borderWidth * 2 )
end