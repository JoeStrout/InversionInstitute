// Return scene for Chapter 1.

import "miscUtil"
ensureImport "scene"

if not sim.nodes then
	sim.setup true
	sim.analyze
end if

scene.prepare 1, "/usr/chapters/1.intro"

playSteps.push function
	Alicia.setExpression alicia.eyebrows.normal, alicia.eyes.giggle, alicia.mouth.smile
	displays.vnBackground.drawImage backgrounds.castle
	drawing.drawSpeech "Did you have fun with that Magic Ink?",
		drawing.Speaker.Left, "Alicia"
end function

// Just for debugging:
playSteps.push function
	Alicia.setExpression alicia.eyebrows.normal, alicia.eyes.normal, alicia.mouth.normal
	displays.vnBackground.drawImage backgrounds.castle
	drawing.drawSpeech "I see you made " + sim.nodes.len + " nodes, " + 
			sim.crossings.len + " crossings, and " + sim.gates.len + " gates.",
		drawing.Speaker.Left, "Alicia"	
end function

if locals == globals then
	scene.play
end if
