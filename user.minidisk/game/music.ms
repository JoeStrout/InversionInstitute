// This module manages background music.

import "miscUtil"
ensureImport "qa"
ensureImport "mathUtil"

fullVolume = 0.5

curPlaying = null
fadingOut = null
fadeVolume = 0

sounds = {}
paths = {}
sounds.title = null
paths.title = "/usr/music/oh-joyous-day.ogg"
sounds.novel = null
paths.novel = "/usr/music/the-forest.ogg"
sounds.editor = null
paths.editor = "/usr/music/sky-meditation.ogg"

preloadAll = function
	for name in paths.indexes
		if not sounds[name] then
			sounds[name] = file.loadSound(paths[name])
			sounds[name].loop = true
		end if
	end for
end function

stop = function
	outer.songToResume = curPlaying
	if curPlaying then curPlaying.stop
	outer.curPlaying = null
	if fadingOut then fadingOut.stop
	outer.fadingOut = null
end function

isOn = function
	return fullVolume > 0
end function

setOn = function(nowOn)
	fullVolume = nowOn * 0.5
	if not nowOn then
		if curPlaying then curPlaying.adjust 0
		if fadingOut then fadingOut.stop
	else if curPlaying then
		if curPlaying.isPlaying then
			curPlaying.adjust fullVolume
		else
			curPlaying.play fullVolume
		end if
	end if
end function

fadeOut = function
	if fadingOut then fadingOut.stop
	outer.fadingOut = null
	if curPlaying then
		outer.fadingOut = curPlaying
		outer.fadeVolume = fullVolume
		outer.curPlaying = null
	end if
end function

playSong = function(soundOrName)
	if soundOrName isa string then
		if not sounds[soundOrName] then
			sounds[soundOrName] = file.loadSound(paths[soundOrName])
			qa.assert sounds[soundOrName]
			sounds[soundOrName].loop = true
		end if
		soundOrName = sounds[soundOrName]
	end if
	if soundOrName == outer.curPlaying then
		// we're already playing this one.  Just keep it up.
		return
	end if
	fadeOut
	outer.curPlaying = soundOrName
	if isOn then curPlaying.play fullVolume
end function


playTitle = function
	playSong "title"
end function

playNovel = function
	playSong "novel"
end function

playEditor = function
	playSong "editor"
end function

update = function(dt=0.016)
	if fadingOut then
		outer.fadeVolume = mathUtil.moveTowards(fadeVolume, 0, dt)
		if fadeVolume <= 0 then
			fadingOut.stop
			outer.fadingOut = null
		else
			fadingOut.adjust fadeVolume
		end if
	end if
end function

if locals == globals then
	print "Inversion Institute Jukebox"
	print
	print "1 - Title"
	print "2 - Novel"
	print "3 - Editor"
	print "Q - quit"
	while true
		update
		yield
		if key.available then
			k = key.get.lower
			if k == "1" then playTitle
			if k == "2" then playNovel
			if k == "3" then playEditor
			if k == "q" then
				stop
				break
			end if
		end if
	end while
end if