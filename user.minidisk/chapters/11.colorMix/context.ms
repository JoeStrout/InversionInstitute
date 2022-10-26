number = 11
folderName = "11.colorMix"
title = "Color Mixer"

globals.circuitPic = gameData.loadCircuitForChapter(number)
if circuitPic == null then
	globals.circuitPic = file.loadImage("start.png")
end if
margin = Rect.make(12, 0, 56, circuitPic.height)

drawObjs = function
	objectives.erase
	objectives.print "Connect the inputs (R, Y, and B) to the outputs (R through K) " +
	"such that, for any combination of input colors, the correct output color lights up."
	objectives.print
	objectives.print "These are pigments, so:"
	objectives.print "  R + Y = O"
	objectives.print "  Y + B = G"
	objectives.print "  R + B = V"
	objectives.print "  R + Y + B = K"
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