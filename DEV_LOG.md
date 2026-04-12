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


## Mar 26 2026

Making rapid progress now:

- Added the FileHandle class to raylib-miniscript, which was missing (it's also massing from command-line MiniScript, filed as #198; we'll fix that in MiniScript 2.0).
- Changed all the `d.mode = foo` display mode changes to `d.setMode foo`.  Unfortunately I can't think of a good way to make the old code compatible here, as we don't have any way to intercept an assignment within MiniScript itself.
- Fixed the way the chapter folder is found in the various introScene and returnScene chapter files.

So now, starting with chapter 4 or 5 via toc.ms, you can play the puzzles and advance from chapter to chapter.  Even the sun set/rise (e.g. between chapters 4 and 5) works as intended and looks beautiful.

I did notice one bug: on one of the puzzles (I think it was 6 or so), I went in with it already solved, and immediately exited — which should have worked; but I didn't see it run the check, and Alice said that I hadn't solved it, and sent me back to the editor.  There I just clicked Check and Test, and then exited, and Alice agreed it was solved.  But that shouldn't be necessary; it's supposed to check automatically.

And I had an idea about the progress display shown while analyzing the grid: instead of the current vertical progress bar (meant to look like a jar filling up with mana or something), it should just be an hour glass, draining sand.  That will be much more obvious as to what it is and what it means.  I just need to find or make some good artwork for it.

Next steps: main menu and sound.  Oh, and I will also need to find all the chapter files that try to load some special image, and make those work (just fixing the paths).

Main menu (title.ms) is now working; so is Sound (new soda class, wraps both sound and music from Raylib's point of view).


## Mar 27 2026

I'm overdue for an update.  Steam does NOT make it easy to find, but here's the link for posting a Steam community update:

	https://steamcommunity.com/games/2145480/partnerevents/

So, new updated posted here:

https://store.steampowered.com/news/app/2145480/view/492720801006485750
https://joestrout.itch.io/inversion-institute/devlog/1471374/major-progress-on-inversion-institute-refit

I also studied the analysis code that runs before we can run the simulation (i.e., while the progress indicator is up), and found a way to speed that up substantially.  So now it takes about 0.7 seconds to analyze the Chapter 7 (majority rule) circuit on my machine.

Also, I implemented the feature where we calculate the smallest box that can contain all of the user's gates, and display this as "core area".  So we now have three metrics: gate count, total ink, core area.  We could log these to a server and show where you land on a histogram of all solutions.


## Apr 02 2026

I've updated the soda module to automatically initialize the window.  Now I'm working on making all the animations in Chapter 1 cutscenes work.  I've also had to adjust the speech dialog position when it gets too tall (they're a little taller now than they were before, thanks to the proper line spacing).

Another issue: checkboxes (empty and checked) are not part of this font, so they're not drawing properly on the objectives.

And for that matter, the text is much too thin/light on the objectives.  I need to find a font that renders better at such small sizes.

...ah, no, it turns out that the font wasn't the problem.  The problem was our font rendering; the standard blend mode causes the font to punch alpha holes in the pixel layer, allowing the color underneath to peek through.  Fixed with this trick around the font rendering (in ttFonts.ms):
```
	// Use normal color blending for RGB, but MAX mode for alpha,
	// so that our font rendering doesn't punch holes in the pixel layer.
	rl.rlSetBlendFactorsSeparate 770, 771, 0, 1, 32774, 32776
	rl.BeginBlendMode 7
```

The checkboxes are still an issue, though.  Raylib fonts don't include any sort of fallback or character-sprite system (unlike Unity's TMPro system).  Do I want to build that into ttFonts, or just handle these checkboxes specially?  Hmm.

I think I'll make this a feature of objectives.ms: a printWithBullet method, that draws a bullet image first and then the text next to it.  ...Yes, that looks great and is easy to use.

I've made a mock-up of the histogram interface.  The idea is to show this after a successful test, and give you the opportunity to "Continue Editing" or "Exit to Story".


## Apr 09 2026

I'm starting today on the backend server for histogram data.  This is written in Go, almost entirely by Claude (Sonnet) since that's not a core area for me.

Its all in the scoreserver folder.  I need to define each puzzle before the server will allow submissions for it.  For example, I can seed a new DB with:

go run ./cmd/seed --puzzle-id 7 --margin-x 18 --margin-y 0 --margin-w 44 --margin-h 64 --title "Test Puzzle"
  
...or just add an additional one with:

sqlite3 dev.db "INSERT INTO puzzles VALUES(1,'v1','v1','Chapter 1',1,datetime('now'));" 

(though actually that command above needs to be updated with the margin rect.)
  
View the available puzzles with:

	sqlite3 dev.db
	SELECT * FROM puzzles;

