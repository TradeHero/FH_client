module(..., package.seeall)

local Constants = require("scripts.Constants")
local SceneManager = require("scripts.SceneManager")
local CountryConfig = require("scripts.config.Country")
local LeagueConfig = require("scripts.config.League")
local TeamConfig = require("scripts.config.Team")
local Navigator = require("scripts.views.Navigator")
local Logic = require("scripts.Logic").getInstance()
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList

local mWidget
local mTopLayer
local mCountryNum = CountryConfig.getConfigNum()
local mCountryExpended = {}

local COUNTRY_CONTENT_HEIGHT = 130
local LEAGUE_CONTENT_HEIGHT = 80
local MIN_MOVE_DISTANCE = 100
local OPTION_MOVE_TIME = 0.5
local OPTION_VIEW_OFFSET_X = 475

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
    helperInitLeagueList()

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

    for k,v in pairs( matchList:getMatchDateList() ) do
        local matchDate = v

        -- Add the date
        local content = GUIReader:shareReader():widgetFromJsonFile("scenes/MatchDate.json")
        local dateDisplay = tolua.cast( content:getChildByName("date"), "Label" )
        dateDisplay:setText( matchDate["dateDisplay"] )
        content:setLayoutParameter( layoutParameter )
        contentContainer:addChild( content )
        contentHeight = contentHeight + content:getSize().height

        -- Add the seprater
        local upper = ImageView:create()
        upper:loadTexture("images/guang.png")
        upper:setLayoutParameter( layoutParameter )
        contentContainer:addChild( upper )
        contentHeight = contentHeight + upper:getSize().height

        for inK, inV in pairs( matchDate["matches"] ) do
            local eventHandler = function( sender, eventType )
                if eventType == TOUCH_EVENT_ENDED then
                    enterMatch( inV )
                end
            end

            local content = GUIReader:shareReader():widgetFromJsonFile("scenes/MatchListContent.json")
            helperInitMatchInfo( content, inV )

            content:setLayoutParameter( layoutParameter )
            contentContainer:addChild( content )
            contentHeight = contentHeight + content:getSize().height

            local vsBt = content:getChildByName("VS")
            vsBt:addTouchEventListener( eventHandler )
        end

        -- Add the seprater
        local bottom = ImageView:create()
        bottom:loadTexture("images/guang-xia.png")
        bottom:setLayoutParameter( layoutParameter )
        contentContainer:addChild( bottom )
        contentHeight = contentHeight + bottom:getSize().height
    end

    contentContainer:setInnerContainerSize( CCSize:new( 0, contentHeight ) )
    local layout = tolua.cast( contentContainer, "Layout" )
    layout:requestDoLayout()
end

function enterMatch( match )
    Logic:setSelectedMatch( match )
    EventManager:postEvent( Event.Enter_Match )
end

function helperInitLeagueList()
    local contentHeight = 0
    local leagueList = tolua.cast( mWidget:getChildByName("leagueList"), "ScrollView" )
    local leagueListHeight = leagueList:getSize().height

    for i = 1, mCountryNum do
        mCountryExpended[i] = false
        local eventHandler = function( sender, eventType )
            if eventType == TOUCH_EVENT_ENDED then
                -- Handler
                if mCountryExpended[i] == true then
                    mCountryExpended[i] = false
                else
                    mCountryExpended[i] = true
                end
                helperUpdateLeagueList( i )
            end
        end

        local content = GUIReader:shareReader():widgetFromJsonFile("scenes/CountryListContent.json")
        local countryName = tolua.cast( content:getChildByName("countryName"), "Label" )
        countryName:setText( CountryConfig.getCountryName( i ) )

        content:addTouchEventListener( eventHandler )
        content:setPosition( ccp( 0, ( i - 1 ) * COUNTRY_CONTENT_HEIGHT ) )
        leagueList:addChild( content )
        content:setName( "country"..i )
        contentHeight = contentHeight + content:getSize().height
        leagueList:jumpToPercentVertical( 1 )
    end

    local scrollViewHeight = leagueList:getSize().height
    if contentHeight < scrollViewHeight then
        local offset = scrollViewHeight - contentHeight

        for i = 1, mCountryNum do
            local countryLogo = leagueList:getChildByName( "country"..i )
            countryLogo:setPosition( ccp( countryLogo:getPositionX() , countryLogo:getPositionY() + offset ) )
            local otherCountryLeagueNum = table.getn( CountryConfig.getLeagueList( i ) ) 
            for j = 1, otherCountryLeagueNum do
                local leagueLogo = leagueList:getChildByName( "country"..i.."_league"..j )
                if leagueLogo ~= nil then
                    leagueLogo:setPosition( ccp( leagueLogo:getPositionX() , leagueLogo:getPositionY() + offset ) )
                end
            end
        end
    else
        leagueList:setInnerContainerSize( CCSize:new( 0, contentHeight ) )    
    end

    local layout = tolua.cast( leagueList, "Layout" )
    layout:requestDoLayout()
