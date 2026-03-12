pressed = function(keyName)
	return raylib.IsKeyDown(keyName)	// ToDo: properly convert from key name to int code
end function

keyQueue = []

available = function
	if keyQueue then return true
	nextCharCode = raylib.GetCharPressed
	if nextCharCode == 0 then return false
	keyQueue.push char(nextCharCode)
	return true
end function

get = function
	if keyQueue then return keyQueue.pull
	while true
		result = raylib.GetCharPressed
		if result then return char(result)
		yield	// ToDo: how to keep rendering while we wait?
	end while
end function

