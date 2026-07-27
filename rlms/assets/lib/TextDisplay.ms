import "importUtil"
ensureImport ["Display", "ttFonts", "listUtil", "color", "qa"]

// TextDisplay reads screen size and loads a texture as soon as this module
// loads, so (unlike most Display subclasses) it needs a live GL context up
// front.  Normally soda.ms has already created the window by the time this
// runs; this guard just makes the module (and its self-tests) work when
// run standalone too.
if not raylib.IsWindowReady then raylib.InitWindow 960, 640

globals.TextDisplayCell = {}
TextDisplayCell.character = ""
TextDisplayCell.color = color.aqua
TextDisplayCell.backColor = color.clear
TextDisplayCell.inverse = false

TextDisplayCell.Make = function(fg=null, bg=null, inv=false)
  noob = new TextDisplayCell
  if fg == null then fg = color.aqua
  if bg == null then bg = color.clear
  noob.color = fg
  noob.backColor = bg
  noob.inverse = inv
  return noob
end function

TextDisplay = new Display
TextDisplay.mode = displayMode.text

TextDisplay.Make = function
  return new TextDisplay
end function
TextDisplay.charW = 8
TextDisplay.charH = 8
TextDisplay.padX = 1
TextDisplay.padY = 2
TextDisplay.gridW = floor(raylib.GetScreenWidth / (TextDisplay.charW + TextDisplay.padX))
TextDisplay.gridH = floor(raylib.GetScreenHeight / (TextDisplay.charH + TextDisplay.padY))
TextDisplay.offsetX = floor((raylib.GetScreenWidth - ((TextDisplay.charW + TextDisplay.padX) * TextDisplay.gridW)) / 2)
TextDisplay.offsetY = floor((raylib.GetScreenHeight - ((TextDisplay.charH + TextDisplay.padY) * TextDisplay.gridH)) / 2)
TextDisplay.grid = null
TextDisplay.fontImage = null
TextDisplay._fontCols = 16   // columns of glyphs in the font sheet

TextDisplay.color	= color.aqua      // get or set the text color (used on subsequent TextDisplay.print)
TextDisplay.backColor = color.clear	// get or set the background color (used on subsequent TextDisplay.print)
TextDisplay.column = 0	            // get/set the cursor column, 0-67 (where subsequent TextDisplay.print begins)
TextDisplay.row	   = 0              // get or set the cursor row, 0-25 (used on subsequent TextDisplay.print)
TextDisplay.inverse	= false         // when true, subsequent printing swaps text and background color
TextDisplay.delimiter	= char(13)    // get/set the extra character output after every TextDisplay.print)

// Loads a new font sheet (a grid of charW x charH glyphs, in ASCII order),
// and resizes the text grid to fit the screen using the new character size.
TextDisplay.setFont = function(path, charW=8, charH=8)
  self.fontImage = raylib.LoadTexture(path)
  raylib.SetTextureFilter self.fontImage, raylib.TEXTURE_FILTER_POINT
  self.charW = charW
  self.charH = charH
  self._fontCols = floor(self.fontImage.width / self.charW)
  self.gridW = floor(raylib.GetScreenWidth / (self.charW + self.padX))
  self.gridH = floor(raylib.GetScreenHeight / (self.charH + self.padY))
  self.offsetX = floor((raylib.GetScreenWidth - ((self.charW + self.padX) * self.gridW)) / 2)
  self.offsetY = floor((raylib.GetScreenHeight - ((self.charH + self.padY) * self.gridH)) / 2)
  self.clear
end function

// get the character at the given column and row
TextDisplay.cell = function(x, y)
  return self.grid[y][x].character
end function

// store character k into the given column and row
TextDisplay.setCell = function(x, y, k)
  self.grid[y][x].character = k
end function

// get the text color at the given column and row
TextDisplay.cellColor = function(x, y)
  return self.grid[y][x].color
end function

// set the text color at the given column and row to c
TextDisplay.setCellColor = function(x, y, c)
  self.grid[y][x].color = c
