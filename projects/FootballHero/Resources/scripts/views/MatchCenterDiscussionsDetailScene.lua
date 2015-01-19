module(..., package.seeall)

local Constants = require("scripts.Constants")
local SceneManager = require("scripts.SceneManager")
local Navigator = require("scripts.views.Navigator")
local Logic = require("scripts.Logic").getInstance()
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local SMIS = require("scripts.SMIS")
local TeamConfig = require("scripts.config.Team")
local MatchCenterConfig = require("scripts.config.MatchCenter")

local mWidget
local mTextInput
local mPostId
local mStep
local mCurrentTotalNum
local mHasMoreToLoad

function loadFrame( discussionInfo, comments )
    mStep = 1

    if table.getn( comments ) < Constants.DISCUSSIONS_PER_PAGE then
        mHasMoreToLoad = false
    else
        mHasMoreToLoad = true
    end
    mPostId = discussionInfo["Id"]    

	mWidget = GUIReader:shareReader():widgetFromJsonFile("scenes/MatchCenterDiscussionsDetailScene.json")
    mWidget:registerScriptHandler( EnterOrExit )
    SceneManager.clearNAddWidget( mWidget )
    SceneManager.setKeypadBackListener( keypadBackEventHandler )
    
    Navigator.loadFrame( mWidget )

    initTitle()

    initPost( discussionInfo )

    initContent( comments )

    local backBt = mWidget:getChildByName("Button_Back")
    backBt:addTouchEventListener( backEventHandler )
end

function refreshFrame( discussionInfo, comments )
    mPostId = discussionInfo["Id"]    

    initTitle()

    initPost( discussionInfo )

    initContent( comments )
end

function isShown()
    return mWidget ~= nil
end

function EnterOrExit( eventType )
    if eventType == "enter" then
    elseif eventType == "exit" then
        mWidget = nil
        mTextInput = nil
    end
end

function backEventHandler( sender, eventType )
    if eventType == TOUCH_EVENT_ENDED then
        keypadBackEventHandler()
    end
end

function keypadBackEventHandler()
    EventManager:popHistory()
end

function loadMoreContent( comments, bJumpToTop )
    
    if not bJumpToTop and table.getn( comments ) < Constants.DISCUSSIONS_PER_PAGE then
        mHasMoreToLoad = false
        if table.getn( comments ) == 0 then
            return
        end
    else
        mHasMoreToLoad = true
    end

    local contentContainer = tolua.cast( mWidget:getChildByName("ScrollView_Comments"), "ScrollView" )

    local layoutParameter = LinearLayoutParameter:create()
    layoutParameter:setGravity(LINEAR_GRAVITY_CENTER_VERTICAL)
    local contentHeight = contentContainer:getInnerContainerSize().height

    for i = 1, table.getn( comments ) do
        local content = SceneManager.widgetFromJsonFile("scenes/MatchCenterDiscussionsCommentFrame.json")
        content:setLayoutParameter( layoutParameter )
        
        -- check for duplicates (when loading more after adding new post)
        if contentContainer:getChildByName( comments[i]["Id"] ) == nil then
            -- z-order to reverse add order (ie. Add to top of scrollview)
            contentContainer:addChild( content,  -comments[i]["UnixTimeStamp"] )
            contentHeight = contentHeight + content:getSize().height
            initCommentContent( i, content, comments[i] )
        end
    end
    mCurrentTotalNum = mCurrentTotalNum + table.getn( comments )

    contentContainer:setInnerContainerSize( CCSize:new( 0, contentHeight ) )
    local layout = tolua.cast( contentContainer, "Layout" )
    layout:requestDoLayout()

    if bJumpToTop then
        contentContainer:jumpToTop()

        -- increment new comments count
        local content = mWidget:getChildByName("Panel_Discussion")
        local bottom  = content:getChildByName("Panel_Bottom")
        local comments = tolua.cast( bottom:getChildByName("Label_Comments"), "Label" )
        comments:setText( tonumber( comments:getStringValue() ) + 1 )
    end
end

