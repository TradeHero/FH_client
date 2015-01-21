module(..., package.seeall)

local Constants = require("scripts.Constants")
local RequestUtils = require("scripts.RequestUtils")

MATCH_CENTER_TAB_ID_MEETINGS = 1
MATCH_CENTER_TAB_ID_DISCUSSION = 2

DISCUSSION_POST_TYPE_GAME = 1
DISCUSSION_POST_TYPE_LEAGUE = 2
DISCUSSION_POST_TYPE_USER = 3
DISCUSSION_POST_TYPE_POST = 4

MAX_DISCUSSION_POST_TEXT_WIDTH = 440
MAX_DISCUSSION_TEXT_WIDTH = 360
MAX_DISCUSSION_TEXT_HEIGHT = 50

MatchCenterType = {
	{ ["id"] = "Button_Meetings", ["displayNameKey"] = "title_meetings", ["enabled"] = false },
	
	{ ["id"] = "Button_Discussion", ["displayNameKey"] = "title_discussion", ["enabled"] = true }
}


function setTimeDiff( content, prevTime )

	local displayTime
    local now = os.time()
    local timeDiff = now - prevTime

    if timeDiff < 120 then
    	displayTime = Constants.String.match_center.just_now
    elseif timeDiff < 7200 then
    	displayTime = string.format( Constants.String.match_center.time_minutes, math.floor( timeDiff / 60 ) )
    elseif timeDiff < 3600 * 24 then
    	displayTime = string.format( Constants.String.match_center.time_hours, math.floor( timeDiff / 3600 ) )
    else
    	displayTime = string.format( Constants.String.match_center.time_days, match.floor( timeDiff / (3600 * 24) ) )
    end

    content:setText( displayTime )
end
