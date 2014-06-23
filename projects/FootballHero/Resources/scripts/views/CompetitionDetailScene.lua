module(..., package.seeall)

local SceneManager = require("scripts.SceneManager")
local Navigator = require("scripts.views.Navigator")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local SMIS = require("scripts.SMIS")


local mWidget
local mCompetitionId
local mSubType
local mStep
local mCurrentTotalNum

-- DS for competitionDetail see CompetitionDetail
function loadFrame( competitionDetail, subType, competitionId )
    mCompetitionId = competitionId
    mSubType = subType

	local widget = GUIReader:shareReader():widgetFromJsonFile("scenes/CompetitionLeaderboard.json")
    mWidget = widget
    mWidget:registerScriptHandler( EnterOrExit )
    SceneManager.clearNAddWidget( widget )

    Navigator.loadFrame( widget )
    local backBt = mWidget:getChildByName("back")
    backBt:addTouchEventListener( backEventHandler )
    local shareBt = mWidget:getChildByName("share")
    shareBt:addTouchEventListener( shareEventHandler )

    -- Init the title
    local title = tolua.cast( mWidget:getChildByName("title"), "Label" )
    title:setText( competitionDetail:getName() )

    -- Init the content
    initContent( competitionDetail )
    mStep = 1
end

function EnterOrExit( eventType )
    if eventType == "enter" then
    elseif eventType == "exit" then
        mWidget = nil
    end
end

function backEventHandler( sender, eventType )
    if eventType == TOUCH_EVENT_ENDED then
        EventManager:popHistory()
    end
end

function initContent( competitionDetail )
	local contentContainer = tolua.cast( mWidget:getChildByName("ScrollView"), "ScrollView" )
    contentContainer:removeAllChildrenWithCleanup( true )

    local layoutParameter = LinearLayoutParameter:create()
    layoutParameter:setGravity(LINEAR_GRAVITY_CENTER_VERTICAL)
    local contentHeight = 0

    -- Add the competition detail info
    local content = GUIReader:shareReader():widgetFromJsonFile("scenes/CompetitionLeaderboardInfo.json")
    local time = tolua.cast( content:getChildByName("time"), "Label" )
    local description = tolua.cast( content:getChildByName("description"), "Label" )
    local codeText = tolua.cast( content:getChildByName("codeText"), "Label" )

    time:setText( string.format( time:getStringValue(), 
                os.date( "%m/%d/%Y", competitionDetail:getStartTime() ), 
                os.date( "%m/%d/%Y", competitionDetail:getEndTime() ) ) )
    codeText:setText( string.format( codeText:getStringValue(), competitionDetail:getJoinToken() ) )
    description:setText( competitionDetail:getDescription() )

    content:setLayoutParameter( layoutParameter )
    contentContainer:addChild( content )
    contentHeight = contentHeight + content:getSize().height

    local showLeague = content:getChildByName("SelectLeague")
    showLeague:addTouchEventListener( showLeagueEventHandler )

    -- Add the leaderboard info
    local leaderboardInfo = competitionDetail:getDto()
    for i = 1, table.getn( leaderboardInfo ) do
    	local eventHandler = function( sender, eventType )
            if eventType == TOUCH_EVENT_ENDED then
                contentClick( leaderboardInfo[i] )
            end
        end

        local content = SceneManager.widgetFromJsonFile("scenes/LeaderboardListContent.json")
        content:setLayoutParameter( layoutParameter )
        contentContainer:addChild( content )
        contentHeight = contentHeight + content:getSize().height
        initLeaderboardContent( i, content, leaderboardInfo[i] )
        content:addTouchEventListener( eventHandler )
    end
    mCurrentTotalNum = table.getn( leaderboardInfo )

    -- Add the "More" button
    contentHeight = contentHeight + addMoreButton( contentContainer, layoutParameter ):getSize().height

    contentContainer:setInnerContainerSize( CCSize:new( 0, contentHeight ) )
    local layout = tolua.cast( contentContainer, "Layout" )
    layout:requestDoLayout()
