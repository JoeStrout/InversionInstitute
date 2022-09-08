// Main title screen for the game.

import "miscUtil"
ensureImport "backgrounds"
ensureImport "displays"
ensureImport "mathUtil"

displays.setupTitle
sprites = displays.tiSprite.sprites

night = new Sprite
night.image = backgrounds.castleNight
night.x = 480; night.y = 320
sprites.push night

//eve = new Sprite
//eve.image = backgrounds.castleEvening
//eve.x = 480; eve.y = 320
//sprites.push eve

title = new Sprite
title.image = file.loadImage("/usr/pics/ui/title.png")
title.x = 480; title.y = 640 - title.image.height/2
title.tint = color.clear
sprites.push title

for t in range(0, 1, 0.02)
	title.scale = mathUtil.lerp(1.5, 0.4, t)
	title.tint = color.lerp(color.clear, color.white, t)
	title.y = mathUtil.lerp(640, 560, t)
	yield
end for
for t in range(0, 1, 0.15)
	title.scale = mathUtil.lerp(0.4, 0.5, t)
	yield
end for

