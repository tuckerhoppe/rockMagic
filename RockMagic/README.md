#  RockMagic

##Summary
Rock magic is a 2d side scroller game where the player uses swiping, tapping to control rocks.
They shoot them at enemies and Gem idols to defend themselves.
The Goal of the game is to get the highest score. Each level passed adds an additional element of difficulty whether it be different enemies, more damage or whatever.

##Features Requirements

###Player functionality
* Use Joystick to move around the screen and area as a whole.
* Swipe up to pull up a boulder from the ground.
* Swipe left or right to launch entire boulder in respective direction.
* Tap to shoot just a piece of the boulder off.
* Separate animations for above features
* Store and display health bar

###Enemy Functionality
* Walk towards player facing the correct direction.
* Once near the player start damaging. 
* Respawn the correct number of enemies based on the current level
* Store and display health bar
* Death animation when health bar hits 0 then slow fade away




## Class Breakdowns

Each Node will handle primarily three things
* Movement
* Animation
* Physics

### Magic Manager
* Detects and interprets gestures (swipe up, left/right, tap).
* Spawns boulder objects.
* Tells boulders what action to perform (e.g., .launch(direction:), .explodePiece()).

✅ MagicManager
Detects and interprets gestures (swipe up, left/right, tap).

Spawns boulder objects.

Tells boulders what action to perform (e.g., .launch(direction:), .explodePiece()).

### Boulder Class
* riseFromGround()
* launch(direction: CGVector)
* explodePiece()
