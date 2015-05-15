module(..., package.seeall)

require "Cocos2d"
local SceneManager = require("scripts.SceneManager")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local Constants = require("scripts.Constants")
local Navigator = require("scripts.views.Navigator")
local Header = require("scripts.views.HeaderFrame")
local CountryConfig = require("scripts.config.Country")
local LeagueConfig = require("scripts.config.League")
local TeamConfig = require("scripts.config.Team")
local LiveScoreConfig = require("scripts.config.LiveScore")

local DATES = { -2, -1, 0, 1, 2 }
local RELOAD_DELAY_TIME = 10

local mWidget
local mDate
local mCurrentSelectedDay
local mRefreshAnim

function loadFrame( groupedLeagueInfo, selectedDay )
    local widget = GUIReader:shareReader():widgetFromJsonFile("scenes/LiveScoreScene.json")
    mWidget = widget
    widget:registerScriptHandler( EnterOrExit )
    SceneManager.clearNAddWidget( widget )
    SceneManager.setKeypadBackListener( keypadBackEventHandler )
    Header.loadFrame( widget, nil, false )
    Header.showLiveButton( false )
    Navigator.loadFrame( widget )

    local backBt = mWidget:getChildByName("back")
    backBt:addTouchEventListener( backEventHandler )

    mRefreshAnim = nil
    refreshFrame( groupedLeagueInfo, selectedDay )
end

function doRefresh()
    -- Only send the request when players are still in the live chat UI.
    if  mWidget ~= nil then
        EventManager:postEvent( Event.Enter_LiveScoreScene, { mCurrentSelectedDay, true } )
    end
    mRefreshAnim = nil
end

function refreshFrame( groupedLeagueInfo, selectedDay )
    mCurrentSelectedDay = selectedDay

    initDates()
    initMatchList( groupedLeagueInfo )

    if mRefreshAnim == nil then
        local seqArray = CCArray:create()
        seqArray:addObject( CCDelayTime:create( RELOAD_DELAY_TIME ) )
        seqArray:addObject( CCCallFuncN:create( doRefresh ) )
        mRefreshAnim = CCSequence:create( seqArray )

        CCDirector:sharedDirector():getRunningScene():runAction( mRefreshAnim )
    end
end

function initDates()
    local nowTime = os.time()
    local oneDay = 3600 * 24
    local scrollWidth = 0
    local dateScroll = tolua.cast( mWidget:getChildByName( "ScrollView" ), "ScrollView" )
    dateScroll:removeAllChildrenWithCleanup( true )
    for i = 1, table.getn( DATES ) do
        local cell = SceneManager.widgetFromJsonFile( "scenes/LiveScoreDateCell.json" )
        local btnSelectDate = tolua.cast( cell:getChildByName("Button_Date"), "Button" )
        dateScroll:addChild( cell )
        scrollWidth = scrollWidth + cell:getSize().width
        updateContentContainer( scrollWidth, cell )
        
        local date = nowTime + oneDay * DATES[i]
        if DATES[i] == 0 then
            tolua.cast( cell:getChildByName("Label_Weekday"), "Label" ):setText( Constants.String.today )
        else
            tolua.cast( cell:getChildByName("Label_Weekday"), "Label" ):setText( os.date( "%a", date ) )
        end
        tolua.cast( cell:getChildByName("Label_Day"), "Label" ):setText( os.date( "%d", date ) )

        if DATES[i] == mCurrentSelectedDay then
            btnSelectDate:setBright( false )
            btnSelectDate:setTouchEnabled( false )
            btnSelectDate:setTitleColor( ccc3( 255, 255, 255 ) )
        else
            btnSelectDate:setBright( true )
            btnSelectDate:setTouchEnabled( true )
            btnSelectDate:setTitleColor( ccc3( 127, 127, 127 ) )
            btnSelectDate:addTouchEventListener( function ( sender, eventType )
                if eventType == TOUCH_EVENT_ENDED then
                    sender:setBright( false )
                    sender:setTouchEnabled( false )
                    CCDirector:sharedDirector():getRunningScene():stopAction( mRefreshAnim )
                    mRefreshAnim = nil
                    EventManager:postEvent( Event.Enter_LiveScoreScene, { DATES[i], false } )
                end
            end )
        end
    end
