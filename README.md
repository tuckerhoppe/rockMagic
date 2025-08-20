# RockMagic

A 2D side-scrolling action game for iOS built with Swift and SpriteKit, featuring a dynamic, physics-based combat system. **This project is currently in a private beta test via TestFlight.**

![RockMagic Gameplay Demo](RockMagicClip.gif)

## Key Features

This project implements a complete, end-to-end gameplay loop, demonstrating a wide range of skills in game architecture, advanced physics programming, UI/UX, and backend services.

### Advanced Combat & Progression Systems

* **Multi-faceted Magic System:** Engineered a complex combat system with four distinct, player-controlled abilities:
    * **Summon:** Dynamically create multi-part boulder objects at any point on the screen.
    * **Quick & Strong Attacks:** Launch individual rock pieces or entire boulders with unique physics properties and damage values.
    * **Splash Attack:** Launch boulders in a calculated parabolic arc (`SKAction.follow(path)`) to deal area-of-effect (AOE) damage at a target location.
* **Interactive Physics Drag-and-Drop:** Implemented a tactile drag-and-throw mechanic using `SKPhysicsJointSpring`. This allows the player to physically manipulate boulders, using them as both a mobile shield and a thrown weapon, with enemies reacting realistically to being hit by a dragged object.
* **Strategic Stamina System:** Designed a resource management system where a powerful "Golden Boulder" can only be manipulated at full stamina, which then drains completely upon use. This creates a high-risk, high-reward "ultimate" ability that relies on a slow, passive regeneration rate.
* **Player Leveling & Upgrade System:** Built a full player progression loop. Players level up by gaining score, which pauses the game and presents a UI with a choice of persistent upgrades (e.g., increased health, attack damage, ability radius). This demonstrates a strong understanding of player motivation and reward systems.

### Robust Architecture & UI

* **Manager-Based Architecture:** Architected a clean and scalable codebase using the Manager pattern (`AnimationManager`, `MagicManager`, `CollisionManager`, etc.) and the Singleton pattern (`GameManager`) to enforce the Single Responsibility Principle and manage global game state.
* **Unified Input System:** Engineered a custom, stateful input manager that processes raw touch data to reliably distinguish between taps, swipes, and drags. This robust system eliminated conflicts between the virtual joystick and multiple, simultaneous gesture-based abilities.
* **Scrolling World & Parallax:** Built a `worldNode` system to create an expansive, side-scrolling world, complete with a multi-layered parallax background that provides a professional sense of depth.
* **Dynamic UI & State Management:** Developed a complete UI and game state system, including a `MainMenuScene`, an in-game `HUDNode` with real-time health and stamina bars, and a full pause/game over/upgrade menu loop.

### Intelligent Enemies & Effects

* **Diverse Enemy AI:** Implemented multiple enemy archetypes with unique behaviors and resistances, forcing strategic adaptation from the player:
    * "Little Rats" have a high chance to dodge direct attacks.
    * "Blockers" are immune to direct damage and must be defeated with splash attacks.
* **Parametric Particle System:** Created a central `EffectManager` to generate visceral, procedural particle effects for all key actions (summons, impacts, speed lines). The intensity of these effects (particle count, speed, scale, color) scales directly with the player's corresponding upgrade level, providing satisfying visual feedback for progression.
* **CloudKit Global Leaderboard:** Integrated a cloud-based backend to fetch and display a global high score leaderboard. This includes saving new scores and handling asynchronous network operations.

## Tech Stack

* **Language:** Swift
* **Frameworks:** SpriteKit, CloudKit
* **Tools:** Xcode, Git, GitHub

## How to Build and Run

1.  Clone the repository: `git clone https://github.com/tuckerhoppe/RockMagic.git`
2.  Open `RockMagic.xcodeproj` in Xcode.
3.  Select a target simulator or a connected iOS device.
4.  Build and run the project (Cmd + R).

### Alternatively contact me at tuckerhoppe22@gmail.com and I will add you to the Beta.

