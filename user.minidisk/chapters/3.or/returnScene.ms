// Return scene for Chapter 2.

import "miscUtil"
ensureImport "scene"
ensureImport "gameData"
import "findErrors"
import "context"

if not gameData.data.hasIndex("ch3") or not gameData.data.ch3 then gameData.data.ch3 = {}

if not globals.hasIndex("sim") then
	displays.setupEditorSim
	display(0).mode = displayMode.solidColor; display(0).color = color.black
	import "pixelLogicSim"; sim = pixelLogicSim
	circuitPic = gameData.loadCircuitForChapter(3)
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

scene.prepare 3, "/usr/chapters/3.or"
if not errors then
	gameData.data.ch3.didDiode = true
	gameData.writeToDisk
end if

if errors then
	playSteps.push function
		displays.vnBackground.drawImage backgrounds.lab
		Alicia.setExpression alicia.eyebrows.sad, alicia.eyes.normal, alicia.mouth.normal
		drawing.drawSpeech "How's it going with the night light project?",
			drawing.Speaker.Left, "Alicia"
	end function

	playSteps.push function
		displays.vnBackground.drawImage backgrounds.lab
		Alicia.setExpression alicia.eyebrows.sad, alicia.eyes.normal, alicia.mouth.normal
		drawing.drawSpeech "I hear Mrs. Oarsley has been losing sleep mediating between Fish and Chip about that light.",
			drawing.Speaker.Left, "Alicia"
	end function

	playSteps.push function
		displays.vnBackground.drawImage backgrounds.lab
		Alicia.setExpression alicia.eyebrows.normal, alicia.eyes.normal, alicia.mouth.normal
		drawing.drawSpeech "The whole family will sleep better once you solve this one, for sure.",
			drawing.Speaker.Left, "Alicia"
	end function

	playSteps.push function
		displays.vnBackground.drawImage backgrounds.lab
		Alicia.setExpression alicia.eyebrows.normal, alicia.eyes.giggle, alicia.mouth.normal
		drawing.drawSpeech "Don't forget to Check your work!",
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

	playSteps.push function
		displays.vnBackground.drawImage backgrounds.lab
		Alicia.setExpression alicia.eyebrows.normal, alicia.eyes.giggle, alicia.mouth.smile
		drawing.drawSpeech "Well done!",
			drawing.Speaker.Left, "Alicia"
	end function

	playSteps.push function
		displays.vnBackground.drawImage backgrounds.lab
		Alicia.setExpression alicia.eyebrows.normal, alicia.eyes.normal, alicia.mouth.normal
		drawing.drawSpeech "Now Fish and Chip can have a light whenever either of them wants it.",
			drawing.Speaker.Left, "Alicia"
	end function

	playSteps.push function
		displays.vnBackground.drawImage backgrounds.lab
		Alicia.setExpression alicia.eyebrows.normal, alicia.eyes.giggle, alicia.mouth.smile
		drawing.drawSpeech "And Mrs. Oarsley can get some sleep!",
			drawing.Speaker.Left, "Alicia"
	end function

	playSteps.push function
		scene.playSunset
		gameData.data.curChapter = 4
		gameData.writeToDisk
		text.row = 0; exit // FOR NOW!
	end function

end if
//----------------------------------------------------------------------


if locals == globals then
	scene.play
end if
