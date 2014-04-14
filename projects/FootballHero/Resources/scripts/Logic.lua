module(..., package.seeall)

local FileUtils = require("scripts.FileUtils")

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
		mSelectedMatchIndex = 0,
		mPredictionList = {},
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

function Logic:getSelectedMatchIndex()
	return self.mSelectedMatchIndex
end

function Logic:setSelectedMatchIndex( index )
	self.mSelectedMatchIndex = index
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

function Logic:getPrediction( predictionIndex )
	return self.mPredictionList[MATCH_PREDICTION..predictionIndex]
end

function Logic:addPrediction( predictionIndex, prediciton )
	print("Index "..predictionIndex.." value "..prediciton)
	self.mPredictionList[MATCH_PREDICTION..predictionIndex] = prediciton		-- use tonumber("3")
end

function Logic:getScorePrediction( predictionIndex )
	return self.mPredictionList[SCORE_PREDICTION..predictionIndex]
end

function Logic:addScorePrediction( predictionIndex, scorePredictionIndex, prediction )
	if self.mPredictionList[SCORE_PREDICTION..predictionIndex] == nil then
		self.mPredictionList[SCORE_PREDICTION..predictionIndex] = {}
	end
	self.mPredictionList[SCORE_PREDICTION..predictionIndex][SUB_PREDICTION..scorePredictionIndex] = prediction
end

function Logic:writeToFile()
	FileUtils.writeTableToFile( "prediction.json", self.mPredictionList )
end

function Logic:readFromFile()
	self.mPredictionList = FileUtils.readTableFromFile( "prediction.json" )
end