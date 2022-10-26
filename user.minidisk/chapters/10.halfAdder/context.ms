number = 10
folderName = "10.halfAdder"
title = "2-Bit Counter"

globals.circuitPic = gameData.loadCircuitForChapter(number)
if circuitPic == null then
	globals.circuitPic = file.loadImage("start.png")
end if
margin = Rect.make(12, 0, 56, circuitPic.height)

drawObjs = function
	objectives.erase
	objectives.print "Connect the inputs (A and B) to the outputs (1 and 2) " +
	"such that:"
	objectives.print
	objectives.print "• if one input is on, 1 lights up"
	objectives.print "• if both inputs are on, 2 lights up"
	objectives.print "• if no inputs are on, no output lights up"
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