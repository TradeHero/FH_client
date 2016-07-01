module(..., package.seeall)

local Constants = require("scripts.Constants")
local SceneManager = require("scripts.SceneManager")
local CountryConfig = require("scripts.config.Country")
local LeagueConfig = require("scripts.config.League")
local TeamConfig = require("scripts.config.Team")
local SportsConfig = require("scripts.config.Sports")
local Navigator = require("scripts.views.Navigator")
local MatchListDropdownFrame = require("scripts.views.MatchListDropdownFrame")
local Logic = require("scripts.Logic").getInstance()
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local SMIS = require("scripts.SMIS")
local Json = require("json")
local ConnectingMessage = require("scripts.views.ConnectingMessage")
local CommunityConfig = require("scripts.config.Community")
local MatchCenterConfig = require("scripts.config.MatchCenter")
local Header = require("scripts.views.HeaderFrame")


local mWidget
local mTopLayer
local mOptionPanelShown
local mTheFirstDate = nil
local mStep
local mHasMoreToLoad

local MATCH_LIST_DROPDOWN_NAME = "matchListDropdown"
local MIN_MOVE_DISTANCE = 100
local OPTION_MOVE_TIME = 0.5
local OPTION_VIEW_OFFSET_X = 475

local CONTENT_FADEIN_TIME = 0.1
local CONTENT_DELAY_TIME = 0.2

function isShown()
    return mWidget ~= nil
end

function loadFrame( matchList, leagueKey )
	local widget = GUIReader:shareReader():widgetFromJsonFile("scenes/MatchListScene.json")
    mWidget = widget
    mWidget:registerScriptHandler( EnterOrExit )
    SceneManager.clearNAddWidget( widget )
    
    Header.loadFrame( widget, nil, false )
    Header.showLiveButton( true )
    Header.showMenuButtonWithSportChangeEventHanlder( sportChangeEventHandler )

    Navigator.loadFrame( widget )
    Navigator.chooseNav( 1 )

    mHasMoreToLoad = true

    initLeagueList( leagueKey )

    -- Init the match list according to the data.
    initMatchList( matchList, leagueKey, true )

    -- Init the toplayer to listen to the swap action.
    --[[
    mTopLayer = CCLayer:create()
    mTopLayer:registerScriptTouchHandler( onTopLevelTouch, false, -100)
    mWidget:addNode( mTopLayer )
    mTopLayer:setTouchEnabled( true )
    mOptionPanelShown = false
    --]]
end

function EnterOrExit( eventType )
    if eventType == "enter" then
    elseif eventType == "exit" then
        -- if not Logic:getBetBlock() then
        --     WebviewDelegate:sharedDelegate():closeWebpage()
        -- end
        mWidget = nil
    end
end