(Use `.mode column` to make SQLite's output suck less.)

Now we need a puzzle with known metrics for testing.  I'll use my circuit-7.png solution, which has 10 gates, total ink = 433, and core area = 247.  I can run the scoring test for that by doing:

go test ./internal/scoring/... -v -run TestMetrics_realCircuit7

It failed at first because we had forgotten about excluding gates outside the editable area (i.e., in the margin).

But with that fixed, all the tests are passing.  I've created a scoreserver/USAGE.md document to remind my future self how to use this thing, but it's pretty straightforward.  Running it on localhost for testing.

But then I remembered that raylib-miniscript doesn't have any http support.  So I just did a sidequest to add that, as well as file.loadRaw (which it was also lacking, though fortunately it already had the RawData class).  And I pulled in a MiniScript base64 implementation from another project.  So we should have all the pieces we need now.

It's basically working, but our first pass at the server storage did not clearly define who was going to decide the histogram bins.  I'm changing it now so that the bin width and starting point (i.e. minimum value for the second bin) for all three metrics are part of the puzzles table, and the server returns exactly the data we need to display, so the client (game) code stays simple.

OK, that's all working; basic histograms are up and stumbling about.  Here's a laundry list for next time:

- Add value labels to the histograms.
- Add triangle-line indicator of user's current scores.
- Fix screen trash in help area (not erasing quite enough).
- Lighten the red error text shown when check fails.

## Apr 11 2026

As a reminder, I need to start the score server each time I sit down to work with:

```bash
cd scoreserver
go run ./cmd/server --config config.local.yaml
```

But then I can just run assets/doneDialog with miniscript-raylib to test the histogram functionality.  I've added labels to the charts; they look great in a 12-point font.

So now I need to show the user's current scores, which I'm going to display both on the chart titles and as graphical indicators.  I can get these as sim.gates.len, sim.totalInk, and sim.coreArea.area, where sim = pixelLogicSim.   ...And that's now working great.  So these items are done:

- Add value labels to the histograms. ✔️
- Add triangle-line indicator of user's current scores. ✔️

And with a little more work, also done:

- Fix screen trash in help area (not erasing quite enough). ✔️
- Lighten the red error text shown when check fails. ✔️

On that last one, I lightened it *and* added a black shadow to make it stand out better against the gray background.

I need to start adjusting the histogram bins and ranges, though.  For chapter 6, I've used 16 glyphs, 549 ink, and 1118 area.  It could have been made a lot more compact, but this is where I am at the moment, and I'm off the chart on all three measures.  The scoreserver/scripts/configure_bins.sh script appears to have a bug.  The update process is pretty straightforward -- we no longer pre-bin things in the DB, but instead just store the count per exact measure -- but I'd still like a script so I don't have to remember the table and field names.

But it turns out Claude was trying to use features of bash 4.x, while macOS uses bash 3.2.  This led to all manner of hardship.  Throwing that script out and rewriting it in Python.  That works much better.

I've noticed another thing to fix in the editor though: the grid lines are not drawing consistently, and when you use the selection tool, it leaves screen trash behind.


## Apr 12 2026

A couple of feature ideas I'm pretty excited about:

### Notebook

In the editor, under the other tools, we should have a "Notebook" button (or perhaps "Notebook (12)" where 12 is the number of entries you have).  Whenever you have an active selection, there will also be an "Add" or "+" button; clicking that adds the current selection to your notebook, prompting you for a title.

Opening the notebook brings up a scrolling alphabetized list of all your notebook entries, and clicking on one shows the circuit (at probably half the editor scale).  There's a delete button to delete it, and a "use" or "apply" or something that closes the notebook and applies that circuit as the pending paste (just like copy/paste).

This simple feature allows you to build a library of reusable sub-circuits, which is a whole new axis of self-directed progression, and also makes solving the later challenges much easier (which means we can design harder later challenges!).

A possible difficulty is that we're running out of room on the right; some of our objectives (like Ch.2) don't fit already.  Maybe we switch to a smaller font size, or reduce the space between the tool buttons and the color palette?

### Keyboard Interface

We could have some little bit patterns, perhaps made with the rightmost colors (magenta and white), which we watch for when scanning the circuit.  If found, we set the state of those nodes according to keyboard state.  We would support at least the four arrow keys, plus maybe Shift, Control, and Space.  Maybe numbers too?  This lets users make interactive circuits and little games.

Bugs (and minor features) for today:
- Grid lines are not drawing consistently. ✔️
- Selection lines are leaving screen trash. ✔️
- Coordinates are not drawing... and I want to move them to the lower-left corner. ✔️
- ...and I want to show width x height when dragging a selection/rect/ellipse tool. ✔️
- Ellipse tools seem imprecise (wiggle around as you drag). ✔️
- Chapter 2 objectives are running off the screen. ✔️
- Some objectives (like Ch.2) are using right-arrow glyphs, which we don't have. ✔️

To tackle that last one, I added support for emoji (as either specific Unicode characters, or Markdown-style strings like ":arrow:") to TTFont.  It's now easy to add whatever custom glyphs we want to any font, and very easy to use them too.  I do need to go back and support for it to the `.width` function, though -- that will probably involve refactoring the `print` code too, extracting a method to split a string into a series of regular text substrings and Emoji.  But this solves the immediate problem, and I'm out of time for today.

(Edited to add: I found more time today; refactoring and `width` complete.)


