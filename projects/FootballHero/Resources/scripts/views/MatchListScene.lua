module(..., package.seeall)

local Constants = require("scripts.Constants")
local SceneManager = require("scripts.SceneManager")
local TeamConfig = require("scripts.config.Team")
local MatchConfig = require("scripts.config.Match")
local Navigator = require("scripts.views.Navigator")
local Logic = require("scripts.Logic").getInstance()
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList

local mWidget
local mTopLayer
local mMatchNum = MatchConfig.getConfigNum()
local mCountryNum = 7
local mCountryExpended = {}

local COUNTRY_CONTENT_HEIGHT = 130
local LEAGUE_CONTENT_HEIGHT = 130
local MIN_MOVE_DISTANCE = 100
local OPTION_MOVE_TIME = 0.5
local OPTION_VIEW_OFFSET_X = 475

function loadFrame()
	local widget = GUIReader:shareReader():widgetFromJsonFile("scenes/MatchListScene.json")
    SceneManager.clearNAddWidget( widget )
    mWidget = widget

    Navigator.loadFrame( widget )

    local contentContainer = tolua.cast( widget:getChildByName("ScrollView"), "ScrollView" )
    local layoutParameter = LinearLayoutParameter:create()
    layoutParameter:setGravity(LINEAR_GRAVITY_CENTER_VERTICAL)
    local contentHeight = 0

    -- Add the date
    local content = GUIReader:shareReader():widgetFromJsonFile("scenes/MatchDate.json")
    content:setLayoutParameter( layoutParameter )
    contentContainer:addChild( content )
    contentHeight = contentHeight + content:getSize().height

    -- Add the seprater
    local upper = ImageView:create()
    upper:loadTexture("images/guang.png")
    upper:setLayoutParameter( layoutParameter )
    contentContainer:addChild( upper )
    contentHeight = contentHeight + upper:getSize().height

    for i = 1, mMatchNum do
        local eventHandler = function( sender, eventType )
            if eventType == TOUCH_EVENT_ENDED then
                enterMatch( i )
            end
        end

        local content = GUIReader:shareReader():widgetFromJsonFile("scenes/MatchListContent.json")
        helperInitMatchInfo( content, i )

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

    contentContainer:setInnerContainerSize( CCSize:new( 0, contentHeight ) )
    local layout = tolua.cast( contentContainer, "Layout" )
    layout:requestDoLayout()

    -- Init the league list
    for i = 1, mCountryNum do
        mCountryExpended[i] = false
    end
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

function enterMatch( index )
    Logic:setSelectedMatchIndex( index )
    EventManager:postEvent( Event.Enter_Match )
end

function helperInitLeagueList()
    local contentHeight = 0
    local leagueList = tolua.cast( mWidget:getChildByName("leagueList"), "ScrollView" )

    for i = 1, mCountryNum do
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

        content:addTouchEventListener( eventHandler )
        content:setPosition( ccp( 0, ( i - 1 ) * COUNTRY_CONTENT_HEIGHT ) )
        leagueList:addChild( content )
        content:setName( "country"..i )
        contentHeight = contentHeight + content:getSize().height
    end

    leagueList:setInnerContainerSize( CCSize:new( 0, contentHeight ) )
    local layout = tolua.cast( leagueList, "Layout" )
    layout:requestDoLayout()
end

function helperUpdateLeagueList( clickedCountryId )
    local subLeagueNum = 2 -- Hack the number for now

    -- Calculate the move offset
    local moveOffsetX = 0
    if mCountryExpended[clickedCountryId] == true then
        moveOffsetX = subLeagueNum * LEAGUE_CONTENT_HEIGHT
    else
        moveOffsetX = subLeagueNum * (-LEAGUE_CONTENT_HEIGHT)
    end

    -- Move upper country and league logo's position    
    local leagueList = mWidget:getChildByName("leagueList")
    for i = clickedCountryId, mCountryNum do
        local countryLogo = leagueList:getChildByName( "country"..i )
        countryLogo:setPosition( ccp( countryLogo:getPositionX() , countryLogo:getPositionY() + moveOffsetX ) )
        for j = 1, subLeagueNum do
            local leagueLogo = leagueList:getChildByName( "country"..i.."_league"..j )
            if leagueLogo ~= nil then
                leagueLogo:setPosition( ccp( leagueLogo:getPositionX() , leagueLogo:getPositionY() + moveOffsetX ) )
            end
        end
    end

    -- Add or remove league logos according to the status
    if mCountryExpended[clickedCountryId] == true then
        for i = 1, subLeagueNum do
            local content = GUIReader:shareReader():widgetFromJsonFile("scenes/LeagueListContent.json")
            local parent = leagueList:getChildByName( "country"..clickedCountryId )
            content:setPosition( ccp( 0, parent:getPositionY() - ( subLeagueNum - i + 1 ) * LEAGUE_CONTENT_HEIGHT ) )
            leagueList:addChild( content )
            content:setName( "country"..clickedCountryId.."_league"..i )
        end
    else
        for i = 1, subLeagueNum do
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

function helperInitMatchInfo( content, matchIndex )
    local team1 = tolua.cast( content:getChildByName("team1"), "ImageView" )
    local team2 = tolua.cast( content:getChildByName("team2"), "ImageView" )
    local team1Name = tolua.cast( content:getChildByName("team1Name"), "Label" )
    local team2Name = tolua.cast( content:getChildByName("team2Name"), "Label" )
    team1:loadTexture( Constants.TEAM_IMAGE_PATH..TeamConfig.getLogo( MatchConfig.getTeam1( matchIndex ) ) )
    team2:loadTexture( Constants.TEAM_IMAGE_PATH..TeamConfig.getLogo( MatchConfig.getTeam2( matchIndex ) ) )
    team1Name:setText( TeamConfig.getDisplayName( MatchConfig.getTeam1( matchIndex ) ) )
    team2Name:setText( TeamConfig.getDisplayName( MatchConfig.getTeam2( matchIndex ) ) )
    team1Name:setFontName("fonts/Newgtbxc.ttf")
    team2Name:setFontName("fonts/Newgtbxc.ttf")

    local previousPrediction = Logic:getPrediction( matchIndex )
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
            mTopLayer:setTouchEnabled( false )
            local seqArray = CCArray:create()
            seqArray:addObject( CCMoveBy:create( OPTION_MOVE_TIME, ccp( OPTION_VIEW_OFFSET_X * (-1), 0 ) ) )
            seqArray:addObject( CCCallFuncN:create( function()
                local optionBt = mWidget:getChildByName("option")
                optionBt:setTouchEnabled( true )
            end ) )
            mWidget:runAction( CCSequence:create( seqArray ) )
        end
    end
end