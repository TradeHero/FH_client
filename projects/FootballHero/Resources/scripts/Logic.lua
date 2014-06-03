module(..., package.seeall)

local Json = require("json")
local FileUtils = require("scripts.FileUtils")
local Coupons = require("scripts.data.Coupons").Coupons
local Constants = require("scripts.Constants")

-- Singleton of logic
local MATCH_PREDICTION = "matchPrediction"
local SCORE_PREDICTION = "scorePrediction"
local SUB_PREDICTION = "sub"

local ACCOUNT_INFO_FILE = "ai.txt"
local ACCOUNT_INFO_EMAIL = "email"
local ACCOUNT_INFO_PASSWORD = "password"

local instance

function getInstance()
	if instance == nil then
		instance = Logic:new()

		local savedAccountInfo = FileUtils.readStringFromFile( ACCOUNT_INFO_FILE )
		if savedAccountInfo ~= nil and string.len( savedAccountInfo ) > 0 then
			local accountInfo = Json.decode( savedAccountInfo )
			print( savedAccountInfo )
			instance:setUserInfo( accountInfo[ACCOUNT_INFO_EMAIL], accountInfo[ACCOUNT_INFO_PASSWORD], 0, "" )
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
		userId = "",
		displayName = "",
		pictureUrl = nil,
		startLeagueId = 0,
		balance = 0,
		FbId = nil,
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

function Logic:setUserInfo( email, password, sessionToken, userId )
	self.email = email
	self.password = password
	self.sessionToken = sessionToken
	self.userId = userId

	local accountInfo = {}
	accountInfo[ACCOUNT_INFO_EMAIL] = email
	accountInfo[ACCOUNT_INFO_PASSWORD] = password
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

function Logic:getUserId()
	return self.userId
end

function Logic:addPrediction( prediciton, answer, reward, answerIcon )
	print( string.format( "Make Prediction: %d with answer[%s], reward[%d] and answerIcon[%s]", prediciton, answer, reward, answerIcon ) )
	self.mCoupons:addCoupon( prediciton, answer, reward, answerIcon )
end

function Logic:setPredictionMetadata( message, shareOnFacebook )
	self.mCoupons:setMessage( message )
	self.mCoupons:setShareOnFacebook( shareOnFacebook )
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

function Logic:getDisplayName()
	return self.displayName
end

function Logic:setDisplayName( name )
	self.displayName = name
end

function Logic:getPictureUrl()
	return self.pictureUrl
end

function Logic:setPictureUrl( url )
	self.pictureUrl = url
end

function Logic:getStartLeagueId()
	return self.startLeagueId
end

function Logic:setStartLeagueId( id )
	self.startLeagueId = id
end

function Logic:setBalance( balance )
	self.balance = balance
end

function Logic:getBalance()
	return self.balance
end

function Logic:getUncommitedBalance()
	return self.mCoupons:getSize() * Constants.STAKE
end

function Logic:setFbId( id )
	self.FbId = id
end

function  Logic:getFbId()
	return self.FbId
end