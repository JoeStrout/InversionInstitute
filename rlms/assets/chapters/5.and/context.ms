number = 5
folderName = "5.and"
title = "Andi's Gate"

globals.circuitPic = gameData.loadCircuitForChapter(number)
if circuitPic == null then
	globals.circuitPic = file.loadImage("start.png")
end if
margin = Rect.make(14, 0, 51, circuitPic.height)

drawObjs = function
	objectives.erase
	objectives.print "Connect the two inputs (A and B) to the output (G) such that " +
	"G is on only when both A and B are on."
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