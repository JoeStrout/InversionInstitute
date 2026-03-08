## Mar 5 2026

I'm restarting this project after a several-year hiatus.  I'm going to rebuild it using raylib-miniscript, but try to keep the existing source as-is as much as possible.  So this entails developing classes to mimic the Mini Micro APIs -- which essentially "Soda" in the roadmap.  So I will be simultaneously refreshing Inversion Institute, stress-testing raylib-miniscript, and starting on the Soda rewrite, all at once.

Day one has gone quite well: I have raylib-miniscript building for Mac, and the dev/test cycle with it is extremely fast (I just change the code/assets, and do `./raylib-miniscript` in the rlms folder).  I have Soda classes for Display, SolidColorDisplay, PixelDisplay, and Image, as well as the color module.  These are all working so far.

The next piece we'll need is the `file` module, which isn't included in raylib-miniscript yet (because that came from MSRLWeb, which couldn't really use it).  So, getting that in will be the next goal.

...And, now that's done too.  A good stopping point for today.  Next time, I should take a hard look at editor.ms and see how much of that I can get working.  (I might need to first add a SpriteDisplay, but that should be pretty straightforward.)


## Mar 7 2026

Added SpriteDisplay.  It was pretty straightforward.

I ran into a little problem with PixelDisplay: Raylib by default does alpha blending on all drawing, whereas in Mini Micro, any drawing you do into a PixelDisplay (even with a translucent or fully clear color) completely replaces the previous pixel colors.  To fix that, I had to add a low-level API, rlSetBlendFactors, to raylib-miniscript.

The editor.ms script is now up and stumbling about.  There is some offset in the mouse position, and you can't change colors or tools, and various other shortcomings -- but you can draw and erase with the pencil, so that's progress.
