module(..., package.seeall)

local SceneManager = require("scripts.SceneManager")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local Header = require("scripts.views.HeaderFrame")
local SMIS = require("scripts.SMIS")
local Constants = require("scripts.Constants")
local RequestUtils = require("scripts.RequestUtils")
local Logic = require("scripts.Logic").getInstance()

local mWidget
local mFollow

function loadFrame( jsonResponse )
    mFollows = jsonResponse
    local nFollow = table.getn( mFollows ) 
--    CCLuaLog ( "follows:" .. nFollow )

    local widget = GUIReader:shareReader():widgetFromJsonFile("scenes/SettingsFollowListScene.json")
    mWidget = widget
    mWidget:registerScriptHandler( EnterOrExit )
    SceneManager.clearNAddWidget( widget )

    Header.loadFrame( mWidget, Constants.String.settings.follow_user , true )


    local contentContainer = tolua.cast( mWidget:getChildByName("ScrollView"), "ScrollView" )
    contentContainer:removeAllChildrenWithCleanup( true )

    local layoutParameter = LinearLayoutParameter:create()
    layoutParameter:setGravity(LINEAR_GRAVITY_CENTER_VERTICAL)
    local contentHeight = 0

    if nFollow == 0 then
        local userName = Constants.String.settings.follow_user_none
    
        contentHeight = contentHeight + addFollow( contentContainer )
    else
        for i = 1, nFollow do
            contentHeight = contentHeight + addFollow( contentContainer, i, mFollows[i] )
        end
    end            
  
    contentContainer:setInnerContainerSize( CCSize:new( 0, contentHeight ) )
    local layout = tolua.cast( contentContainer, "Layout" )
    layout:requestDoLayout()

end

function addFollow( contentContainer, i, userInfo)
    local content = SceneManager.widgetFromJsonFile("scenes/MyPicksFollowContentFrame.json")
    local lblIndex = tolua.cast( content:getChildByName("Label_Index"), "Label" )
    local lblName = tolua.cast( content:getChildByName("Label_Name"), "Label" )
    local lblBalance = tolua.cast( content:getChildByName("Label_Balance"), "Label" )
    local btnFollow = tolua.cast( content:getChildByName("Button_Follow"), "Button" )
    local btnDrop = tolua.cast( content:getChildByName("Button_drop"), "Button" )
    local logo = tolua.cast( content:getChildByName("Image_Photo"), "ImageView" )
 
    if userInfo == nil then
        lblName:setText( Constants.String.settings.follow_user_none )
        lblIndex:setEnabled( false )
        lblBalance:setEnabled( false )
        btnFollow:setEnabled( false )
        contentContainer:addChild( content )
        return content:getSize().height
    end

    local userId = userInfo["UserId"]
    local userName = userInfo["DisplayName"]
    local pictureUrl = userInfo["PictureUrl"]
    local balance = userInfo["Balance"]
    local isFollowed = userInfo["IsFollowed"]

    if  userId == Logic:getUserId() then
        btnFollow:setEnabled( false )
    end

    if isFollowed then
        btnFollow:setTitleText( Constants.String.history.unfollow_button )
    else
        btnFollow:setTitleText( Constants.String.history.follow_button )
    end

    lblIndex:setText( i )
    lblName:setText( userName )
    lblBalance:setText(balance .. " pts")

    local seqArray = CCArray:create()
    seqArray:addObject( CCDelayTime:create( i * 0.2 ) )
    seqArray:addObject( CCCallFuncN:create( function()
        if type( pictureUrl ) ~= "userdata" and pictureUrl ~= "" then
            local handler = function( filePath )
                if filePath ~= nil and mWidget ~= nil and logo ~= nil then
                    local safeLoadTexture = function()
                        logo:loadTexture( filePath )
                    end
                    xpcall( safeLoadTexture, function ( msg )  end )
                end
            end
            SMIS.getSMImagePath( pictureUrl, handler )
        end
    end ) )
    mWidget:runAction( CCSequence:create( seqArray ) )

    if isFollowed then
        btnFollow:setTitleText( Constants.String.history.unfollow_button )
    else
        btnFollow:setTitleText( Constants.String.history.follow_button )
    end

    local followCallback = function (  )
        if isFollowed then
            btnFollow:setTitleText( Constants.String.history.unfollow_button )
        else
            btnFollow:setTitleText( Constants.String.history.follow_button )
        end
        RequestUtils.invalidResponseCacheContainsUrl( RequestUtils.GET_COUPON_HISTORY_REST_CALL )
    end
    local followHandler = function( sender, eventType )
        if eventType == TOUCH_EVENT_ENDED then
            isFollowed = not isFollowed
            EventManager:postEvent( Event.Do_Follow_Expert, { userId , isFollowed ,  followCallback } )
        end
    end
    btnFollow:addTouchEventListener( followHandler ) 

    local userHandler = function( sender, eventType )
        if eventType == TOUCH_EVENT_ENDED then
            EventManager:postEvent( Event.Enter_History, { userId } )
        end
    end
    btnDrop:addTouchEventListener( userHandler ) 
    logo:addTouchEventListener( userHandler ) 

    contentContainer:addChild( content )
 
    return content:getSize().height
end

function EnterOrExit( eventType )
    if eventType == "enter" then
    elseif eventType == "exit" then
        mWidget = nil
    end
end

function isFrameShown()
    return mWidget ~= nil
end
