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

A **scene** is a saved tree of nodes (`.tscn` file). Scenes are reusable templates — `paddle.tscn` can be instanced as many times as you want in other scenes. When instanced, Godot duplicates the whole subtree.

The **Scene Tree** is the live, running version of all loaded scenes merged into one hierarchy. At runtime, `get_tree()` gives you access to it. The scene-file boundaries disappear at runtime — it's all just nodes.

Scenes serve as both organization and reuse. A paddle, a wall, a goal — each lives in its own `.tscn` file and can be instanced wherever needed. The main scene assembles them together.

---

## Chapter 3: Nodes

Nodes are the atomic unit of everything in Godot. Every object in the editor is a node. Nodes have:

- A **type** that determines capabilities (`RigidBody3D`, `MeshInstance3D`, `CollisionShape3D`, etc.)
- A **name** used for tree navigation (e.g. `body.name == "WallN"`)
- A **parent/child relationship** to other nodes
- An optional attached **script**

Types form an inheritance chain: `RigidBody3D` → `PhysicsBody3D` → `CollisionObject3D` → `Node3D` → `Node`. Each level adds capabilities. When a script writes `extends RigidBody3D`, it gets all of that.

### Navigating the Tree

From a script, navigate the tree with:

| Syntax | Meaning |
|---|---|
| `$ChildName` | Shorthand for `get_node("ChildName")` — direct child |
| `$"../Sibling"` | Walk up with `..`, then down — like a file path |
| `get_node_or_null("Path")` | Safe version; returns `null` instead of crashing |
| `get_parent()` | Direct reference to the parent node |
| `get_tree()` | The global scene tree — access groups, change scenes, quit |

---

## Chapter 4: Resources

The "components" attached to nodes — collision shapes, physics materials, meshes — are **Resources**, not nodes. Resources are data objects that can be shared, saved to disk (`.tres` files), and assigned to node properties.

```gdscript
var mat := PhysicsMaterial.new()
mat.friction = 0.0
mat.bounce = 1.0
physics_material_override = mat
```

`PhysicsMaterial`, `BoxShape3D`, `BoxMesh`, `StandardMaterial3D` — all resources. You create them in code, configure their properties, and hand them to a node property. See Chapter 17 for physics materials in context and Chapter 21 for creating surface materials.

---

# Part II — GDScript

## Chapter 5: Scripts and Lifecycle

A script doesn't attach *alongside* a node — it **becomes** the node. Writing `extends RigidBody3D` means your class *is* a `RigidBody3D`, with added or overridden behavior.

**Lifecycle methods** Godot calls automatically:

| Method | When |
|---|---|
| `_ready()` | Once, when the node enters the tree (all children exist) |
| `_process(delta)` | Every frame |
| `_physics_process(delta)` | Every physics tick (fixed rate, independent of frame rate) |

`delta` is seconds since the last tick — multiplying movement by it makes speed frame-rate-independent.

---

## Chapter 6: Variables, Types, and Annotations

GDScript uses dynamic typing by default, but type hints give autocomplete and catch errors early:

```gdscript
var speed: float = 12.0
var name: String = "Player"
var active := true   # inferred type — still statically typed
```

Annotations (`@` prefix) modify how Godot treats a variable or function:

| Annotation | Effect |
|---|---|
| `@export var speed := 12.0` | Exposes the variable in the editor Inspector |
| `@onready var x := $Node` | Delays assignment until `_ready()` so the tree exists |
| `@export_range(0.0, 45.0, 0.5, "degrees") var tilt := 15.0` | Inspector slider with min, max, step, and display hint |

`@onready` is the standard pattern for node references — it guarantees the tree is fully built before the assignment runs. Without it, `$Node` in a field initializer would crash because children don't exist yet.

---

## Chapter 7: Class Names and Inheritance

`class_name` declares a global type name for a script. Any other script can then use it as a type without imports:

```gdscript
# player.gd
class_name Player
extends Node
```

```gdscript
# anywhere else
var p: Player
@export var player: Player
var players: Array[Player] = []
```

This enables autocomplete, type checking, and typed exports in the Inspector. The name is global across the project, so keep it unambiguous.

### Inner Classes

A class can be defined inside another script when it's only relevant to that file:

```gdscript
# game_state.gd
extends Node

class PlayerState:
    var score := 0

var state: Dictionary[Player, PlayerState] = {}
```

`PlayerState` is accessed as `GameState.PlayerState` from outside, or just `PlayerState` from within the same file.

---

## Chapter 8: Collections

### Arrays

```gdscript
var scores: Array[int] = [10, 20, 30]
var players: Array[Player] = []
```

