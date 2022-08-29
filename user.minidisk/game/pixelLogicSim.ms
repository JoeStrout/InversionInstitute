// Pixel Logic Simulator
// based on: https://github.com/JoeStrout/pixelLogic/
// ...and:   https://realhet.wordpress.com/2015/09/02/bitmap-logic-simulator/

import "miscUtil"
ensureImport "mathUtil"
ensureImport "displays"

min = function(a,b)
	if b < a then return b else return a
end function

max = function(a,b)
	if b > a then return b else return a
end function

filePath = null
if (not locals.hasIndex("circuitPic") and
      not globals.hasIndex("circuitPic")) or circuitPic == null then    
	circuitPic = Image.create(80,64, color.black)
	for x in range(10,20)
		for y in range(25,35)
			circuitPic.setPixel x, y, color.white
		end for
	end for
end if

setup = function(keepView=false)
	// Define the map.
	outer.mapW = circuitPic.width    // map width
	outer.mapH = circuitPic.height    // map height
	
	outer.maxX = mapW-1
	outer.maxY = mapH-1
	outer.xrange = range(0, maxX)
	outer.yrange = range(0, maxY)
	
	if not keepView then
		displays.setupEditorSim
		displays.simGfx.clear color.black, mapW, mapH
		displays.simGfx.drawImage circuitPic
		displays.simGfx.scale = max(1, floor(min(960/mapW, 640/mapH)))
		displays.simGfx.scrollX = 480-mapW*displays.simGfx.scale/2
		displays.simGfx.scrollY = 320-mapH*displays.simGfx.scale/2
	end if
	
	outer.coordToNode = {}
	outer.gates = []
	outer.nodes = []
	outer.toDo = []		// list of Nodes that need updating
	outer.scaleIdx = scales.indexOf(displays.simGfx.scale)
	if scaleIdx == null then outer.scaleIdx = 4
end function

// Node: represents a set of pixels that are logically all
// one unit, i.e., they're all either on or off together.
Node = {}
Node.coords = null  // list of [x,y] coordinates
Node.colors = null	// parallel list of colors
Node.indices = null	// indexes into coords and colors
Node.inputs = null	// list of Nodes that are inputs to this node
Node.outputs = null	// list of Nodes that are outputs to this node
Node.on = true
Node.sprite = null	// sprite of the node path with transparent background
Node.add = function(x, y, fullColor)
	self.coords.push [x,y]
	self.colors.push fullColor
	coordToNode[y * mapW + x] = self
end function
Node.prepImage = function
	display(7).mode = displayMode.pixel
	g = display(7)
	g.clear color.clear, mapW, mapH
	if self.indices == null then self.indices = self.coords.indexes
	minX = self.coords[0][0]; maxX = minX
	minY = self.coords[0][1]; maxY = minY
	for i in self.indices
		p = self.coords[i]; x = p[0]; y = p[1]
		g.setPixel x, y, self.colors[i]
		if x < minX then minX = x
		if x > maxX then maxX = x
		if y < minY then minY = y
		if y > maxY then maxY = y
	end for
	self.sprite = new Sprite
	self.sprite.image = g.getImage(minX, minY, maxX-minX+1, maxY-minY+1)
	self.sprite.origX = (minX + maxX + 1)/2
	self.sprite.origY = (minY + maxY + 1)/2
	self.minX = minX; self.maxX = maxX
	
	self.sprite.scale = displays.simGfx.scale
	self.sprite.x = self.sprite.origX * displays.simGfx.scale - displays.simGfx.scrollX
	self.sprite.y = self.sprite.origY * displays.simGfx.scale - displays.simGfx.scrollY
	display(4).sprites.push self.sprite
	display(7).mode = displayMode.off
end function
Node.draw = function
	if not self.sprite then self.prepImage
	if self.on then
		self.sprite.tint = "#FFFFFF"
	else
		self.sprite.tint = "#444444"
	end if
end function
Node.containsXY = function(x, y)
	k = y * mapW + x
	return coordToNode.hasIndex(k) and coordToNode[k] == self
end function
Node.setOn = function(nowOn)
	if nowOn == self.on then return
	self.on = nowOn
	self.draw
	for n in self.outputs
		if toDo.indexOf(n) == null then toDo.push n
	end for
end function
Node.update = function
	// Set this node on if ANY of its input nodes are off.
	if not self.inputs then return
	setOn = false
	for n in self.inputs
		if not n.on then
			setOn = true
			break
		end if
	end for
	if setOn != self.on then
		self.on = setOn
		self.draw
		for n in self.outputs
			if toDo.indexOf(n) == null then toDo.push n
		end for
	end if
end function

// Find the node at the given gfx (not screen) coordinates.
nodeAtXY = function(gfxX, gfxY)
	k = gfxY * mapW + gfxX
	if not coordToNode.hasIndex(k) then return null
	return coordToNode[k]
