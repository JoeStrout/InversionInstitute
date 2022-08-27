
import "qa"

_load = function(name)
	img = file.loadImage("/usr/pics/Backgrounds/" + name + ".png")
	qa.assert img
	return img
end function

_castle = null
castle = function
	if not _castle then outer._castle = _load("castle day")
	return _castle
end function

_arcade = null
arcade = function
	if not _arcade then outer._arcade = _load("arcade fancy day")
	return _arcade
end function

_lab = null
lab = function
	if not _lab then outer._lab = _load("lab")
	return _lab
end function

