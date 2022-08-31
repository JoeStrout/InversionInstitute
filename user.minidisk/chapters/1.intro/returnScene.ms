// Return scene for Chapter 1.

import "miscUtil"
ensureImport "scene"

if not globals.hasIndex("sim") then
	displays.setupEditorSim
	display(0).mode = displayMode.solidColor; display(0).color = color.black
	import "pixelLogicSim"; sim = pixelLogicSim
	circuitPic = gameData.loadCircuitForChapter(1)
	if circuitPic == null then
		circuitPic = Image.create(80, 64, color.black)
	end if
	displays.simGfx.drawImage circuitPic
end if

if not sim.nodes then
	sim.setup true
	sim.analyze
end if

display(0).mode = displayMode.off

CrossingDwg = {}
CrossingDwg.images = []
CrossingDwg.images.push file.loadImage("Crossing0.png")
CrossingDwg.images.push file.loadImage("Crossing1.png")
CrossingDwg.images.push CrossingDwg.images[0]
CrossingDwg.images.push file.loadImage("Crossing2.png")
CrossingDwg.curIndex = -1
CrossingDwg.nextUpdateTime = 0
CrossingDwg.draw = function
	img = self.images[self.curIndex]
	gfx.drawImage img, 592-img.width/2, 420-img.height/2
end function
CrossingDwg.update = function
	if time > self.nextUpdateTime then
		self.curIndex = (self.curIndex + 1) % self.images.len
		self.draw
		self.nextUpdateTime = time + 0.5 + 0.5*(self.curIndex == 1 or self.curIndex == 3)
	end if
end function

GateDwg = {}
GateDwg.editMode = file.loadImage("Gate0.png")
GateDwg.images = []
GateDwg.images.push file.loadImage("Gate1.png")
GateDwg.images.push file.loadImage("Gate2.png")
GateDwg.curIndex = -1
GateDwg.nextUpdateTime = 0
GateDwg.draw = function
	img = self.images[self.curIndex]
	gfx.drawImage img, 592-img.width/2, 420-img.height/2
end function
GateDwg.update = function
	if time > self.nextUpdateTime then
		self.curIndex = (self.curIndex + 1) % self.images.len
		self.draw
		self.nextUpdateTime = time + 1
	end if
end function


scene.prepare 1, "/usr/chapters/1.intro"

//// Just for debugging:
//playSteps.push function
//	Alicia.setExpression alicia.eyebrows.normal, alicia.eyes.normal, alicia.mouth.normal
//	drawing.drawSpeech "I see you made " + sim.nodes.len + " nodes, " + 
//			sim.crossings.len + " crossings, and " + sim.gates.len + " gates.",
//		drawing.Speaker.Left, "Alicia"	
//end function

//----------------------------------------------------------------------
// If player hasn't made any crossings, educate them and send them back.
if not sim.crossings then
	playSteps.push function
		displays.vnBackground.drawImage backgrounds.lab
		Alicia.setExpression alicia.eyebrows.normal, alicia.eyes.giggle, alicia.mouth.smile
		drawing.drawSpeech "Did you have fun with that Magic Ink?",
			drawing.Speaker.Left, "Alicia"
	end function

	playSteps.push function
		displays.vnBackground.drawImage backgrounds.lab
		display(6).clear color.clear
		outer.curDrawing = null
		Alicia.setExpression alicia.eyebrows.normal, alicia.eyes.normal, alicia.mouth.normal
		drawing.drawSpeech "There is a trick or two this Magic Ink can do. " +
			"Let me tell you about crossings!",
			drawing.Speaker.Left, "Alicia"
	end function

	playSteps.push function
		displays.vnBackground.drawImage backgrounds.lab
		displays.vnBackground.drawImage demoTablet, 350, 200
		gfx.clear color.clear
		outer.curDrawing = CrossingDwg
		Alicia.setExpression alicia.eyebrows.normal, alicia.eyes.normal, alicia.mouth.normal
		drawing.drawSpeech "You can cross two sets of ink by using very " +
		 "thin lines, and removing the point right where they cross. " + 
		 "Then the left side will be fully connected to the right, and " +
		 "the top side will be connected to the bottom.",
			drawing.Speaker.Left, "Alicia"
	end function
	
	playSteps.push function
		Alicia.setExpression alicia.eyebrows.normal, alicia.eyes.giggle, alicia.mouth.smile
		drawing.drawSpeech "Why don't you give it a try?",
			drawing.Speaker.Left, "Alicia"
	end function

	playSteps.push function
		sim.nodes = []
		scene.switchToEditor
	end function

