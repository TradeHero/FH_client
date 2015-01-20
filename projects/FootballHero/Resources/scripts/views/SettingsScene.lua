module(..., package.seeall)

local SceneManager = require("scripts.SceneManager")
local Navigator = require("scripts.views.Navigator")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local SettingsConfig = require("scripts.config.Settings")
local Constants = require("scripts.Constants")

local mWidget
local mLogo
local mDropdown
local mDropdownHeight

function loadFrame()
	local widget = GUIReader:shareReader():widgetFromJsonFile("scenes/SettingsHome.json")
    mWidget = widget
    mWidget:registerScriptHandler( EnterOrExit )
    SceneManager.clearNAddWidget( widget )
    SceneManager.clearKeypadBackListener()

    Navigator.loadFrame( widget )

    initContent()
end

function EnterOrExit( eventType )
    if eventType == "enter" then
    elseif eventType == "exit" then
        mWidget = nil
        mLogo = nil
    end
end

function isFrameShown()
    return mWidget ~= nil
end

function initContent()
    local title = tolua.cast( mWidget:getChildByName("Label_Title"), "Label" )
    title:setText( Constants.String.settings.title )
    
	local contentContainer = tolua.cast( mWidget:getChildByName("ScrollView"), "ScrollView" )
    contentContainer:removeAllChildrenWithCleanup( true )

    local layoutParameter = LinearLayoutParameter:create()
    layoutParameter:setGravity(LINEAR_GRAVITY_CENTER_VERTICAL)
    local contentHeight = 0

    for i = 1, table.getn( SettingsConfig.SettingsItem ) do

        local SettingsSubItem = SettingsConfig.SettingsItem[i]

        if SettingsSubItem.Enabled then
            local header = SceneManager.widgetFromJsonFile("scenes/SettingsItemHeaderFrame.json")
            contentContainer:addChild( header )
            contentHeight = contentHeight + header:getSize().height

            local title = tolua.cast( header:getChildByName("Label_Name"), "Label" )
            title:setText( SettingsSubItem.Title )

            contentHeight = contentHeight + initSettingsSubItem( contentContainer, SettingsSubItem )
        end

    end

    contentContainer:setInnerContainerSize( CCSize:new( 0, contentHeight ) )
    local layout = tolua.cast( contentContainer, "Layout" )
    layout:requestDoLayout()
end

function initSettingsSubItem( contentContainer, settingsSubItem )
    local contentHeight

    if settingsSubItem.SettingType == SettingsConfig.SETTING_TYPE_INFO then
        contentHeight = initSettingsUserInfo( contentContainer, settingsSubItem )
    elseif settingsSubItem.SettingType == SettingsConfig.SETTING_TYPE_FAVORITE_TEAM then
        contentHeight = initSettingsFavoriteTeam( contentContainer, settingsSubItem )
    elseif settingsSubItem.SettingType == SettingsConfig.SETTING_TYPE_LANGUAGE then
        contentHeight = initSettingsLanguage( contentContainer, settingsSubItem )
    elseif settingsSubItem.SettingType == SettingsConfig.SETTING_TYPE_OTHERS then
        contentHeight = initSettingsOthers( contentContainer, settingsSubItem )
    end

    return contentHeight
end

function initSettingsUserInfo( contentContainer, settingsSubItem )
    local content = SceneManager.widgetFromJsonFile("scenes/SettingsUserInformationFrame.json")

    local edit = tolua.cast( content:getChildByName("Label_Edit"), "Label" )
    edit:setText( Constants.String.settings.tap_to_edit )
    edit:addTouchEventListener( logoEventHandler )

    mLogo = tolua.cast( content:getChildByName("Image_Logo"), "ImageView" )
    mLogo:addTouchEventListener( logoEventHandler )

    local email = content:getChildByName("Panel_Email")
    local phone = content:getChildByName("Panel_Phone")
    local emailText = tolua.cast( email:getChildByName("Label_Email"), "Label" )
    local phoneText = tolua.cast( phone:getChildByName("Label_Phone"), "Label" )
    emailText:setText( Constants.String.settings.email )
    phoneText:setText( Constants.String.settings.phone )
    
    contentContainer:addChild( content )
    
    return content:getSize().height
end

function initSettingsFavoriteTeam( contentContainer, settingsSubItem )
    -- TODO next version
    -- local content = SceneManager.widgetFromJsonFile("scenes/SettingsUserInformationFrame.json")
    
    -- contentContainer:addChild( content )
    -- contentHeight = contentHeight + content:getSize().height
end

