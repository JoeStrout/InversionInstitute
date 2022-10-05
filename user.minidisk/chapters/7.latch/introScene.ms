// Intro scene for the "latch" task, in which we make an output that
// is turned on with one input and turned off with a different input.

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
Baab.present = true

playSteps.push function
	displays.vnBackground.drawImage backgrounds.lab
	Alicia.setExpression alicia.eyebrows.normal, alicia.eyes.normal, alicia.mouth.normal
	Baab.setExpression baab.eyebrows.normal, baab.eyes.normal, baab.mouth.joy
	drawing.drawSpeech "Hey, " + gameData.playerName + "!  I've got another one for you.",
		drawing.Speaker.Right, "Baab"
end function
playSteps.push function
	displays.vnBackground.drawImage backgrounds.lab
	Alicia.setExpression alicia.eyebrows.normal, alicia.eyes.giggle, alicia.mouth.smile
	Baab.setExpression baab.eyebrows.normal, baab.eyes.normal, baab.mouth.normal
	drawing.drawSpeech "Really, Baab?  " + gameData.pronoun.they + 
		" just finished the last task!", drawing.Speaker.Left, "Alicia"
end function
playSteps.push function
	displays.vnBackground.drawImage backgrounds.lab
	Alicia.setExpression alicia.eyebrows.normal, alicia.eyes.normal, alicia.mouth.normal
	Baab.setExpression baab.eyebrows.mad, baab.eyes.closing, baab.mouth.smile
	drawing.drawSpeech "But this is an interesting one, I swear!",
		drawing.Speaker.Right, "Baab"
end function
playSteps.push function
	displays.vnBackground.drawImage backgrounds.lab
	Alicia.setExpression alicia.eyebrows.normal, alicia.eyes.normal, alicia.mouth.normal
	Baab.setExpression baab.eyebrows.normal, baab.eyes.normal, baab.mouth.normal
	drawing.drawSpeech "So, you know how normally you touch ink, and it lights up " +
	"if it was dark, or goes dark if it was light, right?",
		drawing.Speaker.Right, "Baab"
end function
playSteps.push function
	displays.vnBackground.drawImage backgrounds.lab
	Alicia.setExpression alicia.eyebrows.normal, alicia.eyes.normal, alicia.mouth.small
	Baab.setExpression baab.eyebrows.normal, baab.eyes.normal, baab.mouth.normal
	drawing.drawSpeech "Sure, it toggles.  Everybody knows that.", 
		drawing.Speaker.Left, "Alicia"
end function
playSteps.push function
	displays.vnBackground.drawImage backgrounds.lab
	Alicia.setExpression alicia.eyebrows.normal, alicia.eyes.normal, alicia.mouth.normal
	Baab.setExpression baab.eyebrows.normal, baab.eyes.normal, baab.mouth.normal
	drawing.drawSpeech "Yeah.  Well we have a client that wants to separate the ""on"" " +
	"and ""off"" functions into two different blobs of ink.",
		drawing.Speaker.Right, "Baab"
end function
playSteps.push function
	displays.vnBackground.drawImage backgrounds.lab
	Alicia.setExpression alicia.eyebrows.sad, alicia.eyes.normal, alicia.mouth.smallFrown
	Baab.setExpression baab.eyebrows.normal, baab.eyes.normal, baab.mouth.normal
	drawing.drawSpeech "What?  Like, you could only turn a sign on from one room, " +
	"and only turn it off from a different room?!",
		drawing.Speaker.Left, "Alicia"
end function
playSteps.push function
	displays.vnBackground.drawImage backgrounds.lab
	Alicia.setExpression alicia.eyebrows.sad, alicia.eyes.normal, alicia.mouth.normal
	Baab.setExpression baab.eyebrows.normal, baab.eyes.normal, baab.mouth.smile
	drawing.drawSpeech "Exactly!  Sounds impossible, right?",
		drawing.Speaker.Right, "Baab"
end function
playSteps.push function
	displays.vnBackground.drawImage backgrounds.lab
	Alicia.setExpression alicia.eyebrows.normal, alicia.eyes.normal, alicia.mouth.normal
	Baab.setExpression baab.eyebrows.normal, baab.eyes.giggle, baab.mouth.smile
	drawing.drawSpeech "I told you this was an interesting one!",
		drawing.Speaker.Right, "Baab"
end function
playSteps.push function
	displays.vnBackground.drawImage backgrounds.lab
	Alicia.setExpression alicia.eyebrows.normal, alicia.eyes.normal, alicia.mouth.normal
	Baab.setExpression baab.eyebrows.normal, baab.eyes.normal, baab.mouth.normal
	drawing.drawSpeech "Now I've figured out part of it -- I've got ink blobs that only stay lit when you're touching them.  As soon as you let go, they go dark.",
		drawing.Speaker.Right, "Baab"
end function
playSteps.push function
	displays.vnBackground.drawImage backgrounds.lab
	Alicia.setExpression alicia.eyebrows.normal, alicia.eyes.normal, alicia.mouth.normal
	Baab.setExpression baab.eyebrows.sad, baab.eyes.normal, baab.mouth.huh
	drawing.drawSpeech "But now I'm stuck.  How do I combine these so that one turns the output side on, and the other turns it off?",
		drawing.Speaker.Right, "Baab"
end function
playSteps.push function
	displays.vnBackground.drawImage backgrounds.lab
	Alicia.setExpression alicia.eyebrows.sad, alicia.eyes.normal, alicia.mouth.smallFrown
	Baab.setExpression baab.eyebrows.normal, baab.eyes.normal, baab.mouth.normal
	drawing.drawSpeech "I guess it's sort of like a _latch_ with two buttons... one button sets the latch, and the other one resets it.",
		drawing.Speaker.Left, "Alicia"
end function
playSteps.push function
	displays.vnBackground.drawImage backgrounds.lab
	Alicia.setExpression alicia.eyebrows.normal, alicia.eyes.normal, alicia.mouth.normal
	Baab.setExpression baab.eyebrows.normal, baab.eyes.normal, baab.mouth.frown
	drawing.drawSpeech "If by _set_ you mean ""light up"", and by _reset_ " +
	"you mean ""turn off"", then yeah, I guess that's right.",
		drawing.Speaker.Right, "Baab"
end function
playSteps.push function
	displays.vnBackground.drawImage backgrounds.lab
	Alicia.setExpression alicia.eyebrows.normal, alicia.eyes.normal, alicia.mouth.normal
	Baab.setExpression baab.eyebrows.normal, baab.eyes.normal, baab.mouth.smile
	drawing.drawSpeech "What do you say, " + gameData.playerName + "?  Can you help " +
	"us out again?",
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
