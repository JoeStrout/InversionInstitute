// This is the "Challenge Complete" dialog that appears when you
// finish a puzzle, including the histogram-drawing code.

if not globals.hasIndex("miscUtil") then import "miscUtil"
ensureImport "soda"
ensureImport "ttFonts"
ensureImport "rect"
ensureImport "json"
ensureImport "base64"
ensureImport "listUtil"
ensureImport "SimpleTextButton"

postScoreUrl = "http://localhost:8080/api/v1/submit-solution"

backgroundImage = null
chartTitleFont = null
buttonFont = null
numLabelsFont = null
dlogTitleFont = null
buttonFont = null
barPattern = null
valueMarker = null

drawBackground = function
	loadResources
	img = backgroundImage
	gfx.drawImage img, 480-img.width, 320-img.height, img.width*2, img.height*2
end function

drawTitle = function
	dlogTitleFont.printCentered "Challenge Complete!", 480, 500, 1, color.black
end function

loadResources = function
	if backgroundImage == null then
		outer.backgroundImage = file.loadImage("pics/ui/Parchment-400x300.png")
	end if
	
	if dlogTitleFont == null then
		outer.dlogTitleFont = ttFonts.TTFont.Load("fonts/MorrisRoman-Black.ttf", 64)
	end if

	if buttonFont == null then
		buttonFont = ttFonts.TTFont.Load("fonts/MorrisRoman-Black.ttf", 48)
	end if
	
	if chartTitleFont == null then
		outer.chartTitleFont = ttFonts.TTFont.Load("fonts/MorrisRoman-Black.ttf", 20)
	end if

	if numLabelsFont == null then
		outer.numLabelsFont = ttFonts.TTFont.Load("fonts/MorrisRoman-Black.ttf", 12)
	end if

	if barPattern == null then
		outer.barPattern = file.loadImage("pics/patterns/HashLinesMedT.png")
	end if
	
	if valueMarker == null then
		outer.valueMarker = file.loadImage("pics/ui/HistoValueMarker.png")
	end if
end function

drawHistogram = function(rect, data, title, curValue)
	gfx.color = color.black
	gfx.line rect.left, rect.bottom, rect.right, rect.bottom
	gfx.line rect.left, rect.bottom, rect.left, rect.top
	
	chartTitleFont.printCentered title + ": " + curValue, rect.midX, rect.top, 1, color.black

	counts = []
	for entry in data
		counts.push entry.count
	end for
	maxCount = counts.max
	maxBarHeight = rect.height - 12
	
	integers = data.len > 2 and (data[2].min_value == data[1].min_value + 1)
	
	bars = data.len
	divs = bars - 1
	barW = rect.width / bars
	valX = rect.right - barW/2
	if data[1].min_value > curValue then valX = rect.left + barW/2
	for i in range(1, divs+1)
		x = rect.left + barW * i
		gfx.line x, rect.bottom - 4, x, rect.bottom + 6
		if i > counts.len then continue
		if i < counts.len then
			s = str(data[i].min_value)
			if integers then
				if i == counts.len-1 then s += "+"
				numLabelsFont.printCentered s, x + barW/2, rect.bottom - 20, 1, color.black	
				if data[i].min_value == curValue then valX = x + barW/2
				if i == 1 then
					numLabelsFont.printCentered "<" + s, x - barW/2, rect.bottom - 20, 1, color.black	
				end if
			else
				numLabelsFont.printCentered s, x, rect.bottom - 20, 1, color.black
				curMin = data[i].min_value
				prevMin = data[i-1].min_value
				if prevMin <= curValue < curMin then
					valX = x - barW + barW * (curValue - prevMin) / (curMin - prevMin)
					if i == 1 then valX = x - barW/2
				end if
			end if
		end if
		barH = round(maxBarHeight * counts[i-1] / maxCount)
		if barH <= 0 then continue
		x -= barW
		gfx.patternFill barPattern, x, rect.bottom, barW, barH
		gfx.drawRect x, rect.bottom, barW, barH
	end for
	
	if valX != null then
		gfx.line valX, rect.top - valueMarker.height + 2, valX, rect.bottom, color.black, 2
		gfx.drawImage valueMarker, valX - valueMarker.width/2, rect.top - valueMarker.height
	end if
	
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
	SimpleTextButton.font = buttonFont

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
	sim = pixelLogicSim
	
	print "Histogram data (glyphs):"
	print histogramData.gates
	histW = 216; gap = 20
	histRect = Rect.Make(480 - histW/2 - gap - histW, 240, histW, 196)
	drawHistogram histRect, histogramData.gates, "Inversion Glyphs", sim.gates.len
	
	print "Histogram data (total ink):"
	print histogramData.total_ink
	histRect.left = 480 - histW/2
	drawHistogram histRect, histogramData.total_ink, "Total Ink", sim.totalInk
	
	print "Histogram data (core area):"
	print histogramData.core_area
	histRect.left = 480 + histW/2 + gap
	drawHistogram histRect, histogramData.core_area, "Core Area", sim.coreArea.area
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
	// shim our needed modules for testing
	globals.context = {}
	context.number = 7
	globals.gameData = {}
	gameData.data = {}
	gameData.data.installId = "TestyMcTester"
	globals.pixelLogicSim = {}
	pixelLogicSim.gates = [42]*11
	pixelLogicSim.totalInk = 304
	pixelLogicSim.coreArea = Rect.Make(0, 0, 25, 10)
	present "../scoreserver/internal/scoring/testdata/circuit-7.png"
end function

if locals == globals then test
