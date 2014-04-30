module(..., package.seeall)

local Json = require("json")

-- Singleton of logic
local MATCH_PREDICTION = "matchPrediction"
local SCORE_PREDICTION = "scorePrediction"
local SUB_PREDICTION = "sub"
local instance

function getInstance()
	if instance == nil then
		instance = Logic:new()
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
		mPredictionList = {},  -- DS: [ { id = predictionID, comment = comments } ] Save the prediction of the current match selected.
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
end

function Logic:getEmail()
	return self.email
end

function Logic.getPassword()
	return self.password
end

function Logic.getSessionToken()
	return self.sessionToken
end

function Logic:getPrediction()
	return self.mPredictionList
end

function Logic:addPrediction( prediciton, comment, facebookShare )
	print("Make Prediction: "..prediciton.." with comments: "..comment)
	local item = { Id = prediciton, Comments = comment, FacebookShare = facebookShare }
	table.insert( self.mPredictionList, item )
end