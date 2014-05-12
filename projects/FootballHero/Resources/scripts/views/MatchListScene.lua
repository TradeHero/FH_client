module(..., package.seeall)

local Constants = require("scripts.Constants")
local SceneManager = require("scripts.SceneManager")
local CountryConfig = require("scripts.config.Country")
local LeagueConfig = require("scripts.config.League")
local TeamConfig = require("scripts.config.Team")
local Navigator = require("scripts.views.Navigator")
local LeagueListScene = require("scripts.views.LeagueListScene")
local Logic = require("scripts.Logic").getInstance()
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList

local mWidget
local mTopLayer

local MIN_MOVE_DISTANCE = 100
local OPTION_MOVE_TIME = 0.5
local OPTION_VIEW_OFFSET_X = 475

local CONTENT_FADEIN_TIME = 0.1
local CONTENT_DELAY_TIME = 0.2

function isShown()
    return mWidget ~= nil
end

function loadFrame( matchList )
	local widget = GUIReader:shareReader():widgetFromJsonFile("scenes/MatchListScene.json")
    mWidget = widget
    mWidget:registerScriptHandler( EnterOrExit )
    SceneManager.clearNAddWidget( widget )

    Navigator.loadFrame( widget )

    -- Init the match list according to the data.
    initMatchList( matchList )

    -- Init the league list
    LeagueListScene.loadFrame( "scenes/CountryListContent.json", "scenes/LeagueListContent.json", 
        tolua.cast( mWidget:getChildByName("leagueList"), "ScrollView" ), leagueSelectedCallback )

    -- Option button
    local optionBt = widget:getChildByName("option")
    optionBt:addTouchEventListener( optionEventHandler )

    -- Init the toplayer to listen to the swap action.
    mTopLayer = CCLayer:create()
    mTopLayer:registerScriptTouchHandler( onTopLevelTouch, false, -100)
    mTopLayer:setTouchEnabled( false )
    mWidget:addNode( mTopLayer )
end

function EnterOrExit( eventType )
    if eventType == "enter" then
    elseif eventType == "exit" then
        mWidget = nil
    end
end

-- Param matchList is Object of MatchListData
function initMatchList( matchList ) 
    local contentContainer = tolua.cast( mWidget:getChildByName("ScrollView"), "ScrollView" )
    contentContainer:removeAllChildrenWithCleanup( true )

    local layoutParameter = LinearLayoutParameter:create()
    layoutParameter:setGravity(LINEAR_GRAVITY_CENTER_VERTICAL)
    local contentHeight = 0

    local seqArray = CCArray:create()

    for k,v in pairs( matchList:getMatchDateList() ) do
        local matchDate = v

        seqArray:addObject( CCCallFuncN:create( function()
            -- Add the date
            local content = SceneManager.widgetFromJsonFile("scenes/MatchDate.json")
            local dateDisplay = tolua.cast( content:getChildByName("date"), "Label" )
            dateDisplay:setText( matchDate["dateDisplay"] )
            content:setLayoutParameter( layoutParameter )
            contentContainer:addChild( content )
            contentHeight = contentHeight + content:getSize().height

            content:setOpacity( 0 )
            content:setCascadeOpacityEnabled( true )
            mWidget:runAction( CCTargetedAction:create( content, CCFadeIn:create( CONTENT_FADEIN_TIME ) ) )
        end ) )
        seqArray:addObject( CCDelayTime:create( CONTENT_DELAY_TIME ) )

        seqArray:addObject( CCCallFuncN:create( function()
            -- Add the seprater
            local upper = ImageView:create()
            upper:loadTexture("images/guang.png")
            upper:setLayoutParameter( layoutParameter )
            contentContainer:addChild( upper )
            contentHeight = contentHeight + upper:getSize().height

            upper:setOpacity( 0 )
            mWidget:runAction( CCTargetedAction:create( upper, CCFadeIn:create( CONTENT_FADEIN_TIME ) ) )
        end ) )
        seqArray:addObject( CCDelayTime:create( CONTENT_DELAY_TIME ) )
        

        for inK, inV in pairs( matchDate["matches"] ) do
            local eventHandler = function( sender, eventType )
                if eventType == TOUCH_EVENT_ENDED then
                    enterMatch( inV )
                end
            end

            seqArray:addObject( CCCallFuncN:create( function() 
                local content = SceneManager.widgetFromJsonFile("scenes/MatchListContent.json")
                helperInitMatchInfo( content, inV )

                content:setLayoutParameter( layoutParameter )
                contentContainer:addChild( content )
                contentHeight = contentHeight + content:getSize().height

                local vsBt = content:getChildByName("VS")
                vsBt:addTouchEventListener( eventHandler )

                content:setOpacity( 0 )
                content:setCascadeOpacityEnabled( true )
                mWidget:runAction( CCTargetedAction:create( content, CCFadeIn:create( CONTENT_FADEIN_TIME ) ) )
            end ) )
            seqArray:addObject( CCDelayTime:create( CONTENT_DELAY_TIME ) )
        end

        seqArray:addObject( CCCallFuncN:create( function() 
            -- Add the seprater
            local bottom = ImageView:create()
            bottom:loadTexture("images/guang-xia.png")
            bottom:setLayoutParameter( layoutParameter )
            contentContainer:addChild( bottom )
            contentHeight = contentHeight + bottom:getSize().height

            bottom:setOpacity( 0 )
            mWidget:runAction( CCTargetedAction:create( bottom, CCFadeIn:create( CONTENT_FADEIN_TIME ) ) )
        end ) )
        seqArray:addObject( CCDelayTime:create( CONTENT_DELAY_TIME ) )
    end

    seqArray:addObject( CCCallFuncN:create( function()
        contentContainer:setInnerContainerSize( CCSize:new( 0, contentHeight ) )
        local layout = tolua.cast( contentContainer, "Layout" )
        layout:requestDoLayout()
    end ) )

    mWidget:runAction( CCSequence:create( seqArray ) )
