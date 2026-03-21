number = 12
folderName = "12.fullAdder"
title = "3-Bit Counter (Full Adder)"

globals.circuitPic = gameData.loadCircuitForChapter(number)
if circuitPic == null then
	globals.circuitPic = file.loadImage("start.png")
end if
margin = Rect.make(12, 0, 56, circuitPic.height)

drawObjs = function
	objectives.erase
	objectives.print "Connect the inputs (A, B, and C) to the outputs (1 and 2) " +
	"such that:"
	objectives.print
	objectives.print "• if no inputs are on, no output lights up"
	objectives.print "• if one input is on, 1 lights up"
	objectives.print "• if any two inputs are on, 2 lights up"
	objectives.print "• if all three inputs are on, 1 AND 2 light up"
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