// PixelDisplay + Image test program.

print "Running main.ms"
import "Image"
import "PixelDisplay"

rl = raylib
rl.SetTraceLogLevel(rl.LOG_WARNING)

titleFont = raylib.LoadFontEx("assets/Merkin.ttf", 48)

gfx = PixelDisplay.Make(960, 640, "#000044")

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

// Test getImage/drawImage: clone the test pattern region and draw it elsewhere
snippet = gfx.getImage(100, 100, 200, 100)
gfx.drawImage snippet, 500, 300

printCentered = function(s, y, fontSize=20, color)
	if color == null then color = rl.WHITE
	// DrawText uses a spacing equal to fontSize/10, so measure as:

	//size = rl.MeasureTextEx(rl.GetFontDefault, s, fontSize, fontSize/10)
	//rl.DrawText s, 480 - size.x/2, y, fontSize, color
	
	fontSize = titleFont.baseSize
	size = rl.MeasureTextEx(titleFont, s, fontSize, 0)
	raylib.DrawTextEx titleFont, s, [480 - size.x/2, y], fontSize, 0, color

end function

// Main loop
while true
	rl.BeginDrawing
	gfx.render

	printCentered "Inversion Institute Redux", 10, 30, [100,100,255,255]
	printCentered "host version " + version.host, 40, 10, [50,50,200,255]

	rl.DrawFPS
	rl.EndDrawing
	yield
end while
