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

NORMAL = "NORMAL"
HOVER = "HOVER"
PRESSED = "PRESSED"

SimpleTextButton = {}
SimpleTextButton.font = null
SimpleTextButton.state = NORMAL
SimpleTextButton.Instances = []

SimpleTextButton.Make = function(text, x, y)
	if self.font == null then self.font = ttFonts.TTFont.Load("fonts/MorrisRoman-Black.ttf", 48)
	noob = new self
	noob.text = text
	noob.x = x
	noob.y = y
	self.Instances.push noob
	return noob
end function

SimpleTextButton.contains = function(xy)
	w = self.font.width(self.text)
	top = self.y + self.font.ascent
	if not (self.x - w/2 <= xy.x < self.x + w/2) then return false
	if not (top - self.font.lineHeight <= xy.y <= top) then return false
	return true
end function

SimpleTextButton.draw = function
	if self.state == HOVER then
		c = "#0088FF"
	else if self.state == PRESSED then
		c = "#008888"
	else
		c = color.black
	end if
	self.font.printCentered self.text, self.x, self.y, 1, c
end function

SimpleTextButton.action = function
	print "Clicked: " + self.text
end function

SimpleTextButton.update = function
	doAction = false
	hover = self.contains(mouse)
	if hover and mouse.button then
		// track until mouse released!
		while mouse.button
			if self.contains(mouse) then newState = PRESSED else newState = NORMAL
			if newState != self.state then
				self.state = newState
				self.draw
			end if
			yield
		end while
		if self.state == PRESSED then doAction = true
		self.state = NORMAL
	else
		if hover == (self.state == HOVER) then return
		if hover then self.state = HOVER else self.state = NORMAL
	end if
	self.draw 
	if doAction then self.action
end function

SimpleTextButton.UpdateAll = function
	for btn in self.Instances; btn.update; end for
end function

done = false
exitToStory = false

close = function
	outer.exitToStory = false
	outer.done = true
	display(1).setMode displayMode.off
	globals.gfx = display(3)
	SimpleTextButton.Instances = []
end function

closeAndExit = function
	close
	outer.exitToStory = true
end function

setup = function
	outer.exitToStory = false
	outer.done = false
	drawBackground
	drawTitle

	SimpleTextButton.Instances = []

	contBtn = SimpleTextButton.Make("Continue Editing", 480, 150)
	contBtn.action = @close

	exitBtn = SimpleTextButton.Make("Exit to Story", 480, 80)
	exitBtn.action = @closeAndExit

	for btn in SimpleTextButton.Instances; btn.draw; end for

	histW = 216; gap = 20
	histRect = Rect.Make(480 - histW/2 - gap - histW, 240, histW, 196)
	drawHistogram histRect, [], "Inversion Glyphs"

	histRect.left = 480 - histW/2
	drawHistogram histRect, [], "Total Ink"

	histRect.left = 480 + histW/2 + gap
	drawHistogram histRect, [], "Total Ink"
end function

present = function
	display(1).setMode displayMode.pixel
	globals.gfx = display(1)
	gfx.clear color.clear
	setup
	print "Starting doneDialog loop"
	while not done
		yield
		SimpleTextButton.UpdateAll
		if key.pressed("escape") then close
	end while
	print "Exiting doneDialog loop"
end function


test = function
	clear
	present
end function

if locals == globals then test
