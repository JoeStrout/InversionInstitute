// Intro scene for the "XOR gate" task, in which we must help Mr. Ex-Oarley
// make a discord alert for his two sons.

import "miscUtil"
ensureImport "scene"
ensureImport "objectives"
import "findErrors"
import "context"

scene.prepare context.number, "/usr/chapters/" + context.folderName
ch = "ch" + context.number
if not gameData.data.hasIndex(ch) or not gameData.data[ch] then gameData.data[ch] = {}

Alicia.present = true
Baab.present = false

playSteps.push function
	displays.vnBackground.drawImage backgrounds.lab
		Alicia.setExpression alicia.eyebrows.normal, alicia.eyes.normal, alicia.mouth.smile
		drawing.drawSpeech "Let's do one more design before we call it a day.",
			drawing.Speaker.Left, "Alicia"
end function
playSteps.push function
	displays.vnBackground.drawImage backgrounds.lab
		Alicia.setExpression alicia.eyebrows.normal, alicia.eyes.normal, alicia.mouth.normal
		drawing.drawSpeech "This one will also take three inputs.  Really, a three-digit binary number.",
			drawing.Speaker.Left, "Alicia"
end function
playSteps.push function
	displays.vnBackground.drawImage backgrounds.lab
		Alicia.setExpression alicia.eyebrows.normal, alicia.eyes.normal, alicia.mouth.smile
		drawing.drawSpeech "But now I want to find the equivalent normal number.",
			drawing.Speaker.Left, "Alicia"
end function
playSteps.push function
	displays.vnBackground.drawImage backgrounds.lab
		Alicia.setExpression alicia.eyebrows.normal, alicia.eyes.normal, alicia.mouth.flat
		drawing.drawSpeech "So, this time I've labeled the inputs *1*, *2*, and *4*, according to how much value they have in the binary number.",
			drawing.Speaker.Left, "Alicia"
end function
playSteps.push function
	displays.vnBackground.drawImage backgrounds.lab
		Alicia.setExpression alicia.eyebrows.normal, alicia.eyes.normal, alicia.mouth.smile
		drawing.drawSpeech "All you have to do is add those up, and then light up one of eight outputs, labeled *0* through  *7*.",
			drawing.Speaker.Left, "Alicia"
end function
playSteps.push function
	displays.vnBackground.drawImage backgrounds.lab
		Alicia.setExpression alicia.eyebrows.normal, alicia.eyes.giggle, alicia.mouth.smile
		drawing.drawSpeech "So for example, if inputs *1* and *4* are on, then you should light up output *5*, because *1 + 4 = 5*.  Simple, right?",
			drawing.Speaker.Left, "Alicia"
end function
playSteps.push function
	displays.vnBackground.drawImage backgrounds.lab
		Alicia.setExpression alicia.eyebrows.sad, alicia.eyes.normal, alicia.mouth.smallFrown
		drawing.drawSpeech "...Though it'd be might be a lot to fit in.  I'm not sure how you will keep everything nice and neat.",
			drawing.Speaker.Left, "Alicia"
end function
playSteps.push function
	displays.vnBackground.drawImage backgrounds.lab
		Alicia.setExpression alicia.eyebrows.normal, alicia.eyes.giggle, alicia.mouth.smile
		drawing.drawSpeech "But I'm sure there must be a way.  Good luck!",
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
