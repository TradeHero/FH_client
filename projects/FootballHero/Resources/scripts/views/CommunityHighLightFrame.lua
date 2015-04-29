module(..., package.seeall)

local SceneManager = require("scripts.SceneManager")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local SMIS = require("scripts.SMIS")
local Constants = require("scripts.Constants")
local TeamConfig = require("scripts.config.Team")


local mWidget
local mLeaderboardId
local mSubType
local mStep
local mCurrentTotalNum
local mHasMoreToLoad
local mDropDown
local mFilter

--[[
    [   
    {
        "HomeID": 234,
        "AwayID": 567,
        "Time": "2015/4/30",
        "videoURL": "http://www.dailymotion.com/video/x2o25fz_hd-everton-football-club-3-0-manchester-united-all-goals_sport",
        "HomeGoal": 2,
        "AwayGoal": 3
    },

    {
        "HomeID": 234,
        "AwayID": 567,
        "Time": "2015/4/30",
        "videoURL": "http://www.dailymotion.com/video/x2o25fz_hd-everton-football-club-3-0-manchester-united-all-goals_sport",
        "HomeGoal": 1,
        "AwayGoal": 2
    },

    {
        "HomeID": 234,
        "AwayID": 567,
        "Time": "2015/4/30",
        "videoURL": "http://www.dailymotion.com/video/x2o25fz_hd-everton-football-club-3-0-manchester-united-all-goals_sport",
        "HomeGoal": 0,
        "AwayGoal": 0
    }
]

--]]

function loadFrame( parent, highLightInfo )
	mWidget = GUIReader:shareReader():widgetFromJsonFile("scenes/CommunityHighLightFrame.json")
    parent:addChild( mWidget )
    mWidget:registerScriptHandler( EnterOrExit )

    local contentHeight = 0
    local layoutParameter = LinearLayoutParameter:create()
    layoutParameter:setGravity(LINEAR_GRAVITY_CENTER_VERTICAL)
    local contentContainer = tolua.cast( mWidget:getChildByName("ScrollView_HighLight"), "ScrollView" )
    contentContainer:removeAllChildrenWithCleanup( true )
    
    for i = 1, table.getn( highLightInfo ) do
        local info = highLightInfo[i]
        
        local content = SceneManager.widgetFromJsonFile("scenes/CommunityHighLightContent.json")
        content:setLayoutParameter( layoutParameter )
        contentContainer:addChild( content )
        contentHeight = contentHeight + content:getSize().height

        local teamName1 = tolua.cast( content:getChildByName("Label_teamname1"), "Label" )
        local teamName2 = tolua.cast( content:getChildByName("Label_teamname2"), "Label" )
        local teamImage1 = tolua.cast( content:getChildByName("Image_Team1"), "ImageView" )
        local teamImage2 = tolua.cast( content:getChildByName("Image_Team2"), "ImageView" )
        local score = tolua.cast( content:getChildByName("Label_score"), "Label" )
        local playBt = tolua.cast( content:getChildByName("Button_play"), "Button" )
        local thumbnail = tolua.cast( content:getChildByName("Panel_thumbnail"):getChildByName("Image_thumbnail"), "ImageView" )

        teamName1:setText( TeamConfig.getTeamName( TeamConfig.getConfigIdByKey( info["HomeID"] ) ) )
        teamName2:setText( TeamConfig.getTeamName( TeamConfig.getConfigIdByKey( info["AwayID"] ) ) )
        teamImage1:loadTexture( TeamConfig.getLogo( TeamConfig.getConfigIdByKey( info["HomeID"] ) ) )
        teamImage2:loadTexture( TeamConfig.getLogo( TeamConfig.getConfigIdByKey( info["AwayID"] ) ) )
        score:setText( info["HomeGoal"].." - "..info["AwayGoal"] )
        thumbnail:setEnabled( false )

        local playHandler = function( sender, eventType )
            if eventType == TOUCH_EVENT_ENDED then
                EventManager:postEvent( Event.Enter_DailyMotion_Video, { info["videoURL"] } )
            end
        end
        playBt:addTouchEventListener( playHandler )

        -- Load thumbnail
        loadThumbnailImage( info, i, thumbnail )
    end
    contentContainer:setInnerContainerSize( CCSize:new( 0, contentHeight ) )
    local layout = tolua.cast( contentContainer, "Layout" )
    layout:requestDoLayout()
end

function exitFrame()
    mWidget = nil
end

function isShown()
    return mWidget ~= nil
end

function EnterOrExit( eventType )
    if eventType == "enter" then
    elseif eventType == "exit" then
        mWidget = nil
    end
end


function loadThumbnailImage( info, i, thumbnail )
    local seqArray = CCArray:create()

    seqArray:addObject( CCDelayTime:create( 0.3 * ( i - 1 ) ) )
    seqArray:addObject( CCCallFuncN:create( function()
        local callback = function( success, videoInfo )
            if success and videoInfo and type( videoInfo ) == "table" then
                local imageUrl = videoInfo["thumbnail_url"]

                if imageUrl then
                    local handler = function( path )
                        if mWidget and thumbnail and path then
                            thumbnail:loadTexture( path )
                            thumbnail:setEnabled( true )
                        end
                    end
                    
                    SMIS.getVideoImagePath( imageUrl, handler )
                end
            end
        end
        EventManager:postEvent( Event.Do_Get_DailyMotion_Video_Info, { info["videoURL"], callback } )
    end ) )
    
    mWidget:runAction( CCSequence:create( seqArray ) )
end