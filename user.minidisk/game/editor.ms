// Circuit editor.  Based on /sys/demo/fatbits
// (but heavily modified).

import "miscUtil"
ensureImport "listUtil"
ensureImport "textUtil"
ensureImport "mathUtil"
ensureImport "qa"
ensureImport "displays"
ensureImport "drawing"
ensureImport "pixelLogicSim"; sim = pixelLogicSim

// Constants and global state variables
kModeDraw = "DRAW"
kModeErase = "ERASE"
kModeSelect = "SELECT"
kModeMove = "MOVE"
kModeFill = "FILL"
kModeEyedrop = "EYEDROP"
kModePaint = "PAINT"
kModeLighten = "LIGHTEN"
kModeDarken = "DARKEN"
kModeBlur = "BLUR"
kModeDrawRect = "DRAWRECT"
kModeFillRect = "FILLRECT"
kModeDrawEllipse = "DRAWELLIPSE"
kModeFillEllipse = "FILLELLIPSE"
kModeLine = "DRAWLINE"
kModeReplace = "REPLACE"
kModePasting = "PASTING"

foreColor = "#FFFFFFFF"		// current painting foreground and background colors
backColor = "#000000FF"
spriteBoundsColor = color.silver
ps = 9	// "pixel size" (forgive the short name, but we use this a lot)
circuitPic = Image.create(80, 64, color.black)
picW = circuitPic.width
picH = circuitPic.height
resourceDir = "/sys/data/fatbits/"

testSprites = []		// UI sprites needed only in simulation mode
editSprites = []	// UI sprites needed only in edit mode
alwaysSprites = []	// UI sprites needed always

if not globals.hasIndex("context") then
	context = {}
	context.title = "Ch. 1: Introduction"
end if

// Prepare displays
displays.setupEditorSim picW, picH, ps
spriteDisp = displays.edSprite
fatbits = displays.edFatbits
backdrop = displays.edBackdrop
bgColor = "#888888"
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

saveFromEditArea = function
	circuitPic = fatbits.getImage(0, 0, picW, picH)
end function

saveToDisk = function
	// ToDo
//	err = file.saveImage(self.path, self.image)
//	if not err then
//		dlog = textUtil.Dialog.make("Saved """ + file.name(self.path) + """",
//		   self.path + char(13) + self.image.width + " x " + self.image.height + " pixels")
//		dlog.okBtn.visible = false
//		dlog.show 2
//	else
//		dlog = textUtil.Dialog.make("Unable to Save File", err)
//		dlog.show
//	end if
end function

updatePaintScroll = function
	// ToDo: redo scroll support, using scrollbars or a grabby-hand tool.
	// For now, just hard-code it:
	fatbits.scrollX = -paintArea.left
	fatbits.scrollY = -paintArea.bottom
end function

//---------------------------------------------------------------------
// Make a handy Rect class
Rect = {}
Rect.left = 0
Rect.bottom = 0
Rect.width = 0
Rect.height = 0
Rect.area = function; return self.width * self.height; end function
Rect.right = function; return self.left + self.width; end function
Rect.top = function; return self.bottom + self.height; end function
Rect.midX = function; return self.left + self.width/2; end function
Rect.midY = function; return self.bottom + self.height/2; end function
Rect.make = function(left, bottom, width, height)
	r = new Rect
	r.left = left
	r.bottom = bottom
	r.width = width
	r.height = height
	return r
end function
Rect.fromPoints = function(p0, p1)
	r = new Rect
	if p0.x < p1.x then
		r.left = p0.x
		r.width = p1.x - p0.x
	else
		r.left = p1.x
		r.width = p0.x - p1.x
	end if
	if p0.y < p1.y then
		r.bottom = p0.y
		r.height = p1.y - p0.y
	else
		r.bottom = p1.y
		r.height = p0.y - p1.y
	end if
	return r
end function
Rect.offset = function(dx, dy)
	return Rect.make(self.left + dx, self.bottom + dy, self.width, self.height)
end function
Rect.grow = function(dwidth, dheight)
	return Rect.make(self.left, self.bottom, self.width + dwidth, self.height + dheight)
end function
Rect.contains = function(pt)
	return pt.x >= self.left and pt.x < self.left + self.width and
	  pt.y >= self.bottom and pt.y < self.bottom + self.height
end function
Rect.fill = function(gfx, color=null)
	gfx.fillRect self.left, self.bottom, self.width, self.height, color
end function
Rect.fillEllipse = function(gfx, color=null)
	gfx.fillEllipse self.left, self.bottom, self.width, self.height, color
end function
Rect.drawImage = function(gfx, image)
	gfx.drawImage image, self.left, self.bottom, self.width, self.height
