// PixelDisplay: a retained-mode pixel drawing surface,
// compatible with the Mini Micro PixelDisplay API.
// Backed by a raylib RenderTexture.

rl = raylib

// Convert a hex digit character to its numeric value (0-15).
hexDigitVal = function(c)
	code = c.code
	if code >= 48 and code <= 57 then return code - 48
	if code >= 65 and code <= 70 then return code - 55
	if code >= 97 and code <= 102 then return code - 87
	return 0
end function

// Convert a Mini Micro color string ("#RRGGBB" or "#RRGGBBAA")
// to a raylib [r, g, b, a] list.
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

PixelDisplay = {}
PixelDisplay.color = [255, 255, 255, 255]
PixelDisplay.scale = 1
PixelDisplay.scrollX = 0
PixelDisplay.scrollY = 0
PixelDisplay.width = 960
PixelDisplay.height = 640
PixelDisplay._renderTex = null

// Create a new PixelDisplay with the given size.
PixelDisplay.Make = function(width=960, height=640)
	result = new self
	result.width = width
	result.height = height
	result._renderTex = rl.LoadRenderTexture(width, height)
	result.clear
	return result
end function


// Clear the display.  Optionally change the size and/or clear color.
PixelDisplay.clear = function(color=null, width=960, height=640)
	if width != self.width or height != self.height then
		if self._renderTex != null then rl.UnloadRenderTexture self._renderTex
		self.width = width
		self.height = height
		self._renderTex = rl.LoadRenderTexture(width, height)
	end if
	if color == null then color = [0, 0, 0, 0]
	color = colorToRGBA(color)
	rl.BeginTextureMode self._renderTex
	rl.ClearBackground color
	rl.EndTextureMode
end function

// Set a single pixel.  Uses self.color if color is not specified.
PixelDisplay.setPixel = function(x, y, color=null)
	if color == null then color = self.color
	color = colorToRGBA(color)
	rl.BeginTextureMode self._renderTex
	rl.DrawPixel x, y, color
	rl.EndTextureMode
end function

// Draw a axis-aligned rectangle outline on the pixel display.
PixelDisplay.drawRect = function(left=0, bottom=0, width=100, height=100, color=null)
	if color == null then color = self.color
	color = colorToRGBA(color)
	rl.BeginTextureMode self._renderTex
	rl.DrawRectangleLines left, bottom, width, height, color
	rl.EndTextureMode
end function

// Fill an axis-aligned rectangle on the pixel display.
PixelDisplay.fillRect = function(left=0, bottom=0, width=100, height=100, color=null)
	if color == null then color = self.color
	color = colorToRGBA(color)
	rl.BeginTextureMode self._renderTex
	rl.DrawRectangle left, bottom, width, height, color
	rl.EndTextureMode
end function

// Draw a axis-aligned ellipse outline on the pixel display.
PixelDisplay.drawEllipse = function(left=0, bottom=0, width=100, height=100, color=null)
	if color == null then color = self.color
	color = colorToRGBA(color)
	rl.BeginTextureMode self._renderTex
	rl.DrawEllipseLines left + width/2, bottom + height/2, width/2, height/2, color
	rl.EndTextureMode
end function

// Fill an axis-aligned ellipse on the pixel display.
PixelDisplay.fillEllipse = function(left=0, bottom=0, width=100, height=100, color=null)
	if color == null then color = self.color
	color = colorToRGBA(color)
	rl.BeginTextureMode self._renderTex
	rl.DrawEllipse left + width/2, bottom + height/2, width/2, height/2, color
	rl.EndTextureMode
end function


// Draw this PixelDisplay to the screen (call during BeginDrawing/EndDrawing).
// Uses positive source height (no flip) so that the RenderTexture's natural
// Y-inversion gives us Mini Micro's bottom-up coordinate system.
PixelDisplay.render = function
	w = self.width * self.scale
	h = self.height * self.scale
	src = [0, 0, self.width, self.height]
	dest = [self.scrollX, self.scrollY, w, h]
	rl.DrawTexturePro self._renderTex.texture, src, dest, [0, 0], 0, [255, 255, 255, 255]
end function

return PixelDisplay
