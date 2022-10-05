import "miscUtil"
ensureImport "displays"
ensureImport "bmfFonts"
ensureImport "qa"
ensureImport "json"	// (used for PixelDrawing.load)
ensureImport "markup"

globals.font = bmfFonts.Font.load("/usr/fonts/NotoSerif-24.bmf")

globals.bigPrinter = new markup.BmfPrinter
bigPrinter.font = font
bigPrinter.boldFont = bmfFonts.Font.load("/usr/fonts/NotoSerifBold-24.bmf")
bigPrinter.italicFont = bmfFonts.Font.load("/usr/fonts/NotoSerifItalic-24.bmf")
bigPrinter.boldItalicFont = bmfFonts.Font.load("/usr/fonts/NotoSerifBoldItalic-24.bmf")

globals.smallPrinter = new markup.BmfPrinter
smallPrinter.font = bmfFonts.Font.load("/usr/fonts/NotoSerif-14.bmf")
smallPrinter.boldFont = bmfFonts.Font.load("/usr/fonts/NotoSerifBold-14.bmf")
smallPrinter.italicFont = bmfFonts.Font.load("/usr/fonts/NotoSerifItalic-14.bmf")
smallPrinter.boldItalicFont = bmfFonts.Font.load("/usr/fonts/NotoSerifBoldItalic-14.bmf")

button9slice = null

scratchGfx = null

//----------------------------------------------------------------------
// Image9Slice class: an image wrapper with margins that are not stretched,
// and a middle that is stretched when drawn to any size.
//----------------------------------------------------------------------

globals.Image9Slice = {}
Image9Slice.image = null		// (an Image instance)
Image9Slice.leftMargin = 0
Image9Slice.bottomMargin = 0
Image9Slice.rightMargin = 0
Image9Slice.topMargin = 0

Image9Slice.make = function(image, left=12, bottom=12, right=12, top=12)
	noob = new Image9Slice
	noob.image = image
	noob.leftMargin = left
	noob.bottomMargin = bottom
	noob.rightMargin = right
	noob.topMargin = top
	return noob
end function

Image9Slice.draw = function(g, left, bottom, width, height)
	topH = min(self.topMargin, height/2)
	botH = min(self.bottomMargin, height/2)
	midH = height - topH - botH
	srcMidH = self.image.height - self.bottomMargin - self.topMargin
	nearTop = bottom + height - topH
	srcNearTop = self.image.height - self.topMargin
	midW = width - self.leftMargin - self.rightMargin
	srcW = self.image.width - self.leftMargin - self.rightMargin
	nearRight = left + width - self.rightMargin
	srcNearRight = self.image.width - self.rightMargin
		
	// left side (bottom, middle, top)
	g.drawImage self.image, 
		left, bottom, self.leftMargin, botH,
		0, 0, self.leftMargin, self.bottomMargin
	g.drawImage self.image, 
		left, bottom + self.bottomMargin, self.leftMargin, midH,
		0, self.bottomMargin, self.leftMargin, srcMidH
	g.drawImage self.image, 
		left, nearTop, self.leftMargin, topH,
		0, srcNearTop, self.leftMargin, self.topMargin
	
	// center section (bottom, middle, top)
	g.drawImage self.image, 
		left + self.leftMargin, bottom, midW, botH,
		self.leftMargin, 0, srcW, self.bottomMargin
	g.drawImage self.image, 
		left + self.leftMargin, bottom + self.bottomMargin, midW, midH,
		self.leftMargin, self.bottomMargin, srcW, srcMidH
	g.drawImage self.image, 
		left + self.leftMargin, nearTop, midW, topH,
		self.leftMargin, srcNearTop, srcW, self.topMargin
	
	// right section (bottom, middle, top)
	g.drawImage self.image, 
		nearRight, bottom, self.rightMargin, botH,
		srcNearRight, 0, self.rightMargin, self.bottomMargin
	g.drawImage self.image, 
		nearRight, bottom + self.bottomMargin, self.rightMargin, midH,
		srcNearRight, self.bottomMargin, self.rightMargin, srcMidH
	g.drawImage self.image, 
		nearRight, nearTop, self.rightMargin, topH,
		srcNearRight, srcNearTop, self.rightMargin, self.topMargin	
end function

//----------------------------------------------------------------------
// PixelDrawing: a bunch of pixels we draw one by one, in animated fashion,
// as defined by a text file made with devUtil/makePixelAnim.

PixelDrawing = {}
PixelDrawing.curStep = -1
PixelDrawing.nextStepTime = 0
PixelDrawing.left = 300
PixelDrawing.bottom = 200
PixelDrawing.scale = 5
PixelDrawing.gfx = gfx
PixelDrawing.load = function(path, gfx, left, bottom, scale=5)
	if gfx then self.gfx = gfx
	self.left = left
	self.bottom = bottom
	self.scale = scale
	lines = file.readLines(path)
	qa.assert(lines)
	self.steps = []
	for line in lines
		self.steps.push json.parse(line)
	end for