function initTitle()
    local matchInfo = Logic:getSelectedMatch()

    local title = tolua.cast( mWidget:getChildByName( "Label_Title"), "Label" )

    local homeTeamId = TeamConfig.getConfigIdByKey( matchInfo["HomeTeamId"] )
    local awayTeamId = TeamConfig.getConfigIdByKey( matchInfo["AwayTeamId"] )

    local homeTeamName = TeamConfig.getTeamName( homeTeamId )
    local awayTeamName = TeamConfig.getTeamName( awayTeamId )

    title:setText( homeTeamName.." "..Constants.String.vs.." "..awayTeamName )
end

function initContent( comments )
    initCommentsList( comments )

    local postPanel = mWidget:getChildByName("Panel_Post")

    local loadCommentEventHandler = function( sender,eventType )
        if eventType == TOUCH_EVENT_ENDED then
            sender:setEnabled( false )

            EventManager:postEvent( Event.Load_More_Discussion_Posts, { mPostId, mStep, MatchCenterConfig.DISCUSSION_POST_TYPE_POST } )
        end
    end

    local clickMask = mWidget:getChildByName("Panel_InputCancelMask")
    clickMask:setEnabled( false )

    local clickMaskEventHandler = function( sender, eventType )
        postPanel:setEnabled( false )
        clickMask:setEnabled( false )
        mTextInput:setText( "" )
        --mTextInput:setVisible( false )
    end
    clickMask:addTouchEventListener( clickMaskEventHandler )


    local loadMore = mWidget:getChildByName("Panel_MoreComments")
    loadMore:setEnabled( false )
    loadMore:addTouchEventListener( loadCommentEventHandler )

    local loadText = tolua.cast( loadMore:getChildByName("Label_MoreComments"), "Label" )
    loadText:setText( Constants.String.match_center.load_comments )

    local postCommentEventHandler = function( sender,eventType )
        if eventType == TOUCH_EVENT_ENDED then
            
            postPanel:setEnabled( true )
            clickMask:setEnabled( true )
            --mTextInput:setVisible( true )

            -- Make keyboard appear automatically
            local container = postPanel:getChildByName("Panel_Input")
            inputEventHandler( container, TOUCH_EVENT_ENDED )
        end
    end

    local button = tolua.cast( mWidget:getChildByName("Button_Comment"), "Button" )
    button:addTouchEventListener( postCommentEventHandler )
    local text = tolua.cast( button:getChildByName("Label_Comment"), "Label" )
    text:setText( Constants.String.match_center.write_comment )

    initInput()
end

function initInput()
    local top = mWidget:getChildByName("Panel_Post")
    top:setEnabled( false )

    local container = top:getChildByName("Panel_Input")
    container:addTouchEventListener( inputEventHandler )

    local inputDelegate = EditBoxDelegateForLua:create()
    container:addNode( tolua.cast( inputDelegate, "CCNode" ) )

    
    inputDelegate:registerEventScriptHandler( EDIT_BOX_EVENT_RETURN, function ( textBox )
        textBox:setVisible( true )
    end )

    mTextInput = CCEditBox:create( CCSizeMake( 552, 35 ), CCScale9Sprite:create() )
    container:addNode( mTextInput )
    mTextInput:setPosition( 552 / 2, 60 / 2 )
    mTextInput:setVisible( false )
    mTextInput:setDelegate( inputDelegate.__CCEditBoxDelegate__ )
    
    local postEventHandler = function( sender,eventType )
        if eventType == TOUCH_EVENT_ENDED then
            --mTextInput:setVisible( false )
            top:setEnabled( false )
            if mTextInput:getText() ~= "" then
                EventManager:postEvent( Event.Do_Make_Discussion_Post, { mPostId, mTextInput:getText(), MatchCenterConfig.DISCUSSION_POST_TYPE_POST } )
                mTextInput:setText( "" )
            end
        end
    end
    local button = top:getChildByName("Button_Post")
    button:addTouchEventListener( postEventHandler )

end

function inputEventHandler( sender, eventType )
    if eventType == TOUCH_EVENT_ENDED then
        mTextInput:touchDownAction( sender, eventType )
    end
end