| Operation | Code |
|---|---|
| Add to end | `scores.append(40)` |
| Remove from end | `scores.pop_back()` |
| Length | `scores.size()` |
| Contains | `scores.has(10)` |
| Index access | `scores[0]` |
| Iterate | `for s in scores:` |

Typed arrays (`Array[int]`, `Array[Player]`) are preferred — they give autocomplete and catch type errors early.

### Dictionaries

Dictionaries are key/value stores. Any value can be a key — including node references, which makes them useful for per-player state.

```gdscript
var state: Dictionary[Player, PlayerState] = {}
state[player] = PlayerState.new()
```

| Operation | Code |
|---|---|
| Get | `state[player]` |
| Safe get | `state.get(player, default)` |
| Contains key | `state.has(player)` |
| Remove key | `state.erase(player)` |
| Iterate | `for key in state:` |

Using a node as a key works by object identity. If the node is freed, its key becomes stale — only use node keys for state that lives and dies with the scene.

---

## Chapter 9: Coroutines and await

> *Locked — use `await` in a script to unlock this chapter.*

---

# Part III — Communication

## Chapter 10: Signals

Signals are Godot's event system — a node broadcasts something happened, and any other node can listen. No direct reference needed between broadcaster and listener.

```gdscript
body_entered.connect(_on_body_entered)    # connect a built-in signal
signal color_changed(new_color: Color)    # declare a custom signal
color_changed.emit(new_color)             # fire it
color_changed.connect(func(c): color = c) # connect with a lambda
```

Signals are defined at the class level and are always available on the node — they don't need `_ready()` to exist, only `connect()` does.

---

## Chapter 11: Groups

Groups are a lightweight tagging system. Any node can belong to any number of groups, set either in the editor (Node panel → Groups tab) or from code:

```gdscript
func _ready() -> void:
    add_to_group("players")
```

Query the tree by group from anywhere:

```gdscript
get_tree().get_nodes_in_group("players")    # Array of all matching nodes
get_tree().get_first_node_in_group("ball")  # First match
```

Broadcast a call to every member at once:

```gdscript
get_tree().call_group("players", "reset")
```

Groups are ideal when you need to find or message a category of nodes without holding direct references to each one.

---

## Chapter 12: Autoloads

An **Autoload** is Godot's singleton pattern. Register a script in **Project Settings → Autoload** and Godot instantiates it once at startup, making it globally accessible by name from any script:

```gdscript
# game_state.gd
extends Node

var scores: Dictionary = {}

func _ready() -> void:
    for node in get_tree().get_nodes_in_group("players"):
        scores[node] = 0
```

```gdscript
# anywhere
GameState.scores[player] += 1
```

Autoloads are the right place for state that outlives any individual scene: scores, settings, player data. Extend `Node` rather than a more specific type since they don't need a position or visual.

### Self-Registration

Rather than having the Autoload search the tree, nodes can register themselves in `_ready()`:

```gdscript
func _ready() -> void:
    GameState.ball = self
```

Simpler than `find_child` or groups when there's only ever one of a given node.

---

# Part IV — Input

## Chapter 13: Input

Godot abstracts all hardware (keyboard, mouse, gamepad, touch) behind a unified system. There are two layers.

### Polling

`Input` is a built-in singleton — globally accessible by name, always represents current hardware state. Use it for continuous actions like movement:

```gdscript
func _physics_process(_delta: float) -> void:
    if Input.is_key_pressed(KEY_LEFT):
        move(-1)
```

### Event-Driven

For one-shot actions (pause, reset, confirm), override `_unhandled_input()` which fires once per event:

```gdscript
func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventKey and event.keycode == KEY_R:
        reset()
```

### InputMap: Actions vs Raw Keys

Map abstract action names to physical inputs in **Project Settings → Input Map**, then test against the name instead of a raw key constant. This decouples logic from hardware — the same code works for keyboard, gamepad, or remapped keys:

```gdscript
Input.is_action_pressed("move_left")   # instead of is_key_pressed(KEY_LEFT)
```

### The Input Pipeline

1. Raw hardware event → wrapped in an `InputEvent`
2. Sent to `_input()` on nodes in the scene tree
3. Then to `_unhandled_input()` on nodes that didn't consume it
4. UI nodes consume events before game nodes see them

---

# Part V — Math and Space

## Chapter 14: Vectors and Math

`Vector3` is the fundamental 3D value — used for positions, directions, velocities, and offsets.

