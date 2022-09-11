// This module manages background music.

import "miscUtil"
ensureImport "qa"
ensureImport "mathUtil"

fullVolume = 1

curPlaying = null
fadingOut = null
fadeVolume = 0

sounds = {}
sounds.title = null
sounds.novel = null
sounds.editor = null

stop = function
	if curPlaying then curPlaying.stop
	outer.curPlaying = null
	if fadingOut then fadingOut.stop
	outer.fadingOut = null
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

playSong = function(sound)
	fadeOut
	outer.curPlaying = sound
	curPlaying.play fullVolume
end function

playTitle = function
	if not sounds.title then
		sounds.title = file.loadSound("/usr/music/oh-joyous-day.ogg")
		sounds.title.loop = true
		qa.assert sounds.title
	end if
	playSong sounds.title
end function

playNovel = function
	if not sounds.novel then
		sounds.novel = file.loadSound("/usr/music/the-forest.ogg")
		sounds.novel.loop = true
		qa.assert sounds.novel
	end if
	playSong sounds.novel
end function

playEditor = function
	if not sounds.editor then
		sounds.editor = file.loadSound("/usr/music/sky-meditation.ogg")
		sounds.editor.loop = true
		qa.assert sounds.editor
	end if
	playSong sounds.editor
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