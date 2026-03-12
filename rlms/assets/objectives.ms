// This module provides utilities related to the "Objectives"
// area in the editor.  That includes both drawing them, and
// detecting when they are met (so we can check them off as
// they are achieved).

import "miscUtil"
ensureImport "rect"
ensureImport "drawing"

area = Rect.Make(750,10, 208,390)
bigFont = ttFonts.TTFont.Load("fonts/EBGaramond-Bold.ttf", 30)
smallFont = smallPrinter.boldFont
bgColor = "#666666"
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
	outer.cursorY = smallFont.printWrapped(s, cursorX, cursorY, area.width - 12, color)
end function

printErr = function(s)
	print s, "#AA0000"
end function

printSuccess = function(s)
	print s, "#00FF00"
end function

if locals == globals then
	import "soda"
	clear
	gfx.clear color.black, 960+10, 640+10
	gfx.scrollX = 5; gfx.scrollY = 5
	erase
	print "Here is where objectives will be shown."
	print
	print "Maybe including a checkbox or two."
	while true; yield; end while
end if
