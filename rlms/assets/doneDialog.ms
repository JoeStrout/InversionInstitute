// This is the "Challenge Complete" dialog that appears when you
// finish a puzzle, including the histogram-drawing code.

if not globals.hasIndex("miscUtil") then import "miscUtil"
ensureImport "soda"

drawBackground = function
	img = file.loadImage("pics/ui/Parchment-400x300.png")
	gfx.drawImage img, 480-img.width, 320-img.height, img.width*2, img.height*2
	img.release
end function

test = function
	clear
	drawBackground
	
	pattern = file.loadImage("pics/patterns/HashLinesMedT.png")
	if not pattern then
		print "Could not load pattern"
		exit
	end if
	gfx.patternFill pattern, 400, 100, 24, 100
	gfx.drawRect 400, 100, 24, 100, color.black
	
	while not key.pressed("escape")
		yield
	end while
end function

if locals == globals then test
