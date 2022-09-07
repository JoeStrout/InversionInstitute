globals.circuitPic = gameData.loadCircuitForChapter(3)
if circuitPic == null then
	globals.circuitPic = file.loadImage("start.png")
end if

title = "Ch. 3: Mrs. Oarley's Children"

drawObjs = function
	objectives.erase
	objectives.print "Connect the two inputs (F and C) to the light (L) such that " +
	"the light is on whenever either input is on."
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