end function


// Gate: a special location on the map where special logic
// applies.  It's either a crossing (0), or a a NOT
// gate facing South (1), West (2), North (3), or East (4).
Gate = {}
Gate.x = null
Gate.y = null
Gate.type = 0  // 0: crossing; 1-4: NOT gate
Gate.on = false // output value of the gate (if it's a NOT gate)
Gate.make = function(x, y, type)
	result = new Gate
	result.x = x
	result.y = y
	result.type = type
	// print "Gate at " + x +"," + y + " of type " + type
	return result
end function

// Set the alpha of all non-black pixels is FF, i.e., 
// the pixel is fully "on".
resetAlpha = function
	for y in yrange
		for x in xrange
			c = displays.simGfx.pixel(x,y)
			if c == "#000000FF" then continue
			if c[-2:] != "FF" then
				displays.simGfx.setPixel x, y, c[:7] + "FF"
			end if
		end for
		print floor(100*y/maxY) + "%"; text.row = text.row+1
	end for
end function

// Do a flood-fill starting at x,y, setting the alpha of each
// connected pixel to F0, and gathering the coordinates of
// those pixels into a Node object.
createNodeAt = function(x,y)
	node = new Node
	node.coords = []; node.colors = []; node.inputs = []; node.outputs = []
	toDo = [[x,y]]
	while toDo
		pos = toDo.pop
		x = pos[0]; y = pos[1]
		c = displays.simGfx.pixel(x, y)
		if c == "#000000FF" or c[-2:] != "FF" then continue
		
		displays.simGfx.setPixel x, y, c[:7] + "F0"
		node.add x, y, c
		
		// push immediate neighbors
		if x > 0 then toDo.push [x-1, y]
		if x < maxX then toDo.push [x+1, y]
		if y > 0 then toDo.push [x, y-1]
		if y < maxY then toDo.push [x, y+1]	
		// if our immediate neighbor is a crossing, push the other side
		if x > 1 and displays.simGfx.pixel(x-1,y) == crossingColor then toDo.push [x-2, y]
		if x < maxX-1 and displays.simGfx.pixel(x+1,y) == crossingColor then toDo.push [x+2, y]
		if y > 1 and displays.simGfx.pixel(x,y-1) == crossingColor then toDo.push [x, y-2]
		if y < maxY-1 and displays.simGfx.pixel(x,y+1) == crossingColor then toDo.push [x, y+2]	
	end while
	return node
end function

// Search the current map for all Gates.  Return as a list.
// Also, while we're at it, set Crossing gate pixels to a 
// secret color so we can quickly identify them later.
crossingColor = "#FF00FFF0"
findGates = function
	result = []
	for y in range(1, maxY-1)
		for x in range(1, maxX-1)
			// gates always have a black pixel in the middle
			if displays.simGfx.pixel(x,y) != "#000000FF" then continue
			// if we have that, check the pattern of surrounding pixels
			pat = []
			for j in range(y-1, y+1)
				for i in range(x-1, x+1)
					c = displays.simGfx.pixel(i,j)
					if c == "#000000FF" or c == crossingColor then pat.push "0" else pat.push "1"
				end for				
			end for
			pat = pat.join("")
			if pat == "000000000" then continue
			// print pat
			if pat == "010101010" then  // crossing
				result.push Gate.make(x, y, 0)
				displays.simGfx.setPixel x, y, crossingColor				
			else if pat == "110101110" then  // NOT (East)
				result.push Gate.make(x, y, 4)
			else if pat == "111101010" then // NOT (North)
				result.push Gate.make(x, y, 3)
			else if pat == "011101011" then // NOT (West)
				result.push Gate.make(x, y, 2)
			else if pat == "010101111" then // NOT (South)
				result.push Gate.make(x, y, 1)
			end if
		end for
		print floor(100*y/maxY) + "%"; text.row = text.row+1
	end for
	return result
end function

// Analyze the current map.  We need to find a series of "nodes"
// connected by NOT gates.  Each node is a set of interconnected
// non-black pixels.  We find these by doing a flood-fill on any
// non-black pixel that hasn't already been assigned to a node.
analyze = function
	// Start by ensuring the alpha of all pixels is FF, i.e.,
	// the pixel is full "on".  Then we'll change them to F0
	// as we go, to keep track of which pixels have already
	// been assigned to nodes.
	//print "Resetting alpha" ...actually, let's don't
	//resetAlpha				we'll instead just require opaque images for now
	
	// Find all the gates.
//	print "Finding gates"
	outer.gates = findGates
//	print "Found " + gates.len + " gates"
	
	// Create nodes.
