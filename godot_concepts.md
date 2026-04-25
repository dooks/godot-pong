# Godot Fundamentals

*A living textbook. Each chapter starts locked; it fills in when you use that feature in the project.*

---

## Contents

**Part I — The Engine**
- Chapter 1: The Godot Editor *(locked)*
- Chapter 2: Scenes and the Scene Tree
- Chapter 3: Nodes
- Chapter 4: Resources

**Part II — GDScript**
- Chapter 5: Scripts and Lifecycle
- Chapter 6: Variables, Types, and Annotations
- Chapter 7: Class Names and Inheritance
- Chapter 8: Collections
- Chapter 9: Coroutines and await *(locked)*

**Part III — Communication**
- Chapter 10: Signals
- Chapter 11: Groups
- Chapter 12: Autoloads

**Part IV — Input**
- Chapter 13: Input

**Part V — Math and Space**
- Chapter 14: Vectors and Math
- Chapter 15: Transforms and Coordinate Space

**Part VI — Physics**
- Chapter 16: Physics Bodies
- Chapter 17: Collision
- Chapter 18: Character Movement *(locked)*
- Chapter 19: Navigation and Pathfinding *(locked)*

**Part VII — Visuals**
- Chapter 20: 3D Nodes and Meshes
- Chapter 21: Materials and Shading
- Chapter 22: Lighting
- Chapter 23: Cameras and Viewports
- Chapter 24: Particles and Visual Effects *(locked)*
- Chapter 25: Shaders *(locked)*

**Part VIII — User Interface**
- Chapter 26: Control Nodes
- Chapter 27: Menus and Screens *(locked)*

**Part IX — Time and Motion**
- Chapter 28: Tweens *(locked)*
- Chapter 29: AnimationPlayer *(locked)*

**Part X — Advanced**
- Chapter 30: PackedScene and Runtime Instantiation *(locked)*
- Chapter 31: Audio *(locked)*
- Chapter 32: Saving and Loading Data *(locked)*
- Chapter 33: Editor Scripting

**Part XI — Shipping**
- Chapter 34: Debugging, Profiling, and Exports *(locked)*

---

# Part I — The Engine

## Chapter 1: The Godot Editor

> *Locked — navigate the editor and customize the workspace to unlock this chapter.*

---

## Chapter 2: Scenes and the Scene Tree

### Scenes

A **scene** is a saved, hierarchical tree of nodes stored as a `.tscn` file. Scenes are the core organizational unit of a Godot project — every asset you build (a paddle, a ball, a level, a HUD) lives in a scene.

What makes scenes powerful is reuse. A scene file is a **template**: it can be instanced as many times as you want in other scenes. When instanced, Godot duplicates the entire subtree. `paddle.tscn` can become two paddles in the main scene without duplicating any code.

Scenes serve three roles simultaneously:
- **Prefabs** — reusable assemblies of nodes
- **Levels** — the root scene loaded when the game starts
- **Resources** — scenes are `PackedScene` resources that can be loaded, instantiated, and saved programmatically (see Chapter 30)

The project designates one scene as the **main scene**, configured in Project Settings → Application → Run. This is the entry point when the game launches.

### The Scene Tree

The **SceneTree** is the live, running version of all loaded scenes merged into one hierarchy. When the main scene loads, it becomes `current_scene`. All its nodes are children (and descendants) of the tree's `root` — a `Window` node that always exists.

```
Window (root)
└── Main (current_scene)
    ├── Player1
    ├── Player2
    ├── Ball
    └── HUD
```

Scene-file boundaries disappear at runtime — it's all just nodes. Access the SceneTree from any node with `get_tree()`:

| Method / Property | Purpose |
|---|---|
| `get_tree().current_scene` | Reference to the active main scene node |
| `get_tree().root` | The top-level Window node |
| `get_tree().paused` | Pause all processing and physics |
| `get_tree().change_scene_to_file(path)` | Load a new scene from a file path |
| `get_tree().change_scene_to_packed(packed)` | Load from a PackedScene resource |
| `get_tree().reload_current_scene()` | Restart the current scene |
| `get_tree().quit()` | Exit the application |

### Instancing

When you drag a `.tscn` file into another scene in the editor, Godot creates an **instance** — a live copy of that scene's node tree embedded in the parent. Instances are independent; changing one paddle's Inspector properties doesn't affect the other. Modifications to the source `.tscn` propagate to all instances.

---

## Chapter 3: Nodes

Nodes are the **atomic building block** of everything in Godot. Every visible object, every physics body, every script-bearing element in the editor is a node.

### What a Node Is

Every node has:
- A **type** that determines its capabilities (`RigidBody3D`, `MeshInstance3D`, `Label`, etc.)
- A **name** used for tree navigation and identification
- **Properties** viewable and editable in the Inspector
- A **parent** (except the scene root) and zero or more **children**
- An optional **script** that extends its behavior

### The Inheritance Chain

Node types form an inheritance hierarchy. Every type inherits from a chain of base types, accumulating their capabilities:

```
Node
└── Node3D
    └── CollisionObject3D
        └── PhysicsBody3D
            └── RigidBody3D
```

When your script writes `extends RigidBody3D`, it inherits `position` and `rotation` from `Node3D`, collision layer properties from `CollisionObject3D`, mass and velocity from `RigidBody3D` — the entire chain. You get all of it with no wrapper.

### Composition over Monoliths

Nodes are designed to be **composed**. A physics object separates visual, physical, and logical concerns into distinct child nodes:

```
RigidBody3D          ← physics simulation
├── CollisionShape3D ← defines the hit boundary
└── MeshInstance3D   ← defines what gets rendered
```

Each node does one thing. This lets you swap, disable, or modify individual concerns independently.

### Node Lifecycle

Godot calls specific methods on your script at defined points in a node's life:

| Method | When called | Execution order |
|---|---|---|
| `_enter_tree()` | Node added to the scene tree | Parent before children |
| `_ready()` | Node and all its children have entered the tree | **Children before parents** |
| `_process(delta)` | Every frame | Top-down |
| `_physics_process(delta)` | Every physics tick | Top-down |
| `_exit_tree()` | Node removed from the scene tree | Children before parents |

The bottom-up ordering of `_ready()` is critical: by the time a parent's `_ready()` runs, every child in its subtree is already ready.

### Navigating the Tree

| Syntax | Meaning |
|---|---|
| `$ChildName` | Shorthand for `get_node("ChildName")` |
| `$"Path/To/Node"` | Path navigation through the tree |
| `$"../Sibling"` | Walk up with `..`, then down |
| `get_node_or_null("Path")` | Returns `null` instead of crashing if not found |
| `get_parent()` | Direct reference to the parent node |
| `get_children()` | Array of all direct children |
| `get_tree()` | The global SceneTree |
| `find_child("name")` | Recursive search by name |

---

## Chapter 4: Resources

**Resources** are Godot's data layer. Where nodes provide behavior, resources store the data that nodes consume. Everything Godot saves to or loads from disk — textures, scripts, meshes, audio, animations — is a resource.

### The Node/Resource Distinction

