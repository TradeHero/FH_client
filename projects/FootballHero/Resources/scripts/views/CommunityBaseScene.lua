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
local CommunityHighLightFrame = require("scripts.views.CommunityHighLightFrame")
local CommunityVideoFrame = require("scripts.views.CommunityVideoFrame")
local Minigame = require("scripts.data.Minigame").Minigame
local Header = require("scripts.views.HeaderFrame")
local CheckListConfig = require("scripts.data.CheckList")


local mWidget
local mTabID

-- DS, see Competitions.lua
function loadFrame( jsonResponse, tabID, leaderboardId, subType, minigameResponse )
	local widget = GUIReader:shareReader():widgetFromJsonFile("scenes/CommunityBaseScene.json")
    mWidget = widget
    mWidget:registerScriptHandler( EnterOrExit )
    SceneManager.clearNAddWidget( widget )
    
    Header.loadFrame( mWidget, Constants.String.community.title, false, nil, true )

    Navigator.loadFrame( widget )

    mTabID = tabID
    initContent( jsonResponse, leaderboardId, subType, minigameResponse )
end

function refreshFrame( jsonResponse, tabID, leaderboardId, subType, minigameResponse )
    mTabID = tabID
    initContent( jsonResponse, leaderboardId, subType, minigameResponse )
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

function initContent( jsonResponse, leaderboardId, subType, minigameResponse )
	local contentContainer = tolua.cast( mWidget:getChildByName("ScrollView_Content"), "ScrollView" )
    contentContainer:removeAllChildrenWithCleanup( true )

    -- init header tab
    for i = 1, table.getn( CommunityConfig.CommunityType ) do
        initCommunityTab( CommunityConfig.CommunityType[i], i )
    end

    -- init main content
    loadMainContent( contentContainer, jsonResponse, leaderboardId, subType, minigameResponse )
end

function initCommunityTab( tabInfo, tabId )
    local tab = tolua.cast( mWidget:getChildByName( tabInfo["id"] ), "Button" )
    tab:setTitleText( Constants.String.community[tabInfo["displayNameKey"]] )

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

    if tabId == CommunityConfig.COMMUNITY_TAB_ID_HIGHLIGHT then
        local isNew = CheckListConfig.isItemNew( CheckListConfig.CHECK_LIST_HIGHLIGHTS )
        local newFlag = tab:getChildByName("Image_new")
        newFlag:setEnabled( isNew )
        
    elseif tabId == CommunityConfig.COMMUNITY_TAB_ID_VIDEO then
        local isNew = CheckListConfig.isItemNew( CheckListConfig.CHECK_LIST_VIDEOS )
        local newFlag = tab:getChildByName("Image_new")
        newFlag:setEnabled( isNew )
    end
end

function loadMainContent( contentContainer, jsonResponse, leaderboardId, subType, minigameResponse )
    if mTabID == CommunityConfig.COMMUNITY_TAB_ID_COMPETITION then
        loadCompetitionScene( contentContainer, jsonResponse, minigameResponse )
    elseif mTabID == CommunityConfig.COMMUNITY_TAB_ID_HIGHLIGHT then
        loadHighLightScene( contentContainer, jsonResponse )
    elseif mTabID == CommunityConfig.COMMUNITY_TAB_ID_VIDEO then
        loadVideoScene( contentContainer, jsonResponse )
    elseif mTabID ==  CommunityConfig.COMMUNITY_TAB_ID_LEADERBOARD then
        loadLeaderboardScene( contentContainer, jsonResponse, leaderboardId, subType )
    end
end

function onSelectTab( tabID )
    EventManager:postEvent( Event.Enter_Community, { tabID, 1, 1, Constants.FILTER_MIN_PREDICTION } )

    if tabID == CommunityConfig.COMMUNITY_TAB_ID_HIGHLIGHT then
        CheckListConfig.clearCheckItemNewFlag( CheckListConfig.CHECK_LIST_HIGHLIGHTS )
    elseif tabID == CommunityConfig.COMMUNITY_TAB_ID_VIDEO then
        CheckListConfig.clearCheckItemNewFlag( CheckListConfig.CHECK_LIST_VIDEOS )
    end
end

function loadCompetitionScene( contentContainer, jsonResponse, minigameResponse )
    CommunityLeaderboardFrame.exitFrame()

    local compList = Competitions:new( jsonResponse )
    local minigame = Minigame:new( minigameResponse )
    CommunityCompetitionFrame.loadFrame( contentContainer, compList, minigame )
end

function loadHighLightScene( contentContainer, jsonResponse )
    CommunityLeaderboardFrame.exitFrame()
    if not CommunityHighLightFrame.isShown() then
        CommunityHighLightFrame.loadFrame( contentContainer, jsonResponse )
    end
end

function loadVideoScene( contentContainer, jsonResponse )
    CommunityLeaderboardFrame.exitFrame()
    if not CommunityVideoFrame.isShown() then
        CommunityVideoFrame.loadFrame( contentContainer, jsonResponse )
    end
end

function loadLeaderboardScene( contentContainer, jsonResponse, leaderboardId, subType )
    if CommunityLeaderboardFrame.isShown() then
        CommunityLeaderboardFrame.loadFrame( contentContainer, jsonResponse, leaderboardId, subType, true )
    else
        CommunityLeaderboardFrame.loadFrame( contentContainer, jsonResponse, leaderboardId, subType, false )
    end
end