end

function showLeagueEventHandler( sender, eventType )
    if eventType == TOUCH_EVENT_ENDED then
        EventManager:postEvent( Event.Enter_Competition_Leagues, { mCompetitionId } )
    end
end

function shareEventHandler( sender, eventTYpe )
    if eventType == TOUCH_EVENT_ENDED then
        
    end
end

function addMoreButton( contentContainer, layoutParameter )
    local content = SceneManager.widgetFromJsonFile("scenes/MoreContent.json")
    content:setLayoutParameter( layoutParameter )
    contentContainer:addChild( content )
    content:addTouchEventListener( loadMore )
    content:setName("More")

    return content
end

function initLeaderboardContent( i, content, info )
    local name = tolua.cast( content:getChildByName("name"), "Label" )
    local score = tolua.cast( content:getChildByName("score"), "Label" )
    local index = tolua.cast( content:getChildByName("index"), "Label" )
    local logo = tolua.cast( content:getChildByName("logo"), "ImageView" )

    if info["DisplayName"] == nil then
        name:setText( "Unknow name" )
    else
        name:setText( info["DisplayName"] )
    end
    score:setText( string.format( mSubType["description"], info[mSubType["dataColumnId"]] ) )
    index:setText( i )


    local seqArray = CCArray:create()
    seqArray:addObject( CCDelayTime:create( i * 0.2 ) )
    seqArray:addObject( CCCallFuncN:create( function()
        if info["PictureUrl"] ~= nil then
            local handler = function( filePath )
                if filePath ~= nil and mWidget ~= nil then
                    logo:loadTexture( filePath )
                    logo:setScale( 1 )
                end
            end
            SMIS.getSMImagePath( info["PictureUrl"], handler )
        end
    end ) )

    mWidget:runAction( CCSequence:create( seqArray ) )
end

function loadMore( sender, eventType )
    if eventType == TOUCH_EVENT_ENDED then
        mStep = mStep + 1
        EventManager:postEvent( Event.Load_More_In_Competition_Detail, { mCompetitionId, mStep } )
    end
end

function loadMoreContent( leaderboardInfo )
    local contentContainer = tolua.cast( mWidget:getChildByName("ScrollView"), "ScrollView" )

    -- Remove the "More" button
    local moreButton = contentContainer:getChildByName("More")
    moreButton:removeFromParent()

    local layoutParameter = LinearLayoutParameter:create()
    layoutParameter:setGravity(LINEAR_GRAVITY_CENTER_VERTICAL)
    local contentHeight = contentContainer:getInnerContainerSize().height

    for i = 1, table.getn( leaderboardInfo ) do
        local eventHandler = function( sender, eventType )
            if eventType == TOUCH_EVENT_ENDED then
                contentClick( leaderboardInfo[i] )
            end
        end

        local content = SceneManager.widgetFromJsonFile("scenes/LeaderboardListContent.json")
        content:setLayoutParameter( layoutParameter )
        contentContainer:addChild( content )
        contentHeight = contentHeight + content:getSize().height
        initLeaderboardContent( mCurrentTotalNum + i, content, leaderboardInfo[i] )
        content:addTouchEventListener( eventHandler )
    end
    mCurrentTotalNum = mCurrentTotalNum + table.getn( leaderboardInfo )

    if table.getn( leaderboardInfo ) > 0 then
        -- Add back the "More" button
        addMoreButton( contentContainer, layoutParameter )
    end

    contentContainer:setInnerContainerSize( CCSize:new( 0, contentHeight ) )
    local layout = tolua.cast( contentContainer, "Layout" )
    layout:requestDoLayout()
end

function contentClick( info )
    local id = info["Id"]
    local name = "Unknow name"
    if info["DisplayName"] ~= nil then
        name = info["DisplayName"]
    end
    EventManager:postEvent( Event.Enter_History, { id, name } )
end