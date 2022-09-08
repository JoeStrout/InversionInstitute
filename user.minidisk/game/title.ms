// Main title screen for the game.

import "miscUtil"
ensureImport "backgrounds"
ensureImport "displays"
ensureImport "mathUtil"

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

ensureImport "drawing"
ensureImport "gameData"
ensureImport "json"
ensureImport "button"
button.sprites = displays.tiSprite.sprites

bigFont = bmfFonts.Font.load("/usr/fonts/ArialBlack18.bmf")
//smallFont = bmfFonts.Font.load("/usr/fonts/Arial14Bold.bmf")
smallFont = bmfFonts.Font.load("/usr/fonts/minimicro-pro-16.bmf")

welcomeMsg = "Welcome"
if gameData.get("ch1.done") then welcomeMsg = welcomeMsg + " back"
welcomeMsg = welcomeMsg + ", " + gameData.playerName + "!"
bigFont.printCentered welcomeMsg, 480+2, 450-2, 1, color.black
bigFont.printCentered welcomeMsg, 480, 450, 1, "#76D6FF"

// load chapter metadata
chapters = []
for folder in file.children("/usr/chapters")
	f = file.open("/usr/chapters/" + folder + "/context.ms", "r")
	if f == null or f isa string then continue
	data = {"number":null, "folderName":null, "title":null}
	while not f.atEnd
		parts = f.readLine.split(" = ")
		if parts.len != 2 then continue
		if parts[0] == "number" then data.number = val(parts[1])
		if parts[0] == "folderName" then data.folderName = json.parse(parts[1])
		if parts[0] == "title" then data.title = json.parse(parts[1])
		if data.number and data.folderName and data.title then
			data.done = gameData.get("ch" + data.number + ".done")
			chapters.push data
			break
		end if
	end while
	f.close	
end for
chapters.sort "number"
for i in chapters.indexes
	ch = chapters[i]
	if ch == chapters[0] then
		ch.locked = false
	else
		ch.locked = not chapters[i-1].done
	end if
	if ch.locked then ch.title = "(locked)"
end for

smallFont.printCentered "SELECT CHAPTER:", 480, 410, 1, "#FFFF00CC"

ChapterButton = new Button
ChapterButton.chapter = null  // fill in with a chapter data map from above
ChapterButton.action = function
	if self.chapter.locked then
		// No way José!
		return
	end if
	cd "/usr/chapters/" + self.chapter.folderName
	load "introScene"
	run
end function

ChapterButton.make = function(data)
	w = 220
	h = 40
	oldGfx = gfx
	globals.gfx = displays.tiScratch
	gfx.clear "#00000066", w, h
	gfx.drawRect 0, 0, w, h, color.black
	if data.done then textColor = color.silver else textColor = color.yellow
	if data.locked then textColor = color.gray
	smallFont.printRight data.number + ".", 32, 12, 1, textColor
	tw = w - 34
	if smallFont.width(data.title) <= tw then
		smallFont.print data.title, w - tw, 12, 1, textColor
	else
		lines = drawing.wrapLines(data.title, tw, smallFont)
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

// main loop
while true
	Button.updateAll
	yield
end while


