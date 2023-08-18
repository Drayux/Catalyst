# Setup
###### All dependencies are referred to as their pacman package names
### Make Dependencies (TODO)
- cmake  
- git  
- make  
  
### Dependencies (TODO)
- libusb-compat  
  
# Install
### Clone the repo (pwd assumed to be ~/Downloads/)
>`git clone --depth=1 --recursive https://github.com/itgmania/itgmania.git ITGMania`  
`cd ITGMania/`  
  
### Generate build files with CMake
> `cd Build`  
_^^Build is included with the repo_  
`cmake -G "Unix Makefiles" ..`  
_^^This is the default so -G may not be necessary_  
`cmake ..`
  
### Compile and install
`make && make install`  
  
# Notes
Build Reference -> https://github.com/itgmania/itgmania/tree/release/Build  
  
### Portable mode
It appears that a portable build is possible with `-DCMAKE_INSTALL_LOCAL_ONLY=1`  
_^^Though the repo suggests that make alone creates a portable version by default (I do not remember what what responsible for my .desktop entry however)_  
Further, the install location can be specified with `-DCMAKE_INSTALL_PREFIX=<path>`  

### Song installation
From [itgmania/Songs/instructions.txt](https://github.com/itgmania/itgmania/blob/release/Songs/instructions.txt):
<pre>
[How to Install Songs]
Songs are laid out based on the group that they are in.

Songs\							: root folder
	StepMania 5\				: group folder
		MechaTribe Assault\		: song/simfile folder
			*.png, *.mp3/*.ogg, *.sm/*.ssc/etc files

[How NOT to install songs]
This won't work because StepMania expects groups:

Songs\
	Some Song\
		*.png, *.mp3/*.ogg, *.sm/*.ssc/etc files

And this won't work because StepMania doesn't handle sub-groups:

Songs\
	Song Group\
		SubGroup1\
			Some Song\
				*.png, *.mp3/*.ogg, *.sm/*.ssc/etc files
</pre>

### Themes
DDR A3 Theme -> https://github.com/Curilang/DDR-A3-THEME  

To change themes:  
#### From Simply Love to DDR.A3
\<Main Menu\> -> Options -> System Options -> Theme --> DDR.A3

#### From DDR.A3 to Simply Love
\<Main Menu\> (after press ◻️ to start) -> Options (access via L/R presses) -> Appearance Options -> Theme --> Simply Love

### In-game options
F3 (hold) to view debug menu  
F7 to toggle note clap  
Shift + F7 to toggle measure clap  
F8 to toggle autoplay  
  
### Song Packs
#### [DDR A3](https://zenius-i-vanisher.com/v5.2/viewsimfilecategory.php?categoryid=1509)
#### [DDR A20 PLUS](https://zenius-i-vanisher.com/v5.2/viewsimfilecategory.php?categoryid=1293)
#### [DDR A20](https://zenius-i-vanisher.com/v5.2/viewsimfilecategory.php?categoryid=1292)
#### [DDR A](https://zenius-i-vanisher.com/v5.2/viewsimfilecategory.php?categoryid=1148)
#### [DDR 2014](https://zenius-i-vanisher.com/v5.2/viewsimfilecategory.php?categoryid=864)
#### [DDR 2013](https://zenius-i-vanisher.com/v5.2/viewsimfilecategory.php?categoryid=845)
_More packs available from [zenius-i-vanisher](https://zenius-i-vanisher.com/v5.2/simfiles.php?category=simfiles)_  
  
### Preferred game settings (Simply Love)
#### System Options
**Game** -> dance (DDR Mode ; pump for PIU mode)  
**Theme** -> Simply Love  
**Language** -> English  
**Announcer** -> Off  
  
#### Input Options 
**Automap Joysticks** -> Off  
**Options Navigation** -> Arcade Style  
**Input Debounce Time** -> 10ms (for keyboard)  
  
#### Visual Options -> Appearance Options
**Center 1 Player** -> Off  
**Show Banners** -> On  
**BG Brightness in Gameplay** -> 40%  
  
#### Arcade Options
**Event Mode** -> On  
**Multiple High Scores...** -> On (at home, else Off)  
**Carry Combo** -> Off  
**Disqualification** -> On  
**Max Machine Scores** -> 8 (at home)  
  
#### Advanced Options
**Default Fail Type** -> ImmediateContinue  
**Timing Window Scale** -> 5 (revert to 4 if I modify the windows to DDR timing)  
**Life Difficulty** -> 3 (feels a bit more like DDR)  
**Allow Song Deletion** -> Off  
  
#### Menutimer Options
**Menu Timer** -> Off  
  
#### Simply Love Options
**Visual Style** -> \<star\>  
**MusicWheel Scroll Speed** -> Fast  
**MusicWheel Style** -> ITG  
**Allow Players to Fail Set** -> No  
_Preferred for home configuration_  
**Allow Screen Select Profile** -> Yes  
**Allow Screen Select Color** -> No  
**Allow Screen Eval Summary** -> No  
**Allow Screen Name Entry** -> No  
**Allow Screen Game Over** -> No  
**nice** -> On with Sound  
**Write Custom Scores** -> No  
**Keyboard Features** -> Yes  
**Use Image Cache** -> No  
  
### Bugs
ITGMania seems to prevent the scroll wheel from working in electron-based applications whenever it is running; This issue is fixed as soon as the application is closed  

# To-do
### Determine how to show Fantastic+ events on the post-song histogram
### Determine how to configure timing window settings
### Add option to enable per-beat metronome clap (instead of per measure)
### Determine how to enable DDR-style combo coloring (aka immediately show color of combo)
This appears to be a theme option as this is present in the A3 theme  

### ~~DDR.A3 Theme: Fix the scores to show them normalized to 1,000,000 (not 100,000,000)~~
### DDR.A3 Theme: Unable to change speed options 
Probably missing a setting  
(Also try pressing /)  

### Verify and prune dependencies
### Add pacman support
Create a PKGBUILD file that allows the above process to be automated via `makepkg --install`  
Alternatively, figure out how to "spoof" the install with the pacman manual dependency thing  
