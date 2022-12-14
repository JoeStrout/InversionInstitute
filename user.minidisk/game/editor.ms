// Circuit editor.  Based on /sys/demo/fatbits
// (but heavily modified).

import "miscUtil"
ensureImport "listUtil"
ensureImport "textUtil"
ensureImport "mathUtil"
ensureImport "mapUtil"
ensureImport "qa"
ensureImport "rect"
ensureImport "displays"
ensureImport "drawing"
ensureImport "objectives"
ensureImport "pixelLogicSim"; sim = pixelLogicSim
ensureImport "music"
ensureImport "gameData"

modeHelp = {}

// Constants and global state variables
kModeDraw = "DRAW"
modeHelp[kModeDraw] = "Click or drag to draw or erase."
kModeErase = "ERASE"
modeHelp[kModeErase] = "Click or drag to erase a circular area."
kModeSelect = "SELECT"
modeHelp[kModeSelect] = "Click and drag to select an area, then: [X] cut, [C] copy, [V] paste."
kModeMove = "MOVE"
modeHelp[kModeMove] = "Click and drag to reposition the ink within the canvas."
kModeFill = "FILL"
modeHelp[kModeFill] = "Click to fill with the selected color."
kModeEyedrop = "EYEDROP"
modeHelp[kModeEyedrop] = "Click to switch to the clicked color.  (Shortcut: hold Alt.)"
kModePaint = "PAINT"
modeHelp[kModePaint] = "Click or drag to paint a circular area."
kModeDrawRect = "DRAWRECT"
modeHelp[kModeDrawRect] = "Click and drag to draw a rectangular outline."
kModeFillRect = "FILLRECT"
modeHelp[kModeFillRect] = "Click and drag to draw a filled rectangle."
kModeDrawEllipse = "DRAWELLIPSE"
modeHelp[kModeDrawEllipse] = "Click and drag to draw a round outline."
kModeFillEllipse = "FILLELLIPSE"
modeHelp[kModeFillEllipse] = "Click and drag to draw a filled ellipse."
kModeLine = "DRAWLINE"
modeHelp[kModeLine] = "Click and drag to draw a straight line; [Shift] make crossings."
kModePasting = "PASTING"
modeHelp[kModePasting] = "Click to drop; [R] rotate, [F] flip, [T] transparent."

foreColor = "#FFFFFFFF"		// current painting foreground and background colors
backColor = "#000000FF"
spriteBoundsColor = color.silver
ps = 9	// "pixel size" (forgive the short name, but we use this a lot)
if not globals.hasIndex("circuitPic") or not circuitPic isa Image then
	circuitPic = Image.create(80, 64, color.black)
end if
picW = circuitPic.width
picH = circuitPic.height
marginPic = circuitPic.getImage
resourceDir = "/sys/data/fatbits/"
helpFont = objectives.smallFont
selectionAnchor = null
picAtStart = null

testSprites = []		// UI sprites needed only in simulation mode
editSprites = []	// UI sprites needed only in edit mode
alwaysSprites = []	// UI sprites needed always

if not globals.hasIndex("context") then
	context = {}
	context.title = "Free Play"
	context.filename = ""
	context.update = null		// (called every time through main loop)
end if
context.objectivesDrawn = false
context.isFreePlay = not context.get("number")
if not context.hasIndex("margin") then context.margin = Rect.make(0, 0, picW, picH)
if not globals.hasIndex("clip") then clip = null

// Prepare displays
displays.setupEditorSim picW, picH, ps
spriteDisp = displays.edSprite
fatbits = displays.edFatbits
backdrop = displays.edBackdrop
bgColor = "#888888"
objectives.bgColor = bgColor
scratch = displays.edScratch

// load brush sprites
brushImages = [null]
for i in range(1, 12)
	brushImages.push file.loadImage(resourceDir + "Brush-" + i + ".png")
end for
brushSprite = new Sprite
brushSprite.image = brushImages[5]
brushSprite.tint = "#00FFFF88"
editSprites.push brushSprite

brushRowWidths = [null, [1], [2,2], [3,3,3], [2,4,4,2], [3,5,5,5,3], [4,6,6,6,6,4],
  [3,5,7,7,7,5,3], [4,6,8,8,8,8,6,4], [5,7,9,9,9,9,9,7,5], [4,8,8,10,10,10,10,8,8,4],
  [5,7,9,11,11,11,11,11,9,7,5], [4,8,10,10,12,12,12,12,10,10,8,4]]


// Helper methods we probably should have in a utils module somewhere
Sprite.addBounds = function(inset=0)
	qa.assert self.image != null, "Sprite image is null"
	self.localBounds = new Bounds
	self.localBounds.width = self.image.width - inset*2
	self.localBounds.height = self.image.height - inset*2
