module(..., package.seeall)

local SceneManager = require("scripts.SceneManager")
local Navigator = require("scripts.views.Navigator")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local CommunityConfig = require("scripts.config.Community")
local ViewUtils = require("scripts.views.ViewUtils")
local Constants = require("scripts.Constants")
local Competitions = require("scripts.data.Competitions").Competitions
local CompetitionType = require("scripts.data.Competitions").CompetitionType
local CompetitionStatus = require("scripts.data.Competitions").CompetitionStatus
local CompetitionConfig = require("scripts.data.Competitions")
local ConnectingMessage = require("scripts.views.ConnectingMessage")
local Logic = require("scripts.Logic").getInstance()

local MAX_CONTAINER_HEIGHT = 560

local mWidget

-- DS, see Competitions.lua
function loadFrame( parent, compList, miniGame )
    --local competitionFrame = SceneManager.widgetFromJsonFile("scenes/CommunityCompetitionFrame.json")
    --parent:addChild( competitionFrame )
    
    initCompetitionScene( parent, compList, miniGame )
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

function initCompetitionScene( competitionFrame, compList, miniGame )
    
    local newCompFrame = SceneManager.widgetFromJsonFile("scenes/CommunityNewCompetitionFrame.json")
    local joinedCompFrame = SceneManager.widgetFromJsonFile("scenes/CommunityJoinedCompetitionFrame.json")
    
    local contentHeight = 0

    competitionFrame:addChild( newCompFrame )
    contentHeight = contentHeight + newCompFrame:getSize().height
    
    -- check for mini game
    -- TODO: check competition period
    --if shouldShowMiniGame() and not miniGame["Joined"] then
    if not miniGame["Joined"] then
        contentHeight = contentHeight + initMiniGame( competitionFrame, miniGame )
    end

    -- add banner frame if special competition exists
    local specialCompList = compList:getSpecialCompetitions()
    --if next(specialCompList) ~= nil then
    if table.getn( specialCompList ) > 0 then
        contentHeight = contentHeight + initSpecialCompetitions( competitionFrame, specialCompList )
    end
    
    competitionFrame:addChild( joinedCompFrame )

    local createEventHandler = function( sender, eventType )
        if eventType == TOUCH_EVENT_ENDED then
            EventManager:postEvent( Event.Enter_Create_Competition )
        end
    end
    local joinEventHandler = function( sender, eventType )
        if eventType == TOUCH_EVENT_ENDED then
            local token = newCompFrame:getChildByName( "Panel_Code" ):getNodeByTag( 1 ):getText()
            EventManager:postEvent( Event.Do_Join_Competition, { token } )
        end
    end

    local btnNew = newCompFrame:getChildByName("Button_New")
    btnNew:addTouchEventListener( createEventHandler )
    local btnJoin = newCompFrame:getChildByName("Button_Join")
    btnJoin:addTouchEventListener( joinEventHandler )

    local joinedHeaderBG = joinedCompFrame:getChildByName( "Image_BG_Joined_Comps" )
    contentHeight = contentHeight + joinedHeaderBG:getSize().height

    local scrollBG = joinedCompFrame:getChildByName( "Panel_BG_Joined_Comp" )
    local scrollViewJoined = tolua.cast( joinedCompFrame:getChildByName("ScrollView_Joined_Comp"), "ScrollView" )
    -- bug! layout type is automatically set to LAYOUT_ABSOLUTE(0) ???
    scrollViewJoined:setLayoutType(LAYOUT_LINEAR_VERTICAL) 
    
    local panelNone = scrollBG:getChildByName("Panel_No_Comp")
    if compList:getSize() > 0 or miniGame["Joined"] then
        panelNone:setEnabled( false )
        scrollViewJoined:setEnabled( true )
        scrollViewJoined:removeAllChildrenWithCleanup( true )

        local height = 0
        local layoutParameter = LinearLayoutParameter:create()
        layoutParameter:setGravity(LINEAR_GRAVITY_CENTER_VERTICAL)

        if miniGame["Joined"] then
            local eventHandler = function( sender, eventType )
                if eventType == TOUCH_EVENT_ENDED then
                    enterMinigame( miniGame )
                end
            end
            
            local content = SceneManager.widgetFromJsonFile("scenes/CompetitionItemNew.json")
            content:setLayoutParameter( layoutParameter )
            scrollViewJoined:addChild( content )
            height = height + content:getSize().height

            local bt = tolua.cast( content:getChildByName("Panel_Button"), "Layout" )
            bt:addTouchEventListener( eventHandler )
            
            bt:setBackGroundImage( Constants.COMPETITION_IMAGE_PATH..Constants.EntryPrefix.."shoottowin"..".png" )

            local name = tolua.cast( content:getChildByName("Label_Name"), "Label" )
            name:setEnabled( false )
        end

        for i = 1, compList:getSize() do
            local competition = compList:get(i)

            if competition["CompetitionStatus"] == CompetitionStatus["Joined"] then

                local eventHandler = function( sender, eventType )
                    if eventType == TOUCH_EVENT_ENDED then
                        enterCompetition( competition["Id"],  competition["CompetitionType"] ~=CompetitionType["Private"] )
                    end
                end
                
                local content = SceneManager.widgetFromJsonFile("scenes/CompetitionItemNew.json")
                content:setLayoutParameter( layoutParameter )
                scrollViewJoined:addChild( content )
                height = height + content:getSize().height

                local name = tolua.cast( content:getChildByName("Label_Name"), "Label" )
                name:setText( competition["Name"] )

                local bt = tolua.cast( content:getChildByName("Panel_Button"), "Layout" )
                bt:addTouchEventListener( eventHandler )
                
                if competition["CompetitionType"] ~=CompetitionType["Private"] then
                    bt:setBackGroundImage( Constants.COMPETITION_IMAGE_PATH..Constants.EntryPrefix..competition["JoinToken"]..".png" )
                    name:setEnabled( false )
                end

                --[[if i == compList:getSize() then
                    local separator = content:getChildByName("Image_Separator")
                    separator:setEnabled( false )
                end]]--
            end
        end

        local originalHeight = scrollViewJoined:getInnerContainerSize().height
        local scrollHeight = math.max( height, originalHeight )
        local newContainerHeight = math.min( MAX_CONTAINER_HEIGHT, scrollHeight )
        local deltaY = math.max( newContainerHeight - originalHeight, 0 )

        scrollViewJoined:setInnerContainerSize( CCSize:new( 0, scrollHeight ) )
        scrollViewJoined:setSize( CCSize:new( scrollViewJoined:getSize().width, newContainerHeight ) )
        scrollViewJoined:setPositionY( scrollViewJoined:getPositionY() - deltaY )

        local scrollBGDeltaY = scrollBG:getSize().height - originalHeight
        scrollBG:setSize( CCSize:new( scrollBG:getSize().width, newContainerHeight + scrollBGDeltaY ) )
        scrollBG:setPositionY( scrollBG:getPositionY() - deltaY )
        contentHeight = contentHeight + scrollBG:getSize().height

        local layout = tolua.cast( scrollViewJoined, "Layout" )
        layout:requestDoLayout()
    else
        scrollViewJoined:setEnabled( false )
        local btnCreate = panelNone:getChildByName("Button_Create")
        btnCreate:addTouchEventListener( createEventHandler )

        local lblCTA = tolua.cast( panelNone:getChildByName("Label_CTA"), "Label" )
        lblCTA:setText( Constants.String.community.label_call_to_arm )
    end

    local tokenInput = ViewUtils.createTextInput( newCompFrame:getChildByName( "Panel_Code" ), Constants.String.enter_comp_code, 224 )
    tokenInput:setFontColor( ccc3( 0, 0, 0 ) )
    tokenInput:setPlaceholderFontColor( ccc3( 127, 127, 127 ) )
    tokenInput:setTouchPriority( SceneManager.TOUCH_PRIORITY_MINUS_ONE )
    local inputDelegate = EditBoxDelegateForLua:create()
    inputDelegate:registerEventScriptHandler( EDIT_BOX_EVENT_DID_BEGIN, function ( textBox )
        -- In order not to change the object-c code, here is the work around.
        -- recall the setPosition() to invoke the CCEditBoxImplIOS::adjustTextFieldPosition()
        -- Todo remove this code after the object-c fix is pushed out.
        tokenInput:setPosition( tokenInput:getPosition() )
    end )
    newCompFrame:getChildByName( "Panel_Code" ):addNode( tolua.cast( inputDelegate, "CCNode" ) )
    tokenInput:setDelegate( inputDelegate.__CCEditBoxDelegate__ )

    competitionFrame:setInnerContainerSize( CCSize:new( 0, contentHeight ) )
    local layout = tolua.cast( competitionFrame, "Layout" )
    layout:requestDoLayout()