end

function enterMatch( match )
    Logic:setSelectedMatch( match )
    EventManager:postEvent( Event.Enter_Match )
end

function leagueSelectedCallback( leagueId )
    hideOptionAnim( function()
        EventManager:postEvent( Event.Enter_Match_List, { LeagueConfig.getConfigId( leagueId ) } )
    end )
end

function helperInitMatchInfo( content, matchInfo )
    local team1 = tolua.cast( content:getChildByName("team1"), "ImageView" )
    local team2 = tolua.cast( content:getChildByName("team2"), "ImageView" )
    local team1Name = tolua.cast( content:getChildByName("team1Name"), "Label" )
    local team2Name = tolua.cast( content:getChildByName("team2Name"), "Label" )
    team1:loadTexture( TeamConfig.getLogo( TeamConfig.getConfigIdByKey( matchInfo["HomeTeamId"] ) ) )
    team2:loadTexture( TeamConfig.getLogo( TeamConfig.getConfigIdByKey( matchInfo["AwayTeamId"] ) ) )
    team1Name:setText( TeamConfig.getTeamName( TeamConfig.getConfigIdByKey( matchInfo["HomeTeamId"] ) ) )
    team2Name:setText( TeamConfig.getTeamName( TeamConfig.getConfigIdByKey( matchInfo["AwayTeamId"] ) ) )
    team1Name:setFontName("fonts/Newgtbxc.ttf")
    team2Name:setFontName("fonts/Newgtbxc.ttf")
    local time = tolua.cast( content:getChildByName("time"), "Label" )
    local score = tolua.cast( content:getChildByName("score"), "Label" )
    time:setFontName("fonts/Newgtbxc.ttf")
    score:setFontName("fonts/Newgtbxc.ttf")
    if matchInfo["HomeGoals"] >= 0 and matchInfo["AwayGoals"] >= 0 then
        score:setText( string.format( score:getStringValue(), matchInfo["HomeGoals"], matchInfo["AwayGoals"] ) )
        time:setEnabled( false )
    else
        time:setText( os.date( "%H:%M", matchInfo["StartTime"] ) )
        score:setEnabled( false )
    end

    local isGameStart = matchInfo["StartTime"] > os.time()
    local vsBt = tolua.cast( content:getChildByName("VS"), "Button" )
    if isGameStart then
        vsBt:setTouchEnabled( true )
    else
        vsBt:setTouchEnabled( false )
    end
end

function optionEventHandler( sender, eventType )
    if eventType == TOUCH_EVENT_ENDED then
        local optionBt = mWidget:getChildByName("option")
        optionBt:setTouchEnabled( false )

        local seqArray = CCArray:create()
        seqArray:addObject( CCMoveBy:create( OPTION_MOVE_TIME, ccp( OPTION_VIEW_OFFSET_X, 0 ) ) )
        seqArray:addObject( CCCallFuncN:create( function()
            mTopLayer:setTouchEnabled( true )
        end ) )
        mWidget:runAction( CCSequence:create( seqArray ) )
    end
end

function onTopLevelTouch( eventType, x, y )
    print( "onTopLevelTouch" )

    if eventType == TOUCH_EVENT_ENDED then
        local touchBeginPoint = sender:getTouchStartPos()
        local touchEndPoint = sender:getTouchEndPos()
        print( touchBeginPoint.x - touchEndPoint.x )
        
    end
end


local startPosX, startPosY
function onTopLevelTouch( eventType, x, y )
    if eventType == "began" then
        startPosX, startPosY = x, y
        return true
    elseif eventType == "ended" then
        if startPosX - x > MIN_MOVE_DISTANCE then
            -- Swap to Left
            hideOptionAnim( nil )
        end
    end
end

function hideOptionAnim( callbackFunc )
    mTopLayer:setTouchEnabled( false )
    local seqArray = CCArray:create()
    seqArray:addObject( CCMoveBy:create( OPTION_MOVE_TIME, ccp( OPTION_VIEW_OFFSET_X * (-1), 0 ) ) )
    seqArray:addObject( CCCallFuncN:create( function()
        local optionBt = mWidget:getChildByName("option")
        optionBt:setTouchEnabled( true )

        if callbackFunc ~= nil then
            callbackFunc()
        end
    end ) )
    mWidget:runAction( CCSequence:create( seqArray ) )
end