end function

pointsOnLine = function(pA, pB, manhattanJoin=true)
	if pA == pB then return [pA]
	dx = pB.x - pA.x; dy = pB.y - pA.y
	result = []
	if abs(dx) > abs(dy) then
		// horizontal-ish line
		y = pA.y; lastY = y
		ystep = dy / abs(dx)
		for x in range(pA.x, pB.x)
			curY = round(y + 0.01)
			if manhattanJoin and curY != lastY then result.push {"x":x, "y":lastY}
			result.push {"x":x, "y":curY}
			lastY = curY
			y = y + ystep
		end for
	else
		// vertical-ish line
		x = pA.x; lastX = x
		xstep = dx / abs(dy)
		for y in range(pA.y, pB.y)
			curX = round(x + 0.01)
			if manhattanJoin and curX != lastX then result.push {"x":lastX, "y":y}
			result.push {"x":curX, "y":y}
			lastX = curX
			x = x + xstep
		end for
	end if
	return result
end function

//print pointsOnLine({"x":20, "y":0}, {"x":10, "y":5}); exit

saveToDisk = function
	if not testMode then globals.circuitPic = fatbits.getImage(0, 0, picW, picH)
	path = file.child(gameData.freePlayFolder, context.filename)
	err = file.saveImage(path, circuitPic)
	if not err then
//		dlog = textUtil.Dialog.make("Saved """ + context.filename + """",
//		   self.path + char(13) + self.image.width + " x " + self.image.height + " pixels")
//		dlog.okBtn.visible = false
//		dlog.show 2
	else
		dlog = textUtil.Dialog.make("Unable to Save File", err)
		dlog.show
	end if
end function

doSaveAs = function
	ensureImport "saveFileDialog"
	saveFileDialog.gfxDisplay = gfx
	saveFileDialog.spriteDisplay = displays.edSprite
	saveFileDialog.folder = gameData.freePlayFolder
	newName = saveFileDialog.present
	if newName then
		if newName.len < 4 or newName[-4:] != ".png" then newName = newName + ".png"
		context.filename = newName
		saveToDisk
	end if
	prepareScreen
end function

doSave = function
	if not context.filename then
		doSaveAs
	else
		saveToDisk
	end if
end function

updatePaintScroll = function
	// ToDo: redo scroll support, using scrollbars or a grabby-hand tool.
	// For now, just hard-code it:
	fatbits.scrollX = -paintArea.left
	fatbits.scrollY = -paintArea.bottom
end function

restoreMargins = function
	x0 = context.margin.left
	x1 = context.margin.right
	w = marginPic.width
	y0 = context.margin.bottom
	y1 = context.margin.top
	h = marginPic.height
	if x0 > 0 then fatbits.drawImage marginPic, 0, 0, x0, h, 0, 0, x0, h
	if x1 < w then fatbits.drawImage marginPic, x1, 0, w-x1, h, x1, 0, w-x1, h
	if y0 > 0 then fatbits.drawImage marginPic, x0, 0, x1-x0, y0, x0, 0, x1-x0, y0
	if y1 < h then fatbits.drawImage marginPic, x0, y1, x1-x0, h-y1, x0, y1, x1-x0, h-y1
end function

//---------------------------------------------------------------------
// Buttons
Button = {}
Button.btnDownImg = file.loadImage(resourceDir + "toolButtonDown.png")
Button.btnUpImg = file.loadImage(resourceDir + "toolButtonUp.png")
Button.instances = []
Button.toggles = false
Button.isDown = false	// (for toggle buttons, which can be up or down)
Button.iconUpTint = "#CCCCCC"
Button.iconDownTint = color.white
Button.iconPressedTint = color.white

Button.init = function(imageName, left, top, forEditor=true)
	self.bgSprite = new Sprite
	self.bgSprite.image = Tool.btnUpImg
	self.bgSprite.x = left + Tool.btnUpImg.width/2
	self.bgSprite.y = 640 - top - Tool.btnUpImg.height/2
	
	self.iconSprite = new Sprite
	self.iconSprite.image = file.loadImage(resourceDir + imageName + ".png")
	self.iconSprite.x = self.bgSprite.x
	self.iconSprite.y = self.bgSprite.y
	if forEditor then
		editSprites.push self.bgSprite
		editSprites.push self.iconSprite
	else
		testSprites.push self.bgSprite
		testSprites.push self.iconSprite
	end if
	
	self.bgSprite.addBounds
	
	Button.instances.push self
end function

