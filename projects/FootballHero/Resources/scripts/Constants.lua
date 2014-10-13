module(..., package.seeall)

local FileUtils = require("scripts.FileUtils")


GAME_WIDTH = 640
GAME_HEIGHT = 1136

CONTENT_TYPE_JSON = "Content-Type: application/json"
CONTENT_TYPE_PLAINTEXT = "Content-Type: text/plain"
CONTENT_TYPE_JPG = "Content-Type: image/jpg"

IMAGE_PATH = "images/"
TUTORIAL_IMAGE_PATH = IMAGE_PATH.."tutorial/"

TEAM_IMAGE_PATH = IMAGE_PATH.."teams/"
LEAGUE_IMAGE_PATH = IMAGE_PATH.."leagues/"
COUNTRY_IMAGE_PATH = IMAGE_PATH.."countries/"
PREDICTION_CHOICE_IMAGE_PATH = "scenes/MatchPrediction/"
LEADERBOARD_IMAGE_PATH = "scenes/Leaderboards/"

LOGO_IMAGE_PATH = "myLogo.jpg"

DRAW = 0
TEAM1_WIN = 1
TEAM2_WIN = 2

YES = 1
NO = 2

FONT_1 = "fonts/Newgtbxc.ttf"

STAKE = 1000

TUTORIAL_SHOW_SIGNIN_TYPE = 1
TUTORIAL_SHOW_EMAIL_SELECT = 2
TUTORIAL_SHOW_EMAIL_SIGNIN = 3
TUTORIAL_SHOW_EMAIL_REGISTER = 4
TUTORIAL_SHOW_FORGOT_PASSWORD = 5
TUTORIAL_SHOW_EMAIL_REGISTER_NAME = 6

MOST_POPULAR_LEAGUE_ID = -1

ANALYTICS_EVENT_LOGIN = "Login"
ANALYTICS_EVENT_PREDICTION = "Prediction"
ANALYTICS_EVENT_SOCIAL_ACTION = "Social_Action"
ANALYTICS_EVENT_POPUP = "Pop-Up"
ANALYTICS_EVENT_COMPETITION = "Competition"


local mClientVersion = ""

function getClientVersion()
	if mClientVersion == "" then
		mClientVersion = FileUtils.readStringFromFile( "version" )
		CCLuaLog("Client version: "..mClientVersion)
	end

	return mClientVersion
end

getClientVersion()