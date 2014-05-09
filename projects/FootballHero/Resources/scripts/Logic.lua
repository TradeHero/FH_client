module(..., package.seeall)

local Json = require("json")
local FileUtils = require("scripts.FileUtils")
local Coupons = require("scripts.data.Coupons").Coupons

-- Singleton of logic
local MATCH_PREDICTION = "matchPrediction"
local SCORE_PREDICTION = "scorePrediction"
local SUB_PREDICTION = "sub"
local instance

local ACCOUNT_INFO_FILE = "ai.txt"
local ACCOUNT_INFO_EMAIL = "email"
local ACCOUNT_INFO_PASSWORD = "password"
local ACCOUNT_INFO_SESSIONTOKEN = "sessionToken"

function getInstance()
	if instance == nil then
		instance = Logic:new()

		local savedAccountInfo = FileUtils.readStringFromFile( ACCOUNT_INFO_FILE )
		if string.len( savedAccountInfo ) > 0 then
			local accountInfo = Json.decode( savedAccountInfo )
			print( savedAccountInfo )
			instance:setUserInfo( accountInfo[ACCOUNT_INFO_EMAIL], accountInfo[ACCOUNT_INFO_PASSWORD], accountInfo[ACCOUNT_INFO_SESSIONTOKEN] )
		end
	end

	return instance
end

Logic = {}

function Logic:new()
	if instance ~= nil then
		assert( false )
		return instance
	end
	
	local obj = {
		mPoint = 5000,
		mSelectedMatch = nil,	--DS: see MatchListData
		mCurDisplayMarketIndex = 0,
		mCurMarketInfo = nil,	-- DS: see MarketsForGameData
		mCoupons = Coupons:new(),  -- DS: Coupons
		mPreviousLeagueSelected = 0,
		sessionToken = 0,
		email = "",
		password = "",
	}
    
    setmetatable(obj, self)
    self.__index = self
    
    obj.__newindex = function(t, k, v) assert(false, "Logic--"..k .. "__newindex not exist") end
    
    instance = obj
    return obj 
end

function Logic:getSelectedMatch()
	return self.mSelectedMatch
end

function Logic:setSelectedMatch( match )
	self.mSelectedMatch = match
end

function Logic:getCurDisplayMarketIndex()
	return self.mCurDisplayMarketIndex
end

function Logic:setCurDisplayMarketIndex( index )
	self.mCurDisplayMarketIndex = index
end

function Logic:getCurMarketInfo()
	return self.mCurMarketInfo
end

function Logic:setCurMarketInfo( info )
	self.mCurMarketInfo = info
	self.mCurDisplayMarketIndex = 0
end


function Logic:getPoint()
	return self.mPoint
end

function Logic:setPoint( p )
	self.mPoint = p
end

function Logic:consumePoint( v )
	if self.mPoint > v then
		self:setPoint( self.mPoint - v )
	else
		self:setPoint( 0 )
	end
end

function Logic:setUserInfo( email, password, sessionToken )
	self.email = email
	self.password = password
	self.sessionToken = sessionToken

	local accountInfo = {}
	accountInfo[ACCOUNT_INFO_EMAIL] = email
	accountInfo[ACCOUNT_INFO_PASSWORD] = password
	accountInfo[ACCOUNT_INFO_SESSIONTOKEN] = sessionToken
	FileUtils.writeStringToFile( ACCOUNT_INFO_FILE, Json.encode( accountInfo ) )
end

function Logic:getEmail()
	return self.email
end

function Logic:getPassword()
	return self.password
end

function Logic:getAuthSessionString()
	return "Authorization: FH-Token "..self.sessionToken
end

function Logic:addPrediction( prediciton, comment, facebookShare )
	print("Make Prediction: "..prediciton.." with comments: "..comment)
	self.mCoupons:addCoupon( prediciton, comment, facebookShare )
end

function Logic:getPredictions()
	return self.mCoupons
end

function Logic:resetPredictions()
	self.mCoupons = Coupons:new()
end

function Logic:getPreviousLeagueSelected()
	return self.mPreviousLeagueSelected
end

function Logic:setPreviousLeagueSelected( id )
	self.mPreviousLeagueSelected = id
end