function initPost( info )
    local content = mWidget:getChildByName("Panel_Discussion")

    local post = tolua.cast( content:getChildByName("Label_Post"), "Label" )

    local top  = content:getChildByName("Panel_Top")
    local logo = tolua.cast( top:getChildByName("Image_Logo"), "ImageView" )
    local name = tolua.cast( top:getChildByName("Label_Name"), "Label" )
    local time = tolua.cast( top:getChildByName("Label_Time"), "Label" )
    
    local bottom  = content:getChildByName("Panel_Bottom")
    local checkLike = tolua.cast( bottom:getChildByName("CheckBox_Like"), "CheckBox" )
    local lblLike = tolua.cast( bottom:getChildByName("Label_Like"), "Label" )
    local comments = tolua.cast( bottom:getChildByName("Label_Comments"), "Label" )
    local share = tolua.cast( bottom:getChildByName("Button_Share"), "Button" )
    
    local enableLikeEventHandler = function( bLiked )
        checkLike:setTouchEnabled( true )
        local newCount
        if bLiked then
            newCount = tonumber( lblLike:getStringValue() ) + 1
        else
            newCount = math.max( 0, tonumber( lblLike:getStringValue() ) - 1 )
        end
        info["LikeCount"] = newCount
        info["Liked"] = bLiked
        lblLike:setText( newCount )
    end
    local likeEventHandler = function( sender, eventType )
        local checkbox = tolua.cast( sender, "CheckBox" )    
        if eventType == TOUCH_EVENT_ENDED then
            checkbox:setTouchEnabled( false )
            EventManager:postEvent( Event.Do_Like_Discussion_Post, { info["Id"], not checkbox:getSelectedState(), enableLikeEventHandler, MatchCenterConfig.DISCUSSION_POST_TYPE_GAME } )
        end
    end
    checkLike:addTouchEventListener( likeEventHandler )

    --share:addTouchEventListener( shareTypeSelectEventHandler )
    share:setEnabled( false )

    if type( info["DisplayName"]  ) ~= "string" or info["DisplayName"] == nil then
        name:setText( Constants.String.unknown_name )
    else
        name:setText( info["DisplayName"] )
    end

    post:setText( info["Text"] )
    showFullPost( content )

    lblLike:setText( info["LikeCount"] )
    checkLike:setSelectedState( info["Liked"] )
    comments:setText( info["CommentCount"] )
    
    MatchCenterConfig.setTimeDiff( time, info["UnixTimeStamp"] )
    
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

end

function showFullPost( content )
    
    local top = content:getChildByName("Panel_Top")
    local post = tolua.cast( content:getChildByName("Label_Post"), "Label" )
    local bg = content:getChildByName("Panel_BG")

    local originalSize = post:getSize()
    if originalSize.width > MatchCenterConfig.MAX_DISCUSSION_TEXT_WIDTH then

        local numOfRows = math.ceil( originalSize.width / MatchCenterConfig.MAX_DISCUSSION_POST_TEXT_WIDTH )
        local textHeight = numOfRows * 25    

        post:setTextAreaSize( CCSize:new( MatchCenterConfig.MAX_DISCUSSION_POST_TEXT_WIDTH, textHeight ) )

        local addHeight = textHeight - MatchCenterConfig.MAX_DISCUSSION_TEXT_HEIGHT
        content:setSize( CCSize:new( content:getSize().width, content:getSize().height + addHeight ) )
        bg:setSize( CCSize:new( bg:getSize().width, bg:getSize().height + addHeight ) )
        top:setSize( CCSize:new( top:getSize().width, top:getSize().height + addHeight ) )

        top:setPositionY( top:getPositionY() + addHeight )
        content:setPositionY( content:getPositionY() - addHeight )


        local contentContainer = tolua.cast( mWidget:getChildByName("ScrollView_Comments"), "ScrollView" )
        local moreComments = mWidget:getChildByName("Panel_MoreComments")
        contentContainer:setSize( CCSize:new( contentContainer:getSize().width, contentContainer:getSize().height - addHeight ) )
        moreComments:setPositionY( moreComments:getPositionY() - addHeight )
    end
end

