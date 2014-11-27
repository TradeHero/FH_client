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

TEAM_IMAGE_PATH = IMAGE_PATH.."teams/"
LEAGUE_IMAGE_PATH = IMAGE_PATH.."leagues/"
COUNTRY_IMAGE_PATH = IMAGE_PATH.."countries/"
PREDICTION_CHOICE_IMAGE_PATH = "scenes/MatchPrediction/"
LEADERBOARD_IMAGE_PATH = "scenes/Leaderboards/"
MATCH_LIST_CONTENT_IMAGE_PATH = "scenes/MatchListContent/"
COMPETITION_SCENE_IMAGE_PATH = "scenes/Competition/"
LOGO_IMAGE_PATH = "myLogo.jpg"
COMMUNITY_IMAGE_PATH = "scenes/community/"

BannerPrefix = "banner_"
BannerPreviewPrefix = "banner_prev_"
WelcomePrefix = "welcome_"
EntryPrefix = "entry_"
PrizesPrefix = "prizes_"

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
TUTORIAL_SHOW_EMAIL_REGISTER_NAME = 6

MAX_USER_NAME_LENGTH = 20

MOST_POPULAR_LEAGUE_ID = -1

FILTER_MIN_PREDICTION = 20
RANKINGS_PER_PAGE = 50

ANALYTICS_EVENT_LOGIN = "Login"
ANALYTICS_EVENT_PREDICTION = "Prediction"
ANALYTICS_EVENT_SOCIAL_ACTION = "Social_Action"
ANALYTICS_EVENT_POPUP = "Pop-Up"
ANALYTICS_EVENT_COMPETITION = "Competition"

NOTIFICATION_KEY_SFX = "soundEffects"
EVENT_WELCOME_KEY = "event"
EVENT_NEXT_MINIGAME_TIME_KEY = "next_minigame_time"
EVENT_NEXT_MINIGAME_STAGE = "next_minigame_stage"

MinigameStages = {
	"1",
	"1",
	"1",
	"1",
	"1",
	"1",
	"1",
}
MINIGAME_STAGE_ENDED = -1

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