// Special cut scene for meeting Leo.

import "miscUtil"
ensureImport "scene"
ensureImport "gameData"
import "findErrors"
import "context"

ch = "ch" + context.number
if not gameData.data.hasIndex(ch) or not gameData.data[ch] then gameData.data[ch] = {}

display(0).mode = displayMode.off

scene.prepare context.number, "/usr/chapters/" + context.folderName
Leo.present = true
Alicia.present = false
Baab.present = false

playSteps.push function
	displays.vnBackground.drawImage backgrounds.gardenEvening
	Leo.setExpression leo.eyebrows.normal
	drawing.drawSpeech "Oh, " + gameData.playerName + " - I'm glad I caught you!",
		drawing.Speaker.Left, "Master Leo"
end function

playSteps.push function
	displays.vnBackground.drawImage backgrounds.gardenEvening
	Leo.setExpression leo.eyebrows.normal
	drawing.drawSpeech "I'm Leo.  I sponsored your membership here at the Institute. ",
		drawing.Speaker.Left, "Master Leo"
end function

playSteps.push function
	displays.vnBackground.drawImage backgrounds.gardenEvening
	Leo.setExpression leo.eyebrows.sad
	drawing.drawSpeech "I'm sorry I didn't get a chance to introduce myself right away.",
		drawing.Speaker.Left, "Master Leo"
end function

playSteps.push function
	displays.vnBackground.drawImage backgrounds.gardenEvening
	Leo.setExpression leo.eyebrows.normal
	drawing.drawSpeech "But it seems Alicia and Baab have helped you settle in nicely.",
		drawing.Speaker.Left, "Master Leo"
end function

playSteps.push function
	displays.vnBackground.drawImage backgrounds.gardenEvening
	Leo.setExpression leo.eyebrows.normal
	drawing.drawSpeech "There is a reason I selected you for this position.  You see, " +
	"I have foreseen that Magic Ink is far more important than anyone can imagine.",
		drawing.Speaker.Left, "Master Leo"
end function

playSteps.push function
	displays.vnBackground.drawImage backgrounds.gardenEvening
	Leo.setExpression leo.eyebrows.normal
	drawing.drawSpeech "And you, " + gameData.playerName + ", have a vital role " +
	"to play in the future that is unfolding even now.",
		drawing.Speaker.Left, "Master Leo"
end function

playSteps.push function
	displays.vnBackground.drawImage backgrounds.gardenEvening
	Leo.setExpression leo.eyebrows.sad
	drawing.drawSpeech "I'm afraid I don't have time to explain everything now.",
		drawing.Speaker.Left, "Master Leo"
end function

playSteps.push function
	displays.vnBackground.drawImage backgrounds.gardenEvening
	Leo.setExpression leo.eyebrows.normal
	drawing.drawSpeech "But I expect that Alicia will be coming to you with " +
	"some... odd requests.",
		drawing.Speaker.Left, "Master Leo"
end function

playSteps.push function
	displays.vnBackground.drawImage backgrounds.gardenEvening
	Leo.setExpression leo.eyebrows.mad
	drawing.drawSpeech "Please give her your best, no matter how pointless the "+
	"requests may seem.",
		drawing.Speaker.Left, "Master Leo"
end function

playSteps.push function
	displays.vnBackground.drawImage backgrounds.gardenEvening
	Leo.setExpression leo.eyebrows.normal
	drawing.drawSpeech "I promise that all will be clear in time.",
		drawing.Speaker.Left, "Master Leo"
end function

playSteps.push function
	displays.vnBackground.drawImage backgrounds.gardenEvening
	Leo.setExpression leo.eyebrows.normal
	drawing.drawSpeech "The world is counting on you, " + gameData.playerName +
	".  More than you know.",
		drawing.Speaker.Left, "Master Leo"
end function

playSteps.push function
	scene.playSunset
	gameData.data.curChapter = context.number + 1
	gameData.writeToDisk
	toc.startChapter
//	load "/usr/game/title"; run
end function


if locals == globals then
	scene.play
end if