```gdscript
var pos := Vector3(1.0, 0.0, -2.5)   # x, y, z
var dir := Vector3.RIGHT              # shorthand constants: UP, DOWN, FORWARD, etc.
var len := pos.length()               # magnitude
var unit := pos.normalized()          # same direction, length = 1
var len_sq := pos.length_squared()    # cheaper than length() — avoids sqrt, good for comparisons
```

### Arithmetic

Vectors support standard operators applied component-wise:

```gdscript
var a := Vector3(1, 2, 3)
var b := Vector3(4, 5, 6)
a + b           # Vector3(5, 7, 9)
a * 2.0         # Vector3(2, 4, 6)
a.dot(b)        # scalar: 1*4 + 2*5 + 3*6 = 32
a.cross(b)      # perpendicular vector
```

`limit_length(max)` clamps the vector's magnitude without changing direction — useful for capping speed:

```gdscript
linear_velocity = (linear_velocity * 1.05).limit_length(max_speed)
```

### Interpolation

```gdscript
lerp(a, b, t)           # linear blend; t=0 → a, t=1 → b
lerp_angle(a, b, t)     # same but wraps correctly for angles (radians)
inverse_lerp(a, b, x)   # reverse: given x between a and b, returns its t (0–1)
```

`inverse_lerp` normalizes a value to a 0–1 range — for example, converting `spring_length` into a zoom fraction between `min_zoom` and `max_zoom`.

### Math Utilities

| Function | Purpose |
|---|---|
| `abs(x)` | Absolute value |
| `sign(x)` | -1, 0, or 1 depending on sign |
| `clamp(x, min, max)` | Restrict to range |
| `deg_to_rad(deg)` | Degrees → radians |
| `rad_to_deg(rad)` | Radians → degrees |
| `atan2(y, x)` | Angle of a 2D vector in radians |
| `randf_range(a, b)` | Random float between a and b |
| `randi_range(a, b)` | Random int between a and b |

---

## Chapter 15: Transforms and Coordinate Space

### Local vs World Space

Every `Node3D` has two coordinate systems:

- **Local space** — relative to the parent node. `position` is in local space.
- **World space** — absolute position in the scene. `global_position` is in world space.

Use `global_position` when comparing positions between unrelated nodes. Use `position` when positioning relative to a parent.

### Setting Position

```gdscript
global_position = Vector3.ZERO    # teleport to world origin
position = Vector3(1, 0, 0)       # set local position relative to parent
global_translate(offset)          # add offset to current world position
```

`global_translate` is not the same as setting `global_position` — it *adds* to the current position.

### Rotation

```gdscript
rotation          # Euler angles in radians (Vector3)
rotation_degrees  # same in degrees
```

Godot uses radians internally. Convert with `deg_to_rad()` and `rad_to_deg()` when working with human-readable angles.

### Pointing at a Target

```gdscript
look_at(target_global_position)
```

`look_at()` rotates the node so its forward axis faces the given world position. Called each frame in `_process()`, it makes a node continuously track a moving target — how `stage_light.gd` keeps the spotlight on the paddle.

---

# Part VI — Physics

## Chapter 16: Physics Bodies

Three types of physics body cover different simulation roles:

| Type | Behavior |
|---|---|
| `RigidBody3D` | Fully simulated — has mass, responds to gravity, forces, and collisions |
| `StaticBody3D` | Immovable geometry — walls, floors, obstacles |
| `Area3D` | Detects overlaps; does not physically block anything |

Every physics body needs child nodes to function:

- **`CollisionShape3D`** — defines the shape used for collision detection (see Chapter 17)
- **`MeshInstance3D`** — defines the visual (see Chapter 20)

These are always separate child nodes. Visual, physical, and logical concerns are never the same node.

### RigidBody3D

Drive a `RigidBody3D` through physics properties, not by setting `position` directly:

```gdscript
linear_velocity = Vector3(speed, 0, 0)
gravity_scale = 0.0         # disable gravity
linear_damp = 0.0           # no drag
contact_monitor = true      # required to receive body_entered signal
max_contacts_reported = 1
```

Axis locks constrain physics freedom — locking Y and Z linear axes keeps a paddle on its horizontal rail:

```gdscript
axis_lock_linear_y = true
axis_lock_linear_z = true
```

### Area3D

`Area3D` does not participate in physics simulation — nothing bounces off it. It only detects when other bodies enter or exit its shape. Use it for goal zones, triggers, and pickups.

---

## Chapter 17: Collision

### Collision Shapes

A `CollisionShape3D` node needs a **shape resource** assigned:

```gdscript
var shape := BoxShape3D.new()
shape.size = Vector3(1, 1, 1)
$CollisionShape3D.shape = shape
```

