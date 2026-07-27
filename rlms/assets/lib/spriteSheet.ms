// Utilities for loading a sprite sheet saved in Unity format.

import "qa"
import "stringUtil"

// load: main entry point.
// Path should be to the .png file (we'll find a .meta file next that).
// Returns a map of Sprite objects, with images already set.
load = function(path)
	result = {}
	srcImg = file.loadImage(path)
	qa.assert srcImg, "Couldn't read image at " + path
	meta = file.readLines(path + ".meta")
	qa.assert meta, "Couldn't read file at " + path+".meta"
	i = meta.indexOf("    sprites:")
	while i < meta.len - 1
		i = i + 1
		line = meta[i].trim
		parts = line.split(": ")
		if parts.len < 2 then continue
		if parts[0] == "name" then name = parts[1]
		if parts[0] == "x" then x = val(parts[1])
		if parts[0] == "y" then y = val(parts[1])
		if parts[0] == "width" then width = val(parts[1])
		if parts[0] == "height" then height = val(parts[1])
		if parts[0] == "alignment" then
			sp = new Sprite
			sp.image = srcImg    // shared -- same texture for every sprite from this sheet
			sp.srcRect = [x, srcImg.height - y - height, width, height]   // bottom-up -> top-down
			sp.name = name
			sp.addBounds
			result[name] = sp
		end if
	end while
	return result
end function

if locals == globals then
	ss = load("/usr/pics/Girl5/Body.png")
	for kv in ss
		r = kv.value.srcRect
		print kv.key + ": " + r[2] + " x " + r[3]
	end for
end if
