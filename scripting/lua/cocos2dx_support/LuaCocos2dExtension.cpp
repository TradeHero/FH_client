/*
** Lua binding: Extension
** Generated automatically by tolua++-1.0.92 on 03/24/15 12:09:08.
*/

/****************************************************************************
 Copyright (c) 2011 cocos2d-x.org

 http://www.cocos2d-x.org

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 ****************************************************************************/

extern "C" {
#include "tolua_fix.h"
}

#include <map>
#include <string>
#include "cocos2d.h"
#include "CCLuaEngine.h"
#include "FacebookDelegate.h"
#include "HttpRequestForLua.h"
#include "EditBoxDelegateForLua.h"
#include "Analytics.h"
#include "WebviewDelegate.h"
#include "Misc.h"
#include "QuickBloxChat.h"
#include "C2DXShareSDK.h"

using namespace cocos2d;
using namespace cocos2d::extension;
using namespace Social;
using namespace Utils;
using namespace cn::sharesdk;



#include "LuaCocos2dExtension.h"

/* function to register type */
static void tolua_reg_types (lua_State* tolua_S)
{
 tolua_usertype(tolua_S,"CCEditBoxDelegate");
 tolua_usertype(tolua_S,"Misc");
 tolua_usertype(tolua_S,"CCLayer");
 tolua_usertype(tolua_S,"CCArray");
 tolua_usertype(tolua_S,"cocos2d::CCNode");
 tolua_usertype(tolua_S,"HttpRequestForLua");
 tolua_usertype(tolua_S,"C2DXShareSDK");
 tolua_usertype(tolua_S,"WebviewDelegate");
 tolua_usertype(tolua_S,"Analytics");
 tolua_usertype(tolua_S,"CCHttpRequest");
 tolua_usertype(tolua_S,"FacebookDelegate");
 tolua_usertype(tolua_S,"QuickBloxChat");
 
 tolua_usertype(tolua_S,"CCObject");
 tolua_usertype(tolua_S,"CCDictionary");
 tolua_usertype(tolua_S,"EditBoxDelegateForLua");
}