end function

PixelDrawing.update = function
	if time < self.nextStepTime then return
	self.nextStepTime = time + 0.025
	self.curStep = self.curStep + 1
	if self.curStep >= self.steps.len then return
	x = self.steps[self.curStep][0] * self.scale
	y = self.steps[self.curStep][1] * self.scale
	c = self.steps[self.curStep][2]	
	self.gfx.fillRect self.left + x, self.bottom + y, self.scale, self.scale, c
end function	

PixelDrawing.drawAll = function(tint=null)
	for p in self.steps
		x = p[0] * self.scale
		y = p[1] * self.scale
		c = p[2]	
		if tint then c = color.lerp(c, tint, 0.6)
		self.gfx.fillRect self.left + x, self.bottom + y, self.scale, self.scale, c
	end for
end function

//----------------------------------------------------------------------

// Wrap a long text into multiple lines, breaking on words,
// as needed to fit within the given width.  Return a list of strings.
wrapLines = function(s="", width=550, font=null)
	if not s then return [""]
	if not font then font = globals.font
	result = []
	while true
		lenToFit = font.lenToFit(s, width)
		if lenToFit+1 >= s.len then
			result.push s
			break
		end if
		while lenToFit > 1
			c = s[lenToFit+1]
			if c <= " " then break
			lenToFit = lenToFit - 1
		end while
		result.push s[:lenToFit+1]
		s = s[lenToFit+1:].trimLeft
	end while
	return result
end function

// Extend the font class to draw wrapped text, and return the next Y.
bmfFonts.Font.printWrapped = function(s="", x, y, wrapWidth, tint="#FFFFFF")
	lines = wrapLines(s, wrapWidth, self)
	for line in lines
		self.print line, x, y, 1, tint
		y = y - self.lineHeight
	end for
	return y
end function

// Enum for which speaker a speech box is coming from
Speaker = {}
Speaker.Left = 0
Speaker.Player = 1
Speaker.Right = 2

speechBoxImage = Image9Slice.make(file.loadImage("/usr/pics/ui/SpeechBox.png"), 
		120, 56, 120, 56)

nameBubbleImage = Image9Slice.make(file.loadImage("/usr/pics/ui/NameBubble.png"), 
		60, 20, 60, 20)

drawSpeechBox = function(speaker=Speaker.Left, height=150, name="Someone")
	bottom = 50 + 30 * (speaker != Speaker.Player)
	top = bottom + height
	middle = 480
	width = 600
	left = middle - width/2
	right = middle + width/2	
	speechBoxImage.draw displays.vnSpeech, left, bottom, width, height
	
	if name then
		nameWidth = font.width(name)
		x = middle
		if speaker == Speaker.Left then x = left
		if speaker == Speaker.Right then x = right
		nameBubbleImage.draw displays.vnSpeech, x - nameWidth/2-20, top-12, nameWidth+40, 50
		globals.gfx = displays.vnSpeech
		font.print name, x - nameWidth/2, top+16 + font.sizeOver/2, 1, "#FFFF88"
	end if
	
	return [left, bottom, width, height]
end function

drawSpeech = function(speech="Hello World!", speaker=Speaker.Left, name="Someone")
	displays.vnSpeech.clear color.clear
	textWidth = 550
	textHeight = bigPrinter.calcHeight(speech, 0, 0, textWidth)
	lbwh = drawSpeechBox(speaker, textHeight + 50, name)
	top = lbwh[1] + lbwh[3]
	left = lbwh[0] + 25
	bigPrinter.print speech, left, top - 20 - bigPrinter.font.lineHeight, left + textWidth
end function

drawButton = function(left, bottom, width, height, caption="", font=null, tint="")
	if button9slice == null then
		src = file.loadImage("/usr/pics/ui/button.png")
		hm = src.width/2 - 4
		vm = src.height/2 - 4
		outer.button9slice = Image9Slice.make(src, hm, vm, hm, vm)
	end if
	button9slice.draw gfx, left, bottom, width, height
	if not caption then return
	if not font then font = globals.font
	if not tint then tint = color.white
	font.printCentered caption, left + width/2, bottom+height/2 - font.lineHeight*0.3, 1, tint
end function

makeButton = function(caption, width)
	ensureImport "button"
	if not scratchGfx then outer.scratchGfx = new PixelDisplay
	scratchGfx.clear color.clear, width, 64

	oldGfx = gfx; globals.gfx = scratchGfx
	drawButton 0, 0, width, 64, caption
	img = scratchGfx.getImage
	globals.gfx = oldGfx

	result = new button.Button
	result.init img
	return result
end function

if locals == globals then
	displays.setupVN
	//drawSpeechBox Speaker.Left
	drawSpeech "Hello world!  This is a speech box with several lines of text " +
	"in it.  They should wrap automatically, and the speech bubble should adjust " +
	"as needed to fit."
	drawButton 100, 500, 120, 64, "Button"
end if
