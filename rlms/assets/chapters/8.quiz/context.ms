number = 8
folderName = "8.quiz"
title = "Quiz Game"

globals.circuitPic = gameData.loadCircuitForChapter(number)
if circuitPic == null then
	globals.circuitPic = file.loadImage("start.png")
end if
margin = Rect.make(14, 0, 52, circuitPic.height)

drawObjs = function
	objectives.erase
	objectives.print "Contestants will press their input (A, B, or C) when they " +
	"know the answer.  Light the corresponding output for only the FIRST contestant " +
	"to do so.  Keep it lit, ignoring all other inputs, until RST (reset) is pressed."
	objectives.print
end function

objectivesDrawn = false
checkDrawn = false

update = function
	if not outer.objectivesDrawn or (outer.checkDrawn and not testMode) then
		drawObjs
		outer.objectivesDrawn = true
		outer.checkDrawn = false
	end if
end function

check = function
	err = findErrors.check	
	drawObjs
	objectives.print
	if not err then
		objectives.printSuccess "Success!"
	else
		objectives.printErr "Not quite! " + err
	end if
	outer.checkDrawn = true
	return not err
end function