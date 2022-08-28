// This file defines the Baab character.
// He's a tinkerer who's good at interfacing magic ink with the real world.

import "miscUtil"
ensureImport "displays"
ensureImport "animatedCharacter"

globals.Baab = animatedCharacter.load("/usr/pics/Man2")
Baab.setScale 0.3, false
Baab.setXY 700,0

bodyParts = animatedCharacter.spriteSheets[0]
faceParts = animatedCharacter.spriteSheets[1]
animatedCharacter.spriteSheets = []

eyesSprite = Baab.find("eyesImg").sprite
eyebrowSprite = Baab.find("eyebrowImg").sprite
mouthSprite = Baab.find("mouthImg").sprite

//eyes = {}
//eyes.normal = faceParts.Eyes1.image
//eyes.closing = faceParts.Eyes2.image
//eyes.closed = faceParts.Eyes3.image
//eyes.giggle = faceParts.Eyes4.image
//
//eyebrows = {}
//eyebrows.normal = faceParts.Eyebrow1.image
//eyebrows.sad = faceParts.Eyebrow2.image
//eyebrows.mad = faceParts.Eyebrow3.image
//
//mouth = {}
//mouth.smile = faceParts.Mouth1.image
//mouth.normal = faceParts.Mouth2.image
//mouth.small = faceParts.Mouth3.image
//mouth.flat = faceParts.Mouth4.image
//mouth.frown = faceParts.Mouth5.image
//mouth.smallFrown = faceParts.Mouth6.image
//mouth.openSmile = faceParts.Mouth7.image
//mouth.joy = faceParts.Mouth8.image	// (BIG open smile)
//mouth.oh = faceParts.Mouth9.image	// (small round)
//mouth.openFrown = faceParts.Mouth10.image
//mouth.dismay = faceParts.Mouth11.image
//mouth.bigOh = faceParts.Mouth12.image	// (like WTF?)

//Baab.nonblinkingEyes = eyes.normal

Baab.setExpression = function(eyebrows, eyes, mouth)
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

Baab.setLeftArm = function(armMode)
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

Baab.animate = function
	super.animate
	outer.blinkIdx = blinkIdx - 1
	if blinkIdx < 0 then
		eyesSprite.image = self.nonblinkingEyes
		outer.blinkIdx = round(120 + 300*rnd)
	else if self.nonblinkingEyes == eyes.closed or self.nonblinkingEyes == eyes.giggle then
		// no blinking in this case; eyes are already closed
	else if blinkIdx == 3 or blinkIdx == 4 then
		eyesSprite.image = eyes.closing
	else if blinkIdx < 3 then
		eyesSprite.image = eyes.closed
	end if
end function


if locals == globals then
	displays.setupVN
	displays.vnBackground.drawImage file.loadImage("/usr/pics/Backgrounds/castle day.png")
	Baab.addSpritesToList displays.vnCharacters.sprites
	//Baab.setExpression eyebrows.sad, eyes.normal, mouth.dismay
	while not key.pressed("escape")
		Baab.animate
		yield
	end while
	key.clear
end if
