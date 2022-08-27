import "miscUtil"
ensureImport "displays"
ensureImport "bmfFonts"

globals.font = bmfFonts.Font.load("/usr/fonts/Georgia-24.bmf")


//----------------------------------------------------------------------
// Image9Slice class: an image wrapper with margins that are not stretched,
// and a middle that is stretched when drawn to any size.
//----------------------------------------------------------------------

Image9Slice = {}
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
	midH = height - self.bottomMargin - self.topMargin
	srcH = self.image.height - self.bottomMargin - self.topMargin
	nearTop = bottom + height - self.topMargin
	srcNearTop = self.image.height - self.topMargin
	midW = width - self.leftMargin - self.rightMargin
	srcW = self.image.width - self.leftMargin - self.rightMargin
	nearRight = left + width - self.rightMargin
	srcNearRight = self.image.width - self.rightMargin
	
	// left side (bottom, middle, top)
	g.drawImage self.image, 
		left, bottom, self.leftMargin, self.bottomMargin,
		0, 0, self.leftMargin, self.bottomMargin
	g.drawImage self.image, 
		left, bottom + self.bottomMargin, self.leftMargin, midH,
		0, self.bottomMargin, self.leftMargin, srcH
	g.drawImage self.image, 
		left, nearTop, self.leftMargin, self.topMargin,
		0, srcNearTop, self.leftMargin, self.topMargin
	
	// center section (bottom, middle, top)
	g.drawImage self.image, 
		left + self.leftMargin, bottom, midW, self.bottomMargin,
		self.leftMargin, 0, srcW, self.bottomMargin
	g.drawImage self.image, 
		left + self.leftMargin, bottom + self.bottomMargin, midW, midH,
		self.leftMargin, self.bottomMargin, srcW, srcH
	g.drawImage self.image, 
		left + self.leftMargin, nearTop, midW, self.topMargin,
		self.leftMargin, srcNearTop, srcW, self.topMargin
	
	// right section (bottom, middle, top)
	g.drawImage self.image, 
		nearRight, bottom, self.rightMargin, self.bottomMargin,
		srcNearRight, 0, self.rightMargin, self.bottomMargin
	g.drawImage self.image, 
		nearRight, bottom + self.bottomMargin, self.rightMargin, midH,
		srcNearRight, self.bottomMargin, self.rightMargin, srcH
	g.drawImage self.image, 
		nearRight, nearTop, self.rightMargin, self.topMargin,
		srcNearRight, srcNearTop, self.rightMargin, self.topMargin	
end function

//----------------------------------------------------------------------

// Wrap a long text into multiple lines, breaking on words,
// as needed to fit within the given width.  Return a list of strings.
wrapLines = function(s, width=550)
	result = []
	while true
		lenToFit = font.lenToFit(s, width)
		if lenToFit >= s.len then
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
	lines = wrapLines(speech, 550)
	lbwh = drawSpeechBox(speaker, lines.len * font.lineHeight + 50, name)
	y = lbwh[1] + 25 + font.lineHeight * lines.len + font.sizeOver
	x = lbwh[0] + 25
	globals.gfx = displays.vnSpeech
	for line in lines
		font.print line, x, y
		y = y - font.lineHeight
	end for
end function

if locals == globals then
	displays.setupVN
	drawSpeechBox Speaker.Left
end if