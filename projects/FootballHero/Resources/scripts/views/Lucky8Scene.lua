module(..., package.seeall)

local SceneManager = require("scripts.SceneManager")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local Constants = require("scripts.Constants")
local Navigator = require("scripts.views.Navigator")
local Header = require("scripts.views.Lucky8Header")
local TeamConfig = require("scripts.config.Team")
local RequestUtils = require("scripts.RequestUtils")
local Logic = require("scripts.Logic").getInstance()
local ConnectingMessage = require("scripts.views.ConnectingMessage")

local mWidget 
local mScrollViewHeight
local mTabButtons
local mBtnSubmits

local mMatchlistCells

local CELL_RES_STRING = 
{
    "scenes/YourPicksCell.json",
    "scenes/Lucky8MatchListCell.json",
    "scenes/Lucky8RuleCell.json",
}

local MATHLISTCELL_PICK_RES = {
    pick = Constants.LUCKY8_IMAGE_PATH .. "img-pick.png",
    notpick = Constants.LUCKY8_IMAGE_PATH .. "img-notpick.png",
}

-- cell info
local SingleCell = {
    isTeam1Selected,
    isDrawSelected,
    isTeam2Selected,
}

local mMatchlistCellInfo

function requestLucky8MatchList(  )
    local url = RequestUtils.GET_LUCKY8_GAMES
    local requestInfo = {}
    requestInfo.requestData = ""
    requestInfo.url = url
    local handler = function ( isSucceed, body, header, status, errorBuffer )
        RequestUtils.messageHandler( requestInfo, isSucceed, body, header, status, errorBuffer, RequestUtils.HTTP_200, true, onRequestLucky8MatchListSuccess, onRequestLucky8MatchListFailed )
    end

    local httpRequest = HttpRequestForLua:create( CCHttpRequest.kHttpGet )
    httpRequest:addHeader( Logic:getAuthSessionString() )
    httpRequest:sendHttpRequest( url, handler )

    ConnectingMessage.loadFrame()
end

function onRequestLucky8MatchListSuccess( json )
    mScrollViewHeight = 0;
    initScrollView( json ) 
end

function onRequestLucky8MatchListFailed( json )
    -- body
end

function loadFrame( params )
    local widget = GUIReader:shareReader():widgetFromJsonFile( "scenes/lucky8MainScene.json" )
    mWidget = widget
    widget:registerScriptHandler( EnterOrExit )
    SceneManager.clearNAddWidget( widget )
    Header.loadFrame( widget, Constants.String.lucky8.lucky8_title, true )
    Navigator.loadFrame( widget )

    local btnSubmit = tolua.cast( mWidget:getChildByName("Button_Submit"), "Button" )
    mBtnSubmits = btnSubmit
    btnSubmit:addTouchEventListener( eventSubmit )
    local submitTitle = tolua.cast( btnSubmit:getChildByName("TextField_Submit"), "TextField" )
    submitTitle:setText( Constants.String.lucky8.btn_submit_title )

    initButtonInfo()

    requestLucky8MatchList()
end

function eventSubmit( sender, eventType )
    CCLuaLog( "eventSubmit" )
    CCLuaLog( "eventSubmit" )
end

function helpInitMatchListcell( cell, cellInfo )
    local panelFade = cell:getChildByName("Panel_Fade")
    local textTeamHome = tolua.cast( panelFade:getChildByName("TextField_TeamName1"), "TextField" )
    local homeTeamId = cellInfo["Home"]["TeamId"]
    textTeamHome:setText( TeamConfig.getTeamName( TeamConfig.getConfigIdByKey( homeTeamId ) ) ) 
    local textTeamAway = tolua.cast( panelFade:getChildByName("TextField_TeamName2"), "TextField" )
    local awayTeamId = cellInfo["Away"]["TeamId"]
    textTeamAway:setText( TeamConfig.getTeamName(TeamConfig.getConfigIdByKey( awayTeamId )) )

    local LeagueName = tolua.cast( panelFade:getChildByName("TextField_Legaue"), "TextField" )
    LeagueName:setText( cellInfo["LeagueName"] )

    local team1 = tolua.cast( panelFade:getChildByName("Image_Team1"), "ImageView" )
    team1:loadTexture( TeamConfig.getLogo( TeamConfig.getConfigIdByKey(homeTeamId)) )
    local team2 = tolua.cast( panelFade:getChildByName("Image_Team2"), "ImageView" )
    team2:loadTexture( TeamConfig.getLogo( TeamConfig.getConfigIdByKey(awayTeamId)) )  

    local timeDisplay = os.date( "%H:%M", cellInfo["StartTime"] )
    local textFieldTime = tolua.cast( panelFade:getChildByName("TextField_Time"), "TextField" )
    textFieldTime:setText( timeDisplay )

    local labelScore = tolua.cast( cell:getChildByName("Label_Score_0"), "Label" )
    labelScore:setText( "-:-" )

    local btn1 = tolua.cast( panelFade:getChildByName("Button_1"), "Button" )
    btn1:addTouchEventListener( eventSelectWhoWin )

    local btn2 = tolua.cast( panelFade:getChildByName("Button_2"), "Button" )
    btn2:addTouchEventListener( eventSelectWhoWin )

    local btnDraw = tolua.cast( panelFade:getChildByName("Button_Draw"), "Button" )
    btnDraw:addTouchEventListener( eventSelectWhoWin )
