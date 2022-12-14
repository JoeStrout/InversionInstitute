// Main title screen for the game.

import "miscUtil"
ensureImport "backgrounds"
ensureImport "displays"
ensureImport "mathUtil"
ensureImport "music"

displays.setupTitle
sprites = displays.tiSprite.sprites

night = new Sprite
night.image = backgrounds.castleNight
night.x = 480; night.y = 320
sprites.push night

//eve = new Sprite
//eve.image = backgrounds.castleEvening
//eve.x = 480; eve.y = 320
//sprites.push eve

music.playTitle

title = new Sprite
title.image = file.loadImage("/usr/pics/ui/title.png")
title.x = 480; title.y = 640 - title.image.height/2
title.tint = color.clear
sprites.push title

for t in range(0, 1, 0.02)
	title.scale = mathUtil.lerp(1.5, 0.4, t)
	title.tint = color.lerp(color.clear, color.white, t)
	title.y = mathUtil.lerp(640, 560, t)
	yield
end for
for t in range(0, 1, 0.15)
	title.scale = mathUtil.lerp(0.4, 0.5, t)
	yield
end for

music.preloadAll

ensureImport "drawing"
ensureImport "gameData"
ensureImport "json"
import "button"
button.sprites = displays.tiSprite.sprites

bigFont = bmfFonts.Font.load("/usr/fonts/ArialBlack18.bmf")
//smallFont = bmfFonts.Font.load("/usr/fonts/Arial14Bold.bmf")
smallFont = bmfFonts.Font.load("/usr/fonts/minimicro-pro-16.bmf")

welcomeMsg = "Welcome"
if gameData.get("ch1.done") then welcomeMsg = welcomeMsg + " back"
welcomeMsg = welcomeMsg + ", " + gameData.playerName + "!"
bigFont.printCentered welcomeMsg, 480+2, 450-2, 1, color.black
bigFont.printCentered welcomeMsg, 480, 450, 1, "#76D6FF"

if globals.hasIndex("toc") then
	toc.reload
else
	ensureImport "toc"
end if
chapters = toc.chapters

smallFont.printCentered "SELECT CHAPTER:", 480, 410, 1, "#FFFF00CC"

cleanUp = function
	button.Button.closeAll
end function

ChapterButton = new button.Button
ChapterButton.chapter = null  // fill in with a chapter data map from above
ChapterButton.action = function
	if self.chapter.locked then
		// No way José!
		return
	end if
	cleanUp
	toc.startChapter self.chapter.number
end function

ChapterButton.make = function(data)
	w = 220
	h = 40
	oldGfx = gfx
	globals.gfx = displays.tiScratch
	gfx.clear "#00000066", w, h
	gfx.drawRect 0, 0, w, h, color.black
	title = data.title
	if data.done then textColor = color.silver else textColor = color.yellow
	if data.locked then
		textColor = color.gray
		title = "(locked)"
	end if
	smallFont.printRight data.number + ".", 32, 12, 1, textColor
	tw = w - 34
	if smallFont.width(title) <= tw then
		smallFont.print title, w - tw, 12, 1, textColor
	else
		lines = drawing.wrapLines(title, tw, smallFont)
		smallFont.print lines[0], w - tw, 21, 1, textColor
		smallFont.print lines[1], w - tw, 5, 1, textColor
	end if
	globals.gfx = oldGfx
	sp = new ChapterButton
	sp.chapter = data
	sp.init displays.tiScratch.getImage
	return sp
end function

// create chapter buttons
x = 20
y = 370
for ch in chapters
	btn = ChapterButton.make(ch)
	btn.x = x + btn.image.width/2; btn.y = y
	y = y - 48
	if y < 30 then
		x = x + 232
		y = 370
	end if
end for

// create the "free play" button
FreePlayButton = new button.Button
FreePlayButton.make = function
	w = 220
	h = 40
	oldGfx = gfx
	globals.gfx = displays.tiScratch
	gfx.clear "#00000066", w, h
	gfx.drawRect 0, 0, w, h, color.black
	title = "Free Play"
	textColor = color.silver
	locked = not gameData.get("ch3.done")
	if locked then
		textColor = color.gray
		title = "(locked)"
	end if
	smallFont.printCentered title, w/2, 12, 1, textColor
	globals.gfx = oldGfx
	sp = new FreePlayButton
	sp.init displays.tiScratch.getImage
	sp.locked = locked
	return sp
end function
FreePlayButton.action = function
	if self.locked then return
	cleanUp
	music.playEditor
	cd "/usr/game"
	load "freeplay"
	run
end function
freePlayBtn = FreePlayButton.make
freePlayBtn.x = 826
freePlayBtn.y = 34

// create other UI
optsBtn = button.Button.make(file.loadImage("/usr/pics/ui/optionsButton.png"), 960-90, 600)
optsBtn.action = function
	ensureImport "optionScreen"
	cleanUp
	optionScreen.present
	run
end function

// special welcome dialog during Early Access
doEADialog = function
	import "baab"
	Baab.addSpritesToList displays.vnCharacters.sprites
	displays.vnSpeech.color = color.yellow
	drawing.drawSpeech "Thank you for supporting Inversion Institute in *Early Access!*" +
	char(13) + char(13) + "_This is not a finished game._ There are rough edges to " +
	"polish off, and many more puzzles and features to come. *For support*, please " +
	"use the Steam or itch.io forums, or find us on Discord. We really want to hear " +
	"your feedback!",
		drawing.Speaker.Right, null
	while not key.available and not mouse.button
		Baab.animate
		yield
	end while
	key.clear
	while mouse.button; yield; end while
	displays.vnSpeech.clear
	displays.vnCharacters.clear
end function

if not gameData.get("EAdialog") then
	doEADialog
	gameData.data.EAdialog = true
	gameData.writeToDisk
end if

// main loop
while true
	button.Button.updateAll
	music.update
	yield
end while


