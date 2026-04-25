extends Node

class PlayerState:
	var score = 0

var players: Dictionary[Player, PlayerState]
var ball: Ball

signal reset_game
func _reset_game() -> void:
	for player in players:
		players[player].score = 0
		
	if ball:
		ball._reset()
		
	reset_game.emit()

signal score_goal(player: Player)
func _score_goal(player: Player) -> void:
	if ball:
		ball._reset()
	
	var found_player = players[player]
	if found_player:
		found_player.score += 1

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_R:
		_reset_game()

func _ready() -> void:
	for node in get_tree().get_nodes_in_group("players"):
		players[node as Player] = PlayerState.new()

	score_goal.connect(_score_goal)
