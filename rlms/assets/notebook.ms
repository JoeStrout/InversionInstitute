// This is the "Notebook" dialog that lets you keep clippings of your
// favorite circuits or sub-circuits.

if not globals.hasIndex("miscUtil") then import "miscUtil"
ensureImport "soda"
ensureImport ["ttFonts", "rect", "listbox", "SimpleTextButton", "textField"]
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
Entry.path = ""
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

EntryField = new TextField
EntryField.font = listFont
EntryField.maxLength = 25
EntryField.textColor = color.black
EntryField.cursorColor = "#666666"
EntryField.selColor = "#8888FF"
EntryField.backColor = "#F4D396"
EntryField.borderColor = "#663300"

EntryField.setSelText = function(s="")
	if not s then return super.setSelText(s)
	// filter out printable characters that cause mischief in filenames
	for c in "/\{}?*'""`~:<>|$!&;()[]#%"
		s = s.replace(c, "")
	end for
	if s then return super.setSelText(s)
end function	

Entry.edit = function(g, x, y, width, height)
	sizeStr = self.width + " x " + self.height
	sizeW = listFont.width(sizeStr) + 5
	fieldW = width - sizeW + 8
	print Rect.Make(x - 4, y - 4, fieldW, height + 4).str
	
	field = new EntryField
	field.init Rect.Make(x, y, fieldW, height)
	field.text = self.name
	field.select
	field.setFocus
	field.draw
	field.done = false
	field.commit = function; self.done = true; end function
	while not field.done
		yield
		field.update		
	end while
	self.name = field.text
	field.close
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
		EntryField.font = listFont
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
	circuitList.selectRow null
	newIdx = 0
	for fname in file.children(gameData.notebookFolder).sort
		if not fname.endsWith(".png") then continue
		path = file.child(gameData.notebookFolder, fname)
		img = file.loadImage(path)
		if img == null then continue
		newEntry = Entry.Make((fname - ".png").replace("_", " "), img)
		newEntry.path = path
		circuitList.rows.push newEntry
		if circuitList.rows[-1].name == selName then newIdx = circuitList.rows.len - 1
	end for
	circuitList.selectRow newIdx
	print "At end of loadEntries, selectedIdx = " + circuitList.selectedIdx
end function

clipboardAvailable = function
	return globals.hasIndex("clipboard") and clipboard != null
end function

selectionAvailable = function
	return globals.hasIndex("selection") and selection != null
end function

newFromSelCaption = function
	if selectionAvailable then return "New from Selection"
	return "New from Table"  // (whole circuit)
end function

drawLetter = function
	x = 120; y = 494; wrapWidth = 302
	
	page1 = "Dear " + gameData.playerName + "," + char(10)*2 +
	  "Master Leo has created this notebook, magically linked to your drafting " +
	  "table.  To add a design, select it on your table, then open your notebook " +
	  "and tap """ + newFromSelCaption + """.  Or you can Copy and then tap " +
	  """New from Clipboard""."
	letterFont.printWrapped page1, x, y, wrapWidth, color.black
	
	x = 537
	page2 = "Your designs will stay in your notebook until you delete them.  To " +
	  "add a saved design to your table, just find it again in your notebook, and " +
	  "tap ""Use""." + char(10)*2 +
	  "I hope this notebook serves you well.  Enjoy!" + char(10)*2 + 
	  "- Alicia"
	letterFont.printWrapped page2, x, y, wrapWidth, color.black
  
	useBtn.hidden = true
	deleteBtn.hidden = true
	useBtn.draw
	deleteBtn.draw
end function

drawPreview = function
	gfx.setClip previewArea.left, previewArea.bottom, previewArea.width, previewArea.height
	gfx.drawImage backgroundImage, 
	  480 - backgroundImage.width/2, 320 - backgroundImage.height/2
	if circuitList and circuitList.selectedRow then
		img = circuitList.selectedRow.image
		scale = mathUtil.min(previewArea.width / img.width, previewArea.height / img.height)
		dw = img.width * scale
		dh = img.height * scale
		gfx.drawImage img, previewArea.midX - dw/2, previewArea.midY - dh/2, dw, dh		  
		useBtn.hidden = false
		deleteBtn.hidden = false
	else
		useBtn.hidden = true
		deleteBtn.hidden = true
	end if
	gfx.clearClip
	useBtn.draw
	deleteBtn.draw
