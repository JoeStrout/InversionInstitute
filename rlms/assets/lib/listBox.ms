// This module creates a vertically scrollable listbox.
// Used in this project for the list of circuits in your notebook.
// It can draw directly to a PixelDisplay, or it can return a
// transparent Image.

if not globals.hasIndex("importUtil") then import "importUtil"
ensureImport "soda"
ensureImport "rect"

ListRow = {}
ListRow.isSelected = false
ListRow.draw = function(g, x, y, width, height)
	// override me!
	if self.isSelected then c = "#FF00FF" else c = "#FF8888"
	g.drawEllipse x, y, width, height, c
end function

Listbox = {}
Listbox.bounds = Rect.Make(0, 0, 300, 300)
Listbox.rowHeight = 36
Listbox.scrollbarWidth = 16
Listbox.scroll = 0  // how many pixels our content is currently scrolled up
Listbox.rows = null

Listbox.Make = function(left=0, bottom=0, width=300, height=300)
	noob = new Listbox
	noob.bounds = Rect.Make(left, bottom, width, height)
	noob.rows = []
	return noob
end function

Listbox.contentHeight = function
	return self.rowHeight * self.rows.len
end function

Listbox.draw = function(g)
	if g == null then g = gfx
	rowTop = self.bounds.top + self.scroll
	rowWidth = self.bounds.width - self.scrollbarWidth
	for row in self.rows
		print "considering row at " + rowTop
		if rowTop < self.bounds.bottom then break
		rowBottom = rowTop - self.rowHeight
		if rowBottom < self.bounds.top then
			print "drawing row at " + self.bounds.left + ", " + rowTop
			row.draw g, self.bounds.left, rowTop, rowWidth, self.rowHeight
		end if
		rowTop = rowBottom
	end for
end function



test = function
	clear
	gfx.clear color.green
	lb = Listbox.Make(400, 200)
	for i in range(12)
		lb.rows.push new ListRow
	end for
	lb.draw gfx
	while true
		yield
		if key.pressed("escape") then break
	end while	
end function


if locals == globals then test

