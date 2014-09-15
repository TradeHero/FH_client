module(..., package.seeall)

local Constants = require("scripts.Constants")
local SceneManager = require("scripts.SceneManager")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local Logic = require("scripts.Logic").getInstance()


-- General and prediction switch status is stored here.
-- Competition switch statis is stored in competition info.
local mGeneralSwitch = false
local mPredictionSwitch = nil

function initFromServer( generalSwitch, predictionSwitch )
	mGeneralSwitch = generalSwitch
	if predictionSwitch == 1 then
		mPredictionSwitch = true
	elseif predictionSwitch == 0 then
		mPredictionSwitch = false
	else
		mPredictionSwitch = nil
	end
end

function getGeneralSwitch()
	return mGeneralSwitch
end

function getPredictionSwitch()
	return mPredictionSwitch
end

function setGeneralSwitch( switch )
	if switch ~= mGeneralSwitch then
		mGeneralSwitch = switch
		EventManager:postEvent( Event.Do_Post_PN_User_Settings )
	end
end

function setPredictionSwitch( switch )
	if switch ~= mPredictionSwitch then
		mPredictionSwitch = switch
		EventManager:postEvent( Event.Do_Post_PN_User_Settings )
		if mPredictionSwitch then
			uploadDeviceToken()
    		Misc:sharedDelegate():requestPushNotification()
		end
	end
end

function checkShowPredictionSwitch( yesCallback, noCallback )
	if mPredictionSwitch ~= nil then
		yesCallback()
		return
	end

	local chooseYesCallback = function()
		uploadDeviceToken()
    	Misc:sharedDelegate():requestPushNotification()
    	setPredictionSwitch( true )
    	yesCallback()
    end

    local chooseNoCallback = function()
    	setPredictionSwitch( false )
    	noCallback()
    end

	local PNPredictionScene = require("scripts.views.PNPredictionScene")
    PNPredictionScene.loadFrame( chooseYesCallback, chooseNoCallback )
end

function checkShowCompetitionSwitch( yesCallback, noCallback )
	local chooseYesCallback = function()
    	uploadDeviceToken()
    	Misc:sharedDelegate():requestPushNotification()
    	yesCallback()
    end

    local chooseNoCallback = function()
    	noCallback()
    end

	local PNCompetitionScene = require("scripts.views.PNCompetitionScene")
    PNCompetitionScene.loadFrame( chooseYesCallback, chooseNoCallback )
end

function uploadDeviceToken()
	Logic:checkNUploadDeviceToken()
end