| | Nodes | Resources |
|---|---|---|
| Purpose | Behavior, rendering, game logic | Data storage |
| Live in | The scene tree | Properties of nodes |
| Memory | One per scene instance | Shared; loaded once and cached |
| Lifecycle | Tied to the scene tree | Reference-counted |

### Built-in Resource Types

| Resource | Assigned to |
|---|---|
| `BoxMesh`, `SphereMesh`, etc. | `MeshInstance3D.mesh` |
| `BoxShape3D`, `CapsuleShape3D`, etc. | `CollisionShape3D.shape` |
| `PhysicsMaterial` | `RigidBody3D.physics_material_override` |
| `StandardMaterial3D` | `MeshInstance3D.material_override` |
| `AudioStream` | `AudioStreamPlayer.stream` |
| `PackedScene` | Runtime instantiation via `.instantiate()` |

### Creating Resources in Code

```gdscript
var mat := PhysicsMaterial.new()
mat.friction = 0.0
mat.bounce = 1.0
physics_material_override = mat
```

You create a resource, configure its properties, and assign it to the appropriate node property.

### Loading Resources from Disk

```gdscript
# preload: resolved at compile time — path must be a constant string
var scene = preload("res://scenes/ball.tscn")

# load: resolved at runtime — path can be a variable
var scene = load("res://scenes/" + level_name + ".tscn")
```

`preload` is faster (no runtime I/O) and catches missing paths at editor parse time. Use `load` when the path isn't known until runtime.

### The Resource Cache

Godot loads a resource file **once**. Subsequent calls with the same path return the same cached object. This means:

- Resources are **shared by default** — two nodes using the same material share one object
- Modifying a resource property affects **all nodes** that reference it
- Call `.duplicate()` to get an independent copy: `var my_mat = base_mat.duplicate()`

For per-instance materials on meshes, use `material_override` rather than modifying the shared mesh resource (see Chapter 21).

### Custom Resources

Extend `Resource` to create typed data containers for your game:

```gdscript
class_name PlayerData
extends Resource

@export var player_name: String = ""
@export var high_score: int = 0
```

Custom resources get automatic serialization (`.tres` files), Inspector support, and reference counting for free.

---

# Part II — GDScript

## Chapter 5: Scripts and Lifecycle

### Scripts Become Nodes

A script doesn't attach *alongside* a node — it **extends** it. `extends RigidBody3D` means your script class *is* a `RigidBody3D`, with added or overridden behavior. All of `RigidBody3D`'s properties and methods are directly accessible without any wrapper.

```gdscript
extends RigidBody3D

func _ready() -> void:
    linear_velocity = Vector3.RIGHT * 5.0   # RigidBody3D property, no wrapper needed
    gravity_scale = 0.0
```

### The Node Lifecycle

**Initialization**

`_enter_tree()` — called when the node is added to the scene tree. Parent's `_enter_tree()` runs *before* children's. Children may not be ready yet — avoid accessing them here.

`_ready()` — called once after the node **and all its children** have entered the tree. Executes **children first, then parents** (bottom-up). By the time your `_ready()` runs, every child in the subtree is guaranteed ready. Use this for caching references and wiring up connections.

**Processing**

`_process(delta: float)` — called **every frame** at the display frame rate. Frame rate varies by device. Always multiply movement by `delta` to be frame-rate-independent.

`_physics_process(delta: float)` — called at a **fixed rate** (default 60 Hz, configurable at Project Settings → Physics → Common → Physics Ticks Per Second). Delta is always consistent. Use for anything touching the physics engine — moving rigid bodies, collision queries, velocity changes.

**Cleanup**

`_exit_tree()` — called when the node leaves the scene tree. Children's `_exit_tree()` runs *before* the parent's.

### Frame-Rate Independence

```gdscript
# Wrong — speed doubles at 120 fps vs 60 fps
func _process(_delta: float) -> void:
    position.x += 5.0

# Correct — speed is in units per second regardless of frame rate
func _process(delta: float) -> void:
    position.x += 5.0 * delta
```

`_physics_process` receives a fixed delta, but multiply by it anyway for consistency.

### _notification()

For events not covered by the convenience callbacks, override `_notification(what: int)`:

```gdscript
func _notification(what: int) -> void:
    match what:
        NOTIFICATION_PAUSED:
            save_state()
        NOTIFICATION_UNPAUSED:
            restore_state()
        NOTIFICATION_VISIBILITY_CHANGED:
            if visible:
                play_appear_animation()
```

Useful for pause handling, visibility changes, and other lower-frequency engine events.

---

## Chapter 6: Variables, Types, and Annotations

### Variable Declaration

```gdscript
var speed = 10.0             # dynamic — type inferred at runtime
var speed: float = 10.0      # explicit type hint
var speed := 10.0            # inferred static type (preferred when type is obvious)
const MAX_SPEED: float = 20.0   # constant — cannot be reassigned
static var count := 0        # shared across all instances of this class
```

`:=` infers the type from the right-hand side at compile time. Prefer it over bare `var` when the type is clear. `const` values must be determinable at compile time. `static var` persists even when no instances of the class exist.

### Type Hints

```gdscript
var player: Player
var players: Array[Player] = []
var state: Dictionary[Player, PlayerState] = {}

func move(direction: Vector3) -> void: pass
func get_score() -> int: return score
```

Valid types: built-ins (`int`, `float`, `String`, `bool`, `Vector3`, `Color`, etc.), engine classes, `class_name` declarations, and preloaded scripts.

### @export

Exposes a variable in the Inspector when the node is selected. The value set in the Inspector is saved with the scene.

```gdscript
@export var speed: float = 12.0
@export var player: Player
@export var color: Color = Color.WHITE
```

**Variants:**

```gdscript
# Slider with min, max, and optional step/hints
@export_range(0.0, 100.0) var health: float = 100.0
@export_range(0.1, 10.0, 0.1, "exp") var decay: float = 1.0
@export_range(0, 360, 1, "suffix:°") var angle: float = 0.0
@export_range(-180, 180, 1, "radians_as_degrees") var tilt: float = 0.0

# Dropdown from a fixed list
@export_enum("Easy", "Normal", "Hard") var difficulty: int = 1

# Bit flags — values must be powers of 2
@export_flags("Can Jump:1", "Can Dash:2", "Can Fly:4") var abilities: int

# Group properties visually in the Inspector
@export_group("Movement")
@export var move_speed: float = 10.0
@export var acceleration: float = 5.0
```

`@export_range` hint options: `"or_less"` / `"or_greater"` (allow outside slider range), `"exp"` (exponential scale), `"hide_slider"` (text input only), `"suffix:unit"` (display unit label), `"radians_as_degrees"` (store radians, show degrees).

### @onready

Delays a variable's initialization until `_ready()` — after the full subtree has entered the tree. Essential for caching child node references:

```gdscript
@onready var mesh: MeshInstance3D = $MeshInstance3D
@onready var label: Label = $HUD/ScoreLabel
```

**Initialization order:**
1. Type-dependent defaults or `null`
2. `var` assignments
3. `_init()` method
4. Exported values (from Inspector or scene)
5. **`@onready` assignments**
6. `_ready()` method