Common shapes: `BoxShape3D`, `SphereShape3D`, `CapsuleShape3D`. Use the simplest shape that fits — simpler shapes cost less to simulate.

### Collision Layers and Masks

Every physics object has a **layer** (what it *is*) and a **mask** (what it *sees*). Two objects only interact when one's mask includes the other's layer. Configure layer names in **Project Settings → Layer Names → 3D Physics**.

### Detection Signals

| Signal | Source | Fires when |
|---|---|---|
| `body_entered(body)` | `RigidBody3D`, `Area3D` | A physics body enters the shape |
| `body_exited(body)` | same | A physics body leaves the shape |
| `area_entered(area)` | `Area3D` | Another `Area3D` enters |

```gdscript
func _ready() -> void:
    body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
    if body is Ball:
        score()
```

### Physics Materials

`PhysicsMaterial` controls surface behavior for `RigidBody3D`:

```gdscript
var mat := PhysicsMaterial.new()
mat.friction = 0.0    # no friction — ball doesn't slow on contact
mat.bounce = 1.0      # 100% energy conserved on bounce
physics_material_override = mat
```

`bounce = 1.0` gives perfectly elastic collisions — the ball never loses speed to walls or paddles.

---

## Chapter 18: Character Movement

> *Locked — implement a CharacterBody3D controller to unlock this chapter.*

---

## Chapter 19: Navigation and Pathfinding

> *Locked — add a NavigationAgent to the project to unlock this chapter.*

---

# Part VII — Visuals

## Chapter 20: 3D Nodes and Meshes

### Node3D

`Node3D` is the base class for everything in 3D space. It holds position, rotation, and scale. Every 3D node — physics bodies, lights, cameras — extends it.

### MeshInstance3D

`MeshInstance3D` is the visual component of a 3D object. It holds a **mesh resource** and renders it at the node's world position:

```gdscript
var mesh_instance := $MeshInstance3D as MeshInstance3D
mesh_instance.material_override = mat
```

`MeshInstance3D` has no physics — it only renders. It always lives as a child of a physics body, which provides the position it renders at.

### BoxMesh

`BoxMesh` is a built-in procedural mesh resource — no external file needed:

```gdscript
var mesh := BoxMesh.new()
mesh.size = Vector3(2.0, 0.5, 0.5)
$MeshInstance3D.mesh = mesh
```

In `@tool` scripts, updating `mesh.size` takes effect immediately in the editor without running the game.

### The Physics Object Pattern

Every physics object separates three concerns into child nodes under a body root:

```
RigidBody3D (or StaticBody3D)
├── CollisionShape3D   ← defines hit area
└── MeshInstance3D     ← defines what's drawn
```

The body owns position and physics. The children describe shape and appearance. Keeping them separate means you can change the visual or collision independently.

### Syncing Shape to Scale

In a `@tool` script, the collision shape and mesh can both be driven from the node's `scale` so resizing in the editor updates everything at once:

```gdscript
func _update_size() -> void:
    var collision := get_node_or_null("CollisionShape3D") as CollisionShape3D
    if collision and collision.shape is BoxShape3D:
        (collision.shape as BoxShape3D).size = scale

    var mesh := get_node_or_null("MeshInstance3D") as MeshInstance3D
    if mesh and mesh.mesh is BoxMesh:
        (mesh.mesh as BoxMesh).size = scale
```

---

## Chapter 21: Materials and Shading

### StandardMaterial3D

`StandardMaterial3D` is Godot's default surface shader. For flat color:

```gdscript
func _make_mat() -> StandardMaterial3D:
    var mat := StandardMaterial3D.new()
    mat.albedo_color = color
    return mat
```

`albedo_color` is the base color. For textured objects, assign a `Texture2D` to `albedo_texture` instead.

### material_override

Assigning to `material_override` on a `MeshInstance3D` replaces the mesh's material for that instance only:

```gdscript
mesh.material_override = _make_mat()
```

This matters because mesh resources are shared by default — if two paddles share the same `BoxMesh` and you change the mesh's material, both change. `material_override` breaks that sharing for the specific instance.

### Creating Materials in Code

The paddle creates a new material every time the color property changes:

```gdscript
var color: Color:
    set(value):
        color = value
        var mesh := get_node_or_null("MeshInstance3D") as MeshInstance3D
        if mesh:
            mesh.material_override = _make_mat()
```

The `get_node_or_null` guard is essential here because the setter can fire in the editor (the script uses `@tool`) before child nodes exist.

---

## Chapter 22: Lighting

### SpotLight3D

`SpotLight3D` casts a cone of light from its position. Key properties:

- `spot_angle` — half-angle of the cone in degrees
- `spot_range` — how far the light reaches
- `energy` — brightness multiplier

