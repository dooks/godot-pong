# Godot Fundamentals

Concepts learned building the Pong project.

---

## The Scene Tree

A **scene** is a saved tree of nodes (`.tscn` file). Scenes are reusable templates — `paddle.tscn` can be instanced as many times as you want in other scenes. When instanced, Godot duplicates the whole subtree.

The **Scene Tree** is the live, running version of all loaded scenes merged into one hierarchy. At runtime, `get_tree()` gives you access to it. The scene-file boundaries disappear at runtime — it's all just nodes.

---

## Nodes

Nodes are the atomic unit of everything in Godot. Every object in the editor is a node. Nodes have:

- A **type** that determines capabilities (`RigidBody3D`, `MeshInstance3D`, `CollisionShape3D`, etc.)
- A **name** used for tree navigation (e.g. `body.name == "WallN"`)
- A **parent/child relationship** to other nodes
- An optional attached **script**

Types form an inheritance chain: `RigidBody3D` → `PhysicsBody3D` → `CollisionObject3D` → `Node3D` → `Node`. Each level adds capabilities. When a script writes `extends RigidBody3D`, it gets all of that.

---

## Scripts

A script doesn't attach *alongside* a node — it **becomes** the node. Writing `extends RigidBody3D` means your class *is* a `RigidBody3D`, with added or overridden behavior.

**Lifecycle methods** Godot calls automatically:

| Method | When |
|---|---|
| `_ready()` | Once, when the node enters the tree (all children exist) |
| `_process(delta)` | Every frame |
| `_physics_process(delta)` | Every physics tick (fixed rate, independent of frame rate) |

`delta` is seconds since the last tick — multiplying movement by it makes speed frame-rate-independent.

---

## Resources

The "components" attached to nodes — meshes, collision shapes, physics materials — are **Resources**, not nodes. Resources are data objects that can be shared, saved to disk (`.tres` files), and assigned to node properties.

```gdscript
var mat := PhysicsMaterial.new()
mat.friction = 0.0
mat.bounce = 1.0
physics_material_override = mat
```

`PhysicsMaterial`, `BoxShape3D`, `BoxMesh`, `StandardMaterial3D` — all resources. You create them, configure them, and hand them to a node property.

---

## Annotations

Annotations (`@` prefix) modify how Godot treats a variable or function:

| Annotation | Effect |
|---|---|
| `@export var speed := 12.0` | Exposes the variable in the editor Inspector |
| `@onready var x := $Node` | Delays assignment until `_ready()` so the tree exists |
| `@tool` | Makes the script run in the editor, not just at runtime |

`@tool` is why changing `color` in the Inspector immediately recolors the paddle without playing the game.

---

## Class Names and Typed References

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

## Positions and Transforms

`global_position` is the node's absolute position in world space. Set it directly to teleport:

```gdscript
global_position = Vector3.ZERO  # move to world origin
```

Contrast with:
- `position` — local position relative to parent
- `global_translate(offset)` — moves *by* an offset from current position, does not set an absolute location

---

## Physics Node Structure

The three concerns of a physics object are always separate child nodes:

- **`RigidBody3D`** (root) — participates in physics simulation; has mass, velocity, responds to forces
- **`CollisionShape3D`** (child) — defines the shape used for collision detection
- **`MeshInstance3D`** (child) — defines what gets rendered

Visual, physical, and logical concerns are separate nodes in the same subtree. The parent coordinates them.

`axis_lock_*` properties constrain physics freedom — locking Y and Z linear axes keeps a paddle on its horizontal rail. Use `StaticBody3D` instead of `RigidBody3D` for immovable geometry like walls.

---

## Node Navigation

From a script, navigate the tree with:

| Syntax | Meaning |
|---|---|
| `$ChildName` | Shorthand for `get_node("ChildName")` — direct child |
| `$"../Sibling"` | Walk up with `..`, then down — like a file path |
| `get_node_or_null("Path")` | Safe version; returns `null` instead of crashing |
| `get_parent()` | Direct reference to the parent node |

---

## Signals

Signals are Godot's event system — a node broadcasts something happened, and any other node can listen. No direct reference needed between broadcaster and listener.

```gdscript
body_entered.connect(_on_body_entered)   # built-in signal
signal color_changed(new_color: Color)   # custom signal
color_changed.emit(new_color)            # fire it
color_changed.connect(func(c): color = c) # lambda callback
```

Signals are defined at the class level and are always available on the node — they don't need `_ready()` to be set up.

---

## Groups

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

## Input

Godot abstracts all hardware (keyboard, mouse, gamepad, touch) behind a unified system. There are two layers.

### Polling

`Input` is a built-in singleton — globally accessible by name, always represents current hardware state. Use it for continuous actions like movement:

```gdscript
func _physics_process(_delta: float) -> void:
    if Input.is_key_pressed(KEY_LEFT):
        move(-1)
```

### Event-Driven

For one-shot actions (jump, shoot, pause), override `_input()` which fires once per event:

```gdscript
func _input(event: InputEvent) -> void:
    if event.is_action_pressed("jump"):
        jump()
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

## Arrays and Dictionaries

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

Dictionaries are key/value stores. Any value can be a key — including Node references, which makes them useful for per-player state.

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

Using a Node as a key works by object identity. If the node is freed, its key becomes stale — only use node keys for state that lives and dies with the scene.

---

## Autoloads

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

## To Learn in Practice

Concepts to explore by adding them to Pong. Once implemented, each can become a full section above.

- **`@tool` and `Engine.is_editor_hint()`** — Understand when scripts run in the editor vs. at runtime, and how to guard logic appropriately. We used this but ran into subtle initialization-order issues.
- **PackedScene / runtime instantiation** — Spawn a particle or visual effect when the ball hits a paddle
- **Control nodes (UI)** — Add a scoreboard that displays the current score using `Label` nodes
- **AnimationPlayer / Tweens** — Tween the ball's scale or flash a paddle on hit; tween the score label when it updates
- **`await` / coroutines** — Pause and reset the round after a point is scored with a countdown (`3… 2… 1…`) without blocking other game logic
