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
	Baab.setExpression baab.eyebrows.normal, baab.eyes.normal, baab.mouth.smallOpen
	drawing.drawSpeech "OK, remember that separated _on_ and _off_ thing you did for me last time?",
		drawing.Speaker.Right, "Baab"
end function
playSteps.push function
	displays.vnBackground.drawImage backgrounds.lab
	Alicia.setExpression alicia.eyebrows.normal, alicia.eyes.normal, alicia.mouth.smile
	Baab.setExpression baab.eyebrows.normal, baab.eyes.normal, baab.mouth.normal
	drawing.drawSpeech "You mean the latch, right?", drawing.Speaker.Left, "Alicia"
end function
playSteps.push function
	displays.vnBackground.drawImage backgrounds.lab
	Alicia.setExpression alicia.eyebrows.normal, alicia.eyes.normal, alicia.mouth.normal
	Baab.setExpression baab.eyebrows.mad, baab.eyes.normal, baab.mouth.frown
	drawing.drawSpeech "Yeah.  Turns out the client wasn't telling us the whole story.",
		drawing.Speaker.Right, "Baab"
end function
playSteps.push function
	displays.vnBackground.drawImage backgrounds.lab
	Alicia.setExpression alicia.eyebrows.normal, alicia.eyes.normal, alicia.mouth.normal
	Baab.setExpression baab.eyebrows.normal, baab.eyes.normal, baab.mouth.normal
	drawing.drawSpeech "What they're really trying to make is a quiz game for the annual Snoof Festival.",
		drawing.Speaker.Right, "Baab"
end function
playSteps.push function
	displays.vnBackground.drawImage backgrounds.lab
	Alicia.setExpression alicia.eyebrows.sad, alicia.eyes.normal, alicia.mouth.small
	Baab.setExpression baab.eyebrows.normal, baab.eyes.normal, baab.mouth.normal
	drawing.drawSpeech "Quiz game?  How does that work?", 
		drawing.Speaker.Left, "Alicia"
end function
playSteps.push function
	displays.vnBackground.drawImage backgrounds.lab
	Alicia.setExpression alicia.eyebrows.normal, alicia.eyes.normal, alicia.mouth.normal
	Baab.setExpression baab.eyebrows.normal, baab.eyes.normal, baab.mouth.normal
	drawing.drawSpeech "Well, they'll have three contestants on stage, and a quizmaster who asks them a question.",
		drawing.Speaker.Right, "Baab"
end function
playSteps.push function
	displays.vnBackground.drawImage backgrounds.lab
	Alicia.setExpression alicia.eyebrows.normal, alicia.eyes.normal, alicia.mouth.normal
	Baab.setExpression baab.eyebrows.normal, baab.eyes.normal, baab.mouth.normal
	drawing.drawSpeech "Each contestant has an ink button in front of them, which they touch when they know the answer.  This lights up a big ink symbol on the front of their podium.",
		drawing.Speaker.Right, "Baab"
end function
playSteps.push function
	displays.vnBackground.drawImage backgrounds.lab
	Alicia.setExpression alicia.eyebrows.normal, alicia.eyes.normal, alicia.mouth.openSmile
	Baab.setExpression baab.eyebrows.normal, baab.eyes.normal, baab.mouth.normal
	drawing.drawSpeech "Well that sounds easy!  Just connect the button to the symbol!",
		drawing.Speaker.Left, "Alicia"
end function
playSteps.push function
	displays.vnBackground.drawImage backgrounds.lab
	Alicia.setExpression alicia.eyebrows.sad, alicia.eyes.normal, alicia.mouth.normal
	Baab.setExpression baab.eyebrows.normal, baab.eyes.normal, baab.mouth.smile
	drawing.drawSpeech "Not so fast! They only want it to light up for the _first_ contestant to press the button.  Any subsequent button presses should be ignored, until the quizmaster resets the whole thing for the next question.",
		drawing.Speaker.Right, "Baab"
end function
playSteps.push function
	displays.vnBackground.drawImage backgrounds.lab
	Alicia.setExpression alicia.eyebrows.normal, alicia.eyes.normal, alicia.mouth.smallFrown
	Baab.setExpression baab.eyebrows.normal, baab.eyes.normal, baab.mouth.normal
	drawing.drawSpeech "Oh dear.  That _does_ sound tricky. Why did they tell us before that they wanted a latch?",
		drawing.Speaker.Left, "Alicia"
end function
playSteps.push function
	displays.vnBackground.drawImage backgrounds.lab
	Alicia.setExpression alicia.eyebrows.normal, alicia.eyes.normal, alicia.mouth.normal
	Baab.setExpression baab.eyebrows.mad, baab.eyes.normal, baab.mouth.huh
	drawing.drawSpeech "Why do clients always leave stuff out?  I suppose they thought they were being helpful somehow.",
		drawing.Speaker.Right, "Baab"
end function
playSteps.push function
	displays.vnBackground.drawImage backgrounds.lab
	Alicia.setExpression alicia.eyebrows.normal, alicia.eyes.normal, alicia.mouth.normal
	Baab.setExpression baab.eyebrows.sad, baab.eyes.normal, baab.mouth.normal
	drawing.drawSpeech "Anyway, that's what we need now.  Only light up the output that goes with the _first_ input, ignoring all others until reset.",
		drawing.Speaker.Right, "Baab"
end function
playSteps.push function
	displays.vnBackground.drawImage backgrounds.lab
	Alicia.setExpression alicia.eyebrows.normal, alicia.eyes.normal, alicia.mouth.normal
	Baab.setExpression baab.eyebrows.normal, baab.eyes.normal, baab.mouth.smile
	drawing.drawSpeech "Can you do it, " + gameData.playerName + "?",
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
