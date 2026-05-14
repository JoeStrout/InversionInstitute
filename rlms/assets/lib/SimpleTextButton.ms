
NORMAL = "NORMAL"
HOVER = "HOVER"
PRESSED = "PRESSED"

SimpleTextButton = {}
SimpleTextButton.font = null
SimpleTextButton.state = NORMAL
SimpleTextButton.Instances = []
SimpleTextButton.background = null  // color, Image, or null
SimpleTextButton.hidden = false  // if true, draws background, but no text
SimpleTextButton.enabled = true

SimpleTextButton.Make = function(text, x, y)
	if self.font == null then self.font = ttFonts.TTFont.Load("fonts/MorrisRoman-Black.ttf", 48)
	noob = new self
	noob.text = text
	noob.x = x
	noob.y = y
	self.Instances.push noob
	return noob
end function

SimpleTextButton.bounds = function
	w = self.font.width(self.text) + 16
	h = self.font.lineHeight
	top = self.y + self.font.ascent
	return Rect.Make(self.x - w/2, top - h, w, h)
end function 

SimpleTextButton.contains = function(xy)
	return self.bounds.contains(xy)
end function

SimpleTextButton.draw = function
	if self.background isa string then
		self.bounds.fill gfx, self.background
	else if self.background isa Image then
		// Note: we draw the whole background image, unscaled, centered on
		// our bounds; this may be smaller or larger than our actual bounds.
		b = self.bounds
		gfx.drawImage self.background, 
		  b.midX - self.background.width/2, b.midY - self.background.height/2
	end if
	if self.hidden then return
	
	if not self.enabled then
		c = "#666666"
	else if self.state == HOVER then
		c = "#0088FF"
	else if self.state == PRESSED then
		c = "#008888"
	else
		c = color.black
	end if
	self.font.printCentered self.text, self.x, self.y, 1, c
	if not self.enabled then
		w = self.font.width(self.text)
		y = self.y + self.font.ascent * 0.25
		gfx.line self.x - w/2 - 5, y, self.x + w/2 + 5, y, c
	end if
end function

SimpleTextButton.action = function
	print "Clicked: " + self.text
end function

SimpleTextButton.update = function
	doAction = false
	hover = self.contains(mouse) and self.enabled and not self.hidden
	if hover and mouse.button then
		// track until mouse released!
		while mouse.button
			if self.contains(mouse) then newState = PRESSED else newState = NORMAL
			if newState != self.state then
				self.state = newState
				self.draw
			end if
			yield
		end while
		if self.state == PRESSED then doAction = true
		self.state = NORMAL
	else
		if hover == (self.state == HOVER) then return
		if hover then self.state = HOVER else self.state = NORMAL
	end if
	self.draw 
	if doAction then self.action
end function

SimpleTextButton.UpdateAll = function
	for btn in self.Instances; btn.update; end for
end function

return SimpleTextButton
