// This module creates and manages the Options (or Game Settings) screen.

import "miscUtil"
ensureImport "mathUtil"
ensureImport "textField"
ensureImport "drawing"
ensureImport "button"
ensureImport "gameData"
ensureImport "music"

pronounLabels = ["he/him", "she/her", "they/them", "other"]
pronouns = {}
pronouns[pronounLabels[0]] = ["he", "him", "his", "his"]
pronouns[pronounLabels[1]] = ["she", "her", "her", "hers"]
pronouns[pronounLabels[2]] = ["they", "them", "their", "theirs"]
pronouns[pronounLabels[3]] = [""] * 4

OnOffSwitch = new button.Button
OnOffSwitch.images = []
OnOffSwitch.images.push file.loadImage("/usr/pics/ui/switch-off.png")
OnOffSwitch.images.push file.loadImage("/usr/pics/ui/switch-on.png")
OnOffSwitch.isOn = function
	return self.image == self.images[true]
end function
OnOffSwitch.setOn = function(nowOn)
	self.image = self.images[nowOn]
end function

OnOffSwitch.init = function(leftx=null, midy=320, keys)
	super.init self.images[0], leftx, midy, keys
end function

OnOffSwitch.make = function(leftx=null, midy=320, keys)
	noob = new OnOffSwitch
	noob.init leftx, midy, keys
	return noob
end function

OnOffSwitch.action = function
	self.setOn not self.isOn
end function

setup = function
	clear
	button.Button.closeAll

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
	nameField.text = gameData.playerName
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
	pn = gameData.pronoun
	for pron in [pn.they, pn.them, pn.their, pn.theirs]
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
	
	backBtn = button.Button.make(file.loadImage("/usr/pics/ui/backButton.png"), 10, 600)
	backBtn.action = @cleanUp
	backBtn.keys = ["escape"]
	
	outer.musicSwitch = OnOffSwitch.make(200, 100)
	musicSwitch.setOn music.isOn
	musicSwitch.action = function
		super.action
		text.color = color.aqua
		music.setOn self.isOn
		gameData.data.music = self.isOn
		gameData.writeToDisk
	end function
	font.printRight "Music:", musicSwitch.x-musicSwitch.image.width/2-20, musicSwitch.y - 12

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
	gameData.pronoun.they = pronounFields[0].text
	gameData.pronoun.them = pronounFields[1].text
	gameData.pronoun.their = pronounFields[2].text
	gameData.pronoun.theirs = pronounFields[3].text
	gameData.playerName = nameField.text
	gameData.writeToDisk
	
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
	while not done
		yield
		shiftBg
		TextField.updateAll
		button.Button.updateAll
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

