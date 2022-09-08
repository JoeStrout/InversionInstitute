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

Alicia.present = true

playSteps.push function
	displays.vnBackground.drawImage backgrounds.lab
	Alicia.setExpression alicia.eyebrows.normal, alicia.eyes.giggle, alicia.mouth.smile
	drawing.drawSpeech "You've really gotten the hang of this Magic Ink!",
		drawing.Speaker.Left, "Alicia"
end function
playSteps.push function
	displays.vnBackground.drawImage backgrounds.lab
	Alicia.setExpression alicia.eyebrows.normal, alicia.eyes.normal, alicia.mouth.normal
	drawing.drawSpeech "Master Leo has asked me to think about Ink state as numbers.",
		drawing.Speaker.Left, "Alicia"
end function
playSteps.push function
	displays.vnBackground.drawImage backgrounds.lab
	Alicia.setExpression alicia.eyebrows.normal, alicia.eyes.normal, alicia.mouth.smallFrown
	drawing.drawSpeech "Magic Ink only has two states - on and off - so I guess we'll call those 1 and 0.",
		drawing.Speaker.Left, "Alicia"
end function
playSteps.push function
	displays.vnBackground.drawImage backgrounds.lab
	Alicia.setExpression alicia.eyebrows.normal, alicia.eyes.normal, alicia.mouth.smile
	drawing.drawSpeech "You can help!  Let's make an ink design that lights up as a ZERO when the input signal is off, or a ONE when the input is on!",
		drawing.Speaker.Left, "Alicia"
end function
playSteps.push function
	displays.vnBackground.drawImage backgrounds.lab
	Alicia.setExpression alicia.eyebrows.normal, alicia.eyes.normal, alicia.mouth.smallFrown
	drawing.drawSpeech "It'll have to be kind of a squarish zero.  But I guess that's OK.",
		drawing.Speaker.Left, "Alicia"
end function
playSteps.push function
	context.objectivesDrawn = false
	context.checkDrawn = false
	scene.switchToEditor
end function

if locals == globals then
	scene.play
end if
