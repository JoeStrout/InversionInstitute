//---------------------------------------------------------------------
// Make a handy Rect class
globals.Rect = {}
Rect.left = 0
Rect.bottom = 0
Rect.width = 0
Rect.height = 0

Rect.area = function; return self.width * self.height; end function

Rect.right = function; return self.left + self.width; end function

Rect.top = function; return self.bottom + self.height; end function

Rect.midX = function; return self.left + self.width/2; end function

Rect.midY = function; return self.bottom + self.height/2; end function

Rect.area = function; return self.width * self.height; end function

Rect.str = function
	return "Rect(" + self.left + ", " + self.bottom + ", " + self.width + ", " + self.height + ")"
end function

Rect.Make = function(left, bottom, width, height)
	r = new Rect
	r.left = left
	r.bottom = bottom
	r.width = width
	r.height = height
	return r
end function

Rect.MakeFromCenter = function(midX, midY, width=0, height=0)
	r = new Rect
	r.left = midX - width/2
	r.bottom = midY - height/2
	r.width = width
	r.height = height
	return r
end function

Rect.MakeFromPoints = function(p0, p1, padding=1)
	if p0 == null then
		if p1 == null then return null
		return Rect.MakeFromCenter(p1.x, p1.y)
	end if
	r = new Rect
	if p0.x < p1.x then
		r.left = p0.x
		r.width = p1.x - p0.x + padding
	else
		r.left = p1.x
		r.width = p0.x - p1.x + padding
	end if
	if p0.y < p1.y then
		r.bottom = p0.y
		r.height = p1.y - p0.y + padding
	else
		r.bottom = p1.y
		r.height = p0.y - p1.y + padding
	end if
	return r
end function

Rect.offset = function(dx, dy)
	return Rect.Make(self.left + dx, self.bottom + dy, self.width, self.height)
end function

Rect.grow = function(dwidth, dheight)
	return Rect.Make(self.left, self.bottom, self.width + dwidth, self.height + dheight)
end function

Rect.expandToContain = function(pt)
	right = self.left + self.width
	top = self.bottom + self.height
	if pt.x < self.left then self.left = pt.x
	if pt.x > right then right = pt.x
	if pt.y < self.bottom then self.bottom = pt.y
	if pt.y > top then top = pt.y
	self.width = right - self.left
	self.height = top - self.bottom
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
	   color // TODO: , lineWidth
end function

Rect.frameEllipse = function(gfx, color=null, lineWidth=1, inset=0)
	gfx.drawEllipse self.left+inset, self.bottom+inset,
	   self.width-inset*2, self.height-inset*2,
	   color // TODO: , lineWidth
end function

