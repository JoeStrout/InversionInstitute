// This is the "Challenge Complete" dialog that appears when you
// finish a puzzle, including the histogram-drawing code.

if not globals.hasIndex("miscUtil") then import "miscUtil"
ensureImport "soda"
ensureImport "ttFonts"
ensureImport "rect"
ensureImport "json"
ensureImport "base64"
ensureImport "listUtil"

postScoreUrl = "http://localhost:8080/api/v1/submit-solution"


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
	
	counts = []
	for entry in data
		counts.push entry.count
	end for
	maxCount = counts.max
	maxBarHeight = rect.height - 12
	
	bars = data.len
	divs = bars - 1
	barW = rect.width / bars
	for i in range(1, divs+1)
		x = rect.left + barW * i
		gfx.line x, rect.bottom - 6, x, rect.bottom + 6
		if i > counts.len then continue
		barH = round(maxBarHeight * counts[i-1] / maxCount)
		if barH <= 0 then continue
		x -= barW
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
end function

prepareServerPackage = function(circuitPath)
	data = {}
	data.puzzle_id = context.number
	data.puzzle_version = "v1"  // for now, it's always v1
	data.install_id = gameData.data.installId
	data.client_platform = version.hostName
	pngData = file.loadRaw(circuitPath)
	if pngData == null then
		print "Unable to load PNG at " + circuitPath
		return null
	end if
	data.solution_png_base64 = base64.toBase64(pngData)
	return json.toJSON(data)
end function

drawHistograms = function(histogramData)
	print "Histogram data (glyphs):"
	print histogramData.gates
	histW = 216; gap = 20
	histRect = Rect.Make(480 - histW/2 - gap - histW, 240, histW, 196)
	drawHistogram histRect, histogramData.gates, "Inversion Glyphs"
	
	print "Histogram data (total ink):"
	print histogramData.total_ink
	histRect.left = 480 - histW/2
	drawHistogram histRect, histogramData.total_ink, "Total Ink"
	
	print "Histogram data (core area):"
	print histogramData.core_area
	histRect.left = 480 + histW/2 + gap
	drawHistogram histRect, histogramData.core_area, "Core Area"
end function

present = function(circuitPath)
	display(1).setMode displayMode.pixel
	globals.gfx = display(1)
	gfx.clear color.clear
	setup

	requestBody = prepareServerPackage(circuitPath)
	print "REQUEST:"
	print requestBody
	requestHeaders = {"Content-Type": "application/json"}
	result = http.post(postScoreUrl, requestBody, requestHeaders)
	resultData = json.parse(result)
	print "RESULT:"
	pprint resultData
	if resultData != null and resultData.hasIndex("histograms") then
		drawHistograms resultData.histograms
	end if
		
	for btn in SimpleTextButton.Instances; btn.draw; end for
	
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
	globals.context = {}
	context.number = 7
	globals.gameData = {}
	gameData.data = {}
	gameData.data.installId = "TestyMcTester"
	present "../scoreserver/internal/scoring/testdata/circuit-7.png"
end function

if locals == globals then test
