// PixelDisplay + Image test program.

print "Running main.ms"
import "soda"

rl = raylib
rl.SetTraceLogLevel(rl.LOG_WARNING)

titleFont = raylib.LoadFontEx("assets/Merkin.ttf", 48)

display(7).color = color.green

// Draw some test pixels: a diagonal line of colored dots on a yellow background
gfx.fillRect 100, 100, 100, 100, "#FFFF00"
gfx.drawRect 100, 100, 100, 100, "#8888FF"
gfx.fillEllipse 200,100, 200,100, "#008800"
gfx.drawEllipse 200,100, 200,100, "#88FF88"
for i in range(0, 99)
	gfx.setPixel 100 + i, 100 + i, color.pink
end for

// Test getImage/drawImage: clone the test pattern region and draw it elsewhere
snippet = gfx.getImage(100, 100, 200, 100)
gfx.drawImage snippet, 500, 300

// Also try drawing an image loaded from disk
img = file.loadImage("pics/logo.png")
if img != null then gfx.drawImage img, 500, 500

// And let's get a sprite or two going
sp = new Sprite
sp.image = img
sp.scale = 0.5
sp.x = 480; sp.y = 120
display(4).sprites.push sp

sp = new Sprite
sp.image = file.loadImage("assets/Wumpus.png")
sp.x = 400; sp.y = 100
display(4).sprites.push sp

printCentered = function(s, y, fontSize=20, color)
	if color == null then color = rl.WHITE
	size = rl.MeasureTextEx(titleFont, s, fontSize, 0)
	raylib.DrawTextEx titleFont, s, [480 - size.x/2, y], fontSize, 0, color
end function

// Main loop
while true
	rl.BeginDrawing
	
	soda.update

	printCentered "Inversion Institute Redux", 10, 48, [100,100,255,255]
	printCentered "host version " + version.host, 50, 24, [50,50,200,255]

	rl.DrawFPS
	rl.EndDrawing
	yield
	
	sp.rotation += 3
end while
