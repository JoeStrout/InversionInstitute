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

ChapterButton = new Button
ChapterButton.chapter = null  // fill in with a chapter data map from above
ChapterButton.action = function
	if self.chapter.locked then
		// No way José!
		return
	end if
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
	gfx = oldGfx
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

// create other UI
optsBtn = Button.make(file.loadImage("/usr/pics/ui/optionsButton.png"), 960-90, 600)
optsBtn.action = function
	ensureImport "optionScreen"
	optionScreen.present
	run
end function

// main loop
while true
	Button.updateAll
	music.update
	yield
end while