end function
Rect.frame = function(gfx, color=null, lineWidth=1, inset=0)
	gfx.drawRect self.left+inset, self.bottom+inset,
	   self.width-inset*2, self.height-inset*2,
	   color, lineWidth
end function
Rect.frameEllipse = function(gfx, color=null, lineWidth=1, inset=0)
	gfx.drawEllipse self.left+inset, self.bottom+inset,
	   self.width-inset*2, self.height-inset*2,
	   color, lineWidth
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

modesWithSize = [kModeErase, kModePaint, kModeLighten, kModeDarken, kModeBlur]
setMode = function(newMode)
	globals.mode = newMode
	globals.drawErases = false
	deselect
	for tool in Tool.instances
		tool.update
	end for
end function

//---------------------------------------------------------------------
// screen layout
paintArea = Rect.make(10, 10, 720, 576)
prepareScreen = function
	gfx.clear bgColor, 960+10, 640+10
	gfx.scrollX = 5; gfx.scrollY = 5
	area = paintArea.offset(gfx.scrollX, gfx.scrollY)
	area.fill gfx, color.clear
	area.grow(1,1).frame gfx, color.black, 4, -4
	backdrop.clear color.black
	drawGrid
//	gfx.print "press ? for help", 955 - 16*9, 640-18, color.silver, "small"
	font.print context.title, 10, 640 - font.lineHeight
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
end  function

makeTools = function
	tools = [
	["Pencil", kModeDraw], ["Erase", kModeErase], ["Move", kModeMove], ["Select", kModeSelect],
	["Brush", kModePaint], ["Fill", kModeFill], 
	["Line", kModeLine], ["DrawRect", kModeDrawRect], ["DrawEllipse", kModeDrawEllipse], 
	["Eyedropper", kModeEyedrop], ["FillRect", kModeFillRect], ["FillEllipse", kModeFillEllipse]]
	for i in tools.indexes
		t = tools[i]
		if t[0] == null then continue
		Tool.make t[0], 770 + 40*(i%4), 56 + 40*floor(i/4), t[1]
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
		gfx.drawRect left, botm, selection.width * ps + 1, selection.height * ps + 1
	end if
end function

deselect = function
	if selection == null then return
	globals.selection = null
	drawGrid
end function

copy = function
	if selection == null then return
	globals.clip = fatbits.getImage(selection.left, selection.bottom, selection.width, selection.height)
	drawGrid
end function

deleteSelection = function
	if mode == kModePasting then
		fatbits.fillRect 0, 0, picW+1, picH+1, color.black
		fatbits.drawImage picAtStart, 0, 0
		setMode kModeSelect
	else if selection != null then
		selection.fill fatbits, backColor
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
end function

updatePaste = function(pp)
	fatbits.fillRect 0, 0, picW+1, picH+1, color.black
	fatbits.drawImage picAtStart, 0, 0
	fatbits.drawImage clip, pp.x - floor(clip.width/2), pp.y - floor(clip.height/2)
end function

//--------------------------------------------------------------------------------
// TOOL FUNCTIONS

toolFuncs = {}

toolFuncs[kModeMove] = function(pp, justDown)
	if justDown then
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
end function

toolFuncs[kModeDraw] = function(pp, justDown)
	if justDown then
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
end function

toolFuncs[kModeErase] = function(pos, justDown)
	if brushSize == 1 then
		fatbits.setPixel pos.x, pos.y, backColor
	else
		fatbits.fillEllipse pos.x - brushSize/2, pos.y - brushSize/2, brushSize, brushSize, backColor
	end if
end function

toolFuncs[kModeFill] = function(pos, justDown)
	if not justDown then return
	toDo = [pos]
	matchColor = fatbits.pixel(pp.x, pp.y)
	if matchColor == foreColor then return
	while toDo
		pos = toDo.pop
		if pos.x < 0 or pos.x >= picW or pos.y < 0 or pos.y >= picH then continue
		if fatbits.pixel(pos.x, pos.y) != matchColor then continue		
		setPaintPixel pos, foreColor
		toDo.push {"x":pos.x-1, "y":pos.y}
		toDo.push {"x":pos.x+1, "y":pos.y}
		toDo.push {"x":pos.x, "y":pos.y-1}
		toDo.push {"x":pos.x, "y":pos.y+1}		
	end while
end function

toolFuncs[kModeReplace] = function(pp, justDown)
	if not justDown then return
	fromColor = fatbits.pixel(pp.x, pp.y)
	for y in range(0, picH)
		for x in range(0, picW)
			if fatbits.pixel(x, y) == fromColor then fatbits.setPixel x,y, foreColor
		end for
	end for
end function