/* method: sharedDelegate of class  FacebookDelegate */
#ifndef TOLUA_DISABLE_tolua_Extension_FacebookDelegate_sharedDelegate00
static int tolua_Extension_FacebookDelegate_sharedDelegate00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertable(tolua_S,1,"FacebookDelegate",0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  {
   FacebookDelegate* tolua_ret = (FacebookDelegate*)  FacebookDelegate::sharedDelegate();
    tolua_pushusertype(tolua_S,(void*)tolua_ret,"FacebookDelegate");
  }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'sharedDelegate'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: login of class  FacebookDelegate */
#ifndef TOLUA_DISABLE_tolua_Extension_FacebookDelegate_login00
static int tolua_Extension_FacebookDelegate_login00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"FacebookDelegate",0,&tolua_err) ||
     (tolua_isvaluenil(tolua_S,2,&tolua_err) || !toluafix_isfunction(tolua_S,2,"LUA_FUNCTION",0,&tolua_err)) ||
     !tolua_isnoobj(tolua_S,3,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  FacebookDelegate* self = (FacebookDelegate*)  tolua_tousertype(tolua_S,1,0);
  LUA_FUNCTION handler = (  toluafix_ref_function(tolua_S,2,0));
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'login'", NULL);
#endif
  {
   self->login(handler);
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'login'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: grantPublishPermission of class  FacebookDelegate */
#ifndef TOLUA_DISABLE_tolua_Extension_FacebookDelegate_grantPublishPermission00
static int tolua_Extension_FacebookDelegate_grantPublishPermission00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"FacebookDelegate",0,&tolua_err) ||
     !tolua_isstring(tolua_S,2,0,&tolua_err) ||
     (tolua_isvaluenil(tolua_S,3,&tolua_err) || !toluafix_isfunction(tolua_S,3,"LUA_FUNCTION",0,&tolua_err)) ||
     !tolua_isnoobj(tolua_S,4,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  FacebookDelegate* self = (FacebookDelegate*)  tolua_tousertype(tolua_S,1,0);
  const char* permission = ((const char*)  tolua_tostring(tolua_S,2,0));
  LUA_FUNCTION handler = (  toluafix_ref_function(tolua_S,3,0));
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'grantPublishPermission'", NULL);
#endif
  {
   self->grantPublishPermission(permission,handler);
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'grantPublishPermission'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: setRequestType of class  CCHttpRequest */
#ifndef TOLUA_DISABLE_tolua_Extension_CCHttpRequest_setRequestType00
static int tolua_Extension_CCHttpRequest_setRequestType00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"CCHttpRequest",0,&tolua_err) ||
     !tolua_isnumber(tolua_S,2,0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,3,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  CCHttpRequest* self = (CCHttpRequest*)  tolua_tousertype(tolua_S,1,0);
  CCHttpRequest::HttpRequestType type = ((CCHttpRequest::HttpRequestType) (int)  tolua_tonumber(tolua_S,2,0));
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'setRequestType'", NULL);
#endif
  {
   self->setRequestType(type);
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'setRequestType'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: getRequestType of class  CCHttpRequest */
#ifndef TOLUA_DISABLE_tolua_Extension_CCHttpRequest_getRequestType00
static int tolua_Extension_CCHttpRequest_getRequestType00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"CCHttpRequest",0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  CCHttpRequest* self = (CCHttpRequest*)  tolua_tousertype(tolua_S,1,0);
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'getRequestType'", NULL);
#endif
  {
   CCHttpRequest::HttpRequestType tolua_ret = (CCHttpRequest::HttpRequestType)  self->getRequestType();
   tolua_pushnumber(tolua_S,(lua_Number)tolua_ret);
  }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'getRequestType'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: setUrl of class  CCHttpRequest */
#ifndef TOLUA_DISABLE_tolua_Extension_CCHttpRequest_setUrl00
static int tolua_Extension_CCHttpRequest_setUrl00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"CCHttpRequest",0,&tolua_err) ||
     !tolua_isstring(tolua_S,2,0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,3,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  CCHttpRequest* self = (CCHttpRequest*)  tolua_tousertype(tolua_S,1,0);
  const char* url = ((const char*)  tolua_tostring(tolua_S,2,0));
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'setUrl'", NULL);
#endif
  {
   self->setUrl(url);
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'setUrl'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: getUrl of class  CCHttpRequest */
#ifndef TOLUA_DISABLE_tolua_Extension_CCHttpRequest_getUrl00
static int tolua_Extension_CCHttpRequest_getUrl00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"CCHttpRequest",0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  CCHttpRequest* self = (CCHttpRequest*)  tolua_tousertype(tolua_S,1,0);
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'getUrl'", NULL);
#endif
  {
   const char* tolua_ret = (const char*)  self->getUrl();
   tolua_pushstring(tolua_S,(const char*)tolua_ret);
  }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'getUrl'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: setRequestData of class  CCHttpRequest */
#ifndef TOLUA_DISABLE_tolua_Extension_CCHttpRequest_setRequestData00
static int tolua_Extension_CCHttpRequest_setRequestData00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"CCHttpRequest",0,&tolua_err) ||
     !tolua_isstring(tolua_S,2,0,&tolua_err) ||
     !tolua_isnumber(tolua_S,3,0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,4,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  CCHttpRequest* self = (CCHttpRequest*)  tolua_tousertype(tolua_S,1,0);
  const char* buffer = ((const char*)  tolua_tostring(tolua_S,2,0));
  unsigned int len = ((unsigned int)  tolua_tonumber(tolua_S,3,0));
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'setRequestData'", NULL);
#endif
  {
   self->setRequestData(buffer,len);
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'setRequestData'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: getRequestData of class  CCHttpRequest */
#ifndef TOLUA_DISABLE_tolua_Extension_CCHttpRequest_getRequestData00
static int tolua_Extension_CCHttpRequest_getRequestData00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"CCHttpRequest",0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  CCHttpRequest* self = (CCHttpRequest*)  tolua_tousertype(tolua_S,1,0);
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'getRequestData'", NULL);
#endif
  {
   char* tolua_ret = (char*)  self->getRequestData();
   tolua_pushstring(tolua_S,(const char*)tolua_ret);
  }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'getRequestData'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: getRequestDataSize of class  CCHttpRequest */
#ifndef TOLUA_DISABLE_tolua_Extension_CCHttpRequest_getRequestDataSize00
static int tolua_Extension_CCHttpRequest_getRequestDataSize00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"CCHttpRequest",0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  CCHttpRequest* self = (CCHttpRequest*)  tolua_tousertype(tolua_S,1,0);
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'getRequestDataSize'", NULL);
#endif
  {
   int tolua_ret = (int)  self->getRequestDataSize();
   tolua_pushnumber(tolua_S,(lua_Number)tolua_ret);
  }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'getRequestDataSize'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: setTag of class  CCHttpRequest */
#ifndef TOLUA_DISABLE_tolua_Extension_CCHttpRequest_setTag00
static int tolua_Extension_CCHttpRequest_setTag00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"CCHttpRequest",0,&tolua_err) ||
     !tolua_isstring(tolua_S,2,0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,3,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  CCHttpRequest* self = (CCHttpRequest*)  tolua_tousertype(tolua_S,1,0);
  const char* tag = ((const char*)  tolua_tostring(tolua_S,2,0));
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'setTag'", NULL);
#endif
  {
   self->setTag(tag);
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'setTag'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: getTag of class  CCHttpRequest */
#ifndef TOLUA_DISABLE_tolua_Extension_CCHttpRequest_getTag00
static int tolua_Extension_CCHttpRequest_getTag00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"CCHttpRequest",0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  CCHttpRequest* self = (CCHttpRequest*)  tolua_tousertype(tolua_S,1,0);
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'getTag'", NULL);
#endif
  {
   const char* tolua_ret = (const char*)  self->getTag();
   tolua_pushstring(tolua_S,(const char*)tolua_ret);
  }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'getTag'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: create of class  HttpRequestForLua */
#ifndef TOLUA_DISABLE_tolua_Extension_HttpRequestForLua_create00
static int tolua_Extension_HttpRequestForLua_create00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertable(tolua_S,1,"HttpRequestForLua",0,&tolua_err) ||
     !tolua_isnumber(tolua_S,2,0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,3,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  CCHttpRequest::HttpRequestType type = ((CCHttpRequest::HttpRequestType) (int)  tolua_tonumber(tolua_S,2,0));
  {
   HttpRequestForLua* tolua_ret = (HttpRequestForLua*)  HttpRequestForLua::create(type);
    tolua_pushusertype(tolua_S,(void*)tolua_ret,"HttpRequestForLua");
  }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'create'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: addHeader of class  HttpRequestForLua */
#ifndef TOLUA_DISABLE_tolua_Extension_HttpRequestForLua_addHeader00
static int tolua_Extension_HttpRequestForLua_addHeader00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"HttpRequestForLua",0,&tolua_err) ||
     !tolua_isstring(tolua_S,2,0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,3,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  HttpRequestForLua* self = (HttpRequestForLua*)  tolua_tousertype(tolua_S,1,0);
  const char* header = ((const char*)  tolua_tostring(tolua_S,2,0));
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'addHeader'", NULL);
#endif
  {
   self->addHeader(header);
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'addHeader'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: setUserpwd of class  HttpRequestForLua */
#ifndef TOLUA_DISABLE_tolua_Extension_HttpRequestForLua_setUserpwd00
static int tolua_Extension_HttpRequestForLua_setUserpwd00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"HttpRequestForLua",0,&tolua_err) ||
     !tolua_isstring(tolua_S,2,0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,3,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  HttpRequestForLua* self = (HttpRequestForLua*)  tolua_tousertype(tolua_S,1,0);
  const char* userpwd = ((const char*)  tolua_tostring(tolua_S,2,0));
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'setUserpwd'", NULL);
#endif
  {
   self->setUserpwd(userpwd);
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'setUserpwd'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: setPriority of class  HttpRequestForLua */
#ifndef TOLUA_DISABLE_tolua_Extension_HttpRequestForLua_setPriority00
static int tolua_Extension_HttpRequestForLua_setPriority00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"HttpRequestForLua",0,&tolua_err) ||
     !tolua_isnumber(tolua_S,2,0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,3,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  HttpRequestForLua* self = (HttpRequestForLua*)  tolua_tousertype(tolua_S,1,0);
  int p = ((int)  tolua_tonumber(tolua_S,2,0));
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'setPriority'", NULL);
#endif
  {
   self->setPriority(p);
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'setPriority'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: sendHttpRequest of class  HttpRequestForLua */
#ifndef TOLUA_DISABLE_tolua_Extension_HttpRequestForLua_sendHttpRequest00
static int tolua_Extension_HttpRequestForLua_sendHttpRequest00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"HttpRequestForLua",0,&tolua_err) ||
     !tolua_isstring(tolua_S,2,0,&tolua_err) ||
     (tolua_isvaluenil(tolua_S,3,&tolua_err) || !toluafix_isfunction(tolua_S,3,"LUA_FUNCTION",0,&tolua_err)) ||
     !tolua_isnoobj(tolua_S,4,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  HttpRequestForLua* self = (HttpRequestForLua*)  tolua_tousertype(tolua_S,1,0);
  const char* url = ((const char*)  tolua_tostring(tolua_S,2,0));
  LUA_FUNCTION callbackFunc = (  toluafix_ref_function(tolua_S,3,0));
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'sendHttpRequest'", NULL);
#endif
  {
   self->sendHttpRequest(url,callbackFunc);
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'sendHttpRequest'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: onHttpRequestCompleted of class  HttpRequestForLua */
#ifndef TOLUA_DISABLE_tolua_Extension_HttpRequestForLua_onHttpRequestCompleted00
static int tolua_Extension_HttpRequestForLua_onHttpRequestCompleted00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"HttpRequestForLua",0,&tolua_err) ||
     !tolua_isusertype(tolua_S,2,"cocos2d::CCNode",0,&tolua_err) ||
     !tolua_isuserdata(tolua_S,3,0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,4,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  HttpRequestForLua* self = (HttpRequestForLua*)  tolua_tousertype(tolua_S,1,0);
  cocos2d::CCNode* sender = ((cocos2d::CCNode*)  tolua_tousertype(tolua_S,2,0));
  void* data = ((void*)  tolua_touserdata(tolua_S,3,0));
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'onHttpRequestCompleted'", NULL);
#endif
  {
   self->onHttpRequestCompleted(sender,data);
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'onHttpRequestCompleted'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: setRequest of class  HttpRequestForLua */
#ifndef TOLUA_DISABLE_tolua_Extension_HttpRequestForLua_setRequest00
static int tolua_Extension_HttpRequestForLua_setRequest00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"HttpRequestForLua",0,&tolua_err) ||
     !tolua_isusertype(tolua_S,2,"CCHttpRequest",0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,3,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  HttpRequestForLua* self = (HttpRequestForLua*)  tolua_tousertype(tolua_S,1,0);
  CCHttpRequest* request = ((CCHttpRequest*)  tolua_tousertype(tolua_S,2,0));
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'setRequest'", NULL);
#endif
  {
   self->setRequest(request);
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'setRequest'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: getRequest of class  HttpRequestForLua */
#ifndef TOLUA_DISABLE_tolua_Extension_HttpRequestForLua_getRequest00
static int tolua_Extension_HttpRequestForLua_getRequest00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"HttpRequestForLua",0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  HttpRequestForLua* self = (HttpRequestForLua*)  tolua_tousertype(tolua_S,1,0);
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'getRequest'", NULL);
#endif
  {
   CCHttpRequest* tolua_ret = (CCHttpRequest*)  self->getRequest();
    tolua_pushusertype(tolua_S,(void*)tolua_ret,"CCHttpRequest");
  }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'getRequest'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: create of class  EditBoxDelegateForLua */
#ifndef TOLUA_DISABLE_tolua_Extension_EditBoxDelegateForLua_create00
static int tolua_Extension_EditBoxDelegateForLua_create00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertable(tolua_S,1,"EditBoxDelegateForLua",0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  {
   EditBoxDelegateForLua* tolua_ret = (EditBoxDelegateForLua*)  EditBoxDelegateForLua::create();
    tolua_pushusertype(tolua_S,(void*)tolua_ret,"EditBoxDelegateForLua");
  }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'create'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: registerEventScriptHandler of class  EditBoxDelegateForLua */
#ifndef TOLUA_DISABLE_tolua_Extension_EditBoxDelegateForLua_registerEventScriptHandler00
static int tolua_Extension_EditBoxDelegateForLua_registerEventScriptHandler00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"EditBoxDelegateForLua",0,&tolua_err) ||
     !tolua_isnumber(tolua_S,2,0,&tolua_err) ||
     (tolua_isvaluenil(tolua_S,3,&tolua_err) || !toluafix_isfunction(tolua_S,3,"LUA_FUNCTION",0,&tolua_err)) ||
     !tolua_isnoobj(tolua_S,4,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  EditBoxDelegateForLua* self = (EditBoxDelegateForLua*)  tolua_tousertype(tolua_S,1,0);
  EditBoxEvent eventType = ((EditBoxEvent) (int)  tolua_tonumber(tolua_S,2,0));
  LUA_FUNCTION nHandler = (  toluafix_ref_function(tolua_S,3,0));
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'registerEventScriptHandler'", NULL);
#endif
  {
   self->registerEventScriptHandler(eventType,nHandler);
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'registerEventScriptHandler'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: unregisterEventScriptHandler of class  EditBoxDelegateForLua */
#ifndef TOLUA_DISABLE_tolua_Extension_EditBoxDelegateForLua_unregisterEventScriptHandler00
static int tolua_Extension_EditBoxDelegateForLua_unregisterEventScriptHandler00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"EditBoxDelegateForLua",0,&tolua_err) ||
     !tolua_isnumber(tolua_S,2,0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,3,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  EditBoxDelegateForLua* self = (EditBoxDelegateForLua*)  tolua_tousertype(tolua_S,1,0);
  EditBoxEvent eventType = ((EditBoxEvent) (int)  tolua_tonumber(tolua_S,2,0));
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'unregisterEventScriptHandler'", NULL);
#endif
  {
   self->unregisterEventScriptHandler(eventType);
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'unregisterEventScriptHandler'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* get function: __CCEditBoxDelegate__ of class  EditBoxDelegateForLua */
#ifndef TOLUA_DISABLE_tolua_get_EditBoxDelegateForLua___CCEditBoxDelegate__
static int tolua_get_EditBoxDelegateForLua___CCEditBoxDelegate__(lua_State* tolua_S)
{
  EditBoxDelegateForLua* self = (EditBoxDelegateForLua*)  tolua_tousertype(tolua_S,1,0);
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in accessing variable '__CCEditBoxDelegate__'",NULL);
#endif
#ifdef __cplusplus
   tolua_pushusertype(tolua_S,(void*)static_cast<CCEditBoxDelegate*>(self), "CCEditBoxDelegate");
#else
   tolua_pushusertype(tolua_S,(void*)((CCEditBoxDelegate*)self), "CCEditBoxDelegate");
#endif
 return 1;
}
#endif //#ifndef TOLUA_DISABLE

/* method: sharedDelegate of class  Analytics */
#ifndef TOLUA_DISABLE_tolua_Extension_Analytics_sharedDelegate00
static int tolua_Extension_Analytics_sharedDelegate00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertable(tolua_S,1,"Analytics",0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  {
   Analytics* tolua_ret = (Analytics*)  Analytics::sharedDelegate();
    tolua_pushusertype(tolua_S,(void*)tolua_ret,"Analytics");
  }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'sharedDelegate'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: postEvent of class  Analytics */
#ifndef TOLUA_DISABLE_tolua_Extension_Analytics_postEvent00
static int tolua_Extension_Analytics_postEvent00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"Analytics",0,&tolua_err) ||
     !tolua_isstring(tolua_S,2,0,&tolua_err) ||
     !tolua_isstring(tolua_S,3,0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,4,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  Analytics* self = (Analytics*)  tolua_tousertype(tolua_S,1,0);
  const char* eventName = ((const char*)  tolua_tostring(tolua_S,2,0));
  const char* paramString = ((const char*)  tolua_tostring(tolua_S,3,0));
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'postEvent'", NULL);
#endif
  {
   self->postEvent(eventName,paramString);
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'postEvent'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: sharedDelegate of class  WebviewDelegate */
#ifndef TOLUA_DISABLE_tolua_Extension_WebviewDelegate_sharedDelegate00
static int tolua_Extension_WebviewDelegate_sharedDelegate00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertable(tolua_S,1,"WebviewDelegate",0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  {
   WebviewDelegate* tolua_ret = (WebviewDelegate*)  WebviewDelegate::sharedDelegate();
    tolua_pushusertype(tolua_S,(void*)tolua_ret,"WebviewDelegate");
  }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'sharedDelegate'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: openWebpage of class  WebviewDelegate */
#ifndef TOLUA_DISABLE_tolua_Extension_WebviewDelegate_openWebpage00
static int tolua_Extension_WebviewDelegate_openWebpage00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"WebviewDelegate",0,&tolua_err) ||
     !tolua_isstring(tolua_S,2,0,&tolua_err) ||
     !tolua_isnumber(tolua_S,3,0,&tolua_err) ||
     !tolua_isnumber(tolua_S,4,0,&tolua_err) ||
     !tolua_isnumber(tolua_S,5,0,&tolua_err) ||
     !tolua_isnumber(tolua_S,6,0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,7,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  WebviewDelegate* self = (WebviewDelegate*)  tolua_tousertype(tolua_S,1,0);
  const char* url = ((const char*)  tolua_tostring(tolua_S,2,0));
  int x = ((int)  tolua_tonumber(tolua_S,3,0));
  int y = ((int)  tolua_tonumber(tolua_S,4,0));
  int w = ((int)  tolua_tonumber(tolua_S,5,0));
  int h = ((int)  tolua_tonumber(tolua_S,6,0));
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'openWebpage'", NULL);
#endif
  {
   self->openWebpage(url,x,y,w,h);
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'openWebpage'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: closeWebpage of class  WebviewDelegate */
#ifndef TOLUA_DISABLE_tolua_Extension_WebviewDelegate_closeWebpage00
static int tolua_Extension_WebviewDelegate_closeWebpage00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"WebviewDelegate",0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  WebviewDelegate* self = (WebviewDelegate*)  tolua_tousertype(tolua_S,1,0);
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'closeWebpage'", NULL);
#endif
  {
   self->closeWebpage();
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'closeWebpage'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: sharedDelegate of class  Misc */
#ifndef TOLUA_DISABLE_tolua_Extension_Misc_sharedDelegate00
static int tolua_Extension_Misc_sharedDelegate00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertable(tolua_S,1,"Misc",0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  {
   Misc* tolua_ret = (Misc*)  Misc::sharedDelegate();
    tolua_pushusertype(tolua_S,(void*)tolua_ret,"Misc");
  }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'sharedDelegate'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: copyToPasteboard of class  Misc */
#ifndef TOLUA_DISABLE_tolua_Extension_Misc_copyToPasteboard00
static int tolua_Extension_Misc_copyToPasteboard00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"Misc",0,&tolua_err) ||
     !tolua_isstring(tolua_S,2,0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,3,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  Misc* self = (Misc*)  tolua_tousertype(tolua_S,1,0);
  const char* content = ((const char*)  tolua_tostring(tolua_S,2,0));
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'copyToPasteboard'", NULL);
#endif
  {
   self->copyToPasteboard(content);
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'copyToPasteboard'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: selectImage of class  Misc */
#ifndef TOLUA_DISABLE_tolua_Extension_Misc_selectImage00
static int tolua_Extension_Misc_selectImage00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"Misc",0,&tolua_err) ||
     !tolua_isstring(tolua_S,2,0,&tolua_err) ||
     !tolua_isnumber(tolua_S,3,0,&tolua_err) ||
     !tolua_isnumber(tolua_S,4,0,&tolua_err) ||
     (tolua_isvaluenil(tolua_S,5,&tolua_err) || !toluafix_isfunction(tolua_S,5,"LUA_FUNCTION",0,&tolua_err)) ||
     !tolua_isnoobj(tolua_S,6,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  Misc* self = (Misc*)  tolua_tousertype(tolua_S,1,0);
  char* path = ((char*)  tolua_tostring(tolua_S,2,0));
  int width = ((int)  tolua_tonumber(tolua_S,3,0));
  int height = ((int)  tolua_tonumber(tolua_S,4,0));
  LUA_FUNCTION handler = (  toluafix_ref_function(tolua_S,5,0));
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'selectImage'", NULL);
#endif
  {
   self->selectImage(path,width,height,handler);
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'selectImage'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: sendMail of class  Misc */
#ifndef TOLUA_DISABLE_tolua_Extension_Misc_sendMail00
static int tolua_Extension_Misc_sendMail00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"Misc",0,&tolua_err) ||
     !tolua_isstring(tolua_S,2,0,&tolua_err) ||
     !tolua_isstring(tolua_S,3,0,&tolua_err) ||
     !tolua_isstring(tolua_S,4,0,&tolua_err) ||
     (tolua_isvaluenil(tolua_S,5,&tolua_err) || !toluafix_isfunction(tolua_S,5,"LUA_FUNCTION",0,&tolua_err)) ||
     !tolua_isnoobj(tolua_S,6,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  Misc* self = (Misc*)  tolua_tousertype(tolua_S,1,0);
  char* receiver = ((char*)  tolua_tostring(tolua_S,2,0));
  char* subject = ((char*)  tolua_tostring(tolua_S,3,0));
  char* body = ((char*)  tolua_tostring(tolua_S,4,0));
  LUA_FUNCTION errorHandler = (  toluafix_ref_function(tolua_S,5,0));
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'sendMail'", NULL);
#endif
  {
   self->sendMail(receiver,subject,body,errorHandler);
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'sendMail'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: setFileToRequestData of class  Misc */
#ifndef TOLUA_DISABLE_tolua_Extension_Misc_setFileToRequestData00
static int tolua_Extension_Misc_setFileToRequestData00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"Misc",0,&tolua_err) ||
     !tolua_isusertype(tolua_S,2,"HttpRequestForLua",0,&tolua_err) ||
     !tolua_isstring(tolua_S,3,0,&tolua_err) ||
     !tolua_isstring(tolua_S,4,0,&tolua_err) ||
     !tolua_isstring(tolua_S,5,0,&tolua_err) ||
     !tolua_isstring(tolua_S,6,0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,7,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  Misc* self = (Misc*)  tolua_tousertype(tolua_S,1,0);
  HttpRequestForLua* request = ((HttpRequestForLua*)  tolua_tousertype(tolua_S,2,0));
  const char* begin = ((const char*)  tolua_tostring(tolua_S,3,0));
  const char* end = ((const char*)  tolua_tostring(tolua_S,4,0));
  const char* filePath = ((const char*)  tolua_tostring(tolua_S,5,0));
  const char* pszMode = ((const char*)  tolua_tostring(tolua_S,6,0));
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'setFileToRequestData'", NULL);
#endif
  {
   self->setFileToRequestData(request,begin,end,filePath,pszMode);
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'setFileToRequestData'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: sendSMS of class  Misc */
#ifndef TOLUA_DISABLE_tolua_Extension_Misc_sendSMS00
static int tolua_Extension_Misc_sendSMS00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"Misc",0,&tolua_err) ||
     !tolua_isstring(tolua_S,2,0,&tolua_err) ||
     (tolua_isvaluenil(tolua_S,3,&tolua_err) || !toluafix_isfunction(tolua_S,3,"LUA_FUNCTION",0,&tolua_err)) ||
     !tolua_isnoobj(tolua_S,4,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  Misc* self = (Misc*)  tolua_tousertype(tolua_S,1,0);
  char* body = ((char*)  tolua_tostring(tolua_S,2,0));
  LUA_FUNCTION errorHandler = (  toluafix_ref_function(tolua_S,3,0));
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'sendSMS'", NULL);
#endif
  {
   self->sendSMS(body,errorHandler);
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'sendSMS'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: getDeepLink of class  Misc */
#ifndef TOLUA_DISABLE_tolua_Extension_Misc_getDeepLink00
static int tolua_Extension_Misc_getDeepLink00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"Misc",0,&tolua_err) ||
     (tolua_isvaluenil(tolua_S,2,&tolua_err) || !toluafix_isfunction(tolua_S,2,"LUA_FUNCTION",0,&tolua_err)) ||
     !tolua_isnoobj(tolua_S,3,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  Misc* self = (Misc*)  tolua_tousertype(tolua_S,1,0);
  LUA_FUNCTION handler = (  toluafix_ref_function(tolua_S,2,0));
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'getDeepLink'", NULL);
#endif
  {
   self->getDeepLink(handler);
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'getDeepLink'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: addEventListenerDeepLink of class  Misc */
#ifndef TOLUA_DISABLE_tolua_Extension_Misc_addEventListenerDeepLink00
static int tolua_Extension_Misc_addEventListenerDeepLink00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"Misc",0,&tolua_err) ||
     (tolua_isvaluenil(tolua_S,2,&tolua_err) || !toluafix_isfunction(tolua_S,2,"LUA_FUNCTION",0,&tolua_err)) ||
     !tolua_isnoobj(tolua_S,3,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  Misc* self = (Misc*)  tolua_tousertype(tolua_S,1,0);
  LUA_FUNCTION handler = (  toluafix_ref_function(tolua_S,2,0));
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'addEventListenerDeepLink'", NULL);
#endif
  {
   self->addEventListenerDeepLink(handler);
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'addEventListenerDeepLink'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: getUADeviceToken of class  Misc */
#ifndef TOLUA_DISABLE_tolua_Extension_Misc_getUADeviceToken00
static int tolua_Extension_Misc_getUADeviceToken00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"Misc",0,&tolua_err) ||
     (tolua_isvaluenil(tolua_S,2,&tolua_err) || !toluafix_isfunction(tolua_S,2,"LUA_FUNCTION",0,&tolua_err)) ||
     !tolua_isnoobj(tolua_S,3,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  Misc* self = (Misc*)  tolua_tousertype(tolua_S,1,0);
  LUA_FUNCTION handler = (  toluafix_ref_function(tolua_S,2,0));
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'getUADeviceToken'", NULL);
#endif
  {
   self->getUADeviceToken(handler);
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'getUADeviceToken'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: setUADeviceTokenHandler of class  Misc */
#ifndef TOLUA_DISABLE_tolua_Extension_Misc_setUADeviceTokenHandler00
static int tolua_Extension_Misc_setUADeviceTokenHandler00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"Misc",0,&tolua_err) ||
     (tolua_isvaluenil(tolua_S,2,&tolua_err) || !toluafix_isfunction(tolua_S,2,"LUA_FUNCTION",0,&tolua_err)) ||
     !tolua_isnoobj(tolua_S,3,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  Misc* self = (Misc*)  tolua_tousertype(tolua_S,1,0);
  LUA_FUNCTION handler = (  toluafix_ref_function(tolua_S,2,0));
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'setUADeviceTokenHandler'", NULL);
#endif
  {
   self->setUADeviceTokenHandler(handler);
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'setUADeviceTokenHandler'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: requestPushNotification of class  Misc */
#ifndef TOLUA_DISABLE_tolua_Extension_Misc_requestPushNotification00
static int tolua_Extension_Misc_requestPushNotification00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"Misc",0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  Misc* self = (Misc*)  tolua_tousertype(tolua_S,1,0);
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'requestPushNotification'", NULL);
#endif
  {
   self->requestPushNotification();
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'requestPushNotification'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: openUrl of class  Misc */
#ifndef TOLUA_DISABLE_tolua_Extension_Misc_openUrl00
static int tolua_Extension_Misc_openUrl00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"Misc",0,&tolua_err) ||
     !tolua_isstring(tolua_S,2,0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,3,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  Misc* self = (Misc*)  tolua_tousertype(tolua_S,1,0);
  char* url = ((char*)  tolua_tostring(tolua_S,2,0));
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'openUrl'", NULL);
#endif
  {
   self->openUrl(url);
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'openUrl'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: openRate of class  Misc */
#ifndef TOLUA_DISABLE_tolua_Extension_Misc_openRate00
static int tolua_Extension_Misc_openRate00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"Misc",0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  Misc* self = (Misc*)  tolua_tousertype(tolua_S,1,0);
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'openRate'", NULL);
#endif
  {
   self->openRate();
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'openRate'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: terminate of class  Misc */
#ifndef TOLUA_DISABLE_tolua_Extension_Misc_terminate00
static int tolua_Extension_Misc_terminate00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"Misc",0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  Misc* self = (Misc*)  tolua_tousertype(tolua_S,1,0);
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'terminate'", NULL);
#endif
  {
   self->terminate();
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'terminate'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: sharedDelegate of class  QuickBloxChat */
#ifndef TOLUA_DISABLE_tolua_Extension_QuickBloxChat_sharedDelegate00
static int tolua_Extension_QuickBloxChat_sharedDelegate00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertable(tolua_S,1,"QuickBloxChat",0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  {
   QuickBloxChat* tolua_ret = (QuickBloxChat*)  QuickBloxChat::sharedDelegate();
    tolua_pushusertype(tolua_S,(void*)tolua_ret,"QuickBloxChat");
  }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'sharedDelegate'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: login of class  QuickBloxChat */
#ifndef TOLUA_DISABLE_tolua_Extension_QuickBloxChat_login00
static int tolua_Extension_QuickBloxChat_login00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"QuickBloxChat",0,&tolua_err) ||
     !tolua_isstring(tolua_S,2,0,&tolua_err) ||
     !tolua_isstring(tolua_S,3,0,&tolua_err) ||
     !tolua_isnumber(tolua_S,4,0,&tolua_err) ||
     (tolua_isvaluenil(tolua_S,5,&tolua_err) || !toluafix_isfunction(tolua_S,5,"LUA_FUNCTION",0,&tolua_err)) ||
     !tolua_isnoobj(tolua_S,6,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  QuickBloxChat* self = (QuickBloxChat*)  tolua_tousertype(tolua_S,1,0);
  const char* username = ((const char*)  tolua_tostring(tolua_S,2,0));
  const char* profileImg = ((const char*)  tolua_tostring(tolua_S,3,0));
  int userId = ((int)  tolua_tonumber(tolua_S,4,0));
  LUA_FUNCTION handler = (  toluafix_ref_function(tolua_S,5,0));
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'login'", NULL);
#endif
  {
   self->login(username,profileImg,userId,handler);
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'login'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: logout of class  QuickBloxChat */
#ifndef TOLUA_DISABLE_tolua_Extension_QuickBloxChat_logout00
static int tolua_Extension_QuickBloxChat_logout00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"QuickBloxChat",0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  QuickBloxChat* self = (QuickBloxChat*)  tolua_tousertype(tolua_S,1,0);
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'logout'", NULL);
#endif
  {
   self->logout();
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'logout'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: joinChatRoom of class  QuickBloxChat */
#ifndef TOLUA_DISABLE_tolua_Extension_QuickBloxChat_joinChatRoom00
static int tolua_Extension_QuickBloxChat_joinChatRoom00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"QuickBloxChat",0,&tolua_err) ||
     !tolua_isstring(tolua_S,2,0,&tolua_err) ||
     (tolua_isvaluenil(tolua_S,3,&tolua_err) || !toluafix_isfunction(tolua_S,3,"LUA_FUNCTION",0,&tolua_err)) ||
     !tolua_isnoobj(tolua_S,4,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  QuickBloxChat* self = (QuickBloxChat*)  tolua_tousertype(tolua_S,1,0);
  const char* jid = ((const char*)  tolua_tostring(tolua_S,2,0));
  LUA_FUNCTION handler = (  toluafix_ref_function(tolua_S,3,0));
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'joinChatRoom'", NULL);
#endif
  {
   self->joinChatRoom(jid,handler);
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'joinChatRoom'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: leaveChatRoom of class  QuickBloxChat */
#ifndef TOLUA_DISABLE_tolua_Extension_QuickBloxChat_leaveChatRoom00
static int tolua_Extension_QuickBloxChat_leaveChatRoom00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"QuickBloxChat",0,&tolua_err) ||
     (tolua_isvaluenil(tolua_S,2,&tolua_err) || !toluafix_isfunction(tolua_S,2,"LUA_FUNCTION",0,&tolua_err)) ||
     !tolua_isnoobj(tolua_S,3,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  QuickBloxChat* self = (QuickBloxChat*)  tolua_tousertype(tolua_S,1,0);
  LUA_FUNCTION handler = (  toluafix_ref_function(tolua_S,2,0));
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'leaveChatRoom'", NULL);
#endif
  {
   self->leaveChatRoom(handler);
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'leaveChatRoom'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: sendMessage of class  QuickBloxChat */
#ifndef TOLUA_DISABLE_tolua_Extension_QuickBloxChat_sendMessage00
static int tolua_Extension_QuickBloxChat_sendMessage00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"QuickBloxChat",0,&tolua_err) ||
     !tolua_isstring(tolua_S,2,0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,3,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  QuickBloxChat* self = (QuickBloxChat*)  tolua_tousertype(tolua_S,1,0);
  const char* message = ((const char*)  tolua_tostring(tolua_S,2,0));
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'sendMessage'", NULL);
#endif
  {
   self->sendMessage(message);
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'sendMessage'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: setNewMessageHandler of class  QuickBloxChat */
#ifndef TOLUA_DISABLE_tolua_Extension_QuickBloxChat_setNewMessageHandler00
static int tolua_Extension_QuickBloxChat_setNewMessageHandler00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"QuickBloxChat",0,&tolua_err) ||
     (tolua_isvaluenil(tolua_S,2,&tolua_err) || !toluafix_isfunction(tolua_S,2,"LUA_FUNCTION",0,&tolua_err)) ||
     !tolua_isnoobj(tolua_S,3,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  QuickBloxChat* self = (QuickBloxChat*)  tolua_tousertype(tolua_S,1,0);
  LUA_FUNCTION handler = (  toluafix_ref_function(tolua_S,2,0));
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'setNewMessageHandler'", NULL);
#endif
  {
   self->setNewMessageHandler(handler);
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'setNewMessageHandler'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: authorize of class  C2DXShareSDK */
#ifndef TOLUA_DISABLE_tolua_Extension_C2DXShareSDK_authorize00
static int tolua_Extension_C2DXShareSDK_authorize00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertable(tolua_S,1,"C2DXShareSDK",0,&tolua_err) ||
     !tolua_isnumber(tolua_S,2,0,&tolua_err) ||
     (tolua_isvaluenil(tolua_S,3,&tolua_err) || !toluafix_isfunction(tolua_S,3,"LUA_FUNCTION",0,&tolua_err)) ||
     !tolua_isnoobj(tolua_S,4,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  C2DXPlatType platType = ((C2DXPlatType) (int)  tolua_tonumber(tolua_S,2,0));
  LUA_FUNCTION handler = (  toluafix_ref_function(tolua_S,3,0));
  {
   C2DXShareSDK::authorize(platType,handler);
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'authorize'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: cancelAuthorize of class  C2DXShareSDK */
#ifndef TOLUA_DISABLE_tolua_Extension_C2DXShareSDK_cancelAuthorize00
static int tolua_Extension_C2DXShareSDK_cancelAuthorize00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertable(tolua_S,1,"C2DXShareSDK",0,&tolua_err) ||
     !tolua_isnumber(tolua_S,2,0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,3,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  C2DXPlatType platType = ((C2DXPlatType) (int)  tolua_tonumber(tolua_S,2,0));
  {
   C2DXShareSDK::cancelAuthorize(platType);
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'cancelAuthorize'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: hasAutorized of class  C2DXShareSDK */
#ifndef TOLUA_DISABLE_tolua_Extension_C2DXShareSDK_hasAutorized00
static int tolua_Extension_C2DXShareSDK_hasAutorized00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertable(tolua_S,1,"C2DXShareSDK",0,&tolua_err) ||
     !tolua_isnumber(tolua_S,2,0,&tolua_err) ||
     (tolua_isvaluenil(tolua_S,3,&tolua_err) || !toluafix_isfunction(tolua_S,3,"LUA_FUNCTION",0,&tolua_err)) ||
     !tolua_isnoobj(tolua_S,4,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  C2DXPlatType platType = ((C2DXPlatType) (int)  tolua_tonumber(tolua_S,2,0));
  LUA_FUNCTION handler = (  toluafix_ref_function(tolua_S,3,0));
  {
   bool tolua_ret = (bool)  C2DXShareSDK::hasAutorized(platType,handler);
   tolua_pushboolean(tolua_S,(bool)tolua_ret);
  }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'hasAutorized'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: showShareMenu of class  C2DXShareSDK */
#ifndef TOLUA_DISABLE_tolua_Extension_C2DXShareSDK_showShareMenu00
static int tolua_Extension_C2DXShareSDK_showShareMenu00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertable(tolua_S,1,"C2DXShareSDK",0,&tolua_err) ||
     !tolua_isusertype(tolua_S,2,"CCArray",0,&tolua_err) ||
     !tolua_isusertype(tolua_S,3,"CCDictionary",0,&tolua_err) ||
     (tolua_isvaluenil(tolua_S,4,&tolua_err) || !toluafix_isfunction(tolua_S,4,"LUA_FUNCTION",0,&tolua_err)) ||
     !tolua_isnoobj(tolua_S,5,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  CCArray* platTypes = ((CCArray*)  tolua_tousertype(tolua_S,2,0));
  CCDictionary* content = ((CCDictionary*)  tolua_tousertype(tolua_S,3,0));
  LUA_FUNCTION handler = (  toluafix_ref_function(tolua_S,4,0));
  {
   C2DXShareSDK::showShareMenu(platTypes,content,handler);
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'showShareMenu'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: getCredentialWithType of class  C2DXShareSDK */
#ifndef TOLUA_DISABLE_tolua_Extension_C2DXShareSDK_getCredentialWithType00
static int tolua_Extension_C2DXShareSDK_getCredentialWithType00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertable(tolua_S,1,"C2DXShareSDK",0,&tolua_err) ||
     !tolua_isnumber(tolua_S,2,0,&tolua_err) ||
     (tolua_isvaluenil(tolua_S,3,&tolua_err) || !toluafix_isfunction(tolua_S,3,"LUA_FUNCTION",0,&tolua_err)) ||
     !tolua_isnoobj(tolua_S,4,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  C2DXPlatType platType = ((C2DXPlatType) (int)  tolua_tonumber(tolua_S,2,0));
  LUA_FUNCTION handler = (  toluafix_ref_function(tolua_S,3,0));
  {
   C2DXShareSDK::getCredentialWithType(platType,handler);
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'getCredentialWithType'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* Open function */
TOLUA_API int tolua_Extension_open (lua_State* tolua_S)
{
 tolua_open(tolua_S);
 tolua_reg_types(tolua_S);
 tolua_module(tolua_S,NULL,0);
 tolua_beginmodule(tolua_S,NULL);
  tolua_cclass(tolua_S,"FacebookDelegate","FacebookDelegate","",NULL);
  tolua_beginmodule(tolua_S,"FacebookDelegate");
   tolua_function(tolua_S,"sharedDelegate",tolua_Extension_FacebookDelegate_sharedDelegate00);
   tolua_function(tolua_S,"login",tolua_Extension_FacebookDelegate_login00);
   tolua_function(tolua_S,"grantPublishPermission",tolua_Extension_FacebookDelegate_grantPublishPermission00);
  tolua_endmodule(tolua_S);
  tolua_cclass(tolua_S,"CCHttpRequest","CCHttpRequest","CCObject",NULL);
  tolua_beginmodule(tolua_S,"CCHttpRequest");
   tolua_constant(tolua_S,"kHttpGet",CCHttpRequest::kHttpGet);
   tolua_constant(tolua_S,"kHttpPost",CCHttpRequest::kHttpPost);
   tolua_constant(tolua_S,"kHttpPut",CCHttpRequest::kHttpPut);
   tolua_constant(tolua_S,"kHttpDelete",CCHttpRequest::kHttpDelete);
   tolua_constant(tolua_S,"kHttpUnkown",CCHttpRequest::kHttpUnkown);
   tolua_constant(tolua_S,"pVeryLow",CCHttpRequest::pVeryLow);
   tolua_constant(tolua_S,"pLow",CCHttpRequest::pLow);
   tolua_constant(tolua_S,"pMedium",CCHttpRequest::pMedium);
   tolua_constant(tolua_S,"pHigh",CCHttpRequest::pHigh);
   tolua_constant(tolua_S,"pVeryHigh",CCHttpRequest::pVeryHigh);
   tolua_function(tolua_S,"setRequestType",tolua_Extension_CCHttpRequest_setRequestType00);
   tolua_function(tolua_S,"getRequestType",tolua_Extension_CCHttpRequest_getRequestType00);
   tolua_function(tolua_S,"setUrl",tolua_Extension_CCHttpRequest_setUrl00);
   tolua_function(tolua_S,"getUrl",tolua_Extension_CCHttpRequest_getUrl00);
   tolua_function(tolua_S,"setRequestData",tolua_Extension_CCHttpRequest_setRequestData00);
   tolua_function(tolua_S,"getRequestData",tolua_Extension_CCHttpRequest_getRequestData00);
   tolua_function(tolua_S,"getRequestDataSize",tolua_Extension_CCHttpRequest_getRequestDataSize00);
   tolua_function(tolua_S,"setTag",tolua_Extension_CCHttpRequest_setTag00);
   tolua_function(tolua_S,"getTag",tolua_Extension_CCHttpRequest_getTag00);
  tolua_endmodule(tolua_S);
  tolua_cclass(tolua_S,"HttpRequestForLua","HttpRequestForLua","CCObject",NULL);
  tolua_beginmodule(tolua_S,"HttpRequestForLua");
   tolua_function(tolua_S,"create",tolua_Extension_HttpRequestForLua_create00);
   tolua_function(tolua_S,"addHeader",tolua_Extension_HttpRequestForLua_addHeader00);
   tolua_function(tolua_S,"setUserpwd",tolua_Extension_HttpRequestForLua_setUserpwd00);
   tolua_function(tolua_S,"setPriority",tolua_Extension_HttpRequestForLua_setPriority00);
   tolua_function(tolua_S,"sendHttpRequest",tolua_Extension_HttpRequestForLua_sendHttpRequest00);
   tolua_function(tolua_S,"onHttpRequestCompleted",tolua_Extension_HttpRequestForLua_onHttpRequestCompleted00);
   tolua_function(tolua_S,"setRequest",tolua_Extension_HttpRequestForLua_setRequest00);
   tolua_function(tolua_S,"getRequest",tolua_Extension_HttpRequestForLua_getRequest00);
  tolua_endmodule(tolua_S);
  tolua_constant(tolua_S,"EDIT_BOX_EVENT_DID_BEGIN",EDIT_BOX_EVENT_DID_BEGIN);
  tolua_constant(tolua_S,"EDIT_BOX_EVENT_DID_END",EDIT_BOX_EVENT_DID_END);
  tolua_constant(tolua_S,"EDIT_BOX_EVENT_TEXT_CHANGED",EDIT_BOX_EVENT_TEXT_CHANGED);
  tolua_constant(tolua_S,"EDIT_BOX_EVENT_RETURN",EDIT_BOX_EVENT_RETURN);
  tolua_constant(tolua_S,"EDIT_BOX_EVENT_MAX",EDIT_BOX_EVENT_MAX);
  tolua_cclass(tolua_S,"CCEditBoxDelegate","CCEditBoxDelegate","",NULL);
  tolua_beginmodule(tolua_S,"CCEditBoxDelegate");
  tolua_endmodule(tolua_S);
  tolua_cclass(tolua_S,"EditBoxDelegateForLua","EditBoxDelegateForLua","CCLayer",NULL);
  tolua_beginmodule(tolua_S,"EditBoxDelegateForLua");
   tolua_function(tolua_S,"create",tolua_Extension_EditBoxDelegateForLua_create00);
   tolua_function(tolua_S,"registerEventScriptHandler",tolua_Extension_EditBoxDelegateForLua_registerEventScriptHandler00);
   tolua_function(tolua_S,"unregisterEventScriptHandler",tolua_Extension_EditBoxDelegateForLua_unregisterEventScriptHandler00);
   tolua_variable(tolua_S,"__CCEditBoxDelegate__",tolua_get_EditBoxDelegateForLua___CCEditBoxDelegate__,NULL);
  tolua_endmodule(tolua_S);
  tolua_cclass(tolua_S,"Analytics","Analytics","",NULL);
  tolua_beginmodule(tolua_S,"Analytics");
   tolua_function(tolua_S,"sharedDelegate",tolua_Extension_Analytics_sharedDelegate00);
   tolua_function(tolua_S,"postEvent",tolua_Extension_Analytics_postEvent00);
  tolua_endmodule(tolua_S);
  tolua_cclass(tolua_S,"WebviewDelegate","WebviewDelegate","",NULL);
  tolua_beginmodule(tolua_S,"WebviewDelegate");
   tolua_function(tolua_S,"sharedDelegate",tolua_Extension_WebviewDelegate_sharedDelegate00);
   tolua_function(tolua_S,"openWebpage",tolua_Extension_WebviewDelegate_openWebpage00);
   tolua_function(tolua_S,"closeWebpage",tolua_Extension_WebviewDelegate_closeWebpage00);
  tolua_endmodule(tolua_S);
  tolua_cclass(tolua_S,"Misc","Misc","",NULL);
  tolua_beginmodule(tolua_S,"Misc");
   tolua_function(tolua_S,"sharedDelegate",tolua_Extension_Misc_sharedDelegate00);
   tolua_function(tolua_S,"copyToPasteboard",tolua_Extension_Misc_copyToPasteboard00);
   tolua_function(tolua_S,"selectImage",tolua_Extension_Misc_selectImage00);
   tolua_function(tolua_S,"sendMail",tolua_Extension_Misc_sendMail00);
   tolua_function(tolua_S,"setFileToRequestData",tolua_Extension_Misc_setFileToRequestData00);
   tolua_function(tolua_S,"sendSMS",tolua_Extension_Misc_sendSMS00);
   tolua_function(tolua_S,"getDeepLink",tolua_Extension_Misc_getDeepLink00);
   tolua_function(tolua_S,"addEventListenerDeepLink",tolua_Extension_Misc_addEventListenerDeepLink00);
   tolua_function(tolua_S,"getUADeviceToken",tolua_Extension_Misc_getUADeviceToken00);
   tolua_function(tolua_S,"setUADeviceTokenHandler",tolua_Extension_Misc_setUADeviceTokenHandler00);
   tolua_function(tolua_S,"requestPushNotification",tolua_Extension_Misc_requestPushNotification00);
   tolua_function(tolua_S,"openUrl",tolua_Extension_Misc_openUrl00);
   tolua_function(tolua_S,"openRate",tolua_Extension_Misc_openRate00);
   tolua_function(tolua_S,"terminate",tolua_Extension_Misc_terminate00);
  tolua_endmodule(tolua_S);
  tolua_cclass(tolua_S,"QuickBloxChat","QuickBloxChat","",NULL);
  tolua_beginmodule(tolua_S,"QuickBloxChat");
   tolua_function(tolua_S,"sharedDelegate",tolua_Extension_QuickBloxChat_sharedDelegate00);
   tolua_function(tolua_S,"login",tolua_Extension_QuickBloxChat_login00);
   tolua_function(tolua_S,"logout",tolua_Extension_QuickBloxChat_logout00);
   tolua_function(tolua_S,"joinChatRoom",tolua_Extension_QuickBloxChat_joinChatRoom00);
   tolua_function(tolua_S,"leaveChatRoom",tolua_Extension_QuickBloxChat_leaveChatRoom00);
   tolua_function(tolua_S,"sendMessage",tolua_Extension_QuickBloxChat_sendMessage00);
   tolua_function(tolua_S,"setNewMessageHandler",tolua_Extension_QuickBloxChat_setNewMessageHandler00);
  tolua_endmodule(tolua_S);
  tolua_constant(tolua_S,"C2DXPlatTypeSinaWeibo",C2DXPlatTypeSinaWeibo);
  tolua_constant(tolua_S,"C2DXPlatTypeTencentWeibo",C2DXPlatTypeTencentWeibo);
  tolua_constant(tolua_S,"C2DXPlatTypeSohuWeibo",C2DXPlatTypeSohuWeibo);
  tolua_constant(tolua_S,"C2DXPlatTypeDouBan",C2DXPlatTypeDouBan);
  tolua_constant(tolua_S,"C2DXPlatTypeQZone",C2DXPlatTypeQZone);
  tolua_constant(tolua_S,"C2DXPlatTypeRenren",C2DXPlatTypeRenren);
  tolua_constant(tolua_S,"C2DXPlatTypeKaixin",C2DXPlatTypeKaixin);
  tolua_constant(tolua_S,"C2DXPlatTypePengyou",C2DXPlatTypePengyou);
  tolua_constant(tolua_S,"C2DXPlatTypeFacebook",C2DXPlatTypeFacebook);
  tolua_constant(tolua_S,"C2DXPlatTypeTwitter",C2DXPlatTypeTwitter);
  tolua_constant(tolua_S,"C2DXPlatTypeEvernote",C2DXPlatTypeEvernote);
  tolua_constant(tolua_S,"C2DXPlatTypeFoursquare",C2DXPlatTypeFoursquare);
  tolua_constant(tolua_S,"C2DXPlatTypeGooglePlus",C2DXPlatTypeGooglePlus);
  tolua_constant(tolua_S,"C2DXPlatTypeInstagram",C2DXPlatTypeInstagram);
  tolua_constant(tolua_S,"C2DXPlatTypeLinkedIn",C2DXPlatTypeLinkedIn);
  tolua_constant(tolua_S,"C2DXPlatTypeTumblr",C2DXPlatTypeTumblr);
  tolua_constant(tolua_S,"C2DXPlatTypeMail",C2DXPlatTypeMail);
  tolua_constant(tolua_S,"C2DXPlatTypeSMS",C2DXPlatTypeSMS);
  tolua_constant(tolua_S,"C2DXPlatTypeAirPrint",C2DXPlatTypeAirPrint);
  tolua_constant(tolua_S,"C2DXPlatTypeCopy",C2DXPlatTypeCopy);
  tolua_constant(tolua_S,"C2DXPlatTypeWeixiSession",C2DXPlatTypeWeixiSession);
  tolua_constant(tolua_S,"C2DXPlatTypeWeixiTimeline",C2DXPlatTypeWeixiTimeline);
  tolua_constant(tolua_S,"C2DXPlatTypeQQ",C2DXPlatTypeQQ);
  tolua_constant(tolua_S,"C2DXPlatTypeInstapaper",C2DXPlatTypeInstapaper);
  tolua_constant(tolua_S,"C2DXPlatTypePocket",C2DXPlatTypePocket);
  tolua_constant(tolua_S,"C2DXPlatTypeYouDaoNote",C2DXPlatTypeYouDaoNote);
  tolua_constant(tolua_S,"C2DXPlatTypeSohuKan",C2DXPlatTypeSohuKan);
  tolua_constant(tolua_S,"C2DXPlatTypePinterest",C2DXPlatTypePinterest);
  tolua_constant(tolua_S,"C2DXPlatTypeFlickr",C2DXPlatTypeFlickr);
  tolua_constant(tolua_S,"C2DXPlatTypeDropbox",C2DXPlatTypeDropbox);
  tolua_constant(tolua_S,"C2DXPlatTypeVKontakte",C2DXPlatTypeVKontakte);
  tolua_constant(tolua_S,"C2DXPlatTypeWeixiFav",C2DXPlatTypeWeixiFav);
  tolua_constant(tolua_S,"C2DXPlatTypeYiXinSession",C2DXPlatTypeYiXinSession);
  tolua_constant(tolua_S,"C2DXPlatTypeYiXinTimeline",C2DXPlatTypeYiXinTimeline);
  tolua_constant(tolua_S,"C2DXPlatTypeYiXinFav",C2DXPlatTypeYiXinFav);
  tolua_constant(tolua_S,"C2DXPlatTypeMingDao",C2DXPlatTypeMingDao);
  tolua_constant(tolua_S,"C2DXPlatTypeLine",C2DXPlatTypeLine);
  tolua_constant(tolua_S,"C2DXPlatTypeWhatsApp",C2DXPlatTypeWhatsApp);
  tolua_constant(tolua_S,"C2DXPlatTypeKaKaoTalk",C2DXPlatTypeKaKaoTalk);
  tolua_constant(tolua_S,"C2DXPlatTypeKaKaoStory",C2DXPlatTypeKaKaoStory);
  tolua_constant(tolua_S,"C2DXPlatTypeAny",C2DXPlatTypeAny);
  tolua_constant(tolua_S,"C2DXContentTypeText",C2DXContentTypeText);
  tolua_constant(tolua_S,"C2DXContentTypeImage",C2DXContentTypeImage);
  tolua_constant(tolua_S,"C2DXContentTypeNews",C2DXContentTypeNews);
  tolua_constant(tolua_S,"C2DXContentTypeMusic",C2DXContentTypeMusic);
  tolua_constant(tolua_S,"C2DXContentTypeVideo",C2DXContentTypeVideo);
  tolua_constant(tolua_S,"C2DXContentTypeApp",C2DXContentTypeApp);
  tolua_constant(tolua_S,"C2DXContentTypeNonGif",C2DXContentTypeNonGif);
  tolua_constant(tolua_S,"C2DXContentTypeGif",C2DXContentTypeGif);
  tolua_constant(tolua_S,"C2DXContentTypeFile",C2DXContentTypeFile);
  tolua_constant(tolua_S,"C2DXResponseStateBegin",C2DXResponseStateBegin);
  tolua_constant(tolua_S,"C2DXResponseStateSuccess",C2DXResponseStateSuccess);
  tolua_constant(tolua_S,"C2DXResponseStateFail",C2DXResponseStateFail);
  tolua_constant(tolua_S,"C2DXResponseStateCancel",C2DXResponseStateCancel);
  tolua_cclass(tolua_S,"C2DXShareSDK","C2DXShareSDK","",NULL);
  tolua_beginmodule(tolua_S,"C2DXShareSDK");
   tolua_function(tolua_S,"authorize",tolua_Extension_C2DXShareSDK_authorize00);
   tolua_function(tolua_S,"cancelAuthorize",tolua_Extension_C2DXShareSDK_cancelAuthorize00);
   tolua_function(tolua_S,"hasAutorized",tolua_Extension_C2DXShareSDK_hasAutorized00);
   tolua_function(tolua_S,"showShareMenu",tolua_Extension_C2DXShareSDK_showShareMenu00);
   tolua_function(tolua_S,"getCredentialWithType",tolua_Extension_C2DXShareSDK_getCredentialWithType00);
  tolua_endmodule(tolua_S);
 tolua_endmodule(tolua_S);
 return 1;
}


#if defined(LUA_VERSION_NUM) && LUA_VERSION_NUM >= 501
 TOLUA_API int luaopen_Extension (lua_State* tolua_S) {
 return tolua_Extension_open(tolua_S);
};
#endif

