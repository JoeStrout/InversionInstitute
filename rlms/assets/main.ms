// PixelDisplay test program.

print "Running main.ms"
import "PixelDisplay"

rl = raylib
rl.SetTraceLogLevel(rl.LOG_WARNING)

import "importUtil"
ensureImport "PixelDisplay"

gfx = PixelDisplay.Make(960, 640)

// Draw some test pixels: a diagonal line of colored dots on a yellow background
gfx.fillRect 100, 100, 100, 100, "#FFFF00"
gfx.drawRect 100, 100, 100, 100, "#8888FF"
gfx.fillEllipse 200,100, 200,100, "#008800"
gfx.drawEllipse 200,100, 200,100, "#88FF88"
for i in range(0, 99)
	gfx.setPixel 100 + i, 100 + i, "#FF00FF"
end for

// A few individual pixels at known corners to verify coordinate system
gfx.setPixel 0, 0, [255, 0, 0, 255]           // red at bottom-left
gfx.setPixel 959, 0, [0, 255, 0, 255]          // green at bottom-right
gfx.setPixel 0, 639, [0, 0, 255, 255]          // blue at top-left
gfx.setPixel 959, 639, [255, 255, 255, 255]    // white at top-right

// Main loop
while true
	rl.BeginDrawing
	rl.ClearBackground rl.BLACK
	gfx.render
	rl.DrawFPS
	rl.EndDrawing
	yield
end while
