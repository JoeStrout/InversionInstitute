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
Baab.present = true
Alicia.present = false

if errors then
	playSteps.push function
		displays.vnBackground.drawImage backgrounds.lab
		Baab.setExpression baab.eyebrows.sad, baab.eyes.normal, baab.mouth.frown2
		drawing.drawSpeech "Yeah, this is a tough one, isn't it?",
			drawing.Speaker.Right, "Baab"
	end function

	playSteps.push function
		displays.vnBackground.drawImage backgrounds.lab
		Baab.setExpression baab.eyebrows.normal, baab.eyes.normal, baab.mouth.oh
		drawing.drawSpeech "I was thinking, maybe you could make sort of a ""combination grid"".",
			drawing.Speaker.Right, "Baab"
	end function
	
	playSteps.push function
		displays.vnBackground.drawImage backgrounds.lab
		Baab.setExpression baab.eyebrows.normal, baab.eyes.normal, baab.mouth.huh
		drawing.drawSpeech "I'm picturing a big grid of horizontal and vertical ink lines.",
			drawing.Speaker.Right, "Baab"
	end function
	
	playSteps.push function
		displays.vnBackground.drawImage backgrounds.lab
		Baab.setExpression baab.eyebrows.normal, baab.eyes.normal, baab.mouth.huh
		drawing.drawSpeech "Maybe have one column for each of the values 0-7.  Input lines would feed into that horizontally, and you'd have little inversion glyphs hooked up to activate the right vertical line for each sum.",
			drawing.Speaker.Right, "Baab"
	end function
	
	playSteps.push function
		displays.vnBackground.drawImage backgrounds.lab
		Baab.setExpression baab.eyebrows.normal, baab.eyes.normal, baab.mouth.normal
		drawing.drawSpeech "Then those lines would drop down, and cross another set of horizontal lines, one for each segment in the display.",
			drawing.Speaker.Right, "Baab"
	end function
	
	playSteps.push function
		displays.vnBackground.drawImage backgrounds.lab
		Baab.setExpression baab.eyebrows.normal, baab.eyes.normal, baab.mouth.smile
		drawing.drawSpeech "And here, glyphs would connect each sum line to the segments that should light up for that value!",
			drawing.Speaker.Right, "Baab"
	end function

	playSteps.push function
		displays.vnBackground.drawImage backgrounds.lab
		Baab.setExpression baab.eyebrows.normal, baab.eyes.giggle, baab.mouth.normal
		drawing.drawSpeech "Maybe it's a crazy idea.  But see what you can make of it!",
			drawing.Speaker.Right, "Baab"
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
		Alicia.present = false
		Baab.setExpression baab.eyebrows.normal, baab.eyes.normal, baab.mouth.openSmile
		drawing.drawSpeech "You did it!  And just in time, too!",
			drawing.Speaker.Right, "Baab"
	end function

	playSteps.push function
		displays.vnBackground.drawImage backgrounds.lab
		Alicia.present = true
		Alicia.setExpression alicia.eyebrows.sad, alicia.eyes.normal, alicia.mouth.smile
		Baab.setExpression baab.eyebrows.normal, baab.eyes.normal, baab.mouth.smile
		drawing.drawSpeech "Well hello! You two are in early, aren't you?",
			drawing.Speaker.Left, "Alica"
	end function

	playSteps.push function
		displays.vnBackground.drawImage backgrounds.lab
		Alicia.setExpression alicia.eyebrows.normal, alicia.eyes.normal, alicia.mouth.smile
		Baab.setExpression baab.eyebrows.normal, baab.eyes.normal, baab.mouth.openSmile
		drawing.drawSpeech gameData.playerName + " and I made a little something for you.",
			drawing.Speaker.Right, "Baab"
	end function

	playSteps.push function
		displays.vnBackground.drawImage backgrounds.lab
		Alicia.present = true
		Alicia.setExpression alicia.eyebrows.normal, alicia.eyes.normal, alicia.mouth.joy
		Baab.setExpression baab.eyebrows.normal, baab.eyes.normal, baab.mouth.smile
		drawing.drawSpeech "What's this?  ...Oh my!  Look, it shows any 3-digit binary number as an ordinary number!",
			drawing.Speaker.Left, "Alica"
	end function

	playSteps.push function
		displays.vnBackground.drawImage backgrounds.lab
		Alicia.present = true
		Alicia.setExpression alicia.eyebrows.normal, alicia.eyes.giggle, alicia.mouth.smile
		Baab.setExpression baab.eyebrows.normal, baab.eyes.normal, baab.mouth.smile
		drawing.drawSpeech "Thank you both!  This is going to be really useful!",
			drawing.Speaker.Left, "Alica"
	end function

	playSteps.push function
		displays.vnBackground.drawImage backgrounds.lab
		Alicia.setExpression alicia.eyebrows.normal, alicia.eyes.normal, alicia.mouth.normal
		Baab.setExpression baab.eyebrows.normal, baab.eyes.normal, baab.mouth.normal
		drawing.drawSpeech "I bet that combination grid thing " + gameData.playerName + " came up with will be useful in other places, too.",
			drawing.Speaker.Right, "Baab"
	end function

	playSteps.push function
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
