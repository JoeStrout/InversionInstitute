// Map of Soda key names to Raylib key constants
_nameToRaylib = {}
_nameToRaylib["a"] = raylib.KEY_A
_nameToRaylib["b"] = raylib.KEY_B
_nameToRaylib["c"] = raylib.KEY_C
_nameToRaylib["d"] = raylib.KEY_D
_nameToRaylib["e"] = raylib.KEY_E
_nameToRaylib["f"] = raylib.KEY_F
_nameToRaylib["g"] = raylib.KEY_G
_nameToRaylib["h"] = raylib.KEY_H
_nameToRaylib["i"] = raylib.KEY_I
_nameToRaylib["j"] = raylib.KEY_J
_nameToRaylib["k"] = raylib.KEY_K
_nameToRaylib["l"] = raylib.KEY_L
_nameToRaylib["m"] = raylib.KEY_M
_nameToRaylib["n"] = raylib.KEY_N
_nameToRaylib["o"] = raylib.KEY_O
_nameToRaylib["p"] = raylib.KEY_P
_nameToRaylib["q"] = raylib.KEY_Q
_nameToRaylib["r"] = raylib.KEY_R
_nameToRaylib["s"] = raylib.KEY_S
_nameToRaylib["t"] = raylib.KEY_T
_nameToRaylib["u"] = raylib.KEY_U
_nameToRaylib["v"] = raylib.KEY_V
_nameToRaylib["w"] = raylib.KEY_W
_nameToRaylib["x"] = raylib.KEY_X
_nameToRaylib["y"] = raylib.KEY_Y
_nameToRaylib["z"] = raylib.KEY_Z
_nameToRaylib["0"] = raylib.KEY_ZERO
_nameToRaylib["1"] = raylib.KEY_ONE
_nameToRaylib["2"] = raylib.KEY_TWO
_nameToRaylib["3"] = raylib.KEY_THREE
_nameToRaylib["4"] = raylib.KEY_FOUR
_nameToRaylib["5"] = raylib.KEY_FIVE
_nameToRaylib["6"] = raylib.KEY_SIX
_nameToRaylib["7"] = raylib.KEY_SEVEN
_nameToRaylib["8"] = raylib.KEY_EIGHT
_nameToRaylib["9"] = raylib.KEY_NINE
_nameToRaylib["-"] = raylib.KEY_MINUS
_nameToRaylib["="] = raylib.KEY_EQUAL
_nameToRaylib["["] = raylib.KEY_LEFT_BRACKET
_nameToRaylib["]"] = raylib.KEY_RIGHT_BRACKET
_nameToRaylib["\"] = raylib.KEY_BACKSLASH
_nameToRaylib[","] = raylib.KEY_COMMA
_nameToRaylib["."] = raylib.KEY_PERIOD
_nameToRaylib["/"] = raylib.KEY_SLASH
_nameToRaylib[";"] = raylib.KEY_SEMICOLON
_nameToRaylib["'"] = raylib.KEY_APOSTROPHE
_nameToRaylib["`"] = raylib.KEY_GRAVE
_nameToRaylib["f1"] = raylib.KEY_F1
_nameToRaylib["f2"] = raylib.KEY_F2
_nameToRaylib["f3"] = raylib.KEY_F3
_nameToRaylib["f4"] = raylib.KEY_F4
_nameToRaylib["f5"] = raylib.KEY_F5
_nameToRaylib["f6"] = raylib.KEY_F6
_nameToRaylib["f7"] = raylib.KEY_F7
_nameToRaylib["f8"] = raylib.KEY_F8
_nameToRaylib["f9"] = raylib.KEY_F9
_nameToRaylib["f10"] = raylib.KEY_F10
_nameToRaylib["f11"] = raylib.KEY_F11
_nameToRaylib["f12"] = raylib.KEY_F12
// f13-f15 have no Raylib equivalent; omitted
_nameToRaylib["up"] = raylib.KEY_UP
_nameToRaylib["down"] = raylib.KEY_DOWN
_nameToRaylib["left"] = raylib.KEY_LEFT
_nameToRaylib["right"] = raylib.KEY_RIGHT
_nameToRaylib["[0]"] = raylib.KEY_KP_0
_nameToRaylib["[1]"] = raylib.KEY_KP_1
_nameToRaylib["[2]"] = raylib.KEY_KP_2
_nameToRaylib["[3]"] = raylib.KEY_KP_3
_nameToRaylib["[4]"] = raylib.KEY_KP_4
_nameToRaylib["[5]"] = raylib.KEY_KP_5
_nameToRaylib["[6]"] = raylib.KEY_KP_6
_nameToRaylib["[7]"] = raylib.KEY_KP_7
_nameToRaylib["[8]"] = raylib.KEY_KP_8
_nameToRaylib["[9]"] = raylib.KEY_KP_9
_nameToRaylib["[+]"] = raylib.KEY_KP_ADD
_nameToRaylib["[-]"] = raylib.KEY_KP_SUBTRACT
_nameToRaylib["[*]"] = raylib.KEY_KP_MULTIPLY
_nameToRaylib["[/]"] = raylib.KEY_KP_DIVIDE
_nameToRaylib["enter"] = raylib.KEY_KP_ENTER
_nameToRaylib["equals"] = raylib.KEY_KP_EQUAL
_nameToRaylib["clear"] = raylib.KEY_NUM_LOCK
_nameToRaylib["left shift"] = raylib.KEY_LEFT_SHIFT
_nameToRaylib["right shift"] = raylib.KEY_RIGHT_SHIFT
_nameToRaylib["left ctrl"] = raylib.KEY_LEFT_CONTROL
_nameToRaylib["right ctrl"] = raylib.KEY_RIGHT_CONTROL
_nameToRaylib["left alt"] = raylib.KEY_LEFT_ALT
_nameToRaylib["right alt"] = raylib.KEY_RIGHT_ALT
_nameToRaylib["left cmd"] = raylib.KEY_LEFT_SUPER
_nameToRaylib["right cmd"] = raylib.KEY_RIGHT_SUPER
_nameToRaylib["backspace"] = raylib.KEY_BACKSPACE
_nameToRaylib["tab"] = raylib.KEY_TAB
_nameToRaylib["return"] = raylib.KEY_ENTER
_nameToRaylib["escape"] = raylib.KEY_ESCAPE
_nameToRaylib["space"] = raylib.KEY_SPACE
_nameToRaylib["delete"] = raylib.KEY_DELETE
_nameToRaylib["insert"] = raylib.KEY_INSERT
_nameToRaylib["home"] = raylib.KEY_HOME
_nameToRaylib["end"] = raylib.KEY_END
_nameToRaylib["page up"] = raylib.KEY_PAGE_UP
_nameToRaylib["page down"] = raylib.KEY_PAGE_DOWN


pressed = function(keyName)
	if keyName[:6] == "mouse " and keyName.len >= 7 then
		// Special case: mouse buttons
		btnNum = val(keyName[7])
		return raylib.IsMouseButtonDown(btnNum)
	end if
	if not _nameToRaylib.hasIndex(keyName) then
		print "Invalid key name in key.pressed: " + keyName
		print "Valid names: " + _nameToRaylib.indexes
		print stackTrace
		exit
	end if
	return raylib.IsKeyDown(_nameToRaylib[keyName])
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

clear = function
	outer.keyQueue = []
end function

axis = function(axisName="Horizontal", smoothed=1)
	if axisName == "Mouse ScrollWheel" then
		return raylib.GetMouseWheelMove
	else
		print "key.axis: unsupported axis name " + axisName
	end if
end function 

// Special keys that don't normally generate characters in Raylib,
// and the character codes we want them to generate in Soda:
_extraKeys = {}
_extraKeys[raylib.KEY_TAB] = 9
_extraKeys[raylib.KEY_BACKSPACE] = 8
_extraKeys[raylib.KEY_DELETE] = 127
_extraKeys[raylib.KEY_LEFT] = 17
_extraKeys[raylib.KEY_RIGHT] = 18
_extraKeys[raylib.KEY_UP] = 19
_extraKeys[raylib.KEY_DOWN] = 20
_extraKeys[raylib.KEY_HOME] = 1
_extraKeys[raylib.KEY_END] = 5
_extraKeys[raylib.KEY_ESCAPE] = 27


// In order to make all keys work properly, including ones that Raylib
// doesn't return from GetCharPressed, call this on every frame:
update = function
	for kcode in _extraKeys.indexes
		if raylib.IsKeyPressed(kcode) then keyQueue.push char(_extraKeys[kcode])
	end for
end function
