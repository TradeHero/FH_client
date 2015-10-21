module(..., package.seeall)

local FileUtils = require("scripts.FileUtils")
local LocalizedString = require ("LocalizedString")
String = LocalizedString.Strings

GAME_WINNERS_NONE = 0
GAME_WINNERS_LUCKY8 = 1
GAME_WINNERS_SPINWHEEL = 2

GAME_WIDTH = 640
GAME_HEIGHT = 1136

CONTENT_TYPE_JSON = "Content-Type: application/json"
CONTENT_TYPE_PLAINTEXT = "Content-Type: text/plain"
CONTENT_TYPE_JPG = "Content-Type: image/jpg"

IMAGE_PATH = "images/"
TUTORIAL_IMAGE_PATH = IMAGE_PATH.."tutorial/"
COMPETITION_IMAGE_PATH = IMAGE_PATH.."competitions/"
SPINWHEEL_IMAGE_PATH = IMAGE_PATH.."spinWheel/"

LUCKY8_IMAGE_PATH = IMAGE_PATH .. "lucky8/"
TEAM_IMAGE_PATH = IMAGE_PATH.."teams/"
LEAGUE_IMAGE_PATH = IMAGE_PATH.."leagues/"
COUNTRY_IMAGE_PATH = IMAGE_PATH.."countries/"
PREDICTION_CHOICE_IMAGE_PATH = "scenes/MatchPrediction/"
LEADERBOARD_IMAGE_PATH = "scenes/Leaderboards/"
MATCH_LIST_CONTENT_IMAGE_PATH = "scenes/MatchListContent/"
COMPETITION_SCENE_IMAGE_PATH = "scenes/Competition/"
LOGO_IMAGE_PATH = "myLogo.jpg"
COMMUNITY_IMAGE_PATH = "scenes/community/"
MINIGAME_IMAGE_PATH = "scenes/mini-game/"
CHAT_IMAGE_PATH = "scenes/chat/"
SETTINGS_IMAGE_PATH = "scenes/Settings/"

BET365_URL = "http://imstore.bet365affiliates.com/Tracker.aspx?AffiliateId=83760&AffiliateCode=365_389787&CID=645&DID=82&TID=1&PID=163&LNG=1"

BannerPrefix = "banner_"
BannerPreviewPrefix = "banner_prev_"
WelcomePrefix = "welcome_"
EntryPrefix = "entry_"
PrizesPrefix = "prizes_"
EndPrefix = "end_"
LogoPrefix = "logo_"

ZORDER_POPUP = 65535

DRAW = 0
TEAM1_WIN = 1
TEAM2_WIN = 2

YES = 1
NO = 2

FONT_1 = "fonts/Newgtbxc.ttf"

STAKE = 1000
STAKE_BIGBET = 3000

TUTORIAL_SHOW_SIGNIN_TYPE = 1
TUTORIAL_SHOW_EMAIL_SELECT = 2
TUTORIAL_SHOW_EMAIL_SIGNIN = 3
TUTORIAL_SHOW_EMAIL_REGISTER = 4
TUTORIAL_SHOW_FORGOT_PASSWORD = 5

MAX_USER_NAME_LENGTH = 20

STATS_SHOW_ALL = -1

SpecialLeagueIds = {
	MOST_POPULAR = -1,
	UPCOMING_MATCHES = -2,
	MOST_DISCUSSED = -3,
	TEAM_EXPERT = -4,
	SPECIAL_COUNT = 3,
	ALL_LEAGUES = -99,
}
function IsSpecialLeague( id )
	local bSpecial = false

	if id == SpecialLeagueIds.MOST_POPULAR or 
		id == SpecialLeagueIds.UPCOMING_MATCHES or
		id == SpecialLeagueIds.TEAM_EXPERT or
		id == SpecialLeagueIds.MOST_DISCUSSED then

		bSpecial = true
	end

	return bSpecial
end

FILTER_MIN_PREDICTION = 20
RANKINGS_PER_PAGE = 50
DISCUSSIONS_PER_PAGE = 10

