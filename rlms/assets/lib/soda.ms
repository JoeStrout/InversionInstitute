// This is the main include file for "Soda", i.e., all the 
// classes and modules which mimic the Mini Micro API.
// In your main program, include this, just once.
// It should automatically set everything up for you.
// Then, call soda.update from the main loop (at the 
// point where you want it to render).

import "importUtil"

ensureImport ["Display", "Image", "SolidColorDisplay", "PixelDisplay",
  "SpriteDisplay", "mouse", "key"]

Display.Initialize


update = function
	Display.RenderAll
	mouse.update
end function

