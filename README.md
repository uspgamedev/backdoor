
<img src="https://camo.githubusercontent.com/1779bb0fca2dd020c03393005c8640c4aa1bb980/68747470733a2f2f75737067616d656465762e6f72672f6d6564696177696b692f696d616765732f382f38392f4261636b646f6f72636f7665722e706e67" alt="cover" data-canonical-src="https://uspgamedev.org/mediawiki/images/8/89/Backdoorcover.png" style="margin-left, margin-right: auto;display: block; width: 50%;" width="400">

At the *Front Stage*, from the *Fateful Dream* Endless saga:
The *Outermaze* Book of Rhapsodies'

# BACKDOOR ROUTE

*Backdoor Route* is a card-collecting deck-building rogue-like cyberpunk
computer game developed in partnership with **project:v**. Abandoned in a
colossal planet-ship traveling across the rifts of the multiverse, the survivors
of a long-forgotten tragedy must venture through the ruins of a dead and
hopeless world in search of the Fruits of Vanth while drifting towards what they
believe to be their salvation. Play the role of one of these interdimensional
immigrants in a game that closely follows the format of classic rogue-likes save
for one particularity: your actions, your items, your skills, and even your
character progression are all represented by cards you assemble in decks while
you crawl, hack and slash your way through the world the Gods have left
behind.

## Running the project

### On Unix systems (Linux and MacOS)

Dependencies:

+ git
+ CMake
+ Make
+ löve
+ wget
+ luajit (dev package)

If all the above are properly installed, the command

```bash
$ make
```

Should be enough to download, setup, and run the game.

### On Windows (experimental)

After cloning the repository, download these archives into the project folder:

1. [Patched LÖVE 11.2 for windows x86](https://uspgamedev.org/downloads/projects/backdoor/love-11.2.0-win32-patched.zip)
2. [Game libraries](https://uspgamedev.org/downloads/projects/backdoor/libs.zip)

Then, do the following:

1. Extract `love-11.2.0-win32-patched.zip`
2. Create a shortcut for the `love.exe` inside the extracted folder
3. Move the shortcut to the root folder of the project
4. Extract `libs.zip` (IMPORTANT: do it exactly where you downloaded it, i.e., the root project folder)
5. Drag and drop the `game` folder onto the shortcut to run the game

After this initial setup, you can simply use step 5 to run the game whenever
you want. If an error occurs because of the libraries, it's likely because the
download links are outdated - ask one of the unix developers to update them.
