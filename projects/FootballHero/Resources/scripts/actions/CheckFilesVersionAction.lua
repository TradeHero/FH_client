module(..., package.seeall)

local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local ConnectingMessage = require("scripts.views.ConnectingMessage")
local RequestUtils = require("scripts.RequestUtils")
local FileUtils = require("scripts.FileUtils")
local MD5 = require("MD5")
local Constants = require("scripts.Constants")
local SceneManager = require("scripts.SceneManager")
local RateManager = require("scripts.RateManager")


local fileList = {
	"config/countries.txt",
	"config/leagues.txt",
	"config/teams.txt",
	"config/leagueteams.txt",
}

local MD5ConfigIDList = {
	"CountryConfigMd5",
	"LeagueConfigMd5",
	"TeamConfigMd5",
	"LeagueTeamConfigMd5",
}

local CDNFileNameList = {
	"countries.txt",
	"leagues.txt",
	"teams.txt",
	"leagueteams.txt",
}

local mConfigMd5Info
local mFinishEvent
local mFinishEventParam
local mCurrentFileIndex

function action( param )
	mConfigMd5Info = param[1]
	mFinishEvent = param[2]
	mFinishEventParam = param[3]

	mCurrentFileIndex = 0
	checkNext()
end

function checkNext()
	mCurrentFileIndex = mCurrentFileIndex + 1
	if mCurrentFileIndex <= table.getn( fileList ) then
		checkFile( mCurrentFileIndex )	
	else
		-- Init the configure files.
		ConnectingMessage.loadFrame( Constants.String.login_success )

		local loadDataTaskSeqArray = CCArray:create()
		loadDataTaskSeqArray:addObject( CCDelayTime:create( 1 ) )
		loadDataTaskSeqArray:addObject( CCCallFuncN:create( function()
			local LeagueTeamConfig = require("scripts.config.LeagueTeams")
	        local CountryConfig = require("scripts.config.Country")
	        local LeagueConfig = require("scripts.config.League")
	        local TeamConfig = require("scripts.config.Team")

	        ConnectingMessage.selfRemove()

	        -- Init the deep link.
	        local deepLinkHandler = function( deepLink )
	        	--CCLuaLog("Deep link check after checking files version: "..( deepLink or "null" ) )
	        	if deepLink == nil then
	        		EventManager:postEvent( mFinishEvent, mFinishEventParam )
	        	else
	        		SceneManager.processDeepLink( deepLink, mFinishEvent, mFinishEventParam )
	        	end
	        end

	        SceneManager.registerDeepLinkEvent()
	        Misc:sharedDelegate():getDeepLink( deepLinkHandler )
	        RateManager.addLoginSession()
		end ) )

		CCDirector:sharedDirector():getRunningScene():runAction( CCSequence:create( loadDataTaskSeqArray ) )
	end
end

function checkFile( fileIndex )
	local file = fileList[fileIndex]
	local MD5ConfigId = MD5ConfigIDList[fileIndex]
	local serverMD5 = mConfigMd5Info[MD5ConfigId]
	if serverMD5 == nil then
		print( "Checking "..file..", but server MD5 is nil." )
		checkNext()
		return
	end

	-- Compare the md5 value
	-- Re-download the file if not match
	local fileContent = FileUtils.readStringFromFile( file )
	local localMD5 = MD5.sumhexa( fileContent )
	print( "Checking "..file..": "..serverMD5.." | "..localMD5 )
	if serverMD5 ~= localMD5 then
		local handler = function( isSucceed, body, header, status, errorBuffer )
	        print( "Http reponse: "..status.." and errorBuffer: "..errorBuffer )
	        ConnectingMessage.selfRemove()
	        if status == RequestUtils.HTTP_200 then
	            onRequestSuccess( file, body )
	        else
	            onRequestFailed( errorBuffer )
	        end
	    end

	    local httpRequest = HttpRequestForLua:create( CCHttpRequest.kHttpGet )
	    print("Downloading from: "..RequestUtils.CDN_SERVER_IP..CDNFileNameList[fileIndex])
	    httpRequest:sendHttpRequest( RequestUtils.CDN_SERVER_IP..CDNFileNameList[fileIndex], handler )

	    ConnectingMessage.loadFrame( string.format( Constants.String.updating_files, files ) )
	else
		checkNext()
	end
end

function onRequestSuccess( fileName, fileContent )
    -- Compare the md5 for the new download file
    local MD5ConfigId = MD5ConfigIDList[mCurrentFileIndex]
	local serverMD5 = mConfigMd5Info[MD5ConfigId]
	local localMD5 = MD5.sumhexa( fileContent )
	if serverMD5 ~= nil and serverMD5 ~= localMD5 then
		onRequestFailed("")
	else
		print("Update complete for file: "..fileName)
		FileUtils.writeStringToFile( fileName, fileContent )
		checkNext()
	end
end

function onRequestFailed( errorBuffer )
	if errorBuffer == "" then
		errorBuffer = Constants.String.error.updating_failed
	end

	mCurrentFileIndex = mCurrentFileIndex - 1
    EventManager:postEvent( Event.Show_Error_Message, { errorBuffer, checkNext } )
end