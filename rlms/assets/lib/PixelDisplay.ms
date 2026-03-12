// PixelDisplay: a retained-mode pixel drawing surface,
// compatible with the Mini Micro PixelDisplay API.
// Backed by a raylib RenderTexture.

import "importUtil"
ensureImport "Display"
ensureImport "color"

colorToList = @color.toList
colorFromList = @color.fromList

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

// Begin drawing to the render texture in "replace" blend mode,
// so that drawn colors fully overwrite the destination (matching
// Mini Micro behavior, where alpha < 255 does not blend).
PixelDisplay._beginDraw = function
	rl.BeginTextureMode self._renderTex
	rl.rlSetBlendFactors 1, 0, 32774    // GL_ONE, GL_ZERO, GL_FUNC_ADD
	rl.BeginBlendMode 6                 // BLEND_CUSTOM
end function

PixelDisplay._endDraw = function
	rl.EndBlendMode
	rl.EndTextureMode
end function

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
	self.fillRect 0, 0, width, height, color
end function

// Set a single pixel.  Uses self.color if color is not specified.
PixelDisplay.setPixel = function(x, y, color=null)
	if color == null then color = self.color
	color = colorToList(color)
	self._beginDraw
	rl.DrawPixel x+0.5, self.height - 1 - y + 0.5, color
	self._endDraw
end function

// Get the color of a pixel, as a hex string (e.g. "#FF0000FF").
// NOTE: this is rather expensive.  If you are going to do it a lot,
// instead call getImage on the display, then get pixels of that.
PixelDisplay.pixel = function(x, y)
	img = rl.LoadImageFromTexture(self._renderTex.texture)
	c = rl.GetImageColor(img, x, y)
	rl.UnloadImage img
	return colorFromList(c)
end function

// Draw a straight line.
PixelDisplay.line = function(x1=0, y1=0, x2=960, y2=640, color, penSize=1)
	if color == null then color = self.color
	color = colorToList(color)
	self._beginDraw
	h = 0.5  // offset to properly address pixel coordinates
	rl.DrawLineEx([x1+h, self.height-y1+h], [x2+h, self.height-y2+h], penSize, color)
	self._endDraw
end function

// Draw a axis-aligned rectangle outline on the pixel display.
PixelDisplay.drawRect = function(left=0, bottom=0, width=100, height=100, color=null)
	if color == null then color = self.color
	color = colorToList(color)
	self._beginDraw
	rl.DrawRectangleLines left, self.height - bottom - height, width, height, color
	self._endDraw
end function

// Fill an axis-aligned rectangle on the pixel display.
PixelDisplay.fillRect = function(left=0, bottom=0, width=100, height=100, color=null)
	if color == null then color = self.color
	color = colorToList(color)
	self._beginDraw
	rl.DrawRectangle left, self.height - bottom - height, width, height, color
	self._endDraw
end function

// Draw a axis-aligned ellipse outline on the pixel display.
PixelDisplay.drawEllipse = function(left=0, bottom=0, width=100, height=100, color=null)
	if color == null then color = self.color
	color = colorToList(color)
	self._beginDraw
	rl.DrawEllipseLines left + width/2, self.height - bottom - height/2, width/2, height/2, color
	self._endDraw
end function

// Fill an axis-aligned ellipse on the pixel display.
PixelDisplay.fillEllipse = function(left=0, bottom=0, width=100, height=100, color=null)
	if color == null then color = self.color
	color = colorToList(color)
	self._beginDraw
	rl.DrawEllipse left + width/2, self.height - bottom - height/2, width/2, height/2, color
	self._endDraw
end function


// Get a rectangular region of the display as an Image.
// Requires the Image module.
PixelDisplay.getImage = function(left=0, bottom=0, width, height)
	fullImg = rl.LoadImageFromTexture(self._renderTex.texture)
	if width == null then width = self.width
	if height == null then height = self.height
	if left == 0 and bottom == 0 and width == self.width and height == self.height then
		subImg = fullImg
	else
		subImg = rl.ImageFromImage(fullImg, [left, bottom, width, height])
		rl.UnloadImage fullImg
	end if
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
	// Source rect in texture coords (y=0 at top).
	srcY = img.height - srcBottom - srcHeight
	src = [srcLeft, srcY, srcWidth, srcHeight]
	dest = [left, self.height - bottom - height, width, height]
	self._beginDraw
	rl.DrawTexturePro tex, src, dest, [0, 0], 0, [255, 255, 255, 255]
	self._endDraw
	rl.UnloadTexture tex
end function

// Draw this PixelDisplay to the screen (call during BeginDrawing/EndDrawing).
// Uses negative source height to flip the render texture vertically.
// Drawing functions flip Y coords so content is upside-down in the texture;
// this flip corrects it, giving us Mini Micro's bottom-up coordinate system.
PixelDisplay.render = function
	src = [0, 0, self.width, -self.height]
	w = self.width * self.scale
	h = self.height * self.scale
	top = rl.GetScreenHeight - h
	dest = [-self.scrollX, top + self.scrollY, w, h]
	rl.DrawTexturePro self._renderTex.texture, src, dest, [0, 0], 0, [255, 255, 255, 255]
end function

return PixelDisplay