//----------------------------------------------------------------------
// If player hasn't made any gates, educate them and send them back.
else if not sim.gates then
	playSteps.push function
		displays.vnBackground.drawImage backgrounds.lab
		Alicia.setExpression alicia.eyebrows.normal, alicia.eyes.giggle, alicia.mouth.smile
		drawing.drawSpeech "Looks like you've got the hang of crossings!",
			drawing.Speaker.Left, "Alicia"
	end function

	playSteps.push function
		displays.vnBackground.drawImage backgrounds.lab
		display(6).clear color.clear
		outer.curDrawing = null
		Alicia.setExpression alicia.eyebrows.normal, alicia.eyes.normal, alicia.mouth.normal
		drawing.drawSpeech "In addition to crossings, there is just one special glyph " +
			"which Master Leo worked into Magic Ink.",
			drawing.Speaker.Left, "Alicia"
	end function

	playSteps.push function
		displays.vnBackground.drawImage backgrounds.lab
		displays.vnBackground.drawImage demoTablet, 350, 200
		Alicia.setExpression alicia.eyebrows.normal, alicia.eyes.giggle, alicia.mouth.normal
		drawing.drawSpeech "This is called an Inversion Glyph. " +
		"After the Inversion Institute, of course!",
			drawing.Speaker.Left, "Alicia"
		gfx.drawImage GateDwg.editMode, 592-GateDwg.editMode.width/2, 420-GateDwg.editMode.height/2
	end function

	playSteps.push function
		displays.vnBackground.drawImage backgrounds.lab
		displays.vnBackground.drawImage demoTablet, 350, 200
		Alicia.setExpression alicia.eyebrows.normal, alicia.eyes.normal, alicia.mouth.normal
		drawing.drawSpeech "An Inversion Glyph takes up a 3 by 3 square area, " +
		"with the center and two adjacent corners dark.  Or, you can think " +
		"of it as a little ""C"" shape followed by a dot.",
			drawing.Speaker.Left, "Alicia"
		gfx.drawImage GateDwg.editMode, 592-GateDwg.editMode.width/2, 420-GateDwg.editMode.height/2
	end function

	playSteps.push function
		outer.curDrawing = null
		Alicia.setExpression alicia.eyebrows.normal, alicia.eyes.normal, alicia.mouth.normal
		drawing.drawSpeech "I've painted the Inversion Glyph yellow here, but the color " +
		"doesn't matter.  Also, you can paint them facing any direction.",
			drawing.Speaker.Left, "Alicia"
		gfx.drawImage GateDwg.editMode, 592-GateDwg.editMode.width/2, 420-GateDwg.editMode.height/2
	end function
	
	playSteps.push function
		outer.curDrawing = GateDwg
		Alicia.setExpression alicia.eyebrows.normal, alicia.eyes.normal, alicia.mouth.normal
		drawing.drawSpeech "The magic of an Inversion Glyph is: once it dries, the ink on the " +
		"""dot"" side of the glyph is always opposite the ""C"" part of the glyph. ",
			drawing.Speaker.Left, "Alicia"
	end function

	playSteps.push function
		Alicia.setExpression alicia.eyebrows.normal, alicia.eyes.normal, alicia.mouth.normal
		drawing.drawSpeech "So when the ""C"" side is lit up, the ""dot"" side goes dark, " +
		"and vice versa.",
			drawing.Speaker.Left, "Alicia"
	end function

	playSteps.push function
		Alicia.setExpression alicia.eyebrows.normal, alicia.eyes.giggle, alicia.mouth.smile
		drawing.drawSpeech "Try making some Inversion Glyphs.  Remember to test your drawing!",
			drawing.Speaker.Left, "Alicia"
	end function

	playSteps.push function
		sim.nodes = []
		scene.switchToEditor
	end function

//----------------------------------------------------------------------
// Player has made both gates and nodes -- done with chapter 1!
else
	playSteps.push function
		displays.vnBackground.drawImage backgrounds.lab
		Alicia.setExpression alicia.eyebrows.normal, alicia.eyes.giggle, alicia.mouth.smile
		drawing.drawSpeech "Looks like you've mastered both crossings and Inversion Glyphs!",
			drawing.Speaker.Left, "Alicia"
	end function

	playSteps.push function
		displays.vnBackground.drawImage backgrounds.lab
		Alicia.setExpression alicia.eyebrows.normal, alicia.eyes.normal, alicia.mouth.normal
		drawing.drawSpeech "They don't have much practical use, but they are fun to play with.",
			drawing.Speaker.Left, "Alicia"
	end function

	playSteps.push function
		displays.vnBackground.drawImage backgrounds.lab
		Alicia.setExpression alicia.eyebrows.normal, alicia.eyes.normal, alicia.mouth.normal
		drawing.drawSpeech "It's been a long day.  Let's get you settled in, and tomorrow " +
		"we'll try to find something for you to do around here.",
			drawing.Speaker.Left, "Alicia"
	end function

	playSteps.push function
		scene.playSunset
		text.row = 0; exit // FOR NOW!
	end function

end if
//----------------------------------------------------------------------


if locals == globals then
	scene.play
end if
