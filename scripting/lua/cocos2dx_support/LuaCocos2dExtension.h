#ifndef __LUACOCOSENTENSION_H_
#define __LUACOCOSENTENSION_H_

#ifdef __cplusplus
extern "C" {
#endif
#include "tolua++.h"
#ifdef __cplusplus
}
#endif

TOLUA_API int tolua_Extension_open(lua_State* tolua_S);

#endif // __LUACOCOSENTENSION_H_