function initLeagueList( leagueKey )
    SceneManager.clearKeypadBackListener()
    
    local content = SceneManager.widgetFromJsonFile("scenes/MatchListDropDown.json")
    mWidget:addChild( content )
    content:setName( MATCH_LIST_DROPDOWN_NAME )

    local countryList = tolua.cast( content:getChildByName( "ScrollView_Country"), "ScrollView" )
    local leagueList = tolua.cast( content:getChildByName( "ScrollView_League"), "ScrollView" )
    local countryExpand = content:getChildByName( "Button_CountryExpand" )
    local leagueExpand = content:getChildByName( "Button_LeagueExpand" )
    local countryButton = content:getChildByName("Button_Country")
    local leagueButton = content:getChildByName("Button_League")
    local mask =  content:getChildByName( "Panel_Mask" )

    local countryButtonEventHandler = function( sender, eventType )
        if eventType == TOUCH_EVENT_ENDED then
            if countryList:isEnabled() then
                mask:setEnabled( false )
                countryList:setEnabled( false )
                countryExpand:setBrightStyle( BRIGHT_NORMAL )
            else
                mask:setEnabled( true )
                countryList:setEnabled( true )
                countryExpand:setBrightStyle( BRIGHT_HIGHLIGHT )
                leagueList:setEnabled( false )
                leagueExpand:setBrightStyle( BRIGHT_NORMAL )
            end
        end
    end
    countryButton:addTouchEventListener( countryButtonEventHandler )

    local leagueButtonEventHandler = function( sender, eventType )
        if eventType == TOUCH_EVENT_ENDED then
            if leagueList:isEnabled() then
                mask:setEnabled( false )
                leagueList:setEnabled( false )
                leagueExpand:setBrightStyle( BRIGHT_NORMAL )
            else
                mask:setEnabled( true )
                leagueList:setEnabled( true )
                leagueExpand:setBrightStyle( BRIGHT_HIGHLIGHT )
                countryList:setEnabled( false )
                countryExpand:setBrightStyle( BRIGHT_NORMAL )
            end
        end
    end
    leagueButton:addTouchEventListener( leagueButtonEventHandler )

    leagueList:setEnabled( false )
    countryList:setEnabled( false )
    mask:setEnabled( false )

    local initCurrentCountryLeague = function( leagueKey )
        local logo = tolua.cast( content:getChildByName( "Image_CountryLogo" ), "ImageView" )
        local countryName = tolua.cast( content:getChildByName( "Label_CountryName"), "Label" )
        local leagueName = tolua.cast( content:getChildByName( "Label_LeagueName"), "Label" )

        -- Hardcode Popular League texts and logo
        if Constants.IsSpecialLeague( leagueKey ) then
            countryName:setText( Constants.String.match_list.special )
            if leagueKey == Constants.SpecialLeagueIds.MOST_POPULAR then
                leagueName:setText( Constants.String.match_list.most_popular )
            elseif leagueKey == Constants.SpecialLeagueIds.UPCOMING_MATCHES then
                leagueName:setText( Constants.String.match_list.upcoming_matches )
            elseif leagueKey == Constants.SpecialLeagueIds.TEAM_EXPERT then
                leagueName:setText(  Constants.String.match_list.team_expert )
            elseif leagueKey == Constants.SpecialLeagueIds.MOST_DISCUSSED then
                leagueName:setText( Constants.String.match_list.most_discussed )
            end

            logo:loadTexture( Constants.COUNTRY_IMAGE_PATH.."favorite.png" )
            --leagueButton:setTouchEnabled( false )
            --leagueExpand:setEnabled( false )
        else
            local leagueId = LeagueConfig.getConfigIdByKey( leagueKey )
            local countryId = CountryConfig.getConfigIdByKey( LeagueConfig.getCountryId( leagueId ) )
            
            countryName:setText( CountryConfig.getCountryName( countryId ) )
            leagueName:setText( LeagueConfig.getLeagueName( leagueId ) )
            logo:loadTexture( CountryConfig.getLogo( countryId ) )
            --leagueButton:setTouchEnabled( true )
            --leagueExpand:setEnabled( true )
        end
    end

    
    local leagueSelectedCallback = function( leagueKey )
        mask:setEnabled( false )
        countryList:setEnabled( false )
        countryExpand:setBrightStyle( BRIGHT_NORMAL )
        leagueList:setEnabled( false )
        leagueExpand:setBrightStyle( BRIGHT_NORMAL )
        
        initCurrentCountryLeague( leagueKey )

        mWidget:stopAllActions()
        EventManager:postEvent( Event.Enter_Match_List, { leagueKey } )
    end

    MatchListDropdownFrame.loadFrame( leagueKey, "scenes/CountryDropdownContent.json", "scenes/LeagueDropdownContent.json", 
        countryList, leagueList, leagueSelectedCallback )

    initCurrentCountryLeague( leagueKey )
end

