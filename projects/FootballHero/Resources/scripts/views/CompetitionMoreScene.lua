module(..., package.seeall)

local SceneManager = require("scripts.SceneManager")
local Navigator = require("scripts.views.Navigator")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local SMIS = require("scripts.SMIS")
local ViewUtils = require("scripts.views.ViewUtils")
local Logic = require("scripts.Logic").getInstance()
local Constants = require("scripts.Constants")
local CompetitionType = require("scripts.data.Competitions").CompetitionType
local CountryConfig = require("scripts.config.Country")
local LeagueConfig = require("scripts.config.League")

local mWidget
local mCompetitionId
local mCompetitionToken

-- DS for competitionDetail see CompetitionDetail
function loadFrame( selectedLeagues, competitionId )
    competitionDetail = Logic:getCompetitionDetail()
    mCompetitionId = competitionId
    mCompetitionToken = competitionDetail:getJoinToken()

	local widget = GUIReader:shareReader():widgetFromJsonFile("scenes/CompetitionMore.json")
    mWidget = widget
    mWidget:registerScriptHandler( EnterOrExit )
    SceneManager.clearNAddWidget( mWidget )
    SceneManager.setKeypadBackListener( keypadBackEventHandler )

    Navigator.loadFrame( mWidget )

    -- Init the title
    local title = tolua.cast( mWidget:getChildByName("title"), "Label" )
    title:setText( competitionDetail:getName() )
    local backBt = mWidget:getChildByName("back")
    backBt:addTouchEventListener( backEventHandler )
    
    initContent( competitionDetail, selectedLeagues )
end

function EnterOrExit( eventType )
    if eventType == "enter" then
    elseif eventType == "exit" then
        mWidget = nil
    end
end

function backEventHandler( sender, eventType )
    if eventType == TOUCH_EVENT_ENDED then
        keypadBackEventHandler()
    end
end

function leaveEventHandler( sender, eventType )
    if eventType == TOUCH_EVENT_ENDED then
        local yesCallback = function()
            EventManager:postEvent( Event.Do_Leave_Competition, { mCompetitionId } )
        end

        local noCallback = function()
        end

        EventManager:postEvent( Event.Show_Choice_Message, { Constants.String.choice.leave_comp_title, Constants.String.choice.leave_comp_desc, yesCallback, noCallback } )
    end
end

function rulesEventHandler( sender, eventType )
    if eventType == TOUCH_EVENT_ENDED then
        local title = tolua.cast( mWidget:getChildByName("title"), "Label" )
        local titleText = title:getStringValue()
        EventManager:postEvent( Event.Enter_Competition_Rules, { titleText, mCompetitionToken } )
    end
end

function termsEventHandler( sender, eventType )
    if eventType == TOUCH_EVENT_ENDED then
        local title = tolua.cast( mWidget:getChildByName("title"), "Label" )
        local titleText = title:getStringValue()
        EventManager:postEvent( Event.Enter_Competition_Terms, { titleText, mCompetitionToken } )
    end
end

function keypadBackEventHandler()
    EventManager:popHistory()
end

