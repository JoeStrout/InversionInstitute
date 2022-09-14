// This module adds a "TextField" class, which is a single-line edit field
// drawn in a PixelDisplay using a BMF font.

import "miscUtil"
ensureImport "rect"
ensureImport "bmfFonts"

globals.TextField = {}
TextField.backColor = color.black
TextField.borderColor = color.gray
TextField.textColor = color.white
TextField.selColor = "#5478A7"
TextField.cursorColor = "#CCCCCC"
TextField.bounds = Rect.make(400,300, 160, 50)
TextField.text = ""
TextField.maxLength = 12	// maximum string length we allow
TextField.font = null
if globals.hasIndex("font") then TextField.font = font
TextField.hasFocus = false
TextField.selStart = 0
TextField.selEnd = 0
TextField.offsets = null // list: offests[i] is X position of char index i
TextField.selRect = null // Rect bounds of the current selection
TextField.selAnchor = null	// selection position "anchored" for use with shift-arrow
TextField.mouseWasDown = false
TextField.cursorVisible = false
TextField.cursorStartTime = 0
TextField.byWord = false

TextField.mouseUpTime = 0
TextField.onChange = null	// callback invoked whenever the text changes

instances = []
focusedField = null

// If set, this will be used to keep the drawing within the display bounds
// (it should generally be screen-sized; must be at least big enough to
// contain all fields at their standard position):
scratchGfx = new PixelDisplay

//--------------------------------------------------
// Public methods

TextField.init = function(boundsRect)
	if boundsRect then self.bounds = boundsRect
	self.gfx = gfx
	instances.push self
end function

TextField.close = function
	if self.hasFocus then self.loseFocus
	idx = instances.indexOf(self)
	if idx >= 0 then instances.remove idx
end function

TextField.draw = function
	oldGfx = gfx
	if scratchGfx then globals.gfx = scratchGfx else globals.gfx = self.gfx
	self.bounds.fill gfx, self.backColor
	self.bounds.frame gfx, self.borderColor
	if self.selRect and self.selRect.width > 1 then
		c = self.selColor
		if not self.hasFocus then
			c = color.lerp(self.selColor, self.backColor, 0.5)
		end if
		self.selRect.fill gfx, c
	end if
	if self.text then
		if not self.offsets then self.recomputeOffsets
		x = self.offsets[0]
		y = self.bounds.midY + self.font.sizeOver * 0.4
		self.font.print self.text, x, y, 1, self.textColor
	end if
	if scratchGfx then
		self.gfx.drawImage scratchGfx.getImage(
		  self.bounds.left, self.bounds.bottom, self.bounds.width, self.bounds.height),
		  self.bounds.left, self.bounds.bottom
	end if
	self.cursorVisible = false
	globals.gfx = oldGfx
end function

TextField.select = function(startPos=0, endPos=-1)
	if startPos < 0 then startPos = self.text.len + startPos + 1
	if endPos < 0 then endPos = self.text.len + endPos + 1
	self.selStart = startPos
	self.selEnd = endPos
	self.selAnchor = null
	self.recomputeSelRect
	self.draw
end function

TextField.setText = function(s="", selectAll = false)
	self.text = s
	self.recomputeOffsets
	if selectAll then
		self.select
	else
		self.select -1, -1
	end if
end function

TextField.setSelText = function(s="")
	self.text = self.text[:self.selStart] + s + self.text[self.selEnd:]
	self.text = self.text[:self.maxLength]
	self.selStart = self.selStart + s.len
	if self.selStart > self.text.len then self.selStart = self.text.len
	self.selEnd = self.selStart
	self.recomputeOffsets
	self.recomputeSelRect
	self.draw
	self.onChange
end function	

TextField.handleKey = function(k)
	code = k.code
	ctrl = key.pressed("left ctrl") or key.pressed("right ctrl")
