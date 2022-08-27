import "miscUtil"
ensureImport "displays"
ensureImport "alicia"
ensureImport "drawing"
ensureImport "bmfFonts"

//font = bmfFonts.Font.load("/usr/fonts/Arial14Bold.bmf")
font = bmfFonts.Font.load("/usr/fonts/Georgia-24.bmf")

displays.setupVN
displays.vnBackground.drawImage file.loadImage("/usr/pics/Backgrounds/castle day.png")

Alicia.addSpritesToList displays.vnCharacters.sprites
drawing.drawSpeech "Welcome to Inversion Institute!  I'm Alicia, one of the " +
"mathemagicians here.  Master Leo asked me to help you get settled in."


while not key.pressed("escape")
	Alicia.animate
	yield
end while
key.clear