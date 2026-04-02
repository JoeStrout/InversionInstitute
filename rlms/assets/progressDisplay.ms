import "miscUtil"
ensureImport "soda"
ensureImport "mathUtil"
ensureImport "listUtil"

bgImage = file.loadImage("pics/ui/ProgressBackground.png")
fillImage = file.loadImage("pics/ui/ProgressBlue.png")
shineImage = file.loadImage("pics/ui/ProgressShine.png")

hourglass = file.loadImage("pics/ui/Hourglass.png")

tempG = null

fillForPercent = function(percent)
	if tempG == null then tempG = new PixelDisplay
	tempG.clear color.clear, fillImage.width, fillImage.height
	tempG.drawImage fillImage, 0, 0
	y = mathUtil.lerp(15, 148, percent/100)
	tempG.fillRect 0, y, fillImage.width, fillImage.height-y, color.clear
	return tempG.getImage
end function

setup = function(disp)
	outer.display = disp
	
	Base = new Sprite
	Base.x = 480
	Base.y = 320
	Base.scale = 0.5

	// HACK for now, just show the empty hourglass
	outer.bgSprite = new Base
	bgSprite.image = hourglass // bgImage
	disp.sprites.push bgSprite
//	
//	outer.fillSprite = new Base
//	fillSprite.image = fillForPercent(0)
//	disp.sprites.push fillSprite
//	
//	outer.shineSprite = new Base
//	shineSprite.image = shineImage
//	disp.sprites.push shineSprite
end function

setPercent = function(percent)
	print "Progress: " + round(percent) + "%"
	// HACKED out:
	//fillSprite.image = fillForPercent(percent)
end function

close = function
	display.sprites.removeVal bgSprite
	//display.sprites.removeVal fillSprite
	//display.sprites.removeVal shineSprite
end function

if locals == globals then
	clear
	setup display(4)
	pct = 0
	while not key.available
		yield
		pct = (pct + 10) % 105
		setPercent pct
		//text.row = 25; print pct + "   "
		wait 0.5
	end while
	key.clear
	close
end if