ANALYTICS_EVENT_LOGIN = "Login"
ANALYTICS_EVENT_PREDICTION = "Prediction"
ANALYTICS_EVENT_SOCIAL_ACTION = "Social_Action"
ANALYTICS_EVENT_POPUP = "Pop-Up"
ANALYTICS_EVENT_COMPETITION = "Competition"
ANALYTICS_EVENT_MINIGAME = "Minigame"
ANALYTICS_EVENT_LEAGUE = "League"
ANALYTICS_EVENT_SPINWHEEL = "Spinthewheel"
ANALYTICS_EVENT_SPECIAL_COMPETITION = "SpecialCompetitionJoined"
ANALYTICS_EVENT_SUBMIT_PREDITION_LUCK8 = "SubmitPredictionOfLucky8"
ANALYTICS_EVENT_ENTER_LUCKY8 = "EnterLucky8"

NOTIFICATION_KEY_SFX = "soundEffects"
EVENT_WELCOME_KEY = "event"
EVENT_NEXT_MINIGAME_TIME_KEY = "next_minigame_time"
EVENT_NEXT_MINIGAME_STAGE = "next_minigame_stage"
EVENT_MINIGAME_NEXT_IMAGE = "next_minigame_image"
EVENT_FHC_STATUS_KEY = "footballhero_championship_status"
EVENT_MATCH_DISCUSSION_KEY = "match_discussion_%d"

EVENT_FHC_STATUS_TO_OPEN = 1
EVENT_FHC_STATUS_OPENED = 2
EVENT_FHC_STATUS_JOINED = 3

MINIGAME_PK_ENABLED = false

MinigameStages = {
	-- development values
	-- "3",
	-- "6",
	-- "12",
	-- "30",
	-- -- production values
	"60",		-- 1 min
	"86400",	-- 1 day
	"172800",	-- 2 days
	"345600",	-- 4 days
	"604800",	-- 1 week
}
MINIGAME_STAGE_ENDED = -1
MINIGAME_IMAGE_ONE = 1
MINIGAME_IMAGE_TWO = 2

COMPETITION_PRIZE_WEEKLY = "weekly"
COMPETITION_PRIZE_MONTHLY = "monthly"
COMPETITION_PRIZE_OVERALL = "overall"

SCREEN_SHOT_IMAGE_NAME = "ScreenShot.png"

STATUS_PENDING = 0
STATUS_SKIPPED = 1
STATUS_SELECTED_LEFT = 2
STATUS_SELECTED_RIGHT = 3
STATUS_SELECTED_THIRD = 4

local mClientVersion = ""

function setLanguage( file )
	CCLuaLog("File = "..file)
	local LocalizedString = require ( file )
	String = LocalizedString.Strings
end

function getClientVersion()
	if mClientVersion == "" then
		mClientVersion = FileUtils.readStringFromFile( "version" )
		CCLuaLog("Client version: "..mClientVersion)
	end

	return mClientVersion
end

getClientVersion()

-- FOR DEBUG
function table_print (tt, indent, done)
  done = done or {}
  indent = indent or 0
  if type(tt) == "table" then
    local sb = {}
    for key, value in pairs (tt) do
      table.insert(sb, string.rep (" ", indent)) -- indent it
      if type (value) == "table" and not done [value] then
        done [value] = true
        table.insert(sb, "{\n");
        table.insert(sb, table_print (value, indent + 2, done))
        table.insert(sb, string.rep (" ", indent)) -- indent it
        table.insert(sb, "}\n");
      elseif "number" == type(key) then
        table.insert(sb, string.format("\"%s\"\n", tostring(value)))
      else
        table.insert(sb, string.format(
            "%s = \"%s\"\n", tostring (key), tostring(value)))
       end
    end
    return table.concat(sb)
  else
    return tt .. "\n"
  end
end

function to_string( tbl )
	if  "nil"       == type( tbl ) then
	    return tostring(nil)
	elseif  "table" == type( tbl ) then
	    return table_print(tbl)
	elseif  "string" == type( tbl ) then
	    return tbl
	else
	    return tostring(tbl)
	end
end

function stringFormatWithVariableOrder( format, ... )
    local args, order = {...}, {}

    format = format:gsub('%%(%d+)%$', function(i)
        table.insert( order, args[tonumber(i)] )
        return '%'
    end)

    return string.format( format, unpack(order) )
end

function getYoutubeVideoURLByKey( key )
    return "https://www.youtube.com/watch?v="..key
end

function getYoutubeThumbnailURLByKey( key )
    return "https://i.ytimg.com/vi/"..key.."/mqdefault.jpg"    
end
