
// Visual Novel layers:
vnBackground = null
vnCharacters = null
vnSpeech = null

// Editor/Simulator layers:
edSprite = null			// used for UI buttons, etc.
edBackground = null		// masks off everything except paint area
edFatbits = null		// scaled-up bits for painting in
edBackdrop = null		// appears behind fat-bits drawing (not sure we actually need this!)
edScratch = null		// temporary composition area

// Universal layers
display(1).mode = displayMode.solidColor
fadeInOut = display(1)
fadeInOut.color = color.clear


// Function to set up displays for Visual Novel mode
setupVN = function
	display(7).mode = displayMode.pixel
	outer.vnBackground = display(7)
	vnBackground.clear "#444444"
	
	display(5).mode = displayMode.sprite
	outer.vnCharacters = display(5)
	vnCharacters.clear
	
	display(4).mode = displayMode.pixel
	outer.vnSpeech = display(4)
	vnSpeech.clear color.clear
	
	text.clear
end function

// Set up displays for the editor/simulator
setupEditorSim = function(picW=80, picH=64, scale=9)
	clear

	display(1).mode = displayMode.text
	globals.text = display(1)
	text.backColor = color.clear
	text.clear

	// spriteDisp: used for UI buttons, etc.
	display(2).mode = displayMode.sprite
	outer.edSprite = display(2)
	edSprite.clear

	// gfx: static overlay (drawing area grid, etc.)
	display(3).mode = displayMode.pixel
	globals.gfx = display(3)
	gfx.clear

	// bkgnd: background color; masks off everything except paint area
	display(4).mode = displayMode.pixel
	outer.edBackground = display(4)
	edBackground.clear "#929292", 970, 650
	edBackground.scrollX = 5
	edBackground.scrollY = 5

	// fatbits: scaled-up (fat) display of picture we're drawing
	display(5).mode = displayMode.pixel
	outer.edFatbits = display(5)
	edFatbits.clear color.clear, picW, picH
	edFatbits.scale = scale

	// backdrop: area that appears behind the fat-bits drawing (and preview area)
	display(6).mode = displayMode.pixel
	outer.edBackdrop = display(6)
	edBackdrop.color = "#444444"

	// scratch: hidden drawing area
	display(7).mode = displayMode.pixel
	outer.edScratch = display(7)
end function

if locals == globals then setupVN
