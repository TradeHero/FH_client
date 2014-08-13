#ifndef __DeviceJNI_H__
#define __DeviceJNI_H__

#include "cocos2d.h"

#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)

#include "ExtensionMacros.h"

void closeKeyboardJNI(void *ctx);

#endif /* #if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID) */

#endif /* __DeviceJNI_H__ */

