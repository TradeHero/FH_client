module(..., package.seeall)

local HAS_RATED = "hasRated"
local PREDICTION_MADE = "predictionMade"
local LOGIN_SESSIONS = "loginSessions"


local mHasRated = false
local mOldPredictionMade = 0
local mPredictionMade = 0
local mOldLoginSessions = 0
local mLoginSessions = 0


local CONDITION_TYPE_PREDICTION_MADE = "predictionMade"
local CONDITION_TYPE_LOGIN_SESSION = "loginSession"
local CONDITIONS = {
	{ ["type"] = CONDITION_TYPE_PREDICTION_MADE, ["threshold"] = 5 },
	{ ["type"] = CONDITION_TYPE_LOGIN_SESSION, ["threshold"] = 7 },
	{ ["type"] = CONDITION_TYPE_LOGIN_SESSION, ["threshold"] = 21 }
}

function init()
	mHasRated = CCUserDefault:sharedUserDefault():getBoolForKey( HAS_RATED )
	mPredictionMade = CCUserDefault:sharedUserDefault():getIntegerForKey( PREDICTION_MADE )
	mLoginSessions = CCUserDefault:sharedUserDefault():getIntegerForKey( LOGIN_SESSIONS )

	if mHasRated then
		CCLuaLog("Rated")
	end
	
	CCLuaLog("Rate manager init. Predition made is "..mPredictionMade.." and login sessions is "..mLoginSessions)

	mOldPredictionMade = mPredictionMade
	mOldLoginSessions = mLoginSessions
end

function shouldAskToRate()
	if mHasRated then
		return false
	end

	CCLuaLog("Stats mOldPredictionMade : "..mOldPredictionMade)
	CCLuaLog("Stats mPredictionMade : "..mPredictionMade)
	CCLuaLog("Stats mOldLoginSessions : "..mOldLoginSessions)
	CCLuaLog("Stats mLoginSessions : "..mLoginSessions)

	for i = 1, table.getn( CONDITIONS ) do
		local conditionType = CONDITIONS[i]["type"]
		local conditionThreshold = CONDITIONS[i]["threshold"]
		if conditionType == CONDITION_TYPE_PREDICTION_MADE then
			if mOldPredictionMade < conditionThreshold and mPredictionMade >= conditionThreshold then

				mOldPredictionMade = mPredictionMade
				return true
			end
		elseif conditionType == CONDITION_TYPE_LOGIN_SESSION then
			if mOldLoginSessions < conditionThreshold and mLoginSessions >= conditionThreshold then

				mOldLoginSessions = mLoginSessions
				return true
			end
		end
	end
end

function setRated( rated )
	if rated then
		mHasRated = true
		save()
	end
end

function addPredictionMade()
	mPredictionMade = mPredictionMade + 1
	save()
end

function addLoginSession()
	mLoginSessions = mLoginSessions + 1
	save()
end

function save()
	CCUserDefault:sharedUserDefault():setBoolForKey( HAS_RATED, mHasRated )
	CCUserDefault:sharedUserDefault():setIntegerForKey( PREDICTION_MADE, mPredictionMade )
	CCUserDefault:sharedUserDefault():setIntegerForKey( LOGIN_SESSIONS, mLoginSessions )
end