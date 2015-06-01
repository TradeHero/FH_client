module(..., package.seeall)

STATUS_NOT_STARTED = "NS"
STATUS_1ST_HALF = "HT1"
STATUS_2ND_HALF = "HT2"
STATUS_POSTPONED = "PP"
STATUS_FINISHED = "FT"
STATUS_HALF_TIME = "HT"
STATUS_INTERRUPTED = "IR"
STATUS_1ST_OVERTIME = "OT1"
STATUS_2ND_OVERTIME = "OT2"

function statusOrMinute( gameinfo )
	local status = gameinfo["Status"]
	local minute = gameinfo["Minute"]

	if status == STATUS_1ST_HALF or 
		status == STATUS_2ND_HALF or 
		status == STATUS_1ST_OVERTIME or 
		status == STATUS_2ND_OVERTIME then
		return minute
	end

	return status
end

function scoreOrTime( gameinfo )
	local status = gameinfo["Status"]
	if status == STATUS_NOT_STARTED then
		local timestamp = gameinfo["StartTime"]
		return os.date( "%H:%M", timestamp )
	elseif status == STATUS_POSTPONED or
		status == STATUS_INTERRUPTED then
		return "-"
	else
		return gameinfo["HomeGoals"].." - "..gameinfo["AwayGoals"]
	end
end