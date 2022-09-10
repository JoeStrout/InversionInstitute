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
		r.width = p1.x - p0.x + 1
	else
		r.left = p1.x
		r.width = p0.x - p1.x + 1
	end if
	if p0.y < p1.y then
		r.bottom = p0.y
		r.height = p1.y - p0.y + 1
	else
		r.bottom = p1.y
		r.height = p0.y - p1.y + 1
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

