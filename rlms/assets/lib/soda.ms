// This is the main include file for "Soda", i.e., all the 
// classes and modules which mimic the Mini Micro API.
// In your main program, include this, just once.
// It should automatically set everything up for you.
// Then, call soda.update from the main loop (at the 
// point where you want it to render).

raylib.SetTraceLogLevel raylib.LOG_WARNING
if not raylib.IsWindowReady then
	raylib.InitWindow 960, 640  // create the window
end if

import "importUtil"

ensureImport ["Display", "Image", "SolidColorDisplay", "PixelDisplay",
  "SpriteDisplay", "mouse", "key", "color", "Sound"]

Display.Initialize

update = function(beginEndRaylibDrawing = true)
	if beginEndRaylibDrawing then raylib.BeginDrawing
	Display.RenderAll
	if beginEndRaylibDrawing then raylib.EndDrawing
	mouse.update
	Sound.UpdateAll
end function

// Override (actually, shadow) the `yield` intrinsic to do our standard
// update, so that a tight yield loop does not lock up the app.
globals.yield = function
	outer.update
	intrinsics.yield
end function