**Critical rule:** Never combine `@export` and `@onready` on the same variable. `@onready` fires after exported values are applied and will silently overwrite whatever was set in the Inspector. Godot treats this combination as an error.

---

## Chapter 7: Class Names and Inheritance

### class_name

Registers a script as a globally accessible type. Any other script can use it as a type without importing or preloading:

```gdscript
# player.gd
class_name Player
extends Node
```

```gdscript
# anywhere else — no import needed
var p: Player
@export var player: Player
var players: Array[Player] = []
```

The name is global across the project — keep it unambiguous. Only one `class_name` per script, declared before `extends`. Optionally attach an editor icon:

```gdscript
@icon("res://icons/player.png")
class_name Player
extends Node
```

### Inheritance

```gdscript
extends Node              # extend an engine class
extends "enemy_base.gd"   # extend another script by path
```

Type checking with `is`:

```gdscript
if body is Ball:
    body.apply_spin()
if node is Control:
    node.hide()
```

### super()

When overriding a method the parent implements, call `super()` to run the parent's version:

```gdscript
func _ready() -> void:
    super()                  # parent's _ready runs first
    setup_custom_behavior()

func take_damage(amount: int) -> void:
    super.take_damage(amount) # specific parent method
    play_hurt_animation()
```

### _init() — The Constructor

Runs when a new instance is created, before `_ready()`. Runs even for nodes not yet in the scene tree (e.g. `Node.new()`):

```gdscript
func _init(start_health: int = 100) -> void:
    health = start_health
```

Call the parent constructor with `super(args)`.

### Inner Classes

Define a class inside a script when it belongs exclusively to that file:

```gdscript
# game_state.gd
extends Node

class PlayerState:
    var score := 0
    var lives := 3

var state: Dictionary[Player, PlayerState] = {}
```

Access from outside: `GameState.PlayerState.new()`. From within the same file: `PlayerState.new()`.

### Abstract Classes (Godot 4.5+)

Prevent direct instantiation and require subclasses to implement abstract methods:

```gdscript
@abstract class Shape:
    @abstract func area() -> float:
        pass

class Circle extends Shape:
    var radius: float
    func area() -> float:
        return PI * radius * radius
```

`Shape.new()` errors at runtime; `Circle.new()` works.

---

## Chapter 8: Collections

### Arrays

```gdscript
var items: Array = [1, "text", true]    # untyped — any mixture
var scores: Array[int] = [10, 20, 30]   # typed — int only (preferred)
var players: Array[Player] = []
```

| Operation | Code |
|---|---|
| Append | `arr.append(value)` |
| Append array | `arr.append_array(other)` |
| Insert at index | `arr.insert(index, value)` |
| Remove at index | `arr.remove_at(index)` |
| Remove last | `arr.pop_back()` |
| Remove first | `arr.pop_front()` |
| Size | `arr.size()` |
| Is empty | `arr.is_empty()` |
| Contains | `arr.has(value)` |
| Find index | `arr.find(value)` |
| Sort | `arr.sort()` |
| Slice | `arr.slice(begin, end)` |
| Clear | `arr.clear()` |

Typed arrays (`Array[int]`, `Array[Player]`) enable static analysis and are more performant than untyped arrays. Prefer them.

### Packed Arrays

`PackedByteArray`, `PackedInt32Array`, `PackedFloat32Array`, `PackedStringArray`, `PackedVector2Array`, `PackedVector3Array`, `PackedColorArray` — fixed-type arrays stored in contiguous memory. Lower overhead than `Array[T]` for large datasets. Use when handling geometry, audio samples, or color buffers at scale.

### Dictionaries

```gdscript
var config: Dictionary = {"speed": 10.0, "health": 100}
var typed: Dictionary[String, float] = {"speed": 10.0}
var state: Dictionary[Player, PlayerState] = {}
```

| Operation | Code |
|---|---|
| Set | `d[key] = value` |
| Get | `d[key]` (errors if missing) |
| Safe get | `d.get(key, default)` |
| Contains key | `d.has(key)` |
| Remove key | `d.erase(key)` |
| All keys | `d.keys()` |
| All values | `d.values()` |
| Size | `d.size()` |
| Iterate | `for key in d:` |

Using a node as a key works by object identity. If the node is freed, its key becomes a dangling reference — only use node keys for state that lives and dies with the scene.

---

## Chapter 9: Coroutines and await

> *Locked — use `await` in a script to unlock this chapter.*

---

# Part III — Communication

## Chapter 10: Signals

Signals are Godot's built-in observer pattern. A node **emits** a signal when something happens; any other node can **connect** a callback to listen. The emitter doesn't need to know who's listening, and the listener doesn't need to know who emitted — they're fully decoupled.

### Declaration and Emission

```gdscript
signal health_changed(old_value: int, new_value: int)
signal player_died

func take_damage(amount: int) -> void:
    var old := health
    health -= amount
    health_changed.emit(old, health)
    if health <= 0:
        player_died.emit()
```

### Connecting Signals

```gdscript
func _ready() -> void:
    health_changed.connect(_on_health_changed)
    player_died.connect(func(): get_tree().reload_current_scene())
    body_entered.connect(_on_body_entered)   # built-in signal
```

Use `Signal.connect(callable)` — it provides compile-time validation over the legacy string-based `Object.connect("signal_name", callable)` form.

### Connection Flags

Pass optional flags as the second argument to `connect()`:

| Flag | Effect |
|---|---|
| `CONNECT_DEFERRED` | Callback runs at end of frame. Use to avoid modifying physics or scene state mid-step. |
| `CONNECT_ONE_SHOT` | Disconnects automatically after the first emission. Use for one-time events. |
| `CONNECT_REFERENCE_COUNTED` | Allows the same callable to be connected multiple times; fully disconnects only when the count reaches zero. |
| `CONNECT_PERSIST` | Saves the connection when the scene is serialized. Editor-created connections use this. Lambda functions cannot be persistent. |

```gdscript
level_completed.connect(_on_level_done, CONNECT_ONE_SHOT)
body_entered.connect(_on_hit, CONNECT_DEFERRED)
```

### Callable.bind()

Attach extra arguments to a callback that the signal doesn't emit:

```gdscript
# The signal emits one Player parameter, but the callback needs a player_index too
score_goal.connect(_on_goal.bind(player_index))

func _on_goal(player: Player, player_index: int) -> void:
    scores[player_index] += 1
```

Signal parameters are passed first; bound parameters follow.

### Lambda Connections

```gdscript
timer.timeout.connect(func(): score += 1)
GameState.reset_game.connect(update_score)   # method reference
```

Lambdas capture the enclosing scope, making them useful for lightweight callbacks without dedicated methods.

### Disconnecting

```gdscript
signal.disconnect(callable)

if signal.is_connected(callable):
    signal.disconnect(callable)
```

### await

`await` pauses a coroutine until a signal fires:

```gdscript
func start_round() -> void:
    await countdown_finished   # execution pauses here
    spawn_ball()               # resumes after the signal fires
```

Full coverage in Chapter 9.

---

## Chapter 11: Groups

Groups work like **tags**. Add nodes to groups, then query or broadcast to all members without holding direct references.

### Managing Membership

