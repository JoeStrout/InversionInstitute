// General code and utilities related to cut scenes.

import "miscUtil"
ensureImport "displays"
ensureImport "alicia"
ensureImport "drawing"
ensureImport "backgrounds"
ensureImport "gameData"

prepare = function(chapterNum, chapterPath)
	displays.setupVN
	globals.curDrawing = null		// (something with .draw and .update functions)
	globals.playSteps = []
	globals.returnFunc = function
		gameData.saveCircuitForChapter(chapterNum, circuitPic)
		cd chapterPath
		load "returnScene"; run
	end function
end function

playOneStep = function(curStep)
	f = playSteps[curStep]
	f
	if curDrawing then curDrawing.draw
end function

play = function(startAtStep = 0)
	curStep = startAtStep

	displays.setupVN
	Alicia.addSpritesToList displays.vnCharacters.sprites	// Alicia enters on left

	while curStep < playSteps.len
		playOneStep curStep
		while true
			Alicia.animate
			if curDrawing then curDrawing.update
			if key.available then
				k = key.get.code
				if (k == 17 or k == 19) and curStep > 0 then
					curStep = curStep - 1
					break
				else if k == 18 or k == 20 or k == 32 or k == 10 or k == 13 then
					curStep = curStep + 1
					break
				end if
			end if
			yield
		end while	
	end while
end function

switchToEditor = function
	text.color = color.clear
	cd "/usr/game"
	load "editor"
	text.color = color.silver
	run
end function