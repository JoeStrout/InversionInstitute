// This module creates and manages the Free Play screen, which
// is really just a file browser/manager for the freeplay folder.

import "miscUtil"
ensureImport "mathUtil"
ensureImport "textField"
ensureImport "drawing"
ensureImport "button"
ensureImport "fileList"

// Constants:
listBgColor = "#444444"
listFrameColor = "#222222"

setup = function
	clear

	display(6).mode = displayMode.solidColor
	display(6).color = "#222266"
	display(5).mode = displayMode.sprite

	outer.bgSprites = display(5)
	bgSprites.clear

	display(4).mode = displayMode.pixel
	globals.gfx = display(4)
	gfx.clear color.clear
	
	display(2).mode = displayMode.sprite
	outer.uiSprites = display(2)
	uiSprites.clear
	
	font.printCentered "Free Play", 480, 600, 2, color.yellow

	previewBox = Rect.make(460, 148, 480, 384)
	previewBox.fill gfx, "#222222"

	fileListBox = Rect.make(32, 80, 400, 452)
	fileListBox.fill gfx, listBgColor
	fileListBox.grow(2,2).frame gfx, listFrameColor, 3
	fileList.width = fileListBox.width
	fileList.prepare
	fileList.draw fileListBox
	
	fileList.onSelChange = function
		if fileList.selectedRow == null then
			previewBox.fill gfx, "#222222"
		else
			entry = fileList.entries[fileList.selectedRow]
			gfx.drawImage entry.circuitPic, previewBox.left, previewBox.bottom,
				previewBox.width, previewBox.height
		end if
	end function

	button.sprites = uiSprites.sprites
		
	newBtn = drawing.makeButton("New", 150)
	newBtn.x = fileListBox.left + newBtn.image.width/2
	newBtn.y = 40
	newBtn.action = function
		globals.context = {}
		context.title = "Free Play"
		context.filename = null
		context.update = null		// (called every time through main loop)
		globals.circuitPic = Image.create(80, 64)
		globals.returnFunc = function
			load "freeplay"
			run
		end function
		cleanUp
		load "editor"; run
	end function
	
	openBtn = drawing.makeButton("Open", 150)
	openBtn.x = previewBox.left + openBtn.image.width/2
	openBtn.y = previewBox.bottom - openBtn.image.height/2 - 12
	openBtn.action = function
		if fileList.selectedRow == null then return
		entry = fileList.entries[fileList.selectedRow]
		globals.context = {}
		context.title = "Free Play"
		context.filename = entry.filename
		context.update = null		// (called every time through main loop)
		globals.circuitPic = entry.circuitPic
		globals.returnFunc = function
			load "freeplay"
			run
		end function
		cleanUp
		load "editor"; run
	end function
	openBtn.keys = ["o", "enter", "return"]
	
	delBtn = drawing.makeButton("Delete", 150)
	delBtn.x = previewBox.right - delBtn.image.width/2
	delBtn.y = previewBox.bottom - delBtn.image.height/2 - 12
//	delBtn.action = @pronounAction		// ToDo!

	backBtn = button.Button.make(file.loadImage("/usr/pics/ui/backButton.png"), 10, 600)
	backBtn.action = @cleanUp
	backBtn.keys = ["escape"]

end function

cleanUp = function
//	TextField.closeAll
	button.Button.closeAll
	uiSprites.sprites = []
	bgSprites.sprites = []
	fileList.onSelChange = null
	outer.done = true
end function

doMainLoop = function
	outer.done = false
	while not done
		yield
		button.Button.updateAll
		fileList.doEvents
	end while
	cleanUp
	key.clear
end function

present = function
	setup
	doMainLoop
	load "title"; run
end function


if locals == globals then
	present
end if

