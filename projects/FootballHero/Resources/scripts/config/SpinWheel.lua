module(..., package.seeall)

local Constants = require("scripts.Constants")
local RequestUtils = require("scripts.RequestUtils")

--[[
 Data structure

 {
   "LastSpinUtc": 1421135692,
   "Email": null,
   "PrizeInformation": {
      "Prizes": [
         {
            "Id": 1,
            "Name": "+3,000 POINTS",
            "ImageUrl": "http://fhmainstorage.blob.core.windows.net/wheelres/img-point.png",
            "DrawTicket": false,
            "DrawInformation": null
         },
         {
            "Id": 2,
            "Name": "+8,000 POINTS",
            "ImageUrl": "http://fhmainstorage.blob.core.windows.net/wheelres/img-point.png",
            "DrawTicket": false,
            "DrawInformation": null
         },
         {
            "Id": 3,
            "Name": "+12,000 POINTS",
            "ImageUrl": "http://fhmainstorage.blob.core.windows.net/wheelres/img-point.png",
            "DrawTicket": false,
            "DrawInformation": null
         },
         {
            "Id": 4,
            "Name": "US$ 1.00",
            "ImageUrl": "http://fhmainstorage.blob.core.windows.net/wheelres/img-cash.png",
            "DrawTicket": false,
            "DrawInformation": null
         },
         {
            "Id": 5,
            "Name": "US$ 2.00",
            "ImageUrl": "http://fhmainstorage.blob.core.windows.net/wheelres/img-cash.png",
            "DrawTicket": false,
            "DrawInformation": null
         },
         {
            "Id": 6,
            "Name": "US$ 5.00",
            "ImageUrl": "http://fhmainstorage.blob.core.windows.net/wheelres/img-cash.png",
            "DrawTicket": false,
            "DrawInformation": null
         },
         {
            "Id": 8,
            "Name": "Xiaomi Phone",
            "ImageUrl": "http://fhmainstorage.blob.core.windows.net/wheelres/img-xiaomi.png",
            "DrawTicket": false,
            "DrawInformation": null
         },
         {
            "Id": 10,
            "Name": "Lucky Draw Messi Signed Jersey",
            "ImageUrl": "http://fhmainstorage.blob.core.windows.net/wheelres/img-messi.png",
            "DrawTicket": true,
            "DrawInformation": "One Messi Signed Jersey awarded every 3500 tickets"
         },
         {
            "Id": 13,
            "Name": "Ronaldo Signed Jersey",
            "ImageUrl": "http://fhmainstorage.blob.core.windows.net/wheelres/img-ronaldo.png",
            "DrawTicket": false,
            "DrawInformation": null
         }
      ],
      "Order": [
         1,
         4,
         1,
         10,
         5,
         1,
         8,
         6,
         1,
         13,
         2,
         1,
         3
      ]
   }
}
--]]

-- TODO remove the below hard code these two prizes.
PRIZE_XIAOMI = 8
PIRZE_JERSEY = 13

local mInit = false
local mPrizeConfig = {}
local mPrizeOrder = {}
local mLastSpinTime
local mContactEmail
local mLuckDrawPrizeId
local mLuckDrawPrizeDescription

function isInit()
	return mInit
end

function init( spinWheelConfig )
	mLastSpinTime = spinWheelConfig["LastSpinUtc"]
	mContactEmail = spinWheelConfig["Email"]
	if type( mContactEmail ) == "userdata" then
		mContactEmail = nil
	end

	local prizeInfo = spinWheelConfig["PrizeInformation"]

	mPrizeConfig = prizeInfo["Prizes"]
	mPrizeOrder = prizeInfo["Order"]
	mInit = true
	for i = 1, table.getn( mPrizeConfig ) do
		local config = mPrizeConfig[i]
		if config["DrawTicket"] then
			mLuckDrawPrizeId = config["Id"]
			mLuckDrawPrizeDescription = config["DrawInformation"]
			CCLuaLog("Lucky draw prize id "..mLuckDrawPrizeId.." : "..mLuckDrawPrizeDescription)
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

function getContactEmail()
	return mContactEmail
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

	return ( selectedPrize - 1 ) * range + range / 2
end