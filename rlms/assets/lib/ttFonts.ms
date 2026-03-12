// This module adds a TTFont class, representing a TrueType font rendered
// with Raylib, with an API meant to mimic bmfFonts.Font.  That makes them
// mostly interchangeable to user code.

rl = raylib

TTFont = {}
TTFont._font = null  // Raylib font
TTFont._size = 0	 // loaded point size

TTFont.Load = function(path, size=24)
	// ToDo: provide a way to load more (non-ASCII) characters, perhaps
	// the standard Mini Micro character set?
	font = new TTFont
	font._font = rl.LoadFontEx(path, size)
	font._size = size
	if not font._font or not rl.IsFontValid(font._font) then
		print "ERROR: TTFont: unable to load font at " + path
		font._font = null
		exit
	end if
	return font
end function

TTFont.unload = function
	if self._font then
		rl.UnloadFont(self._font)
		self._font = null
	end if
end function

TTFont._beginDrawing = function(gfx)
	// Send drawing to the given PixelDisplay texture, and also swizzle around
	// the drawing matrix so it comes out right-side-up.  That flips all the triangles
	// we're about to draw, so we also have to turn backface culling off.
	rl.BeginTextureMode gfx._renderTex
	rl.rlPushMatrix
	rl.rlTranslatef 0, gfx.height, 0
	rl.rlScalef 1, -1, 1
	rl.rlDisableBackfaceCulling
end function

TTFont._endDrawing = function
	rl.rlDrawRenderBatchActive  // (force immediate draw, while backface culling is off)
	rl.rlEnableBackfaceCulling
	rl.rlPopMatrix
	rl.EndTextureMode
end function

// Render (draw) the given character to gfx, and return how
// far to shift the cursor.  This uses the image cache, so
// it gets faster after the first drawing of each character.
TTFont.printChar = function(c, x=480, y=320, scale=1, tint="#FFFFFF")
	self._beginDrawing gfx
	rl.DrawTextCodepoint self._font, c.code, [x, y], self._size * scale, tint
	self._endDrawing
	info = rl.GetGlyphInfo(self._font, c.code)
	return info.advanceX
end function

// Print the given string to gfx at the given location.
TTFont.print = function(s, x=20, y=320, scale=1, tint="#FFFFFF")
	self._beginDrawing gfx
	rl.DrawTextEx self._font, s, [x, gfx.height - y], self._size * scale, 0, tint
	self._endDrawing
end function

//// Print the given string to gfx, centered horizontally on the given x.
//Font.printCentered = function(s, x=480, y=320, scale=1, tint="#FFFFFF")
//	self.print s, x - self.width(s, scale)/2, y, scale, tint
//end function
//
//// Print the given string to gfx, right-aligned on x.
//Font.printRight = function(s, x=940, y=320, scale=1, tint="#FFFFFF")
//	self.print s, x - self.width(s, scale), y, scale, tint
//end function
//
//// Return the width of the given string in this font.
//Font.width = function(s, scale=1)
//	sum = 0
//	lastc = ""
//	for c in s
//		d = self.charData(c)
//		if d == null then continue
//		sum = sum + (d.shift + self.addSpace + self.kern(lastc, c)) * scale
//		lastc = c
//	end for
//	return sum
//end function

if locals == globals then
	import "soda"
	
	gfx.clear color.green
	
	f = TTFont.Load("fonts/NotoSerif-Regular.ttf")
	print "f._font: " + f._font
	x = 20; y = 0
	//for x in range(-600, 600, 100)
		x += f.printChar("A", x, y)
		x += f.printChar("b", x, y)
		x += f.printChar("c", x, y)
	//end for

	f.print "Hello world!", 400, 200

	while true
		yield
		raylib.BeginDrawing
		soda.update
		raylib.EndDrawing		
	end while
	
end if