end

function helperUpdateLeagueList( clickedCountryId )
    local leagueNum = table.getn( CountryConfig.getLeagueList( clickedCountryId ) ) 

    -- Calculate the move offset
    local moveOffsetX = 0
    if mCountryExpended[clickedCountryId] == true then
        moveOffsetX = leagueNum * LEAGUE_CONTENT_HEIGHT
    else
        moveOffsetX = leagueNum * (-LEAGUE_CONTENT_HEIGHT)
    end

    -- Move upper country and league logo's position    
    local leagueList = mWidget:getChildByName("leagueList")
    for i = clickedCountryId, mCountryNum do
        local countryLogo = leagueList:getChildByName( "country"..i )
        countryLogo:setPosition( ccp( countryLogo:getPositionX() , countryLogo:getPositionY() + moveOffsetX ) )
        local otherCountryLeagueNum = table.getn( CountryConfig.getLeagueList( i ) ) 
        for j = 1, otherCountryLeagueNum do
            local leagueLogo = leagueList:getChildByName( "country"..i.."_league"..j )
            if leagueLogo ~= nil then
                leagueLogo:setPosition( ccp( leagueLogo:getPositionX() , leagueLogo:getPositionY() + moveOffsetX ) )
            end
        end
    end

    -- Add or remove league logos according to the status
    if mCountryExpended[clickedCountryId] == true then
        for i = 1, leagueNum do
            local leagueId = CountryConfig.getLeagueList( clickedCountryId )[i]

            local eventHandler = function( sender, eventType )
                if eventType == TOUCH_EVENT_ENDED then
                    hideOptionAnim( function()
                        EventManager:postEvent( Event.Enter_Match_List, { LeagueConfig.getConfigId( leagueId ) } )
                    end )
                end
            end

            local content = GUIReader:shareReader():widgetFromJsonFile("scenes/LeagueListContent.json")
            local parent = leagueList:getChildByName( "country"..clickedCountryId )
            content:setPosition( ccp( 0, parent:getPositionY() - ( leagueNum - i + 1 ) * LEAGUE_CONTENT_HEIGHT ) )
            leagueList:addChild( content )
            content:setName( "country"..clickedCountryId.."_league"..i )
            content:addTouchEventListener( eventHandler )
            local leagueName = tolua.cast( content:getChildByName("leagueName"), "Label" )
            leagueName:setText( LeagueConfig.getLeagueName( leagueId ) )
        end
    else
        for i = 1, leagueNum do
            local leagueLogo = leagueList:getChildByName( "country"..clickedCountryId.."_league"..i )
            leagueList:removeChild( leagueLogo )
        end
    end 
    
    -- Update the max container size.
    local originHeight = leagueList:getInnerContainerSize().height
    leagueList:setInnerContainerSize( CCSize:new( 0, originHeight + moveOffsetX ) )
    local layout = tolua.cast( leagueList, "Layout" )
    layout:requestDoLayout()
end

function helperInitMatchInfo( content, matchInfo )
    local team1 = tolua.cast( content:getChildByName("team1"), "ImageView" )
    local team2 = tolua.cast( content:getChildByName("team2"), "ImageView" )
    local team1Name = tolua.cast( content:getChildByName("team1Name"), "Label" )
    local team2Name = tolua.cast( content:getChildByName("team2Name"), "Label" )
    team1:loadTexture( Constants.TEAM_IMAGE_PATH..TeamConfig.getLogo( TeamConfig.getConfigIdByKey( matchInfo["HomeTeamId"] ) ) )
    team2:loadTexture( Constants.TEAM_IMAGE_PATH..TeamConfig.getLogo( TeamConfig.getConfigIdByKey( matchInfo["AwayTeamId"] ) ) )
    team1Name:setText( TeamConfig.getTeamName( TeamConfig.getConfigIdByKey( matchInfo["HomeTeamId"] ) ) )
    team2Name:setText( TeamConfig.getTeamName( TeamConfig.getConfigIdByKey( matchInfo["AwayTeamId"] ) ) )
    team1Name:setFontName("fonts/Newgtbxc.ttf")
    team2Name:setFontName("fonts/Newgtbxc.ttf")
    local time = tolua.cast( content:getChildByName("time"), "Label" )
    time:setText( os.date( "%H:%M", matchInfo["StartTime"] ) )
    time:setFontName("fonts/Newgtbxc.ttf")

    local previousPrediction = nil -- TODO Logic:getPrediction( matchIndex )
    local vsBt = tolua.cast( content:getChildByName("VS"), "Button" )
    if previousPrediction == nil then
        vsBt:setBright( true )
        vsBt:setTouchEnabled( true )
    else
        vsBt:setBright( false )
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