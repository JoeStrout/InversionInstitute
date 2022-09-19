// This module is responsible for managing all the game state data:
// which missions have been completed, the circuits the player has
// made, etc.  It manages the disk files where all this data is stored.

import "miscUtil"
ensureImport "grfon"
ensureImport "qa"
ensureImport "mapUtil"

// Display name of the player, for use in dialogs etc.
// (We might use some sanitized version of this as the game
// folder name, too.)
playerName = "Player"
pronoun = {}
pronoun.they = "he"			// subjective
pronoun.them = "him"		// objective
pronoun.their = "his"		// possessive (adjective)
pronoun.theirs = "his"		// possessive (independent)

// Path to the folder containing all the saved games.
// ToDo: get /usr2 mapped to the user library folder,
// and save stuff there instead of in /usr.
savedGamesFolder = "/usr/userdata"
if not file.exists(savedGamesFolder) then file.makedir savedGamesFolder

// Path of the folder containing the current game data.
gameFolder = file.child(savedGamesFolder, "default")
if not file.exists(gameFolder) then file.makedir gameFolder

// Path of the folder containing your free-play circuits
freePlayFolder = file.child(gameFolder, "freeplay")
if not file.exists(freePlayFolder) then file.makedir freePlayFolder

// Data map: this is the main repository of persistent data.
// It gets stored in GRFON format, so should contain only
// simple types (including small maps) within it.
data = {}

// get: helper method to look up foo.bar.baz in the `data` map,
// returning null if any part of the path isn't found.
get = function(dotPath)
	m = data
	for part in dotPath.split(".")
		if not m.hasIndex(part) then return null
		m = m[part]
		if m == null then return null
	end for
	return m
end function

clearData = function
	outer.data = {}
	data.playerName = playerName
	data.curChapter = 1
	// ToDo: set any other defaults here
end function

readFromDisk = function
	clearData
	f = file.open(file.child(gameFolder, "data.grfon"), "r")
	if not f isa FileHandle then return	// (e.g., file does not exist)
	dataStr = f.read
	f.close
	if dataStr then
		outer.data = grfon.parse(dataStr)
	end if
	// copy a few items to module level for convenience
	if data.hasIndex("playerName") then outer.playerName = str(data.playerName)
	if data.hasIndex("pronoun") and data.pronoun isa map then
		outer.pronoun = outer.pronoun + data.pronoun
	end if
end function

writeToDisk = function
	// copy the stuff we keep at module level for convenience
	data.playerName = playerName
	data.pronoun = pronoun
	// then write the whole shebang to disk
	tempPath = file.child(gameFolder, "~data.grfon")
	finalPath = file.child(gameFolder, "data.grfon")
	f = file.open(tempPath, "w")
	qa.assert f isa FileHandle
	f.write grfon.toGRFON(data)
	f.close
	if file.exists(tempPath) then
		file.delete finalPath
		file.move tempPath, finalPath
	end if
end function

// File path for the user's circuit (image)
// for the given chapter.
circuitPathForChapter = function(chapterNum)
	return file.child(gameFolder, "circuit-" + chapterNum + ".png")
end function

loadCircuitForChapter = function(chapterNum)
	return file.loadImage(circuitPathForChapter(chapterNum))
end function

saveCircuitForChapter = function(chapterNum, circuitPic)
	file.saveImage circuitPathForChapter(chapterNum), circuitPic
end function

readFromDisk
