module(..., package.seeall)

function decode ( str )
  return cjson.decode( str )
end

function encode( obj )
  return cjson.encode( obj )
end