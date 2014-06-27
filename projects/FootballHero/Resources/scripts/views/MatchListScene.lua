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
local SMIS = require("scripts.SMIS")


local mWidget
local mTopLayer
local mOptionPanelShown
local mTheFirstDate = nil

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

    local userName = tolua.cast( widget:getChildByName("userName"), "Label" )
    userName:setText( Logic:getDisplayName() )
    
    if Logic:getPictureUrl() ~= nil then
        local handler = function( filePath )
            if filePath ~= nil then
                local userLogo = tolua.cast( widget:getChildByName("userPhoto"), "ImageView" )
                userLogo:loadTexture( filePath )
            end
        end
        SMIS.getSMImagePath( Logic:getPictureUrl(), handler )
    end

    -- Init the toplayer to listen to the swap action.
    mTopLayer = CCLayer:create()
    mTopLayer:registerScriptTouchHandler( onTopLevelTouch, false, -100)
    mWidget:addNode( mTopLayer )
    mOptionPanelShown = false
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
    
    mTheFirstDate = nil
    for k,v in pairs( matchList:getMatchDateList() ) do
        local matchDate = v

        local zOrder = matchDate["date"]
        seqArray:addObject( CCCallFuncN:create( function()
            -- Add the date
            local content = SceneManager.widgetFromJsonFile("scenes/MatchDate.json")
            local dateDisplay = tolua.cast( content:getChildByName("date"), "Label" )
            dateDisplay:setText( matchDate["dateDisplay"] )
            content:setLayoutParameter( layoutParameter )
            content:setZOrder( zOrder )
            contentContainer:addChild( content )
            contentHeight = contentHeight + content:getSize().height

            if mTheFirstDate == nil then
                mTheFirstDate = content
            end

            content:setOpacity( 0 )
            content:setCascadeOpacityEnabled( true )
            mWidget:runAction( CCTargetedAction:create( content, CCFadeIn:create( CONTENT_FADEIN_TIME ) ) )

            updateContentContainer( contentHeight, content )
        end ) )
        seqArray:addObject( CCDelayTime:create( CONTENT_DELAY_TIME ) )

        seqArray:addObject( CCCallFuncN:create( function()
            -- Add the seprater
            local upper = ImageView:create()
            upper:loadTexture("images/guang.png")
            upper:setLayoutParameter( layoutParameter )
            upper:setZOrder( zOrder )
            contentContainer:addChild( upper )
            contentHeight = contentHeight + upper:getSize().height

            upper:setOpacity( 0 )
            mWidget:runAction( CCTargetedAction:create( upper, CCFadeIn:create( CONTENT_FADEIN_TIME ) ) )

            updateContentContainer( contentHeight, upper )
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
                content:setZOrder( zOrder )
                contentContainer:addChild( content )
                contentHeight = contentHeight + content:getSize().height

                content:addTouchEventListener( eventHandler )

                content:setOpacity( 0 )
                content:setCascadeOpacityEnabled( true )
                mWidget:runAction( CCTargetedAction:create( content, CCFadeIn:create( CONTENT_FADEIN_TIME ) ) )

                updateContentContainer( contentHeight, content )
            end ) )
            seqArray:addObject( CCDelayTime:create( CONTENT_DELAY_TIME ) )
        end

        seqArray:addObject( CCCallFuncN:create( function() 
            -- Add the seprater
            local bottom = ImageView:create()
            bottom:loadTexture("images/guang.png")
            bottom:setFlipY(true)
            bottom:setLayoutParameter( layoutParameter )
            bottom:setZOrder( zOrder )
            contentContainer:addChild( bottom )
            contentHeight = contentHeight + bottom:getSize().height

            bottom:setOpacity( 0 )
            mWidget:runAction( CCTargetedAction:create( bottom, CCFadeIn:create( CONTENT_FADEIN_TIME ) ) )

            updateContentContainer( contentHeight, bottom )
        end ) )
        seqArray:addObject( CCDelayTime:create( CONTENT_DELAY_TIME ) )
    end

    seqArray:addObject( CCCallFuncN:create( function()
        if contentContainer:getChildrenCount() == 0 then
            local content = SceneManager.widgetFromJsonFile("scenes/MatchListEmptyIndi.json")
            content:setLayoutParameter( layoutParameter )
            contentContainer:addChild( content )
            contentHeight = contentHeight + content:getSize().height
            updateContentContainer( contentHeight, content )
        end
    end ) )

    mWidget:runAction( CCSequence:create( seqArray ) )
end

function updateContentContainer( contentHeight, addContent )
    local contentContainer = tolua.cast( mWidget:getChildByName("ScrollView"), "ScrollView" )

    contentContainer:setInnerContainerSize( CCSize:new( 0, contentHeight ) )
    local layout = tolua.cast( contentContainer, "Layout" )
    layout:requestDoLayout()

    if mTheFirstDate ~= nil then
        if addContent:getZOrder() < mTheFirstDate:getZOrder() then
            local y = contentContainer:getInnerContainer():getPositionY() + addContent:getSize().height
            contentContainer:jumpToDestination( ccp( 0, y ) )
        end
    end
