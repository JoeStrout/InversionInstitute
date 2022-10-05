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
	Alicia.setExpression alicia.eyebrows.normal, alicia.eyes.normal, alicia.mouth.small
	drawing.drawSpeech "Remember Mrs. Oarsley?  You helped her make a night light for her two boys, Fish and Chip.",
		drawing.Speaker.Left, "Alicia"
end function
playSteps.push function
	displays.vnBackground.drawImage backgrounds.lab
	Alicia.setExpression alicia.eyebrows.sad, alicia.eyes.normal, alicia.mouth.smallFrown
	drawing.drawSpeech "Well, she has an ex-husband.  He calls himself ""Ex-Oarsley"", I guess to be very clear about it.",
		drawing.Speaker.Left, "Alicia"
end function
playSteps.push function
	displays.vnBackground.drawImage backgrounds.lab
	Alicia.setExpression alicia.eyebrows.normal, alicia.eyes.normal, alicia.mouth.normal
	drawing.drawSpeech "Mr. Ex-Oarsley has come to us with his own Magic Ink request.  But it seems his needs are different.",
		drawing.Speaker.Left, "Alicia"
end function
playSteps.push function
	displays.vnBackground.drawImage backgrounds.lab
	Alicia.setExpression alicia.eyebrows.normal, alicia.eyes.normal, alicia.mouth.smile
	drawing.drawSpeech "When the boys are with him, they get along most of the time.  Mr. Ex-Oarsley is content to let them make their own decisions, as long as they are in agreement.",
		drawing.Speaker.Left, "Alicia"
end function
playSteps.push function
	displays.vnBackground.drawImage backgrounds.lab
	Alicia.setExpression alicia.eyebrows.sad, alicia.eyes.normal, alicia.mouth.openFrown
	drawing.drawSpeech "But when they disagree, it quickly escalates into bickering, and apparently Mr. Ex-Oarsley can't stand that.",
		drawing.Speaker.Left, "Alicia"
end function
playSteps.push function
	displays.vnBackground.drawImage backgrounds.lab
	Alicia.setExpression alicia.eyebrows.normal, alicia.eyes.normal, alicia.mouth.smile
	drawing.drawSpeech "So!  He has an idea he calls a ""discord alert"".  When they're making a decision, each boy will touch his own ink pad to say Yay or Nay.  And Mr. Oarsley wants his own ink blob to light up only when the two boys disagree.",
		drawing.Speaker.Left, "Alicia"
end function
playSteps.push function
	displays.vnBackground.drawImage backgrounds.lab
	Alicia.setExpression alicia.eyebrows.normal, alicia.eyes.giggle, alicia.mouth.smile
	drawing.drawSpeech "That way, he'll know to step in before things get out of hand.",
		drawing.Speaker.Left, "Alicia"
end function
playSteps.push function
	displays.vnBackground.drawImage backgrounds.lab
	Alicia.setExpression alicia.eyebrows.normal, alicia.eyes.normal, alicia.mouth.normal
	drawing.drawSpeech "He's got the ink pads all laid out.  Can you show him how to connect them up properly?",
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
