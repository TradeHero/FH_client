module(..., package.seeall)

function sumhexa (k)
	k = crypt1.sum(k)
	return (string.gsub(k, ".", function (c)
    	return string.format("%02x", string.byte(c))
    end))
end
