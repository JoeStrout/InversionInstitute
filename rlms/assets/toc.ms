// Table of Contents
//
// ...in other words, this module knows about all the chapters in the game,
// and has some utility functions for switching between them.

import "miscUtil"
ensureImport "soda"
ensureImport "gameData"
ensureImport "json"

chapters = []		// ordered list of chapters
chapterByNum = {}	// map from chapter number to chapter

chaptersFolder = function
	path = file.child(env.MS_EXE_DIR, "assets")
	path = file.child(path, "chapters")
	outer.chaptersFolder = path	// memoize!
	return path
end function

// load chapter metadata
reload = function
	env.MS_IMPORT_PATH = "$MS_SCRIPT_DIR:$MS_SCRIPT_DIR/lib:$MS_EXE_DIR/assets/lib:$MS_EXE_DIR/assets"
	outer.chapters = []
	outer.chapterByNum = {}
	for folderName in file.children(chaptersFolder)
		folderPath = file.child(chaptersFolder, folderName)
		contextPath = file.child(folderPath, "context.ms")
		f = file.open(contextPath, "r")
		if f == null or f isa string then continue
		data = {"number":null, "folderName":null, "title":null}
		while not f.atEnd
			parts = f.readLine.split(" = ")
			if parts.len != 2 then continue
			if parts[0] == "number" then data.number = val(parts[1])
			if parts[0] == "folderName" then data.folderName = json.parse(parts[1])
			if parts[0] == "title" then data.title = json.parse(parts[1])
			if data.number and data.folderName and data.title then
				data.done = gameData.get("ch" + data.number + ".done")
				chapters.push data
				chapterByNum[data.number] = data
				//print data
				break
			end if
		end while
		f.close	
	end for
	chapters.sort "number"
	for i in chapters.indexes
		ch = chapters[i]
		if ch == chapters[0] then
			ch.locked = false
		else
			ch.locked = not chapters[i-1].done
		end if
	end for
end function
reload

startChapter = function(chapterNum)
	if chapterNum == null then chapterNum = gameData.data.curChapter
	ch = chapterByNum[chapterNum]
	path = file.child(env.MS_EXE_DIR, "assets")
	path = file.child(path, "chapters")
	path = file.child(path, ch.folderName)
	print "toc.startChapter: path = " + path
	run file.child(path, "introScene.ms")
end function

returnToTitle = function
	text.color = color.clear
	cd "/usr/game"
	load "title"
	text.color = color.gray  // at least during debugging
	run
end function

if locals == globals then
	print json.indexes
	startChapter 4
end if