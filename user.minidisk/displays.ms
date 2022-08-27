
// Visual Novel layers:
vnBackground = null
vnCharacters = null
vnSpeech = null

// Universal layers
display(1).mode = displayMode.solidColor
fadeInOut = display(1)
fadeInOut.color = color.clear


// Function to set up displays for Visual Novel mode
setupVN = function
	display(7).mode = displayMode.pixel
	outer.vnBackground = display(7)
	vnBackground.clear "#444444"
	
	display(6).mode = displayMode.sprite
	outer.vnCharacters = display(6)
	vnCharacters.clear
	
	display(5).mode = displayMode.pixel
	outer.vnSpeech = display(5)
	vnSpeech.clear color.clear
	
	text.clear
end function

if locals == globals then setupVN
