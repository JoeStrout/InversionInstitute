number = 13
folderName = "13.3bitDecoder"
title = "3-Bit Decoder"

globals.circuitPic = gameData.loadCircuitForChapter(number)
if circuitPic == null then
	globals.circuitPic = file.loadImage("start.png")
end if
margin = Rect.make(7, 9, circuitPic.width-7, circuitPic.height-9)

drawObjs = function
	objectives.erase
	objectives.print "Connect the inputs (1, 2, and 4) to the outputs (0-7) so that " +
	"the lit output indicates the sum of the inputs."
	objectives.print
	objectives.print "For example, if inputs 1 and 2 are lit, output 3 (only) should be lit."
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