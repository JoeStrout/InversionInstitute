// This module creates a vertically scrollable listbox.
// Used in this project for the list of circuits in your notebook.
// It can draw directly to a PixelDisplay, or it can return a
// transparent Image.

if not globals.hasIndex("importUtil") then import "importUtil"
ensureImport "soda"
ensureImport ["rect", "mathUtil"]


scrollbarImg = file.loadImage("pics/ui/VintageScrollbarV.png")
scrollbarImgTop = scrollbarImg.getImage(0, 33, 12, 26)
scrollbarImgBot = scrollbarImg.getImage(0, 0, 12, 26)

ListRow = {}
ListRow.isSelected = false
ListRow.draw = function(g, x, y, width, height)
	// override me!
	if self.isSelected then c = "#FF00FF" else c = "#FF8888"
	g.drawEllipse x, y, width, height, c
end function
ListRow.edit = function(g, x, y, width, height)
	// override me too!
	print "No row edit function available for " + self
end function

State = {}
State.IDLE = "IDLE"
State.SELECTING = "SELECTING" // (selecting whatever row is under mouse while button down)
State.SCROLLING = "SCROLLING" // (tracking scrollbar with mouse movement)
State.WAITMOUSEUP = "WAITMOUSEUP" // (ignoring all events until button is released)

Listbox = {}
Listbox.bounds = Rect.Make(0, 0, 300, 300)
Listbox.background = "#CCCCCC"  // color or Image to use as background, or null
Listbox.rowHeight = 36
Listbox.scrollbarWidth = 16
Listbox.scroll = 0  // how many pixels our content is currently scrolled up
Listbox.rows = null
Listbox.state = State.IDLE
Listbox.selectedIdx = null

Listbox.selectedRow = function
	if self.selectedIdx < 0 or self.selectedIdx >= self.rows.len then self.selectedIdx = null
	if self.selectedIdx == null then return null
	return self.rows[self.selectedIdx]
end function

Listbox.Make = function(left=0, bottom=0, width=300, height=300)
	noob = new Listbox
	noob.bounds = Rect.Make(left, bottom, width, height)
	noob.rows = []
	return noob
end function

Listbox.contentHeight = function
	return self.rowHeight * self.rows.len
end function

Listbox.maxScroll = function
	maxScroll = self.contentHeight - self.bounds.height
	if maxScroll < 0 then maxScroll = 0
	return maxScroll
end function

Listbox.drawScrollbar = function(g)
	w = scrollbarImgTop.width; h = scrollbarImgTop.height
	g.drawImage scrollbarImgTop, self.bounds.right - w, self.bounds.top - h
	g.drawImage scrollbarImgBot, self.bounds.right - w, self.bounds.bottom
	x = self.bounds.right - floor(w/2)
	g.line x, self.bounds.top - h, x, self.bounds.bottom + h, color.black, 2
	trackHeight = (self.bounds.top - h) - (self.bounds.bottom + h)
	thumbHeight = round(trackHeight * (self.bounds.height / self.contentHeight))
	thumbHeight = mathUtil.clamp(thumbHeight, 6, trackHeight)
	if self.maxScroll == 0 then
		thumbOffset = 0
		thumbWidth = 4
	else
		thumbOffset = (trackHeight - thumbHeight) * (self.scroll / self.maxScroll)
		thumbWidth = 6
	end if
	y = self.bounds.top - h - thumbOffset
	g.line x, y, x, y-thumbHeight, color.black, thumbWidth
	hw = thumbWidth / 2
	g.fillEllipse x-hw, y-hw, thumbWidth, thumbWidth, color.black
	g.fillEllipse x-hw, y-thumbHeight-hw, thumbWidth, thumbWidth, color.black

	self.thumb = Rect.Make(self.bounds.right - self.scrollbarWidth,
		y - thumbHeight, self.scrollbarWidth, thumbHeight)
end function

Listbox.moveScrollThumb = function(pixels)
	if self.maxScroll == 0 then return false
	h = scrollbarImgTop.height
	trackHeight = (self.bounds.top - h) - (self.bounds.bottom + h)
	thumbHeight = self.thumb.height
	thumbOffset = (trackHeight - thumbHeight) * (self.scroll / self.maxScroll)
	newOffset = thumbOffset + pixels
	newScroll = newOffset / (trackHeight - thumbHeight) * self.maxScroll
	newScroll = mathUtil.clamp(newScroll, 0, self.maxScroll)
	if newScroll == self.scroll then return false
	self.scroll = newScroll
	print "new scroll: " + newScroll
	return true
end function	