end function

// get the background color at the given column and row
TextDisplay.cellBackColor = function(x, y)
  return self.grid[y][x].backColor
end function

// set the background color at the given column and row to c
TextDisplay.setCellBackColor = function(x, y, c)
  self.grid[y][x].backColor = c
end function

// Internal: move the cursor to the start of the next row, scrolling
// the grid up by one row if the cursor would go past the bottom.
TextDisplay._newLine = function
  self.column = 0
  self.row += 1
  if self.row >= self.gridH then
    for r in range(0, self.gridH - 2)
      self.grid[r] = self.grid[r + 1]
    end for
    self.grid[self.gridH - 1] = list.init(self.gridW, null)
    for c in range(0, self.gridW - 1)
      self.grid[self.gridH - 1][c] = new TextDisplayCell
    end for
    self.row = self.gridH - 1
  end if
end function

// Internal: write a single character at the cursor and advance it,
// wrapping and/or scrolling as needed.  Handles CR/LF as a newline.
TextDisplay._putChar = function(c)
  if c.code == 13 or c.code == 10 then
    self._newLine
    return
  end if
  if self.column >= self.gridW then self._newLine
  cell = self.grid[self.row][self.column]
  cell.character = c
  if self.inverse then
    cell.color = self.backColor
    cell.backColor = self.color
  else
    cell.color = self.color
    cell.backColor = self.backColor
  end if
  cell.inverse = self.inverse
  self.column += 1
end function

// print string s (followed by the delimiter d, which defaults to self.delimiter)
TextDisplay.print = function(s, d=null)
  if d == null then d = self.delimiter
  if s == null then s = ""
  for c in s
    self._putChar c
  end for
  for c in d
    self._putChar c
  end for
end function

// Clears and resets TextDisplay
TextDisplay.clear = function
  self.grid = list.init2d(self.gridH, self.gridW, null)
  for row in range(0, self.gridH - 1)
    for col in range(0, self.gridW - 1)
      self.grid[row][col] = new TextDisplayCell
    end for
  end for
  self.column = 0
  self.row = 0
end function

// Internal: source rect into fontImage for the given character.
// The sheet's cell 0 holds code point 1, not 0 (cell 0 = SOH, always
// blank), so every code is shifted down by one cell.
TextDisplay._srcRectFor = function(c)
  index = c.code - 1
  col = index % self._fontCols
  row = floor(index / self._fontCols)
  return [col * self.charW, row * self.charH, self.charW, self.charH]
end function

// Draw text grid
TextDisplay.render = function
  if self.fontImage == null then return
  for row in range(0, self.gridH - 1)
    for col in range(0, self.gridW - 1)
      cell = self.grid[row][col]
      x = self.offsetX + col * (self.charW + self.padX)
      y = self.offsetY + row * (self.charH + self.padY)
      if cell.backColor != color.clear then
        // fill the full cell pitch (not just the glyph box), so the padding
        // gap between cells doesn't show through as a gap between fills
        raylib.DrawRectangle x, y, self.charW + self.padX, self.charH + self.padY, color.toList(cell.backColor)
      end if
      if cell.character != "" then
        src = self._srcRectFor(cell.character)
        // center the glyph within the cell pitch, rather than flush against
        // its top-left, so the backColor padding is split evenly around it
        glyphX = x + floor(self.padX / 2)
        glyphY = y + floor(self.padY / 2)
        dest = [glyphX, glyphY, self.charW, self.charH]
        raylib.DrawTexturePro self.fontImage, src, dest, [0, 0], 0, color.toList(cell.color)
      end if
    end for
  end for
end function

TextDisplay.setFont "assets/lib/font/TextUI.png"

