# Pong

A Pong game built with Godot 4.6.

## Requirements

- [Godot 4.6](https://godotengine.org/download/)

## Running

Open the project in Godot and press **F5**, or run the exported build from the `docs/` folder.

## Controls

| Key | Action |
|-----|--------|
| Left / Right Arrow | Move paddle |
| R | Reset game |

## Project Structure

| File | Purpose |
|------|---------|
| `scene1.tscn` | Main scene |
| `ball.gd` | Ball physics and reset logic |
| `paddle.gd` | Paddle movement |
| `player.gd` | Player node |
| `goal.gd` | Goal detection |
| `hud.gd` | Score display |
| `game_state.gd` | Autoload singleton — scores and game events |
| `stage_light.gd` | Stage lighting |
| `wall.gd` | Boundary walls |

## License

[MIT](LICENSE)