Listbox.scrollIntoView = function(row=null)
	if row == null then row = self.selectedIdx
	if row == null then return
	print "scrollIntoView " + row
	rowTop = row * self.rowHeight
	rowBottom = rowTop + self.rowHeight
	if rowTop < self.scroll then
		self.scroll = row * self.rowHeight
		print "scroll up to " + self.scroll
		return true
	else if rowBottom > self.scroll + self.bounds.height then
		self.scroll = rowBottom - self.bounds.height
		print "scroll down to " + self.scroll
		if self.scroll < 0 then self.scroll = 0
		return true
	else
		print "No scroll needed"
		print "scroll: " + self.scroll
		print "row * rowHeight: " + row * self.rowHeight
		print "(row + 1) * self.rowHeight: " + ((row + 1) * self.rowHeight)
		print "self.scroll + self.bounds.height: " + (self.scroll + self.bounds.height)
	end if
	return false
end function

Listbox.draw = function(g)
	if g == null then g = gfx

	g.setClip self.bounds.left, self.bounds.bottom, self.bounds.width, self.bounds.height
	if self.background isa string then
		self.bounds.fill g, self.background
	else if self.background isa Image then
		g.drawImage self.background,
		  self.bounds.left, self.bounds.bottom, self.bounds.width, self.bounds.height
	end if
	
	// draw rows
	rowTop = self.bounds.top + self.scroll
	rowWidth = self.bounds.width - self.scrollbarWidth
	for row in self.rows
		if rowTop < self.bounds.bottom then break
		rowBottom = rowTop - self.rowHeight
		if rowBottom < self.bounds.top then
			row.draw g, self.bounds.left, rowBottom, rowWidth, self.rowHeight
		end if
		rowTop = rowBottom
	end for
	
	self.drawScrollbar g
	
	// outline (for debugging)
	// self.bounds.frame g, "#888888"
	
	g.clearClip
end function

Listbox.rowAtY = function(y)
	row = floor((self.bounds.top + self.scroll - y) / self.rowHeight)
	if row < 0 or row >= self.rows.len then return null
	return row
end function

Listbox.selectRow = function(rowIdx)
	for i in self.rows.indexes
		self.rows[i].isSelected = (i == rowIdx)
	end for
	if rowIdx < 0 or rowIdx >= self.rows.len then rowIdx = null
	self.selectedIdx = rowIdx
end function

Listbox.editRow = function(rowIdx=null, g)
	if g == null then g = gfx
	if rowIdx == null then rowIdx = self.selectedIdx
	if rowIdx == null then return
	rowTop = self.bounds.top + self.scroll - rowIdx * self.rowHeight
	rowBottom = rowTop - self.rowHeight
	rowWidth = self.bounds.width - self.scrollbarWidth
	self.rows[rowIdx].edit gfx, self.bounds.left, rowBottom, rowWidth, self.rowHeight
end function

Listbox.addToScroll = function(delta)
	newScroll = mathUtil.clamp(self.scroll + delta, 0, self.maxScroll)
	if newScroll == self.scroll then return false
	self.scroll = newScroll
	return true
end function	

// Process mouse events, and return true if we need a redraw.
Listbox.handleMouse = function
	if not self.bounds.contains(mouse) and self.state == State.IDLE then return

	if self.state == State.IDLE then
		scrollWheel = key.axis("Mouse ScrollWheel")
		if scrollWheel then return self.addToScroll(-scrollWheel * 12)
		
		if mouse.button then
			if mouse.x > self.thumb.left then
				// click in the scrollbar
				pageStep = self.bounds.height
				if mouse.y > self.bounds.top - 25 then
					self.state = State.WAITMOUSEUP
					return self.addToScroll(-self.rowHeight)
				else if mouse.y < self.bounds.bottom + 25 then
					self.state = State.WAITMOUSEUP
					return self.addToScroll(self.rowHeight)
				else if mouse.y > self.thumb.top then
					self.state = State.WAITMOUSEUP
					return self.addToScroll(-pageStep)
				else if mouse.y < self.thumb.bottom then
					self.state = State.WAITMOUSEUP
					return self.addToScroll(pageStep)
				end if
				self.lastMouseY = mouse.y
				self.state = State.SCROLLING
			else
				// click in the content (rows)
				row = self.rowAtY(mouse.y)
				if row != null then
					self.selectRow row
					self.state = State.SELECTING
					return true
				end if
			end if
		end if
	
	else if self.state == State.WAITMOUSEUP then
		if not mouse.button then self.state = State.IDLE
	
	else if self.state == State.SCROLLING then
		if mouse.button then
			delta = mouse.y - self.lastMouseY
			self.lastMouseY = mouse.y
			return self.moveScrollThumb(-delta)
		else
			self.state = State.IDLE
		end if

	else if self.state == State.SELECTING then
		if mouse.button then
			row = self.rowAtY(mouse.y)
			if row != null and row != self.selectedIdx then
				self.selectRow row
				return true
			end if
		else
			self.state = State.IDLE
		end if
	end if
	return false
end function


test = function
	clear
	gfx.clear color.green
	lb = Listbox.Make(400, 200)
	for i in range(30)
		lb.rows.push new ListRow
	end for
	lb.draw gfx

	while true
		yield
		if lb.handleMouse then lb.draw gfx
		if key.pressed("escape") then break
	end while	
end function


if locals == globals then test

