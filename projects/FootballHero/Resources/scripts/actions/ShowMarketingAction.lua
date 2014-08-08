module(..., package.seeall)

local FileUtils = require("scripts.FileUtils")
local Json = require("json")
local Logic = require("scripts.Logic").getInstance()


function action( param )
	if not Logic:getActiveInCompetition() then
		local leagueId = param[1]

		local MARKETING_INFO_FILE = "marketing.txt"
		local REMAIN_TIME = "remainTimes"
		local LAST_TIMESTAMP = "lastTimestamp"
		local MAX_TIME = 3

		local toShow = false
		local currentRemain = MAX_TIME
		local marketingInfo = FileUtils.readStringFromFile( MARKETING_INFO_FILE )
		if marketingInfo ~= nil and string.len( marketingInfo ) > 0 then
			marketingInfo = Json.decode( marketingInfo )
			print( marketingInfo )
			
			if marketingInfo[REMAIN_TIME] > 0 then
				local now = os.time()
			    local todayYear = os.date("%y", now)
			    local todayMonth = os.date("%m", now)
			    local todayDay = os.date("%d", now)

			    local time = marketingInfo[LAST_TIMESTAMP]
			    local year = os.date("%y", time)
			    local month = os.date("%m", time)
			    local day = os.date("%d", time)

			    if todayYear ~= year or todayMonth ~= month or todayDay ~= day then
			    	toShow = true
			    	currentRemain = marketingInfo[REMAIN_TIME]
			    end
			end
		else
			toShow = true
			currentRemain = MAX_TIME
		end

		if toShow then
			local info = {}
			info[REMAIN_TIME] = currentRemain - 1
			info[LAST_TIMESTAMP] = os.time()
			FileUtils.writeStringToFile( MARKETING_INFO_FILE, Json.encode( info ) )

	    	local MarketingMessage = require("scripts.views.MarketingMessage")
			MarketingMessage.loadFrame( leagueId )
	    end
	end
end