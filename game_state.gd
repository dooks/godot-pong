extends Node

class PlayerState:
	var score = 0

var players: Dictionary[Player, PlayerState]
var ball: Ball

signal score_goal(player: Player)
func _score_goal(player: Player) -> void:
	if ball:
		ball._reset()
	
	var found_player = players[player]
	if found_player:
		found_player.score += 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for node in get_tree().get_nodes_in_group("players"):
		players[node as Player] = PlayerState.new()

	score_goal.connect(_score_goal)
