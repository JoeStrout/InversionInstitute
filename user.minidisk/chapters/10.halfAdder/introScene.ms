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

playSteps.push function
	displays.vnBackground.drawImage backgrounds.lab
	Alicia.setExpression alicia.eyebrows.normal, alicia.eyes.normal, alicia.mouth.smile
	drawing.drawSpeech "Good morning, " + gameData.playerName + ". I hope you slept well.",
		drawing.Speaker.Left, "Alicia"
end function
playSteps.push function
	displays.vnBackground.drawImage backgrounds.lab
	Alicia.setExpression alicia.eyebrows.sad, alicia.eyes.normal, alicia.mouth.oh
	drawing.drawSpeech "I had a long talk with Master Leo last evening. I think I " +
	"understand now why Magic Ink is so much more important than I had realized.",
		drawing.Speaker.Left, "Alicia"
end function
playSteps.push function
	displays.vnBackground.drawImage backgrounds.lab
	Alicia.setExpression alicia.eyebrows.normal, alicia.eyes.normal, alicia.mouth.normal
	drawing.drawSpeech "The projects you've done have demonstrated a lot of basic " +
	"elements of mathemagics. Master Leo thinks it's now time to address that head-on!",
		drawing.Speaker.Left, "Alicia"
end function
playSteps.push function
	displays.vnBackground.drawImage backgrounds.lab
	Alicia.setExpression alicia.eyebrows.normal, alicia.eyes.giggle, alicia.mouth.smile
	drawing.drawSpeech "So, today let's see if we can make Ink _count!_",
		drawing.Speaker.Left, "Alicia"
end function
playSteps.push function
	displays.vnBackground.drawImage backgrounds.lab
	Alicia.setExpression alicia.eyebrows.sad, alicia.eyes.normal, alicia.mouth.normal
	drawing.drawSpeech "We'll put two inputs on the left, which can take any values. " +
	"And on the right, we'll have outputs labelled 1 and 2.",
		drawing.Speaker.Left, "Alicia"
end function
playSteps.push function
	displays.vnBackground.drawImage backgrounds.lab
	Alicia.setExpression alicia.eyebrows.normal, alicia.eyes.normal, alicia.mouth.smile
	drawing.drawSpeech "I need you to light up 1 if only *one* of the inputs is lit; " +
	"or 2 if *both* inputs are lit.  If neither input is lit, then leave both outputs off.",
		drawing.Speaker.Left, "Alicia"
end function
playSteps.push function
	displays.vnBackground.drawImage backgrounds.lab
	Alicia.setExpression alicia.eyebrows.normal, alicia.eyes.giggle, alicia.mouth.smile
	drawing.drawSpeech "I'm not sure how to do it, but I'm sure you can figure it out!",
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
