// Return scene for Chapter 2.

import "miscUtil"
ensureImport "scene"
ensureImport "gameData"
import "findErrors"
import "context"

if not gameData.data.hasIndex("ch2") or not gameData.data.ch2 then gameData.data.ch2 = {}

if not globals.hasIndex("sim") then
	displays.setupEditorSim
	display(0).mode = displayMode.solidColor; display(0).color = color.black
	import "pixelLogicSim"; sim = pixelLogicSim
	circuitPic = gameData.loadCircuitForChapter(2)
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

scene.prepare 2, "/usr/chapters/2.diode"
if not errors then
	gameData.data.ch2.didDiode = true
	gameData.writeToDisk
end if

if errors then
	playSteps.push function
		displays.vnBackground.drawImage backgrounds.lab
		Alicia.setExpression alicia.eyebrows.sad, alicia.eyes.normal, alicia.mouth.smallFrown
		drawing.drawSpeech "Hmm, it looks like you don't quite have it yet.",
			drawing.Speaker.Left, "Alicia"
	end function

	playSteps.push function
		displays.vnBackground.drawImage backgrounds.lab
		Alicia.setExpression alicia.eyebrows.normal, alicia.eyes.normal, alicia.mouth.normal
		drawing.drawSpeech "Remember, touching the control pad (A) should toggle the sign (B), but touching the sign (B) should not change the ink at all.",
			drawing.Speaker.Left, "Alicia"
	end function

	playSteps.push function
		displays.vnBackground.drawImage backgrounds.lab
		Alicia.setExpression alicia.eyebrows.normal, alicia.eyes.giggle, alicia.mouth.normal
		drawing.drawSpeech "I mean, touching the sign may briefly toggle it, but it should immediately change right back.",
			drawing.Speaker.Left, "Alicia"
	end function

	playSteps.push function
		displays.vnBackground.drawImage backgrounds.lab
		Alicia.setExpression alicia.eyebrows.normal, alicia.eyes.normal, alicia.mouth.smile
		drawing.drawSpeech "Keep at it!  Master Leo believes in you, and so do I.",
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
		drawing.drawSpeech "You did it!",
			drawing.Speaker.Left, "Alicia"
	end function

	playSteps.push function
		displays.vnBackground.drawImage backgrounds.lab
		Alicia.setExpression alicia.eyebrows.normal, alicia.eyes.normal, alicia.mouth.smile
		drawing.drawSpeech "Now Mr. Guttersnipe can signal his children when it's time to come in, and they can't easily turn the sign off.",
			drawing.Speaker.Left, "Alicia"
	end function

	playSteps.push function
		displays.vnBackground.drawImage backgrounds.lab
		Alicia.setExpression alicia.eyebrows.normal, alicia.eyes.normal, alicia.mouth.openSmile
		drawing.drawSpeech "He will be so happy!  I'll be sure to tell him who figured it out.",
			drawing.Speaker.Left, "Alicia"
	end function

	playSteps.push function
		scene.playSunset
		gameData.data.curChapter = 3
		gameData.writeToDisk
		text.row = 0; exit // FOR NOW!
	end function

end if
//----------------------------------------------------------------------


if locals == globals then
	scene.play
end if
