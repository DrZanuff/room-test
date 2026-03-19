# Room Test (Godot 4.6)

Small first-person/third-person exploration prototype built as a practical assessment project.

This repository showcases:

- Physics-based player locomotion with a `RigidBody3D`
- A key-and-door interaction loop
- Lightweight game state management via autoload singletons
- Clear separation between player movement/camera and interaction handling

## Demo Goal

Explore the room, find the **Ice Key**, unlock the **Ice Door**, and enter the **Ice Dome** to complete the game.

## Play Online (Web)

- [itch.io Web Build](https://drzanuff.itch.io/rom-test)

## Walkthrough (Loom)

Short video walkthrough of the environment, scene hierarchy, physics, and interaction logic:

- [Loom walkthrough](https://www.loom.com/share/0bccf0dc922d4f2ca9f21eafbd76986f)

## How To Run

1. Open the project in **Godot 4.6**.
2. Run the main scene (configured in `project.godot` as `game.tscn`).

## Controls

- `WASD` or arrow keys: Move
- `Space`: Jump
- `Mouse move`: Rotate camera around the player (yaw)
- `Mouse wheel up/down`: Zoom camera in/out
- `E`: Interact when the interaction prompt is visible
- `Esc`: Toggle mouse capture

## Gameplay Loop

1. Spawn in the room.
2. Navigate to the key area and interact (`E`) to collect the key.
3. Go to the Ice Door and interact to unlock/open it.
4. Enter the Ice Dome to trigger win message.
5. Falling into the bottom pit resets the scene.

## Tech Stack

- **Engine:** Godot 4.6
- **Language:** GDScript
- **Physics backend:** Jolt Physics (`project.godot`)
- **Scene system:** Godot `.tscn` composition + autoload singletons

## Project Structure

- `game.tscn` / `game.gd`
  - Main scene orchestration and intro message.
- `objects/player/`
  - `player.tscn`, `player.gd`: Player physics, movement, jump, animation state machine, camera follow anchor.
  - `player_camera.tscn`, `player_camera.gd`: Camera zoom and camera shake behavior.
  - `player_interactions.gd`: Interaction flow and trigger responses.
- `objects/ice_door/`
  - `ice_door.tscn`, `ice_door.gd`: Door scene and open animation behavior.
- `objects/room/the_room.tscn`
  - Environment composition and world interaction areas (key, pit, finish).
- `scripts/game_manager.gd`
  - Global game state for key ownership and door status.
- `ui/game_ui.tscn`, `ui/game_ui.gd`
  - Message modal and interaction prompt.

## Architecture and Design Patterns

### 1) Singleton State Coordinator (Autoload)

`GameManager` and `GameUi` are configured as autoloads in `project.godot`.

- `GameManager` centralizes game progression state:
  - player has key?
  - door open?
  - references to registered player/door
- `GameUi` centralizes UI concerns:
  - modal messages
  - interaction indicator
  - mouse capture transitions for modal usage

Why this helps:

- Removes hard scene coupling for cross-cutting concerns.
- Keeps gameplay scripts focused on domain behavior.

### 2) Explicit Registration Pattern

Core gameplay actors register themselves with `GameManager`:

- `Player._ready()` -> `GameManager.register_player(self)`
- `IceDoor._ready()` -> `GameManager.register_door(self)`

Why this helps:

- Avoids brittle node-path lookups from a global manager.
- Keeps dependencies explicit and lifecycle-aware.

### 3) Event-Driven Communication with Signals

Signals are used for loose coupling:

- Player emits `got_key`.
- `GameManager` listens to `got_key` after player registration and updates state.
- UI button emits `pressed`, handled by `GameUi` to close message and continue callbacks.
- `AnimationPlayer.animation_finished` controls jump lock/unlock flow in player state.

Why this helps:

- Reduces direct script-to-script dependencies.
- Enables clear, reactive gameplay flow.

### 4) Separation of Responsibilities (Single Responsibility)

Player logic is split by scope:

- `player.gd`: movement, jump, camera anchor rotation, animation state
- `player_camera.gd`: zoom smoothing and camera shake
- `player_interactions.gd`: interaction contexts, prompts, and outcomes

This keeps each script small and easier to reason about.

### 5) Finite State Machine (FSM) for Player Animation

`PlayerState` enum (`IDLE`, `MOVE`, `JUMP`) drives animation transitions through `_set_state(...)`.

Benefits:

- deterministic animation transitions
- clear constraints (jump lock active while jump animation is running)
- easier extension (e.g., crouch, dash) without ad-hoc condition sprawl

### 6) Data-Driven Interaction Zones via Groups

World `Area3D` nodes use groups (`ICE_KEY`, `ICE_DOOR`, `ICE_DOME`, `BOTTOM_PIT`) to classify interactions.
`PlayerInteractions` matches group type and triggers contextual behavior.

Benefits:

- interaction rules depend on semantic tags instead of fragile node names
- easy to add new interaction zones

## Physics Notes

- Player is a `RigidBody3D`.
- Movement is force-based in XZ using camera-relative vectors.
- Floor checks use multiple downward raycasts for jump eligibility.
- Horizontal deceleration is applied when movement input is released.
- Jump takeoff sets vertical velocity directly for consistent behavior in this setup.

## UI/UX Notes

- Interaction prompt appears when entering relevant trigger areas.
- Modal messages pause interaction flow and release mouse capture until confirmed.
- Camera zoom is smoothed with interpolation (`lerp`) for better feel.

## Input Map Summary

Defined in `project.godot`:

- `up`, `down`, `left`, `right`
- `jump`
- `interaction`
- `scroll_up`, `scroll_down`

## Future Improvements

- Add audio feedback for key pickup, door unlock, and win state.
- Add save/checkpoint system instead of scene reload resets.
- Add dedicated interaction interface for typed interactables.
- Add unit/integration tests with GUT or WAT for state transitions.

## Notes for Reviewers

This project intentionally prioritizes:

- clean scene/script organization
- readable gameplay code
- practical use of signals, autoloads, and state management

Visual polish is secondary to architecture clarity and interaction correctness.
