// This module provides a simple Markup interpreter.  It supports the
// following syntax:
//
//   `code`         -- code (monospaced), with no further interpretation within
//   *bold*         -- bold
//   _italic_       -- italic
//   __underline__  -- underlined
//   ~~struck~~     -- strikethrough
//   ##highlight##  -- highlighted
//
// Still TO-DO: make printers keep their own cursor position, and possibly wrap
// settings so you can call print on them multiple times to add additional
// lines/paragraphs.

import "miscUtil"
ensureImport "stringUtil"
ensureImport "bmfFonts"

// StyleRun class: represents a bit of text with a uniform style.
StyleRun = {}
StyleRun.text = ""
StyleRun.code = false
StyleRun.bold = false
StyleRun.italic = false
StyleRun.underline = false
StyleRun.strikethrough = false
StyleRun.highlight = false
StyleRun.make = function(s, copyStyle=null)
	if copyStyle then
		result = copyStyle + {}
	else
		result = new StyleRun
	end if
	result.text = s
	return result
end function

// parse: takes a string containing markup, and returns it as 
// a list of StyleRuns.
parse = function(markup)
	result = []
	maxi = markup.len - 1
	i = -1
	startIndex = 0
	curStyle = new StyleRun
	while i < maxi
		i = i + 1
		c = markup[i]
		if "`*_~#\".indexOf(c) == null then continue
		if curStyle.code and c != "`" then continue // (ignore markup inside code blocks)
		if (c == "_" or c == "~" or c == "#") and i < maxi and markup[i+1] == c then
			c = c+c	// detect double markup chars __, ~~, and ##
		end if		
		if c == "\" then
			// skip the backslash and ignore the next char IF it is a markup char
			if "`*_~#".indexOf(nextc) != null then
				print "Skipping at " + i
				markup = markup[:i] + markup[i+1:]
				maxi = maxi - 1
				continue
			end if
		else if c == "`" then
			if startIndex < i then
				result.push StyleRun.make(markup[startIndex:i], curStyle)
			end if
			curStyle.code = not curStyle.code
		else if c == "*" then
			if startIndex < i then
				result.push StyleRun.make(markup[startIndex:i], curStyle)
			end if
			curStyle.bold = not curStyle.bold
		else if c == "_" then
			if startIndex < i then
				result.push StyleRun.make(markup[startIndex:i], curStyle)
			end if
			curStyle.italic = not curStyle.italic
		else if c == "__" then
			if startIndex < i then
				result.push StyleRun.make(markup[startIndex:i], curStyle)
			end if
			curStyle.underline = not curStyle.underline
		else if c == "~~" then
			if startIndex < i then
				result.push StyleRun.make(markup[startIndex:i], curStyle)
			end if
			curStyle.strikethrough = not curStyle.strikethrough
		else if c == "##" then
			if startIndex < i then
				result.push StyleRun.make(markup[startIndex:i], curStyle)
			end if
			curStyle.highlight = not curStyle.highlight
		end if
		startIndex = i + c.len
		i = i + c.len - 1
	end while
	if startIndex < markup.len then
		result.push StyleRun.make(markup[startIndex:], curStyle)
	end if
	return result
end function

//-----------------------------------------------------------------
// TextPrinter: prints markup using a Text display.  Feel free to 
// override the applyStyle method for custom purposes.
TextPrinter = {}
TextPrinter.color = {}
TextPrinter.color.normal = null			// (null: use text.color at the time of printing)
TextPrinter.color.normalBack = null		// (null: use text.backColor)
TextPrinter.color.code = color.teal
TextPrinter.color.bold = color.yellow
TextPrinter.color.italic = color.pink
TextPrinter.color.underline = color.blue
TextPrinter.color.strikethrough = color.gray
TextPrinter.color.highlight = null
TextPrinter.color.highlightBack = color.yellow

