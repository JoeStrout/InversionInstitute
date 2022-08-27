// Intro scene for Chapter 1, in which Alicia introduces herself
// and leads the player through some sham mini-games, before
// finally introducing the digital circuits.

import "miscUtil"
ensureImport "displays"
ensureImport "alicia"
ensureImport "drawing"
ensureImport "backgrounds"

demoTablet = file.loadImage("/usr/pics/ui/DemoTablet.png")

playSteps = []
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
	drawing.drawSpeech "In the meantime, here's something fun to play with: Magic Ink.",
		drawing.Speaker.Left, "Alicia"
end function
playSteps.push function
	displays.vnBackground.drawImage backgrounds.lab
	displays.vnBackground.drawImage demoTablet, 350, 200
	Alicia.setExpression alicia.eyebrows.normal, alicia.eyes.normal, alicia.mouth.normal
	Alicia.setLeftArm alicia.LeftArm.showing
	drawing.drawSpeech "You can draw lines and blobs with this ink, and then when you " +
		"touch it, it lights up!  Or if it's already lit, it goes dark.  Kids love it!",
		drawing.Speaker.Left, "Alicia"
end function



playOneStep = function(curStep)
	f = playSteps[curStep]
	f
end function

play = function(startAtStep = 0)
	curStep = startAtStep

	displays.setupVN
	Alicia.addSpritesToList displays.vnCharacters.sprites	// Alicia enters on left

	while curStep < playSteps.len
		playOneStep curStep
		while true
			Alicia.animate
			if key.available then
				k = key.get.code
				if (k == 17 or k == 19) and curStep > 0 then
					curStep = curStep - 1
					break
				else if k == 18 or k == 20 or k == 32 or k == 10 or k == 13 then
					curStep = curStep + 1
					break
				end if
			end if
			yield
		end while	
	end while
end function


if locals == globals then
	play 6
end if
