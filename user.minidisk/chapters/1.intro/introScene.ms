// Intro scene for Chapter 1, in which Alicia introduces herself
// and leads the player through some sham mini-games, before
// finally introducing the digital circuits.

import "miscUtil"
ensureImport "scene"

scene.prepare 1, "/usr/chapters/1.intro"

demoTablet = file.loadImage("/usr/pics/ui/DemoTablet.png")
lineToHeartPix = new drawing.PixelDrawing
display(6).mode = displayMode.pixel
display(6).clear color.clear
lineToHeartPix.load "lineToHeart.txt", display(6), 340, 100, 8
lineToHeartPix.draw = function
	step = self.curStep % 200
	if step == 0 then
		self.drawAll color.black
	else if step == 100 then
		self.drawAll
	end if
end function
lineToHeartPix.update = function
	super.update
	if self.curStep < 200 then return
	self.draw
end function

playSteps.push function
	Alicia.setExpression alicia.eyebrows.normal, alicia.eyes.normal, alicia.mouth.normal
	displays.vnBackground.drawImage backgrounds.castle
	drawing.drawSpeech "Welcome to Inversion Institute!  I'm Alicia, one of the " +
		"mathemagicians here.  Master Leo asked me to help you get settled in. " +
		"He seemed quite excited about your arrival!",
		drawing.Speaker.Left, "Alicia"
end function
playSteps.push function
	displays.vnBackground.drawImage backgrounds.castle
	Alicia.setExpression alicia.eyebrows.normal, alicia.eyes.normal, alicia.mouth.smallFrown
	drawing.drawSpeech "Though come to think of it, he didn't actually say why.",
		drawing.Speaker.Left, "Alicia"
end function
playSteps.push function
	displays.vnBackground.drawImage backgrounds.castle
	Alicia.setExpression alicia.eyebrows.normal, alicia.eyes.giggle, alicia.mouth.smile
	drawing.drawSpeech "But I'm sure we'll find out soon!  ...Please come in.",
		drawing.Speaker.Left, "Alicia"
end function
playSteps.push function
	displays.vnBackground.drawImage backgrounds.arcade
	Alicia.setExpression alicia.eyebrows.normal, alicia.eyes.normal, alicia.mouth.normal
	drawing.drawSpeech "We study many kinds of magic here at the Institute.  Let's " +
		"go to my lab, and we'll see what suits you.",
		drawing.Speaker.Left, "Alicia"
end function
playSteps.push function
	displays.vnBackground.drawImage backgrounds.lab
	Alicia.setExpression alicia.eyebrows.normal, alicia.eyes.normal, alicia.mouth.smile
	drawing.drawSpeech "Here you will be playing several sham mini-games, that each " +
		"end in an explosion!",
		drawing.Speaker.Left, "Alicia"
end function
playSteps.push function
	displays.vnBackground.drawImage backgrounds.lab
	Alicia.setExpression alicia.eyebrows.sad, alicia.eyes.normal, alicia.mouth.frown
	drawing.drawSpeech "But those haven't actually been coded up yet.",
		drawing.Speaker.Left, "Alicia"
end function
playSteps.push function
	displays.vnBackground.drawImage backgrounds.lab
	Alicia.setExpression alicia.eyebrows.normal, alicia.eyes.normal, alicia.mouth.normal
	Alicia.setLeftArm alicia.LeftArm.normal
	display(6).clear color.clear
	drawing.drawSpeech "In the meantime, here's something fun to play with: Magic Ink.",
		drawing.Speaker.Left, "Alicia"
end function
playSteps.push function
	displays.vnBackground.drawImage backgrounds.lab
	displays.vnBackground.drawImage demoTablet, 350, 200
	display(6).clear color.clear
	outer.curDrawing = lineToHeartPix
	Alicia.setExpression alicia.eyebrows.normal, alicia.eyes.normal, alicia.mouth.normal
	Alicia.setLeftArm alicia.LeftArm.showing
	drawing.drawSpeech "You can draw lines and blobs with this ink, and then when you " +
		"touch it, it lights up!  Or if it's already lit, it goes dark.  Kids love it!",
		drawing.Speaker.Left, "Alicia"
end function
playSteps.push function
	displays.vnBackground.drawImage backgrounds.lab
	displays.vnBackground.drawImage demoTablet, 350, 200
	outer.curDrawing = null
	lineToHeartPix.drawAll
	Alicia.setExpression alicia.eyebrows.normal, alicia.eyes.normal, alicia.mouth.smile
	Alicia.setLeftArm alicia.LeftArm.normal
	drawing.drawSpeech "Here, why don't you play with this for a while. " +
		"I need to go see Master Leo.",
		drawing.Speaker.Left, "Alicia"
end function
playSteps.push function
	globals.circuitPic = gameData.loadCircuitForChapter(1)
	if circuitPic == null then
		globals.circuitPic = Image.create(80, 64, color.black)
	end if
	scene.switchToEditor
end function

if locals == globals then
	scene.play
end if
