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
local ACCOUNT_INFO_FB_ACCESSTOKEN = "fbAccessToken"

local instance

function getInstance()
	if instance == nil then
		instance = Logic:new()

		local savedAccountInfo = FileUtils.readStringFromFile( ACCOUNT_INFO_FILE )
		if savedAccountInfo ~= nil and string.len( savedAccountInfo ) > 0 then
			local accountInfo = Json.decode( savedAccountInfo )
			print( savedAccountInfo )
			instance:setUserInfo( accountInfo[ACCOUNT_INFO_EMAIL], 
				accountInfo[ACCOUNT_INFO_PASSWORD], 
				accountInfo[ACCOUNT_INFO_FB_ACCESSTOKEN], 0, "" )
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
		mSelectedLeagues = nil,
		mAllLeaguesQualify = false,
		mLastChatMessageTimestamp = 0,
		sessionToken = 0,
		email = "",
		password = "",
		fbAccessToken = "",
		userId = "",
		displayName = "",
		pictureUrl = nil,
		startLeagueId = 0,
		balance = 0,
		mTicket = 0,
		ActiveInCompetition = false,
		FbId = nil,
		mExpert = false,
		deviceToken = "",
		favoriteTeams = {},
		quickBloxToken = "",
		deviceID = "",
	

		competitionDetail = nil,
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

function Logic:getSelectedLeagues()
	return self.mSelectedLeagues
end

function Logic:setSelectedLeagues( selectedLeagues )
	self.mSelectedLeagues = selectedLeagues
end

function Logic:getAllLeaguesQualify()
	return self.mAllLeaguesQualify
end

function Logic:setAllLeaguesQualify( bQualify )
	self.mAllLeaguesQualify = bQualify
end

function Logic:getLastChatMessageTimestamp()
	return self.mLastChatMessageTimestamp
end

function Logic:setLastChatMessageTimestamp( timestamp )
	self.mLastChatMessageTimestamp = timestamp
end

function Logic:setUserInfo( email, password, fbAccessToken, sessionToken, userId )
	self.email = email
	self.password = password
	self.fbAccessToken = fbAccessToken
	self.sessionToken = sessionToken
	self.userId = userId

	local accountInfo = {}
	accountInfo[ACCOUNT_INFO_EMAIL] = email
	accountInfo[ACCOUNT_INFO_PASSWORD] = password
	accountInfo[ACCOUNT_INFO_FB_ACCESSTOKEN] = fbAccessToken
	FileUtils.writeStringToFile( ACCOUNT_INFO_FILE, Json.encode( accountInfo ) )
end

function Logic:clearAccountInfoFile()
	self:setUserInfo( "", "", "", 0, "" )
end

function Logic:getEmail()
	return self.email
end

function Logic:getPassword()
	return self.password
end

function Logic:getFBAccessToken()
	return self.fbAccessToken
end

function Logic:getAuthSessionString()
	return "Authorization: FH-Token "..self.sessionToken
end

function Logic:getQuickbloxSessionString()
	return "QB-Token: "..self.quickBloxToken
end

function Logic:getUserId()
	return self.userId
end

function Logic:addPrediction( prediction, question, answer, reward, answerIcon, predictionType, leagueId, teamid1, teamid2, stake )
	print( string.format( "Make Prediction: %d with answer[%s], reward[%d] and answerIcon[%s]", 
							prediction, answer, reward, answerIcon ) )
	self.mCoupons:addCoupon( prediction, question, answer, reward, answerIcon, predictionType, leagueId, teamid1, teamid2, stake )
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

function Logic:setTicket( ticket )
	self.mTicket = ticket
end

function Logic:getTicket()
	return self.mTicket
end

function Logic:setActiveInCompetition( active )
	self.ActiveInCompetition = active
end

function Logic:getActiveInCompetition()
	return self.ActiveInCompetition
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

function Logic:setExpert( bExpert )
    self.mExpert = bExpert
end

function Logic:getExpert( )
    return self.mExpert
end

function Logic:getDeviceToken()
	if self.deviceToken == "" then
		Misc:sharedDelegate():getUADeviceToken( function( token )
			if token == nil then
				self.deviceToken = ""
			else
				self.deviceToken = token	
			end
		end )
		return ""
	else
		return self.deviceToken
	end
end

function Logic:checkNUploadDeviceToken()
	Misc:sharedDelegate():setUADeviceTokenHandler( function( token )
		if token ~= nil and token ~= "" and self.deviceToken ~= token then
			self.deviceToken = token

			-- Todo upload to server
			local EventManager = require("scripts.events.EventManager").getInstance()
			local Event = require("scripts.events.Event").EventList
			EventManager:postEvent( Event.Do_Post_Device_Token, { self.deviceToken } )
		end
	end )
end

function Logic:getDeviceID()
    if self.deviceID == "" then
        self.deviceID = getDeviceID()
    end
    return self.deviceID
end

function Logic:setCompetitionDetail( competitionDetail )
	self.competitionDetail = competitionDetail
end

function Logic:getCompetitionDetail()
	return self.competitionDetail
end

function Logic:setFavoriteTeams( favoriteTeam )
	if  "table" == type( favoriteTeam ) then
		self.favoriteTeams = favoriteTeam
	else
		local isFavorite, index = instance:isFavoriteTeam( favoriteTeam )
		if isFavorite then
			table.remove( self.favoriteTeams, index )
		else
			table.insert( self.favoriteTeams, favoriteTeam )
		end
		
	end
end

function Logic:getFavoriteTeams()
	return self.favoriteTeams
end

function Logic:isFavoriteTeam( teamId )
	for i = 1, table.getn( self.favoriteTeams ) do
		if self.favoriteTeams[i] == teamId then
			return true, i
		end
	end

	return false
end

function Logic:getQuickBloxToken()
	return self.quickBloxToken
end

function Logic:setQuickBloxToken( token )
	self.quickBloxToken = token
end