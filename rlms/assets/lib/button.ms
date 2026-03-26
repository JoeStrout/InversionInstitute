// Button class -- makes a handy clickable sprite!
// Just be sure to call .update on every frame.

sprites = null
if display(4).mode == displayMode.sprite then sprites = display(4).sprites

Button = new Sprite
Button.sortOrder = 0
Button.highlighted = false
Button.pressed = false
Button.instances = []
Button.shine = null // (list of shine frames)
Button.shineStep = 0
Button.tint = "#AABBB9"	// tint applied to buttons when not moused-over
Button.action = null
Button.keys = ""  // key(s) that can be pressed to activate this button

Button.init = function(image, leftx=null, midy=320, keys)
	if leftx == null then leftx = 480 - image.width/2
	self.image = image
	self.keys = keys
	self.x = leftx + image.width/2
	self.y = midy
	self.localBounds = new Bounds
	self.localBounds.width = image.width
	self.localBounds.height = image.height
	sprites.push self
	Button.instances.push self
end function

Button.make = function(image, leftx=null, midy=320, keys)
	noob = new Button
	noob.init image, leftx, midy, keys
	return noob
end function

Button.close = function
	idx = Button.instances.indexOf(self)
	if idx >= 0 then Button.instances.remove idx
	idx = sprites.indexOf(self)
	if idx >= 0 then sprites.remove idx
end function

Button.closeAll = function
	for inst in Button.instances[:]
		inst.close
	end for
end function

Button.highlight = function(hilightIt=true)
	if hilightIt then
		self.highlighted = true
		self.tint = color.white
		for b in Button.instances
			if b.highlighted and b != self then
				b.highlighted = false
				b.tint = Button.tint
			end if
		end for
	else
		self.highlighted = false
		self.tint = Button.tint
	end if
end function

Button.update = function
	if self.highlighted then
		if not self.contains(mouse) then self.highlight false
	else
		if self.contains(mouse) then self.highlight
	end if
	if self.contains(mouse) and mouse.button then
		stdX = self.x; stdY = self.y
		while mouse.button
			yield
			if self.contains(mouse) then
				self.x = stdX + 1; self.y = stdY - 2
				self.tint = color.white
			else
				self.tint = Button.tint
				self.x = stdX; self.y = stdY
			end if
		end while
		self.x = stdX; self.y = stdY
		if self.tint == color.white then
			self.action
		end if
		self.highlight false
	end if
	for k in self.keys
		if key.pressed(k) then
			self.tint = color.white
			wait 0.2
			self.action
			self.highlight false
		end if
	end for
end function

Button.updateAll = function
	for sp in Button.instances
		sp.update
	end for
end function