end

function enterMatch( match )
    if match["PredictionsPlayed"] == match["PredictionsAvailable"] then
        EventManager:postEvent( Event.Show_Error_Message, { "You have completed this match." } )
        return
    end

    Logic:setSelectedMatch( match )
    EventManager:postEvent( Event.Enter_Match )
end

function leagueSelectedCallback( leagueId )
    hideOptionAnim( function()
        EventManager:postEvent( Event.Enter_Match_List, { leagueId } )
    end )
end

function helperInitMatchInfo( content, matchInfo )
    local team1 = tolua.cast( content:getChildByName("team1"), "ImageView" )
    local team2 = tolua.cast( content:getChildByName("team2"), "ImageView" )
    local team1Name = tolua.cast( content:getChildByName("team1Name"), "Label" )
    local team2Name = tolua.cast( content:getChildByName("team2Name"), "Label" )
    local friendNum = tolua.cast( content:getChildByName("friendNum"), "Label" )
    local fhNum = tolua.cast( content:getChildByName("fhNum"), "Label" )
    local played = tolua.cast( content:getChildByName("played"), "Label" )
    
    -- Load the team logo
    team1:loadTexture( TeamConfig.getLogo( TeamConfig.getConfigIdByKey( matchInfo["HomeTeamId"] ) ) )
    team2:loadTexture( TeamConfig.getLogo( TeamConfig.getConfigIdByKey( matchInfo["AwayTeamId"] ) ) )

    -- Load the team names
    local teamName = TeamConfig.getTeamName( TeamConfig.getConfigIdByKey( matchInfo["HomeTeamId"] ) )
    if string.len( teamName ) > 20 then
        team1Name:setFontSize( 20 )
    end
    team1Name:setText( teamName )
    teamName = TeamConfig.getTeamName( TeamConfig.getConfigIdByKey( matchInfo["AwayTeamId"] ) )
    if string.len( teamName ) > 20 then
        team2Name:setFontSize( 20 )
    end
    team2Name:setText( teamName )

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

    if matchInfo["FriendsPlayed"] > 0 then
        friendNum:setText( matchInfo["FriendsPlayed"] )
    else
        friendNum:setText("0")
    end
    fhNum:setText( matchInfo["TotalUsersPlayed"] )
    played:setText( string.format( played:getStringValue(), matchInfo["PredictionsPlayed"], matchInfo["PredictionsAvailable"] ) )

    local isGameStart = matchInfo["StartTime"] > os.time()
    if isGameStart then
        content:setTouchEnabled( true )
    else
        content:setTouchEnabled( false )
    end
end

function optionEventHandler( sender, eventType )
    if eventType == TOUCH_EVENT_ENDED then
        if mOptionPanelShown then
            hideOptionAnim()
        else
            showOptionAnim()
        end
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
        if startPosX - x > MIN_MOVE_DISTANCE and mOptionPanelShown == true then
            -- Swap to Left
            hideOptionAnim()
        elseif x - startPosX > MIN_MOVE_DISTANCE and mOptionPanelShown == false then
            -- Swap to Right
            showOptionAnim()
        end
    end
end

function showOptionAnim( callbackFunc )
    local optionBt = mWidget:getChildByName("option")
    optionBt:setTouchEnabled( false )
    mTopLayer:setTouchEnabled( false )

    local seqArray = CCArray:create()
    seqArray:addObject( CCMoveBy:create( OPTION_MOVE_TIME, ccp( OPTION_VIEW_OFFSET_X, 0 ) ) )
    seqArray:addObject( CCCallFuncN:create( function()
        optionBt:setTouchEnabled( true )
        mTopLayer:setTouchEnabled( true )
        mOptionPanelShown = true

        if callbackFunc ~= nil then
            callbackFunc()
        end
    end ) )
    mWidget:runAction( CCSequence:create( seqArray ) )
end

function hideOptionAnim( callbackFunc )
    local optionBt = mWidget:getChildByName("option")
    optionBt:setTouchEnabled( false )
    mTopLayer:setTouchEnabled( false )

    local seqArray = CCArray:create()
    seqArray:addObject( CCMoveBy:create( OPTION_MOVE_TIME, ccp( OPTION_VIEW_OFFSET_X * (-1), 0 ) ) )
    seqArray:addObject( CCCallFuncN:create( function()
        optionBt:setTouchEnabled( true )
        mTopLayer:setTouchEnabled( true )
        mOptionPanelShown = false

        if callbackFunc ~= nil then
            callbackFunc()
        end
    end ) )
    mWidget:runAction( CCSequence:create( seqArray ) )
end