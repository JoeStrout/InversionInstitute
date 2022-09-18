// This module creates a list of free-play circuit files, as seen
// in a "Save As" dialog or on the main Free Play loading screen.
// The list can scroll, the user can select any file by clicking
// on it, and we can automatically scroll any file into view by name.
//
// All drawing is done in the global `gfx` layer.

import "miscUtil"
ensureImport "drawing"
ensureImport "gameData"
ensureImport "rect"
ensureImport "mathUtil"

// constants
bgColor = "#444444"
highlightColor = "#4444CC"
textColor = color.white
width = 300
rowHeight = 68

selectedRow = null
onSelChange = null		// callback for when selectedRow changes

// Entry class (we keep one instance for each circuit file in the list)
Entry = {}
Entry.filename = ""

Entry.circuitPic = null
Entry.image = null
Entry.highlightedImage = null
Entry.highlighted = false

Entry.path = function
	return file.child(gameData.freePlayFolder, self.filename)
end function

Entry.ensureImage = function
	if self.highlighted then
		if self.highlightedImage then return
	else
		if self.image then return
	end if
	if self.highlighted then c = highlightColor else c = bgColor
	scratch.clear c, width, rowHeight
	if not self.circuitPic then self.circuitPic = file.loadImage(self.path)
	// For now we are going to assume all circuits are 80x64.
	// ToDo: handle other sizes by shrinking circuitPic down as needed.
	scratch.drawImage self.circuitPic, 8, rowHeight/2 - self.circuitPic.height/2

	oldg = gfx; globals.gfx = scratch
	font.print self.filename - ".png", 96, rowHeight/2 - font.lineHeight*0.35, 1, textColor
	globals.gfx = oldg

	p = scratch.getImage
	if self.highlighted then self.highlightedImage = p else self.image = p
end function

// Draw this entry into gfx with its top at the given top,
// but limited to the given bounds.
Entry.drawInBounds = function(bounds, top)
	bottom = top - rowHeight
	if top < bounds.bottom or bottom > bounds.top then return	// entirely out of bounds!
	self.ensureImage
	if self.highlighted then img = self.highlightedImage else img = self.image
	if top > bounds.top then
		// cut off on top
		d = top - bounds.top
		gfx.drawImage img, bounds.left, bottom, width, img.height-d,
			0, 0, width, img.height-d
	else if bottom < bounds.bottom then
		// cut off on bottom
		d = bounds.bottom - bottom
		gfx.drawImage img, bounds.left, bounds.bottom, width, img.height-d,
			0, d, width, img.height-d
	else
		// entirely in bounds
		gfx.drawImage img, bounds.left, bottom	
	end if
end function

prepare = function
	outer.scratch = new PixelDisplay
	outer.entries = []
	for f in file.children(gameData.freePlayFolder)
		if f.len < 4 or f[-4:] != ".png" then continue
		entry = new Entry
		entry.filename = f
		entries.push entry
	end for
	outer.scroll = 0		// how much our list is scrolled up
	outer.mouseWasDown = mouse.button
	outer.selectedRow = null
end function

draw = function(bounds = null)
	if bounds then
		outer.bounds = bounds
	else
		bounds = outer.bounds
	end if
	outer.maxScroll = entries.len * rowHeight - bounds.height
	y = bounds.top + scroll
	for entry in entries
		entry.drawInBounds bounds, y
		y = y - rowHeight
	end for
end function

highlightRow = function(rowIndex)
	// unhighlight the previous row, and highlight this one
	if selectedRow != null then
		entries[selectedRow].highlighted = false
	end if

	if rowIndex != null then
		outer.selectedRow = rowIndex
		entries[selectedRow].highlighted = true
	
		// scroll it into view
		rowTop = bounds.top + scroll - rowHeight * rowIndex
		rowBottom = rowTop - rowHeight
		if rowTop > bounds.top then
			outer.scroll = scroll + bounds.top - rowTop
		else if rowBottom < bounds.bottom then
			outer.scroll = scroll + bounds.bottom - rowBottom
		end if
	end if

	// redraw and invoke event
	outer.selectedRow = rowIndex
	draw
	onSelChange
end function

rowForName = function(filename)
	if filename.len < 4 or filename[-4:] != ".png" then filename = filename + ".png"
	for i in entries.indexes
		if entries[i].filename == filename then return i
	end for
	return null
end function
	
highlightByName = function(filename)
	highlightRow rowForName(filename)
end function	

handleClick = function
	row = floor((bounds.top + scroll - mouse.y) / rowHeight)
	if row < 0 or row >= entries.len then return
	highlightRow row
end function

doEvents = function
	if not bounds.contains(mouse) then return
	dscroll = -round(key.axis("Mouse ScrollWheel")*25)
	if dscroll then
		outer.scroll = mathUtil.clamp(outer.scroll + dscroll, 0, maxScroll)
		draw
	end if
	if mouse.button and not mouseWasDown then handleClick
	outer.mouseWasDown = mouse.button
end function

doTest = function
	clear
	prepare
	r = Rect.make(200, 200, width, 400)
	r.grow(2,2).frame gfx, color.blue, 3
	draw r
	while true
		yield
		doEvents
	end while
end function

if locals == globals then doTest