end

function initMatchList( groupedLeagueInfo )
    local matchListContent = tolua.cast( mWidget:getChildByName("ScrollView_LiveScore"), "ScrollView" )
    matchListContent:removeAllChildrenWithCleanup( true )
    local height = 0

    for k,v in pairs( groupedLeagueInfo ) do
        local leagueKey = k
        local games = v
        local cell = SceneManager.widgetFromJsonFile( "scenes/LiveScoreCell.json" )
        local leagueFlag = tolua.cast( cell:getChildByName("Image_Nation"), "ImageView" )
        local leagueName = tolua.cast( cell:getChildByName("Label_leagueName"), "Label" )
        local leagueId = LeagueConfig.getConfigIdByKey( leagueKey )
        local countryId = CountryConfig.getConfigIdByKey( LeagueConfig.getCountryId( leagueId ) )
        
        leagueName:setText( CountryConfig.getCountryName( countryId ).." - "..LeagueConfig.getLeagueName( leagueId ) )
        leagueFlag:loadTexture( CountryConfig.getLogo( countryId ) )
        matchListContent:addChild( cell )
        height = height + cell:getSize().height

        for i = 1, table.getn( games ) do
            local game = games[i]
            local subCell = SceneManager.widgetFromJsonFile( "scenes/LiveScoreMatchCell.json" )
            local status = tolua.cast( subCell:getChildByName("Label_Status"), "Label" )
            local team1 = tolua.cast( subCell:getChildByName("Label_Team1"), "Label" )
            local team2 = tolua.cast( subCell:getChildByName("Label_Team2"), "Label" )
            local score = tolua.cast( subCell:getChildByName("Label_Score"), "Label" )

            team1:setText( TeamConfig.getTeamName( TeamConfig.getConfigIdByKey( game["HomeTeamId"] ) ) )
            team2:setText( TeamConfig.getTeamName( TeamConfig.getConfigIdByKey( game["AwayTeamId"] ) ) )
            score:setText( LiveScoreConfig.scoreOrTime( game ) )
            status:setText( LiveScoreConfig.statusOrMinute( game ) )

            matchListContent:addChild( subCell )
            height = height + subCell:getSize().height
        end
    end

    updateContentContainerHeight( height, matchListContent )
end

function updateContentContainerHeight( height, content )
    local content = tolua.cast( mWidget:getChildByName("ScrollView_LiveScore"), "ScrollView" )
    content:setInnerContainerSize( CCSize:new(0, height))
    local layout = tolua.cast( content , "Layout" )
    layout:requestDoLayout()
end

function updateContentContainer( width, content )
    local contentContainer = tolua.cast( mWidget:getChildByName("ScrollView"), "ScrollView" )
    contentContainer:setInnerContainerSize( CCSize:new(width, 0) )
    local layout = tolua.cast( contentContainer, "Layout" )
    layout:requestDoLayout()
end

-- function enterGame( index )
--     EventManager:postEvent( ENTER_GAME_EVENT_LIST[index][1], ENTER_GAME_EVENT_LIST[index][2] )
-- end

function EnterOrExit( eventType )
    if eventType == "enter" then
        elseif eventType == "exit" then
        mWidget = nil
        mRefreshAnim = nil
    end
end

function isFrameShown()
    return mWidget ~= nil
end

function backEventHandler( sender, eventType )
    if eventType == TOUCH_EVENT_ENDED then
        keypadBackEventHandler()
    end
end

function keypadBackEventHandler()
    EventManager:popHistory()
end