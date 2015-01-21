module(..., package.seeall)

local SceneManager = require("scripts.SceneManager")
local LeaderboardConfig = require("scripts.config.Leaderboard")
local Constants = require("scripts.Constants")


local mListWidget
local mContainer
local mSelectCallback

local mChildIndex

function loadFrame( listWidget, container, selectCallback )
	mListWidget = listWidget
	mContainer = container
	mSelectCallback = selectCallback

	helperInitLeagueList()
end

function helperInitLeagueList()
    local contentHeight = 0
    mChildIndex = 1

    for i = 1, table.getn( LeaderboardConfig.LeaderboardSubType ) do
        local eventHandler = function( sender, eventType )
            if eventType == TOUCH_EVENT_ENDED then
                mSelectCallback( i )
            end
        end

        local content = SceneManager.widgetFromJsonFile( mListWidget )
        mContainer:addChild( content, 0, mChildIndex )
        content:addTouchEventListener( eventHandler )

        local name = tolua.cast( content:getChildByName("Label_Name"), "Label" )
        name:setText( Constants.String.leaderboard[LeaderboardConfig.LeaderboardSubType[i]["titleKey"]] )

        contentHeight = contentHeight + content:getSize().height
        mChildIndex = mChildIndex + 1
    end

    mContainer:setInnerContainerSize( CCSize:new( 0, contentHeight ) )
    local layout = tolua.cast( mContainer, "Layout" )
    layout:requestDoLayout()
    layout:setLayoutType(LAYOUT_LINEAR_VERTICAL)
end