-- Param matchList is Object of MatchListData
function initMatchList( matchList, leagueKey, bInit )
    if not bInit then
        MatchListDropdownFrame.initLeagueList( leagueKey )
    end

    mStep = 1

    local predictionScene = SceneManager.getWidgetByName( "TappablePredictionScene" )
    local predictionConfirmScene = SceneManager.getWidgetByName( "PredTotalConfirmScene" )
    if predictionScene ~= nil then
        SceneManager.removeWidget( predictionScene )

        if predictionConfirmScene ~= nil then
            SceneManager.removeWidget( predictionConfirmScene )
        else
            -- Skip the refresh and show directly
            return
        end
    end

    local contentContainer = tolua.cast( mWidget:getChildByName("ScrollView"), "ScrollView" )
    contentContainer:removeAllChildrenWithCleanup( true )

    if leagueKey == Constants.SpecialLeagueIds.UPCOMING_MATCHES then
        contentContainer:addEventListenerScrollView( scrollViewEventHandler )
    else
        contentContainer:addEventListenerScrollView( scrollViewDoNothingEventHandler )
    end

    local seqArray = CCArray:create()
    seqArray:addObject( CCDelayTime:create( 0.3 ) )
    seqArray:addObject( CCCallFunc:create( function()
        local layoutParameter = LinearLayoutParameter:create()
        layoutParameter:setGravity(LINEAR_GRAVITY_CENTER_VERTICAL)
        local contentHeight = 0
        
        if leagueKey == Constants.SpecialLeagueIds.MOST_POPULAR or leagueKey == Constants.SpecialLeagueIds.MOST_DISCUSSED then
            
            -- if not Logic:getBetBlock() then
            --     WebviewDelegate:sharedDelegate():openWebpage(  "http://spiritrain.tk/home.html", 0, 145 , 640, 120)
            -- end
            if Logic:getBetBlock() then
            -- if false then
                local friendReferal = SceneManager.widgetFromJsonFile("scenes/MatchListFriendsReferal.json")
                local referalButton = friendReferal:getChildByName("Button_refer")
                referalButton:addTouchEventListener( function( sender, eventType )
                    if eventType == TOUCH_EVENT_ENDED then
                        EventManager:postEvent( Event.Enter_Friend_Referal )
                    end
                end )

                friendReferal:setLayoutParameter( layoutParameter )
                contentContainer:addChild( friendReferal )
                contentHeight = contentHeight + friendReferal:getSize().height           
            else
                -- WebviewDelegate:sharedDelegate():openWebpage(  "http://spiritrain.tk/home.html", 0, 145 , 640, 120)

                -- ad banner
                local betHandler = function ( sender, eventType )
                    if eventType == TOUCH_EVENT_ENDED then
                        EventManager:postEvent( Event.Enter_Bet365 )
                    end
                end
                local content = SceneManager.widgetFromJsonFile( "scenes/MatchListFriendsReferal.json" )
                local referalButton = tolua.cast( content:getChildByName("Button_refer"), "Button" )
                referalButton:addTouchEventListener( betHandler )
                referalButton:loadTextureNormal( Constants.IMAGE_PATH .. "ads/banner_home.jpg" )

                contentContainer:addChild( content )
                contentHeight = contentHeight + content:getSize().height
            end

            for i = 1, table.getn( matchList ) do
                local match = matchList[i]
                local eventHandler = function( sender, eventType )
                    if eventType == TOUCH_EVENT_ENDED then
                        enterMatch( match )
                    end
                end

                local content = SceneManager.widgetFromJsonFile("scenes/MatchListContent.json")
                helperInitMatchInfo( content, match, leagueKey )

                content:setLayoutParameter( layoutParameter )
                contentContainer:addChild( content )
                contentHeight = contentHeight + content:getSize().height

                content:addTouchEventListener( eventHandler )

                if i == table.getn( matchList ) then
                    local separator = content:getChildByName("Panel_Separator")
                    separator:setEnabled( false )
                end

                content:setOpacity( 0 )
                content:setCascadeOpacityEnabled( true )
                mWidget:runAction( CCTargetedAction:create( content, CCFadeIn:create( CONTENT_FADEIN_TIME ) ) )
                
                updateContentContainer( contentHeight, content, true )
            end

        else
            mTheFirstDate = nil
            for k,v in pairs( matchList:getMatchDateList() ) do
                local matchDate = v

                -- Vincent: for most popular leagues, there are no matches before the "Tap to make a prediction!" hint, thus there is no need for zOrder position shifting
                local zOrder = matchDate["date"]
            
                local content = SceneManager.widgetFromJsonFile("scenes/MatchDate.json")
                local dateDisplay = tolua.cast( content:getChildByName("Label_Date"), "Label" )
                local timeDisplay = tolua.cast( content:getChildByName("Label_Time"), "Label" )
                dateDisplay:setText( matchDate["dateDisplay"] )
                timeDisplay:setText( matchDate["timeDisplay"] )
                content:setLayoutParameter( layoutParameter )
                content:setZOrder( zOrder )

                if mTheFirstDate == nil then
                    local hintContent = SceneManager.widgetFromJsonFile("scenes/TapToMakePrediction.json")

                    local hintText = tolua.cast( hintContent:getChildByName("Label_Tap"), "Label" )
                    hintText:setText( Constants.String.match_prediction.hint_tap )

                    hintContent:setLayoutParameter( layoutParameter )
                    hintContent:setZOrder( zOrder )
                    contentContainer:addChild( hintContent )
                    contentHeight = contentHeight + hintContent:getSize().height

                    mTheFirstDate = content
                end

                -- Add the date
                contentContainer:addChild( content )
                contentHeight = contentHeight + content:getSize().height

                content:setOpacity( 0 )
                content:setCascadeOpacityEnabled( true )
                mWidget:runAction( CCTargetedAction:create( content, CCFadeIn:create( CONTENT_FADEIN_TIME ) ) )

                local i = 1
                for inK, inV in pairs( matchDate["matches"] ) do
                    local eventHandler = function( sender, eventType )
                        if eventType == TOUCH_EVENT_ENDED then
                            enterMatch( inV )
                        end
                    end

                    local content = SceneManager.widgetFromJsonFile("scenes/MatchListContent.json")
                    helperInitMatchInfo( content, inV, leagueKey )

                    content:setLayoutParameter( layoutParameter )
                    content:setZOrder( zOrder )
                    contentContainer:addChild( content )
                    contentHeight = contentHeight + content:getSize().height

                    content:addTouchEventListener( eventHandler )

                    if i == table.getn( matchDate["matches"] ) then
                        local separator = content:getChildByName("Panel_Separator")
                        separator:setEnabled( false )
                    end

                    content:setOpacity( 0 )
                    content:setCascadeOpacityEnabled( true )
                    mWidget:runAction( CCTargetedAction:create( content, CCFadeIn:create( CONTENT_FADEIN_TIME ) ) )
                    
                    updateContentContainer( contentHeight, content )

                    i = i + 1
                end
            end
        end

        if contentContainer:getChildrenCount() == 0 then
            local content = SceneManager.widgetFromJsonFile("scenes/MatchListEmptyIndi.json")
            content:setLayoutParameter( layoutParameter )
            contentContainer:addChild( content )
            contentHeight = contentHeight + content:getSize().height
            updateContentContainer( contentHeight, content )
        end
    end ) )

    --seqArray:addObject( CCCallFunc:create( checkMiniGame ) )
    
    mWidget:runAction( CCSequence:create( seqArray ) )