end

function initMiniGame( parent, miniGame )
    local contentHeight = 0

    local bannerFrame = SceneManager.widgetFromJsonFile("scenes/CommunityCompetitionBannerFrame.json")
    
    local bannerBG = tolua.cast( bannerFrame:getChildByName( "Image_BannerBG" ), "ImageView" )
    bannerBG:loadTexture(  Constants.COMPETITION_IMAGE_PATH..Constants.BannerPrefix.."shoottowin"..".png" )

    local joinEventHandler = function( sender, eventType )
        if eventType == TOUCH_EVENT_ENDED then
            checkFacebookAndOpenWebview()
        end
    end
    local joinBtn = bannerFrame:getChildByName( "Button_Join" )
    joinBtn:addTouchEventListener( joinEventHandler )
    parent:addChild( bannerFrame )
    contentHeight = contentHeight + bannerFrame:getSize().height

    return contentHeight
end

function shouldShowMiniGame()
    
    local minigameStage = CCUserDefault:sharedUserDefault():getIntegerForKey( Constants.EVENT_NEXT_MINIGAME_STAGE )
    local bShouldShow = false

    if minigameStage == Constants.MINIGAME_STAGE_ENDED then
        -- Already played, do not show
        print( "Already joined minigame" )
    else
        bShouldShow = true
    end
    
    return bShouldShow
