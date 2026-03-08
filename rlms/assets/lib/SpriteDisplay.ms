globals.Sprite = {}
Sprite.x = 0
Sprite.y = 320
Sprite.rotation = 0
Sprite.scale = 1
Sprite.srcTexture = null // must be defined
Sprite.srcRect = null    // optional: [left, top, width, height] in srcTexture
Sprite.tint = raylib.WHITE

Sprite.update = null	// define your own update method if needed

Sprite.draw = function(offsetX=0, offsetY=0)
	if self.image == null then return
	if self.srcRect then
		srcRect = self.srcRect
	else
		srcRect = [0, 0, self.image.width, self.image.height]
	end if
	destWidth = srcRect[2] * self.scale
	destHeight = srcRect[3] * self.scale
	destRect = [self.x + offsetX, self.y + offsetY, destWidth, destHeight]
	origin = [destWidth * 0.5, destHeight * 0.5]
	raylib.DrawTexturePro self.image.texture, srcRect, destRect,
		origin, self.rotation, self.tint
end function

SpriteDisplay = new Display
SpriteDisplay.scrollX = 0
SpriteDisplay.scrollY = 0
SpriteDisplay.sprites = null

SpriteDisplay.Make = function
	sp = new SpriteDisplay
	sp.clear
	return sp
end function

SpriteDisplay.clear = function
	self.sprites = []
	self.scrollX = 0
	self.scrollY = 0
end function

SpriteDisplay.render = function
	for sp in self.sprites
		sp.draw self.scrollX, self.scrollY
	end for
end function

return SpriteDisplay

