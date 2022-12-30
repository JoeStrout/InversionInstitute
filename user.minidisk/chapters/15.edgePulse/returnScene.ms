// Return scene for Chapter 11.

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
Baab.present = false
Alicia.present = true

if errors then
	playSteps.push function
		displays.vnBackground.drawImage backgrounds.lab
			Alicia.setExpression alicia.eyebrows.normal, alicia.eyes.normal, alicia.mouth.small
			drawing.drawSpeech "How's it going?",
				drawing.Speaker.Left, "Alicia"
	end function

	playSteps.push function
		displays.vnBackground.drawImage backgrounds.lab
			Alicia.setExpression alicia.eyebrows.normal, alicia.eyes.normal, alicia.mouth.smallFrown
			drawing.drawSpeech "I feel like that _latch_ you made a while back might be useful here.",
				drawing.Speaker.Left, "Alicia"
	end function

	playSteps.push function
		displays.vnBackground.drawImage backgrounds.lab
			Alicia.setExpression alicia.eyebrows.normal, alicia.eyes.normal, alicia.mouth.flat
			drawing.drawSpeech "Hooked up somehow to feed back and combine with the input, so the output can only be high when the input is high _and_ the latch is off.",
				drawing.Speaker.Left, "Alicia"
	end function

	playSteps.push function
		displays.vnBackground.drawImage backgrounds.lab
			Alicia.setExpression alicia.eyebrows.normal, alicia.eyes.giggle, alicia.mouth.smile
			drawing.drawSpeech "Something like that.  I know you can figure it out!",
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
			drawing.drawSpeech "You did it!  Nice work, " + gameData.playerName + "!",
				drawing.Speaker.Left, "Alicia"
	end function

	playSteps.push function
		displays.vnBackground.drawImage backgrounds.lab
			Alicia.setExpression alicia.eyebrows.normal, alicia.eyes.normal, alicia.mouth.normal
			drawing.drawSpeech "I have a feeling we'll be using this a lot in the future.",
				drawing.Speaker.Left, "Alicia"
	end function

	playSteps.push function
		gameData.data.curChapter = context.number + 1
		gameData.writeToDisk
//		scene.playSunset
//		toc.startChapter
		load "/usr/game/title"; run
	end function

end if
//----------------------------------------------------------------------


if locals == globals then
	scene.play
end if
