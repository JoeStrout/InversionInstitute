// Return scene for Chapter 6.

import "miscUtil"
ensureImport "scene"
ensureImport "gameData"
import "findErrors"
import "context"

ch = "ch" + context.number
if not gameData.data.hasIndex(ch) or not gameData.data[ch] then gameData.data[ch] = {}

if not globals.hasIndex("sim") then
	displays.setupEditorSim
	display(0).mode = displayMode.solidColor; display(0).color = color.black
	import "pixelLogicSim"; sim = pixelLogicSim
	circuitPic = gameData.loadCircuitForChapter(context.number)
	if circuitPic == null then
		circuitPic = Image.create(80, 64, color.black)
	end if
	displays.simGfx.drawImage circuitPic
end if

if not sim.nodes then
	sim.setup true
	sim.analyze
end if

errors = findErrors.check

display(0).mode = displayMode.off

scene.prepare context.number, "/usr/chapters/" + context.folderName
Baab.present = true

if errors then
	playSteps.push function
		displays.vnBackground.drawImage backgrounds.lab
		Alicia.setExpression alicia.eyebrows.normal, alicia.eyes.normal, alicia.mouth.normal
		Baab.setExpression baab.eyebrows.sad, baab.eyes.normal, baab.mouth.frown
		drawing.drawSpeech "Hmm, I guess this is a tricky one?",
			drawing.Speaker.Right, "Baab"
	end function

	playSteps.push function
		displays.vnBackground.drawImage backgrounds.lab
		Alicia.setExpression alicia.eyebrows.normal, alicia.eyes.normal, alicia.mouth.smile
		Baab.setExpression baab.eyebrows.normal, baab.eyes.normal, baab.mouth.huh
		// ToDo: get player's pronouns, and adjust accordingly
		drawing.drawSpeech "Don't worry Baab, " + gameData.pronoun.they + "'ll get it!",
			drawing.Speaker.Left, "Alicia"
	end function
	
	playSteps.push function
		sim.nodes = []
		context.objectivesDrawn = false
		context.checkDrawn = false
		scene.switchToEditor
	end function

else
	//----------------------------------------------------------------------
	// Done with this task!
	gameData.data[ch].done = true
	gameData.writeToDisk

	playSteps.push function
		displays.vnBackground.drawImage backgrounds.lab
		Alicia.setExpression alicia.eyebrows.normal, alicia.eyes.normal, alicia.mouth.smile
		Baab.setExpression baab.eyebrows.normal, baab.eyes.normal, baab.mouth.openSmile
		drawing.drawSpeech "You've done it again, " + gameData.playerName + "!",
			drawing.Speaker.Right, "Baab"
	end function

	playSteps.push function
		displays.vnBackground.drawImage backgrounds.lab
		Alicia.setExpression alicia.eyebrows.normal, alicia.eyes.giggle, alicia.mouth.smile
		Baab.setExpression baab.eyebrows.normal, baab.eyes.normal, baab.mouth.smile
		// ToDo: get player's pronouns, and adjust accordingly
		drawing.drawSpeech "I never had any doubt.",
			drawing.Speaker.Left, "Alicia"
	end function

	playSteps.push function
//		scene.playSunset
		gameData.data.curChapter = context.number + 1
		gameData.writeToDisk
		toc.startChapter
	end function

end if
//----------------------------------------------------------------------


if locals == globals then
	scene.play
end if
