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

checkboxEmpty = file.loadImage("pics/ui/checkboxEmpty.png")
checkboxChecked = file.loadImage("pics/ui/checkboxChecked.png")

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

print = function(s, color=null, shadow=false)
	if s[:2] == "☐ " then
		printWithBullet checkboxEmpty, s[2:], color, shadow
	else if s[:2] == "☑ " then
		printWithBullet checkboxChecked, s[2:], color, shadow
	else
		if color == null then color = textColor
		if shadow then smallFont.printWrapped(s, cursorX+1, cursorY-1, area.width-12-1, "#000000")
		outer.cursorY = smallFont.printWrapped(s, cursorX, cursorY, area.width-12, color)
	end if
end function

printWithBullet = function(bulletImg, s, color=null, shadow=false)
	gfx.drawImage bulletImg, cursorX, cursorY - 1
	w = bulletImg.width + 2
	if color == null then color = textColor
	if shadow then smallFont.printWrapped(s, cursorX + w+1, cursorY-1, area.width-12-w, "#000000")
	outer.cursorY = smallFont.printWrapped(s, cursorX + w, cursorY, area.width-12-w, color)
end function

printErr = function(s)
	print s, "#FF0000", true
end function

printSuccess = function(s)
	print s, "#00FF00", true
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
