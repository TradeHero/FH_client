module(..., package.seeall)

function crypt ( str, key )
	return crypt2.crypt( str, key )
end

function decrypt( str, key )
	return crypt2.decrypt( str, key )
end