end function

addNewPage = function(circuitPic)
	if circuitList == null then loadEntries
	circuitList.rows.push Entry.Make("Untitled", circuitPic)
	circuitList.selectRow circuitList.rows.len - 1
	circuitList.scrollIntoView
	circuitList.draw
	drawPreview
	circuitList.editRow
	selRow = circuitList.rows[circuitList.selectedIdx]
	newFileName = selRow.name.replace(" ", "_") - ".png" + ".png"
	result = file.saveImage(file.child(gameData.notebookFolder, newFileName), circuitPic)
	print "saveImage result: " + result
	loadEntries
	for i in circuitList.rows.indexes
		if circuitList.rows[i].name == selRow.name then
			circuitList.selectRow i
			circuitList.scrollIntoView
			break
		end if
	end for
	if circuitList.rows.len == 1 then drawAll else circuitList.draw
end function

newFromClipboard = function
	addNewPage clipboard
end function

newFromSelection = function
	pic = circuitPic
	if selectionAvailable then
		pic = pic.getImage(selection.left, selection.bottom, selection.width, selection.height)
	end if
	addNewPage pic
end function

drawAll = function
	bgLeft = 480 - backgroundImage.width/2
	bgBotm = 320 - backgroundImage.height/2
	gfx.drawImage backgroundImage, bgLeft, bgBotm

	for btn in SimpleTextButton.Instances
		btn.draw
	end for

	if circuitList and circuitList.rows.len > 0 then
		circuitList.draw
		drawPreview
	else
		drawLetter
	end if
end function

setup = function
	loadResources

	SimpleTextButton.Instances = []
	SimpleTextButton.font = buttonFont
	
	closeBtn = SimpleTextButton.Make("X", 107, 511)
	closeBtn.action = @close
	
	newClipBtn = SimpleTextButton.Make("New from Clipboard", 196, 182)
	newClipBtn.enabled = clipboardAvailable
	newClipBtn.action = @newFromClipboard

	newSelBtn = SimpleTextButton.Make(newFromSelCaption, 366, 182)
	newSelBtn.action = @newFromSelection

	outer.useBtn = SimpleTextButton.Make("Use", 600, 182)
	useBtn.hidden = true
	useBtn.action = @useSelectedRow
	
	outer.deleteBtn = SimpleTextButton.Make("Delete", 759, 182)
	deleteBtn.hidden = true
	deleteBtn.action = @deleteCircuit

	bgLeft = 480 - backgroundImage.width/2
	bgBotm = 320 - backgroundImage.height/2
	for btn in SimpleTextButton.Instances
		b = btn.bounds
		btn.background = backgroundImage.getImage(
		  b.left - bgLeft, b.bottom - bgBotm, b.width, b.height)
	end for
	
	loadEntries

	drawAll
end function

useSelectedRow = function
	useCircuit circuitList.selectedRow
end function

// "Use" callback -- callers can replace this as desired.
useCircuit = function(entry)
	print "Using circuit: " + entry.name
end function

deleteCircuit = function(entry)
	idx = circuitList.selectedIdx
	result = file.delete(circuitList.selectedRow.path)
	print "delete " + circuitList.selectedRow.path + ": " + result
	loadEntries
	if circuitList.rows.len == 0 then
		drawAll
	else
		circuitList.selectRow mathUtil.min(idx, circuitList.rows.len - 1)
		circuitList.draw
		drawPreview
	end if
end function
	

present = function(circuitPath)
	oldDisp1Mode = display(1).mode
	oldGfxIdx = gfx.index
	display(1).setMode displayMode.pixel
	globals.gfx = display(1)
	gfx.clear color.clear
	setup
	
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

	display(1).setMode oldDisp1Mode
	globals.gfx = display(oldGfxIdx)
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