Button.update = function(pressed=false)
	if pressed then
		self.bgSprite.image = Tool.btnDownImg
		self.bgSprite.tint = "#666666"
		self.iconSprite.tint = self.iconPressedTint
	else if self.isDown then
		self.bgSprite.image = Tool.btnDownImg
		self.bgSprite.tint = color.white
		self.iconSprite.tint = self.iconDownTint
	else
		self.bgSprite.image = Tool.btnUpImg
		self.bgSprite.tint = color.white
		self.iconSprite.tint = self.iconUpTint
	end if
end function

Button.make = function(imageName, left, top, toggles=false)
	btn = new Button
	btn.init imageName, left, top
	btn.toggles = toggles
	return btn
end function

Button.hide = function
	// hacky, but it works:
	self.bgSprite.y = self.bgSprite.y + 10000
	self.iconSprite.y = self.iconSprite.y + 10000
end function
Button.unhide = function
	self.bgSprite.y = self.bgSprite.y % 10000
	self.iconSprite.y = self.iconSprite.y % 10000
end function

Button.handleClick = function
	if self.toggles then
		self.isDown = not self.isDown
	end if
end function

Button.checkEvents = function
	if mouse.button and self.bgSprite.contains(mouse) then
		// track mouse until released
		while mouse.button
			self.update self.bgSprite.contains(mouse)
			yield
		end while
		if self.bgSprite.contains(mouse) then self.handleClick
		self.update
	end if
end function


//---------------------------------------------------------------------
// Tools
Tool = new Button
Tool.mode = null
Tool.instances = []
Tool.init = function(name, left, top, mode)
	super.init "tool" + name, left, top	
	self.mode = mode
	Tool.instances.push self
end function

Tool.make = function(name, left, top, mode)
	tool = new Tool
	tool.init name, left, top, mode
	return tool
end function

Tool.isDown = function
	return mode == self.mode
end function

// if option key is pressed, switch temporarily to eyedrop mode,
// and use this to remember what to switch back to:
Tool.optKeySwitchedFrom = null

Tool.checkEvents = function
	optKeyIsDown = key.pressed("left alt") or key.pressed("right alt")
	if optKeyIsDown then
		if self.mode == kModeEyedrop and mode != self.mode then
			Tool.optKeySwitchedFrom = mode
			setMode self.mode
		end if
	else if Tool.optKeySwitchedFrom == self.mode then
		Tool.optKeySwitchedFrom = null
		setMode self.mode
	end if
	
	super.checkEvents
end function

Tool.handleClick = function
	setMode self.mode
end function

modesWithSize = [kModeErase, kModePaint]
setMode = function(newMode)
	globals.mode = newMode
	globals.drawErases = false
	deselect
	for tool in Tool.instances
		tool.update
	end for
	drawHelp modeHelp.get(mode)
end function

//---------------------------------------------------------------------
// screen layout
paintArea = Rect.make(10, 24, 720, 576)
prepareScreen = function
	gfx.clear bgColor, 960+10, 640+10
	gfx.scrollX = 5; gfx.scrollY = 5
	area = paintArea.offset(gfx.scrollX, gfx.scrollY)
	area.fill gfx, color.clear
	area.grow(1,1).frame gfx, color.black, 4, -4
	backdrop.clear color.black
	drawGrid
//	gfx.print "press ? for help", 955 - 16*9, 640-18, color.silver, "small"
	if not context.isFreePlay then
		font.print "Ch." + context.number + ": " + context.title, 10, 642 + font.sizeOver
	else
		s = context.title
		if context.filename then s = s + ": " + (context.filename - ".png")
		font.print s, 10, 642 + font.sizeOver
	end if
	objectives.area = Rect.make(750,10, 208,410)
	outer.helpArea = Rect.make(paintArea.left, 0, paintArea.right, paintArea.bottom-2)
end function

drawGrid = function
	// Select current image
	img = circuitPic
//	// Calculate backdrop rectangle
//	if img.width >= 80 then maxWidth = 80 else maxWidth = img.width
//	if img.height >= 64 then maxHeight = 64 else maxHeight = img.height
//	backdropRect = Rect.make(
//	    paintArea.midX - (maxWidth / 2)*ps,
//	    paintArea.midY - (maxHeight / 2)*ps,
//	    maxWidth * ps,
//	    maxHeight * ps).offset(gfx.scrollX, gfx.scrollY)
//	// Fill backdrop area
//	backdropRect.fill backdrop, "#FF00FF"//backdrop.color

	// Draw lines for individual "fat" pixels
	gfx.color = "#88888866"
	area = paintArea.offset(gfx.scrollX, gfx.scrollY)
	for i in range(1, area.width/ps)
		if i % 8 == 0 then continue
		x = area.left + i*ps
		gfx.line x, area.top, x, area.bottom
		if i <= 64 then
			y = area.bottom + i*ps
			gfx.line area.left, y, area.right, y
		end if
	end for
	// Draw 8x8 cell separators
	gfx.color = "#777777AA"
	for i in range(0, 80, 8)
		x = area.left + i*ps
		gfx.line x, area.top, x, area.bottom
		if i <= 64 then
			y = area.bottom + i*ps
			gfx.line area.left, y, area.right, y
		end if
	end for
	// Draw margin (edit area) boundary
	gfx.color = "#AAAAFF"
	b = context.margin
	gfx.drawRect area.left + b.left*ps, area.bottom + b.bottom*ps, b.width*ps, b.height*ps