```gdscript
func _ready() -> void:
    add_to_group("enemies")
    add_to_group("shootable")

func die() -> void:
    remove_from_group("enemies")

if is_in_group("enemies"):
    take_damage(10)
```

Groups can also be assigned in the editor: Node panel → Groups tab. Editor-assigned groups persist with the scene; code-assigned groups reset on scene reload.

### Querying Groups

```gdscript
# All nodes in a group (ordered by scene hierarchy)
var enemies := get_tree().get_nodes_in_group("enemies")

# First match — useful when only one exists (e.g., the ball)
var ball := get_tree().get_first_node_in_group("ball")
```

Returns an empty array (not null) if no nodes match.

### Broadcasting to Groups

```gdscript
# Call a method on every node in the group immediately
get_tree().call_group("enemies", "take_damage", 10)

# Call with behavior flags
get_tree().call_group_flags(SceneTree.GROUP_CALL_DEFERRED, "ui", "refresh")
```

**Flags for `call_group_flags`:**

| Flag | Effect |
|---|---|
| `GROUP_CALL_DEFERRED` | Defer to end of frame — avoids state conflicts during physics/rendering |
| `GROUP_CALL_REVERSE` | Process nodes in reverse hierarchy order |
| `GROUP_CALL_UNIQUE` | Execute only once per frame (requires DEFERRED) — prevents duplicate calls |

Combine flags with `|`. Nodes in the group that lack the called method are silently skipped.

---

## Chapter 12: Autoloads

An **Autoload** is Godot's singleton pattern. Register a script in **Project Settings → Autoload**, give it a name, and Godot instantiates it once at startup — before any other scene loads — and makes it globally accessible by that name from any script.

### Registration

1. Create a script extending `Node`
2. **Project → Project Settings → Autoload**
3. Select the file, assign a name (e.g., `GameState`), enable it

```gdscript
# game_state.gd
extends Node

var players: Dictionary[Player, PlayerState] = {}
signal score_goal(player: Player)
signal reset_game
```

Access from anywhere:

```gdscript
GameState.score_goal.emit(player)
GameState.players[player].score += 1
```

### Initialization Order

Autoloads initialize **before any scene loads**, in the order listed in the Autoload tab. Their `_ready()` methods run before the main scene's `_ready()`. This makes them safe to access in any node's `_ready()`. If one autoload depends on another, place the dependency higher in the list.

### Self-Registration Pattern

Instead of the Autoload searching the tree, nodes register themselves:

```gdscript
# ball.gd
func _ready() -> void:
    GameState.ball = self
```

Simpler than groups or `find_child()` when there's only ever one of a given node.

### When to Use (and Not Use)

**Use autoloads for:** state that outlives any scene (scores, settings), signals coordinating unrelated scenes, global managers (audio, transitions).

**Don't use autoloads for:** scene-specific data (pass it as parameters), dumping all global code in one place (keep responsibilities focused).

**Never call `free()` or `queue_free()` on an autoload** — the engine will crash.

---

# Part IV — Input

## Chapter 13: Input

Godot wraps all hardware input into `InputEvent` objects routed through a unified pipeline. There are two complementary approaches: event callbacks and polling the `Input` singleton.

### The Input Pipeline

Events flow through these methods in order. Each can consume an event to stop further propagation:

| Method | Use for |
|---|---|
| `_input(event)` | Low-level, first-pass handling |
| `_gui_input(event)` | UI interaction on Control nodes |
| `_shortcut_input(event)` | Keyboard shortcuts |
| `_unhandled_key_input(event)` | Key events not yet consumed |
| `_unhandled_input(event)` | **Game input** — fires only after UI has had its chance |

For game logic, use `_unhandled_input()`. This prevents pressing a UI button from also triggering a gameplay action.

```gdscript
func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed:
        if event.keycode == KEY_R:
            get_tree().reload_current_scene()
```

### InputEvent Types

| Type | Represents |
|---|---|
| `InputEventKey` | Keyboard press/release; `keycode`, `pressed`, modifier keys |
| `InputEventMouseButton` | Mouse clicks and scroll; `button_index`, `pressed`, `position` |
| `InputEventMouseMotion` | Cursor movement; `position`, `relative`, `velocity` |
| `InputEventJoypadButton` | Gamepad buttons; `button_index`, `pressed` |
| `InputEventJoypadMotion` | Analog sticks/triggers; `axis`, `axis_value` |
| `InputEventScreenTouch` | Touch start/end; `index`, `position` |
| `InputEventScreenDrag` | Touch drag; `index`, `position`, `relative` |

### The Input Singleton

`Input` reflects current hardware state at any moment. Use it for continuous polling:

```gdscript
func _physics_process(_delta: float) -> void:
    if Input.is_action_pressed("move_left"):
        velocity.x = -speed
```

| Method | Returns | Use when |
|---|---|---|
| `is_action_pressed(action)` | `bool` — true while held | Continuous (movement) |
| `is_action_just_pressed(action)` | `bool` — true on first frame | One-shot (jump, fire) |
| `is_action_just_released(action)` | `bool` — true on release frame | Release detection |
| `get_axis(neg, pos)` | `float` (-1 to 1) | Keyboard directional input |
| `get_vector(neg_x, pos_x, neg_y, pos_y)` | `Vector2` (magnitude ≤ 1) | 2D directional input |

`get_vector` returns a Vector2 capped to unit length and supports an optional deadzone:

```gdscript
var dir := Input.get_vector("move_left", "move_right", "move_fwd", "move_back")
velocity = dir * speed
```

### InputMap: Actions vs Raw Keys

Configure named actions at **Project → Project Settings → Input Map** to decouple code from hardware:

```gdscript
Input.is_action_pressed("move_left")    # works with keyboard, gamepad, or remapped input
# vs
Input.is_key_pressed(KEY_LEFT)          # hardcoded keyboard only
```

Multiple inputs can map to one action (arrow keys + WASD). Actions can be remapped at runtime via `InputMap.action_add_event()` / `action_erase_events()`.

### Event Consumption

Stop an event from propagating further:

```gdscript
# In _input()
get_viewport().set_input_as_handled()

# In Control._gui_input()
accept_event()
```

`Input.is_action_pressed()` and other singleton methods reflect raw hardware state and are **never affected** by event consumption — they always report true input state.

---

# Part V — Math and Space

## Chapter 14: Vectors and Math

### Vector Types

Godot provides `Vector2`, `Vector3`, and `Vector4`. In a 3D project, `Vector3` is used for positions, directions, velocities, and offsets.

```gdscript
var pos := Vector3(1.0, 0.0, -2.5)
var up  := Vector3.UP       # named constants: ZERO, ONE, UP, DOWN, LEFT, RIGHT, FORWARD, BACK
pos.x   # 1.0
pos[0]  # same as pos.x
```

### Arithmetic

Vector math applies component-wise:

```gdscript
a + b          # displacement
a - b          # difference / direction from b to a
a * 2.0        # scale magnitude
-a             # reverse direction
a.dot(b)       # scalar: 1.0 = same direction, 0 = perpendicular, -1 = opposite
a.cross(b)     # Vector3 perpendicular to both (right-hand rule)
```

### Magnitude

