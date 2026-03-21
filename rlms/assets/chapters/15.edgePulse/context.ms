number = 15
folderName = "15.edgePulse"
title = "Edge Pulse Generator"

globals.circuitPic = gameData.loadCircuitForChapter(number)
if circuitPic == null then
	globals.circuitPic = file.loadImage("start.png")
end if
margin = Rect.make(21,0, 60-21,circuitPic.height)

drawObjs = function
	objectives.erase
	objectives.print "Connect the input (IN) to the output so that the output " +
	 "comes briefly on when IN goes from low to high."
	objectives.print
	objectives.print "The output should never stay on for more than the shortest " +
	 "possible pulse."
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