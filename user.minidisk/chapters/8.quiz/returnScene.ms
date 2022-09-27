// Return scene for Chapter 8.

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
Alicia.present = true

if errors then
	playSteps.push function
		displays.vnBackground.drawImage backgrounds.lab
		Alicia.setExpression alicia.eyebrows.normal, alicia.eyes.normal, alicia.mouth.normal
		Baab.setExpression baab.eyebrows.sad, baab.eyes.normal, baab.mouth.frown
		drawing.drawSpeech "Hmm, I thought this might be tricky.",
			drawing.Speaker.Right, "Baab"
	end function

	playSteps.push function
		displays.vnBackground.drawImage backgrounds.lab
		Alicia.setExpression alicia.eyebrows.normal, alicia.eyes.normal, alicia.mouth.smile
		Baab.setExpression baab.eyebrows.normal, baab.eyes.normal, baab.mouth.huh
		// ToDo: get player's pronouns, and adjust accordingly
		drawing.drawSpeech "Don't worry Baab, " + gameData.playerName +
			" will get it!", drawing.Speaker.Left, "Alicia"
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
		drawing.drawSpeech "You've done it!",
			drawing.Speaker.Right, "Baab"
	end function

	playSteps.push function
		displays.vnBackground.drawImage backgrounds.lab
		Alicia.setExpression alicia.eyebrows.normal, alicia.eyes.giggle, alicia.mouth.smile
		Baab.setExpression baab.eyebrows.normal, baab.eyes.normal, baab.mouth.smile
		drawing.drawSpeech "The Snoof Festival is saved.",
			drawing.Speaker.Left, "Alicia"
	end function

	playSteps.push function
		scene.playSunset
		gameData.data.curChapter = context.number + 1
		gameData.writeToDisk
//		toc.startChapter
		load "/usr/game/title"; run
	end function

end if
//----------------------------------------------------------------------


if locals == globals then
	scene.play
end if
