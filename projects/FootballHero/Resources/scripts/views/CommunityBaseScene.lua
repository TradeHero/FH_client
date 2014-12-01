module(..., package.seeall)

local SceneManager = require("scripts.SceneManager")
local Navigator = require("scripts.views.Navigator")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local CommunityConfig = require("scripts.config.Community")
local Constants = require("scripts.Constants")
local Competitions = require("scripts.data.Competitions").Competitions
local CommunityCompetitionFrame = require("scripts.views.CommunityCompetitionFrame")
local CommunityLeaderboardFrame = require("scripts.views.CommunityLeaderboardFrame")

local mWidget
local mTabID

-- DS, see Competitions.lua
function loadFrame( jsonResponse, tabID, leaderboardId, subType )
	local widget = GUIReader:shareReader():widgetFromJsonFile("scenes/CommunityBaseScene.json")
    mWidget = widget
    mWidget:registerScriptHandler( EnterOrExit )
    SceneManager.clearNAddWidget( widget )
    SceneManager.clearKeypadBackListener()

    Navigator.loadFrame( widget )

    mTabID = tabID
    initContent( jsonResponse, leaderboardId, subType )
end

function refreshFrame( jsonResponse, tabID, leaderboardId, subType )
    mTabID = tabID
    initContent( jsonResponse, leaderboardId, subType )
end

function EnterOrExit( eventType )
    if eventType == "enter" then
    elseif eventType == "exit" then
        mWidget = nil
    end
end

function isShown()
    return mWidget ~= nil
end

function initContent( jsonResponse, leaderboardId, subType )
	local contentContainer = tolua.cast( mWidget:getChildByName("ScrollView_Content"), "ScrollView" )
    contentContainer:removeAllChildrenWithCleanup( true )

    -- global chats
    initGlobalChatButton()

    -- init header tab
    for i = 1, table.getn( CommunityConfig.CommunityType ) do
        initCommunityTab( CommunityConfig.CommunityType[i], i )
    end

    -- init main content
    loadMainContent( contentContainer, jsonResponse, leaderboardId, subType );
end

function initGlobalChatButton()
    --TODO
end

function initCommunityTab( tabInfo, tabId )
    local tab = tolua.cast( mWidget:getChildByName( tabInfo["id"] ), "Button" )
    tab:setTitleText( tabInfo["displayName"] )

    local isActive = mTabID == tabId

    if isActive then
        tab:setBright( false )
        tab:setTouchEnabled( false )
        tab:setTitleColor( ccc3( 255, 255, 255 ) )
    else
        local eventHandler = function( sender, eventType )
            if eventType == TOUCH_EVENT_ENDED then

                onSelectTab( tabId )
            end
        end
        tab:setBright( true )
        tab:setTouchEnabled( true )
        tab:setTitleColor( ccc3( 127, 127, 127 ) )
        tab:addTouchEventListener( eventHandler )
    end
end

function loadMainContent( contentContainer, jsonResponse, leaderboardId, subType )
    if mTabID == CommunityConfig.COMMUNITY_TAB_ID_COMPETITION then
        loadCompetitionScene( contentContainer, jsonResponse )
    elseif mTabID ==  CommunityConfig.COMMUNITY_TAB_ID_LEADERBOARD then
        loadLeaderboardScene( contentContainer, jsonResponse, leaderboardId, subType )
    end
end

function onSelectTab( tabID )
    EventManager:postEvent( Event.Enter_Community, { tabID, 1, 1, Constants.FILTER_MIN_PREDICTION } )
end

function loadCompetitionScene( contentContainer, jsonResponse )
    CommunityLeaderboardFrame.exitFrame()

    local compList = Competitions:new( jsonResponse )
    CommunityCompetitionFrame.loadFrame( contentContainer, compList )
end

function loadLeaderboardScene( contentContainer, jsonResponse, leaderboardId, subType )
    if CommunityLeaderboardFrame.isShown() then
        CommunityLeaderboardFrame.loadFrame( contentContainer, jsonResponse, leaderboardId, subType, true )
    else
        CommunityLeaderboardFrame.loadFrame( contentContainer, jsonResponse, leaderboardId, subType, false )
    end
end