end

function initScrollView( data )
    local games = data["Games"]
    local contentContainer = tolua.cast( mWidget:getChildByName("ScrollView_Content"), "ScrollView" )
    contentContainer:removeAllChildrenWithCleanup( true )
    for k,v in pairs( games ) do
        local matchContent = SceneManager.widgetFromJsonFile( "scenes/Lucky8MatchListCell.json" )
        helpInitMatchListcell( matchContent, v )
        contentContainer:addChild( matchContent )
        mScrollViewHeight = mScrollViewHeight + matchContent:getSize().height
        updateScrollView( mScrollViewHeight, content )
    end
end

function updateScrollView( scrollViewHeight, content )
    local contentContainer = tolua.cast( mWidget:getChildByName("ScrollView_Content"), "ScrollView" )
    contentContainer:setInnerContainerSize( CCSize:new(0, scrollViewHeight) )
    local layout = tolua.cast( contentContainer, "Layout" )
    layout:requestDoLayout()
end

function getCurrentTime(  )
    local currentTime = os.time()
    -- local currentDate = os.date( "%B %")
end

function eventSelectWhoWin( sender, eventType )
    if eventType == TOUCH_EVENT_ENDED then
        CCLuaLog( "eventSelectWhoWin" )
        -- sender:loadTextureNormal( MATHLISTCELL_PICK_RES[1] )
        sender:setBright( false )
    end
end

function changeScrollView( index, cellNum )
    local contentContainer = tolua.cast( mWidget:getChildByName("ScrollView_Content"), "ScrollView" )
    contentContainer:removeAllChildrenWithCleanup( true )
    mScrollViewHeight = 0
    if index == 1 or index == 3 then
        mBtnSubmits:setVisible( false )
    else
        mBtnSubmits:setVisible( true )
    end
    for i = 1, cellNum do
        local cell = SceneManager.widgetFromJsonFile( CELL_RES_STRING[index] )
        if index == 1 then
            cell:addTouchEventListener( enterHistory )
        elseif index == 2 then
            requestLucky8MatchList()
        else
            local text = tolua.cast( cell:getChildByName("TextField_Rule"), "TextField" )
            text:setText( Constants.String.lucky8.lucky8_rule )
        end
        contentContainer:addChild( cell )
        mScrollViewHeight = mScrollViewHeight + cell:getSize().height
        updateScrollView( mScrollViewHeight, cell )
    end
end

function enterHistory( sender, eventType )
    if eventType == TOUCH_EVENT_ENDED then
        EventManager:postEvent( Event.Enter_Lucky8History )
    end
end

function changeTab( index, cellNum )
    changeScrollView( index, cellNum )
end

function onSelectTab( index )
    local cellNum = 8
    if index == 3 then
        cellNum = 1
    end
    for i = 1, table.getn( mTabButtons ) do
        local btnTab = mTabButtons[ i ]
        if i == index then
            btnTab:setBright( false )
            btnTab:setTouchEnabled( false )
            btnTab:setTitleColor( ccc3( 255, 255, 255 ) )
            changeTab( index, cellNum )
        else
            btnTab:setBright( true )
            btnTab:setTouchEnabled( true )
            btnTab:setTitleColor( ccc3( 127, 127, 127 ) )
        end
    end
end

function bindEventHandler( btnTab, index )
    local eventHandler = function ( sender, eventType )
        if eventType == TOUCH_EVENT_ENDED then
            onSelectTab( index )
        end
    end
    btnTab:addTouchEventListener( eventHandler )
end

function initButtonInfo(  )
    mTabButtons = {}
    local btnPicks = tolua.cast( mWidget:getChildByName( "Button_Picks" ), "Button" )  
    btnPicks:setTitleText( Constants.String.lucky8.btn_picks_title )
    table.insert( mTabButtons, btnPicks )
    bindEventHandler( btnPicks, 1 )

    local btnMatchLists = tolua.cast( mWidget:getChildByName( "Button_MatchLists" ), "Button" )
    table.insert( mTabButtons, btnMatchLists )
    bindEventHandler( btnMatchLists, 2 )
    getCurrentTime()

    local btnRules = tolua.cast( mWidget:getChildByName( "Button_Rules" ), "Button" )
    table.insert( mTabButtons, btnRules )
    btnRules:setTitleText( Constants.String.lucky8.btn_rules_title )
    bindEventHandler( btnRules, 3 )

    onSelectTab( 2 )
end

function EnterOrExit( eventType )
    if eventType == "enter" then
    elseif eventType == "exit" then
        mWidget = nil
    end
end

function isFrameShown()
    return mWidget ~= nil
end