TextPrinter.applyStyle = function(style)
	self.prevColor = text.color
	self.prevBack = text.backColor
	if style.highlight then
		if self.color.highlightBack then text.backColor = self.color.highlightBack
	else
		if self.color.normalBack then text.backColor = self.color.normalBack
	end if
	c = null
	if style.bold then
		if c == null then c = self.color.bold else c = color.lerp(c, self.color.bold, 0.5)
	end if
	if style.italic then
		if c == null then c = self.color.italic else c = color.lerp(c, self.color.italic, 0.5)
	end if
	if style.underline then
		if c == null then c = self.color.underline else c = color.lerp(c, self.color.underline, 0.5)
	end if
	if style.strikethrough then
		if c == null then c = self.color.strikethrough else c = color.lerp(c, self.color.strikethrough, 0.5)
	end if
	if style.highlight then
		if c == null then c = self.color.highlight else c = color.lerp(c, self.color.highlight, 0.5)
	end if
	if c == null then c = self.color.normal
	if c then text.color = c
end function

TextPrinter.restore = function
	text.color = self.prevColor
	text.backColor = self.prevBack
end function

// Cut the text of the given style run to fit within the given width,
// on a word boundary if possible.  Return the left part; update 
// styleRun.text to be the right part.  If we can't fit, then return
// "" unless forceCut is true.
TextPrinter.cutToFit = function(styleRun, width, forceCut=false)
	i = width
	while i > 0
		if styleRun.text[i] <= " " then
			result = styleRun.text[:i]
			styleRun.text = styleRun.text[i:].trimLeft
			return result
		end if
		i = i - 1
	end while
	if not forceCut then
		styleRun.text = styleRun.text.trimLeft
		return ""
	end if
	result = styleRun.text[:width]
	styleRun.text = styleRun.text[width:].trimLeft
	return result
end function

TextPrinter.print = function(markup, col, row, wrapAt=68, wrapTo=null)
	if col != null then text.column = col
	if row != null then text.row = row
	if wrapTo == null then wrapTo = text.column
	oldDelim = text.delimiter
	text.delimiter = ""
	for styleRun in parse(markup)
		self.applyStyle styleRun
		while wrapAt - text.column < styleRun.text.len
			text.print self.cutToFit(styleRun, wrapAt - text.column, text.column<=wrapTo) + char(13)
			text.column = wrapTo
		end while
		text.print styleRun.text
		self.restore
	end for
	text.print oldDelim
	text.delimiter = oldDelim
end function
	
//-----------------------------------------------------------------
// GfxPrinter: Prints to a PixelDisplay (gfx by default).  Always prints in the
// current color, but you can define the color to use for the highlight background.
GfxPrinter = {}
GfxPrinter.highlightBackColor = color.yellow
GfxPrinter.font = "normal"
GfxPrinter.display = null	// if null, uses current gfx at time of printing

GfxPrinter.underlineOffset = {}
GfxPrinter.underlineOffset.small = -1
GfxPrinter.underlineOffset.medium = -1
GfxPrinter.underlineOffset.normal = -1
GfxPrinter.underlineOffset.large = -3

GfxPrinter.strikeOffset = {}
GfxPrinter.strikeOffset.small = 6
GfxPrinter.strikeOffset.medium = 8
GfxPrinter.strikeOffset.normal = 10
GfxPrinter.strikeOffset.large = 14

GfxPrinter.lineHeight = {}
GfxPrinter.lineHeight.small = 14
GfxPrinter.lineHeight.medium = 20
GfxPrinter.lineHeight.normal = 24
GfxPrinter.lineHeight.large = 32

GfxPrinter.width = function(text)
	if self.font == "large" then return text.len * 20
	if self.font == "small" then return text.len * 8
	if self.font == "medium" then return text.len * 17 // ?
	return text.len * 14
end function

// Cut the text of the given style run to fit within the given width,
// on a word boundary if possible.  Return the left part; update 
// styleRun.text to be the right part.  If we can't fit, then return
// "" unless forceCut is true.
GfxPrinter.cutToFit = function(styleRun, width, forceCut=false)
	charWidth = floor(width / self.width("m"))	// find character position at which to cut
	i = charWidth
	while i > 0
		if styleRun.text[i] <= " " then
			result = styleRun.text[:i]
			styleRun.text = styleRun.text[i:].trimLeft
			return result
		end if
		i = i - 1
	end while
	if not forceCut then
		styleRun.text = styleRun.text.trimLeft
		return ""
	end if
	result = styleRun.text[:charWidth]
	styleRun.text = styleRun.text[charWidth:].trimLeft
	return result
