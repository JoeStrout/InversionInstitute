
// Visual Novel layers:
vnBackground = null
vnCharacters = null
vnSpeech = null

// Editor/Simulator layers:
edSprite = null			// used for UI buttons, etc.
edFatbits = null		// scaled-up bits for painting in
edBackdrop = null		// appears behind fat-bits drawing (not sure we actually need this!)
edScratch = null		// temporary composition area
simGfx = null			// usually, the same as edFatbits
simSprite = null		// sprite layer for showing nodes on/off

// Title screen layers:
tiSprite = null			// used for all sprites

// Universal layers
display(1).mode = displayMode.solidColor
fadeInOut = display(1)
fadeInOut.color = color.clear


// Function to set up displays for Visual Novel mode
setupVN = function
	display(1).mode = displayMode.solidColor
	outer.fadeInOut = display(1)
	fadeInOut.color = color.clear

	display(7).mode = displayMode.pixel
	outer.vnBackground = display(7)
	vnBackground.clear "#444444"
	
	display(6).mode = displayMode.pixel
	globals.gfx = display(6)
	gfx.clear color.clear
	
	display(5).mode = displayMode.sprite
	outer.vnCharacters = display(5)
	vnCharacters.clear
	
	display(4).mode = displayMode.pixel
	outer.vnSpeech = display(4)
	vnSpeech.clear color.clear
	
	display(3).mode = displayMode.off
	display(2).mode = displayMode.off
	display(1).mode = displayMode.text
	globals.text = display(1)
	
	text.clear
end function

// Set up displays for the editor/simulator
setupEditorSim = function(picW=80, picH=64, scale=9)
	clear

	display(1).mode = displayMode.text
	globals.text = display(1)
	text.backColor = color.clear
	text.clear

	// edSprite: used for UI buttons, etc.
	display(2).mode = displayMode.sprite
	outer.edSprite = display(2)
	edSprite.clear

	// gfx: static overlay (drawing area grid, etc.)
	display(3).mode = displayMode.pixel
	globals.gfx = display(3)
	gfx.clear

	// simSprite: sprite layer for the simulation (used to show nodes on/off)
	display(4).mode = displayMode.sprite
	outer.simSprite = display(4)
	simSprite.clear

	// fatbits: scaled-up (fat) display of picture we're drawing
	display(5).mode = displayMode.pixel
	outer.edFatbits = display(5)
	edFatbits.clear color.clear, picW, picH
	edFatbits.scale = scale
	outer.simGfx = edFatbits

	// backdrop: area that appears behind the fat-bits drawing (and preview area)
	display(6).mode = displayMode.pixel
	outer.edBackdrop = display(6)
	edBackdrop.color = "#444444"

	// scratch: hidden drawing area
	display(7).mode = displayMode.pixel
	outer.edScratch = display(7)
end function

// Set up displays for the title screen
setupTitle = function
	clear
	
	display(7).mode = displayMode.pixel
	outer.tiScratch = display(7)
	tiScratch.clear color.clear
	
	display(6).mode = displayMode.solidColor
	display(6).color = color.black
	
	display(5).mode = displayMode.sprite
	outer.tiSprite = display(5)
	tiSprite.clear
	
	display(4).mode = displayMode.pixel
	globals.gfx = display(4)
	gfx.clear color.clear
end function

if locals == globals then setupVN