end  function

drawHelp = function(helpStr)
	helpArea.fill gfx, bgColor
	helpFont.printCentered helpStr, helpArea.midX, helpArea.midY, 1, color.silver
end function

makeTools = function
	tools = [
	["Pencil", kModeDraw], ["Erase", kModeErase], ["Move", kModeMove], ["Select", kModeSelect],
	["Brush", kModePaint], ["Fill", kModeFill],  ["Eyedropper", kModeEyedrop], ["Line", kModeLine], 
	["DrawRect", kModeDrawRect], ["DrawEllipse", kModeDrawEllipse], 
	["FillRect", kModeFillRect], ["FillEllipse", kModeFillEllipse]]
	for i in tools.indexes
		t = tools[i]
		if t[0] == null then continue
		Tool.make t[0], 770 + 40*(i%4), 40 + 40*floor(i/4), t[1]
	end for
end function
makeTools

// Find the painting location at the given screen location.
paintPixelAtXY = function(pos)
	result = {}
	result.x = floor((pos.x + fatbits.scrollX) / ps)
	result.y = floor((pos.y + fatbits.scrollY) / ps)
	return result
end function

// Find the X and Y screen locations for a given painting location.
// (Inverse of paintPixelAtXY, above.)  This returns the CENTER of
// the given fat pixel.
xAtPaintPixel = function(pp); return (pp.x + 0.5) * ps - fatbits.scrollX; end function
yAtPaintPixel = function(pp); return (pp.y + 0.5) * ps - fatbits.scrollY; end function

// Set one pixel in our painting to a specific color.
setPaintPixel = function(pos, c="#000000")
	fatbits.setPixel pos.x, pos.y, c
end function

// Get all the pixels affected by a brush (of brushSize) at the given position.
affectedPixels = function(pp)
	if brushSize == 1 then return [pp]
	widths = brushRowWidths[brushSize]
	result = []
	for i in widths.indexes
		w = widths[i]
		y = pp.y - floor(brushSize/2) + i
		for x in range(pp.x - floor(w/2), pp.x + floor(w/2) - 1 + brushSize%2)
			result.push {"x":x, "y":y}
		end for
	end for
	return result
end function

//--------------------------------------------------------------------------------
// CLIPBOARD HELPER FUNCTIONS
selection = null

drawSelection = function
	if selection == null then
		drawGrid
	else
		if time % 1 > 0.9 then gfx.color = color.black else gfx.color = "#FF00FF"
		left = xAtPaintPixel({"x":selection.left}) - floor(ps/2)
		botm = yAtPaintPixel({"y":selection.bottom}) - floor(ps/2)
		gfx.drawRect left + gfx.scrollX, botm + gfx.scrollY, selection.width * ps + 1, selection.height * ps + 1
	end if
end function

deselect = function
	if selection == null then return
	globals.selection = null
	drawGrid
end function

grabSelection = function(andClear = false)
	if selection == null then return null
	result = fatbits.getImage(selection.left, selection.bottom, selection.width, selection.height)
	if andClear then selection.fill fatbits, backColor
	return result
end function

copy = function
	if selection == null then return
	globals.clip = grabSelection
	drawGrid
end function

deleteSelection = function
	if mode == kModePasting then
		fatbits.fillRect 0, 0, picW+1, picH+1, color.black
		fatbits.drawImage picAtStart, 0, 0
		setMode kModeSelect
	else if selection != null then
		selection.fill fatbits, backColor
		restoreMargins
		deselect
	end if
end function

paste = function
	if not globals.hasIndex("clip") or clip == null then
		print char(7) // Beep!
		return
	end if
	globals.picAtStart = fatbits.getImage(0, 0, picW, picH)
	globals.mode = kModePasting
	globals.pasted = clip
	globals.clipMouseOffset = {"x": floor(clip.width/2), "y": floor(clip.height/2)}
	drawHelp modeHelp[kModePasting]
end function

updatePaste = function(pp)
	fatbits.fillRect 0, 0, picW+1, picH+1, color.black
	fatbits.drawImage picAtStart, 0, 0
	fatbits.drawImage pasted, pp.x - clipMouseOffset.x, pp.y - clipMouseOffset.y
	restoreMargins