end

function extendMatchList( matchList )
    if table.getn( matchList:getMatchDateList() ) == 0 then
        mHasMoreToLoad = false
        return
    end
    
    local contentContainer = tolua.cast( mWidget:getChildByName("ScrollView"), "ScrollView" )
    
    local seqArray = CCArray:create()
    seqArray:addObject( CCDelayTime:create( 0.3 ) )
    seqArray:addObject( CCCallFunc:create( function()
        local layoutParameter = LinearLayoutParameter:create()
        layoutParameter:setGravity(LINEAR_GRAVITY_CENTER_VERTICAL)
        -- There will be a slight bug if container height < default container height of 900... 
        -- 1 match = about 303 height, 3 matches = 906
        local contentHeight = contentContainer:getInnerContainerSize().height
        
        for k,v in pairs( matchList:getMatchDateList() ) do
            local matchDate = v

            local zOrder = matchDate["date"]
        
            local content = SceneManager.widgetFromJsonFile("scenes/MatchDate.json")
            local dateDisplay = tolua.cast( content:getChildByName("Label_Date"), "Label" )
            local timeDisplay = tolua.cast( content:getChildByName("Label_Time"), "Label" )
            dateDisplay:setText( matchDate["dateDisplay"] )
            timeDisplay:setText( matchDate["timeDisplay"] )
            content:setLayoutParameter( layoutParameter )
            content:setZOrder( zOrder )

            -- Add the date
            contentContainer:addChild( content )
            contentHeight = contentHeight + content:getSize().height

            content:setOpacity( 0 )
            content:setCascadeOpacityEnabled( true )
            mWidget:runAction( CCTargetedAction:create( content, CCFadeIn:create( CONTENT_FADEIN_TIME ) ) )

            local i = 1
            for inK, inV in pairs( matchDate["matches"] ) do
                local eventHandler = function( sender, eventType )
                    if eventType == TOUCH_EVENT_ENDED then
                        enterMatch( inV )
                    end
                end

                local content = SceneManager.widgetFromJsonFile("scenes/MatchListContent.json")
                helperInitMatchInfo( content, inV, leagueKey )

                content:setLayoutParameter( layoutParameter )
                content:setZOrder( zOrder )
                contentContainer:addChild( content )
                contentHeight = contentHeight + content:getSize().height

                content:addTouchEventListener( eventHandler )

                if i == table.getn( matchDate["matches"] ) then
                    local separator = content:getChildByName("Panel_Separator")
                    separator:setEnabled( false )
                end

                content:setOpacity( 0 )
                content:setCascadeOpacityEnabled( true )
                mWidget:runAction( CCTargetedAction:create( content, CCFadeIn:create( CONTENT_FADEIN_TIME ) ) )
                
                updateContentContainer( contentHeight, content )

                i = i + 1
            end
        end
    end ) )
    
    mWidget:runAction( CCSequence:create( seqArray ) )
end

function sendAnalytics( nextImageID, shared )
    local params
    if nextImageID == Constants.MINIGAME_IMAGE_ONE then
        params = { ImageOne = shared }
    else
        params = { ImageTwo = shared }
    end
    
    CCLuaLog("Send ANALYTICS_EVENT_MINIGAME_ACTION: "..Json.encode( params ) )
    Analytics:sharedDelegate():postEvent( Constants.ANALYTICS_EVENT_MINIGAME, Json.encode( params ) )
    Analytics:sharedDelegate():postFlurryEvent( Constants.ANALYTICS_EVENT_MINIGAME, Json.encode( params ) )
    Analytics:sharedDelegate():postTongdaoEvent( Constants.ANALYTICS_EVENT_MINIGAME, Json.encode( params ) )
end

