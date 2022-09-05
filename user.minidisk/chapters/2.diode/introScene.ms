// Intro scene the "signal diode" task, in which we must help a teacher
// recall his unruly students at the end of recess.

import "miscUtil"
ensureImport "scene"
ensureImport "objectives"
import "findErrors"
import "context"

scene.prepare 2, "/usr/chapters/2.diode"
if not gameData.data.hasIndex("ch2") or not gameData.data.ch2 then gameData.data.ch2 = {}

//demoTablet = file.loadImage("/usr/pics/ui/DemoTablet.png")

playSteps.push function
	displays.vnBackground.drawImage backgrounds.lab
	Alicia.setExpression alicia.eyebrows.normal, alicia.eyes.giggle, alicia.mouth.smile
	drawing.drawSpeech "Good morning!  I hope your room was comfortable.",
		drawing.Speaker.Left, "Alicia"
end function
playSteps.push function
	displays.vnBackground.drawImage backgrounds.lab
	Alicia.setExpression alicia.eyebrows.normal, alicia.eyes.normal, alicia.mouth.normal
	drawing.drawSpeech "I have a task for you today.",
		drawing.Speaker.Left, "Alicia"
end function
playSteps.push function
	displays.vnBackground.drawImage backgrounds.lab
	Alicia.setExpression alicia.eyebrows.normal, alicia.eyes.normal, alicia.mouth.normal
	drawing.drawSpeech "Sometimes local townsfolk come to the Institute for help. " +
	"Especially if it has to do with one of the Institute products, like Magic Ink.",
		drawing.Speaker.Left, "Alicia"
end function
playSteps.push function
	displays.vnBackground.drawImage backgrounds.lab
	Alicia.setExpression alicia.eyebrows.normal, alicia.eyes.closing, alicia.mouth.flat
	drawing.drawSpeech "Yesterday I said that Magic Ink doesn't have much practical use. " +
	"But some people actually do try to use it for more than just fun and art.",
		drawing.Speaker.Left, "Alicia"
end function
playSteps.push function
	displays.vnBackground.drawImage backgrounds.lab
	Alicia.setExpression alicia.eyebrows.normal, alicia.eyes.normal, alicia.mouth.normal
	drawing.drawSpeech "Mr. Guttersnipe, the local children's schoolteacher, would like " +
	"to use it to make a sign he can light up when it's time for the kids to come in from recess.",
		drawing.Speaker.Left, "Alicia"
end function
playSteps.push function
	displays.vnBackground.drawImage backgrounds.lab
	Alicia.setExpression alicia.eyebrows.normal, alicia.eyes.normal, alicia.mouth.openSmile
	drawing.drawSpeech "He painted a big RECESS OVER sign on the outside wall, with a trail " +
	"of ink connecting it to a blob on his desk.  So he can touch the blob to turn the " +
	"sign on and off!  Clever, right?",
		drawing.Speaker.Left, "Alicia"
end function
playSteps.push function
	displays.vnBackground.drawImage backgrounds.lab
	Alicia.setExpression alicia.eyebrows.sad, alicia.eyes.normal, alicia.mouth.frown
	drawing.drawSpeech "The trouble is... his little rascals keep tapping the sign to turn it back off.",
		drawing.Speaker.Left, "Alicia"
end function
playSteps.push function
	displays.vnBackground.drawImage backgrounds.lab
	Alicia.setExpression alicia.eyebrows.normal, alicia.eyes.normal, alicia.mouth.normal
	drawing.drawSpeech "Can you come up with a way that the sign can only be controlled " +
	"from Mr. Guttersnipe's end, and not from the sign itself?",
		drawing.Speaker.Left, "Alicia"
end function
playSteps.push function
	displays.vnBackground.drawImage backgrounds.lab
	Alicia.setExpression alicia.eyebrows.normal, alicia.eyes.giggle, alicia.mouth.normal
	drawing.drawSpeech "Give it a try! I can't wait to see what you come up with.",
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
