module(..., package.seeall)

Strings = {
  -- The default langueage should contains nothing.
}

require "DefaultString"
setmetatable( Strings, extendsStringDefault() )
CCLuaLog("Load ar string.")