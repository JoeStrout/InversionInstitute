// This is the "Notebook" dialog that lets you keep clippings of your
// favorite circuits or sub-circuits.

if not globals.hasIndex("miscUtil") then import "miscUtil"
ensureImport "soda"
ensureImport "ttFonts"
ensureImport "rect"
ensureImport "json"
ensureImport "base64"
ensureImport "listUtil"
ensureImport "SimpleTextButton"

backgroundImage = null
letterFont = null
listFont = null
buttonFont = null
done = false

Entry = {}
Entry.name = ""
Entry.width = 0
Entry.height = 0

Entry.Instances = []

Entry.Add = function(name, width, height)
	noob = new Entry
	noob.name = name
	noob.width = width
	noob.height = height
	self.Instances.push noob
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
		outer.listFont = ttFonts.TTFont.Load("fonts/EBGaramond-Regular.ttf", 24)
	end if

	if buttonFont == null then
		outer.buttonFont = ttFonts.TTFont.Load("fonts/EBGaramond-Regular.ttf", 26)
	end if
end function


drawLetter = function
	x = 120; y = 494; wrapWidth = 302
	page1 = "Dear " + gameData.playerName + "," + char(10)*2 +
	  "Master Leo has created this notebook, magically attached to your drafting " +
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

setup = function
	loadResources
	gfx.drawImage backgroundImage, 
	  480 - backgroundImage.width/2, 320 - backgroundImage.height/2

	SimpleTextButton.Instances = []
	SimpleTextButton.font = buttonFont
	
	newClipBtn = SimpleTextButton.Make("New From Clipboard", 196, 182)
//	newClipBtn.action = @newFromClipboard

	newSelBtn = SimpleTextButton.Make("New From Selection", 366, 182)
//	newSelBtn.action = @newFromSelection

	for btn in SimpleTextButton.Instances; btn.draw; end for
end function


present = function(circuitPath)
	display(1).setMode displayMode.pixel
	globals.gfx = display(1)
	gfx.clear color.clear
	setup
	
	drawLetter
	
	while not done
		yield
		SimpleTextButton.UpdateAll
		if key.pressed("escape") then close
	end while
end function


test = function
	clear
	// shim our needed modules for testing
	globals.context = {}
	context.number = 7
	globals.gameData = {}
	gameData.data = {}
	gameData.playerName = "Testy"
	gameData.data.installId = "TestyMcTester"
	present
end function

if locals == globals then test