if locals == globals then
  import "soda"

	print "== Pure logic tests (no rendering needed) =="

	print "clear resets the grid shape and cursor"
	TextDisplay.clear
	qa.assert TextDisplay.grid.len == TextDisplay.gridH, "grid should have gridH rows"
	qa.assert TextDisplay.grid[0].len == TextDisplay.gridW, "grid should have gridW columns"
	qa.assertEqual TextDisplay.column, 0, "clear should reset column"
	qa.assertEqual TextDisplay.row, 0, "clear should reset row"
	qa.assertEqual TextDisplay.cell(0, 0), "", "new cells should be blank"

	print "setCell / cell round-trip"
	TextDisplay.clear
	TextDisplay.setCell 3, 2, "Q"
	qa.assertEqual TextDisplay.cell(3, 2), "Q", "setCell then cell should return 'Q'"
	qa.assertEqual TextDisplay.cell(0, 0), "", "untouched cells should remain blank"

	print "setCellColor / cellColor and setCellBackColor / cellBackColor round-trip"
	TextDisplay.clear
	TextDisplay.setCellColor 1, 1, color.red
	TextDisplay.setCellBackColor 1, 1, color.blue
	qa.assertEqual TextDisplay.cellColor(1, 1), color.red, "cell color should round-trip"
	qa.assertEqual TextDisplay.cellBackColor(1, 1), color.blue, "cell backColor should round-trip"

	print "print writes characters at the cursor and advances the column"
	TextDisplay.clear
	TextDisplay.column = 5
	TextDisplay.row = 2
	TextDisplay.print "Hi", ""
	qa.assertEqual TextDisplay.cell(5, 2), "H", "first char should land at the starting column"
	qa.assertEqual TextDisplay.cell(6, 2), "i", "second char should land one column over"
	qa.assertEqual TextDisplay.column, 7, "column should advance past the printed text"
	qa.assertEqual TextDisplay.row, 2, "row should be unchanged with an empty delimiter"

	print "print applies the current color, backColor and inverse to each cell"
	TextDisplay.clear
	TextDisplay.color = color.yellow
	TextDisplay.backColor = color.navy
	TextDisplay.inverse = false
	TextDisplay.print "A", ""
	qa.assertEqual TextDisplay.cellColor(0, 0), color.yellow, "non-inverse cell color should be the fg color"
	qa.assertEqual TextDisplay.cellBackColor(0, 0), color.navy, "non-inverse cell backColor should be the bg color"
	TextDisplay.inverse = true
	TextDisplay.print "B", ""
	qa.assertEqual TextDisplay.cellColor(1, 0), color.navy, "inverse cell color should be swapped with backColor"
	qa.assertEqual TextDisplay.cellBackColor(1, 0), color.yellow, "inverse cell backColor should be swapped with color"
	TextDisplay.inverse = false

	print "print's default delimiter starts a new line"
	TextDisplay.clear
	TextDisplay.print "Hi"
	qa.assertEqual TextDisplay.column, 0, "default delimiter should return column to 0"
	qa.assertEqual TextDisplay.row, 1, "default delimiter should advance to the next row"

	print "print wraps to the next row when it reaches the right edge"
	TextDisplay.clear
	TextDisplay.column = TextDisplay.gridW - 1
	TextDisplay.row = 0
	TextDisplay.print "XY", ""
	qa.assertEqual TextDisplay.cell(TextDisplay.gridW - 1, 0), "X", "last char of row 0 should hold X"
	qa.assertEqual TextDisplay.cell(0, 1), "Y", "wrapped char should land at column 0 of the next row"
	qa.assertEqual TextDisplay.row, 1, "cursor row should have advanced on wrap"
	qa.assertEqual TextDisplay.column, 1, "cursor column should be 1 after the wrapped char"

	print "print scrolls the grid up when it overflows the bottom row"
	TextDisplay.clear
	TextDisplay.setCell 0, 1, "T"   // row 1, so it survives the scroll by becoming row 0
	TextDisplay.column = TextDisplay.gridW - 1
	TextDisplay.row = TextDisplay.gridH - 1
	TextDisplay.print "YZ", ""     // Y fills the last cell of the bottom row; Z forces a wrap+scroll
	qa.assertEqual TextDisplay.row, TextDisplay.gridH - 1, "row should stay pinned to the bottom after scrolling"
	qa.assertEqual TextDisplay.cell(0, 0), "T", "row 1 should have shifted up to become row 0"
	qa.assertEqual TextDisplay.cell(TextDisplay.gridW - 1, TextDisplay.gridH - 2), "Y", "old bottom row should shift up by one"
	qa.assertEqual TextDisplay.cell(0, TextDisplay.gridH - 1), "Z", "new char should land on the new bottom row"

	print "_srcRectFor maps ASCII codes to the font sheet, offset by the blank leading cell"
	qa.assertEqual TextDisplay._srcRectFor("A"), [0, 32, 8, 8], "'A' (code 65) should be sheet cell (0,4)"
	qa.assertEqual TextDisplay._srcRectFor(" "), [120, 8, 8, 8], "' ' (code 32) should be sheet cell (15,1)"
	qa.assertEqual TextDisplay._srcRectFor("0"), [120, 16, 8, 8], "'0' (code 48) should be sheet cell (15,2)"
	qa.assertEqual TextDisplay._srcRectFor("3"), [16, 24, 8, 8], "'3' (code 51) should be sheet cell (2,3)"

	print "All tests passed!"

	print "== Visual test (look at the app window) =="
	TextDisplay.clear
	// the tests above leave color/backColor/inverse set to whatever they last
	// tested; clear doesn't touch that "pen" state (matching Mini Micro), so
	// reset it explicitly rather than inheriting leftover values here.
	TextDisplay.color = color.white
	TextDisplay.backColor = color.clear
	TextDisplay.inverse = false

	TextDisplay.print "TextDisplay visual test"
	TextDisplay.print "------------------------"
	TextDisplay.print ""

	TextDisplay.print "Text colors: ", ""
	textColors = [["red", color.red], ["orange", color.orange], ["yellow", color.yellow],
	  ["lime", color.lime], ["aqua", color.aqua], ["blue", color.blue],
	  ["purple", color.purple], ["pink", color.pink]]
	for c in textColors
		TextDisplay.color = c[1]
		TextDisplay.print c[0] + " ", ""
	end for
	TextDisplay.color = color.white
	TextDisplay.print ""

	TextDisplay.print "Background colors: ", ""
	backColors = [["navy", color.navy], ["maroon", color.maroon], ["teal", color.teal], ["olive", color.olive]]
	for c in backColors
		TextDisplay.backColor = c[1]
		TextDisplay.print " " + c[0] + " ", ""
		TextDisplay.backColor = color.clear
		TextDisplay.print " ", ""
	end for
	TextDisplay.print ""

	TextDisplay.print "Inverse: normal ", ""
	TextDisplay.backColor = color.black   // inverse swaps color <-> backColor, so this becomes the visible text color
	TextDisplay.inverse = true
	TextDisplay.print " INVERTED ", ""
	TextDisplay.inverse = false
	TextDisplay.backColor = color.clear
	TextDisplay.print " normal again", ""
	TextDisplay.print ""

	TextDisplay.color = color.yellow
	TextDisplay.print "Wrapping (this line is longer than the screen is wide, so it should wrap to a second row):"
	TextDisplay.print "0123456789" * 12
	TextDisplay.color = color.white
	TextDisplay.print ""

	TextDisplay.print "setCell / setCellColor (direct grid access, bypassing print):"
	word = "TEXTDISPLAY"
	wordRow = TextDisplay.row
	wordColors = [color.red, color.orange, color.yellow, color.lime, color.aqua, color.blue, color.purple, color.pink]
	for i in range(0, word.len - 1)
		TextDisplay.setCell i, wordRow, word[i]
		TextDisplay.setCellColor i, wordRow, wordColors[i % wordColors.len]
	end for
	TextDisplay.row = wordRow + 1
	TextDisplay.column = 0
	TextDisplay.print ""

	TextDisplay.color = color.lime
	TextDisplay.print "All TextDisplay unit tests passed!"

  while not raylib.WindowShouldClose
    yield
  end while
	exit
else
	return TextDisplay
end if