//	text.row = 25; print code + "  ctrl:" + ctrl + "   "
	if k >= " " and code != 127 then
		self.setSelText k
	else if code == 8 then		// backspace
		if self.selStart == self.selEnd then
			if self.selStart > 0 then self.selStart = self.selStart - 1
		end if
		self.setSelText ""		
	else if code == 127 then	// forward delete
		if self.selStart == self.selEnd then
			if self.selEnd <= self.text.len then self.selEnd = self.selEnd + 1
		end if
		self.setSelText ""
	else if code == 19 or (code == 1 and not ctrl) then		// up arrow or Home
		if self.selAnchor == null then self.selAnchor = self.selStart
		self.shiftSelection 0 - self.selAnchor
	else if code == 20 or code == 5 then		// down arrow or End
		if self.selAnchor == null then self.selAnchor = self.selEnd
		self.shiftSelection self.text.len - self.selAnchor
	else if code == 17 then		// left arrow
		self.shiftSelection -1
	else if code == 18 then		// right arrow
		self.shiftSelection 1
	else if code == 1 and ctrl then		// ^A (select all)
		self.select
	else if code == 9 then		// tab
		self.focusNext key.pressed("left shift") or key.pressed("right shift")
	else if code == 25 then		// shift-tab
		self.focusNext true
	else
//		print "Unknown key code: " + code
	end if
end function

TextField.loseFocus = function
	self.hasFocus = false
	self.draw
	if focusedField == self then outer.focusedField = null
end function

TextField.setFocus = function
	if focusedField then focusedField.loseFocus
	self.hasFocus = true
	outer.focusedField = self
	self.draw
end function

TextField.handleMouse = function(firstDown)
	if firstDown then
		if not self.bounds.contains(mouse) then
			// click outside bounds; lose focus
			if self.hasFocus then self.loseFocus
			return
		end if
		
		// ensure we have the focus on mouse-down
		if not self.hasFocus then self.setFocus

		// check for double-click
		self.byWord = false
		if time < self.mouseUpTime + 0.3 then self.byWord = true
	end if
	if not self.hasFocus then return
	
	// find the closest offset to the position clicked
	besti = null
	bestDiff = 0
	for i in self.offsets.indexes
		diff = abs(mouse.x - self.offsets[i])
		if besti == null or diff < bestDiff then
			besti = i
			bestDiff = diff
		end if
	end for

	// move the selection
	shift = key.pressed("left shift") or key.pressed("right shift")
	if shift or not firstDown then
		// with shift, or on subsequent drag: move unanchored point
		if besti < self.selAnchor then
			self.selStart = besti
			self.selEnd = self.selAnchor
		else
			self.selEnd = besti
			self.selStart = self.selAnchor
		end if
	else if firstDown then
		// initial click, without shift: move cursor and anchor
		self.selStart = besti
		self.selEnd = self.selStart
		self.selAnchor = self.selStart
	end if
	
	// if in word mode, then extend to whole words
	if self.byWord then
		while self.selStart > 0 and not self.isWordStart(self.selStart)
			self.selStart = self.selStart - 1
		end while
		while self.selEnd < self.text.len and not self.isWordEnd(self.selEnd)
			self.selEnd = self.selEnd + 1
		end while
	end if	
	
	self.recomputeSelRect
	self.draw
end function

TextField.update = function
	mouseIsDown = mouse.button
	if mouseIsDown then
		if not self.mouseWasDown and (self.bounds.contains(mouse) or self.hasFocus) then self.handleMouse(true)
		if self.mouseWasDown and self.hasFocus then self.handleMouse(false)
	else if self.mouseWasDown then
		self.mouseUpTime = time
	end if
	self.mouseWasDown = mouseIsDown
	
	if not self.hasFocus then return

	if key.available then self.handleKey key.get

	if self.selStart == self.selEnd and self.hasFocus then
		showCursor = (time - self.cursorStartTime) % 1 < 0.7
		if showCursor != self.cursorVisible then self.drawCursor showCursor
	end if
end function

TextField.focusNext = function(orActuallyPrevious=false)
	idx = instances.indexOf(self)
	if orActuallyPrevious then
		idx = (idx + instances.len - 1) % instances.len
	else
		idx = (idx + 1) % instances.len
	end if
	instances[idx].setFocus
end function

TextField.updateAll = function
	for inst in instances
		inst.update
	end for
end function

//--------------------------------------------------
// Internal-use methods

isWordChar = function(c)
	return (c >= "A" and c <= "Z") or
	  (c >= "a" and c <= "z") or
	  (c >= "0" and c <= "9") or
	  c > 127
end function

