// The Transform class returned by this module represents a 2D position,
// rotation, and scale.  These can be arranged in a hierarchy; every part
// knows its "local" (relative to the parent) transform, and can then
// compute its "world" (relative to the screen) transform from that and
// its parent transform.

// Careful of the circular references!  Please be sure to clean up properly
// when done with a Transform, by calling its dispose method.

import "listUtil"

// A little map to represent a position, rotation, and scale
// in some arbitrary coordinate system.
posRotScale = function(x=0, y=0, rotation=0, scale=1)
	prs = {}
	prs.x = x
	prs.y = y
	prs.rotation = rotation
	prs.scale = scale
	return prs
end function

globals.Transform = {}
Transform.name = "Transform" // (used mainly for debugging)
Transform.parent = null
Transform.children = null	// list of Transform
Transform.local = posRotScale
Transform._world = posRotScale
Transform._world.stale = false

Transform.init = function(x=0, y=0, rotation=0, scale=1, name)
	if name then self.name = name
	self.children = []
	self.local = posRotScale(x, y, rotation, scale)
	self._world = posRotScale
	self._world.stale = true
end function

Transform.make = function(x=0, y=0, rotation=0, scale=1, name)
	t = new Transform
	t.init x, y, rotation, scale, name
	return t
end function

Transform.dispose = function
	if self.parent then self.parent.children.removeVal self
	for c in self.children
		c.dispose
	end for
	self.children = null
end function

Transform.setParent = function(parent)
	// ToDo: ensure we are not creating a loop.
	if self.parent then self.parent.children.removeVal self
	self.parent = parent
	parent.children.push self
end function

// Compute the world position of a given point in local coordinates.
// Return as [worldX, worldY].
Transform.transformPoint = function(localX, localY)
	pw = self.world
	if (pw.rotation % 360 == 0) then return [localX * pw.scale + pw.x, localY * pw.scale + pw.y]
	radians = pw.rotation * pi/180
	sinAng = sin(radians); cosAng = cos(radians)
	x2 = localX * cosAng - localY * sinAng
	y2 = localY * cosAng + localX * sinAng
	return [x2 * pw.scale + pw.x, y2 * pw.scale + pw.y]
end function

Transform.world = function
	if self._world.stale then
		if self.parent == null then
			self._world = self.local + {"stale": false}
		else
			// Here's the heart of the hierarchy magic.
			// Compute our world pos/rot/scale from our local PRS,
			// affected by the parent world PRS.
			pw = self.parent.world
			pos = self.parent.transformPoint(self.local.x, self.local.y)
			self._world.x = pos[0]
			self._world.y = pos[1]
			self._world.rotation = pw.rotation + self.local.rotation
			self._world.scale = pw.scale * self.local.scale
			self._world.stale = false
		end if
	end if
	return self._world
end function

Transform.markStale = function
	self._world.stale = true
	for c in self.children; c.markStale; end for
end function

Transform.find = function(childName)
	if self.name == childName then return self
	for c in self.children
		result = c.find(childName)
		if result then return result
	end for
	return null
end function

Transform.applyToSprite = function(sprite)
	if sprite == null and self.hasIndex("sprite") then sprite = self.sprite
	if sprite == null then return
	pw = self.world
	sprite.x = pw.x
	sprite.y = pw.y
	if self.hasIndex("flip") and self.flip then
		sprite.scale = [-pw.scale, pw.scale]
	else
		sprite.scale = pw.scale
	end if
	sprite.rotation = pw.rotation
end function

Transform.update = function
	if self._world.stale then self.world
	if self.hasIndex("sprite") then self.applyToSprite self.sprite
	for c in self.children; c.update; end for
end function

Transform.setXY = function(x, y, updateNow=true)
	self.local.x = x
	self.local.y = y
	self.markStale
	if updateNow then self.update
end function

Transform.setRotation = function(rotation, updateNow=true)
	self.local.rotation = rotation
	self.markStale
	if updateNow then self.update
end function

Transform.setScale = function(scale, updateNow=true)
	self.local.scale = scale
	self.markStale
	if updateNow then self.update
end function

Transform.pprint = function(indent=0)
	prs = self.local
	s = self.name + "(local: " + [prs.x, prs.y, prs.rotation, prs.scale].join(", ")
	prs = self.world
	s = s + "; world: " + [prs.x, prs.y, prs.rotation, prs.scale].join(", ") + ")"
	print "  " * indent + s
	for c in self.children
		c.pprint indent+1
	end for
end function

Transform.debugDisplay = function
	display(6).mode = displayMode.sprite
	if self.hasIndex("sprite") then
		if display(6).sprites.indexOf(self.sprite) == null then display(6).sprites.push self.sprite
		self.applyToSprite
	end if
	for c in self.children
		//gfx.line self.world.x, self.world.y, c.world.x, c.world.y, color.aqua
		c.debugDisplay
	end for
end function

if locals == globals then
	clear; gfx.clear color.clear
	display(6).mode = displayMode.sprite; display(6).clear

	base = Transform.make(480, 320, 0, 2, "base")
	base.sprite = new Sprite
	base.sprite.image = file.loadImage("/sys/pics/shapes/TriangleThickInv.png")

	a = Transform.make(100,0, 0, 1, "a")
	a.setParent base
	a.sprite = new Sprite
	a.sprite.image = file.loadImage("/sys/pics/shapes/SquareThickInv.png")

	b = Transform.make(50, 50, 45, 0.5, "b")
	b.setParent a
	b.sprite = new Sprite
	b.sprite.image = file.loadImage("/sys/pics/Wumpus.png")

	base.pprint
	base.debugDisplay
end if
