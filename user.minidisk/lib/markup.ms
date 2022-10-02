// This module provides a simple Markup interpreter.  It supports the
// following syntax:
//
//   `code`         -- code (monospaced), with no further interpretation within
//   *bold*         -- bold
//   _italic_       -- italic
//   __underline__  -- underlined
//   ~~struck~~     -- strikethrough
//   ##highlight##  -- highlighted

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

// Parser class: takes a string containing markup, and returns it as 
// a list of StyleRuns.
Parser = {}
Parser.parse = function(markup)
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
			startIndex = i + 1
			curStyle.code = not curStyle.code
		else if c == "*" then
			if startIndex < i then
				result.push StyleRun.make(markup[startIndex:i], curStyle)
			end if
			startIndex = i + 1
			curStyle.bold = not curStyle.bold
		else if c == "_" then
			if startIndex < i then
				result.push StyleRun.make(markup[startIndex:i], curStyle)
			end if
			startIndex = i + 1
			curStyle.italic = not curStyle.italic
		else if c == "__" then
			if startIndex < i then
				result.push StyleRun.make(markup[startIndex:i], curStyle)
			end if
			startIndex = i + 2
			curStyle.underline = not curStyle.underline
		else if c == "~~" then
			if startIndex < i then
				result.push StyleRun.make(markup[startIndex:i], curStyle)
			end if
			startIndex = i + 2
			curStyle.strikethrough = not curStyle.strikethrough
		else if c == "##" then
			if startIndex < i then
				result.push StyleRun.make(markup[startIndex:i], curStyle)
			end if
			startIndex = i + 2
			curStyle.highlight = not curStyle.highlight
		end if
	end while
	if startIndex < markup.len then
		result.push StyleRun.make(markup[startIndex:], curStyle)
	end if
	return result
end function

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

TextPrinter.print = function(markup, endDelimiter=null)
	if endDelimiter == null then endDelimiter = char(13)
	oldDelim = text.delimiter
	text.delimiter = ""
	for styleRun in Parser.parse(markup)
		self.applyStyle styleRun
		text.print styleRun.text
		self.restore
	end for
	print endDelimiter
	text.delimiter = oldDelim
end function
	

runUnitTests = function
	p = new Parser
	//pprint p.parse("Hello *there* world, this is _italic_, but _*this*_ and *_this_* are both!")
	print
	//pprint p.parse("5\*3 is five\three")
	//pprint p.parse("##Highlight## this, __underline__ that, and ~~strike this out~~.")
	tp = new TextPrinter
	tp.print "Hello *there* world, this is _italic_, but _*this*_ and *_this_* are both!"
	tp.print "##Highlight## this, __underline__ that, and ~~strike this out~~."
end function

if locals == globals then runUnitTests
