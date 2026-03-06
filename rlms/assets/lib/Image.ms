// Image: a pixel buffer compatible with the Mini Micro Image class.
// Backed by a raylib Image (CPU-side pixel data).
//
// Internally, pixel data is stored in raylib orientation (y=0 at top).
// All public methods use Mini Micro orientation (y=0 at bottom).

rl = raylib

// --- Color utility functions ---

hexDigitVal = function(c)
	code = c.code
	if code >= 48 and code <= 57 then return code - 48
	if code >= 65 and code <= 70 then return code - 55
	if code >= 97 and code <= 102 then return code - 87
	return 0
end function

colorToRGBA = function(s)
	if s isa list then return s
	if not s isa string or s.len < 7 or s[0] != "#" then return [255, 255, 255, 255]
	r = hexDigitVal(s[1]) * 16 + hexDigitVal(s[2])
	g = hexDigitVal(s[3]) * 16 + hexDigitVal(s[4])
	b = hexDigitVal(s[5]) * 16 + hexDigitVal(s[6])
	if s.len >= 9 then
		a = hexDigitVal(s[7]) * 16 + hexDigitVal(s[8])
	else
		a = 255
	end if
	return [r, g, b, a]
end function

_hexDigits = "0123456789ABCDEF"
rgbaToColor = function(c)
	s = "#"
	s = s + _hexDigits[floor(c.r / 16)] + _hexDigits[c.r % 16]
	s = s + _hexDigits[floor(c.g / 16)] + _hexDigits[c.g % 16]
	s = s + _hexDigits[floor(c.b / 16)] + _hexDigits[c.b % 16]
	s = s + _hexDigits[floor(c.a / 16)] + _hexDigits[c.a % 16]
	return s
end function

// --- Image class ---

Image = {}
Image._img = null	// raylib Image map
Image.width = 0
Image.height = 0

// Create a new Image filled with the given color.
Image.create = function(width, height, color="#00000000")
	result = new Image
	result._img = rl.GenImageColor(width, height, colorToRGBA(color))
	result.width = width
	result.height = height
	return result
end function

// Wrap an existing raylib Image map as an Image instance.
Image._fromRaylibImage = function(rImg)
	result = new Image
	result._img = rImg
	result.width = rImg.width
	result.height = rImg.height
	return result
end function

// Get the color of a pixel as a "#RRGGBBAA" string.
Image.pixel = function(x, y)
	ry = self.height - 1 - y
	c = rl.GetImageColor(self._img, x, ry)
	return rgbaToColor(c)
end function

// Set the color of a pixel.
Image.setPixel = function(x, y, color)
	ry = self.height - 1 - y
	rl.ImageDrawPixel self._img, x, ry, colorToRGBA(color)
end function

// Extract a rectangular sub-region as a new Image.
Image.getImage = function(left, bottom, width, height)
	ry = self.height - bottom - height
	subImg = rl.ImageFromImage(self._img, [left, ry, width, height])
	return Image._fromRaylibImage(subImg)
end function

// Flip the image in place.
// vertical=true flips top/bottom; vertical=false (default) flips left/right.
Image.flip = function(vertical=false)
	if vertical then
		rl.ImageFlipVertical self._img
	else
		rl.ImageFlipHorizontal self._img
	end if
end function

// Rotate the image in place, counter-clockwise, in 90-degree increments.
Image.rotate = function(degrees=90)
	degrees = degrees % 360
	if degrees < 0 then degrees = degrees + 360
	if degrees == 90 then
		rl.ImageRotateCCW self._img
	else if degrees == 180 then
		rl.ImageRotateCCW self._img
		rl.ImageRotateCCW self._img
	else if degrees == 270 then
		rl.ImageRotateCW self._img
	end if
	self.width = self._img.width
	self.height = self._img.height
end function

// Add a load method to the global file module.
file.loadImage = function(path)
	rImg = rl.LoadImage(path)
	if rImg == null then return null
	return Image._fromRaylibImage(rImg)
end function


return Image
