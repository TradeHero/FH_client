//
//  DeviceID.cpp
//  FootballHero
//
//  Created by SpiritRain on 15/7/22.
//
//

#include "DeviceID.h"
#include "cocos2d.h"

#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)

#include "../extensions/GUI/Android/DeviceJNI.h"

#elif (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)

#include "DeviceUtil.h"

#endif



int getDeviceID(lua_State *L){
    std::string text="";
    
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
    text = getDeviceIDJNI();
#elif (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
    text = *IOSDevice::getDeviceID();
#endif
    lua_pushstring(L, text.c_str());
    return 1;
}