end function

// Print a single line of text in a single style, at the given
// x and y coordinates.  Return the new x coordinate after printing.
GfxPrinter.printOneRun = function(style, text, x, y)
	g = self.display
	if g == null then g = gfx
	x1 = x + self.width(text) + 2 + 2 * (self.font == "large")
	if style.highlight then
		h = self.lineHeight[self.font]
		y0 = y - floor(h * 0.08)
		y1 = y0 + h
		gfx.fillRect x-1, y0, x1 - x + 2, y1 - y0, self.highlightBackColor
	end if
	g.print text, x, y, gfx.color, self.font
	if style.underline then
		ty = y + self.underlineOffset[self.font]
		gfx.line x, ty, x1, ty
	end if
	if style.strikethrough then
		ty = y + self.strikeOffset[self.font]
		gfx.line x-1, ty, x1+1, ty
	end if
	if style.bold then gfx.print text, x+1, y-1, gfx.color, self.font
	if style.italic then
		h = self.lineHeight[self.font]
		y0 = y - floor(h * 0.12)
		y1 = y0 + h
		h4 = ceil(h * 0.25)
		img = gfx.getImage(x+2, y0, x1 - x - 2, h4)
		gfx.drawImage img, x, y0
		img = gfx.getImage(x+1, y0+h4, x1 - x - 1, h4)
		gfx.drawImage img, x, y0+h4
		img = gfx.getImage(x, y1-h4, x1 - x - 1, h4)
		gfx.drawImage img, x + 1, y1-h4
	end if
	return x1	
end function

GfxPrinter.print = function(markup, x, y, wrapAt=960, wrapTo=null)
	if wrapTo == null then wrapTo = x
	for styleRun in parse(markup)
		while wrapAt - x < self.width(styleRun.text)
			partialText = self.cutToFit(styleRun, wrapAt - x, x <= wrapTo)
			self.printOneRun styleRun, partialText, x, y
			x = wrapTo
			y = y - self.lineHeight[self.font]
		end while
		x = self.printOneRun(styleRun, styleRun.text, x, y)
	end for
end function

//-----------------------------------------------------------------
// BmfPrinter: prints using BMF fonts.
BmfPrinter = {}
BmfPrinter.highlightBackColor = color.yellow
BmfPrinter.font = null				// required (a BMF font)
BmfPrinter.boldFont = null			// optional
BmfPrinter.boldItalicFont = null	// also optional
BmfPrinter.display = null	// if null, uses current gfx at time of printing

// Cut the text of the given style run to fit within the given width,
// on a word boundary if possible.  Return the left part; update 
// styleRun.text to be the right part.  If we can't fit, then return
// "" unless forceCut is true.
BmfPrinter.cutToFit = function(styleRun, width, forceCut=false)
	charWidth = self.font.lenToFit(styleRun.text, width)
	i = charWidth
	while i > 0
		if i == styleRun.text.len or styleRun.text[i] <= " " then
			result = styleRun.text[:i]
			styleRun.text = styleRun.text[i:].trimLeft
			return result
		end if
		i = i - 1
	end while
	if not forceCut then
		styleRun.text = styleRun.text.trimLeft
		return ""
	end if
	result = styleRun.text[:charWidth]
	styleRun.text = styleRun.text[charWidth:].trimLeft
	return result
end function

