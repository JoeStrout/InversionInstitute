// This module adds a TTFont class, representing a TrueType font rendered
// with Raylib, with an API meant to mimic bmfFonts.Font.  That makes them
// mostly interchangeable to user code.

rl = raylib

TTFont = {}
TTFont._font = null  // Raylib font
TTFont._size = 0	 // loaded point size
TTFont.ascent = 0    // font ascent (best estimate)

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
	info = rl.GetGlyphInfo(font._font, "M".code)
	font.ascent = size - info.offsetY
	return font
end function

TTFont.unload = function
	if self._font then
		rl.UnloadFont(self._font)
		self._font = null
	end if
end function

// Render (draw) the given character to gfx, and return how
// far to shift the cursor.
TTFont.printChar = function(c, x=480, y=320, scale=1, tint="#FFFFFF")
	rl.BeginTextureMode gfx._renderTex
	rl.DrawTextCodepoint self._font, c.code, [x, gfx.height - y - self.ascent * scale], self._size * scale, tint
	rl.EndTextureMode
	info = rl.GetGlyphInfo(self._font, c.code)
	return info.advanceX
end function

// Print the given string to gfx at the given location.
TTFont.print = function(s, x=20, y=320, scale=1, tint="#FFFFFF")
	rl.BeginTextureMode gfx._renderTex
	size = self._size * scale
	rl.DrawTextEx self._font, s, [x, gfx.height - y - self.ascent * scale], size, 0, tint
	rl.EndTextureMode
end function

// Print the given string to gfx, centered horizontally on the given x.
TTFont.printCentered = function(s, x=480, y=320, scale=1, tint="#FFFFFF")
	self.print s, x - self.width(s, scale)/2, y, scale, tint
end function

// Print the given string to gfx, right-aligned on x.
TTFont.printRight = function(s, x=940, y=320, scale=1, tint="#FFFFFF")
	self.print s, x - self.width(s, scale), y, scale, tint
end function

// Return the width of the given string in this font.
TTFont.width = function(s, scale=1)
	return rl.MeasureTextEx(self._font, s, self._size * scale, 0).x
end function

if locals == globals then
	import "soda"
	
	f = TTFont.Load("fonts/NotoSerif-Regular.ttf")
	print "f._font: " + f._font
	x = 20; y = 0
	//for x in range(-600, 600, 100)
		x += f.printChar("A", x, y)
		x += f.printChar("b", x, y)
		x += f.printChar("c", x, y)
	//end for

	f.print "Hello world!", 400, 200
	w = f.width("Hello world!")
	gfx.line 400, 200, 400+w, 200, color.yellow
	f.print "Width of that was: " + w, 400, 150

	while true
		yield
		raylib.BeginDrawing
		soda.update
		raylib.EndDrawing		
	end while
	
end if