end function

flipClip = function
	img = null
	if mode == kModePasting then img = pasted
	if mode == kModeSelect then img = grabSelection		
	if img == null then return
	
	if key.pressed("left shift") or key.pressed("right shift") then
		// flip vertically
		xrange = range(0, img.width-1)
		for y in range(0, floor(img.height/2)-1)
			y2 = img.height - 1 - y
			for x in xrange
				c = img.pixel(x,y)
				img.setPixel x,y, img.pixel(x,y2)
				img.setPixel x,y2, c
			end for
		end for
	else
		// flip horizontally
		yrange = range(0, img.height-1)
		for x in range(0, floor(img.width/2)-1)
			x2 = img.width - 1 - x
			for y in yrange
				c = img.pixel(x,y)
				img.setPixel x,y, img.pixel(x2,y)
				img.setPixel x2,y, c
			end for
		end for
	end if
	
	if mode == kModeSelect then
		fatbits.drawImage img, selection.left, selection.bottom
		restoreMargins
	end if
end function

rotateClip = function
	img = null
	if mode == kModePasting then img = pasted
	if mode == kModeSelect then img = grabSelection(true)	
	if img == null then return
	
	result = Image.create(img.height, img.width)
	xrange = range(0, img.width-1)
	if key.pressed("left shift") or key.pressed("right shift") then
		// rotate left
		for y in range(0, img.height-1)
			for x in xrange
				result.setPixel img.height-y, x, img.pixel(x,y)
			end for
		end for
	else
		// rotate right
		for y in range(0, img.height-1)
			for x in xrange
				result.setPixel y, img.width-x, img.pixel(x,y)
			end for
		end for
	end if
	
	if mode == kModeSelect then
		// rotate the selection so that the center stays the same
		left = round(selection.midX - selection.height/2)
		bottom = round(selection.midY - selection.width/2)
		drawGrid
		globals.selection = Rect.make(left, bottom, selection.height, selection.width)
		fatbits.drawImage result, selection.left, selection.bottom
		restoreMargins
	else
		globals.pasted = result
	end if
end function

makeClipTransparent = function
	if globals.mode != kModePasting then return
	xrange = range(0, pasted.width-1)
	if key.pressed("left shift") or key.pressed("right shift") then
		// make NON-transparent
		for y in range(0, pasted.height-1)
			for x in xrange
				if pasted.pixel(x,y) == "#00000000" then pasted.setPixel x,y, "#000000FF"
			end for
		end for
	else
		// make transparent
		for y in range(0, pasted.height-1)
			for x in xrange
				if pasted.pixel(x,y) == "#000000FF" then pasted.setPixel x,y, "#00000000"
			end for
		end for
	end if
end function

//--------------------------------------------------------------------------------
// TOOL FUNCTIONS

toolFuncs = {}

toolFuncs[kModeMove] = function(pp, justDown)
	if justDown or startPaintPos == null then
		globals.startPaintPos = pp
		globals.startPaintImg = fatbits.getImage(0, 0, picW, picH)
		return
	end if
	// Shift the data within the picture.
	dx = pp.x - startPaintPos.x
	dy = pp.y - startPaintPos.y
	fatbits.fillRect 0, 0, picW+1, picH+1, color.black
	fatbits.drawImage startPaintImg.getImage(-dx * (dx<0), -dy * (dy<0), 
	  picW-abs(dx), picH-abs(dy)), dx * (dx>0), dy * (dy>0)
	restoreMargins
end function

toolFuncs[kModeDraw] = function(pp, justDown)
	if justDown or lastPP == null then
		// On the initial mouse-down, pick erase mode if we're clicking
		// a pixel that's already the fore color; otherwise, draw mode.
		pcolor = fatbits.pixel(pp.x, pp.y)
		globals.drawErases = (pcolor == foreColor)
		outer.lastPP = pp
	end if
	if drawErases then c = backColor else c = foreColor
	for pos in pointsOnLine(lastPP, pp)
		setPaintPixel pos, c
	end for
	restoreMargins
	outer.lastPP = pp
end function

toolFuncs[kModePaint] = function(pos, justDown)
	if brushSize == 1 then
		fatbits.setPixel pos.x, pos.y, foreColor
	else
		x = ceil(pos.x - brushSize/2)
		y = ceil(pos.y - brushSize/2)
		fatbits.fillEllipse x, y, brushSize, brushSize, foreColor
	end if
	restoreMargins
end function

toolFuncs[kModeErase] = function(pos, justDown)
	if brushSize == 1 then
		fatbits.setPixel pos.x, pos.y, backColor
	else
		fatbits.fillEllipse pos.x - brushSize/2, pos.y - brushSize/2, brushSize, brushSize, backColor
	end if
	restoreMargins
