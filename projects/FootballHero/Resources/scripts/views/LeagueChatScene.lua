module(..., package.seeall)

local SceneManager = require("scripts.SceneManager")
local Navigator = require("scripts.views.Navigator")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local ViewUtils = require("scripts.views.ViewUtils")
local Logic = require("scripts.Logic").getInstance()
local Constants = require("scripts.Constants")
local SMIS = require("scripts.SMIS")
local LeagueChatConfig = require("scripts.config.LeagueChat").LeagueChatType

local mWidget
local mLeagueChatId
local mContainerHeight
local mHasTodayMessage
local mIsFirstCall
local MESSAGE_CONTAINER_NAME = "Panel_MessageContainer"
local RELOAD_DELAY_TIME = 5

-- DS for chatMessages: see ChatMessages
function loadFrame( leaguechatId )
    mLeagueChatId = leaguechatId

    local widget = GUIReader:shareReader():widgetFromJsonFile("scenes/ChatroomScene.json")
    mWidget = widget
    mWidget:registerScriptHandler( EnterOrExit )
    SceneManager.clearNAddWidget( widget )
    SceneManager.setKeypadBackListener( keypadBackEventHandler )

    Navigator.loadFrame( widget )

    mHasTodayMessage = false
    mIsFirstCall = true

    local backBt = widget:getChildByName("Button_Back")
    backBt:addTouchEventListener( backEventHandler )

    local sendBt = widget:getChildByName("Button_Send")
    sendBt:addTouchEventListener( sendEventHandler )

    local messageInput = ViewUtils.createTextInput( mWidget:getChildByName( MESSAGE_CONTAINER_NAME ), Constants.String.message_hint, 470, 50 )

    initTitle()
    doGetLatestMessages()
end

function initTitle()    
    local title = tolua.cast( mWidget:getChildByName("Label_Title"), "Label" )
    title:setText( Constants.String.league_chat[LeagueChatConfig[mLeagueChatId]["displayNameKey"]] )

    local logo = tolua.cast( mWidget:getChildByName("Image_Title"), "ImageView" )
    logo:loadTexture( LeagueChatConfig[mLeagueChatId]["logo"] ) 
    logo:setPositionX( title:getPositionX() - title:getSize().width/ 2 - logo:getSize().width )

    local panel = tolua.cast( mWidget:getChildByName("Panel_Title"), "Layout" )
    panel:setBackGroundColor( LeagueChatConfig[mLeagueChatId]["color"] )
end

function getLatestMessages()
    EventManager:scheduledExecutor( doGetLatestMessages, RELOAD_DELAY_TIME )
end

local mLastGetLatestMessageTime = 0
function doGetLatestMessages()
    -- Only send the request when players are still in the chat UI.
    if mIsFirstCall or ( mWidget ~= nil and os.time() - mLastGetLatestMessageTime >= RELOAD_DELAY_TIME ) then
        local callback, isLeague = getLatestMessages , true
        local lastChatTime, isSilent
        if mIsFirstCall then 
            lastChatTime = 0
            isSilent = false
            mIsFirstCall = false
        else
            lastChatTime = Logic:getLastChatMessageTimestamp()
            isSilent = true
        end
        EventManager:postEvent( Event.Do_Get_Chat_Message, { mLeagueChatId, lastChatTime, isSilent, callback, isLeague } )
        mLastGetLatestMessageTime = os.time()
    end
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

function backEventHandler( sender,eventType )
    if eventType == TOUCH_EVENT_ENDED then
        keypadBackEventHandler()
    end
end

function keypadBackEventHandler()
    EventManager:popHistory()
end


function sendEventHandler( sender,eventType )
    if eventType == TOUCH_EVENT_ENDED then
        local messageInput = mWidget:getChildByName( MESSAGE_CONTAINER_NAME ):getNodeByTag( 1 )
        local message = messageInput:getText()
        messageInput:setText("")
        if string.len( message ) > 0 then
            local isLeague = true
            EventManager:postEvent( Event.Do_Send_Chat_Message, { mLeagueChatId, message, isLeague } )
        end
    end
end

function initMessages( chatMessages )
    local contentContainer = tolua.cast( mWidget:getChildByName("ScrollView"), "ScrollView" )
    contentContainer:removeAllChildrenWithCleanup( true )

    local layoutParameter = LinearLayoutParameter:create()
    layoutParameter:setGravity(LINEAR_GRAVITY_CENTER_VERTICAL)
    mContainerHeight = 0

    for k,v in pairs( chatMessages:getMessageDateList() ) do
        local content = SceneManager.widgetFromJsonFile("scenes/ChatMessageDate.json")
        local dateDisplay = tolua.cast( content:getChildByName("date"), "Label" )
        dateDisplay:setText( v["dateDisplay"] )
        
        -- Record whether there is message of today. So no more today will be added for addMessages()
        if v["dateDisplay"] == "Today" then
            mHasTodayMessage = true
        end

        content:setLayoutParameter( layoutParameter )
        contentContainer:addChild( content )
        mContainerHeight = mContainerHeight + content:getSize().height

        local messages = v["messages"]
        for i = 1, table.getn( messages ) do
            local content = createMessageContent( i, messages[i] )
            
            content:setLayoutParameter( layoutParameter )
            contentContainer:addChild( content )
            mContainerHeight = mContainerHeight + content:getSize().height
        end
    end

    contentContainer:setInnerContainerSize( CCSize:new( 0, mContainerHeight ) )
    local layout = tolua.cast( contentContainer, "Layout" )
    layout:requestDoLayout()

    contentContainer:jumpToBottom()
end

