// Prepare standard imports...
import "miscUtil"
ensureImport "displays"
ensureImport "alicia"
ensureImport "drawing"
ensureImport "bmfFonts"
ensureImport "backgrounds"

// ...Then drop right into scene 1!
// (Or whatever scene we are currently working on.)
text.color = color.black
cd "/usr/chapters/6.majority"
load "introScene"; run
