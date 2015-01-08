module(..., package.seeall)

local FileUtils = require("scripts.FileUtils")
require "LocalizedString"

LANGUAGE_DEF = "en"
String = LocalizedString[LANGUAGE_DEF]

GAME_WIDTH = 640
GAME_HEIGHT = 1136

CONTENT_TYPE_JSON = "Content-Type: application/json"
CONTENT_TYPE_PLAINTEXT = "Content-Type: text/plain"
CONTENT_TYPE_JPG = "Content-Type: image/jpg"

IMAGE_PATH = "images/"
TUTORIAL_IMAGE_PATH = IMAGE_PATH.."tutorial/"
COMPETITION_IMAGE_PATH = IMAGE_PATH.."competitions/"
SPINWHEEL_IMAGE_PATH = IMAGE_PATH.."spinWheel/"

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


BannerPrefix = "banner_"
BannerPreviewPrefix = "banner_prev_"
WelcomePrefix = "welcome_"
EntryPrefix = "entry_"
PrizesPrefix = "prizes_"
EndPrefix = "end_"

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
	SPECIAL_COUNT = 2
}

FILTER_MIN_PREDICTION = 20
RANKINGS_PER_PAGE = 50

ANALYTICS_EVENT_LOGIN = "Login"
ANALYTICS_EVENT_PREDICTION = "Prediction"
ANALYTICS_EVENT_SOCIAL_ACTION = "Social_Action"
ANALYTICS_EVENT_POPUP = "Pop-Up"
ANALYTICS_EVENT_COMPETITION = "Competition"
ANALYTICS_EVENT_MINIGAME = "Minigame"
ANALYTICS_EVENT_LEAGUE = "League"


NOTIFICATION_KEY_SFX = "soundEffects"
EVENT_WELCOME_KEY = "event"
EVENT_NEXT_MINIGAME_TIME_KEY = "next_minigame_time"
EVENT_NEXT_MINIGAME_STAGE = "next_minigame_stage"
EVENT_MINIGAME_NEXT_IMAGE = "next_minigame_image"
EVENT_FHC_STATUS_KEY = "footballhero_championship_status"

EVENT_FHC_STATUS_TO_OPEN = 1
EVENT_FHC_STATUS_OPENED = 2
EVENT_FHC_STATUS_JOINED = 3

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

STATUS_PENDING = 0
STATUS_SKIPPED = 1
STATUS_SELECTED_LEFT = 2
STATUS_SELECTED_RIGHT = 3
STATUS_SELECTED_THIRD = 4

local mClientVersion = ""

function getClientVersion()
	if mClientVersion == "" then
		mClientVersion = FileUtils.readStringFromFile( "version" )
		CCLuaLog("Client version: "..mClientVersion)
	end

	return mClientVersion
end

getClientVersion()