TextField.isWordStart = function(pos)
	if pos == 0 or pos >= self.text.len then return true
	w = self.text[pos]
	p = self.text[pos-1]
	return isWordChar(w) and not isWordChar(p)
end function

TextField.isWordEnd = function(pos)
	if pos == 0 or pos >= self.text.len then return true
	if pos == self.text.len - 1 then return false
	w = self.text[pos]
	p = self.text[pos-1]
	return not isWordChar(w) and isWordChar(p)
end function

TextField.drawCursor = function(visible)
	self.cursorVisible = visible
	if self.selRect.right > self.bounds.right then return
	if visible then
		self.selRect.fill self.gfx, self.cursorColor
	else
		self.selRect.fill self.gfx, self.backColor
	end if
end function

TextField.nextSelPos = function(selPos, delta, byWord=false)
	selPos = mathUtil.clamp(selPos + delta, 0, self.text.len)
	if byWord == true then
		if delta > 0 then
			while selPos < self.text.len and not self.isWordEnd(selPos)
				selPos = selPos + 1
			end while
		else
			while selPos > 0 and not self.isWordStart(selPos)
				selPos = selPos - 1
			end while
		end if
	end if
	return selPos
end function

// Apply a left (-1) or right (1) arrow to the current selection,
// taking into account whether the shift key is pressed.
TextField.shiftSelection = function(delta, byWord=false)
	shift = key.pressed("left shift") or key.pressed("right shift")
	if shift then
		// with shift key: extend from the anchor
		if self.selStart == self.selEnd then
			self.selAnchor = self.selStart
		end if
		if delta < 0 then
			if self.selAnchor == self.selEnd then
				if self.selStart <= 0 then return
				self.selStart = self.nextSelPos(self.selStart, delta, byWord)
			else
				self.selEnd = self.nextSelPos(self.selEnd, delta, byWord)
			end if
		else
			if self.selAnchor == self.selStart then
				if self.selEnd >= self.text.len then return
				self.selEnd = self.nextSelPos(self.selEnd, delta, byWord)
			else
				self.selStart = self.nextSelPos(self.selStart, delta, byWord)
			end if
		end if
	else if self.selEnd > self.selStart then
		// without shift key, and with an extended selection:
		// go to the start or end of the text
		if delta > 0 then
			self.selStart = self.selEnd
		else
			self.selEnd = self.selStart
		end if
		self.selAnchor = null
	else
		// without shift key or an extended selection:
		// move the cursor
		if self.selStart == 0 and delta < 0 then return
		if self.selStart >= self.text.len and delta > 0 then return
		self.selStart = self.nextSelPos(self.selStart, delta, byWord)

		self.selEnd = self.selStart
		self.selAnchor = null
	end if
	self.recomputeSelRect
	self.draw
end function

// Recompute the X offset of each letter in our text.
TextField.recomputeOffsets = function
	self.offsets = [self.bounds.left + 4]
	if not text then return
	for i in range(1, self.text.len)
		self.offsets.push self.offsets[0] + self.font.width(self.text[:i])
	end for
end function

TextField.recomputeSelRect = function
	if not self.offsets then self.recomputeOffsets
	left = self.offsets[self.selStart]
	right = self.offsets[self.selEnd] + 1
	bottom = self.bounds.midY + self.font.sizeOver * 0.4 - self.font.sizeUnder - 2
	top = self.bounds.midY - self.font.sizeOver * 0.6 + 1
	self.selRect = Rect.make(left, bottom, right - left, top - bottom)
	self.cursorStartTime = time
end function

//--------------------------------------------------
// Demo/Test

demo = function
	clear
	display(6).mode = displayMode.solidColor
	display(6).color = "#000044"
	display(7).mode = displayMode.pixel
	outer.scratchGfx = display(7)
	
	outer.field = new TextField
	field.init
	field.font = bmfFonts.Font.load("/usr/fonts/Georgia-24.bmf")
	field.text = "Hello World"
	field.select 6, -1
	field.draw
	
	outer.field2 = new TextField
	field2.init
	field2.bounds = Rect.make(400,200, 160, 50)
	field2.font = field.font
	field2.text = "Second Field"
	field2.select -1
	field2.draw
	
	field.setFocus

	while not key.pressed("escape")
		field.update
		field2.update
		yield
	end while
	key.clear
end function

if locals == globals then demo