function checkMiniGame()
    -- check if popup should appear
    local bFHCAppear = shouldShowFHC()
    
    local bMiniGameAppear = false 
    if Constants.MINIGAME_PK_ENABLED then
        bMiniGameAppear = shouldShowMiniGame()
    end

    if not bMiniGameAppear and not bFHCAppear then
        return
    end

    local closeEventHandler, playEventHandler, BG

    local minigamePopup = SceneManager.widgetFromJsonFile("scenes/MinigamePopup.json")
    minigamePopup:setZOrder( Constants.ZORDER_POPUP )
    mWidget:addChild( minigamePopup )

    if bMiniGameAppear then
        local nextImage = getNextMiniGameImage()
        closeEventHandler = function( sender, eventType )
            if eventType == TOUCH_EVENT_ENDED then
                sendAnalytics( nextImage, "closed" )
                -- save in localDB
                local stage = CCUserDefault:sharedUserDefault():getIntegerForKey( Constants.EVENT_NEXT_MINIGAME_STAGE )
                setMiniGameNextStage( stage )
                mWidget:removeChild(minigamePopup)
            end
        end

        playEventHandler = function( sender, eventType )
            if eventType == TOUCH_EVENT_ENDED then
                sendAnalytics( nextImage, "shared" )
                -- save in localDB
                setMiniGameNextStage( Constants.MINIGAME_STAGE_ENDED )
                mWidget:removeChild(minigamePopup)
                --checkFacebookAndOpenWebview()
            end
        end

        --local later = minigamePopup:getChildByName( "Button_Later" )
        --later:addTouchEventListener( closeEventHandler )

        --local play = minigamePopup:getChildByName( "Button_Play" )
        --play:addTouchEventListener( playEventHandler )

        -- Set Background Image, reposition buttons
        BG = tolua.cast( minigamePopup:getChildByName( "Image_BG" ), "ImageView" )
        BG:loadTexture( Constants.MINIGAME_IMAGE_PATH.."pop-out-"..nextImage..".png" )
        BG:addTouchEventListener( playEventHandler )

        --later:setPositionY( bgPos.y - bgSize.height / 2 + 75 )
        --play:setPositionY( bgPos.y - bgSize.height / 2 + 75 )

    elseif bFHCAppear then
        -- TODO: end date?
        -- FH Championship popup
        closeEventHandler = function( sender, eventType )
            if eventType == TOUCH_EVENT_ENDED then
                mWidget:removeChild(minigamePopup)
                CCUserDefault:sharedUserDefault():setIntegerForKey( Constants.EVENT_FHC_STATUS_KEY, Constants.EVENT_FHC_STATUS_OPENED )
            end
        end

        playEventHandler = function( sender, eventType )
            if eventType == TOUCH_EVENT_ENDED then
                mWidget:removeChild(minigamePopup)
                EventManager:postEvent( Event.Enter_Community, { CommunityConfig.COMMUNITY_TAB_ID_COMPETITION } )
                CCUserDefault:sharedUserDefault():setIntegerForKey( Constants.EVENT_FHC_STATUS_KEY, Constants.EVENT_FHC_STATUS_OPENED )
            end
        end

        BG = tolua.cast( minigamePopup:getChildByName( "Image_BG" ), "ImageView" )
        BG:loadTexture( Constants.COMPETITION_IMAGE_PATH.."popup_seacup15.png" )
        BG:addTouchEventListener( playEventHandler )
        --
    end

    local close = minigamePopup:getChildByName( "Button_Close" )
    close:addTouchEventListener( closeEventHandler )

    local mask = minigamePopup:getChildByName( "Panel_Mask" )
    mask:addTouchEventListener( closeEventHandler )

    local bgPos = ccp( BG:getPositionX(), BG:getPositionY() )
    local bgScale = BG:getScale()
    local bgSize = BG:getSize()
    
    close:setPosition( ccp( bgPos.x + bgSize.width / 2 * bgScale, bgPos.y + bgSize.height / 2 * bgScale ) )

end

function getNextMiniGameImage()
    local nextImage = CCUserDefault:sharedUserDefault():getIntegerForKey( Constants.EVENT_MINIGAME_NEXT_IMAGE )
    
    local image_id
    if nextImage == 0 then
        -- first image
        if Logic:getUserId() % 2 == 0 then
            image_id = Constants.MINIGAME_IMAGE_TWO 
            CCUserDefault:sharedUserDefault():setIntegerForKey( Constants.EVENT_MINIGAME_NEXT_IMAGE, Constants.MINIGAME_IMAGE_ONE )
        else
            image_id = Constants.MINIGAME_IMAGE_ONE 
            CCUserDefault:sharedUserDefault():setIntegerForKey( Constants.EVENT_MINIGAME_NEXT_IMAGE, Constants.MINIGAME_IMAGE_TWO )
        end
    else
        if nextImage == Constants.MINIGAME_IMAGE_ONE then
            image_id = Constants.MINIGAME_IMAGE_ONE 
            CCUserDefault:sharedUserDefault():setIntegerForKey( Constants.EVENT_MINIGAME_NEXT_IMAGE, Constants.MINIGAME_IMAGE_TWO )
        else
            image_id = Constants.MINIGAME_IMAGE_TWO 
            CCUserDefault:sharedUserDefault():setIntegerForKey( Constants.EVENT_MINIGAME_NEXT_IMAGE, Constants.MINIGAME_IMAGE_ONE )
        end
    end

    return image_id
end

