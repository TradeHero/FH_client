module(..., package.seeall)

local SceneManager = require("scripts.SceneManager")
local Event = require("scripts.events.Event").EventList
local EventManager = require("scripts.events.EventManager").getInstance()
local SMIS = require("scripts.SMIS")
local TeamConfig = require("scripts.config.Team")
local Constants = require("scripts.Constants")

local mWidget
local mStep
local mHasMoreToLoad

function loadFrame( parent, jsonResponse )
    mWidget = GUIReader:shareReader():widgetFromJsonFile("scenes/CommunityTimelineFrame.json")
    mWidget:registerScriptHandler( EnterOrExit )
    parent:addChild( mWidget )

    mStep = 1
    mHasMoreToLoad = true

    local contentContainer = tolua.cast( mWidget:getChildByName("ScrollView"), "ScrollView" )
    contentContainer:addEventListenerScrollView( scrollViewEventHandler )
    initContent( contentContainer, 0, jsonResponse )
end

function refreshFrame( jsonResponse )
    CCLuaLog("refreshFrame")
    mStep = 1
    mHasMoreToLoad = true

    local contentContainer = tolua.cast( mWidget:getChildByName("ScrollView"), "ScrollView" )
    contentContainer:removeAllChildrenWithCleanup( true )
    initContent( contentContainer, 0, jsonResponse )
end


function loadMoreContent( jsonResponse )
    if table.getn( jsonResponse ) < 20 then
        mHasMoreToLoad = false
    end
    mStep = mStep + 1
    local contentContainer = tolua.cast( mWidget:getChildByName("ScrollView"), "ScrollView" )
    initContent( contentContainer, contentContainer:getInnerContainerSize().height, jsonResponse )
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


function initContent( contentContainer, contentHeight, timelines )
    local layoutParameter = LinearLayoutParameter:create()
    layoutParameter:setGravity(LINEAR_GRAVITY_CENTER_VERTICAL)
 
    for i = 1, table.getn( timelines ) do
        CCLuaLog ("content hight:" .. contentHeight)
        local content = SceneManager.widgetFromJsonFile("scenes/CommunityTimelineContent.json")
        createContent( content, timelines[i], i )
        content:setLayoutParameter( layoutParameter )

        contentHeight = contentHeight + content:getSize().height
        contentContainer:addChild( content )
    end
    contentContainer:setInnerContainerSize( CCSize:new( 0, contentHeight ) )
    CCLuaLog ("contentHeight:" .. contentHeight .. " inner:" .. contentContainer:getInnerContainerSize().height)
    local layout = tolua.cast( contentContainer, "Layout" )
    layout:requestDoLayout()
end

