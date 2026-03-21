number = 9
folderName = "9.xor"
title = "Ex-Oarsley's Discord Alert"

globals.circuitPic = gameData.loadCircuitForChapter(number)
if circuitPic == null then
	globals.circuitPic = file.loadImage("start.png")
end if
margin = Rect.make(18, 0, 46, circuitPic.height)

drawObjs = function
	objectives.erase
	objectives.print "Connect the two inputs (F and C) to the alert (X) such that " +
	"the alert is on whenever the inputs differ (F is not equal to C)."
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