```gdscript
v.length()           # magnitude (involves a square root)
v.length_squared()   # squared magnitude — faster; use for comparisons to avoid sqrt
v.normalized()       # unit vector: same direction, length = 1
v.limit_length(max)  # clamp magnitude without changing direction
```

Prefer `length_squared()` when comparing magnitudes:

```gdscript
if linear_velocity.length_squared() < min_speed * min_speed:
    linear_velocity = linear_velocity.normalized() * min_speed
```

### Direction and Distance

```gdscript
a.distance_to(b)    # scalar distance between two points
a.direction_to(b)   # normalized vector pointing from a toward b
```

### Physics Operations

```gdscript
v.slide(normal)    # remove the component perpendicular to normal (sliding along a wall)
v.reflect(normal)  # reflect v through the plane defined by normal
v.bounce(normal)   # like reflect, but points away from the surface
v.project(onto)    # component of v parallel to 'onto'
```

### Interpolation

```gdscript
lerp(a, b, t)            # linear blend; t=0 → a, t=1 → b (works for floats and vectors)
a.slerp(b, t)            # spherical lerp — constant angular speed, preserves magnitude
lerp_angle(a, b, t)      # lerp for angles (radians), handles wrap-around correctly
inverse_lerp(a, b, x)    # reverse: given x between a and b, returns its 0–1 position
```

`inverse_lerp` normalizes a value into [0, 1]. Combine with `lerp` to remap between ranges:

```gdscript
# Remap spring_length into a tilt angle
var t := inverse_lerp(min_zoom, max_zoom, spring_length)
rotation.x = lerp(tilt_near, tilt_far, t)
```

### Global Math Functions

| Function | Description |
|---|---|
| `abs(x)` | Absolute value |
| `sign(x)` | -1, 0, or 1 |
| `clamp(x, min, max)` | Restrict to range |
| `min(a, b)` / `max(a, b)` | Minimum / maximum |
| `floor(x)` / `ceil(x)` / `round(x)` | Rounding |
| `sqrt(x)` / `pow(x, y)` | Roots and powers |
| `sin(x)` / `cos(x)` / `tan(x)` | Trig (radians) |
| `atan2(y, x)` | Angle of a 2D vector; range [-π, π] |
| `deg_to_rad(deg)` | Degrees → radians |
| `rad_to_deg(rad)` | Radians → degrees |
| `randf_range(a, b)` | Random float in [a, b] |
| `randi_range(a, b)` | Random int in [a, b] |
| `snapped(x, step)` | Snap to nearest multiple of step |
| `is_equal_approx(a, b)` | Float-safe equality |
| `is_zero_approx(x)` | Float-safe zero check |

---

## Chapter 15: Transforms and Coordinate Space

### Transform3D

A `Transform3D` is a 3×4 matrix representing a complete 3D spatial transformation — position, rotation, and scale in one value:

```
Transform3D
├── basis: Basis   — 3×3 rotation and scale matrix (three Vector3 column axes)
└── origin: Vector3 — position (translation)
```

```gdscript
transform.basis    # rotation/scale
transform.origin   # position
Transform3D.IDENTITY  # no translation, no rotation, unit scale
```

### The Coordinate System

Godot 3D uses a **right-handed, Y-up coordinate system** matching OpenGL conventions:
- **+X** — right
- **+Y** — up
- **-Z** — forward (objects face -Z by default)
- **+Z** — back

### Local vs World Space

Every `Node3D` has two coordinate frames:

**Local space** — relative to the parent node:
- `position`, `rotation`, `scale`, `transform`

**World space** — absolute coordinates in the scene:
- `global_position`, `global_rotation`, `global_transform`

When nodes are parented, their world transform is `parent.global_transform * child.transform`.

```gdscript
global_position = Vector3.ZERO  # teleport to world origin
position = Vector3(1, 0, 0)     # move 1 unit right of parent
global_translate(offset)        # add offset to current world position
```

### Think in Basis Vectors

For robust rotation, prefer basis vectors over Euler angles. Euler angles suffer from **gimbal lock** and can produce unexpected interpolation. The basis axes tell you directly where the object is pointing:

```gdscript
-transform.basis.z   # forward direction (objects face -Z)
transform.basis.x    # right direction
transform.basis.y    # up direction
```

Rotations via Euler angles are convenient for simple cases; for anything animated or interpolated, work through `Basis` or `Quaternion`.

### look_at()

`look_at(target: Vector3, up: Vector3 = Vector3.UP)` rotates the node so its **-Z axis** points toward the target:

```gdscript
func _process(_delta: float) -> void:
    look_at(target.global_position)   # track a moving target every frame
```

The second parameter sets the reference up vector (defaults to `Vector3.UP`).

### Coordinate Conversion

```gdscript
to_global(local_pos)   # local → world
to_local(world_pos)    # world → local
```

### Interpolating Transforms

```gdscript
transform = transform.interpolate_with(target_transform, weight)
```

For smooth rotation without gimbal lock, interpolate through Quaternion:

```gdscript
var q_from := Quaternion(transform.basis)
var q_to   := Quaternion(target_transform.basis)
transform.basis = Basis(q_from.slerp(q_to, weight))
```

---

# Part VI — Physics

## Chapter 16: Physics Bodies

Godot's 3D physics provides five node types covering every simulation role.

### The Body Types

**`RigidBody3D`** — fully simulated. Has mass, responds to gravity, forces, and collisions. Motion is calculated by the engine; do not set `position` directly. Use for balls, crates, projectiles, and any dynamic object.

**`StaticBody3D`** — immovable. Doesn't respond to gravity or collisions. Other bodies bounce off it. Use for floors, walls, and terrain. Can be repositioned in code without disturbing the simulation. Special properties `constant_linear_velocity` and `constant_angular_velocity` push touching bodies without the body itself moving (conveyor belts, moving platforms).

**`AnimatableBody3D`** — like StaticBody3D but driven by animations or Tweens. Its velocity is estimated each physics frame and used to push other bodies. Use for animated doors and platforms. Do **not** use `move_and_collide()` on it.

**`CharacterBody3D`** — script-controlled. Not affected by gravity or external forces by default. Provides `move_and_slide()` for precise movement with slope detection and wall sliding. Exposes `is_on_floor()`, `is_on_ceiling()`, `is_on_wall()`. See Chapter 18.

**`Area3D`** — detects overlaps without physical blocking. Emits signals when bodies enter or leave. Use for triggers, pickups, damage zones, and scoring regions. Requires `monitoring = true` (default) to fire signals.

### RigidBody3D Properties

```gdscript
mass: float             # default 1.0 — affects inertia
gravity_scale: float    # default 1.0 — multiply gravity (0 = weightless)
linear_velocity: Vector3
angular_velocity: Vector3
linear_damp: float      # velocity reduction per second
angular_damp: float     # rotation reduction per second
lock_rotation: bool     # prevent all rotation
```

Axis locks prevent movement or rotation along specific world axes:

```gdscript
axis_lock_linear_y = true    # can't move up/down
axis_lock_linear_z = true    # can't move forward/back
axis_lock_angular_x = true   # can't pitch
```

For contact signals to fire, enable the contact monitor:

```gdscript
contact_monitor = true
max_contacts_reported = 4
body_entered.connect(_on_body_entered)
```

### Forces and Impulses

```gdscript
# Forces: applied continuously (per-frame thrust)
apply_central_force(force: Vector3)
apply_force(force: Vector3, position: Vector3 = Vector3.ZERO)

# Impulses: instantaneous kick
apply_central_impulse(impulse: Vector3)
apply_impulse(impulse: Vector3, position: Vector3 = Vector3.ZERO)

# Constant force applied every physics tick until cleared
add_constant_force(force: Vector3)
```

### Sleep and Freeze

`RigidBody3D` enters sleep mode when stationary to save performance; it wakes automatically when forces or collisions occur. Set `can_sleep = false` to keep it always active.

`freeze = true` disables gravity and forces entirely. `freeze_mode` controls whether the frozen body acts as a static or kinematic body.

---

## Chapter 17: Collision

### CollisionShape3D

Every physics body needs a `CollisionShape3D` child with a `Shape3D` resource:

```gdscript
var shape := BoxShape3D.new()
shape.size = Vector3(2.0, 0.5, 0.5)
$CollisionShape3D.shape = shape
```

The shape defines *where* the body collides; `MeshInstance3D` handles appearance separately. **Never** translate, rotate, or scale `CollisionShape3D` nodes in the scene tree — this breaks Godot's collision optimizations. Adjust the shape resource's dimensions instead.

To temporarily disable a shape without removing it:

```gdscript
$CollisionShape3D.set_deferred("disabled", true)
```

Use `set_deferred` to avoid conflicts with an in-progress physics step.

### Shape Types

| Shape | Best for | Performance |
|---|---|---|
| `BoxShape3D` | Rectangular objects | Fastest |
| `SphereShape3D` | Round objects | Fastest |
| `CapsuleShape3D` | Characters, pillars | Fast |
| `CylinderShape3D` | Wheels, barrels | Fast |
| Convex hull | Irregular roughly-convex objects | Moderate |
| Concave/trimesh | Complex static geometry | Slowest; StaticBody only |

Always use the simplest shape that fits. A box approximating a complex model is almost always preferable to a precise mesh shape on a dynamic body.

### Collision Layers and Masks

Every physics object has two 32-bit bitmasks:

- **`collision_layer`** — which layers this object *occupies*
- **`collision_mask`** — which layers this object *detects*

Two objects only interact when A's mask includes B's layer AND B's mask includes A's layer. Configure layer names at **Project Settings → Layer Names → 3D Physics**.

### Detection Signals

| Signal | Available on | Fires when |
|---|---|---|
| `body_entered(body)` | `RigidBody3D`, `Area3D` | A physics body enters the shape |
| `body_exited(body)` | same | A physics body leaves |
| `area_entered(area)` | `Area3D` | Another Area3D enters |
| `area_exited(area)` | same | Another Area3D exits |

```gdscript
func _ready() -> void:
    body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
    if body is Ball:
        GameState.score_goal.emit(player)
```

### PhysicsMaterial

Controls surface properties for `RigidBody3D`:

| Property | Default | Effect |
|---|---|---|
| `friction` | 1.0 | Grip; 0 = perfectly slippery |
| `bounce` | 0.0 | Energy returned; 1.0 = perfect elastic bounce |
| `rough` | false | When true, uses the highest friction of the two surfaces |
| `absorbent` | false | When true, subtracts bounce from colliding objects |

```gdscript
var mat := PhysicsMaterial.new()
mat.friction = 0.0
mat.bounce = 1.0
physics_material_override = mat
```

With `bounce = 1.0`, the ball conserves 100% of its kinetic energy on each collision. Note: `linear_damp` can still drain speed over time even at full bounce.

---

## Chapter 18: Character Movement

> *Locked — implement a CharacterBody3D controller to unlock this chapter.*

---

## Chapter 19: Navigation and Pathfinding

> *Locked — add a NavigationAgent to the project to unlock this chapter.*

---

# Part VII — Visuals

## Chapter 20: 3D Nodes and Meshes

### The 3D Coordinate System

Godot 3D uses a **right-handed, Y-up coordinate system** where one unit equals one meter. Physics accuracy depends on objects being reasonably close to real-world scale.

Axes: **+X** = right, **+Y** = up, **-Z** = forward. Objects face -Z by default.

### Node3D

`Node3D` is the base class for all 3D scene content. It provides `position`, `rotation`, `scale`, and `transform`. Every 3D node — physics bodies, lights, cameras, mesh instances — extends it.

### MeshInstance3D

`MeshInstance3D` is the visual component of a 3D object. It holds a `Mesh` resource and renders it at the node's world position. It has **no physics** — it only draws geometry.

```gdscript
var mesh_inst := $MeshInstance3D as MeshInstance3D
mesh_inst.mesh = BoxMesh.new()
mesh_inst.material_override = my_material
```

### Procedural Mesh Resources

Built-in mesh resources generate geometry without external files:

| Resource | Shape | Key properties |
|---|---|---|
| `BoxMesh` | Rectangular prism | `size: Vector3` |
| `SphereMesh` | Sphere | `radius`, `height`, `radial_segments`, `rings` |
| `CylinderMesh` | Cylinder | `top_radius`, `bottom_radius`, `height` |
| `CapsuleMesh` | Capsule | `radius`, `height` |
| `PlaneMesh` | Flat quad | `size: Vector2` |
| `TorusMesh` | Donut | `inner_radius`, `outer_radius` |

```gdscript
var mesh := BoxMesh.new()
mesh.size = Vector3(2.0, 0.5, 0.5)
$MeshInstance3D.mesh = mesh
```

In `@tool` scripts, updating mesh resource properties takes effect immediately in the editor without pressing Play.

### The Physics Object Pattern

```
RigidBody3D (or StaticBody3D / Area3D)
├── CollisionShape3D   ← physics boundary
└── MeshInstance3D     ← visual representation
```

The body owns position and physics simulation. The children describe shape and appearance. Keeping them separate lets you change or disable either independently.

### Syncing Shape to Node Scale

In a `@tool` script, drive both the collision and mesh sizes from the node's `scale` so a single resize in the editor updates everything:

```gdscript
func _update_size() -> void:
    var collision := get_node_or_null("CollisionShape3D") as CollisionShape3D
    if collision and collision.shape is BoxShape3D:
        (collision.shape as BoxShape3D).size = scale

    var mesh := get_node_or_null("MeshInstance3D") as MeshInstance3D
    if mesh and mesh.mesh is BoxMesh:
        (mesh.mesh as BoxMesh).size = scale
```

### WorldEnvironment

`WorldEnvironment` sets global rendering properties — sky, ambient light, tone mapping, fog, and post-processing. Typically a direct child of the scene root, it applies to all cameras in the scene.

---

## Chapter 21: Materials and Shading

### StandardMaterial3D

`StandardMaterial3D` is Godot's default Physically Based Rendering (PBR) surface shader. It models real-world material behavior with a small set of intuitive properties.

**Core PBR properties:**