toolFuncs[kModeEyedrop] = function(pp, justDown)
	c = fatbits.pixel(pp.x, pp.y)
	PalButton.selectMatchingColor c
end function

toolFuncs[kModeLine] = function(pp, justDown)
	if justDown then
		globals.picAtStart = fatbits.getImage(0, 0, picW, picH)
		globals.posAtStart = pp
		return
	end if
	fatbits.fillRect 0, 0, picW+1, picH+1, color.black
	fatbits.drawImage picAtStart
	for pos in pointsOnLine(posAtStart, pp)
		setPaintPixel pos, foreColor
	end for
end function

toolFuncs[kModeDrawRect] = function(pp, justDown)
	if justDown then
		globals.picAtStart = fatbits.getImage(0, 0, picW, picH)
		globals.posAtStart = pp
		return
	end if
	fatbits.fillRect 0, 0, picW+1, picH+1, color.black
	fatbits.drawImage picAtStart
	startPos = posAtStart
	curPos = pp
	Rect.fromPoints(startPos, curPos).frame fatbits, foreColor, 1
end function

toolFuncs[kModeFillRect] = function(pp, justDown)
	if justDown then
		globals.picAtStart = fatbits.getImage(0, 0, picW, picH)
		globals.posAtStart = pp
		return
	end if
	fatbits.fillRect 0, 0, picW+1, picH+1, color.black
	fatbits.drawImage picAtStart
	startPos = posAtStart
	curPos = pp
	Rect.fromPoints(startPos, curPos).fill fatbits, foreColor
end function

toolFuncs[kModeDrawEllipse] = function(pp, justDown)
	if justDown then
		globals.picAtStart = fatbits.getImage(0, 0, picW, picH)
		globals.posAtStart = pp
		return
	end if
	fatbits.fillRect 0, 0, picW+1, picH+1, color.black
	fatbits.drawImage picAtStart
	startPos = posAtStart
	curPos = pp
	Rect.fromPoints(startPos, curPos).frameEllipse fatbits, foreColor, 1
end function

toolFuncs[kModeFillEllipse] = function(pp, justDown)
	if justDown then
		globals.picAtStart = fatbits.getImage(0, 0, picW, picH)
		globals.posAtStart = pp
		return
	end if
	fatbits.fillRect 0, 0, picW+1, picH+1, color.black
	fatbits.drawImage picAtStart
	startPos = posAtStart
	curPos = pp
	Rect.fromPoints(startPos, curPos).fillEllipse fatbits, foreColor
end function

toolFuncs[kModeSelect] = function(pp, justDown)
	if justDown then globals.selectionAnchor = pp
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
	if justDown then
		globals.mode = kModeSelect
		globals.selectionAnchor = pp
	end if
end function

//--------------------------------------------------------------------------------
// COLOR PALETTE
palSelectionRing = new Sprite
palSelectionRing.image = Image.create(22, 22, "#CCCCCC")
editSprites.push palSelectionRing

paletteArea = Rect.make(766, 408, 164, 44) 
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
	if c.len < 9 then c = c + "FF"
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

testMode = false

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

exitButton = new ModeButton
exitButton.init "EXIT", paintArea.right - 80, paintArea.top + 20
exitButton.handleClick = function
	// for now:
	text.row = 0; print; exit
end function

editModeButton = new ModeButton
editModeButton.init "EDIT", paletteArea.midX - 80, paintArea.top + 20
editModeButton.isDown = true; editModeButton.update
editModeButton.handleClick = function
	setTestMode false
end function
testModeButton = new ModeButton
testModeButton.init "TEST", paletteArea.midX, paintArea.top + 20
testModeButton.handleClick = function
	setTestMode true
end function

setTestMode = function(enterTestMode = true)
	outer.testMode = enterTestMode
	editModeButton.isDown = not testMode; editModeButton.update
	testModeButton.isDown = testMode; testModeButton.update
	if testMode then
		globals.circuitPic = fatbits.getImage(0, 0, picW, picH)
		spriteDisp.sprites = alwaysSprites + testSprites
		sim.setup true
		sim.analyze
		text.clear
	else
		displays.simSprite.clear
		fatbits.drawImage circuitPic, 0, 0
		spriteDisp.sprites = alwaysSprites + editSprites
	end if
end function


//--------------------------------------------------------------------------------
// MAIN PROGRAM

startPaintPos = null
startPaintImg = null
brushSize = 6
setMode kModeDraw

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
	saveFromEditArea
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
	if k == "x" then
		copy
		deleteSelection
	end if
	if k == "s" then saveToDisk
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
while true
	yield
	
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
		if mouseIsDown then handleClick not mouseWasDown
		mouseWasDown = mouseIsDown
		if key.available then handleKeys
		if selection != null then drawSelection
	end if
end while
