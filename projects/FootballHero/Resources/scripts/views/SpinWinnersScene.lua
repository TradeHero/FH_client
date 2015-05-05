module(..., package.seeall)

local SceneManager = require("scripts.SceneManager")
local Navigator = require("scripts.views.Navigator")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local Constants = require("scripts.Constants")
local SMIS = require("scripts.SMIS")
local Header = require("scripts.views.HeaderFrame")

local mWidget
local mCurrentTotalNum
local mStep
local mHasMoreToLoad
local mOnlyShowBigPrize
local mTotalNumCountdown
local mWhichGame

function updateWhichGame( whichGame )
    mWhichGame = whichGame
end

function loadFrame( winners, onlyShowBigPrize, totalNum )
	local widget = GUIReader:shareReader():widgetFromJsonFile("scenes/SpinWinnersScene.json")

    mWidget = widget
    mWidget:registerScriptHandler( EnterOrExit )
    SceneManager.clearNAddWidget( widget )
    
    Header.loadFrame( mWidget, Constants.String.spinWheel.winners, true )

    Navigator.loadFrame( widget )

    refreshFrame( winners, onlyShowBigPrize, totalNum )
end

function refreshFrame( winners, onlyShowBigPrize, totalNum )
    mTotalNumCountdown = totalNum
    mOnlyShowBigPrize = onlyShowBigPrize
    initContent( winners )
    mStep = 1
    mHasMoreToLoad = true
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

function initContent( winners )
    initTitle()
    initFilter()

    -- init main content
    loadMainContent( winners )
end

function initTitle()
    local showBigPrizeOnly = tolua.cast( mWidget:getChildByName("Label_bigPrize"), "Label" )
    showBigPrizeOnly:setText( Constants.String.spinWheel.only_show_big_prize )
end

function initFilter()
    local onlyShowBigPrizeEventHandler = function( sender, eventType )
        if eventType == TOUCH_EVENT_ENDED then
            local onlyShowBigPrize = tolua.cast( sender, "CheckBox" )
            
            mWidget:stopAllActions()

            if onlyShowBigPrize:getSelectedState() == true then                
                mOnlyShowBigPrize = false
            else                
                mOnlyShowBigPrize = true
            end

            EventManager:postEvent( Event.Enter_Spin_winner, { mOnlyShowBigPrize, mWhichGame } )
        end
    end
    local onlyShowBigPrize = tolua.cast( mWidget:getChildByName("CheckBox_bigPrize"), "CheckBox" )
    onlyShowBigPrize:addTouchEventListener( onlyShowBigPrizeEventHandler )
    onlyShowBigPrize:setSelectedState( mOnlyShowBigPrize )
end

function loadMainContent( winners )
    
    local contentContainer = tolua.cast( mWidget:getChildByName("ScrollView_Leaderboard"), "ScrollView" )
    local CTA = tolua.cast( mWidget:getChildByName("Label_CTA"), "Label" )

    contentContainer:removeAllChildrenWithCleanup( true )

    if table.getn( winners ) > 0 then
        CTA:setEnabled( false )

        local layoutParameter = LinearLayoutParameter:create()
        layoutParameter:setGravity(LINEAR_GRAVITY_CENTER_VERTICAL)
        local contentHeight = 0

        for i = 1, table.getn( winners ) do
            local content = SceneManager.widgetFromJsonFile("scenes/SpinWinnerContent.json")
            content:setLayoutParameter( layoutParameter )
            contentContainer:addChild( content )
            contentHeight = contentHeight + content:getSize().height
            initLeaderboardContent( i, content, winners[i] )
        end

        contentContainer:setInnerContainerSize( CCSize:new( 0, contentHeight ) )
        local layout = tolua.cast( contentContainer, "Layout" )
        layout:requestDoLayout()
        contentContainer:addEventListenerScrollView( scrollViewEventHandler )

        mCurrentTotalNum = table.getn( winners )
    else
        CTA:setEnabled( true )
        CTA:setText( Constants.String.spinWheel.no_one_won )
    end
end

function loadMoreWinners( winners )
    if table.getn( winners ) == 0 then
        mHasMoreToLoad = false
        return
    end

    local contentContainer = tolua.cast( mWidget:getChildByName("ScrollView_Leaderboard"), "ScrollView" )

    local layoutParameter = LinearLayoutParameter:create()
    layoutParameter:setGravity(LINEAR_GRAVITY_CENTER_VERTICAL)
    local contentHeight = contentContainer:getInnerContainerSize().height

    for i = 1, table.getn( winners ) do
        local content = SceneManager.widgetFromJsonFile("scenes/SpinWinnerContent.json")
        content:setLayoutParameter( layoutParameter )
        contentContainer:addChild( content )
        contentHeight = contentHeight + content:getSize().height
        initLeaderboardContent( mCurrentTotalNum + i, content, winners[i] )
    end

    contentContainer:setInnerContainerSize( CCSize:new( 0, contentHeight ) )
    local layout = tolua.cast( contentContainer, "Layout" )
    layout:requestDoLayout()

    mCurrentTotalNum = mCurrentTotalNum + table.getn( winners )
end

function initLeaderboardContent( i, content, info )
    local top  = content:getChildByName("Panel_Top")
    local index = tolua.cast( top:getChildByName("Label_Index"), "Label" )
    local name = tolua.cast( top:getChildByName("Label_Name"), "Label" )
    local score = tolua.cast( top:getChildByName("Label_Score"), "Label" )
    local logo = tolua.cast( top:getChildByName("Image_Logo"), "ImageView" )

    if info["DisplayName"] == nil or type( info["DisplayName"] ) ~= "string"  then
        name:setText( Constants.String.unknown_name )
    else
        name:setText( info["DisplayName"] )
    end

    index:setText( mTotalNumCountdown )
    score:setText( info["PrizeName"] )

    mTotalNumCountdown = math.max( 1, mTotalNumCountdown - 1 )

    local seqArray = CCArray:create()
    seqArray:addObject( CCDelayTime:create( i * 0.2 ) )
    seqArray:addObject( CCCallFuncN:create( function()
        if info["PictureUrl"] ~= nil then
            local handler = function( filePath )
                if filePath ~= nil and mWidget ~= nil and logo ~= nil then
                    local safeLoadTexture = function()
                        logo:loadTexture( filePath )
                    end

                    local errorHandler = function( msg )
                        -- Do nothing
                    end

                    xpcall( safeLoadTexture, errorHandler )
                end
            end
            SMIS.getSMImagePath( info["PictureUrl"], handler )
        end
    end ) )

    mWidget:runAction( CCSequence:create( seqArray ) )
end

function scrollViewEventHandler( target, eventType )
    if eventType == SCROLLVIEW_EVENT_BOUNCE_BOTTOM and mHasMoreToLoad then
        mStep = mStep + 1
        EventManager:postEvent( Event.Load_More_In_Spin_Winner, { mStep, mOnlyShowBigPrize, mWhichGame } )
    end
end