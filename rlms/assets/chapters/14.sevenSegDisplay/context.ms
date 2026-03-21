number = 14
folderName = "14.sevenSegDisplay"
title = "7-Segment Display"

globals.circuitPic = gameData.loadCircuitForChapter(number)
if circuitPic == null then
	globals.circuitPic = file.loadImage("start.png")
end if
margin = Rect.make(7, 0, 50, circuitPic.height)

drawObjs = function
	objectives.erase
	objectives.print "Connect the inputs (1, 2, and 4) to the outputs so that the output " +
	"pins show the sum of the inputs."
	objectives.print
	objectives.print "For example, if inputs 1 and 2 are lit, the output should show 3."
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