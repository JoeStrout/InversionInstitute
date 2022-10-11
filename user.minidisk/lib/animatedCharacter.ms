// Loads and manages an animated character, with a hierarchy defined in a GRFON file.

import "miscUtil"
ensureImport "stringUtil"
ensureImport "grfon"
ensureImport "spriteSheet"
ensureImport "mathUtil"
ensureImport "matrixUtil"
ensureImport "transform"
ensureImport "qa"

twoPi = pi * 2

spriteSheets = []

findSprite = function(name)
	name = name.trim
	for ss in spriteSheets
		if ss.hasIndex(name) then return ss[name]
	end for
	print "Unable to find sprite """ + name + """"
	return null
end function

CharPart = new Transform
CharPart.minRot = 0
CharPart.maxRot = 0
CharPart.animLength = 3
CharPart.animPhase = 0
CharPart.animate = function(updateNow = true)
	if self.minRot != self.maxRot then
		t = cos(((time % self.animLength) / self.animLength + self.animPhase) * twoPi) * 0.5 + 0.5
		self.setRotation mathUtil.lerp(self.minRot, self.maxRot, t), updateNow
	end if
	for c in self.children; c.animate(false); end for
	if updateNow then self.update
end function

CharPart.setAnimLength = function(newLength, recurse=true)
	self.animLength = newLength
	if recurse then
		for c in self.children
			c.setAnimLength newLength, true
		end for
	end if
end function

CharPart.allSprites = function
	sprites = []
	toDo = [self]
	while toDo
		cp = toDo.pull
		if cp.hasIndex("sprite") then sprites.push cp.sprite
		if cp.children then toDo = toDo + cp.children
	end while
	return sprites
end function

CharPart.addSpritesToList = function(spriteList)
	sprites = self.allSprites
	sprites.sort "z", false
	for s in sprites; spriteList.push s; end for
end function

CharPart.removeSpritesFromList = function(spriteList)
	for spr in self.allSprites
		idx = spriteList.indexOf(spr)
		if idx != null then spriteList.remove idx
	end for
end function

makeObjFromMap = function(m, z=0)
	noob = new CharPart
	noob.init
	for kv in m
		if kv.key == "x" then noob.local.x = val(kv.value) * 100
		if kv.key == "y" then noob.local.y = val(kv.value) * 100
		if kv.key == "z" then z = z + val(kv.value) * 100
		if kv.key == "minRot" then noob.minRot = val(kv.value)
		if kv.key == "maxRot" then noob.maxRot = val(kv.value)
		if kv.key == "animPhase" then noob.animPhase = val(kv.value)
		if kv.key == "sprite" then
			noob.sprite = findSprite(kv.value)
			qa.assert noob.sprite != null, "Sprite undefined: " + kv.value
			noob.sprite.z = z
		end if
		if kv.value isa map then
			child = makeObjFromMap(kv.value, z)
			child.name = kv.key
			child.setParent noob
		end if
	end for
	return noob
end function

load = function(dirPath)
	spriteSheets.push spriteSheet.load(dirPath + "/Body.png")
	spriteSheets.push spriteSheet.load(dirPath + "/Face.png")
	
	hierData = file.readLines(dirPath + "/Hierarchy.grfon").join(char(13))
	hierarchy = grfon.parse(hierData)
	obj = makeObjFromMap(hierarchy)
	obj.present = true
	//pprint obj
	return obj
end function

test = function
	display(6).mode = displayMode.sprite; display(6).clear
	character = load("/usr/pics/Girl5")
	character.setScale 0.3, false
	character.setXY 200,120
	character.debugDisplay
	display(6).sprites.sort "z", false
	
	globals.eyes = character.find("eyesImg")
	globals.eyeImages = [spriteSheets[1].Eyes1.image, spriteSheets[1].Eyes2.image, spriteSheets[1].Eyes3.image]
	blinkIdx = 0
	character.animate = function
		super.animate
		outer.blinkIdx = blinkIdx - 1
		if blinkIdx < 0 then
			eyes.sprite.image = eyeImages[0]
			outer.blinkIdx = round(120 + 300*rnd)
		else if blinkIdx >= 8 and blinkIdx < 12 then
			eyes.sprite.image = eyeImages[1]	// half-closed
		else if blinkIdx >= 4 and blinkIdx < 8 then
			eyes.sprite.image = eyeImages[2]	// closed
		else if blinkIdx < 4 then
			eyes.sprite.image = eyeImages[1]	// half-closed
		end if
	end function
	
	while not key.pressed("escape")
		character.animate
		yield
	end while
	key.clear
end function

if locals ==  globals then
	clear; gfx.clear color.clear
	test
end if