end function

toolFuncs[kModeFill] = function(pos, justDown)
	if not justDown then return
	toDo = [pos]
	matchColor = fatbits.pixel(pp.x, pp.y)
	if matchColor == foreColor then return
	while toDo
		pos = toDo.pop
		if not context.margin.contains(pos) then continue
		if fatbits.pixel(pos.x, pos.y) != matchColor then continue		
		setPaintPixel pos, foreColor
		toDo.push {"x":pos.x-1, "y":pos.y}
		toDo.push {"x":pos.x+1, "y":pos.y}
		toDo.push {"x":pos.x, "y":pos.y-1}
		toDo.push {"x":pos.x, "y":pos.y+1}		
	end while
	restoreMargins
end function

toolFuncs[kModeEyedrop] = function(pp, justDown)
	c = fatbits.pixel(pp.x, pp.y)
	PalButton.selectMatchingColor c
end function

toolFuncs[kModeLine] = function(pp, justDown)
	if justDown or picAtStart == null or posAtStart == null then
		globals.picAtStart = fatbits.getImage(0, 0, picW, picH)
		globals.posAtStart = pp
		return
	end if
	fatbits.fillRect 0, 0, picW+1, picH+1, color.black
	fatbits.drawImage picAtStart
	if key.pressed("left shift") or key.pressed("right shift") then
		// crossing mode -- try to make crossings
		for pos in pointsOnLine(posAtStart, pp)
			if fatbits.pixel(pos.x, pos.y) == "#000000FF" or
			  pos == posAtStart or pos == pp then
				setPaintPixel pos, foreColor
			else
				setPaintPixel pos, "#000000FF"
			end if
		end for
	else
		// standard mode (overwrite whatever's there)
		for pos in pointsOnLine(posAtStart, pp)
			setPaintPixel pos, foreColor
		end for
	end if
	restoreMargins
end function

toolFuncs[kModeDrawRect] = function(pp, justDown)
	if justDown or picAtStart == null or posAtStart == null then
		globals.picAtStart = fatbits.getImage(0, 0, picW, picH)
		globals.posAtStart = pp
		return
	end if
	fatbits.fillRect 0, 0, picW+1, picH+1, color.black
	fatbits.drawImage picAtStart
	startPos = posAtStart
	curPos = pp
	Rect.fromPoints(startPos, curPos).frame fatbits, foreColor, 1
	restoreMargins
end function

toolFuncs[kModeFillRect] = function(pp, justDown)
	if justDown or picAtStart == null or posAtStart == null then
		globals.picAtStart = fatbits.getImage(0, 0, picW, picH)
		globals.posAtStart = pp
		return
	end if
	fatbits.fillRect 0, 0, picW+1, picH+1, color.black
	fatbits.drawImage picAtStart
	startPos = posAtStart
	curPos = pp
	Rect.fromPoints(startPos, curPos).fill fatbits, foreColor
	restoreMargins
end function

toolFuncs[kModeDrawEllipse] = function(pp, justDown)
	if justDown or picAtStart == null or posAtStart == null then
		globals.picAtStart = fatbits.getImage(0, 0, picW, picH)
		globals.posAtStart = pp
		return
	end if
	fatbits.fillRect 0, 0, picW+1, picH+1, color.black
	fatbits.drawImage picAtStart
	startPos = posAtStart
	curPos = pp
	Rect.fromPoints(startPos, curPos).frameEllipse fatbits, foreColor, 1
	restoreMargins
end function

toolFuncs[kModeFillEllipse] = function(pp, justDown)
	if justDown or picAtStart == null or posAtStart == null then
		globals.picAtStart = fatbits.getImage(0, 0, picW, picH)
		globals.posAtStart = pp
		return
	end if
	fatbits.fillRect 0, 0, picW+1, picH+1, color.black
	fatbits.drawImage picAtStart
	startPos = posAtStart
	curPos = pp
	Rect.fromPoints(startPos, curPos).fillEllipse fatbits, foreColor
	restoreMargins
end function

toolFuncs[kModeSelect] = function(pp, justDown)
	if justDown or selectionAnchor == null then
		if selection and selection.contains(pp) then
			// drag the existing selection
			left = selection.left; bottom = selection.bottom
			savedClip = clip
			copy; deleteSelection; paste
			clipMouseOffset.x = pp.x - left
			clipMouseOffset.y = pp.y - bottom
			globals.clip = savedClip
			return
		else
			// start a new selection
			globals.selectionAnchor = pp
		end if
	end if
	if pp == selectionAnchor then
		deselect
	else
		newSel = Rect.fromPoints(selectionAnchor, pp)
		if newSel.width == 0 then newSel.width = 1
		if newSel.height == 0 then newSel.height = 1
		if newSel == selection then return
		globals.selection = newSel
		drawGrid
		drawSelection
	end if