function shouldShowMiniGame()
    local nowTimeStamp = os.time()
    local minigameStage = CCUserDefault:sharedUserDefault():getIntegerForKey( Constants.EVENT_NEXT_MINIGAME_STAGE )
    local nextTimeStamp = CCUserDefault:sharedUserDefault():getIntegerForKey( Constants.EVENT_NEXT_MINIGAME_TIME_KEY )
    local bShouldShow = false

    if minigameStage == Constants.MINIGAME_STAGE_ENDED then
        -- Already played, do not show
        print( "Already played, do not show" )
    elseif minigameStage == 0 then
        -- Next time does not exist, init
        print( "Next time does not exist, init" )
        setMiniGameNextStage( 0 )
    elseif nextTimeStamp < nowTimeStamp then
        print( "show popup" )
        bShouldShow = true
    else
        print( "waiting to show popup" )
    end
    
    return bShouldShow
end

function shouldShowFHC()
    local bShouldShow = false
    
    local stage = CCUserDefault:sharedUserDefault():getIntegerForKey( Constants.EVENT_FHC_STATUS_KEY )
    if stage ~= Constants.EVENT_FHC_STATUS_JOINED and stage ~= Constants.EVENT_FHC_STATUS_OPENED then
        bShouldShow = true
    end

    return bShouldShow
end

function setMiniGameNextStage( stage )
    --local stage = CCUserDefault:sharedUserDefault():getIntegerForKey( Constants.EVENT_NEXT_MINIGAME_STAGE )

    if stage == Constants.MINIGAME_STAGE_ENDED then
        -- No more minigame popup
        print( "No more minigame popup" )
        CCUserDefault:sharedUserDefault():setIntegerForKey( Constants.EVENT_NEXT_MINIGAME_STAGE, Constants.MINIGAME_STAGE_ENDED )

    else
        if stage < table.getn( Constants.MinigameStages ) then
            -- Set to next stage
            print( "Set to next stage from stage: ".. stage )
            stage = stage + 1
            CCUserDefault:sharedUserDefault():setIntegerForKey( Constants.EVENT_NEXT_MINIGAME_STAGE, stage )
        end

        local nowTimeStamp = os.time()
        CCUserDefault:sharedUserDefault():setIntegerForKey( Constants.EVENT_NEXT_MINIGAME_TIME_KEY, nowTimeStamp + Constants.MinigameStages[stage] )
        print( "Current Timestamp: ".. nowTimeStamp )
        print( "Set next timestamp to ".. nowTimeStamp + Constants.MinigameStages[stage] )
    end
end

function updateContentContainer( contentHeight, addContent, bPopular )
    local contentContainer = tolua.cast( mWidget:getChildByName("ScrollView"), "ScrollView" )

    contentContainer:setInnerContainerSize( CCSize:new( 0, contentHeight ) )
    local layout = tolua.cast( contentContainer, "Layout" )
    layout:requestDoLayout()


    if bPopular == nil and mTheFirstDate ~= nil then
        if addContent:getZOrder() < mTheFirstDate:getZOrder() then
            local y = contentContainer:getInnerContainer():getPositionY() + addContent:getSize().height
            contentContainer:jumpToDestination( ccp( 0, y ) )
        end
    end
end

function enterMatch( match )
    Logic:setSelectedMatch( match )
    EventManager:postEvent( Event.Enter_Match_Center, { MatchCenterConfig.MATCH_CENTER_TAB_ID_MEETINGS, match["Id"] } )
end

