// Return scene for Chapter 2.

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
Alicia.present = true

if errors then
	playSteps.push function
		displays.vnBackground.drawImage backgrounds.lab
		Alicia.setExpression alicia.eyebrows.sad, alicia.eyes.normal, alicia.mouth.normal
		drawing.drawSpeech "Still working on that zero/one display?",
			drawing.Speaker.Left, "Alicia"
	end function

	playSteps.push function
		displays.vnBackground.drawImage backgrounds.lab
		Alicia.setExpression alicia.eyebrows.normal, alicia.eyes.normal, alicia.mouth.normal
		drawing.drawSpeech "Well, please keep at it. If anyone can figure it out, you can!",
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
		Alicia.setExpression alicia.eyebrows.normal, alicia.eyes.giggle, alicia.mouth.smile
		drawing.drawSpeech "Thank you, that looks perfect!",
			drawing.Speaker.Left, "Alicia"
	end function

	playSteps.push function
		displays.vnBackground.drawImage backgrounds.lab
		Alicia.setExpression alicia.eyebrows.normal, alicia.eyes.normal, alicia.mouth.smile
		drawing.drawSpeech "This proves that Ink signals can be thought of as 0 and 1.  And displayed that way, too!",
			drawing.Speaker.Left, "Alicia"
	end function

	playSteps.push function
		displays.vnBackground.drawImage backgrounds.lab
		Alicia.setExpression alicia.eyebrows.normal, alicia.eyes.normal, alicia.mouth.normal
		drawing.drawSpeech "I'll start thinking about what we can do with that.",
			drawing.Speaker.Left, "Alicia"
	end function

	playSteps.push function
		scene.playSunset
		gameData.data.curChapter = context.number + 1
		gameData.writeToDisk
		text.row = 0; exit // FOR NOW!
	end function

end if
//----------------------------------------------------------------------


if locals == globals then
	scene.play
end if