end function

toolFuncs[kModePasting] = function(pp, justDown)
	//	if justDown then
	//		setMode kModeSelect
	//		globals.selectionAnchor = pp
	//	end if
end function

//--------------------------------------------------------------------------------
// COLOR PALETTE
palSelectionRing = new Sprite
palSelectionRing.image = Image.create(22, 22, "#CCCCCC")
editSprites.push palSelectionRing

paletteArea = Rect.make(766, 424, 164, 44) 
PalButton = new Sprite
PalButton.image = Image.create(18, 18, color.white)
PalButton.instances = []
PalButton.make = function(c)
	noob = new PalButton
	if c.len < 9 then c = c + "FF"
	noob.tint = c
	noob.index = PalButton.instances.len
	PalButton.instances.push noob
	editSprites.push noob
	noob.x = paletteArea.left + 12 + 20 * (noob.index % 8)
	noob.y = paletteArea.top - 12 - 20 * floor(noob.index / 8)
	noob.addBounds
	if noob.index == 0 then
		palSelectionRing.x = noob.x
		palSelectionRing.y = noob.y
	end if
end function

PalButton.checkEventsForAll = function
	if not mouse.button or not paletteArea.contains(mouse) then return
	for btn in PalButton.instances
		if not btn.contains(mouse) then continue
		palSelectionRing.x = btn.x
		palSelectionRing.y = btn.y
		globals.foreColor = btn.tint
		break
	end for
end function

PalButton.selectMatchingColor = function(c)
	c = c[:7] + "FF"
	globals.foreColor = c
	for btn in PalButton.instances
		if btn.tint == c then
			palSelectionRing.x = btn.x
			palSelectionRing.y = btn.y
			return
		end if
	end for
	palSelectionRing.x = -999
end function

makeDefaultPalette = function
	for c in ("000000 000099 2222FF 007722 66AAFF 833494 FF0000 FF22FF " +
		"D19E6F AAAAAA FF8000 FFAAAA 00FF00 FFFF00 B6F0D6 FFFFFF").split
		PalButton.make "#" + c
	end for
end function
makeDefaultPalette

//--------------------------------------------------------------------------------
// Mode Buttons & Mode Management

testMode = -1

ModeButton = new Button
ModeButton.iconUpTint = color.black
ModeButton.iconPressedTint = color.gray
ModeButton.iconDownTint = color.white
ModeButton.init = function(label, left, bottom)
	self.bgSprite = new Sprite
	self.bgSprite.image = Tool.btnUpImg
	self.bgSprite.scale = [2, 0.5]
	self.bgSprite.x = left + Tool.btnUpImg.width*2/2
	self.bgSprite.y = bottom + Tool.btnUpImg.height*0.5/2
	alwaysSprites.push self.bgSprite
	
	scratch.clear color.clear
	scratch.print label, 0, 0, color.white, "small"
	labelImg = scratch.getImage(0, 0, 8*label.len, 14)
	self.iconSprite = new Sprite
	self.iconSprite.image = labelImg
	self.iconSprite.x = self.bgSprite.x
	self.iconSprite.y = self.bgSprite.y
	self.iconSprite.tint = color.black
	alwaysSprites.push self.iconSprite
	
	self.bgSprite.addBounds
	
	Button.instances.push self
end function

if context.isFreePlay then
	// Free play mode: add Save As and Save buttons
	saveAsButton = new ModeButton
	saveAsButton.init "SAVE AS", paintArea.right - 72 - 88*2, paintArea.top + 14
	saveAsButton.handleClick = @doSaveAs
	
	saveButton = new ModeButton
	saveButton.init "SAVE", paintArea.right - 72 - 88*1, paintArea.top + 14
	saveButton.handleClick = @doSave
end if

exitButton = new ModeButton
exitButton.init "EXIT", paintArea.right - 72, paintArea.top + 14
exitButton.handleClick = function
	if not testMode then globals.circuitPic = fatbits.getImage(0, 0, picW, picH)
	if globals.hasIndex("returnFunc") then
		returnFunc
	else
		text.row = 0; print; exit
	end if
end function

editModeButton = new ModeButton
editModeButton.init "EDIT", paletteArea.midX - 80, paintArea.top + 14
editModeButton.isDown = true; editModeButton.update
editModeButton.handleClick = function
	setTestMode false
end function
testModeButton = new ModeButton
testModeButton.init "TEST", paletteArea.midX, paintArea.top + 14
testModeButton.handleClick = function
	setTestMode true
