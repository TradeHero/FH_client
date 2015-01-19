module(..., package.seeall)

Strings = {
}

require "DefaultString"

setmetatable( Strings, extendsStringDefault() )
for i = 1 , table.getn( StringDefaultSubTableList ) do
    local subTableTitle = StringDefaultSubTableList[i]
    if Strings[subTableTitle] then
        setmetatable( Strings[subTableTitle], extendsStringDefaultSubTable(subTableTitle) )  
    end
end

CCLuaLog("Load bahasa string.")