### Tracking a Target

`SpotLight3D` extends `Node3D`, so `look_at()` rotates it to face any world position:

```gdscript
func _process(_delta: float) -> void:
    if _paddle:
        look_at(_paddle.global_position)
```

Called every frame, this makes the light continuously track the paddle as it moves.

### Light Types

| Type | Shape | Use case |
|---|---|---|
| `DirectionalLight3D` | Parallel rays, infinite distance | Sun, moon, outdoor scenes |
| `OmniLight3D` | Sphere (all directions) | Lamps, explosions, pickups |
| `SpotLight3D` | Cone | Stage lights, flashlights |

---

## Chapter 23: Cameras and Viewports

### Camera3D

The active `Camera3D` determines what the player sees. Only one camera is active at a time. Set `current = true` in the Inspector or from script to activate it.

`Camera3D` is typically a child of a `SpringArm3D` or placed directly in the scene tree.

### SpringArm3D

`SpringArm3D` is a camera mount. The "spring" refers to the arm collapsing when geometry is in the way, then extending back to `spring_length`. It prevents the camera from clipping through walls.

`spring_length` is the desired distance from the pivot to the camera — increase it to zoom out:

```gdscript
if Input.is_key_pressed(KEY_DOWN):
    spring_length = min(spring_length + zoom_speed * delta, max_zoom)
if Input.is_key_pressed(KEY_UP):
    spring_length = max(spring_length - zoom_speed * delta, min_zoom)
```

### Spring-Damper Camera Follow

A spring-damper makes the camera follow a target smoothly without rigid snapping or indefinite oscillation:

```gdscript
@export var stiffness := 20.0
@export var damping := 5.0

var vel := 0.0

func _physics_process(delta: float) -> void:
    var acc := stiffness * (target.global_position.x - global_position.x) - damping * vel
    vel += acc * delta
    global_position.x += vel * delta
```

- **Stiffness** — how aggressively it accelerates toward the target.
- **Damping** — how quickly it bleeds off velocity to avoid oscillation.

Higher stiffness relative to damping gives a snappier follow. When `damping ≈ 2 * sqrt(stiffness)`, the system is critically damped — fastest convergence with no overshoot.

### Tilt on Zoom

`inverse_lerp` converts `spring_length` into a normalized zoom fraction, which can drive a tilt adjustment so the camera angles down as it zooms out:

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

### CanvasLayer

`CanvasLayer` renders 2D content on top of the 3D world, completely independent of the 3D camera. Content inside it stays fixed on screen — it doesn't move when the camera moves.

A `CanvasLayer` is the root of a HUD or overlay scene. Extend it with `extends CanvasLayer` and add UI nodes as children.

### Label

`Label` displays text. Update it by setting `.text`:

```gdscript
$Score.text = "Player 1: 3\nPlayer 2: 1"
```

`$Score` assumes a `Label` node named "Score" is a direct child of the `CanvasLayer`.

### HUD Pattern

The HUD knows how to redraw itself; it doesn't know what caused the change. The Autoload fires signals; the HUD reacts:

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

Adding `@tool` at the top of a script makes it run inside the editor, not just at runtime:

```gdscript
@tool
extends RigidBody3D
```

This is how changing `color` in the Inspector immediately recolors the paddle without pressing Play — the script is live in the editor.

### Engine.is_editor_hint()

When `@tool` is active, all lifecycle methods run in the editor. Guard logic that should only run at runtime:

```gdscript
func _ready() -> void:
    if Engine.is_editor_hint():
        return
    setup_game_logic()
```

### The Initialization-Order Trap

In a `@tool` script, property setters can fire before child nodes exist — for example, when the scene loads in the editor. Using `$ChildNode` in a setter that runs at editor load will crash. Always use `get_node_or_null()`:

```gdscript
var color: Color:
    set(value):
        color = value
        var mesh := get_node_or_null("MeshInstance3D") as MeshInstance3D
        if mesh:
            mesh.material_override = _make_mat()
```

The `if mesh:` guard makes this safe to call at any point during the editor's initialization.

### Use Cases in This Project

- **`paddle.gd`** — `@tool` makes color changes preview live in the Inspector; `get_node_or_null` prevents a crash when the setter fires on scene load.
- **`wall.gd`** — `@tool` syncs both the `CollisionShape3D` and `MeshInstance3D` sizes to `scale`, so resizing a wall in the editor updates its collision and visual together.

---

# Part XI — Shipping

## Chapter 34: Debugging, Profiling, and Exports

> *Locked — profile or export the project to unlock this chapter.*
