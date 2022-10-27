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
	drawing.drawSpeech "OK, I promised to explain why I've started calling your 2-input counter a ""half adder"".",
		drawing.Speaker.Left, "Alicia"
end function
playSteps.push function
	displays.vnBackground.drawImage backgrounds.lab
	Alicia.setExpression alicia.eyebrows.normal, alicia.eyes.normal, alicia.mouth.openSmile
	drawing.drawSpeech "I'm looking into ways that Magic Ink could be used to do arithmetic.  This will have so many uses!  Right now, the Institute employs legions of people called ""computers"" to do this sort of math for us.",
		drawing.Speaker.Left, "Alicia"
end function
playSteps.push function
	displays.vnBackground.drawImage backgrounds.lab
	Alicia.setExpression alicia.eyebrows.normal, alicia.eyes.normal, alicia.mouth.normal
	drawing.drawSpeech "Their work goes into making magic squares, figuring out optimal potion ingredients, working out the best times to plant crops and how much seed to save for next year, and many other things.",
		drawing.Speaker.Left, "Alicia"
end function
playSteps.push function
	displays.vnBackground.drawImage backgrounds.lab
	Alicia.setExpression alicia.eyebrows.normal, alicia.eyes.giggle, alicia.mouth.smile
	drawing.drawSpeech "So if we can make their jobs easier or faster with Magic Ink, it's a big win.",
		drawing.Speaker.Left, "Alicia"
end function
playSteps.push function
	displays.vnBackground.drawImage backgrounds.lab
	Alicia.setExpression alicia.eyebrows.normal, alicia.eyes.normal, alicia.mouth.normal
	drawing.drawSpeech "Remember how we can think of an ink signal as representing *0* when off, or *1* when on?",
		drawing.Speaker.Left, "Alicia"
end function
playSteps.push function
	displays.vnBackground.drawImage backgrounds.lab
	Alicia.setExpression alicia.eyebrows.normal, alicia.eyes.normal, alicia.mouth.smile
	drawing.drawSpeech "Well, I've worked out a numbering system that uses only those two digits, instead of the ten different digits we're used to.",
		drawing.Speaker.Left, "Alicia"
end function
playSteps.push function
	displays.vnBackground.drawImage backgrounds.lab
	Alicia.setExpression alicia.eyebrows.normal, alicia.eyes.normal, alicia.mouth.normal
	drawing.drawSpeech "For example, 0 is still 0, and 1 is still 1, but 2 would be written *10*, and 3 would be written *11*.  I call these numbers ""binary"" based on the Ancient word _binarius_, which means ""consisting of two"".",
		drawing.Speaker.Left, "Alicia"
end function
playSteps.push function
	displays.vnBackground.drawImage backgrounds.lab
	Alicia.setExpression alicia.eyebrows.normal, alicia.eyes.normal, alicia.mouth.small
	drawing.drawSpeech "That 2-input counter you made can be thought of as adding two 1-digit binary numbers.  But if we look at the outputs as a 2-digit binary number, we can see it doesn't have enough inputs - the output can never be 11, because that would require three inputs.",
		drawing.Speaker.Left, "Alicia"
end function
playSteps.push function
	displays.vnBackground.drawImage backgrounds.lab
	Alicia.setExpression alicia.eyebrows.normal, alicia.eyes.giggle, alicia.mouth.smile
	drawing.drawSpeech "So you see, you made an adder of sorts, but's really only _half_ an adder.  A full adder would take _three_ 1-digit inputs, and represent the count as a 2-digit binary number.",
		drawing.Speaker.Left, "Alicia"
end function
playSteps.push function
	displays.vnBackground.drawImage backgrounds.lab
	Alicia.setExpression alicia.eyebrows.sad, alicia.eyes.normal, alicia.mouth.openFrown
	drawing.drawSpeech "Oh dear, you look confused.  I can see I'm not explaining this very well.",
		drawing.Speaker.Left, "Alicia"
end function
playSteps.push function
	displays.vnBackground.drawImage backgrounds.lab
	Alicia.setExpression alicia.eyebrows.sad, alicia.eyes.giggle, alicia.mouth.smile
	drawing.drawSpeech "Well, it's not important!  For now, just make me a circuit that lights up two outputs according to how many of three inputs are on.  Don't worry, I wrote the desired results down for you as I always do.",
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
