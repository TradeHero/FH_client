module(..., package.seeall)

local SceneManager = require("scripts.SceneManager")
local Event = require("scripts.events.Event").EventList
local EventManager = require("scripts.events.EventManager").getInstance()
local SMIS = require("scripts.SMIS")
local TeamConfig = require("scripts.config.Team")

local mWidget

function loadFrame( parent, jsonResponse )
    table.getn( jsonResponse )
    mWidget = GUIReader:shareReader():widgetFromJsonFile("scenes/CommunityTimelineFrame.json")
    parent:addChild( mWidget )
    mWidget:registerScriptHandler( EnterOrExit )

    initContent( jsonResponse["Timelines"] )
end

function exitFrame()
    mWidget = nil
end

function isShown()
    return mWidget ~= nil
end

function EnterOrExit( eventType )
    if eventType == "enter" then
    elseif eventType == "exit" then
        mWidget = nil
    end
end


function initContent( data )
    local contentHeight = 0
    local layoutParameter = LinearLayoutParameter:create()
    layoutParameter:setGravity(LINEAR_GRAVITY_CENTER_VERTICAL)
    
    local contentContainer = tolua.cast( mWidget:getChildByName("ScrollView"), "ScrollView" )
    contentContainer:removeAllChildrenWithCleanup( true )
    local now = os.time()

    for i = 1, table.getn( data ) do
        local userId = data[i]["UserMetaData"]["UserId"]
        local userName = data[i]["UserMetaData"]["DisplayName"]
        local pictureUrl = data[i]["UserMetaData"]["PictureUrl"]
        local message = data[i]["Message"]
        local diff = now - data[i]["CreateTime"]
        local timelineType = data[i]["TimelineType"]

        local content = SceneManager.widgetFromJsonFile("scenes/CommunityTimelineContent.json")
        local panel = tolua.cast( content:getChildByName("Panel_Content"), "Layout" )

        local imageProfile = tolua.cast( panel:getChildByName("Image_Profile"), "ImageView" )
        local labelName = tolua.cast( panel:getChildByName("Label_Name"), "Label" )
        local labelTime = tolua.cast( panel:getChildByName("Label_Time"), "Label" )
        local labelMsg = tolua.cast( panel:getChildByName("Label_Msg"), "Label" )
        local imagePic = tolua.cast( panel:getChildByName("Image_Pic"), "ImageView" )

        local userHandler = function( sender, eventType )
            if eventType == TOUCH_EVENT_ENDED then
                enterUserHistory( userId )
            end
        end
        labelName:setText( userName )
        labelMsg:setText( message )
        labelTime:setText( getTimeString( diff ))

        imageProfile:addTouchEventListener( userHandler )
        local seqArray = CCArray:create()
        seqArray:addObject( CCDelayTime:create( i * 0.2 ) )
        seqArray:addObject( CCCallFuncN:create( function()
            if type( pictureUrl ) ~= "userdata" and pictureUrl ~= nil then
                local handler = function( filePath )
                    if filePath ~= nil and mWidget ~= nil and imageProfile ~= nil then
                        local safeLoadTexture = function()
                           imageProfile:loadTexture( filePath )
                        end
                        xpcall( safeLoadTexture, function ( msg )  end )
                    end
                end
                SMIS.getSMImagePath( pictureUrl, handler )
            end
        end ) )
        mWidget:runAction( CCSequence:create( seqArray ) )

        if timelineType == 1 then -- predict
             local gameId = data[i]["GameId"]
            local pickId = data[i]["PickTeamId"]
            local teamLogo
            if pickId == -1 then
                teamLogo = ""
            else
                teamLogo = TeamConfig.getLogo( data[i]["PickTeamId"], true )
            end
            imagePic:loadTexture( teamLogo )

            local predHandler = function( sender, eventType )
                if eventType == TOUCH_EVENT_ENDED then
                    predictMatch( gameId )
                end
            end
            imagePic:addTouchEventListener( predHandler )
        elseif timelineType == 2 then -- follow
           local followData = data[i]["FollowUserMetaData"]
            local followId = followData["UserId"]
            local followUrl = followData["PictureUrl"]

            local followHandler = function( sender, eventType )
                if eventType == TOUCH_EVENT_ENDED then
                    enterUserHistory( followId )
                end
            end
            imagePic:addTouchEventListener( followHandler )

            seqArray = CCArray:create()
            seqArray:addObject( CCDelayTime:create( i * 0.2 ) )
            seqArray:addObject( CCCallFuncN:create( function()
                if type( followUrl ) ~= "userdata" and followUrl ~= nil then
                    local handler = function( filePath )
                        if filePath ~= nil and mWidget ~= nil and imagePic ~= nil then
                            local safeLoadTexture = function()
                               imagePic:loadTexture( filePath )
                            end
                            xpcall( safeLoadTexture, function ( msg )  end )
                        end
                    end
                    SMIS.getSMImagePath( followUrl, handler )
                end
            end ) )
            mWidget:runAction( CCSequence:create( seqArray ) )           
        elseif timelineType == 3 then -- join 
            local competitionId = data[i]["JoinToken"]
            local competitionHandler = function( sender, eventType )
                if eventType == TOUCH_EVENT_ENDED then
                    joinCompetition( competitionId )
                end
            end
            imagePic:addTouchEventListener( competitionHandler )

        elseif timelineType == 4 then
            CCLuaLog( "Predict:" )
        end


        content:setLayoutParameter( layoutParameter )
        contentContainer:addChild( content )
        contentHeight = contentHeight + content:getSize().height
    end
    contentContainer:setInnerContainerSize( CCSize:new( 0, contentHeight ) )
    local layout = tolua.cast( contentContainer, "Layout" )
    layout:requestDoLayout()
end

function getTimeString( diff )
    if diff < 60 then
        return string.format("%d seconds ago", diff)
     elseif diff < 7200 then
        return string.format( "%d mins ago", math.floor( diff / 60 ) )
    elseif diff < 3600 * 24 then
        return os.date( "%H hrs ago", math.floor( diff / 3600 ) )
    elseif diff < 3600 * 24 * 60 then
        return os.date( "%d days ago", math.floor( diff / 3600 / 24 ) )
    else
        return os.date( "%m month ago", math.floor( diff / 3600 / 24 / 30) )
    end
end

-- function predictHistory( userId, matchId )
--     EventManager:postEvent( Event.Enter_History_Detail, { userId, true, matchId } ) 
-- end

function predictMatch( matchId )
    EventManager:postEvent( Event.Enter_Match_Center, { 1 , matchId } )
end

function enterUserHistory( userId )
    EventManager:postEvent( Event.Enter_History, { userId } )
end

function joinCompetition( competitionId )
    EventManager:postEvent( Event.Enter_Competition_Detail, { competitionId, false, 3, 1 } )
end
