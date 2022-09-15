// This module creates and manages the Options (or Game Settings) screen.

import "miscUtil"
ensureImport "mathUtil"
ensureImport "textField"
ensureImport "drawing"
ensureImport "button"

pronounLabels = ["he/him", "she/her", "they/them", "other"]
pronouns = {}
pronouns[pronounLabels[0]] = ["he", "him", "his", "his"]
pronouns[pronounLabels[1]] = ["she", "her", "her", "hers"]
pronouns[pronounLabels[2]] = ["they", "them", "their", "theirs"]
pronouns[pronounLabels[3]] = [""] * 4

setup = function
	clear

	display(6).mode = displayMode.solidColor
	display(6).color = "#000066"
	display(5).mode = displayMode.sprite

	outer.bgSprites = display(5)
	bgSprites.clear

	display(4).mode = displayMode.pixel
	globals.gfx = display(4)
	gfx.clear color.clear
	
	display(2).mode = displayMode.sprite
	outer.uiSprites = display(2)
	uiSprites.clear
	
	outer.circuitBg = new Sprite
	circuitBg.image = file.loadImage("/usr/pics/Backgrounds/circuitPattern.png")
	circuitBg.scale = 8
	circuitBg.tint = "#FFFFFF33"
	circuitBg.x = 480; circuitBg.y = 320
	bgSprites.sprites.push circuitBg
	
	font.printCentered "Game Options", 480, 600, 2, color.yellow
	x = 400; y = 500
	font.printRight "Player Name:", x, y
	outer.nameField = new TextField
	nameField.init
	nameField.bounds = Rect.make(x+20, y-16, 160, 50)
	nameField.font = font
	nameField.text = "Pat"
	nameField.select
	nameField.draw
	
	x = 200; y = 400
	font.printRight "Pronouns:", x-20, y

	button.sprites = uiSprites.sprites
	for opt in pronounLabels
		btn = drawing.makeButton(opt, 150)
		btn.x = x + btn.image.width/2
		btn.y = y + 10
		btn.pronouns = pronouns[opt]
		btn.action = @pronounAction
		x = x + btn.image.width + 16
	end for
	
	x = 250; y = 320
	outer.pronounFields = []
	for pron in pronouns[pronounLabels[0]]
		fld = new TextField
		fld.init
		fld.bounds = Rect.make(x+20, y-16, 100, 50)
		fld.font = font
		fld.text = pron
		fld.select
		fld.draw
		pronounFields.push fld
		x = x + 120
	end for
	
	font.printRight "Example:", 380-20, 280 - 20
	updateExample
	
	for fld in textField.instances
		fld.onChange = @updateExample
	end for
	
	backBtn = Button.make(file.loadImage("/usr/pics/ui/backButton.png"), 10, 600)
	backBtn.action = @cleanUp
	
	nameField.setFocus
end function

pronounAction = function
	for i in range(3)
		if self.pronouns[i] then pronounFields[i].setText self.pronouns[i], true
	end for
	if not self.pronouns[i] then
		pronounFields[0].setFocus
	end if
	updateExample
end function

updateExample = function
	box = Rect.make(380, 280-100, 320, 100)
	box.fill gfx, color.clear
//	box.frame gfx, color.aqua
	s = "If you see " + nameField.text + ", tell " + pronounFields[1].text +
	 " that " + pronounFields[0].text + " can play " + pronounFields[2].text +
	 " game because it is " + pronounFields[3].text + "."
	font.printWrapped s, box.left + 4, box.top - 20, box.width - 16
end function

cleanUp = function
	TextField.closeAll
	uiSprites.sprites = []
	bgSprites.sprites = []
	outer.done = true
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
	outer.done = false
	while not key.pressed("escape") and not done
		yield
		shiftBg
		TextField.updateAll
		Button.updateAll
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

