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
pronoun.he = "he"		// subjective
pronoun.him = "him"		// objective
pronoun.his = "his"		// possessive

// Path to the folder containing all the saved games.
// ToDo: get /usr2 mapped to the user library folder,
// and save stuff there instead of in /usr.
savedGamesFolder = "/usr/userdata"
if not file.exists(savedGamesFolder) then file.makedir(savedGamesFolder)

// Path of the folder containing the current game data.
gameFolder = file.child(savedGamesFolder, "user123")
if not file.exists(gameFolder) then file.makedir(gameFolder)

// Data map: this is the main repository of persistent data.
// It gets stored in GRFON format, so should contain only
// simple types (including small maps) within it.
data = {}

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
end function

writeToDisk = function
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
