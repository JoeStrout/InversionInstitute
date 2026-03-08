// Miscellaneous small helper functions that don't fit anywhere else.

env = {}  // ToDo: make this actually work in the host!
env.importPaths = [".", "/usr/game", "/usr/lib", "/sys/lib"]

import "importUtil"

// Get the maximum of two values
globals.max = function(a,b)
	if a > b then return a else return b
end function

// Get the minimum of two values
globals.min = function(a,b)
	if a < b then return a else return b
end function

// Get back the result of a die roll with a certain number of sides
rollDie = function(sides = 6)
	return ceil(rnd * sides)
end function

runUnitTests = function()
	ensureImport "qa"
	qa.assert max(2,5) == 5
	qa.assert max(5,2) == 5
	qa.assert min(2,5) == 2
	qa.assert min(5,2) == 2
end function

if locals == globals then runUnitTests

	