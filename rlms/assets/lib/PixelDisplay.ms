// PixelDisplay: a retained-mode pixel drawing surface,
// compatible with the Mini Micro PixelDisplay API.
// Backed by a raylib RenderTexture.

import "importUtil"
ensureImport "Display"

colorToList = @color.toList

rl = raylib

PixelDisplay = new Display
PixelDisplay.mode = displayMode.pixel
PixelDisplay.color = [255, 255, 255, 255]
PixelDisplay.scale = 1
PixelDisplay.scrollX = 0
PixelDisplay.scrollY = 0
PixelDisplay.width = 960
PixelDisplay.height = 640
PixelDisplay._renderTex = null

// Create a new PixelDisplay with the given size.
PixelDisplay.Make = function(width=960, height=640, color="#00000000")
	result = new self
	result.width = width
	result.height = height
	result._renderTex = rl.LoadRenderTexture(width, height)
	result.fillRect 0, 0, width, height, color
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
	result.fillRect 0, 0, width, height, color
end function

// Set a single pixel.  Uses self.color if color is not specified.
PixelDisplay.setPixel = function(x, y, color=null)
	if color == null then color = self.color
	color = colorToList(color)
	rl.BeginTextureMode self._renderTex
	rl.DrawPixel x, y, color
	rl.EndTextureMode
end function

// Draw a axis-aligned rectangle outline on the pixel display.
PixelDisplay.drawRect = function(left=0, bottom=0, width=100, height=100, color=null)
	if color == null then color = self.color
	color = colorToList(color)
	rl.BeginTextureMode self._renderTex
	rl.DrawRectangleLines left, bottom, width, height, color
	rl.EndTextureMode
end function

// Fill an axis-aligned rectangle on the pixel display.
PixelDisplay.fillRect = function(left=0, bottom=0, width=100, height=100, color=null)
	if color == null then color = self.color
	color = colorToList(color)
	rl.BeginTextureMode self._renderTex
	rl.DrawRectangle left, bottom, width, height, color
	rl.EndTextureMode
end function

// Draw a axis-aligned ellipse outline on the pixel display.
PixelDisplay.drawEllipse = function(left=0, bottom=0, width=100, height=100, color=null)
	if color == null then color = self.color
	color = colorToList(color)
	rl.BeginTextureMode self._renderTex
	rl.DrawEllipseLines left + width/2, bottom + height/2, width/2, height/2, color
	rl.EndTextureMode
end function

// Fill an axis-aligned ellipse on the pixel display.
PixelDisplay.fillEllipse = function(left=0, bottom=0, width=100, height=100, color=null)
	if color == null then color = self.color
	color = colorToList(color)
	rl.BeginTextureMode self._renderTex
	rl.DrawEllipse left + width/2, bottom + height/2, width/2, height/2, color
	rl.EndTextureMode
end function


// Get a rectangular region of the display as an Image.
// Requires the Image module.
PixelDisplay.getImage = function(left, bottom, width, height)
	fullImg = rl.LoadImageFromTexture(self._renderTex.texture)
	ry = self.height - bottom - height
	subImg = rl.ImageFromImage(fullImg, [left, ry, width, height])
	rl.UnloadImage fullImg
	return Image.FromRaylibImage(subImg)
end function

// Draw an Image onto this PixelDisplay.
PixelDisplay.drawImage = function(img, left, bottom, width=null, height=null, srcLeft=0, srcBottom=0, srcWidth=null, srcHeight=null)
	if width == null then width = img.width
	if height == null then height = img.height
	if srcWidth == null then srcWidth = img.width
	if srcHeight == null then srcHeight = img.height
	// Create a temp texture from the image
	tex = rl.LoadTextureFromImage(img._img)
	// Source rect in texture coords (y=0 at top), with negative height to
	// flip vertically — compensating for the render texture's Y-inversion.
	srcY = img.height - srcBottom - srcHeight
	src = [srcLeft, srcY, srcWidth, -srcHeight]
	dest = [left, bottom, width, height]
	rl.BeginTextureMode self._renderTex
	rl.DrawTexturePro tex, src, dest, [0, 0], 0, [255, 255, 255, 255]
	rl.EndTextureMode
	rl.UnloadTexture tex
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