function initSettingsLanguage( contentContainer, settingsSubItem )
    local contentHeight = 0

    local appLanguage = CCUserDefault:sharedUserDefault():getIntegerForKey( SettingsConfig.SETTING_KEY_LANGUAGE ) or SettingsConfig.LanguageType.kLanguageEnglish
    local selectedLanguage = settingsSubItem["Items"][appLanguage + 1]

    local content = SceneManager.widgetFromJsonFile("scenes/SettingsItemContentFrame.json")
    local name = tolua.cast( content:getChildByName("Label_Name"), "Label" )
    local button = tolua.cast( content:getChildByName("Panel_Button"), "Layout" )
    local arrow = content:getChildByName("Image_Arrow")

    name:setText( selectedLanguage.itemName )
    button:setBackGroundImage( Constants.COMMUNITY_IMAGE_PATH.."img-leaguebox.png" )

    contentContainer:addChild( content )
    contentHeight = contentHeight + content:getSize().height

    button:addTouchEventListener( toggleLanguageEventHandler )
    mDropdown = SceneManager.widgetFromJsonFile("scenes/SettingsItemDropdownFrame.json")
    local dropdown = mDropdown:getChildByName("Panel_Dropdown")

    mDropdownHeight = 0
    for i = 1, table.getn( settingsSubItem["Items"] ) do

        local language = settingsSubItem["Items"][i]

        if language then
            local content = SceneManager.widgetFromJsonFile("scenes/SettingsItemContentFrame.json")
            local name = tolua.cast( content:getChildByName("Label_Name"), "Label" )
            local button = tolua.cast( content:getChildByName("Panel_Button"), "Layout" )
            local arrow = tolua.cast( content:getChildByName("Image_Arrow"), "ImageView" )
            
            content:removeChild( arrow )
            name:setText( language.itemName )

            local eventHandler = function( sender, eventType )
                if eventType == TOUCH_EVENT_ENDED then
                    EventManager:postEvent( language.event, i )
                end
            end
            button:addTouchEventListener( eventHandler )
            
            dropdown:addChild( content )
            mDropdownHeight = mDropdownHeight + content:getSize().height
        end
    end
    
    dropdown:setSize( CCSize:new( dropdown:getSize().width, mDropdownHeight ) )

    -- Initialize dropdown container height to 0
    mDropdown:setSize( CCSize:new( mDropdown:getSize().width, 0 ) )
    mDropdown:setEnabled( false )
    
    contentHeight = contentHeight + content:getSize().height
    contentContainer:addChild( mDropdown )
    
    return contentHeight
end

function initSettingsOthers( contentContainer, settingsSubItem )
    local contentHeight = 0

    for i = 1, table.getn( settingsSubItem["Items"] ) do
        local setting = settingsSubItem["Items"][i]
        local content = SceneManager.widgetFromJsonFile("scenes/SettingsItemContentFrame.json")
        local name = tolua.cast( content:getChildByName("Label_Name"), "Label" )
        local button = tolua.cast( content:getChildByName("Panel_Button"), "Layout" )
        local arrow = content:getChildByName("Image_Arrow")

        name:setText( setting.itemName )

        local eventHandler = function( sender, eventType )
            if eventType == TOUCH_EVENT_ENDED then
                EventManager:postEvent( setting.event )
            end
        end
        button:addTouchEventListener( eventHandler )
        arrow:addTouchEventListener( eventHandler )

        button:setBackGroundImage( Constants.COMMUNITY_IMAGE_PATH.."img-leaguebox.png" )
        
        contentContainer:addChild( content )
        contentHeight = contentHeight + content:getSize().height
    end

    return contentHeight
end


function initSettingsItemContent( content, info )
    local name = tolua.cast( content:getChildByName("name"), "Label" )

    name:setText( info["itemName"] )
end

function logoEventHandler( sender,eventType )
    if eventType == TOUCH_EVENT_ENDED then
        local logoSelectResultHandler = function( success )
            if success then
                local postLogoCallback = function()
                    mLogo:loadTexture( Constants.LOGO_IMAGE_PATH )

                    RequestUtils.invalidResponseCacheContainsUrl( RequestUtils.GET_COUPON_HISTORY_REST_CALL )
                end

                EventManager:postEvent( Event.Do_Post_Logo, { postLogoCallback } )
                
            end
        end

        Misc:sharedDelegate():selectImage( Constants.LOGO_IMAGE_PATH, 100, 100, logoSelectResultHandler )
    end
end

function toggleLanguageEventHandler( sender,eventType )
    local contentContainer = tolua.cast( mWidget:getChildByName("ScrollView"), "ScrollView" )
    local contentHeight = contentContainer:getSize().height
    
    if eventType == TOUCH_EVENT_ENDED then
        if mDropdown:isEnabled() then
            mDropdown:setSize( CCSize:new( mDropdown:getSize().width, 0 ) )
            mDropdown:setEnabled( false )
            contentHeight = contentHeight - mDropdown:getSize().height
            
        else
            mDropdown:setSize( CCSize:new( mDropdown:getSize().width, mDropdownHeight ) )
            mDropdown:setEnabled( true )
            contentHeight = contentHeight + mDropdown:getSize().height
            
        end
    end

    contentContainer:setInnerContainerSize( CCSize:new( 0, contentHeight ) )
    local layout = tolua.cast( contentContainer, "Layout" )
    layout:requestDoLayout()
end
