module(..., package.seeall)

local SceneManager = require("scripts.SceneManager")
local Navigator = require("scripts.views.Navigator")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local TeamConfig = require("scripts.config.Team")
local LeaderboardConfig = require("scripts.config.Leaderboard")


local SUB_CONTENT_HEIGHT = 187

local mWidget


-- DS for couponHistory see CouponHistoryData
function loadFrame( couponHistory )
	local widget = GUIReader:shareReader():widgetFromJsonFile("scenes/LeaderboardScene.json")
    mWidget = widget
    mWidget:registerScriptHandler( EnterOrExit )
    SceneManager.clearNAddWidget( widget )

    Navigator.loadFrame( widget )

    initContent( couponHistory )
end

function EnterOrExit( eventType )
    if eventType == "enter" then
    elseif eventType == "exit" then
        mWidget = nil
    end
end

function initContent( couponHistory )
	local contentContainer = tolua.cast( mWidget:getChildByName("ScrollView"), "ScrollView" )
    contentContainer:removeAllChildrenWithCleanup( true )

    local layoutParameter = LinearLayoutParameter:create()
    layoutParameter:setGravity(LINEAR_GRAVITY_CENTER_VERTICAL)
    local contentHeight = 0

    for i = 1, table.getn( LeaderboardConfig.LeaderboardType ) do
    	local eventHandler = function( sender, eventType )
            if eventType == TOUCH_EVENT_ENDED then
                contentClick( i )
            end
        end

        local content = SceneManager.widgetFromJsonFile("scenes/LeaderboardContent.json")
        content:setLayoutParameter( layoutParameter )
        contentContainer:addChild( content )
        contentHeight = contentHeight + content:getSize().height
        local bt = content:getChildByName("button")
        bt:addTouchEventListener( eventHandler )
        initLeaderboardContent( content, LeaderboardConfig.LeaderboardType[i] )

        -- Add sub
        local subContent = SceneManager.widgetFromJsonFile("scenes/LeaderboardSubContent.json")
        subContent:setLayoutParameter( layoutParameter )
        contentContainer:addChild( subContent )
        subContent:setName( "subContent"..i )
        for j = 1, 4 do
            local eventHandler = function( sender, eventType )
                if eventType == TOUCH_EVENT_ENDED then
                    subContentClick( i, j )
                end
            end

            local button = subContent:getChildByName("button"..j)
            button:addTouchEventListener( eventHandler )
        end
    end

    contentContainer:setInnerContainerSize( CCSize:new( 0, contentHeight ) )
    local layout = tolua.cast( contentContainer, "Layout" )
    layout:requestDoLayout()
end

function initLeaderboardContent( content, info )
    local name = tolua.cast( content:getChildByName("name"), "Label" )
    local logo = tolua.cast( content:getChildByName("logo"), "ImageView" )

    name:setText( info["displayName"] )
    logo:loadTexture( info["logo"] )
end

function contentClick( id )
    local contentContainer = tolua.cast( mWidget:getChildByName("ScrollView"), "ScrollView" )
    local subContent = contentContainer:getChildByName( "subContent"..id )
    local originSize = subContent:getSize()

    if originSize.height > 0 then
        subContent:setSize( CCSize:new( originSize.width, 0 ) )
        contentContainer:setInnerContainerSize( CCSize:new( 0, contentContainer:getInnerContainerSize().height - SUB_CONTENT_HEIGHT ) )
    else
        subContent:setSize( CCSize:new( originSize.width, SUB_CONTENT_HEIGHT ) )
        contentContainer:setInnerContainerSize( CCSize:new( 0, contentContainer:getInnerContainerSize().height + SUB_CONTENT_HEIGHT ) )
    end
    
    local layout = tolua.cast( contentContainer, "Layout" )
    layout:requestDoLayout()
end

function subContentClick( id, subId )
    EventManager:postEvent( Event.Enter_Leaderboard_List, { id, subId } )
end