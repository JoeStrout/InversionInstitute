// This is the "Challenge Complete" dialog that appears when you
// finish a puzzle, including the histogram-drawing code.

if not globals.hasIndex("miscUtil") then import "miscUtil"
ensureImport "soda"
ensureImport "ttFonts"
ensureImport "rect"

chartTitleFont = null
dlogTitleFont = null
buttonFont = null
barPattern = null

drawBackground = function
	img = file.loadImage("pics/ui/Parchment-400x300.png")
	gfx.drawImage img, 480-img.width, 320-img.height, img.width*2, img.height*2
	img.release
end function

drawTitle = function
	if dlogTitleFont == null then
		outer.dlogTitleFont = ttFonts.TTFont.Load("fonts/MorrisRoman-Black.ttf", 64)
	end if
	dlogTitleFont.printCentered "Challenge Complete!", 480, 500, 1, color.black
end function

drawHistogram = function(rect, data, title)
	gfx.color = color.black
	gfx.line rect.left, rect.bottom, rect.right, rect.bottom
	gfx.line rect.left, rect.bottom, rect.left, rect.top
	
	if chartTitleFont == null then
		outer.chartTitleFont = ttFonts.TTFont.Load("fonts/MorrisRoman-Black.ttf", 20)
	end if
	chartTitleFont.printCentered title, rect.midX, rect.top, 1, color.black

	if barPattern == null then
		outer.barPattern = file.loadImage("pics/patterns/HashLinesMedT.png")
	end if
	
	bars = 9
	divs = bars - 1
	barW = rect.width / 9
	for i in range(1, divs)
		x = rect.left + barW * i
		gfx.line x, rect.bottom - 6, x, rect.bottom + 6
		barH = round(rect.height * floor(rnd*10) / 10)
		if barH <= 0 then continue
		gfx.patternFill barPattern, x, rect.bottom, barW, barH
		gfx.drawRect x, rect.bottom, barW, barH
	end for
end function

drawButtons = function
	if buttonFont == null then
		outer.buttonFont = ttFonts.TTFont.Load("fonts/MorrisRoman-Black.ttf", 48)
	end if
	buttonFont.printCentered "Continue Editing", 480, 150, 1, color.black
	buttonFont.printCentered "Exit to Story", 480, 80, 1, color.black
end function

test = function
	clear
	drawBackground
	drawTitle
	
	histW = 216; gap = 20
	histRect = Rect.Make(480 - histW/2 - gap - histW, 240, histW, 196)
	drawHistogram histRect, [], "Inversion Glyphs"

	histRect.left = 480 - histW/2
	drawHistogram histRect, [], "Total Ink"

	histRect.left = 480 + histW/2 + gap
	drawHistogram histRect, [], "Total Ink"

	drawButtons

	while not key.pressed("escape")
		yield
	end while
end function

if locals == globals then test
