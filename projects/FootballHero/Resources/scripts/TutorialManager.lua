module(..., package.seeall)

local Constants = require("scripts.Constants")
local SceneManager = require("scripts.SceneManager")
local Event = require("scripts.events.Event").EventList


TUTORIAL_SEL_FAV_TEAM = "tutorial_sel_fav_team"
TUTORIAL_PREDICTION = "tutorial_prediction"

local mTutorialConfig = {
    { ["event"] = TUTORIAL_SEL_FAV_TEAM, ["uiKey"] = "scenes/TutorialSelectFavourite.json"  },
    { ["event"] = TUTORIAL_PREDICTION, ["uiKey"] = "scenes/TutorialPrediction.json"  },
}

function checkRunTutorial( event )
    for i = 1, table.getn( mTutorialConfig ) do
        local config = mTutorialConfig[i]
        if config["event"] == event then
            local record = CCUserDefault:sharedUserDefault():getBoolForKey( config["event"] )
            if record == false then
                CCUserDefault:sharedUserDefault():setBoolForKey( config["event"], true )

                local TutorialScene = require("scripts.views.TutorialScene")
                TutorialScene.loadFrame( config["uiKey"] )
            end
        end
    end
end