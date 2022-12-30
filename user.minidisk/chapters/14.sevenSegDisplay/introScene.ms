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

Alicia.present = false
Baab.present = true

playSteps.push function
	displays.vnBackground.drawImage backgrounds.lab
	Baab.setExpression baab.eyebrows.normal, baab.eyes.normal, baab.mouth.openSmile
	drawing.drawSpeech "Hey " + gameData.playerName + "! Glad I caught you before Alicia got in.",
		drawing.Speaker.Right, "Baab"
end function
playSteps.push function
	displays.vnBackground.drawImage backgrounds.lab
	Baab.setExpression baab.eyebrows.normal, baab.eyes.normal, baab.mouth.normal
	drawing.drawSpeech "Remember that 0/1 display you did for her a while back?",
		drawing.Speaker.Right, "Baab"
end function
playSteps.push function
	displays.vnBackground.drawImage backgrounds.lab
	Baab.setExpression baab.eyebrows.normal, baab.eyes.normal, baab.mouth.smile
	drawing.drawSpeech "Well, now she's on this ""binary numbers"" kick, I thought maybe we could surprise her with a better display.",
		drawing.Speaker.Right, "Baab"
end function
playSteps.push function
	displays.vnBackground.drawImage backgrounds.lab
	Baab.setExpression baab.eyebrows.normal, baab.eyes.normal, baab.mouth.normal
	drawing.drawSpeech "I've worked out a pattern of ink with 7 segments that can light up in differnt ways to represent any digit from 0 to 9.",
		drawing.Speaker.Right, "Baab"
end function
playSteps.push function
	displays.vnBackground.drawImage backgrounds.lab
	Baab.setExpression baab.eyebrows.normal, baab.eyes.normal, baab.mouth.frown2
	drawing.drawSpeech "Though come to think of it, a 3-digit binary number can't be bigger than 1+2+4, which is *7*.  So I guess we only need it to show 0 through 7.",
		drawing.Speaker.Right, "Baab"
end function
playSteps.push function
	displays.vnBackground.drawImage backgrounds.lab
	Baab.setExpression baab.eyebrows.normal, baab.eyes.normal, baab.mouth.normal
	drawing.drawSpeech "Anyway, I'd love to give Alicia something where 3 inputs come in on the left, and on the right, the number 0-7 appears on our 7-segment display.",
		drawing.Speaker.Right, "Baab"
end function
playSteps.push function
	displays.vnBackground.drawImage backgrounds.lab
	Baab.setExpression baab.eyebrows.sad, baab.eyes.normal, baab.mouth.frown
	drawing.drawSpeech "Trouble is, we don't have a lot of space.  I don't know how you're going to cram all that in!",
		drawing.Speaker.Right, "Baab"
end function
playSteps.push function
	displays.vnBackground.drawImage backgrounds.lab
	Baab.setExpression baab.eyebrows.normal, baab.eyes.giggle, baab.mouth.smile
	drawing.drawSpeech "But you're good at this stuff!  I bet you can think of something.",
		drawing.Speaker.Right, "Baab"
end function
playSteps.push function
	displays.vnBackground.drawImage backgrounds.lab
	Baab.setExpression baab.eyebrows.normal, baab.eyes.normal, baab.mouth.smile
	drawing.drawSpeech "And I'll keep thinking about it too.  If you get stuck, come talk to me again and we'll see what we can figure out together.",
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
