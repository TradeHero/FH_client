module(..., package.seeall)

local SceneManager = require("scripts.SceneManager")


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

    for i = 1, leagueNum do
        local leagueId = CountryConfig.getLeagueList( i )[j]

        local eventHandler = function( sender, eventType )
            if eventType == TOUCH_EVENT_ENDED then
                selectOnLeague( sender )
                mSelectCallback( LeagueConfig.getConfigId( leagueId ), sender )
            end
        end

        local content = SceneManager.widgetFromJsonFile( mListWidget )
        mContainer:addChild( content, 0, mChildIndex )
        content:addTouchEventListener( eventHandler )

        local logo = tolua.cast( content:getChildByName("countryLogo"), "ImageView" )
        local leagueName = tolua.cast( content:getChildByName("countryName"), "Label" )
        local expendedIndicator = content:getChildByName( "expendIndi" )
        local selectedIndi = content:getChildByName("selectedIndi")

        if expendedIndicator ~= nil then
            expendedIndicator:setEnabled( false )
        end
        leagueName:setText( CountryConfig.getCountryName( i ).." - "..LeagueConfig.getLeagueName( leagueId ) )
        logo:loadTexture( CountryConfig.getLogo( i ) )
        if selectedIndi ~= nil then
            selectedIndi:setEnabled( false )
        end

        contentHeight = contentHeight + content:getSize().height

        if mLeagueInitCallback ~= nil then
            mLeagueInitCallback( content, LeagueConfig.getConfigId( leagueId ) )
        end

        mChildIndex = mChildIndex + 1
    end

    mContainer:setInnerContainerSize( CCSize:new( 0, contentHeight ) )
    local layout = tolua.cast( mContainer, "Layout" )
    layout:requestDoLayout()
    layout:setLayoutType(LAYOUT_LINEAR_VERTICAL)
end

function selectOnLeague( selectedLeague )
    for i = 1, mChildIndex - 1  do
        local child = mContainer:getChildByTag( i )
        if child == selectedLeague then
            local selectedIndi = child:getChildByName("selectedIndi")
            if selectedIndi ~= nil then
                selectedIndi:setEnabled( true )
            end
        else
            local selectedIndi = child:getChildByName("selectedIndi")
            if selectedIndi ~= nil then
                selectedIndi:setEnabled( false )
            end
        end
    end
end