| Property | Type | Effect |
|---|---|---|
| `albedo_color` | Color | Base color, multiplied with `albedo_texture` if set |
| `albedo_texture` | Texture2D | Base color texture |
| `metallic` | float (0–1) | 0 = dielectric (plastic/stone); 1 = metal (gold/steel) |
| `roughness` | float (0–1) | 0 = perfect mirror; 1 = fully diffuse |
| `emission` | Color | Self-emitted light |
| `emission_energy_multiplier` | float | Brightness of emission |

Most appearances come from combining `metallic` and `roughness`: brushed metal = high metallic + high roughness; mirror = high metallic + low roughness; plastic = low metallic + mid roughness.

**Transparency modes:**

| Mode | Use case |
|---|---|
| `TRANSPARENCY_DISABLED` | Fully opaque (fastest) |
| `TRANSPARENCY_ALPHA` | Smooth blending with depth sorting (slowest) |
| `TRANSPARENCY_ALPHA_SCISSOR` | Hard-edge cutout; casts shadows correctly |
| `TRANSPARENCY_ALPHA_HASH` | Dithered soft edges; shadow-capable |
| `TRANSPARENCY_DEPTH_PRE_PASS` | Best approximation for mostly-opaque objects |

**Shading modes:**
- `SHADING_MODE_PER_PIXEL` — default; full lighting per pixel
- `SHADING_MODE_PER_VERTEX` — performance optimization; interpolates lighting between vertices
- `SHADING_MODE_UNSHADED` — ignores all lighting; always shows flat albedo color

### Material Priority

Materials at four levels, highest wins:

1. `MeshInstance3D.material_override` — overrides everything for this instance
2. `MeshInstance3D` surface slot — overrides mesh default
3. Mesh resource's surface material — shared across all instances
4. `MeshInstance3D.material_overlay` — composites on top without replacing

### material_override for Per-Instance Color

Mesh resources are **shared** — two paddles using the same `BoxMesh` share one object. Changing the mesh's material changes both. Assign to `material_override` instead for per-instance materials:

```gdscript
func _update_color() -> void:
    var mesh := get_node_or_null("MeshInstance3D") as MeshInstance3D
    if mesh:
        var mat := StandardMaterial3D.new()
        mat.albedo_color = color
        mesh.material_override = mat
```

The `get_node_or_null` guard prevents a crash when this setter runs in the editor before children exist (this script uses `@tool`).

---

## Chapter 22: Lighting

### The Three Light Types

**`DirectionalLight3D`** — simulates a distant source like the sun. Rays are parallel and cover the entire scene. **Position is irrelevant — only rotation matters.** Most efficient light type. Uses Parallel Split Shadow Maps (PSSM) for shadow detail at varying distances.

**`OmniLight3D`** — spherical point source emitting in all directions. Light falls off over `omni_range`. `omni_attenuation` controls the falloff curve. `omni_size` enables area-light-style soft shadows.

**`SpotLight3D`** — cone of light. `spot_angle` (degrees) controls the half-width. `spot_angle_attenuation` softens the edges. Uses `spot_range` and `spot_attenuation` for distance falloff.

### Shared Properties

| Property | Effect |
|---|---|
| `light_color` | Color of emitted light |
| `light_energy` | Brightness multiplier |
| `light_indirect_energy` | Contribution to GI bounced light |
| `light_specular` | Specular highlight intensity; 0 = purely diffuse |
| `shadow_enabled` | Whether this light casts shadows |
| `shadow_bias` | Shift to prevent self-shadowing artifacts |
| `shadow_normal_bias` | Surface-normal-based bias — more robust than `shadow_bias`, reduces peter-panning |

### Tracking with look_at()

Because `SpotLight3D` extends `Node3D`, `look_at()` rotates it toward any world position:

```gdscript
func _process(_delta: float) -> void:
    if _paddle:
        look_at(_paddle.global_position)
```

Called every frame, this keeps the spotlight locked onto the paddle. The same pattern works for turrets, flashlights, or any "aim at target" effect.

### Shadow Bias

**`shadow_bias`** offsets shadow samples to prevent a surface from shadowing itself. Too low = shadow acne (flickering dark spots). Too high = peter-panning (shadows detach from objects).

**`shadow_normal_bias`** (generally preferred) shifts along the surface normal, avoiding peter-panning while still curing acne.

---

## Chapter 23: Cameras and Viewports

### Camera3D

`Camera3D` defines the player's viewpoint. Only one camera is active at a time per viewport. The first camera to enter the scene tree becomes active automatically. Set `current = true` explicitly to override.

| Property | Default | Effect |
|---|---|---|
| `fov` | 75° | Vertical field of view (perspective only). Lower = telephoto; higher = wide-angle. |
| `near` | 0.05 | Near clipping plane. Keep as large as practical — smaller values reduce depth buffer precision. |
| `far` | 4000.0 | Far clipping plane. Reduce to improve culling performance. |
| `projection` | Perspective | `PERSPECTIVE`, `ORTHOGONAL`, or `FRUSTUM` |

**Projection types:**
- **Perspective** — objects appear smaller with distance; natural 3D gameplay
- **Orthogonal** — consistent object size regardless of depth; isometric, top-down, or 2D-style 3D
- **Frustum** — shifted frustum for off-axis projection effects

### SpringArm3D

`SpringArm3D` is a camera mount that performs collision detection along its Z axis:

> "Casts a ray or a shape along its Z axis and moves all its direct children to the collision point, with an optional margin."

This prevents the camera from clipping through walls.

| Property | Default | Effect |
|---|---|---|
| `spring_length` | 1.0 | Maximum arm length from the pivot to the camera |
| `margin` | 0.01 | Gap between the detected collision point and the camera — prevents the camera from touching walls |

Exclude the player from collision detection:

```gdscript
func _ready() -> void:
    add_excluded_object(player_body.get_rid())
```

Without this, the player's own collider immediately collapses the arm to zero.

### Spring-Damper Camera Follow

A spring-damper tracks a target smoothly without snapping or oscillating:

```gdscript
@export var stiffness := 20.0
@export var damping := 5.0

var vel := 0.0

func _physics_process(delta: float) -> void:
    var acc := stiffness * (target.global_position.x - global_position.x) - damping * vel
    vel += acc * delta
    global_position.x += vel * delta
```

- **Stiffness** — how aggressively it accelerates toward the target
- **Damping** — how quickly it bleeds off velocity to prevent oscillation

When `damping ≈ 2 * sqrt(stiffness)`, the system is **critically damped** — fastest convergence with no overshoot.

### Tilt on Zoom

`inverse_lerp` converts `spring_length` into a 0–1 fraction to drive a tilt adjustment:

```gdscript
var t := inverse_lerp(min_zoom, max_zoom, spring_length)
rotation.x = lerp(_base_tilt + deg_to_rad(tilt_at_min_zoom), _base_tilt, t)
```

---

## Chapter 24: Particles and Visual Effects

> *Locked — add a particle emitter to the project to unlock this chapter.*

---

## Chapter 25: Shaders

> *Locked — write a custom shader to unlock this chapter.*

---

# Part VIII — User Interface

## Chapter 26: Control Nodes

### The UI System

