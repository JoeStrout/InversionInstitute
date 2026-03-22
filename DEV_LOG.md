## Mar 5 2026

I'm restarting this project after a several-year hiatus.  I'm going to rebuild it using raylib-miniscript, but try to keep the existing source as-is as much as possible.  So this entails developing classes to mimic the Mini Micro APIs -- which essentially "Soda" in the roadmap.  So I will be simultaneously refreshing Inversion Institute, stress-testing raylib-miniscript, and starting on the Soda rewrite, all at once.

Day one has gone quite well: I have raylib-miniscript building for Mac, and the dev/test cycle with it is extremely fast (I just change the code/assets, and do `./raylib-miniscript` in the rlms folder).  I have Soda classes for Display, SolidColorDisplay, PixelDisplay, and Image, as well as the color module.  These are all working so far.

The next piece we'll need is the `file` module, which isn't included in raylib-miniscript yet (because that came from MSRLWeb, which couldn't really use it).  So, getting that in will be the next goal.

...And, now that's done too.  A good stopping point for today.  Next time, I should take a hard look at editor.ms and see how much of that I can get working.  (I might need to first add a SpriteDisplay, but that should be pretty straightforward.)


## Mar 7 2026

Added SpriteDisplay.  It was pretty straightforward.

I ran into a little problem with PixelDisplay: Raylib by default does alpha blending on all drawing, whereas in Mini Micro, any drawing you do into a PixelDisplay (even with a translucent or fully clear color) completely replaces the previous pixel colors.  To fix that, I had to add a low-level API, rlSetBlendFactors, to raylib-miniscript.

The editor.ms script is now up and stumbling about.  There is some offset in the mouse position, and you can't change colors or tools, and various other shortcomings -- but you can draw and erase with the pencil, so that's progress.


## Mar 12 2026

Fixed the offset mouse position, and some tricky bits with line drawing (turns out you need to add 0.5 to X and Y to get lines to draw cleanly in Raylib).

Today I'm thinking about text.  I don't *need* text right now to get the editor working, but there are places where it would be nice -- captions on buttons, help dialog shown when you press ?, etc.  And I've decided that it's silly to use BMFFonts in this environment for cases where I could just use a TrueType font, i.e., anywhere I have a TTF as my source anyway, and I'm not making use of baked-in pixel colors.  That's the case pretty much throughout Inversion Institute.

So what I really need is a TTFont class that mimics the BMFFont API.  Then I should be able to use them pretty much interchangeably.

Man, getting fonts to render right side up in my PixelDisplay texture was a real bear.  I did finally manage it, by (1) transforming the view matrix, (2) disabling backface culling, and (3) flushing the render queue immediately, but what a pain.  So I decided to flip the way the PixelDisplay texture is stored.  It was always a compromise: some operations needed to flip Y, and others did not.  But the new arrangement is a better compromise: drawing operations (lines, rectangles, etc.) need to flip Y, but direct-access operations (pixel, getTexture, and especially font drawing) do not.

Lots of good progress today!  The editor is basically complete, and I've also got the drawing and objectives modules working.  The next step is to get those mode buttons (especially EDIT/TEST) to appear.  Then I will be able to hook up the simulation, and see how it performs.


## Mar 19 2026

I got those buttons working (it seems like our current Soda support for Sprite does not include non-uniformly scaled sprites, plus I needed to print via the new ttFonts class).  And with very little extra effort, got the pixelLogicSim working too.

So now we have the complete edit-test pipeline going!  Woohoo!

I posted an update (the first in years) to the Steam commuinty and itch.io:

https://store.steampowered.com/news/app/2145480/view/520867483423343055

https://joestrout.itch.io/inversion-institute/devlog/1463585/rumors-of-our-demise-have-been-greatly-exaggerated

I also updated the puzzle guide at https://steamcommunity.com/sharedfiles/filedetails/?id=2880784525 a bit; I'll need to do more at some point.


## Mar 20 2026

Going to get our animated characters up and idling today.  ...There were two tricky bits here.  First, there was code in animatedCharacter.ms that was relying on the order of keys in a map, which worked in MS1 C#, but not in MS1 C++.  Would have worked fine with MS2, but it was easy enough to change the code so that order does not matter.

Second, our Sprites were rotating the wrong way due to the inverted Y axis in raylib.  That's fixed now too.  Both Alicia and Baab are on the job!


## Mar 21 2026

I've just about got all the pieces in place to start connecting it all together.  However, the Mini Micro version used a lot of `cd` and `load`/`run` to get from section to section of the game.  Raylib-miniscript doesn't support this yet.

And actually, currently import can't quite substitute in this case either, because we only search assets and assets/lib for files to import.  There is no equivalent of `env.importPaths` or `env.MS_IMPORT_PATH` in Raylib-MiniScript yet.

One possible way out: have rlms search the current script directory, the script directory's `lib` folder, and finally assets/lib (these three are analogous to what command-line MiniScript does by default -- maybe even call them the same thing?).  Then add a `run` command which takes a file path, and updates MS_SCRIPT_DIR, so that subsequent imports automatically go relative to that.  And of course `run` would also load and run the current program.

Implemented that, and it seems to be working.

Fixed a bug in Image.getImage (it was not properly applying defaults), which was causing margin protection to not work.  So, margin protection is working now!

You can run toc.ms, which takes you straight to chapter 4; run through the intro scene, and then get all the way to the editor, which functions properly.  Real progress.  Another day or so of this, and we could have the full game loop functional.  Then it's only things like the title and options screen remaining.  (And background music/sfx -- still need to make a Soda class for Sound.)



