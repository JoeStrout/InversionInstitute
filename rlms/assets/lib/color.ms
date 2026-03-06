
clear = "#00000000"
black = "#000000"
white = "#FFFFFF"
gray = "#808080"
silver = "#C0C0C0"
maroon = "#800000"
red = "#FF0000"
olive = "#808000"
yellow = "#FFFF00"
orange = "#FF8000"
green = "#008000"
lime = "#00FF00"
teal = "#008080"
aqua = "#00FFFF"
navy = "#000080"
blue = "#0000FF"
purple = "#800080"
fuchsia = "#FF00FF"
brown = "#996633"
pink = "#FF8080"


// Convert a hex digit character to its numeric value (0-15).
hexDigitVal = function(c)
	code = c.code
	if code >= 48 and code <= 57 then return code - 48
	if code >= 65 and code <= 70 then return code - 55
	if code >= 97 and code <= 102 then return code - 87
	return 0
end function

// Convert a Mini Micro color string ("#RRGGBB" or "#RRGGBBAA")
// to a numeric [r, g, b, a] list.
toList = function(s)
	if s isa list then return s
	if not s isa string or s.len < 7 or s[0] != "#" then return [255, 255, 255, 255]
	r = hexDigitVal(s[1]) * 16 + hexDigitVal(s[2])
	g = hexDigitVal(s[3]) * 16 + hexDigitVal(s[4])
	b = hexDigitVal(s[5]) * 16 + hexDigitVal(s[6])
	if s.len >= 9 then
		a = hexDigitVal(s[7]) * 16 + hexDigitVal(s[8])
	else
		a = 255
	end if
	return [r, g, b, a]
end function