function createContent( content, timeline, i )
    local userId = timeline["UserMetaData"]["UserId"]
    local userName = timeline["UserMetaData"]["DisplayName"]
    local pictureUrl = timeline["UserMetaData"]["PictureUrl"]
    local message = timeline["Message"]
    local diff = os.time() - timeline["CreateTime"]
    local timelineType = timeline["TimelineType"]

    local panel = tolua.cast( content:getChildByName("Panel_Content"), "Layout" )
    local imageProfile = tolua.cast( panel:getChildByName("Image_Profile"), "ImageView" )
    local labelName = tolua.cast( panel:getChildByName("Label_Name"), "Label" )
    local labelTime = tolua.cast( panel:getChildByName("Label_Time"), "Label" )
    local labelMsg = tolua.cast( panel:getChildByName("Label_Msg"), "Label" )
    local imagePic = tolua.cast( panel:getChildByName("Image_Pic"), "ImageView" )

    local panelMore = tolua.cast( content:getChildByName("Panel_More"), "Layout" )
    local btnMore = tolua.cast( panel:getChildByName("Button_More"), "Button" )
    btnMore:setEnabled( false )
    panelMore:setEnabled( false )

    local userHandler = function( sender, eventType )
        if eventType == TOUCH_EVENT_ENDED then
            enterUserHistory( userId )
        end
    end
    labelName:setText( userName )
    labelMsg:setText( message )
    labelTime:setText( getTimeString( diff ))

    imageProfile:addTouchEventListener( userHandler )
    local seqArray = CCArray:create()
    seqArray:addObject( CCDelayTime:create( i * 0.2 ) )
    seqArray:addObject( CCCallFuncN:create( function()
        if type( pictureUrl ) ~= "userdata" and pictureUrl ~= nil then
            local handler = function( filePath )
                if filePath ~= nil and mWidget ~= nil and imageProfile ~= nil then
                    local safeLoadTexture = function()
                       imageProfile:loadTexture( filePath )
                    end
                    xpcall( safeLoadTexture, function ( msg )  end )
                end
            end
            SMIS.getSMImagePath( pictureUrl, handler )
        end
    end ) )
    mWidget:runAction( CCSequence:create( seqArray ) )

    if timelineType == 1 then -- predict
        local gameId = timeline["GameId"]
        local pickId = timeline["PickTeamId"]
        local teamLogo = ""
        local predHandler = function( sender, eventType )
            if eventType == TOUCH_EVENT_ENDED then
                predictMatch( gameId )
            end
        end
        imagePic:addTouchEventListener( predHandler )
        if pickId ~= -1 then
            pickId = TeamConfig.getConfigIdByKey(timeline["PickTeamId"])
            teamLogo = TeamConfig.getLogo( pickId, true )
        end
        imagePic:loadTexture( teamLogo )

        -- local scroll = tolua.cast( mWidget:getChildByName("ScrollView"), "ScrollView" )
        -- local labelMore = tolua.cast( panelMore:getChildByName("Label_More"), "Label" )
        -- labelMore:setText( message )
        -- local btnMore = tolua.cast( panel:getChildByName("Button_More"), "Button" )
        -- local dropHandler = function( sender, eventType )
        --     if eventType == TOUCH_EVENT_ENDED then
        --         local deltaY = 80
        --         local hight = scroll:getInnerContainerSize().height

        --         panelMore:setEnabled( true )
        --         btnMore:setEnabled( false )
        --         content:setSize( CCSize:new( content:getSize().width, content:getSize().height + deltaY ) )
        --         hight = hight + deltaY
        --         CCLuaLog("More")

        --         scroll:setInnerContainerSize( CCSize:new( 0, hight ) )
        --         local layout = tolua.cast( scroll, "Layout" )
        --         layout:requestDoLayout()
        --     end
        -- end
        -- btnMore:addTouchEventListener(dropHandler)

    elseif timelineType == 2 then -- follow
       local followData = timeline["FollowUserMetaData"]
        local followId = followData["UserId"]
        local followUrl = followData["PictureUrl"]

        local followHandler = function( sender, eventType )
            if eventType == TOUCH_EVENT_ENDED then
                enterUserHistory( followId )
            end
        end
        imagePic:addTouchEventListener( followHandler )

        seqArray = CCArray:create()
        seqArray:addObject( CCDelayTime:create( i * 0.2 ) )
        seqArray:addObject( CCCallFuncN:create( function()
            if type( followUrl ) ~= "userdata" and followUrl ~= nil then
                local handler = function( filePath )
                    if filePath ~= nil and mWidget ~= nil and imagePic ~= nil then
                        local safeLoadTexture = function()
                           imagePic:loadTexture( filePath )
                        end
                        xpcall( safeLoadTexture, function ( msg )  end )
                    end
                end
                SMIS.getSMImagePath( followUrl, handler )
            end
        end ) )
        mWidget:runAction( CCSequence:create( seqArray ) )           

    elseif timelineType == 3 then -- join 
        local competitionId = timeline["CompetitionId"]
        local token = timeline["JoinToken"]
        local competitionHandler = function( sender, eventType )
            if eventType == TOUCH_EVENT_ENDED then
                enterCompetition( competitionId )
            end
        end
        imagePic:addTouchEventListener( competitionHandler )
        imagePic:loadTexture( Constants.COMPETITION_IMAGE_PATH .. Constants.LogoPrefix .. token .. ".png" )

    elseif timelineType == 4 then
        local competitionId = timeline["CompetitionId"]
        local competitionHandler = function( sender, eventType )
            if eventType == TOUCH_EVENT_ENDED then
                enterCompetition( competitionId )
            end
        end
        imagePic:addTouchEventListener( competitionHandler )
        imagePic:loadTexture( Constants.COMPETITION_IMAGE_PATH .. "rank.png" )
    end
end
function getTimeString( diff )
    if diff < 60 then
        return string.format("%d seconds ago", diff)
     elseif diff < 7200 then
        return string.format( "%d mins ago", math.floor( diff / 60 ) )
    elseif diff < 3600 * 24 then
        return string.format( "%d hrs ago", math.floor( diff / 3600 ) )
    elseif diff < 3600 * 24 * 60 then
        return string.format( "%d days ago", math.floor( diff / 3600 / 24 ) )
    else
        return string.format( "%d month ago", math.floor( diff / 3600 / 24 / 30) )
    end
end

function predictMatch( matchId )
    EventManager:postEvent( Event.Enter_Match_Center, { 1 , matchId } )
end

function enterUserHistory( userId )
    EventManager:postEvent( Event.Enter_History, { userId } )
end

function enterCompetition( competitionId )
    EventManager:postEvent( Event.Enter_Competition_Detail, { competitionId, false, 3, 2 } )
-- http://fhapi-dev1.cloudapp.net/api/leaderboards/getCompetitionInfoAndLeaderboard?competitionId=22910&sortType=3&step=1&perPage=50&useDev=true&yearNumber=2015&monthNumber=09
-- http://fhapi-dev1.cloudapp.net/api/leaderboards/getCompetitionInfoAndLeaderboard?competitionId=22909&sortType=3&step=1&perPage=50&useDev=true
end


function scrollViewEventHandler( target, eventType )
    if eventType == SCROLLVIEW_EVENT_BOUNCE_BOTTOM and mHasMoreToLoad then
        mStep = mStep + 1
        EventManager:postEvent( Event.Load_More_In_Timeline, { mStep } )
        -- if mFilter == true then
        --     EventManager:postEvent( Event.Load_More_In_Leaderboard, { mLeaderboardId, mSubType, mStep, Constants.FILTER_MIN_PREDICTION } )
        -- else
        --     EventManager:postEvent( Event.Load_More_In_Leaderboard, { mLeaderboardId, mSubType, mStep } )
        -- end
    elseif eventType == SCROLLVIEW_EVENT_BOUNCE_TOP then
        mStep = 1
        mHasMoreToLoad = true
        EventManager:postEvent( Event.Load_More_In_Timeline, { mStep } )
        -- EventManager:postEvent( Event.Load_More_In_Leaderboard, { mLeaderboardId, mSubType, mStep, Constants.FILTER_MIN_PREDICTION } )
    end
end