function initCommentsList( comments )
    local contentContainer = tolua.cast( mWidget:getChildByName("ScrollView_Comments"), "ScrollView" )
    contentContainer:removeAllChildrenWithCleanup( true )

    local layoutParameter = LinearLayoutParameter:create()
    layoutParameter:setGravity(LINEAR_GRAVITY_CENTER_VERTICAL)
    local contentHeight = 0
    
    for i = 1, table.getn( comments ) do
        local content = SceneManager.widgetFromJsonFile("scenes/MatchCenterDiscussionsCommentFrame.json")
        content:setLayoutParameter( layoutParameter )
        contentContainer:addChild( content,  -comments[i]["UnixTimeStamp"] )
        contentHeight = contentHeight + content:getSize().height
        initCommentContent( i, content, comments[i] )
    end
    mCurrentTotalNum = table.getn( comments )

    contentContainer:setInnerContainerSize( CCSize:new( 0, contentHeight ) )
    local layout = tolua.cast( contentContainer, "Layout" )
    layout:requestDoLayout()
    contentContainer:addEventListenerScrollView( scrollViewEventHandler )
end

function initCommentContent( i, content, info )

    content:setName( info["Id"] )

    local post = tolua.cast( content:getChildByName("Label_Comment"), "Label" )
    local bg = content:getChildByName("Panel_BG")
    local checkLike = tolua.cast( content:getChildByName("CheckBox_Like"), "CheckBox" )
    local lblLike = tolua.cast( content:getChildByName("Label_Like"), "Label" )

    local top = content:getChildByName("Panel_Top")
    local logo = tolua.cast( top:getChildByName("Image_Logo"), "ImageView" )
    local name = tolua.cast( top:getChildByName("Label_Name"), "Label" )
    local time = tolua.cast( top:getChildByName("Label_Time"), "Label" )
    local more = tolua.cast( post:getChildByName("Label_More"), "Label" )
    
    local enableLikeEventHandler = function( bLiked )
        checkLike:setTouchEnabled( true )
        local newCount
        if bLiked then
            newCount = tonumber( lblLike:getStringValue() ) + 1
        else
            newCount = math.max( 0, tonumber( lblLike:getStringValue() ) - 1 )
        end
        info["LikeCount"] = newCount
        info["Liked"] = bLiked
        lblLike:setText( newCount )
    end
    local likeEventHandler = function( sender, eventType )
        local checkbox = tolua.cast( sender, "CheckBox" )    
        if eventType == TOUCH_EVENT_ENDED then
            checkbox:setTouchEnabled( false )
            EventManager:postEvent( Event.Do_Like_Discussion_Post, { info["Id"], not checkbox:getSelectedState(), enableLikeEventHandler, MatchCenterConfig.DISCUSSION_POST_TYPE_POST } )
        end
    end
    checkLike:addTouchEventListener( likeEventHandler )

    if type( info["DisplayName"]  ) ~= "string" or info["DisplayName"] == nil then
        name:setText( Constants.String.unknown_name )
    else
        name:setText( info["DisplayName"] )
    end

    post:setText( info["Text"] )
    lblLike:setText( info["LikeCount"] )
    checkLike:setSelectedState( info["Liked"] )
    
    MatchCenterConfig.setTimeDiff( time, info["UnixTimeStamp"] )

    local bIsLongComment = isLongComment( post, info, bg, top )
    if bIsLongComment then
        local moreEventHandler = function( sender, eventType )
            local text = more:getStringValue()

            if eventType == TOUCH_EVENT_ENDED then
                local deltaHeight
                if text == Constants.String.match_center.more then
                    more:setText( Constants.String.match_center.less )
                    deltaHeight = expandComment( info["Text"], info["numOfRows"], content )
                else
                    more:setText( Constants.String.match_center.more )
                    deltaHeight = reduceComment( info["ShortText"], info["numOfRows"], content )
                end

                local contentContainer = tolua.cast( mWidget:getChildByName("ScrollView_Comments"), "ScrollView" )
                
                contentContainer:setInnerContainerSize( CCSize:new( 0, contentContainer:getInnerContainerSize().height + deltaHeight ) )
                local layout = tolua.cast( contentContainer, "Layout" )
                layout:requestDoLayout()
                contentContainer:addEventListenerScrollView( scrollViewEventHandler )
            end
        end
        more:addTouchEventListener( moreEventHandler )
    else
        more:setEnabled( false )
    end

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