function helperInitMatchInfo( topContent, matchInfo, leagueKey )
    
    local bg = topContent:getChildByName("Panel_MatchBG")
    local homePercent = tolua.cast( topContent:getChildByName("Label_HomePercent"), "Label" )
    local awayPercent = tolua.cast( topContent:getChildByName("Label_AwayPercent"), "Label" )
    local drawPercent = tolua.cast( topContent:getChildByName("Label_DrawPercent"), "Label" )
    local lbDraw = tolua.cast( topContent:getChildByName("Label_Draw"), "Label" )
    local lbTotalFans = tolua.cast( topContent:getChildByName("Label_TotalFans"), "Label" )
    local fanCount = tolua.cast( topContent:getChildByName("Label_FanCount"), "Label" )
    
    local fadePanel = topContent:getChildByName("Panel_Fade")
    local team1 = tolua.cast( fadePanel:getChildByName("Image_Team1"), "ImageView" )
    local team2 = tolua.cast( fadePanel:getChildByName("Image_Team2"), "ImageView" )
    local team1Name = tolua.cast( fadePanel:getChildByName("Label_Team1Name"), "Label" )
    local team2Name = tolua.cast( fadePanel:getChildByName("Label_Team2Name"), "Label" )
    local compName = tolua.cast( fadePanel:getChildByName("Label_CompetitionName"), "Label" )

    local statusPanel = tolua.cast( topContent:getChildByName("Panel_Status"), "Layout" )
    local played = tolua.cast( statusPanel:getChildByName("Label_PlayedCount"), "Label" )
    local lbPlayed = tolua.cast( statusPanel:getChildByName("Label_Played"), "Label" )
    local status = tolua.cast( statusPanel:getChildByName("Label_Status"), "Label" )
    local ball = tolua.cast( statusPanel:getChildByName("Image_Ball"), "ImageView" )
    
    local postCount = tolua.cast( topContent:getChildByName("Label_DiscussionCount"), "Label" )
    postCount:setText( matchInfo["CommentCount"] )

    if not SportsConfig.isCurrentSportHasDraw() then
        lbDraw:setEnabled( false )
        drawPercent:setEnabled( false )
        topContent:getChildByName("Label_SeparatorHome"):setEnabled( false )
        topContent:getChildByName("Label_SeparatorAway"):setEnabled( false )
    end

    -- Labels
    lbDraw:setText( Constants.String.match_list.draw )
    lbPlayed:setText( Constants.String.match_list.played )
    lbTotalFans:setText( Constants.String.match_list.total_fans )
    if leagueKey == Constants.SpecialLeagueIds.MOST_POPULAR or leagueKey == Constants.SpecialLeagueIds.UPCOMING_MATCHES then
        compName:setText( matchInfo["LeagueName"] )
        compName:setEnabled( true )
    else
        bg:setSize( CCSize:new( bg:getSize().width, bg:getSize().height - 30 ) )
        topContent:setSize( CCSize:new( topContent:getSize().width, topContent:getSize().height - 30 ) )
        compName:setEnabled( false )
    end
    status:setEnabled( false )

    -- Load the team logo
    team1:loadTexture( TeamConfig.getLogo( TeamConfig.getConfigIdByKey( matchInfo["HomeTeamId"] ), true ) )
    team2:loadTexture( TeamConfig.getLogo( TeamConfig.getConfigIdByKey( matchInfo["AwayTeamId"] ), false ) )

    -- Load the team names
    local teamName = TeamConfig.getTeamName( TeamConfig.getConfigIdByKey( matchInfo["HomeTeamId"] ) )
    if string.len( teamName ) > 20 then
        team1Name:setFontSize( 20 )
    end
    team1Name:setText( teamName )
    teamName = TeamConfig.getTeamName( TeamConfig.getConfigIdByKey( matchInfo["AwayTeamId"] ) )
    if string.len( teamName ) > 20 then
        team2Name:setFontSize( 20 )
    end
    team2Name:setText( teamName )

    local enableMatchStatus = function( szStatus, profit )
        played:setEnabled( false )
        lbPlayed:setEnabled( false )
        ball:setEnabled( false )
        status:setEnabled( true )
        
        statusPanel:setBackGroundColorOpacity( 255 )

        if szStatus == Constants.String.match_list.match_started then
            statusPanel:setBackGroundColor( ccc3( 40, 119, 209 ) )
            status:setText( szStatus )
            status:setColor( ccc3( 248, 231, 28 ) )
        elseif szStatus == Constants.String.match_list.match_ended then
            statusPanel:setBackGroundColor( ccc3( 60, 58, 58 ) )
            status:setText( szStatus )
            status:setColor( ccc3( 248, 231, 28 ) )
        elseif szStatus == Constants.String.match_list.match_won then
            status:setText( string.format( szStatus, profit ) )
            statusPanel:setBackGroundColor( ccc3( 455, 165, 26 ) )
        elseif szStatus == Constants.String.match_list.match_lost then
            statusPanel:setBackGroundColor( ccc3( 208, 2, 27 ) )
            status:setText( string.format( szStatus, profit ) )
        end
    end

    local isNotGameStart = matchInfo["StartTime"] > os.time()
    local score = tolua.cast( topContent:getChildByName("Label_Score"), "Label" )
    if matchInfo["HomeGoals"] >= 0 and matchInfo["AwayGoals"] >= 0 then
        score:setText( string.format( score:getStringValue(), matchInfo["HomeGoals"], matchInfo["AwayGoals"] ) )
    
        -- not working
        --fadePanel:setOpacity( 127 )
        --fadePanel:setCascadeOpacityEnabled( true )
        local children = fadePanel:getChildren()
        for i = 1, children:count() do
            local child = children:objectAtIndex(i - 1)
            child:setOpacity( 127 )
        end

        if matchInfo["PredictionsPlayed"] == 0 then
            -- match ended
            enableMatchStatus( Constants.String.match_list.match_ended )
            --statusPanel:setEnabled( false )
        elseif type(matchInfo["Profit"]) == "userdata" then
            
        elseif matchInfo["Profit"] >= 0 then
            -- won
            enableMatchStatus( Constants.String.match_list.match_won, math.abs( matchInfo["Profit"] ) )
        else
            -- lost
            enableMatchStatus( Constants.String.match_list.match_lost, math.abs( matchInfo["Profit"] ) )
        end
    else
        score:setText( "-:-" )
        score:setColor( ccc3( 255, 255, 255 ) )
        
        if not isNotGameStart then
            -- match started
            enableMatchStatus( Constants.String.match_list.match_started )
        end
    end

    local totalWinPredictions = matchInfo["HomePredictions"] + matchInfo["AwayPredictions"] + matchInfo["DrawPredictions"]
    local homeWinPercent = 0
    local awayWinPercent = 0
    local drawWinPercent = 0
    if totalWinPredictions > 0 then
        homeWinPercent = matchInfo["HomePredictions"] / totalWinPredictions * 100
        awayWinPercent = matchInfo["AwayPredictions"] / totalWinPredictions * 100
        drawWinPercent = matchInfo["DrawPredictions"] / totalWinPredictions * 100
    end
    homePercent:setText( string.format( homePercent:getStringValue(), homeWinPercent ) )
    awayPercent:setText( string.format( awayPercent:getStringValue(), awayWinPercent ) )
    drawPercent:setText( string.format( drawPercent:getStringValue(), drawWinPercent ) )
    fanCount:setText( matchInfo["TotalUsersPlayed"] )
    played:setText( string.format( played:getStringValue(), matchInfo["PredictionsPlayed"], matchInfo["PredictionsAvailable"] ) )

    -- if isNotGameStart then
    --     topContent:setTouchEnabled( true )
    -- else
    --     topContent:setTouchEnabled( false )
    -- end