Godot's UI is built from `Control` nodes — a 2D tree that renders on top of 3D content (via `CanvasLayer`). Controls don't use 3D transforms; they use a layout system based on **anchors** and **offsets**.

### CanvasLayer

`CanvasLayer` renders its children in a dedicated 2D layer independent of the 3D camera. Content inside stays fixed on screen.

The **`layer`** property (default: 1) controls draw order. Lower values render behind higher values. Standard gameplay lives at layer 0; a HUD at layer 1 always appears on top. Embedded editor windows appear at layer 1024.

`follow_viewport_enabled` (default: false for HUDs) keeps the layer screen-fixed. Set true for parallax backgrounds that scroll with the camera.

### Anchors and Offsets

Anchors define reference points on the parent using normalized coordinates (0.0 = left/top, 1.0 = right/bottom):

```
anchor_left, anchor_right, anchor_top, anchor_bottom  — each 0.0 to 1.0
```

A control anchored at (0, 0, 0, 0) positions relative to the parent's top-left corner. Anchors at (0, 1, 0, 1) make it stretch to fill the parent entirely.

**Offsets** are pixel distances from each anchor — fine-tuning after anchors set the primary reference point.

### Size Flags

Controls inside containers respond to size flags:

- `SIZE_FILL` — expand to fill available space
- `SIZE_SHRINK_CENTER` — stay at natural size, center in available space
- `SIZE_SHRINK_BEGIN` / `SIZE_SHRINK_END` — align to start or end

`size_flags_stretch_ratio` allocates proportional space when multiple controls have `SIZE_FILL`. A ratio of 2.0 gets twice the space of a ratio of 1.0.

### Label

Displays text. Update with `.text`:

```gdscript
$Score.text = "Player 1: 3"
$Score.text = "Line 1\nLine 2"
```

| Property | Effect |
|---|---|
| `text` | The displayed string |
| `horizontal_alignment` | Left, center, right, fill |
| `vertical_alignment` | Top, center, bottom, fill |
| `autowrap_mode` | Text wrapping within node bounds |
| `visible_characters` | Show only first N characters (typewriter effect) |
| `visible_ratio` | 0.0–1.0 fraction of characters shown |
| `uppercase` | Display all characters as capitals |

For styled text (bold, italic, BBCode colors), use `RichTextLabel`.

### Button

```gdscript
$StartButton.text = "Start Game"
$StartButton.pressed.connect(_on_start_pressed)

func _on_start_pressed() -> void:
    get_tree().change_scene_to_file("res://scenes/game.tscn")
```

The `pressed` signal fires on click, keyboard Enter/Space when focused, or gamepad confirm.

### Theme System

A `Theme` resource defines fonts, colors, and `StyleBox` visuals shared across all `Control` nodes that inherit it. Assign one Theme to a parent Control; all children inherit it unless they override locally. This enables consistent, project-wide style changes from a single resource.

### HUD Pattern

```gdscript
extends CanvasLayer

@onready var players = GameState.players

func update_score() -> void:
    var text := ""
    var i := 1
    for player in players:
        text += "Player " + str(i) + ": "
        text += str(players[player].score) + "\n"
        i += 1
    $Score.text = text

func _ready() -> void:
    update_score()
    GameState.score_goal.connect(func(_p): update_score())
    GameState.reset_game.connect(update_score)
```

The HUD doesn't know what caused the score to change — it only knows how to redraw itself. Autoload signals carry the event; the HUD reacts.

---

## Chapter 27: Menus and Screens

> *Locked — build a title screen or pause menu to unlock this chapter.*

---

# Part IX — Time and Motion

## Chapter 28: Tweens

> *Locked — tween a property in the project to unlock this chapter.*

---

## Chapter 29: AnimationPlayer

> *Locked — add an AnimationPlayer to the project to unlock this chapter.*

---

# Part X — Advanced

## Chapter 30: PackedScene and Runtime Instantiation

> *Locked — spawn a scene at runtime to unlock this chapter.*

---

## Chapter 31: Audio

> *Locked — add sound to the project to unlock this chapter.*

---

## Chapter 32: Saving and Loading Data

> *Locked — persist game data to disk to unlock this chapter.*

---

## Chapter 33: Editor Scripting

### @tool

Adding `@tool` at the top of a script makes it run **inside the Godot editor**, not just at runtime:

```gdscript
@tool
extends RigidBody3D
```

With `@tool`, all lifecycle methods — `_ready()`, `_process()`, property setters — execute while you're editing the scene. This enables live feedback: changing a `color` export variable in the Inspector immediately updates the visual without pressing Play.

### Engine.is_editor_hint()

When `@tool` is active, the script runs in both the editor and at runtime. Guard code that should only execute during gameplay:

```gdscript
func _ready() -> void:
    if Engine.is_editor_hint():
        return               # skip runtime setup when running in the editor
    GameState.ball = self    # only register during actual gameplay
```

### The Initialization-Order Trap

In `@tool` scripts, property setters can fire before child nodes exist — for example, when Godot loads the scene into the editor. A setter using `$ChildNode` will crash. Always use `get_node_or_null()` in setters that `@tool` might call at load time:

```gdscript
var color: Color:
    set(value):
        color = value
        var mesh := get_node_or_null("MeshInstance3D") as MeshInstance3D
        if mesh:
            mesh.material_override = _make_mat()
```

### Persistent Nodes from @tool Scripts

When `_ready()` creates child nodes programmatically in the editor, set their `owner` to save them with the scene:

```gdscript
func _ready() -> void:
    if not Engine.is_editor_hint():
        return
    var node := Node3D.new()
    add_child(node)
    node.owner = get_tree().edited_scene_root  # without this, the node won't survive a save
```

### Configuration Warnings

`_get_configuration_warnings()` returns strings displayed as yellow warning icons in the Scene dock:

```gdscript
func _get_configuration_warnings() -> PackedStringArray:
    var warnings := PackedStringArray()
    if not player:
        warnings.append("Player must be assigned in the Inspector.")
    return warnings
```

Call `update_configuration_warnings()` whenever the relevant condition may have changed (e.g., inside a property setter).

### Critical Caveats

**Dependency requirement:** Any script called by a `@tool` script must **also** have `@tool`. Calling a non-tool script from a tool script produces undefined behavior.

**No undo:** Modifications made by `@tool` code during editing don't integrate with the editor's undo/redo history. Use version control as a safety net.

**Don't call `queue_free()`:** Freeing nodes from tool code during editor initialization can crash the editor. Use `owner = null` to detach a node from the saved scene without freeing it.

**Inheritance:** `@tool` is **not inherited**. Extending a `@tool` script does not make the child script a tool — it must declare `@tool` itself.

### Use Cases in This Project

- **`paddle.gd`** — `@tool` gives live color preview when the `color` property is changed in the Inspector. `get_node_or_null` prevents a crash when the setter fires on scene load before `MeshInstance3D` exists.
- **`wall.gd`** — `@tool` syncs both `CollisionShape3D` and `MeshInstance3D` sizes to the node's `scale`, so resizing a wall in the editor updates the collision boundary and visual simultaneously.

---

# Part XI — Shipping

## Chapter 34: Debugging, Profiling, and Exports

> *Locked — profile or export the project to unlock this chapter.*
