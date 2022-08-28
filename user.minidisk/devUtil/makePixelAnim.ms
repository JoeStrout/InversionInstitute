// Little utility to let you trace over a pixel image and record
// the coordinates (and their colors) in a text file, so we can
// play them back in cut scenes as a demo of drawing.

clear
oldpath = ""
if globals.hasIndex("inpath") then oldpath = inpath
inpath = input("Image path [" + oldpath + "]: ")
if not inpath then inpath = oldpath
img = file.loadImage(inpath)

gfx.scale = 10
gfx.drawImage img, 0, 0

data = []

while true
	yield
	if key.available and key.get.code == 27 then break
	if not mouse.button then continue
	while mouse.button
		x = floor(mouse.x / gfx.scale); y = floor(mouse.y / gfx.scale)
		c = gfx.pixel(x,y)
		if c[-2:] != "FF" then continue
		data.push [x, y, c]
		c = c[:-2] + "44"
		gfx.setPixel x, y, c
		yield
	end while
end while

oldpath = ""
if globals.hasIndex("outpath") then oldpath = outpath
outpath = input("Output path [" + oldpath + "]: ")
if not outpath then outpath = oldpath
file.writeLines outpath, data
print "Wrote " + data.len + " lines to " + outpath