end

function optionEventHandler( sender, eventType )
    if eventType == TOUCH_EVENT_ENDED then
        if mOptionPanelShown then
            hideOptionAnim()
        else
            showOptionAnim()
        end
    end
end

local startPosX, startPosY
function onTopLevelTouch( eventType, x, y )
    if eventType == "began" then
        startPosX, startPosY = x, y
        return true
    elseif eventType == "ended" then
        if startPosX - x > MIN_MOVE_DISTANCE and mOptionPanelShown == true then
            -- Swap to Left
            hideOptionAnim()
        elseif startPosX < 80 and x - startPosX > MIN_MOVE_DISTANCE and mOptionPanelShown == false then
            -- Swap to Right
            showOptionAnim()
        end
    end
end

function showOptionAnim( callbackFunc )
    local optionBt = mWidget:getChildByName("option")
    optionBt:setTouchEnabled( false )
    mTopLayer:setTouchEnabled( false )

    local seqArray = CCArray:create()
    seqArray:addObject( CCMoveBy:create( OPTION_MOVE_TIME, ccp( OPTION_VIEW_OFFSET_X, 0 ) ) )
    seqArray:addObject( CCCallFuncN:create( function()
        optionBt:setTouchEnabled( true )
        mTopLayer:setTouchEnabled( true )
        mOptionPanelShown = true

        if callbackFunc ~= nil then
            callbackFunc()
        end
    end ) )
    mWidget:runAction( CCSequence:create( seqArray ) )
end

function hideOptionAnim( callbackFunc )
    local optionBt = mWidget:getChildByName("option")
    optionBt:setTouchEnabled( false )
    mTopLayer:setTouchEnabled( false )

    local seqArray = CCArray:create()
    seqArray:addObject( CCMoveBy:create( OPTION_MOVE_TIME, ccp( OPTION_VIEW_OFFSET_X * (-1), 0 ) ) )
    seqArray:addObject( CCCallFuncN:create( function()
        optionBt:setTouchEnabled( true )
        mTopLayer:setTouchEnabled( true )
        mOptionPanelShown = false

        if callbackFunc ~= nil then
            callbackFunc()
        end
    end ) )
    mWidget:runAction( CCSequence:create( seqArray ) )
end

function scrollViewEventHandler( target, eventType )
    if eventType == SCROLLVIEW_EVENT_BOUNCE_BOTTOM and mHasMoreToLoad then
        mStep = mStep + 1
        
        EventManager:postEvent( Event.Enter_Match_List, { Constants.SpecialLeagueIds.UPCOMING_MATCHES, mStep } )
    end
end

function scrollViewDoNothingEventHandler( target, eventType )
end

function sportChangeEventHandler()
    EventManager:postEvent( Event.Enter_Match_List, { Constants.SpecialLeagueIds.MOST_POPULAR } )
    MatchListDropdownFrame.initCountryList()

    -- Reset the match list drop down
    local content = mWidget:getChildByName( MATCH_LIST_DROPDOWN_NAME )

    local logo = tolua.cast( content:getChildByName( "Image_CountryLogo" ), "ImageView" )
    local countryName = tolua.cast( content:getChildByName( "Label_CountryName"), "Label" )
    local leagueName = tolua.cast( content:getChildByName( "Label_LeagueName"), "Label" )

    countryName:setText( Constants.String.match_list.special )
    leagueName:setText( Constants.String.match_list.most_popular )
    logo:loadTexture( Constants.COUNTRY_IMAGE_PATH.."favorite.png" )
end