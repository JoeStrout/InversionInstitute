// This is the "Notebook" dialog that lets you keep clippings of your
// favorite circuits or sub-circuits.

if not globals.hasIndex("miscUtil") then import "miscUtil"
ensureImport "soda"
ensureImport ["ttFonts", "rect", "listbox", "SimpleTextButton"]
ensureImport ["json", "base64", "listUtil", "mathUtil"]

backgroundImage = null
letterFont = null
listFont = null
buttonFont = null
done = false
circuitList = null  // Listbox
previewArea = Rect.Make(528, 212, 308, 287)

Entry = new listbox.ListRow
Entry.name = ""
Entry.image = null
Entry.width = function; return self.image.width; end function
Entry.height = function; return self.image.height; end function

Entry.draw = function(g, x, y, width, height)
	if self.isSelected then c = "#4444AA" else c = color.black
	baseline = y + 10
	listFont.print self.name, x, baseline, 1, c
	sizeStr = self.width + " x " + self.height
	listFont.printRight sizeStr, x + width, y + 10, 1, c
	x0 = x + floor((listFont.width(self.name) + 10) / 7) * 7
	x1 = x + width - listFont.width(sizeStr) - 5
	for dotX in range(x0, x1, 7)
		g.fillRect dotX-2, baseline, 2, 2, c
	end for
	//g.drawRect x, y, width, height, "#888888" // for debugging
end function

Entry.Make = function(name, image)
	noob = new Entry
	noob.name = name
	noob.image = image
	return noob
end function


close = function
	gfx.clear color.clear
	outer.done = true
end function

loadResources = function
	if backgroundImage == null then
		outer.backgroundImage = file.loadImage("pics/ui/VintageBookOrtho.png")
	end if

	if letterFont == null then
		outer.letterFont = ttFonts.TTFont.Load("fonts/MorrisRoman-Black.ttf", 27)
	end if
		
	if listFont == null then
		outer.listFont = ttFonts.TTFont.Load("fonts/EBGaramond-Regular.ttf", 34)
	end if

	if buttonFont == null then
		outer.buttonFont = ttFonts.TTFont.Load("fonts/EBGaramond-Regular.ttf", 26)
	end if
end function

loadEntries = function
	if circuitList == null then
		outer.circuitList = listbox.Listbox.Make(116, 220, 338, 273)
		circuitList.rowHeight = 30
		bgLeft = 480 - backgroundImage.width/2
		bgBotm = 320 - backgroundImage.height/2
		b = circuitList.bounds
		circuitList.background = backgroundImage.getImage(
		   b.left - bgLeft, b.bottom - bgBotm, b.width, b.height)
	end if
	selName = ""
	if circuitList.selectedIdx != null then selName = circuitList.selectedRow.name
	circuitList.rows = []
	for fname in file.children(gameData.notebookFolder).sort
		if not fname.endsWith(".png") then continue
		path = file.child(gameData.notebookFolder, fname)
		img = file.loadImage(path)
		if img == null then continue
		circuitList.rows.push Entry.Make((fname - ".png").replace("_", " "), img)
		if circuitList.rows[-1].name == selName then
			circuitList.selectedIdx = circuitList.rows.len - 1
		end if
	end for
end function

drawLetter = function
	x = 120; y = 494; wrapWidth = 302
	page1 = "Dear " + gameData.playerName + "," + char(10)*2 +
	  "Master Leo has created this notebook, magically linked to your drafting " +
	  "table.  To add a design, select it on your table, then open your notebook " +
	  "and tap ""New from Selection"".  Or you can Copy and then tap ""New from " + 		
	  "Clipboard""."
	letterFont.printWrapped page1, x, y, wrapWidth, color.black
	
	x = 537
	page2 = "Your designs will stay in your notebook until you delete them.  To " +
	  "add a saved design to your table, just find it again in your notebook, and " +
	  "tap ""Use""." + char(10)*2 +
	  "I hope this notebook serves you well.  Enjoy!" + char(10)*2 + 
	  "- Alicia"
	letterFont.printWrapped page2, x, y, wrapWidth, color.black
  
end function

drawPreview = function
	gfx.setClip previewArea.left, previewArea.bottom, previewArea.width, previewArea.height
	gfx.drawImage backgroundImage, 
	  480 - backgroundImage.width/2, 320 - backgroundImage.height/2
	if circuitList and circuitList.selectedIdx != null then
		img = circuitList.selectedRow.image
		scale = mathUtil.min(previewArea.width / img.width, previewArea.height / img.height)
		dw = img.width * scale
		dh = img.height * scale
		gfx.drawImage img, previewArea.midX - dw/2, previewArea.midY - dh/2, dw, dh		  
	end if
	gfx.clearClip
	useBtn.hidden = false
	deleteBtn.hidden = false
	useBtn.draw
	deleteBtn.draw
end function

setup = function
	loadResources
	bgLeft = 480 - backgroundImage.width/2
	bgBotm = 320 - backgroundImage.height/2
	gfx.drawImage backgroundImage, bgLeft, bgBotm

	SimpleTextButton.Instances = []
	SimpleTextButton.font = buttonFont
	
	closeBtn = SimpleTextButton.Make("X", 107, 511)
	closeBtn.action = @close
	
	newClipBtn = SimpleTextButton.Make("New from Clipboard", 196, 182)
//	newClipBtn.action = @newFromClipboard

	newSelBtn = SimpleTextButton.Make("New from Selection", 366, 182)
//	newSelBtn.action = @newFromSelection

	outer.useBtn = SimpleTextButton.Make("Use", 600, 182)
	useBtn.hidden = true
	useBtn.action = @useSelectedRow
	
	outer.deleteBtn = SimpleTextButton.Make("Delete", 759, 182)
	deleteBtn.hidden = true

	for btn in SimpleTextButton.Instances
		b = btn.bounds
		btn.background = backgroundImage.getImage(
		  b.left - bgLeft, b.bottom - bgBotm, b.width, b.height)
		btn.draw
	end for
	
	drawPreview
end function

useSelectedRow = function
	useCircuit circuitList.selectedRow
end function

// "Use" callback -- callers can replace this as desired.
useCircuit = function(entry)
	print "Using circuit: " + entry.name
end function

present = function(circuitPath)
	display(1).setMode displayMode.pixel
	globals.gfx = display(1)
	gfx.clear color.clear
	setup
	loadEntries
	
	if not circuitList.rows then
		drawLetter
		outer.circuitList = null
	else
		circuitList.draw
	end if
	
	lastSelIdx = null
	outer.done = false
	while not done
		yield
		SimpleTextButton.UpdateAll
		if circuitList and circuitList.handleMouse then
			circuitList.draw
			if circuitList.selectedIdx != lastSelIdx then
				drawPreview
				lastSelIdx = circuitList.selectedIdx
			end if
		end if
		if key.pressed("escape") then close
	end while
end function

test = function
	clear
	// shim our needed modules for testing
	globals.context = {}
	context.number = 7
	ensureImport "gameData"
//	globals.gameData = {}
//	gameData.data = {}
//	gameData.playerName = "Testy"
//	gameData.data.installId = "TestyMcTester"
	present
end function

if locals == globals then test