function addMessage( chatMessages )
    
    if not mWidget then
        -- protect against user changing scene while fetching new messages
        return
    end

    local contentContainer = tolua.cast( mWidget:getChildByName("ScrollView"), "ScrollView" )

    local layoutParameter = LinearLayoutParameter:create()
    layoutParameter:setGravity(LINEAR_GRAVITY_CENTER_VERTICAL)

    local chatMessageList = chatMessages:getMessageDateList()
    for k,v in pairs( chatMessageList ) do

        -- Add message must be happened today.
        -- There might be bug during mid-night, but who cares.
        if not mHasTodayMessage then
            local content = SceneManager.widgetFromJsonFile("scenes/ChatMessageDate.json")
            local dateDisplay = tolua.cast( content:getChildByName("date"), "Label" )
            dateDisplay:setText( v["dateDisplay"] )

            content:setLayoutParameter( layoutParameter )
            contentContainer:addChild( content )
            mContainerHeight = mContainerHeight + content:getSize().height
            
            mHasTodayMessage = true
        end

        local messages = v["messages"]
        for i = 1, table.getn( messages ) do
            local content = createMessageContent( i, messages[i] )
            content:setLayoutParameter( layoutParameter )
            contentContainer:addChild( content )
            mContainerHeight = mContainerHeight + content:getSize().height
        end
    end

    contentContainer:setInnerContainerSize( CCSize:new( 0, mContainerHeight ) )
    local layout = tolua.cast( contentContainer, "Layout" )
    layout:requestDoLayout()

    if next( chatMessageList ) then
        contentContainer:jumpToBottom()
    end
end


function createMessageContent( i, message )
    local name = message["UserName"]
    -- Todo according to the name of the sender
    local content
    if name == Logic:getDisplayName() then
        content = SceneManager.widgetFromJsonFile("scenes/ChatMyMessageContent.json")
        relayoutChatMessage( content, message, true )
    else
        content = SceneManager.widgetFromJsonFile("scenes/ChatMessageContent.json")
        relayoutChatMessage( content, message, false, i )
    end

    return content
end

function relayoutChatMessage( content, message, isMe, i )
    local messageTextMaxWidth = 500
    local messageTextHeight = 28
    local messageTextPaddingY = 8
    local messageTextMinWidth = 170
    local messageBgNTextOffset = ccp( 50, 70 )
    local messagePanelNTextOffset = ccp( 140, 90 )
    local messageNameNTextOffsetY = 50
    local messageTimeNTextOffsetX = 50

    if isMe then
        messageBgNTextOffset = ccp( 50, 30 )
        messagePanelNTextOffset = ccp( 140, 50 )
    end

    local name = message["UserName"]
    local text = message["MessageText"]
    local time = message["UnixTimeStamp"]
    local userid = message["UserId"]

    local messageBg = tolua.cast( content:getChildByName("bg"), "ImageView" )
    local messageLabel = tolua.cast( content:getChildByName("message"), "Label" )
    local messageName = tolua.cast( content:getChildByName("name"), "Label" )
    local messageTime = tolua.cast( content:getChildByName("time"), "Label" )
    local logo = tolua.cast( content:getChildByName("Image_Profile"), "ImageView" )
    messageName:setText( name )
    messageLabel:setText( text )
    messageTime:setText( os.date( "%H:%M", time ) )
    local originSize = messageLabel:getSize()
    local messageNamePositionX = messageName:getPositionX()
    local messageTimePositionY = messageTime:getPositionY()
    if originSize.width > messageTextMaxWidth then
        local messageBlockHeight = math.ceil( originSize.width / messageTextMaxWidth ) * ( messageTextHeight + messageTextPaddingY )
        messageLabel:setTextAreaSize( CCSize:new( messageTextMaxWidth, messageBlockHeight ) )
        messageBg:setSize( CCSize:new( messageTextMaxWidth + messageBgNTextOffset.x, messageBlockHeight + messageBgNTextOffset.y ) )
        content:setSize( CCSize:new( messageTextMaxWidth + messagePanelNTextOffset.x, messageBlockHeight + messagePanelNTextOffset.y ) )
        messageName:setPosition( ccp( messageNamePositionX, messageBlockHeight + messageNameNTextOffsetY ) )
        if not isMe then
            logo:setPosition( ccp( logo:getPositionX(), messageBlockHeight + messageNameNTextOffsetY ) )
        end
    else
        local textWidth = math.max( originSize.width, messageTextMinWidth )
        textWidth = math.max( textWidth, messageName:getSize().width )

        messageBg:setSize( CCSize:new( textWidth + messageBgNTextOffset.x, messageTextHeight + messageBgNTextOffset.y ) )
        content:setSize( CCSize:new( textWidth + messagePanelNTextOffset.x, messageTextHeight + messagePanelNTextOffset.y ) )
        messageName:setPosition( ccp( messageNamePositionX, messageTextHeight + messageNameNTextOffsetY ) )
        if not isMe then
            logo:setPosition( ccp( logo:getPositionX(), messageTextHeight + messageNameNTextOffsetY ) )
            messageTime:setPosition( ccp( textWidth + messageTimeNTextOffsetX, messageTimePositionY ) )
        end
    end

    if not isMe then
        local eventHandler = function( sender, eventType )
            if eventType == TOUCH_EVENT_ENDED then
                EventManager:postEvent( Event.Enter_History, { userid } )
            end
        end
        logo:addTouchEventListener( eventHandler )
        messageName:addTouchEventListener( eventHandler )

        local seqArray = CCArray:create()
        seqArray:addObject( CCDelayTime:create( i * 0.2 ) )
        seqArray:addObject( CCCallFuncN:create( function()
            if message["PictureUrl"] ~= nil then
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
                SMIS.getSMImagePath( message["PictureUrl"], handler )
            end
        end ) )

        mWidget:runAction( CCSequence:create( seqArray ) )
    end
end