// Return scene for Chapter 1.

import "miscUtil"
ensureImport "scene"

if not sim.nodes then
	sim.setup true
	sim.analyze
end if

CrossingDwg = {}
CrossingDwg.images = []
CrossingDwg.images.push file.loadImage("Crossing0.png")
CrossingDwg.images.push file.loadImage("Crossing1.png")
CrossingDwg.images.push CrossingDwg.images[0]
CrossingDwg.images.push file.loadImage("Crossing2.png")
CrossingDwg.curIndex = -1
CrossingDwg.nextUpdateTime = 0
CrossingDwg.update = function
	if time > self.nextUpdateTime then
		self.curIndex = (self.curIndex + 1) % self.images.len
		img = self.images[self.curIndex]
		gfx.drawImage img, 592-img.width/2, 420-img.height/2
		self.nextUpdateTime = time + 0.5 + 0.5*(self.curIndex == 1 or self.curIndex == 3)
	end if
end function

scene.prepare 1, "/usr/chapters/1.intro"

playSteps.push function
	displays.vnBackground.drawImage backgrounds.lab
	Alicia.setExpression alicia.eyebrows.normal, alicia.eyes.giggle, alicia.mouth.smile
	drawing.drawSpeech "Did you have fun with that Magic Ink?",
		drawing.Speaker.Left, "Alicia"
end function

// Just for debugging:
playSteps.push function
	Alicia.setExpression alicia.eyebrows.normal, alicia.eyes.normal, alicia.mouth.normal
	drawing.drawSpeech "I see you made " + sim.nodes.len + " nodes, " + 
			sim.crossings.len + " crossings, and " + sim.gates.len + " gates.",
		drawing.Speaker.Left, "Alicia"	
end function

//----------------------------------------------------------------------
// If player hasn't made any crossings, educate them and send them back.
if not sim.crossings then
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
end if
//----------------------------------------------------------------------


if locals == globals then
	scene.play
end if