//	print "Creating nodes"
	outer.nodes = []
	for y in yrange
		for x in xrange
			c = displays.simGfx.pixel(x,y)
			if c == "#000000FF" then continue
			if c[-2:] != "FF" then continue
			
			node = createNodeAt(x,y)
			// print "Got node at " + x + "," + y + " with " + node.coords.len + " pixels"
			nodes.push node
		end for
		print floor(100*y/maxY) + "%"; text.row = text.row+1
	end for
//	print "Found " + nodes.len + " nodes"
	
	// Then, take out all the crossing gates, and set them back to black.
	// And for the NOT gates, hook up their inputs and outputs.
//	print "Cleaning up"
	if gates.len > 0 then
		for i in range(gates.len - 1)
			if i % 10 == 0 then
				print (100 - floor(100*i/gates.len)) + "%"
				text.row = text.row + 1
			end if
			g = gates[i]
			t = g.type
			if t == 0 then
				displays.simGfx.setPixel g.x, g.y, "#000000FF"
				gates.remove i
				continue
			else if t == 1 then  // NOT from North to South
				g.input = nodeAtXY(g.x, g.y+1)
				g.output = nodeAtXY(g.x, g.y-1)
			else if t == 2 then // NOT from East to West
				g.input = nodeAtXY(g.x+1, g.y)
				g.output = nodeAtXY(g.x-1, g.y)
			else if t == 3 then // NOT from South to North
				g.input = nodeAtXY(g.x, g.y-1)
				g.output = nodeAtXY(g.x, g.y+1)
			else // NOT from West to East
				g.input = nodeAtXY(g.x-1, g.y)
				g.output = nodeAtXY(g.x+1, g.y)
			end if
			g.output.inputs.push g.input
			g.input.outputs.push g.output
		end for
	end if
	for n in nodes
		n.setOn false
	end for
	//	outer.toDo = nodes[:]
end function

scales = [0.1, 0.25, 0.5, 0.75] + range(1,32)

repositionSprites = function
	scale = displays.simGfx.scale
	sx = -displays.simGfx.scrollX
	sy = -displays.simGfx.scrollY
	for s in display(4).sprites
		s.x = s.origX * scale + sx
		s.y = s.origY * scale + sy
	end for
end function

doZoom = function(clicks)
	// get position of mouse in the PixelDisplay
	mx = (mouse.x + displays.simGfx.scrollX) / displays.simGfx.scale
	my = (mouse.y + displays.simGfx.scrollY) / displays.simGfx.scale
	// adjust the scroll
	outer.scaleIdx = mathUtil.clamp(scaleIdx + clicks,
	0, scales.len-1)
	displays.simGfx.scale = scales[scaleIdx]
	// adjust scroll so mouse is still over mx, my
	// (just solve the above for scroll -- yay, algebra!)
	displays.simGfx.scrollX = mx * displays.simGfx.scale - mouse.x
	displays.simGfx.scrollY = my * displays.simGfx.scale - mouse.y
	repositionSprites
end function

dragScroll = function
	// get position of mouse in the PixelDisplay
	mx = (mouse.x + displays.simGfx.scrollX) / displays.simGfx.scale
	my = (mouse.y + displays.simGfx.scrollY) / displays.simGfx.scale
	
	// while right button down, keep adjusting it
	// so the mouse is still over mx, my
	while mouse.button(1)
		// adjust scroll so mouse is still over mx, my
		// (just solve the above for scroll -- yay, algebra!)
		displays.simGfx.scrollX = mx * displays.simGfx.scale - mouse.x
		displays.simGfx.scrollY = my * displays.simGfx.scale - mouse.y
		repositionSprites
		yield
	end while	
end function

handleMouse = function
	zoom = round(key.axis("Mouse ScrollWheel")*5)
	if zoom != 0 then doZoom zoom
	if mouse.button(1) then dragScroll
	if not mouse.button then return
	node = nodeAtXY(floor((mouse.x + displays.simGfx.scrollX) / displays.simGfx.scale), 
	  floor((mouse.y + displays.simGfx.scrollY) / displays.simGfx.scale))
	if node != null then
		node.setOn not node.on
	end if
	while mouse.button; yield; end while	
end function

handleKeys = function
	if not key.available then return
	k = key.get
	if k == " " then
		outer.singleStep = true
		simOneStep
	else if k == char(10) then
		outer.singleStep = false
	else if k == "+" or k == "=" then
		doZoom 1
	else if k == "-" or k == "_" then
		doZoom -1
	end if
end function

simOneStep = function
	stepsLeft = toDo.len
	//text.row=25; text.column=60; print stepsLeft+"   "
	while stepsLeft > 0
		n = toDo.pull
		stepsLeft = stepsLeft - 1
		n.update
	end while
end function

singleStep = false

update = function
	handleMouse
	handleKeys
	if not singleStep then simOneStep
	yield
end function

if locals == globals then
	setup
	print "Analyzing..."
	analyze
	print "Ready!"
	wait
	text.clear
	while not key.pressed("escape")
		update
	end while
	key.clear
end if
