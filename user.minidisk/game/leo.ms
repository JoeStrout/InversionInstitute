// This file defines the Leo character.

import "miscUtil"
ensureImport "displays"
ensureImport "animatedCharacter"

globals.Leo = animatedCharacter.load("/usr/pics/Man3")
Leo.setScale 0.32, false
Leo.setXY 200,0
Leo.setAnimLength 4.5

bodyParts = animatedCharacter.spriteSheets[0]
faceParts = animatedCharacter.spriteSheets[1]
animatedCharacter.spriteSheets = []

eyesSprite = Leo.find("eyesImg").sprite
eyebrowSprite = Leo.find("eyebrowImg").sprite

eyes = {}
eyes.normal = faceParts.Eyes1.image
eyes.closing = faceParts.Eyes2.image
eyes.closed = faceParts.Eyes3.image

eyebrows = {}
eyebrows.normal = faceParts.Eyebrow1.image
eyebrows.mad = faceParts.Eyebrow2.image
eyebrows.sad = faceParts.Eyebrow3.image

Leo.nonblinkingEyes = eyes.normal

Leo.setExpression = function(eyebrows, eyes)
	if eyes == null then eyes = outer.eyes.normal
	eyebrowSprite.image = eyebrows
	eyesSprite.image = eyes
	self.nonblinkingEyes = eyes
end function

RightArm = {}
RightArm.normal = 0
LeftArm = {}
LeftArm.normal = 0
LeftArm.showing = 1		// turned outward, as if showing something

Leo.setLeftArm = function(armMode)
	arm = self.find("leftArm")
	armImg = arm.find("leftArmImg")
	if armMode == LeftArm.showing then
		armImg.flip = true
		arm.setXY 350, -310, false
		arm.minRot = 40; arm.maxRot = 41
	else
		armImg.flip = false
		arm.setXY 169, -453, false
		arm.minRot = -5.691; arm.maxRot = 0	
	end if
end function

blinkIdx = 0

Leo.animate = function
	super.animate
	outer.blinkIdx = blinkIdx - 1
	if blinkIdx < 0 then
		eyesSprite.image = self.nonblinkingEyes
		outer.blinkIdx = round(120 + 300*rnd)
	else if self.nonblinkingEyes == eyes.closed then
		// no blinking in this case; eyes are already closed
	else if blinkIdx >= 8 and blinkIdx < 12 then
		eyesSprite.image = eyes.closing
	else if blinkIdx >= 4 and blinkIdx < 8 then
		eyesSprite.image = eyes.closed
	else if blinkIdx < 4 then
		eyesSprite.image = eyes.closing
	end if
end function


if locals == globals then
	displays.setupVN
	displays.vnBackground.drawImage file.loadImage("/usr/pics/Backgrounds/castle day.png")
	Leo.addSpritesToList displays.vnCharacters.sprites
	//Leo.setExpression eyebrows.sad, eyes.normal, mouth.dismay
	while not key.pressed("escape")
		Leo.animate
		yield
	end while
	key.clear
end if
