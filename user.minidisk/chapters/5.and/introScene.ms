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
	Alicia.setExpression alicia.eyebrows.normal, alicia.eyes.normal, alicia.mouth.normal
	Alicia.setLeftArm alicia.LeftArm.normal
	Baab.present = false
	drawing.drawSpeech "I'd like to introduce you to someone today.",
		drawing.Speaker.Left, "Alicia"
end function
playSteps.push function
	displays.vnBackground.drawImage backgrounds.lab
	Baab.present = true
	Alicia.setExpression alicia.eyebrows.normal, alicia.eyes.normal, alicia.mouth.smile
	Alicia.setLeftArm alicia.LeftArm.showing
	drawing.drawSpeech "This is Baab.  Spelled with two ""A""s.",
		drawing.Speaker.Left, "Alicia"
end function
playSteps.push function
	displays.vnBackground.drawImage backgrounds.lab
	Alicia.setExpression alicia.eyebrows.normal, alicia.eyes.giggle, alicia.mouth.smile
	Alicia.setLeftArm alicia.LeftArm.normal
	Baab.setExpression baab.eyebrows.mad, baab.eyes.closing, baab.mouth.huh
	drawing.drawSpeech "Well of course it's with two ""A""s.  How else would you spell it?!",
		drawing.Speaker.Right, "Baab"
end function
playSteps.push function
	displays.vnBackground.drawImage backgrounds.lab
	Alicia.setExpression alicia.eyebrows.normal, alicia.eyes.normal, alicia.mouth.normal
	Baab.setExpression baab.eyebrows.normal, baab.eyes.normal, baab.mouth.normal
	drawing.drawSpeech "Baab has been working on ways to make Magic Ink affect real objects in the world.",
		drawing.Speaker.Left, "Alicia"
end function
playSteps.push function
	displays.vnBackground.drawImage backgrounds.lab
	Alicia.setExpression alicia.eyebrows.normal, alicia.eyes.normal, alicia.mouth.normal
	Baab.setExpression baab.eyebrows.normal, baab.eyes.normal, baab.mouth.smile
	drawing.drawSpeech "Right.  I'm currently working on a project for an important Institute sponsor, Andi Anderson.",
		drawing.Speaker.Right, "Baab"
end function
playSteps.push function
	displays.vnBackground.drawImage backgrounds.lab
	Alicia.setExpression alicia.eyebrows.normal, alicia.eyes.normal, alicia.mouth.normal
	Baab.setExpression baab.eyebrows.normal, baab.eyes.normal, baab.mouth.smile
	drawing.drawSpeech "He's got this big wall around his estate, and a gate with two guards out front.",
		drawing.Speaker.Right, "Baab"
end function
playSteps.push function
	displays.vnBackground.drawImage backgrounds.lab
	Alicia.setExpression alicia.eyebrows.normal, alicia.eyes.normal, alicia.mouth.normal
	Baab.setExpression baab.eyebrows.normal, baab.eyes.normal, baab.mouth.smile
	drawing.drawSpeech "I've made a spell that can unlock the gate when some Magic Ink lights up.",
		drawing.Speaker.Right, "Baab"
end function
playSteps.push function
	displays.vnBackground.drawImage backgrounds.lab
	Alicia.setExpression alicia.eyebrows.normal, alicia.eyes.normal, alicia.mouth.normal
	Baab.setExpression baab.eyebrows.sad, baab.eyes.normal, baab.mouth.frown
	drawing.drawSpeech "...Trouble is, Andi wants the gate to open only if BOTH guards activate their Ink.  I'm not sure how to do that.",
		drawing.Speaker.Right, "Baab"
end function
playSteps.push function
	displays.vnBackground.drawImage backgrounds.lab
	Alicia.setExpression alicia.eyebrows.normal, alicia.eyes.giggle, alicia.mouth.smile
	Baab.setExpression baab.eyebrows.normal, baab.eyes.normal, baab.mouth.normal
	drawing.drawSpeech "I told Baab that you were clever with that sort of thing.",
		drawing.Speaker.Left, "Alicia"
end function
playSteps.push function
	displays.vnBackground.drawImage backgrounds.lab
	Alicia.setExpression alicia.eyebrows.normal, alicia.eyes.normal, alicia.mouth.normal
	Baab.setExpression baab.eyebrows.normal, baab.eyes.normal, baab.mouth.smile
	drawing.drawSpeech "Boy, if you could, that would really help me out!",
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
