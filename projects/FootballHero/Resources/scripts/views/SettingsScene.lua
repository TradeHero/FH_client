module(..., package.seeall)

local SceneManager = require("scripts.SceneManager")
local Navigator = require("scripts.views.Navigator")
local EventManager = require("scripts.events.EventManager").getInstance()
local Event = require("scripts.events.Event").EventList
local SettingsConfig = require("scripts.config.Settings")
local LanguagesConfig = require("scripts.config.Languages")
local Constants = require("scripts.Constants")
local Logic = require("scripts.Logic").getInstance()
local SMIS = require("scripts.SMIS")
local RequestUtils = require("scripts.RequestUtils")


local mWidget
local mLogo
local mDropdown
local mDropdownHeight
local mCurrLanguage

function loadFrame()
	local widget = GUIReader:shareReader():widgetFromJsonFile("scenes/SettingsHome.json")
    mWidget = widget
    mWidget:registerScriptHandler( EnterOrExit )
    SceneManager.clearNAddWidget( widget )
    SceneManager.clearKeypadBackListener()

    Navigator.loadFrame( widget )

    local backBt = mWidget:getChildByName("Button_Back")
    backBt:setEnabled( false )

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
    
    local logout = tolua.cast( mWidget:getChildByName("Button_Logout"), "Button" )
    logout:setTitleText( Constants.String.settings.logout )
    local eventHandler = function( sender, eventType )
        if eventType == TOUCH_EVENT_ENDED then
            EventManager:postEvent( Event.Do_Log_Out )
        end
    end
    logout:addTouchEventListener( eventHandler )

	local contentContainer = tolua.cast( mWidget:getChildByName("ScrollView"), "ScrollView" )
    contentContainer:removeAllChildrenWithCleanup( true )

    local layoutParameter = LinearLayoutParameter:create()
    layoutParameter:setGravity(LINEAR_GRAVITY_CENTER_VERTICAL)
    local contentHeight = 0

    for i = 1, table.getn( SettingsConfig.SettingsItem ) do

        local SettingsSubItem = SettingsConfig.SettingsItem[i]

        if SettingsSubItem.Enabled then
            contentHeight = contentHeight + initSettingsHeader( contentContainer, SettingsSubItem )
            contentHeight = contentHeight + initSettingsSubItem( contentContainer, SettingsSubItem )
        end

    end

    contentContainer:setInnerContainerSize( CCSize:new( 0, contentHeight ) )
    local layout = tolua.cast( contentContainer, "Layout" )
    layout:requestDoLayout()
end

function initSettingsHeader( contentContainer, settingsSubItem )
    local header = SceneManager.widgetFromJsonFile("scenes/SettingsItemHeaderFrame.json")
    contentContainer:addChild( header )
    
    local title = tolua.cast( header:getChildByName("Label_Name"), "Label" )
    title:setText( Constants.String.settings[settingsSubItem["TitleKey"]] )

    local edit = tolua.cast( header:getChildByName("Button_Edit"), "Button" )

    if settingsSubItem.SettingType == SettingsConfig.SETTING_TYPE_FAVORITE_TEAM then
        local editEventHandler = function( sender, eventType )
            if eventType == TOUCH_EVENT_ENDED then
                EventManager:postEvent( Event.Enter_Settings_Select_League )
            end
        end
        edit:addTouchEventListener( editEventHandler )
    else
        edit:setEnabled( false )
    end

    return header:getSize().height
end

function initSettingsSubItem( contentContainer, settingsSubItem )
    local contentHeight

    if settingsSubItem.SettingType == SettingsConfig.SETTING_TYPE_INFO then
        contentHeight = initSettingsUserInfo( contentContainer, settingsSubItem )
    elseif settingsSubItem.SettingType == SettingsConfig.SETTING_TYPE_FAVORITE_TEAM then
        contentHeight = initSettingsFavoriteTeam( contentContainer, settingsSubItem )
    elseif settingsSubItem.SettingType == SettingsConfig.SETTING_TYPE_LANGUAGE then
        contentHeight = initSettingsLanguage( contentContainer )
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

    local pictureUrl = Logic:getPictureUrl()
    if pictureUrl ~= nil then
        local handler = function( filePath )
            if filePath ~= nil and mWidget ~= nil and mLogo ~= nil then
                local safeLoadTexture = function()
                    mLogo:loadTexture( filePath )
                end

                local errorHandler = function( msg )
                    -- Do nothing
                end

                xpcall( safeLoadTexture, errorHandler )
            end
        end
        SMIS.getSMImagePath( pictureUrl, handler )
    end

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
    
    local contentHeight = 0

    -- foreach fav teams
        local content = SceneManager.widgetFromJsonFile("scenes/SettingsItemContentFrame.json")
        local teamName = tolua.cast( content:getChildByName("Label_Name"), "Label" )
        local button = tolua.cast( content:getChildByName("Panel_Button"), "Layout" )
        local arrow = content:getChildByName("Image_Arrow")

        teamName:setText( Constants.String.settings.favorite_team_none )
        button:setBackGroundImage( Constants.COMMUNITY_IMAGE_PATH.."img-leaguebox.png" )
        arrow:setEnabled( false )

    
    contentContainer:addChild( content )
    contentHeight = contentHeight + content:getSize().height

    return contentHeight
