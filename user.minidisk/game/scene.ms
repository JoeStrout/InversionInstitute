// General code and utilities related to cut scenes.

import "miscUtil"
ensureImport "displays"
ensureImport "alicia"
ensureImport "baab"
ensureImport "leo"
ensureImport "drawing"
ensureImport "backgrounds"
ensureImport "gameData"
ensureImport "music"

characters = [Alicia, Baab, Leo]
for c in characters; c.present = false; end for

prepare = function(chapterNum, chapterPath)
	displays.setupVN
	Baab.present = false
	Leo.present = false
	globals.curDrawing = null		// (something with .draw and .update functions)
	globals.playSteps = []
	globals.returnFunc = function
		gameData.saveCircuitForChapter(chapterNum, circuitPic)
		cd chapterPath
		load "returnScene"; run
	end function
	music.playNovel
end function

playOneStep = function(curStep)
	f = playSteps[curStep]
	f
	for character in characters
		if character.present and not character.onStage then
			character.addSpritesToList displays.vnCharacters.sprites
			character.onStage = true
		else if character.onStage and not character.present then
			character.removeSpritesFromList displays.vnCharacters.sprites
			character.onStage = false
		end if
	end for
	if curDrawing then curDrawing.draw
end function

play = function(startAtStep = 0)
	curStep = startAtStep

	displays.setupVN
	for character in characters
		if character.present then
			character.addSpritesToList displays.vnCharacters.sprites
			character.onStage = true
		else
			character.onStage = false
		end if
	end for
	
	while curStep < playSteps.len
		playOneStep curStep
		while true
			for character in characters
				character.animate
			end for
			if curDrawing then curDrawing.update
			if key.available then
				k = key.get.code
				if (k == 17 or k == 19) and curStep > 0 then
					curStep = curStep - 1
					break
				else if k == 18 or k == 20 or k == 32 or k == 10 or k == 13 then
					curStep = curStep + 1
					break
				else if k == 27 then
					load "/usr/game/title"
					run
				end if
			end if
			if mouse.button then
				while mouse.button; yield; end while
				curStep = curStep + 1
				break
			end if
			music.update
			yield
		end while	
	end while
end function

switchToEditor = function
	music.playEditor
	text.color = color.clear
	cd "/usr/game"
	load "editor"
	text.color = color.silver
	run
end function

playSunRiseOrSet = function(startAlpha, endAlpha)
	display(1).mode = displayMode.sprite
	sprDisp = display(1)
	sprDisp.clear
	
	night = new Sprite
	night.image = backgrounds.castleNight
	night.x = 480; night.y = 320
	sprDisp.sprites.push night

	eve = new Sprite
	eve.image = backgrounds.castleEvening
	eve.x = 480; eve.y = 320
	eve.tint = color.rgba(255,255,255, startAlpha)
	sprDisp.sprites.push eve

	wait 1
	for alpha in range(startAlpha, endAlpha)
		eve.tint = color.rgba(255,255,255, alpha)
		if key.available and key.get.code == 27 then toc.returnToTitle
		music.update
		yield
	end for
	wait 1
end function

playSunset = function
	playSunRiseOrSet 255, 0
end function	

playSunrise = function
	playSunRiseOrSet 0, 255
end function	

