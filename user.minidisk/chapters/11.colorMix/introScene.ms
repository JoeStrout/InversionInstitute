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
Baab.present = true

playSteps.push function
	displays.vnBackground.drawImage backgrounds.lab
	Alicia.setExpression alicia.eyebrows.normal, alicia.eyes.normal, alicia.mouth.smile
	Baab.setExpression baab.eyebrows.normal, baab.eyes.normal, baab.mouth.openSmile
	drawing.drawSpeech "Heya, " + gameData.playerName + ". I've got an easy job for you!",
		drawing.Speaker.Right, "Baab"
end function
playSteps.push function
	displays.vnBackground.drawImage backgrounds.lab
	Alicia.setExpression alicia.eyebrows.mad, alicia.eyes.normal, alicia.mouth.bigOh
	Baab.setExpression baab.eyebrows.normal, baab.eyes.normal, baab.mouth.smile
	drawing.drawSpeech "Baab! You're interrupting. I was about to explain why I've decided " +
	"to call that 2-bit counter a _half adder_.",
		drawing.Speaker.Left, "Alicia"
end function
playSteps.push function
	displays.vnBackground.drawImage backgrounds.lab
	Alicia.setExpression alicia.eyebrows.normal, alicia.eyes.normal, alicia.mouth.frown
	Baab.setExpression baab.eyebrows.normal, baab.eyes.normal, baab.mouth.huh
	drawing.drawSpeech "Oops, sorry Alicia. But we just got a request from Ms. Mixwell, and it's kind of urgent. But I think it'll be an easy one for " + gameData.playerName + ".",
		drawing.Speaker.Right, "Baab"
end function
playSteps.push function
	displays.vnBackground.drawImage backgrounds.lab
	Alicia.setExpression alicia.eyebrows.normal, alicia.eyes.normal, alicia.mouth.normal
	Baab.setExpression baab.eyebrows.normal, baab.eyes.normal, baab.mouth.normal
	drawing.drawSpeech "All right then. What's the job?",
		drawing.Speaker.Left, "Alicia"
end function
playSteps.push function
	displays.vnBackground.drawImage backgrounds.lab
	Alicia.setExpression alicia.eyebrows.normal, alicia.eyes.normal, alicia.mouth.normal
	Baab.setExpression baab.eyebrows.normal, baab.eyes.normal, baab.mouth.normal
	drawing.drawSpeech "Ms. Mixwell, the art teacher, has a new class starting soon. " +
	"And she this idea to help her students learn how to mix paints.",
		drawing.Speaker.Right, "Baab"
end function
playSteps.push function
	displays.vnBackground.drawImage backgrounds.lab
	Alicia.setExpression alicia.eyebrows.normal, alicia.eyes.normal, alicia.mouth.normal
	Baab.setExpression baab.eyebrows.normal, baab.eyes.normal, baab.mouth.normal
	drawing.drawSpeech "She's going to paint a little Magic Ink diagram with the primary " +
	"colors on the left, and the possible mixed colors on the right.",
		drawing.Speaker.Right, "Baab"
end function
playSteps.push function
	displays.vnBackground.drawImage backgrounds.lab
	Alicia.setExpression alicia.eyebrows.normal, alicia.eyes.normal, alicia.mouth.normal
	Baab.setExpression baab.eyebrows.normal, baab.eyes.normal, baab.mouth.smile
	drawing.drawSpeech "We just need to light up the right color for any combination of paints!",
		drawing.Speaker.Right, "Baab"
end function
playSteps.push function
	displays.vnBackground.drawImage backgrounds.lab
	Alicia.setExpression alicia.eyebrows.normal, alicia.eyes.giggle, alicia.mouth.smile
	Baab.setExpression baab.eyebrows.normal, baab.eyes.normal, baab.mouth.normal
	drawing.drawSpeech "That _does_ sound like an easy one for " + gameData.playerName + "!",
		drawing.Speaker.Left, "Alicia"
end function
playSteps.push function
	displays.vnBackground.drawImage backgrounds.lab
	Alicia.setExpression alicia.eyebrows.normal, alicia.eyes.normal, alicia.mouth.normal
	Baab.setExpression baab.eyebrows.normal, baab.eyes.normal, baab.mouth.smile
	drawing.drawSpeech "Better get to it, " + gameData.playerName + ". I promise I'll " +
	"explain about the half-adder thing when you're done with this.",
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