function initContent( competitionDetail, selectedLeagues )
    local contentContainer = tolua.cast( mWidget:getChildByName("ScrollView"), "ScrollView" )
    contentContainer:removeAllChildrenWithCleanup( true )

    local layoutParameter = LinearLayoutParameter:create()
    layoutParameter:setGravity(LINEAR_GRAVITY_CENTER_VERTICAL)
    mContainerHeight = 0

    if competitionDetail:getCompetitionType() ~=CompetitionType["Private"] then
        -- Competition Banner
        local banner = GUIReader:shareReader():widgetFromJsonFile("scenes/CommunityCompetitionBannerFrame.json")
        local joinBtn = banner:getChildByName("Button_Join")
        joinBtn:setEnabled( false )
        local bannerBG = tolua.cast( banner:getChildByName("Image_BannerBG"), "ImageView" )
        bannerBG:loadTexture( Constants.COMPETITION_IMAGE_PATH..Constants.BannerPrefix..mCompetitionToken..".png" )
        
        banner:setLayoutParameter( layoutParameter )
        contentContainer:addChild( banner )
        mContainerHeight = mContainerHeight + banner:getSize().height
    end

    -- Add the competition detail info
    local content = GUIReader:shareReader():widgetFromJsonFile("scenes/CompetitionMoreContent.json")
    content:setLayoutParameter( layoutParameter )
    contentContainer:addChild( content )
    mContainerHeight = mContainerHeight + content:getSize().height

    local time = tolua.cast( content:getChildByName("time"), "Label" )
    local description = tolua.cast( content:getChildByName("description"), "Label" )
    if competitionDetail:getEndTime() == 0 then
        time:setText( string.format( Constants.String.duration_forever, 
                os.date( "%m/%d/%Y", competitionDetail:getStartTime() ) ) )
    else
        time:setText( string.format( Constants.String.duration_to, 
                os.date( "%m/%d/%Y", competitionDetail:getStartTime() ), 
                os.date( "%m/%d/%Y", competitionDetail:getEndTime() ) ) )
    end
    
    description:setText( competitionDetail:getDescription() )

    initSelectedLeagues( contentContainer, selectedLeagues )

    mContainerHeight = contentContainer:getInnerContainerSize().height
    contentContainer:setInnerContainerSize( CCSize:new( 0, mContainerHeight ) )
    local layout = tolua.cast( contentContainer, "Layout" )
    layout:requestDoLayout()

    local normalPanel = mWidget:getChildByName("Panel_Normal")
    local specialPanel = mWidget:getChildByName("Panel_Special")

    if competitionDetail:getCompetitionType() == CompetitionType["Private"] then
        specialPanel:setEnabled( false )

        local quitBtn = normalPanel:getChildByName("Button_Quit")
        quitBtn:addTouchEventListener( leaveEventHandler )
    else
        normalPanel:setEnabled( false )

        local quitBtn = specialPanel:getChildByName("Button_Quit")
        quitBtn:addTouchEventListener( leaveEventHandler )

        local termsBtn = specialPanel:getChildByName("Button_TnC")
        termsBtn:addTouchEventListener( termsEventHandler )

        local rulesBtn = specialPanel:getChildByName("Button_Rules")
        rulesBtn:addTouchEventListener( rulesEventHandler )
    end
end

function isInSelectedLeague( leagueId, selectedLeagues )
    for i = 1, table.getn( selectedLeagues ) do
        if selectedLeagues[i] == leagueId then
            return true
        end
    end

    return false
end

function initSelectedLeagues( contentContainer, selectedLeagues )
    local childIndex = 1
    for i = 1, CountryConfig.getConfigNum() do
        local leagueNum = table.getn( CountryConfig.getLeagueList( i ) )
        for j = 1, leagueNum do
            local leagueId = CountryConfig.getLeagueList( i )[j]

            if isInSelectedLeague( LeagueConfig.getConfigId( leagueId ), selectedLeagues ) then
                local content = SceneManager.widgetFromJsonFile( "scenes/LeagueContentWithTransparentBG.json" )
                contentContainer:addChild( content, 0, childIndex )
                
                local logo = tolua.cast( content:getChildByName("countryLogo"), "ImageView" )
                local leagueName = tolua.cast( content:getChildByName("countryName"), "Label" )
                
                leagueName:setText( CountryConfig.getCountryName( i ).." - "..LeagueConfig.getLeagueName( leagueId ) )
                logo:loadTexture( CountryConfig.getLogo( i ) )

                mContainerHeight = mContainerHeight + content:getSize().height
                childIndex = childIndex + 1
            end
        end
    end

    contentContainer:setInnerContainerSize( CCSize:new( 0, mContainerHeight ) )
    local layout = tolua.cast( contentContainer, "Layout" )
    layout:requestDoLayout()
    layout:setLayoutType(LAYOUT_LINEAR_VERTICAL)
end
