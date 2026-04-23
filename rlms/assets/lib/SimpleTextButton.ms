
NORMAL = "NORMAL"
HOVER = "HOVER"
PRESSED = "PRESSED"

SimpleTextButton = {}
SimpleTextButton.font = null
SimpleTextButton.state = NORMAL
SimpleTextButton.Instances = []

SimpleTextButton.Make = function(text, x, y)
	if self.font == null then self.font = ttFonts.TTFont.Load("fonts/MorrisRoman-Black.ttf", 48)
	noob = new self
	noob.text = text
	noob.x = x
	noob.y = y
	self.Instances.push noob
	return noob
end function

SimpleTextButton.contains = function(xy)
	w = self.font.width(self.text)
	top = self.y + self.font.ascent
	if not (self.x - w/2 <= xy.x < self.x + w/2) then return false
	if not (top - self.font.lineHeight <= xy.y <= top) then return false
	return true
end function

SimpleTextButton.draw = function
	if self.state == HOVER then
		c = "#0088FF"
	else if self.state == PRESSED then
		c = "#008888"
	else
		c = color.black
	end if
	self.font.printCentered self.text, self.x, self.y, 1, c
end function

SimpleTextButton.action = function
	print "Clicked: " + self.text
end function

SimpleTextButton.update = function
	doAction = false
	hover = self.contains(mouse)
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
