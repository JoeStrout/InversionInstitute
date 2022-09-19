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
ensureImport "fileList"

// Set these before calling present:
gfxDisplay = null		// PixelDisplay
spriteDisplay = null		// SpriteDisplay
folder = null

// Constants:
bgColor = "#CCCCCC"
frameColor = "#222222"
listBgColor = "#444444"
listFrameColor = "#222222"

present = function(filename="Untitled")
	qa.assert gfxDisplay != null and gfxDisplay.mode == displayMode.pixel
	qa.assert spriteDisplay != null and spriteDisplay.mode == displayMode.sprite
	qa.assert folder != null and file.info(folder).isDirectory
	button.sprites = spriteDisplay.sprites

	// because fileList requires it, for now we will also require:
	qa.assert gfxDisplay == gfx
	// (we can refactor that requirement away in the future if needed)

	w = 480
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
	field.text = filename
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
	fileListBox.grow(2,2).frame gfxDisplay, listFrameColor, 3
	fileList.width = fileListBox.width
	fileList.prepare
	fileList.highlightByName filename
	fileList.draw fileListBox
	
	field.onChange = function
		fileList.highlightByName self.text
	end function
	
	fileList.onSelChange = function
		if fileList.selectedRow == null then return
		name = fileList.entries[fileList.selectedRow].filename - ".png"
		if name != field.text then
			field.setText name, true
			field.setFocus
		end if
	end function
	
	field.setFocus
	done = false
	canceled = false
	while not done
		yield

		TextField.updateAll
		button.Button.updateAll
		fileList.doEvents
	end while
	if canceled then result = null else result = field.text
	TextField.closeAll
	button.Button.closeAll
	return result
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