// Print a single line of text in a single style, at the given
// x and y coordinates.  Return the new x coordinate after printing.
// If dryRun is true, don't actually print; just calculate.
BmfPrinter.printOneRun = function(style, text, x, y, dryRun=false)
	g = self.display
	if g == null then g = gfx
	font = self.font
	if style.bold and style.italic and self.boldItalicFont then
		font = self.boldItalicFont
	else if style.bold and self.boldFont then
		font = self.boldFont
	else if style.italic and self.italicFont then
		font = self.italicFont
	end if
	
	x1 = x + font.width(text) + 2	// ToDo: figure correct fudge factor
	if dryRun then return x1
	if style.highlight then
		h = self.font.lineHeight
		y0 = y - self.font.sizeUnder
		y1 = y - self.font.sizeOver
		gfx.fillRect x-1, y0, x1 - x + 2, y1 - y0, self.highlightBackColor
	end if
	font.print text, x, y, 1, gfx.color
	if style.underline then
		ty = y - ceil(self.font.sizeUnder/2)
		gfx.line x, ty, x1, ty
	end if
	if style.strikethrough then
		ty = y - floor(self.font.sizeOver * 0.4)
		gfx.line x-1, ty, x1+1, ty
	end if
	if style.bold and not self.boldFont then
		// fake bold by drawing again with a slight offset
		font.print text, x+1, y-1, 1, gfx.color
	end if
	if style.italic and not self.italicFont then
		// Fake italics by pixel-shifting.
		h = self.font.lineHeight
		y0 = y - floor(h * 0.12)
		y1 = y0 + h
		h4 = ceil(h * 0.25)
		img = gfx.getImage(x+2, y0, x1 - x - 2, h4)
		gfx.drawImage img, x, y0
		img = gfx.getImage(x+1, y0+h4, x1 - x - 1, h4)
		gfx.drawImage img, x, y0+h4
		img = gfx.getImage(x, y1-h4, x1 - x - 1, h4)
		gfx.drawImage img, x + 1, y1-h4
	end if
	return x1	
end function

BmfPrinter.print = function(markup, x, y, wrapAt=960, wrapTo=null)
	if wrapTo == null then wrapTo = x
	for styleRun in parse(markup)
		while wrapAt - x < self.font.width(styleRun.text)
			partialText = self.cutToFit(styleRun, wrapAt - x, x <= wrapTo)
			self.printOneRun styleRun, partialText, x, y
			x = wrapTo
			y = y - self.font.lineHeight
		end while
		x = self.printOneRun(styleRun, styleRun.text, x, y)
	end for
end function

BmfPrinter.calcHeight = function(markup, x, y, wrapAt=960, wrapTo=null)
	if wrapTo == null then wrapTo = x
	top = y - self.font.sizeOver
	for styleRun in parse(markup)
		while wrapAt - x < self.font.width(styleRun.text)
			partialText = self.cutToFit(styleRun, wrapAt - x, x <= wrapTo)
			x = wrapTo
			y = y - self.font.lineHeight
		end while
		x = self.printOneRun(styleRun, styleRun.text, x, y, true)
	end for
	bottom = y - self.font.sizeUnder
	return top - bottom
end function


//-----------------------------------------------------------------
runDemo = function
	clear; text.delimiter = char(13)
	text.color = color.silver
	msg1 = "Hello *there* world, this is _italic_, but _*this*_ and *_this_* are both!"
	msg2 = "##Highlight## this, __underline__ that, and ~~strike this out~~."
	msg3 = "This is a ##much## longer message.  _So_ long, in fact, that we will need " +
	"to do *word wrap*, and it's __vital__ that we do this ~~fast~~ correctly. " +
	"Even with _*bold italic*_ text!"
	outer.tp = new TextPrinter
	tp.print msg1
	tp.print msg2
	text.column = 4; tp.print msg3
	gfx.color = color.silver
	outer.gp = new GfxPrinter
	y = 450
	for f in ["small", "normal", "large"]	// ToDo: add "medium" in v1.2
		gp.font = f
		gp.print msg1, 10, y
		gp.print msg2, 10, y - gp.lineHeight[f]
		y = y - 100
	end for
	gp.print msg3, 10, y - 30
	text.row = 1
	print "Press Esc to exit, or any other key for the BMF demo"
	if key.get == char(27) then return
	clear
	ensureImport "bmfFonts"
	outer.bp = new BmfPrinter
	bp.font = bmfFonts.Font.load("/usr/fonts/NotoSans-24.bmf")
	bp.boldFont = bmfFonts.Font.load("/usr/fonts/NotoSansBold-24.bmf")
	bp.italicFont = bmfFonts.Font.load("/usr/fonts/NotoSansItalic-24.bmf")
	bp.boldItalicFont = bmfFonts.Font.load("/usr/fonts/NotoSansBoldItalic-24.bmf")
	bp.print msg3, 100, 500, 400
end function

if locals == globals then runDemo
