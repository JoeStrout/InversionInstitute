// This module provides utilities related to the "Objectives"
// area in the editor.  That includes both drawing them, and
// detecting when they are met (so we can check them off as
// they are achieved).

import "miscUtil"
ensureImport "rect"
ensureImport "drawing"

area = Rect.make(750,10, 208,390)
bigFont = bmfFonts.Font.load("/usr/fonts/minimicro-pro-16.bmf")
smallFont = bmfFonts.Font.load("/usr/fonts/minimicro-pro-12.bmf")
bgColor = color.gray
textColor = color.silver

cursorX = area.left + 4
cursorY = area.top + 20

erase = function(drawTitle = true)
	area.fill gfx, bgColor
	y = area.top + bigFont.sizeOver - bigFont.sizeUnder
	gfx.line area.left, y, area.right, y, color.silver
	y = area.top + bigFont.sizeOver
	bigFont.printCentered "Objectives", area.midX, y
	outer.cursorX = area.left + 4
	outer.cursorY = y - 30
end function

print = function(s, color=null)
	if color == null then color = textColor
	outer.cursorY = smallFont.printWrapped(s, cursorX, cursorY, area.width - 8, color)
end function

printErr = function(s)
	print s, "#AA0000"
end function

printSuccess = function(s)
	print s, "#00FF00"
end function

if locals == globals then
	clear
	gfx.clear color.gray, 960+10, 640+10
	gfx.scrollX = 5; gfx.scrollY = 5
	erase
	print "Here is where objectives will be shown."
	print
	print "Maybe including a checkbox or two."
end if