end function
checkButton = new ModeButton
checkButton.init "CHECK", paletteArea.midX, 20
checkButton.handleClick = function
	if context.hasIndex("check") then context.check
end function
checkButton.hide

drawSimStats = function
	gfx.fillRect 760, 525, 192, 92, bgColor
	x = 848
	y = 575
	gap = 12
	helpFont.printRight "Glyphs:", x,y, 1, color.silver
	helpFont.print str(sim.gates.len), x + gap,y, 1, color.white

	y = y - 20
	helpFont.printRight "Total Ink:", x,y, 1, color.silver
	helpFont.print str(sim.totalInk), x + gap,y, 1, color.white
end function

setTestMode = function(enterTestMode = true)
	if testMode == enterTestMode then return	// (already in the correct mode)
	outer.testMode = enterTestMode
	editModeButton.isDown = not testMode; editModeButton.update
	testModeButton.isDown = testMode; testModeButton.update
	if testMode then
		globals.circuitPic = fatbits.getImage(0, 0, picW, picH)
		spriteDisp.sprites = alwaysSprites + testSprites
		sim.setup true
		sim.analyze
		text.clear
		drawSimStats
		if context.hasIndex("check") then checkButton.unhide else checkButton.hide
		drawHelp "Click any ink to toggle it on or off."
	else
		displays.simSprite.clear
		fatbits.drawImage circuitPic, 0, 0
		spriteDisp.sprites = alwaysSprites + editSprites
		checkButton.hide
		setMode mode
	end if
end function


//--------------------------------------------------------------------------------
// MAIN PROGRAM

startPaintPos = null
startPaintImg = null
brushSize = 6
mode = null

PalButton.selectMatchingColor foreColor

prepareScreen
fatbits.clear color.clear, picW, picH
fatbits.scale = ps
fatbits.drawImage circuitPic
updatePaintScroll
setTestMode false

handleClick = function(justDown)
	if not paintArea.contains(mouse) then return
	pp = paintPixelAtXY(mouse)
	tf = toolFuncs[mode]
	tf pp, justDown
	if not testMode then globals.circuitPic = fatbits.getImage(0, 0, picW, picH)
end function

handleMouseUp = function
	// The only case where we do something special on mouse-up is
	// while pasting a selection:
	if mode == kModePasting then
		setMode kModeSelect
	end if
end function

showHelp = function
	lines = []
	lines.push "Alt - Color Picker      "
	lines.push "X - Cut                 "
	lines.push "C - Copy                "
	lines.push "V - Paste               "
	lines.push "Backspace/Delete - Clear"
	lines.push "S - Save                "
	lines.push "Q - Quit                "
	d = textUtil.Dialog.make("Keyboard Shortcuts", lines.join(char(13)))
	d.show
end function

handleKeys = function
	if not key.available then return
	k = key.get.lower
	if k == "c" then copy
	if k == "v" then paste
	if k.code == 8 or k.code == 127 then deleteSelection
	if k == "x" then; copy; deleteSelection; end if
	if k == "f" then flipClip
	if k == "r" then rotateClip
	if k == "t" then makeClipTransparent
	if k == "s" and context.isFreePlay then doSave
	if k == "?" or k == "/" then showHelp
	if k == "q" then
		d = textUtil.Dialog.make("Quit fatbits?", "Are you sure you want to quit?")
		d.okBtn.caption = "Quit"
		d.cancelBtn.visible = true
		if d.show.caption == "Quit" then
			clear
			exit
		end if
	end if
end function

mouseWasDown = mouse.button
setMode kModeDraw
while true
	yield
	music.update
	
	pp = paintPixelAtXY(mouse)
	gfx.fillRect 860, 0, 100, 20, bgColor
	brushSprite.x = -9999
	if pp.x >= 0 and pp.y >= 0 and pp.x < picW and pp.y < picH then
		gfx.print pp.x + "," + pp.y, 860, 3, color.silver, "small"
		if modesWithSize.contains(mode) then
			brushSprite.x = xAtPaintPixel(pp) - (not brushSize%2)*ps/2
			brushSprite.y = yAtPaintPixel(pp) - (not brushSize%2)*ps/2
		end if
	end if
	if mode == kModePasting then updatePaste pp
	
	// check UI elements
	for btn in Button.instances; btn.checkEvents; end for
	
	if testMode then
		// update simulation
		sim.handleMouse
		sim.simOneStep
	else
		// then, update usage of tools (e.g. painting)
		PalButton.checkEventsForAll
		mouseIsDown = mouse.button
		if mouseIsDown then
			handleClick not mouseWasDown
		else if mouseWasDown then
			handleMouseUp
		end if
		mouseWasDown = mouseIsDown
		if key.available then handleKeys
		if selection != null then drawSelection
	end if
	context.update
end while
