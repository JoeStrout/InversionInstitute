number = 2
folderName = "2.diode"
title = "Recess is Over"

globals.circuitPic = gameData.loadCircuitForChapter(number)
if circuitPic == null then
	globals.circuitPic = file.loadImage("start.png")
end if

drawObjs = function
	objectives.erase
	objectives.print "Connect the control pad (A) to the sign (B) in such a way " +
	"that the sign can ONLY be controlled from A; tapping the sign should not work."
	objectives.print
	objectives.print "B should be on whenever A is on, and B should be off when A is off."
	objectives.print
	objectives.print "A on  → B on"
	objectives.print "A off → B off"
	objectives.print
	objectives.print "(Remember to TEST your design, and press EXIT when done.)"	
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