end

function setMiniGameEndStage()
    -- No more minigame popup
    print( "No more minigame popup" )
    CCUserDefault:sharedUserDefault():setIntegerForKey( Constants.EVENT_NEXT_MINIGAME_STAGE, Constants.MINIGAME_STAGE_ENDED )
end

function checkFacebookAndOpenWebview()

    local openWebview = function()
        local handler = function( accessToken, success )
            if success then
                -- already has permission
                if accessToken == nil then
                    accessToken = Logic:getFBAccessToken()
                end
                setMiniGameEndStage()
                EventManager:postEvent( Event.Enter_Minigame, { accessToken } )
            else
                ConnectingMessage.selfRemove()
            end
        end
        ConnectingMessage.loadFrame()
        FacebookDelegate:sharedDelegate():grantPublishPermission( "publish_actions", handler )
    end

    if Logic:getFbId() == false then
        local successHandler = function()
            openWebview()
        end
        local failedHandler = function()
            -- Nothing to do.
        end
        EventManager:postEvent( Event.Do_FB_Connect_With_User, { successHandler, failedHandler } )
    else
        openWebview()
    end
end

function initSpecialCompetitions( parent, compList )
    local contentHeight = 0
    -- Add the available ones.
    for i = 1, table.getn( compList ) do
        local competition = compList[i]

        if competition["CompetitionType"] ~= CompetitionType["Preview"] and competition["CompetitionStatus"] == CompetitionStatus["Available"] then
            local bannerFrame = SceneManager.widgetFromJsonFile("scenes/CommunityCompetitionBannerFrame.json")
            
            local bannerBG = tolua.cast( bannerFrame:getChildByName( "Image_BannerBG" ), "ImageView" )
            bannerBG:loadTexture(  Constants.COMPETITION_IMAGE_PATH..Constants.BannerPrefix..competition["JoinToken"]..".png" )

            local joinEventHandler = function( sender, eventType )
                if eventType == TOUCH_EVENT_ENDED then
                    EventManager:postEvent( Event.Do_Join_Competition, { competition["JoinToken"] } )
                end
            end
            local joinBtn = bannerFrame:getChildByName( "Button_Join" )
            joinBtn:addTouchEventListener( joinEventHandler )
            parent:addChild( bannerFrame )
            contentHeight = contentHeight + bannerFrame:getSize().height
        end
    end

    -- Add the preview ones.
    for i = 1, table.getn( compList ) do
        local competition = compList[i]

        if competition["CompetitionType"] == CompetitionType["Preview"] then
            local bannerFrame = SceneManager.widgetFromJsonFile("scenes/CommunityCompetitionBannerFrame.json")
            
            local bannerBG = tolua.cast( bannerFrame:getChildByName( "Image_BannerBG" ), "ImageView" )
            bannerBG:loadTexture(  Constants.COMPETITION_IMAGE_PATH..Constants.BannerPreviewPrefix..competition["JoinToken"]..".png" )

            local joinBtn = bannerFrame:getChildByName( "Button_Join" )
            joinBtn:setEnabled( false )
            parent:addChild( bannerFrame )
            contentHeight = contentHeight + bannerFrame:getSize().height
        end
    end

    return contentHeight
end

function enterCompetition( competitionId, isSpecialComp )

    if isSpecialComp then
        EventManager:postEvent( Event.Enter_Competition_Detail, { competitionId, false, 3, CompetitionConfig.COMPETITION_TAB_ID_OVERALL } )
    else
        EventManager:postEvent( Event.Enter_Competition_Detail, { competitionId } )
    end
end

function enterMinigame( miniGame )
    EventManager:postEvent( Event.Enter_Minigame_Detail, { miniGame } )
end
