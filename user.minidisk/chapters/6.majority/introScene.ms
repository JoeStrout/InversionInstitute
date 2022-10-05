// Intro scene for the "bit display" task, in which we make a 1-bit
// binary (0/1) numeric display.

import "miscUtil"
ensureImport "scene"
ensureImport "objectives"
import "findErrors"
import "context"

scene.prepare context.number, "/usr/chapters/" + context.folderName
ch = "ch" + context.number
if not gameData.data.hasIndex(ch) or not gameData.data[ch] then gameData.data[ch] = {}

//demoTablet = file.loadImage("/usr/pics/ui/DemoTablet.png")

Baab.present = true
Alicia.present = false

playSteps.push function
	displays.vnBackground.drawImage backgrounds.lab
	Alicia.present = false
	Baab.setExpression baab.eyebrows.sad, baab.eyes.normal, baab.mouth.huh
	drawing.drawSpeech "Well!  Your ""guard 1 _and_ guard 2"" Ink design worked perfectly, but...",
		drawing.Speaker.Right, "Baab"
end function
playSteps.push function
	displays.vnBackground.drawImage backgrounds.lab
	Alicia.present = true
	Alicia.setExpression alicia.eyebrows.sad, alicia.eyes.normal, alicia.mouth.oh
	Baab.setExpression baab.eyebrows.mad, baab.eyes.normal, baab.mouth.huh
	drawing.drawSpeech "Oh dear... Is there a problem?",
		drawing.Speaker.Left, "Alicia"
end function
playSteps.push function
	displays.vnBackground.drawImage backgrounds.lab
	Alicia.setExpression alicia.eyebrows.sad, alicia.eyes.normal, alicia.mouth.flat
	Baab.setExpression baab.eyebrows.mad, baab.eyes.normal, baab.mouth.frown
	drawing.drawSpeech "Andi has decided that his guards aren't that competent. " +
	"Apparently, sometimes a guard will refuse someone that they really should let in.",
		drawing.Speaker.Right, "Baab"
end function
playSteps.push function
	displays.vnBackground.drawImage backgrounds.lab
	Alicia.setExpression alicia.eyebrows.normal, alicia.eyes.normal, alicia.mouth.normal
	Baab.setExpression baab.eyebrows.normal, baab.eyes.normal, baab.mouth.oh
	drawing.drawSpeech "So now he wants to add a _third_ guard. And he wants the gate to open if at least two of the guards agree it should open.",
		drawing.Speaker.Right, "Baab"
end function
playSteps.push function
	displays.vnBackground.drawImage backgrounds.lab
	Alicia.setExpression alicia.eyebrows.normal, alicia.eyes.normal, alicia.mouth.smile
	Baab.setExpression baab.eyebrows.normal, baab.eyes.normal, baab.mouth.huh
	drawing.drawSpeech "Sort of a ""majority rule"", I guess?",
		drawing.Speaker.Left, "Alicia"
end function
playSteps.push function
	displays.vnBackground.drawImage backgrounds.lab
	Alicia.setExpression alicia.eyebrows.normal, alicia.eyes.normal, alicia.mouth.normal
	Baab.setExpression baab.eyebrows.normal, baab.eyes.normal, baab.mouth.normal
	drawing.drawSpeech "Exactly. And I don't see how to do that. Can you help me out again?",
		drawing.Speaker.Right, "Baab"
end function
playSteps.push function
	context.objectivesDrawn = false
	context.checkDrawn = false
	scene.switchToEditor
end function

if locals == globals then
	scene.play
end if
