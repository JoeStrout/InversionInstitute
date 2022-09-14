// This module creates and manages the Options (or Game Settings) screen.

import "miscUtil"
ensureImport "mathUtil"
ensureImport "textField"
ensureImport "drawing"

setup = function
	clear

	display(6).mode = displayMode.solidColor
	display(6).color = "#000066"
	display(5).mode = displayMode.sprite

	outer.spriteDisp = display(5)
	spriteDisp.clear

	display(4).mode = displayMode.pixel
	globals.gfx = display(4)
	gfx.clear color.clear
	
	outer.circuitBg = new Sprite
	circuitBg.image = file.loadImage("/usr/pics/Backgrounds/circuitPattern.png")
	circuitBg.scale = 8
	circuitBg.tint = "#FFFFFF33"
	circuitBg.x = 480; circuitBg.y = 320
	spriteDisp.sprites.push circuitBg
	
	font.printCentered "Game Options", 480, 600, 2, color.yellow
	x = 400; y = 500
	font.printRight "Player Name", x, y
	outer.nameField = new TextField
	nameField.init
	nameField.bounds = Rect.make(x+20, y-16, 160, 50)
	nameField.font = font
	nameField.text = "Pat"
	nameField.select
	nameField.draw
	
	x = 320; y = 400
	font.printRight "Pronouns", x, y
	outer.pronounFields = []
	for pron in ["he", "him", "his", "his"]
		fld = new TextField
		fld.init
		fld.bounds = Rect.make(x+20, y-16, 100, 50)
		fld.font = font
		fld.text = pron
		fld.select
		fld.draw
		outer.pronounFields.push fld
		x = x + 120
	end for
	font.printRight "Example:", 380-20, 350 - 20
	updateExample
	
	for fld in textField.instances
		fld.onChange = @updateExample
	end for
	
	nameField.setFocus
end function

cleanUp = function
	nameField.close
end function

updateExample = function
	box = Rect.make(380, 350-100, 320, 100)
	box.fill gfx, color.clear
//	box.frame gfx, color.aqua
	s = "If you see " + nameField.text + ", tell " + pronounFields[1].text +
	 " that " + pronounFields[0].text + " can play " + pronounFields[2].text +
	 " game because it is " + pronounFields[3].text + "."
	font.printWrapped s, box.left + 4, box.top - 20, box.width - 16
end function

shiftBg = function
	extraWidth = circuitBg.image.width * circuitBg.scale - 960
	extraHeight = circuitBg.image.height * circuitBg.scale - 640
	mx = 1 - mathUtil.clamp(mouse.x/960, 0, 1)
	my = 1 - mathUtil.clamp(mouse.y/640, 0, 1)
	circuitBg.x = 480 - extraWidth/2 + extraWidth * mx
	circuitBg.y = 320 - extraHeight/2 + extraHeight * my
end function

doMainLoop = function
	while not key.pressed("escape")
		yield
		shiftBg
		TextField.updateAll
	end while
	cleanUp
	key.clear
end function

present = function
	setup
	doMainLoop
end function


if locals == globals then
	present
end if