function isLongComment( post, info )
    
    local bIsLong = false
    local originalSize = post:getSize()
    if originalSize.width > MatchCenterConfig.MAX_DISCUSSION_TEXT_WIDTH then

        info["numOfRows"] = math.ceil( originalSize.width / MatchCenterConfig.MAX_DISCUSSION_TEXT_WIDTH )
        if info["numOfRows"] > 2 then
            bIsLong = true
            -- truncate text
            info["ShortText"] = string.sub( post:getStringValue(), 0, 65 ).."..."
            post:setText( info["ShortText"] )
        end

        post:setTextAreaSize( CCSize:new( MatchCenterConfig.MAX_DISCUSSION_TEXT_WIDTH, MatchCenterConfig.MAX_DISCUSSION_TEXT_HEIGHT ) )
    end

    return bIsLong
end

function expandComment( newText, numOfRows, content )

    local top = content:getChildByName("Panel_Top")
    local comment = tolua.cast( content:getChildByName("Label_Comment"), "Label" )
    local bg = content:getChildByName("Panel_BG")

    local textHeight = numOfRows * 25
    comment:setTextAreaSize( CCSize:new( MatchCenterConfig.MAX_DISCUSSION_TEXT_WIDTH, textHeight ) )
    comment:setText( newText )

    local addHeight = textHeight - MatchCenterConfig.MAX_DISCUSSION_TEXT_HEIGHT
    content:setSize( CCSize:new( content:getSize().width, content:getSize().height + addHeight ) )
    bg:setSize( CCSize:new( bg:getSize().width, bg:getSize().height + addHeight ) )
    
    top:setPositionY( top:getPositionY() + addHeight )

    return addHeight
end

function reduceComment( newText, numOfRows, content )

    local top = content:getChildByName("Panel_Top")
    local comment = tolua.cast( content:getChildByName("Label_Comment"), "Label" )
    local bg = content:getChildByName("Panel_BG")

    local textHeight = numOfRows * 25
    comment:setTextAreaSize( CCSize:new( MatchCenterConfig.MAX_DISCUSSION_TEXT_WIDTH, MatchCenterConfig.MAX_DISCUSSION_TEXT_HEIGHT ) )
    comment:setText( newText )

    local addHeight = MatchCenterConfig.MAX_DISCUSSION_TEXT_HEIGHT - textHeight
    content:setSize( CCSize:new( content:getSize().width, content:getSize().height + addHeight ) )
    bg:setSize( CCSize:new( bg:getSize().width, bg:getSize().height + addHeight ) )
    
    top:setPositionY( top:getPositionY() + addHeight )

    return addHeight
end

function shareTypeSelectEventHandler( sender, eventType )
    if eventType == TOUCH_EVENT_ENDED then
        EventManager:postEvent( Event.Enter_Share, { Constants.String.match_center.share_title,
                                                    Constants.String.match_center.share_body, mCompetitionToken,
                                                    shareByFacebook } )
    end
end

function shareByFacebook( sender, eventType )
    if eventType == TOUCH_EVENT_ENDED then
        local doShare = function()
            local handler = function( accessToken, success )
                ConnectingMessage.selfRemove()
                if success then
                    -- already has permission
                    if accessToken == nil then
                        accessToken = Logic:getFBAccessToken()
                    end
                    EventManager:postEvent( Event.Do_Share_Discussion_Post, { mCompetitionId, accessToken } )
                end
            end
            ConnectingMessage.loadFrame()
            FacebookDelegate:sharedDelegate():grantPublishPermission( "publish_actions", handler )
        end

        if Logic:getFbId() == false then
            local successHandler = function()
                doShare()
            end
            local failedHandler = function()
                -- Nothing to do.
            end
            EventManager:postEvent( Event.Do_FB_Connect_With_User, { successHandler, failedHandler } )
        else
            doShare()
        end
    end
end

function scrollViewEventHandler( target, eventType )

    if eventType == SCROLLVIEW_EVENT_SCROLL_TO_BOTTOM and mHasMoreToLoad then
        mStep = mStep + 1
        
        mHasMoreToLoad = false

        local loadMore = mWidget:getChildByName("Panel_MoreComments")
        loadMore:setEnabled( true )
    end
end
