// Table of Contents
//
// ...in other words, this module knows about all the chapters in the game,
// and has some utility functions for switching between them.

chapters = []		// ordered list of chapters
chapterByNum = {}	// map from chapter number to chapter

// load chapter metadata
for folder in file.children("/usr/chapters")
	f = file.open("/usr/chapters/" + folder + "/context.ms", "r")
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
			break
		end if
	end while
	f.close	
end for
chapters.sort "number"
recheckLocks = function
	for i in chapters.indexes
		ch = chapters[i]
		if ch == chapters[0] then
			ch.locked = false
		else
			ch.locked = not chapters[i-1].done
		end if
	end for
end function
recheckLocks

startChapter = function(chapterNum)
	if chapterNum == null then chapterNum = gameData.data.curChapter
	ch = chapterByNum[chapterNum]
	cd "/usr/chapters/" + ch.folderName
	text.color = color.clear
	load "introScene"
	text.color = color.gray  // at least during debugging
	run
end function

returnToTitle = function
	text.color = color.clear
	cd "/usr/game"
	load "title"
	text.color = color.gray  // at least during debugging
	run
end function
