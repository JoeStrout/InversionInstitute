// Utilities for loading a sprite sheet saved in Unity format.

import "qa"
import "stringUtil"

// load: main entry point.
// Path should be to the .png file (we'll find a .meta file next that).
// Returns a map of Sprite objects, with images already set.
load = function(path)
	result = {}
	srcImg = file.loadImage(path)
	qa.assert srcImg
	meta = file.readLines(path + ".meta")
	qa.assert meta
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
			sp.image = srcImg.getImage(x, y, width, height)
			sp.name = name
			result[name] = sp
		end if
	end while
	return result
end function

if locals == globals then
	ss = load("/usr/pics/Girl5/Body.png")
	for kv in ss
		print kv.key + ": " + kv.value.image.width + " x " + kv.value.image.height
	end for
	view ss.HeadImg.image
end if
