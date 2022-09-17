// This module creates a "save as" dialog, using a pixel display
// and a sprite display.  It shows a preview of the existing
// files for your reference while saving, and uses TextField to
// allow the user to type a new file name.

import "miscUtil"
ensureImport "qa"
ensureImport "rect"
ensureImport "textField"
ensureImport "button"
ensureImport "drawing"

// Set these before calling present:
gfxDisplay = null		// PixelDisplay
spriteDisplay = null		// SpriteDisplay
folder = null

// Constants:
bgColor = "#CCCCCC"
frameColor = "#222222"
listBgColor = "#444444"
listFrameColor = "#222222"

present = function
	qa.assert gfxDisplay != null and gfx.mode == displayMode.pixel
	qa.assert spriteDisplay != null and spriteDisplay.mode == displayMode.sprite
	qa.assert folder != null and file.info(folder).isDirectory
	button.sprites = spriteDisplay.sprites

	w = 580
	h = 426
	frame = Rect.make(480-w/2, 320-h/2, w, h)
	frame.fill gfxDisplay, bgColor
	frame.frame gfxDisplay, frameColor, 5
	
	label = "Save as:"
	x = frame.left + font.width(label) + 20
	font.printRight label, x - 4, frame.top-38, 1, color.black
	
	field = new TextField
	field.init
	field.bounds = Rect.make(x, frame.top - 48, frame.right - 20 - x, 36)
	field.font = font
	field.maxLength = 28
	field.text = "Untitled"
	field.select
	field.draw
	
	bw = 120  // (button width)
	globals.okBtn = drawing.makeButton("Save", bw)
	okBtn.x = frame.right - 12 - bw/2
	okBtn.y = frame.bottom + 8 + okBtn.image.height/2
	okBtn.keys = ["return", "enter"]
	okBtn.action = function
		outer.done = true
	end function

	cancelBtn = drawing.makeButton("Cancel", bw)
	cancelBtn.x = frame.right - 12 - bw - 12 - bw/2
	cancelBtn.y = frame.bottom + 8 + cancelBtn.image.height/2
	cancelBtn.keys = ["escape"]
	cancelBtn.action = function
		outer.done = true
	end function
	
	fileListBox = Rect.make(frame.left + 20, frame.bottom + 84, frame.width - 40, frame.height - 144)
	fileListBox.fill gfxDisplay, listBgColor
	fileListBox.frame gfxDisplay, listFrameColor, 3
	
	field.setFocus
	done = false
	while not done
		yield

		TextField.updateAll
		button.Button.updateAll
	end while

end function


if locals == globals then
	clear
	gfx.clear "#444488"
	gfxDisplay = gfx
	spriteDisplay = display(4)
	folder = "/usr/userdata/default/freeplay"
	present
	TextField.closeAll
end if