end

function initSettingsLanguage( contentContainer )
    local contentHeight = 0

    local appLanguage = CCUserDefault:sharedUserDefault():getStringForKey( LanguagesConfig.KEY_OF_LANGUAGE )
    local selectedLanguageConfig = LanguagesConfig.getLanguageConfigById( tonumber( appLanguage ) )

    local content = SceneManager.widgetFromJsonFile("scenes/SettingsItemContentFrame.json")
    mCurrLanguage = tolua.cast( content:getChildByName("Label_Name"), "Label" )
    local button = tolua.cast( content:getChildByName("Panel_Button"), "Layout" )
    local arrow = content:getChildByName("Image_Arrow")

    mCurrLanguage:setText( selectedLanguageConfig["name"] )
    button:setBackGroundImage( Constants.COMMUNITY_IMAGE_PATH.."img-leaguebox.png" )

    contentContainer:addChild( content )
    contentHeight = contentHeight + content:getSize().height

    button:addTouchEventListener( toggleLanguageEventHandler )
    arrow:addTouchEventListener( toggleLanguageEventHandler )
    mDropdown = SceneManager.widgetFromJsonFile("scenes/SettingsItemDropdownFrame.json")
    local dropdown = mDropdown:getChildByName("Panel_Dropdown")

    mDropdownHeight = 0
    local supportedLanguages = LanguagesConfig.getSupportedLanguages()
    for i = 1, table.getn( supportedLanguages ) do

        local language = supportedLanguages[i]

        if language then
            local content = SceneManager.widgetFromJsonFile("scenes/SettingsItemContentFrame.json")
            local name = tolua.cast( content:getChildByName("Label_Name"), "Label" )
            local button = tolua.cast( content:getChildByName("Panel_Button"), "Layout" )
            local arrow = tolua.cast( content:getChildByName("Image_Arrow"), "ImageView" )
            
            content:removeChild( arrow )
            name:setText( language["name"] )

            local eventHandler = function( sender, eventType )
                if eventType == TOUCH_EVENT_ENDED then
                    local appLanguage = language["id"]
                    CCUserDefault:sharedUserDefault():setStringForKey( LanguagesConfig.KEY_OF_LANGUAGE, tostring(appLanguage) )
                    toggleLanguageDropDown( language["name"] )
                    EventManager:postEvent( Event.Do_Select_Language, { appLanguage } )
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

        name:setText( Constants.String.settings[setting.itemName] )

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
    if eventType == TOUCH_EVENT_ENDED then
        
        local parent = sender:getParent()
        local arrow = tolua.cast( parent:getChildByName("Image_Arrow"), "ImageView" )
        
        if mDropdown:isEnabled() then
            arrow:setRotation( 270 )
        else
            arrow:setRotation( 0 )
        end

        toggleLanguageDropDown()
    end
end

function toggleLanguageDropDown( languageText )
    local contentContainer = tolua.cast( mWidget:getChildByName("ScrollView"), "ScrollView" )
    local contentHeight = contentContainer:getSize().height
    
    if mDropdown:isEnabled() then
        mDropdown:setSize( CCSize:new( mDropdown:getSize().width, 0 ) )
        mDropdown:setEnabled( false )
        contentHeight = contentHeight - mDropdown:getSize().height
        
    else
        mDropdown:setSize( CCSize:new( mDropdown:getSize().width, mDropdownHeight ) )
        mDropdown:setEnabled( true )
        contentHeight = contentHeight + mDropdown:getSize().height
        
    end

    contentContainer:setInnerContainerSize( CCSize:new( 0, contentHeight ) )
    local layout = tolua.cast( contentContainer, "Layout" )
    layout:requestDoLayout()

    if languageText then
        mCurrLanguage:setText( languageText )
    end
end

