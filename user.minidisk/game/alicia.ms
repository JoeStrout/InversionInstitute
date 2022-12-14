// This file defines the Alicia character.
// She's the main mathematician (and becomes the first computer scientist)
// at the Inversion Institute, and the player's main interface.

import "miscUtil"
ensureImport "displays"
ensureImport "animatedCharacter"

globals.Alicia = animatedCharacter.load("/usr/pics/Girl5")
Alicia.setScale 0.3, false
Alicia.setXY 200,100

bodyParts = animatedCharacter.spriteSheets[0]
faceParts = animatedCharacter.spriteSheets[1]
animatedCharacter.spriteSheets = []

eyesSprite = Alicia.find("eyesImg").sprite
eyebrowSprite = Alicia.find("eyebrowImg").sprite
mouthSprite = Alicia.find("mouthImg").sprite

eyes = {}
eyes.normal = faceParts.Eyes1.image
eyes.closing = faceParts.Eyes2.image
eyes.closed = faceParts.Eyes3.image
eyes.giggle = faceParts.Eyes4.image

eyebrows = {}
eyebrows.normal = faceParts.Eyebrow1.image
eyebrows.sad = faceParts.Eyebrow2.image
eyebrows.mad = faceParts.Eyebrow3.image

mouth = {}
mouth.smile = faceParts.Mouth1.image
mouth.normal = faceParts.Mouth2.image
mouth.small = faceParts.Mouth3.image
mouth.flat = faceParts.Mouth4.image
mouth.frown = faceParts.Mouth5.image
mouth.smallFrown = faceParts.Mouth6.image
mouth.openSmile = faceParts.Mouth7.image
mouth.joy = faceParts.Mouth8.image	// (BIG open smile)
mouth.oh = faceParts.Mouth9.image	// (small round)
mouth.openFrown = faceParts.Mouth10.image
mouth.dismay = faceParts.Mouth11.image
mouth.bigOh = faceParts.Mouth12.image	// (like WTF?)

Alicia.nonblinkingEyes = eyes.normal

Alicia.setExpression = function(eyebrows, eyes, mouth)
	eyebrowSprite.image = eyebrows
	eyesSprite.image = eyes
	mouthSprite.image = mouth
	self.nonblinkingEyes = eyes
end function

RightArm = {}
RightArm.normal = 0
LeftArm = {}
LeftArm.normal = 0
LeftArm.showing = 1		// turned outward, as if showing something

Alicia.setLeftArm = function(armMode)
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

Alicia.animate = function
	super.animate
	outer.blinkIdx = blinkIdx - 1
	if blinkIdx < 0 then
		eyesSprite.image = self.nonblinkingEyes
		outer.blinkIdx = round(120 + 300*rnd)
	else if self.nonblinkingEyes == eyes.closed or self.nonblinkingEyes == eyes.giggle then
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
	Alicia.addSpritesToList displays.vnCharacters.sprites
	//Alicia.setExpression eyebrows.sad, eyes.normal, mouth.dismay
	while not key.pressed("escape")
		Alicia.animate
		yield
	end while
	key.clear
end if
